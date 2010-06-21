#!/usr/bin/env ruby
#
# = Printasaurus Daemon

require File.join(File.dirname(__FILE__), '..', 'lib', 'mail_fetcher')
require File.join(File.dirname(__FILE__), '..', 'lib', 'file_printer')
require 'daemons'

class Hash
	def symbolize_keys
	  self.inject({}) do |options, (key, value)|
	    options[(key.to_sym rescue key) || key] = value
	    options
	  end
	end
	
	def symbolize_keys!
		self.replace(self.symbolize_keys)
	end
	
	def recursive_symbolize_keys!
		self.symbolize_keys!
		self.values.each {|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
		self.values.select {|v| v.is_a?(Array) }.flatten.each {|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
		self
	end
end

module Printasaurus
	class Daemon
		attr_accessor :args
	
		def initialize(args)
			@args = args
			@config_file = @args.shift
		end
	
		def run!
			if load_config_file
				
			else
				STDERR.puts "Error loading config file"
				exit 1
			end
		end
	
		private
			def load_config_file
				if FileTest.exist? @config_file
					@config = YAML.load(File.read(@config_file)).recursive_symbolize_keys!
				end
				false
			end
	end
end

if __FILE__ == $0
	app = Daemon.new(ARGV)
	app.run!
end