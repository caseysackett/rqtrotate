# Copyright 2011 The Skunkworx.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module RQTRotate
  # Read a single atom and return an array of [size, type].
  def read_atom(stream)
    stream.read(8).unpack("NA4")
  end

  # return a list of top-level atoms and their absolute
  # positions
  def get_index(stream)
    index = []

    while not stream.eof?
      atom_size, atom_type = read_atom(stream)
      index << [atom_type, stream.pos - 8, atom_size]

      if atom_size < 8
        break
      else
        stream.seek(atom_size - 8 , IO::SEEK_CUR)
      end
    end

    top_level_atoms = index.collect{|atom| atom[0]}
  
    ['ftyp', 'moov', 'mdat'].each do |atom_type|
      if not top_level_atoms.include?(atom_type)
        print "#{atom_type} atom not found, is this a valid MOV/MP4 file?"
        exit(1)
      end
    end

    index
  end

  # read through the stream and yield each atom to the
  # specified block
  def find_atoms(size, stream, &block)
    stop = stream.pos + size
    
    while stream.pos < stop
      atom_size, atom_type = read_atom(stream)

      exit(1) if atom_size == 0

      # 'trak's contiain child atoms
      if atom_type == 'trak'
        find_atoms(atom_size - 8, stream) do |sub_atom_type|
          block.call sub_atom_type
        end
      elsif ['mvhd', 'tkhd'].include?(atom_type)
        block.call atom_type
      else
        stream.seek(atom_size - 8, IO::SEEK_CUR)
      end
    end
  end

  # determine if an existing stream is rotated  
  def get_rotation(stream)
    degrees = []

    process_stream(stream) do |atom_type, matrix|
      9.times do |i|
        if (i + 1) % 3 == 0
          matrix[i] = matrix[i].to_f / (1 << 30)
        else
          matrix[i] = matrix[i].to_f / (1 << 16)
        end
      end

      if ['mvhd', 'tkhd'].include?(atom_type)
        deg = -(Math::asin(matrix[3]) * (180.0 / Math::PI)) % 360
        deg = (Math::acos(matrix[0]) * (180.0 / Math::PI)) if deg == 0
        degrees << deg if deg != 0
      end        
    end
    
    if degrees.count == 0
      0
    elsif degrees.uniq.count == 1
      degrees.pop
    else
      -1
    end
  end
  
  # take an existing stream and rotate it
  def set_rotation(stream, rotation)
    process_stream(stream) do |atom_type, matrix|
      if atom_type == 'tkhd'
        rad = rotation * Math::PI / 180.0
        cos_deg = ((1 << 16) * Math::cos(rad)).to_i
        sin_deg = ((1 << 16) * Math::sin(rad)).to_i

        # pending patch acceptance to pack.c
        # value = [cos_deg, sin_deg, 0, -sin_deg, cos_deg, 0, 0, 0, (1 << 30)].pack("O9")
        value = [cos_deg, sin_deg, 0, -sin_deg, cos_deg, 0, 0, 0, (1 << 30)].signed_bigendian_pack()
        
        stream.seek(-36, IO::SEEK_CUR)
        stream.write(value)
      else
        9.times do |i|
          if (i + 1) % 3 == 0
            matrix[i] = matrix[i].to_f / (1 << 30)
          else
            matrix[i] = matrix[i].to_f / (1 << 16)
          end
        end        
      end
    end
  end

  # core of the whole thing. find all relevant atoms
  # and yield to consumers
  def process_stream(stream, &block)
    index = get_index(stream)
    moov_size = -1

    index.each do |atom, pos, size| 
      if atom == 'moov'
        moov_size = size
        stream.seek(pos + 8)
        break
      end
    end

    find_atoms(moov_size - 8, stream) do |atom_type|
      vf = stream.read(4)
      version = vf.unpack("C4")[0]
      flags = vf.unpack("N")[0] & 0x00ffffff

      if version == 1
        if atom_type == 'mvhd'
          stream.read(28)
        elsif atom_type == 'tkhd'
          stream.read(32)
        end
      elsif version == 0
        if atom_type == 'mvhd'
          stream.read(16)
        elsif atom_type == 'tkhd'
          stream.read(20)
        end
      end

      stream.read(16)
      raw = stream.read(36)
      # matrix = raw.unpack('O*') # pending patch acceptance to pack.c
      matrix = raw.signed_bigendian_unpack

      block.call atom_type, matrix
      
      if atom_type == 'mvhd'
        stream.read(28)
      elsif atom_type == 'tkhd'
        stream.read(8)
      end
    end # find_atoms
  end  # process_stream
end # module
