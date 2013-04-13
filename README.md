rapidshare-perl
===============
Old rapidshare downloader using perl. must have a valid account with rapidshare.
Not working right now because Rapidshare changed validation to JS.
Here for learning purpose. Will rewrite in Node.js!

Must download WWW::Mechanize using CPAN.
Must have installed zip unrar and 7z in your distribution

Usage:
1. Copy the links in a textfile.
2. Run in the command line ./rapidshare.pl
3. Enter the file name
4. If all files downloaded then it will decompress the file

Enhancements
Files that fail to download save them in a text file for later reference.