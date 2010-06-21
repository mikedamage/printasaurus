require "rubygems"
require "tmail"
require "mms2r"
require "net/imap"

module Printasaurus
	class MailFetcher
		attr_reader :config
		attr_accessor :imap
		
		def initialize(config={})
			@config = config
			if verify_config
				@imap = Net::IMAP.new(@config[:host], @config[:port], @config[:use_ssl])
			else
				raise ArgumentError, "Invalid arguments!"
			end
		end
		
		def fetch_messages
			
		end
		
		private
			def verify_config
				@config.include?(:host) && @config.include?(:port) && @config.include?(:username) && @config.include?(:password)
			end
	end
end