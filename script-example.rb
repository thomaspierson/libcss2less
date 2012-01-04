#!/usr/bin/ruby

require 'css2less'

css = File.read(ARGV[0])

converter = Css2Less::Converter.new(css)
converter.generate
converter.print
