#!/usr/bin/perl

# CLeanFilenames.pl

# Prerequisites:
# (1) iki.setup config file in the same directory
#     as this file

# Input:
# stdin - (file)name (UTF-8 encoded)

# Output:
# stdout - clean filename according to the allowed
#          wiki file chars in iki.setup (UTF-8 encoded)
#          with a maximum length of 100 characters

use File::Basename;

binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';

my $Dir = dirname(__FILE__);
chomp( my @Matches = `grep wiki_file_chars "$Dir/iki.setup"` );
my $wiki_file_chars = $Matches[0];
$wiki_file_chars =~ s/^[ \t]*wiki_file_chars *=> *["']//;
$wiki_file_chars =~ s/['"],[ \t]*$//;
$wiki_file_chars =~ s|/||;
#--slashes must be allowed for ikiwiki, but not for
# files to be created by mail2wiki!
$re = qr/$wiki_file_chars/;

#print $wiki_file_chars."\n";

chomp( my $input = substr <STDIN>, 0, 100 );
$input =~ s/[^${re}]/_/g;
print $input."\n";
