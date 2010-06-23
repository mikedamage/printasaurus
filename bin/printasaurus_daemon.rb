# = Printasaurus Daemon
# Controlled by printasaurus.rb. Do not invoke this directly.

require File.join(File.dirname(__FILE__), '..', 'lib', 'mail_fetcher')
require File.join(File.dirname(__FILE__), '..', 'lib', 'file_printer')
require File.join(File.dirname(__FILE__), '..', 'lib', 'printasaurus_logger')
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
		attr_accessor :config_file, :log
		attr_reader :config
	
		def initialize(config="/etc/printasaurus.conf.yml")
			@config_file = config
			@config      = FileTest.exist?(@config_file) ? YAML.load(File.read(@config_file)).recursive_symbolize_keys! : {}
		end
	
		def run!
			if @config[:mailboxes]
				@mailboxes = @config[:mailboxes]
				@mailboxes.each do |key, box_config|
					fetcher = Printasaurus::MailFetcher.new(box_config)
					fetcher.fetch_and_process_messages
					
					if fetcher.messages.any?
						fetcher.messages.each do |msg|
							printer = Printasaurus::FilePrinter.new(msg)
							printer.add_print_jobs
							printer.print_queued_job
						end
						fetcher.logout_from_server
						fetcher.purge_temp_files
					else
						fetcher.logout_from_server
						return {:code => 2, :message => 'No messages found'}
					end
				end
				return {:code => 0, :message => 'Message(s) found, downloaded, and printed'}
			else
				return {:code => 1, :message => 'Configuration file invalid or not found'}
			end
		end
	end
end

if ARGV.any?
	app = Printasaurus::Daemon.new(ARGV.first)
else
	app = Printasaurus::Daemon.new
end

if FileTest.exist?(File.dirname(app.config[:daemon][:log]))
	log = PrintasaurusLogger.new(app.config[:daemon][:log])
else
	log = PrintasaurusLogger.new(STDOUT)
end

log.info("Printasaurus daemon started.")

loop do
	log.info("Checking mailbox")
	
	result = app.run!
	
	log.info(result[:message])
	log.info("Sleeping...")
	
	sleep(app.config[:daemon][:interval].to_i)
end
