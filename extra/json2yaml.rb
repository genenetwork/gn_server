#! /usr/bin/env ruby

require 'json'
require 'yaml'
     
json = ARGF.read
data = JSON.parse(json)
yml = YAML::dump(data)
     
puts yml
