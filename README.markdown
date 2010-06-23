# Printasaurus

by [Mike Green](mailto:mike.is.green@gmail.com)

Printasaurus is a daemon that checks one or more IMAP mailboxes for messages with attachments. If those attachments are printable, it submits them as print jobs, then goes back to sleep.

I'm basing this project on a proof of concept I did earlier this year, with an emphasis on configurability. If this works well enough, I'll release it as a gem so all its dependencies will be automatically resolved.

I haven't tested it on any other platforms besides OS X 10.5 and 10.6. Once I bake in the CUPS support it should also work on Linux boxes.

## Roadmap

* Submit print jobs to CUPS using the CUPS gem (currently it uses the `lpr` command line utility).
* Support for multiple config files (maybe the RConfig gem)
* Support for multiple IMAP mailboxes (maybe add Gmail and POP3 support down the road)

## Usage

_coming soon_

_Note:_ Throws errors if you don't have a default printer selected.