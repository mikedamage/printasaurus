#!/usr/bin/env ruby
#
# = Printasaurus Daemon

require File.join(File.dirname(__FILE__), '..', 'lib', 'mail_fetcher')
require File.join(File.dirname(__FILE__), '..', 'lib', 'file_printer')
require 'daemons'

class Application
	attr_accessor :args
	
	def initialize(args)
		@args = args
	end
	
	def run!
		
	end
end

if __FILE__ == $0
	app = Application.new(ARGV)
	app.run!
end