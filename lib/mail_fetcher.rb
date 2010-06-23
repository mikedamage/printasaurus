require "rubygems"
require "tmail"
require "mms2r"
require "net/imap"

module Printasaurus
	class MailFetcher
		attr_reader :config, :auth_response, :message_uids
		attr_accessor :imap, :messages, :attachments
		
		def initialize(config={})
			@config   = config
			@messages = []
			
			if verify_config
				@imap          = Net::IMAP.new(@config[:host], @config[:port], @config[:use_ssl])
				@auth_response = @imap.authenticate('LOGIN', @config[:username], @config[:password])
				@imap.select('INBOX')
			else
				raise ArgumentError, "Invalid arguments!"
			end
		end
		
		def fetch_and_process_messages
			get_message_uids
			
			# Fetch and parse each message by UID
			# TODO: Check subjects on server to cut down on unnecessary fetching/parsing
			if @message_uids.any?
				@message_uids.each do |uid|
					msg = @imap.uid_fetch(uid, 'RFC822')
					mms = MMS2R.parse(msg.first.attr['RFC822'])
					@messages << mms
					mark_message_read(uid)
				end
				@messages
			else
				[]
			end
		end
		
		def get_message_uids
			@message_uids = @imap.uid_search(['NEW'])
		end
		
		def logout_from_server
			@imap.expunge if @config[:delete_messages]
			@imap.logout
		end
		
		def purge_temp_files
			@messages.each do |msg|
				msg.purge
			end
		end
		
		private
			def verify_config
				@config.include?(:host) && @config.include?(:port) && @config.include?(:username) && @config.include?(:password)
			end
			
			def mark_message_read(uid)
				@imap.uid_store(uid, '+FLAGS', [:Seen])
				
				if @config[:delete_messages]
					@imap.uid_store(uid, '+FLAGS', [:Deleted])
				end
			end
	end
end