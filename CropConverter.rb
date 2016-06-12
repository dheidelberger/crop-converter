# CropConverter
# Written by David Heidelberger
# Distributed under an MIT License

require 'psd'
require 'uri'
require "addressable/uri"
require 'optparse'

#Default framerate of sequence
#Can be one of: 23.976, 23.98, 24, 25, 29.97, 30, 50, 59.94, 60
DEFAULT_FRAMERATE = 29.97

#Length of default clip in seconds
SHOT_LENGTH = 3

#Time in seconds to pad the in-point of the clip, default is 5 minutes (5*60 seconds)
IN_PAD = 5*60

#Some fun color additions to the string class.
#I copied this from somewhere at some point, but I forget where. Sorry, author.
class String
	def black;          "\033[30m#{self}\033[0m" end
	def red;            "\033[31m#{self}\033[0m" end
	def green;          "\033[32m#{self}\033[0m" end
	def yellow;          "\033[33m#{self}\033[0m" end
	def blue;           "\033[34m#{self}\033[0m" end
	def magenta;        "\033[35m#{self}\033[0m" end
	def cyan;           "\033[36m#{self}\033[0m" end
	def gray;           "\033[37m#{self}\033[0m" end
	def bg_black;       "\033[40m#{self}\033[0m" end
	def bg_red;         "\033[41m#{self}\033[0m" end
	def bg_green;       "\033[42m#{self}\033[0m" end
	def bg_brown;       "\033[43m#{self}\033[0m" end
	def bg_blue;        "\033[44m#{self}\033[0m" end
	def bg_magenta;     "\033[45m#{self}\033[0m" end
	def bg_cyan;        "\033[46m#{self}\033[0m" end
	def bg_gray;        "\033[47m#{self}\033[0m" end
	def bold;           "\033[1m#{self}\033[22m" end
	def reverse_color;  "\033[7m#{self}\033[27m" end

	def color(x)
		"\033[38;5;#{x.to_s}m#{self}\033[0;00m"
	end

	def spectrum(c)

		colors = []
		y = 196

		(0..24).step(6) do |x|
			colors << x+y
			
		end

		x=24

		196.step(0,-36) do |y|
			colors << x+y
		end

		index = (c*10).round(0)
		return self.color(colors[index])
	end
end

#Method to parse out the command line options using Ruby OptionParser
def parse_arguments
	options = {}
	
	optparse = OptionParser.new do|opts|   
		# Set a banner, displayed at the top   
		# of the help screen.   
		opts.banner = "Usage: ruby #{$0} [options] file1 file2..."

		#Figure out the framerate
		options[:framerate] = DEFAULT_FRAMERATE
		rates = [23.976, 23.98, 24, 25, 29.97, 30, 50, 59.94, 60]
		opts.on('-f', '--framerate RATE', Float, "The framerate of your sequence. Defaults to #{DEFAULT_FRAMERATE}. Acceptable rates: #{rates}") do |fr|
			if !rates.include?(fr)
				puts "Invalid framerate. Must be one of: #{rates}.".red
				exit
			end
			options[:framerate] = fr
		end

		# This displays the help screen, all programs are
		# assumed to have this option.   
		opts.on( '-h', '--help', 'Display this screen' ) do
			puts opts
			exit
		end

	end

	#Parse the options we've set above.
	#Whatever is left goes into ARGV
	optparse.parse!

	#XML requirements. Timebase is the round number closest to the framerate
	timebase = options[:framerate].round
	ntsc = "FALSE"

	#NTSC is true if the true framerate is not a round number
	#NTSC should be true if the framerate does not match the timebase
	if timebase != options[:framerate]
		ntsc = "TRUE"
	end

	options[:timebase] = timebase
	options[:ntsc] = ntsc

	if ARGV.length == 0
		puts "No files listed.".red
		exit
	end

	#Parse out the remaining files
	options[:files] = Array.new(ARGV)
	 
	return options
end

def xml_file(my_file,options)

	#Path to file
	path = my_file

	#Get a url with file:// format for XML
	parsed_url = Addressable::URI.parse(path).normalize.to_str
	uri = URI.join('file:///', parsed_url)
	urlpath = uri.to_s

	#Get filename
	filename = File.basename(URI.unescape(uri.path))

	#Set xml filename
	othername = URI.unescape(File.join( File.dirname(uri.path), "#{filename}.xml" ))

	#Number of seconds
	shot_length = SHOT_LENGTH

	#Initialize PSD file
	psd = PSD.new(path)
	psd.parse!
	psd_hash = psd.tree.to_hash

	#Set timebase and NTSC options for XML
	timebase = options[:timebase]
	ntsc = options[:ntsc]

	#Get width and height
	height = psd_hash[:document][:height]
	width = psd_hash[:document][:width]

	#Get height float for later calculations
	heightf = height.to_f
	puts "  Width:  #{width}"
	puts "  Height: #{height}"

	#Get the guides
	#Only get the horizontal ones (select command)
	#Convert to percent for bottom crop (map command)
	guides = psd_hash[:document][:resources][:guides].select{|guide| guide[:direction]=="horizontal"}.map {|guide| (100*(heightf - guide[:location])/heightf).round(3)}.sort.reverse

	#Add a final guide for the last uncropped clip
	guides << 0

	#Prefix for XML
	#I know you can make XMLs in Ruby, but it's kind of a pain and this was faster to set up
	outxml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE xmeml><xmeml version=\"4\"><sequence id=\"sequence\"><rate><timebase>#{timebase}</timebase><ntsc>#{ntsc}</ntsc></rate><name>#{filename}</name><media><video><format><samplecharacteristics><width>#{width}</width><height>#{height}</height><anamorphic>FALSE</anamorphic><pixelaspectratio>square</pixelaspectratio><fielddominance>none</fielddominance><colordepth>24</colordepth></samplecharacteristics></format><track>"

	#Initalize the timecode variables
	
	#Timeline timecode
	start_tc = 0
	end_tc = timebase*shot_length

	#Clip timecode
	in_tc = timebase*IN_PAD
	out_tc = in_tc + timebase*shot_length

	
	puts "  Finding guides:"

	#Create clipitem for each guide
	guides.each do |croplevel|
		clipitem = "<clipitem id=\"bullet1\"><name>#{filename}</name><enabled>TRUE</enabled><rate><timebase>#{timebase}</timebase><ntsc>#{ntsc}</ntsc></rate><start>#{start_tc}</start><end>#{end_tc}</end><in>#{in_tc}</in><out>#{out_tc}</out><alphatype>straight</alphatype><pixelaspectratio>square</pixelaspectratio><anamorphic>FALSE</anamorphic><file id=\"file1\"><name>#{filename}</name><pathurl>#{urlpath}</pathurl><media><video></video></media></file><filter><effect><name>Crop</name><effectid>crop</effectid><effectcategory>motion</effectcategory><effecttype>motion</effecttype><mediatype>video</mediatype><parameter><parameterid>bottom</parameterid><name>bottom</name><valuemin>0</valuemin><valuemax>100</valuemax><value>#{croplevel}</value></parameter></effect></filter></clipitem>"
		outxml += clipitem
		puts "    Crop: #{croplevel}"

		#Increment timecode in sequence
		start_tc = end_tc
		end_tc += timebase*shot_length

		
		

	end

	#End of the XML
	outxml += "</track></video></media></sequence></xmeml>"

	#Write the file
	File.open(othername, 'w') { |file| file.write(outxml) }
	puts "  Done!".green
	puts 
end


#Parse the command arguments
opts = parse_arguments

#Make an XML for each file
opts[:files].each do |file|
	puts "Exporting: #{file}"
	xml_file(file,opts)
end