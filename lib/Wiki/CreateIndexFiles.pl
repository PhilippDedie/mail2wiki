#!/usr/bin/perl
# CreateIndexFiles.pl

# Input:
# $1 - Base directory to be checked for contacts subdirectories
# $2 - Clear name of the mailbox owner (mail sender)
# $3 - Either "txt" or "html" - determines which mail body type
#      to prefer to display in the wiki. Will be assumed as HTML
#      if omitted or invalid
# $4 - Output language. Currently DE or EN. Defaults to EN.

# Output:
# (1) index.mdwn in the base directory, containing links to all 
#     contact subdirectories
# (2) index.mdwn in every contact subdirectory, containing
#     links to all e-mails and attachments in chronological
#     order (not using ikiwiki wildcard pagespecs, which is
#     too slow for great amounts of e-mails)

use Date::Format;
use Date::Parse;
use HTML::Template;
use File::Basename;
use strict;

my $BASEDIR=$ARGV[0];
my $OWNERCLEARTEXT=$ARGV[1];
my $TXTORHTML=$ARGV[2];
my $Language = uc($ARGV[3]);

my $DE;
my $EN;
if ( $Language eq "DE" ) { $DE = 1; }
else { $EN = 1; }
my $ScriptPath = dirname(__FILE__);
my $OWNERVCFPATH;
chomp( $OWNERVCFPATH = `ls -1 $BASEDIR/*.vcf | head -n 1 2>&1` );
my $OWNERNAME = $OWNERVCFPATH;
$OWNERNAME =~ s|^$BASEDIR/||;
$OWNERNAME =~ s/\.vcf$//;
#print "$OWNERVCFPATH | $OWNERNAME\n";
my $HtmlPreferred=1;
if ( uc($TXTORHTML) eq "TXT" )
{
    $HtmlPreferred=0;
}
#print "\$HtmlPreferred = $HtmlPreferred\n";

my $MainTempl = HTML::Template->new(
           filename => $ScriptPath."/MainIndex.tmpl", );
$MainTempl->param(ownername => $OWNERCLEARTEXT);
$MainTempl->param(ownerfilename => $OWNERNAME);
$MainTempl->param(en => $EN);
$MainTempl->param(de => $DE);

# Loop through base directory:
opendir(D, $BASEDIR) || die "Cannot open directory $BASEDIR: $!\n";
my @List = readdir(D);
closedir(D);
my @SortedList = sort { "\L$a" cmp "\L$b" } @List;

my @ContactList;
my $nmax = scalar @List;
my $n = 0;
my $LastLetter = "";
my $NewLetter = 0;
foreach my $ContactDir (@SortedList)
{
    $n = $n + 1;
    printf "\r%2.0f%%", $n/$nmax*100;
    next if ( ! -d "$BASEDIR/$ContactDir" );
    next if $ContactDir =~ /^\.\.?$/;
    #print "Gefunden: $ContactDir\n";
    open(SUBIDX, ">$BASEDIR/$ContactDir/index.html");

    my $FirstLetter = uc(substr($ContactDir, 0, 1));
    if ( $FirstLetter =~ m/[A-Z]/ )
    {
	if ( $FirstLetter ne $LastLetter )
	{
	    $NewLetter = 1;
	}
	else
	{
	    $NewLetter = 0;
	}
    }
    $LastLetter = $FirstLetter;
    push @ContactList, { contactdir => $ContactDir, 
                         newletter => $NewLetter,
                         firstletter => $FirstLetter };
    my $HtmlTempl = HTML::Template->new(
                    filename => $ScriptPath."/ContactIndex.tmpl", );
    $HtmlTempl->param(title => $ContactDir);
    $HtmlTempl->param(contactname => $ContactDir);
    $HtmlTempl->param(de => $DE);
    $HtmlTempl->param(en => $EN);
    my @MessageHtmlList;

    # Loop through subdirectories:
    chomp( my @MailList = `ls -1tr "$BASEDIR/$ContactDir"` );
    foreach my $MailDir (@MailList)
    {
        next if ( ! -d "$BASEDIR/$ContactDir/$MailDir" );
	#print "Handling $BASEDIR/$ContactDir/$MailDir\n";
        
        # Set mail date and time to $MailDir and contents:
        chomp( my $DateStr = `cat "$BASEDIR/$ContactDir/$MailDir/hdr" | reformail -x Date:` );
        my $Date = str2time($DateStr); 
        # old shell script: DATE_EPOCH=$(date --date="$DATE" +%s)
        #print "Date is: ".ctime($Date)."\n";

        # Loop through mail body and attachments:
        chomp( my @MailFiles = `ls -1atr "$BASEDIR/$ContactDir/$MailDir"` );
        # Option -a as there may be files starting with a dot
        # (e.g. from a mail subject ".......")
	# Remove ".." from list:
	my $i = 0;
	$i++ until $MailFiles[$i] eq "..";
	splice @MailFiles, $i, 1;

	# Set date with absolute path:
	my @AbsMailFiles;
	foreach my $File (@MailFiles)
	{
	    my $AbsFile = "$BASEDIR/$ContactDir/$MailDir/$File";
	    push @AbsMailFiles, $AbsFile;
	    utime $Date, $Date, $AbsFile;
        #DATE_PLUS_EINS=$(expr $DATE_EPOCH + 1)
        ## Das ist, um die Anhaenge im Wiki unterhalb (spaeter)
        ## als den Nachrichtentext darzustellen.
        #ls -1 "$ABLAGEVERZ/$MAILVERZ" > /tmp/lst2
        #while read FILE
        #do
        #  echo "$FILE" | egrep "\.(txt|html)$" > /dev/null \
        #  && touch -d "$DATE" "$ABLAGEVERZ/$MAILVERZ/$FILE" \
        #  || touch -d @$DATE_PLUS_EINS "$ABLAGEVERZ/$MAILVERZ/$FILE"
        #done < /tmp/lst2
        #touch -d "$DATE" "$ABLAGEVERZ/$MAILVERZ"
	}

	my $Path = "$BASEDIR/$ContactDir/$MailDir";
        my $Subject = ReadFile("$Path/subject");
	my $MessageFile;
        if ( -e "$Path/message.html" and $HtmlPreferred )  
        {
            $MessageFile = "message.html";
        }
        elsif ( -e "$Path/message.txt" and !$HtmlPreferred )
        {
            $MessageFile = "message.txt";
	}
        elsif ( -e "$Path/message.txt" )
        { 
            $MessageFile = "message.txt";
        }
	elsif ( -e "$Path/message.html" )
	{
	    $MessageFile = "message.html";
	}
	else
	{
	    $MessageFile = "subject";
	}

	#print SUBIDX MailHtmlSection($Subject, $Path, $MessageFile);
	push @MessageHtmlList, { messagehtml => MailHtmlSection($Subject, $Path, $MessageFile, \@MailFiles) };

	my $UnusedType = ( $MessageFile =~ /\.txt$/ ) ? "html" : "txt";
	rename "$BASEDIR/$ContactDir/$MailDir/message.$UnusedType", "$BASEDIR/$ContactDir/$MailDir/message.$UnusedType.unused"
    }

    #print SUBIDX "[[!inline pages=\"$ContactDir/* and !*/hdr and !*/log and !*/src\" sort=\"-age\" show=\"0\"]]\n";
    $HtmlTempl->param(messages => \@MessageHtmlList);
    print SUBIDX $HtmlTempl->output;
    close(SUBIDX);
$MainTempl->param(contactlist => \@ContactList);
open(MAINIDX, ">$BASEDIR/index.html");
print MAINIDX $MainTempl->output;
close(MAINIDX);
}

print "\n";

sub ReadFile
{
    my $filename = $_[0];
    my $content;
    open(my $fh, '<', $filename); # or die "cannot open file $filename";
    {
        local $/;
        $content = <$fh>;
    }
    close($fh);
    #print "content read from ".$filename.": ".$content."\n";
    return $content;
}

sub MailHtmlSection 
{
    my $Subject = $_[0];
    my $Path = $_[1];
    my $MessageFile = $_[2];
    my @MailFiles = @{$_[3]};

    my $HtmlTemplate = HTML::Template->new(
           filename => $ScriptPath."/MailHtmlSection.tmpl", );
    $HtmlTemplate->param(de => $DE);
    $HtmlTemplate->param(en => $EN);
    my $MailDir = $Path; $MailDir =~ s|^.*/||;
    $HtmlTemplate->param(subject => $Subject);
    $HtmlTemplate->param(time => time2str("%d. %m. %Y %T", (stat $Path)[9]));
    $HtmlTemplate->param(sourcefiles => $MailDir);
    my $Message = ReadFile("$Path/$MessageFile");
    my $Txt;
    if ( $MessageFile =~ /\.html$/ ) { $Txt = 0; }
    else { $Txt = 1; }
    $HtmlTemplate->param(txt => $Txt);
    $HtmlTemplate->param(message => $Message);

    my @AttachmentList;
    foreach my $File (@MailFiles)
    {
	next if ( $File eq "." or $File eq "hdr" 
                  or $File eq "src" or $File =~ /^message\./ );
	next if ( $File eq "subject" or $File eq "bodysource.txt.bak" 
                   or $File eq "log" );
	push @AttachmentList, {maildir => $MailDir, file => $File};
    }
    $HtmlTemplate->param(attachments => \@AttachmentList);
    return $HtmlTemplate->output;
}
