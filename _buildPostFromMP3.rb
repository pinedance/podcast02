require "mp3info"
require 'uri'

## CONSTANTS

URLRGX = /(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?/

## Functions

def buildPost( filename )

	puts "Detected #{filename}"

	ext_name = File.extname( filename )
	base_name = File.basename( filename, ext_name )

	no = base_name[0..1]
	title = base_name[3..-1]
	mdfilename = "_posts/2022-01-01-#{no}-#{title.gsub(' ', '-')}.md"
	filename2 = URI.encode("#{ base_name }#{ ext_name }")
	Mp3Info.open( filename ) do |mp3|
		len_h = (mp3.length / 3600).floor
		len_m = (mp3.length / 60).floor - ( len_h * 60 )
		len_s = (mp3.length).floor - ( len_h * 3600 ) - ( len_m * 60 )
		mp3.tag2.TLEN = "#{ len_h.to_s.rjust(2, '0') }:#{ len_m.to_s.rjust(2, '0') }:#{ len_s.to_s.rjust(2, '0') }"
		ym = string = <<-FIN
---
layout: post
explicit: no
title: "#{no} #{ title }"
enclosure:
  type: "Audio/mp3"
  filename: "#{ base_name }#{ ext_name }"
  filename2: "#{ filename2 }"
  duration: "#{ mp3.tag2.TLEN }"
tags: podcasts
---

FIN
		puts "Creating #{mdfilename} ..."
		File.open( mdfilename, 'w').puts ym

		mp3.tag.title = title

	end

end

## MAIN

filelist = Dir["./mp3/*.mp3"]
filelist.each { |filename| buildPost( filename ) }

