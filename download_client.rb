# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'fileutils'
require 'json'

def download(file,locationPath,internalMeetingId)
  # Format: "https://hostname/presentation/meetingID/#{file}"

  path = "#{file}"

  puts "Downloading #{path}"

  File.open(locationPath+ '/'+ file, 'rb') do |input_stream|
    File.open(internalMeetingId+'/'+file, 'wb') do |output_stream|
      IO.copy_stream(input_stream, output_stream)
    end
  end
end
locationPath = ARGV[0]
internalMeetingId = ARGV[1]
['shapes.svg'].each do |get|
  download(get,locationPath,internalMeetingId)
end

# Opens shapes.svg
@doc = Nokogiri::XML(File.open(internalMeetingId+'/'+'shapes.svg'))

slides = @doc.xpath('//xmlns:image', 'xmlns' => 'http://www.w3.org/2000/svg', 'xlink' => 'http://www.w3.org/1999/xlink')

# Download all captions
json = JSON.parse(File.read(locationPath+'/'+'captions.json'))

(0..json.length - 1).each do |i|
  download("caption_#{json[i]['locale']}.vtt", locationPath,internalMeetingId)
end

# Download each slide
slides.each do |img|
  path = File.dirname(img.attr('xlink:href'))

  # Creates folder structure if it's not yet present
  FileUtils.mkdir_p(internalMeetingId+'/'+path) unless File.directory?(internalMeetingId+'/'+path)
  puts img.attr('xlink:href')
  download(img.attr('xlink:href'),locationPath,internalMeetingId)
end

