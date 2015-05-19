# mail2wiki
Archive e-mails in wiki format, messages and attachments as simple files in a filesystem.

## Purpose/Motivation
* I would like to archive my e-mails locally in addition to storing them on the servers of an e-mail service provider.
* I did not find any mail user agent or similar program able to store e-mails with directly readable attachments in a file system.
* Instead of writing a new mail user agent, I decided to use a wiki compiler with a web browser (browsing locally) for the visual representation of the mailbox. But all messages and attachments can also be read *and searched* as plain files in a file system.

## Description
* The shell script reads e-mails (in RFC822 internet format) in a given directory and stores the messages in a folder structure like "Contacts/Firstname_Lastname/MessageID1/Subject.txt", the MIME attachment being in the same folder as Subject.txt.
* This folder structure will be rendered for display in a web browser. Currently, the ikiwiki wiki compiler <https://ikiwiki.info/> is used for this -- a possible alternative might be the gitit wiki engine <http://gitit.net/>.
* Optionally, a collection of contacts in a .vcf vcard file is used for assigning the "Firstname_Lastname" folders to multiple e-mail adresses.
* "Firstname_Lastname" folders are automatically created for new contacts not present in the .vcf file.
* The result of the whole process is a conversation view with attachments of all messages, ordered by the contact names. This is very similar to the conversation view for smartphone messages.
* As mail2wiki.sh memorizes the message IDs, the script can by run again and again over the mailbox, archiving additional e-mails.

## Usage
1. Edit the configuration in the file mail2wiki.sh
2. Run mail2wiki.sh

## System Requirements
* sh shell
* Unix command line tools: sed, grep, awk, file, convert
* Unix mail handling tools: reformail, munpack
* Wiki compiler: ikiwiki

