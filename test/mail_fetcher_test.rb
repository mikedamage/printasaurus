require File.join(File.dirname(__FILE__), '..', 'lib', 'mail_fetcher')
require File.join(File.dirname(__FILE__), 'monkeyspecdoc')
require File.join(File.dirname(__FILE__), 'test_helper')
require "shoulda"
require "yaml"

class MailFetcherTest < Test::Unit::TestCase
	context "MailFetcher" do
		setup do
			# Need to supply your own config file w/ login credentials and stuff.
			@config        = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'config.yml'))[:mailboxes]
			@first_mailbox = @config.first[1]
			@fetcher       = Printasaurus::MailFetcher.new(@first_mailbox)
		end
		
		should "be a valid instance of MailFetcher given valid input" do
			@fetcher.class == Printasaurus::MailFetcher
		end
		
		should "raise an error when given an invalid config hash" do
			assert_raises ArgumentError do
				Printasaurus::MailFetcher.new(@first_mailbox.except(:host))
			end
		end
		
		should "create a valid instance of Net::IMAP on initialization" do
			@fetcher.imap == Net::IMAP
		end
	end
end