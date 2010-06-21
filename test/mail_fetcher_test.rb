require File.join(File.dirname(__FILE__), '..', 'lib', 'mail_fetcher')
require File.join(File.dirname(__FILE__), 'monkeyspecdoc')
require File.join(File.dirname(__FILE__), 'test_helper')
require "shoulda"
require "yaml"

class MailFetcherTest < Test::Unit::TestCase
	context "Printasaurus::MailFetcher" do
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
		
		should "login to the IMAP server successfully" do
			assert_equal @fetcher.auth_response.name, 'OK'
		end
		
		should "return an array of message UIDs" do
			@fetcher.get_message_uids
			@fetcher.message_uids.class == Array
		end
		
		should "#fetch_messages should return an array" do
			@fetcher.fetch_and_process_messages.class == Array
		end
	end
end