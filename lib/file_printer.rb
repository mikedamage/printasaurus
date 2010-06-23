require "rubygems"
require "cups"

module Printasaurus
	class FilePrinter
		attr_reader :message, :attachments, :print_job, :status
		
		def initialize(mms2r_object)
			@message     = mms2r_object
			@attachment  = @message.attachments
		end
		
		def add_print_jobs
			@print_job = Cups::PrintJob.new(@message.default_media.path)
		end
		
		def print_queued_job
			@status = @print_job.print
		end
	end
end