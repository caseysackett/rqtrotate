
# ruby's unpack can't extract signed big-endian longs
# (although I'm going to submit a patch to ruby-core to do so).
# this patch compensates for that.
class String
  def signed_bigendian_unpack()
    arr = self.unpack("C*")
    result = []

    # the data is big-endian (netowrk order). if we're on a
    # little endian platform we'll have	to reverse the bytes
    if [1, 0].pack("N*") == [1, 0].pack("L*")
      result = arr
    else
      arr.each_slice(4) do |slice|
        result += slice.reverse
      end
    end

    result.pack('c*').unpack("l*")
  end
end

class Array
  def signed_bigendian_pack()
    if [1, 0].pack("N*") == [1, 0].pack("L*")
      pack('c*')     
    else
      result = ''
      
      each do |i|
        br = ''
        
        4.times do
          br << (i & 0xFF)
          i >>= 8
        end
                
        result << br.reverse! 
      end
      
      result
    end
  end
end