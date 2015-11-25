#/usr/bin/perl

# Eingabe:
# $1 - Postverzeichnis mit den zu importierenden E-Mails im Internet-Format
# $2 - Anzahl der zu importierenden E-Mails aus dem Postverzeichnis
# $3 - Zielverzeichnis mit vorhandenen Kontakt-Unterverzeichnissen
# $4 - Dateiname der E-Mail-zu-Kontaktverzeichnis-CSV-Liste
#      ( musz sich im Zielverzeichnis befinden )
# $5 - Dateiname der Liste der bekannten Message-IDs
# $6 - Dateinamenfilter fuer find (darf leer sein)
# $7 - "txt" or "html", which to prefer in the output
# $8 - "DE" or "EN", language for the HTML index files

# Ausgabe:
# Importierte E-Mails in den Kontaktverzeichnissen im Zielverzeichnis

my $POSTVERZ=$ARGV[0];
my $POSTZAHL=$ARGV[1];
my $ZIELVERZ=$ARGV[2];
my $LISTEADRESSEZUVERZ=$ARGV[3];
my $LISTEMESSAGEIDS=$ARGV[4];
my $DATEINAMENFILTER=$ARGV[5];
my $SKRIPTVERZ=dirname($0);
my $TXTORHTML=$ARGV[6];
my $LANGUAGE=$ARGV[7];

use File::Basename;
use File::Find;
use Cwd 'abs_path';
use strict;

my $SKRIPTVERZ = abs_path(dirname($0));
my $N = 1;
#$/="";




#my $N = 1;
# Make the file filter regex-compatible:
$DATEINAMENFILTER =~ s/\*/\.\*/;

#print "Dateinamenfilter ist: $DATEINAMENFILTER\n";
my @MessageIds;
LoadMessageIds("$ZIELVERZ/$LISTEMESSAGEIDS");
find( \&HandleFile, $POSTVERZ);
SaveMessageIds("$ZIELVERZ/$LISTEMESSAGEIDS");

print "\n".($N - 1)." new messages found\n";

sub HandleFile
{
    if ( $N > $POSTZAHL ) { return; }
    my $ARGS = $File::Find::name;

    # Check whether file or directory:
    if (! -f $ARGS) { return; }

    # Check whether file should be treated or not:
    if ( $DATEINAMENFILTER ne "" && $ARGS !~ qr/$DATEINAMENFILTER/ ) { return; }
    my $MessageId = ReadMessageId($ARGS);
    #print "Read Message-ID: \"".$MessageId."\"\n";    
    return if MessageIdKnown($MessageId);

  print "$N $ARGS";
    chomp( my $ABSADR=`sh $SKRIPTVERZ/AbsenderAdresse.sh "$ARGS"` );
    chomp( my $ABSNAME=`sh $SKRIPTVERZ/AbsenderName.sh "$ARGS"` );
    my $UMGEKEHRT=0;
    #print "****** Absenderadresse ermittelt: $ABSADR *********\n";
    #print "****** Absendernamen ermittelt: $ABSNAME *********\n";
    chomp ( my $POSTABSENDERADRESSEN=`sh $SKRIPTVERZ/../Kontakte/Postabsenderadressen.sh "$ZIELVERZ" "$LISTEADRESSEZUVERZ"` );
  # --erst hier ermitteln, weil zum Absender_namen_ zur Laufzeit
  # --weitere Absender_adressen_ hinzugefuegt werden koennen
    #print "Postabsenderadressen sind: $POSTABSENDERADRESSEN\n";

    my $UMGEKEHRT = 0;
  if ( index($POSTABSENDERADRESSEN, $ABSADR) != -1 || index($POSTABSENDERADRESSEN, $ABSNAME) != -1 )
  {
      chomp( my $ABSADR2=`sh $SKRIPTVERZ/ErsteEmpfaengerAdresse.sh "$ARGS"` );
    # might be empty if defective mail header
      if ( $ABSADR2 ne "" ) { $ABSADR=$ABSADR2; }
      $UMGEKEHRT=1;
      #print "Erste Empfängeradresse ist: $ABSADR\n";
  }
    chomp( my $KONTAKTVERZ=`sh $SKRIPTVERZ/../Kontakte/VerzZuAdresseErmitteln.sh "$ABSADR" "$ZIELVERZ/$LISTEADRESSEZUVERZ"` );
    #print "******** Kontaktverzeichnis zu $ABSADR ermittelt: $KONTAKTVERZ *********\n";
  if ( $KONTAKTVERZ eq "" )
{
    #echo Erstelle neuen Kontakt für $ABSADR
    chomp( $KONTAKTVERZ=`sh $SKRIPTVERZ/../Kontakte/NeuErstellenAusMail.sh "$ARGS" "$ZIELVERZ" $LISTEADRESSEZUVERZ $UMGEKEHRT` );
    #print "Neuer Kontakt \"$KONTAKTVERZ\" erstellt aus $ARGS\n";
}
  print " => $KONTAKTVERZ; ";
  system("sh $SKRIPTVERZ/EineEntpacken.sh \"$ARGS\" \"$ZIELVERZ/$KONTAKTVERZ\" \"$MessageId\"");
  print "ID: ".$MessageId."\n";
  $N=$N + 1;
  #print "."; 
  push @MessageIds, $MessageId;

  if ( $N % 100 == 0 )
  {
      print("Updating HTML index\n");
      my $POSTABSENDER = "nn.";
      system("perl $SKRIPTVERZ/../Wiki/CreateIndexFiles.pl \"$ZIELVERZ\" \"$POSTABSENDER\" \"$SKRIPTVERZ/..\" $TXTORHTML $LANGUAGE");
  }

}

sub LoadMessageIds
{
    my $MessageIdFile = $_[0];
    open (in,"<$MessageIdFile");
    chomp( @MessageIds = <in> );
    close in;
    my $n = scalar @MessageIds;
    #print "Loaded $n Message-IDs from $MessageIdFile\n";
    #print "\"$MessageIds[0]\"\n";
}

sub SaveMessageIds
{
    my $MessageIdFile = $_[0];
    open(DATEI, ">", $MessageIdFile);
    print DATEI "$_\n" for @MessageIds;
    close(DATEI);
    my $n = scalar @MessageIds;
    #print "Saved $n Message-IDs to $MessageIdFile\n";
}

sub ReadMessageId
{
    my $MailFile = $_[0];
    my $ShellCommand = "cat \"$MailFile\" | sed -r '/^\$/q; /^Message-/{ s/^Message-Id: *(.<)?//i; s/>.*\$//; q}; d' | perl $SKRIPTVERZ/../Wiki/CleanFilenames.pl";
    chomp( my $Id =  `$ShellCommand` );
    return $Id if $Id ne "";

    # No Message-ID found. Random number as replacement:
    $Id = int(rand(1000000)).'@mail2wiki';
    #print "Generated Message-ID: \"".$Id."\"\n";
    return $Id;
}

sub MessageIdKnown
{
    my $Id = $_[0];
    #print "Searching for \"$Id\"\n";
    my @found = grep {$_ eq $Id} @MessageIds;
    return 1 if (@found);
    return 0;
}
