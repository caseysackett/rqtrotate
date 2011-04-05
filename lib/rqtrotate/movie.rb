
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
  # core object to managing movie rotation. represents a stream
  # of quicktime data.
  class Movie
    attr_accessor :stream
    
    # set (modify) the rotation in the structure matrix of the movie
    def rotation=(value)
      set_rotation @stream, value
      reset_stream
    end
    
    # read the rotation value from the structure of the movie
    def rotation
      rotation = get_rotation @stream
      reset_stream
      rotation
    end

    # open a movie so the caller can perform actions within the block,
    # namely getting or setting the rotation. close when done.
    def self.open(file_name, &block)
      movie = Movie.new(File.open(file_name, File::RDWR), true)
      block.call movie      
      movie.stream.close
    end
    
    # constructor. accept a stream of movie data and allow caller
    # to specify ownership
    def initialize(stream, owns_stream = false)
      @stream = stream
      @owns_stream = owns_stream
    end
    
    private
    # if being called in an open block we own the stream so we'll 
    # reset it so future operations can start at the begining.
    def reset_stream
       @stream.seek(0, IO::SEEK_SET) if @owns_stream
    end
  end
end
