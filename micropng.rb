#!/usr/local/bin/ruby -w
#==============================================================================
#	NAME:
#		micropng.rb
#
#	DESCRIPTION:
#		Single-function minimal PNG exporter.
#
#	COPYRIGHT:
#		Copyright (c) 2019, refNum Software
#		All rights reserved.
#
#		Redistribution and use in source and binary forms, with or without
#		modification, are permitted provided that the following conditions
#		are met:
#		
#		1. Redistributions of source code must retain the above copyright
#		notice, this list of conditions and the following disclaimer.
#		
#		2. Redistributions in binary form must reproduce the above copyright
#		notice, this list of conditions and the following disclaimer in the
#		documentation and/or other materials provided with the distribution.
#		
#		3. Neither the name of the copyright holder nor the names of its
#		contributors may be used to endorse or promote products derived from
#		this software without specific prior written permission.
#		
#		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#		"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#		LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#		A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#		HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#		SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#		LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#		DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#		THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#		(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#		OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#==============================================================================
# Imports
#------------------------------------------------------------------------------
require 'zlib';





#==============================================================================
#		savePNG : Export an image array to a PNG file.
#------------------------------------------------------------------------------
#		Note :	The image is an array of scanlines, where each scanline is an
#				array of pixels.
#
#				Each pixel contains 3 (RGB) or 4 (RGBA) values between 0..255.
#------------------------------------------------------------------------------
def savePNG(theFile, theImage)

	# Get the image spec
	theHeight   = theImage.size;
	theWidth    = theImage[0].size;
	numChannels = theImage[0][0].size;



	# Filter the image
	#
	# We use the null filter, so just prefix each scanline with 0.
	pixelData = Array.new();

	theImage.each do |scanLine|
		pixelData << 0;
		
		scanLine.each do |thePixel|
			pixelData.concat(thePixel);
		end
	end

	pixelData = pixelData.pack("C*");



	# PNG chunk encoder
	#
	# Each chunk has a header, payload, and trailer.
	def pngChunk(type, data)
        header  = [data.length].pack("N");
		payload = type.bytes.pack("CCCC") + data;
		trailer = [Zlib.crc32(payload)].pack("N");

		return(header + payload + trailer);
	end



	# Encode the File
	#
	# A minimal .png has a signature followed by header, data, and end chunks.
	sigPNG  = [137, 80, 78, 71, 13, 10, 26, 10];
	colType = (numChannels == 3 ? 2 : 6);

	theData = sigPNG.pack("C*");
	theData += pngChunk("IHDR", [theWidth, theHeight, 8, colType, 0, 0, 0].pack("NNCCCCC"));
	theData += pngChunk("IDAT", Zlib.deflate(pixelData));
	theData += pngChunk("IEND", "");

	File.write(theFile, theData);

end





#==============================================================================
# Example
#------------------------------------------------------------------------------
# Example image
theImage = Array.new();

for y in 0...600
	scanLine = Array.new();
	
	for x in 0...800
		scanLine << [50 + (x % 200), 50 + ((x / 200) * 40), 50 + (y % 200)];
	end
	
	theImage << scanLine;
end


# Save it
savePNG("/tmp/example.png", theImage)
puts "Image saved to /tmp/example.png";





