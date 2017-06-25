#! /usr/bin/env ruby

require 'json'
require 'yaml'

yaml = ARGF.read
data = YAML.load(yaml)
puts JSON::generate(data)
