
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
  class Movie
    def rotation=(value)
      set_rotation @stream, value
      reset_stream
    end
    
    def rotation
      rotation = get_rotation @stream
      reset_stream
      rotation
    end
    
    def initialize(options, &block)
      if options[:file_name] && block
        @stream = File.open(options[:file_name], File::RDWR)
        @owns_stream = true
      elsif options[:stream]
        @stream = options[:stream]
      else
        raise "Neither file_name with block nor stream specified"
      end

      block.call self
      
      @stream.close if @owns_stream && block
    end
    
    private
    def reset_stream
      @stream.seek(0, IO::SEEK_SET) if @owns_stream
    end
  end
end
