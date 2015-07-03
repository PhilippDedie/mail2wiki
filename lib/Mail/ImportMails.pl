#/usr/bin/perl

# Eingabe:
# $1 - Postverzeichnis mit den zu importierenden E-Mails im Internet-Format
# $2 - Anzahl der zu importierenden E-Mails aus dem Postverzeichnis
# $3 - Zielverzeichnis mit vorhandenen Kontakt-Unterverzeichnissen
# $4 - Dateiname der E-Mail-zu-Kontaktverzeichnis-CSV-Liste
#      ( musz sich im Zielverzeichnis befinden )
# $5 - Dateiname der Liste der bekannten Message-IDs
# $6 - Dateinamenfilter fuer find (darf leer sein)

# Ausgabe:
# Importierte E-Mails in den Kontaktverzeichnissen im Zielverzeichnis

my $POSTVERZ=$ARGV[0];
my $POSTZAHL=$ARGV[1];
my $ZIELVERZ=$ARGV[2];
my $LISTEADRESSEZUVERZ=$ARGV[3];
my $LISTEMESSAGEIDS=$ARGV[4];
my $DATEINAMENFILTER=$ARGV[5];
#my $SKRIPTVERZ=dirname($0);

use File::Basename;
use File::Find;
use Cwd 'abs_path';
my $SKRIPTVERZ = abs_path(dirname($0));
my $N = 1;
#$/="";

sub HandleFile
{
    if ( $N > $POSTZAHL ) { return; }
    my $ARGS = $File::Find::name;

    # CHeck whether file or directory:
    if (! -f $ARGS) { return; }

    # Check whether file should be treated or not:
    if ( $DATEINAMENFILTER ne "" && $ARGS !~ qr/$DATEINAMENFILTER/ ) { return; }

  print "$N $ARGS\n";
    chomp( $ABSADR=`sh $SKRIPTVERZ/AbsenderAdresse.sh "$ARGS"` );
    chomp( $ABSNAME=`sh $SKRIPTVERZ/AbsenderName.sh "$ARGS"` );
    $UMGEKEHRT=0;
    #print "****** Absenderadresse ermittelt: $ABSADR *********\n";
    #print "****** Absendernamen ermittelt: $ABSNAME *********\n";
    chomp ( $POSTABSENDERADRESSEN=`sh $SKRIPTVERZ/../Kontakte/Postabsenderadressen.sh "$ZIELVERZ" "$LISTEADRESSEZUVERZ"` );
  # --erst hier ermitteln, weil zum Absender_namen_ zur Laufzeit
  # --weitere Absender_adressen_ hinzugefuegt werden koennen
    #print "Postabsenderadressen sind: $POSTABSENDERADRESSEN\n";

  if ( index($POSTABSENDERADRESSEN, $ABSADR) != -1 || index($POSTABSENDERDRESSEN, $ABSNAME) != -1 )
  {
      chomp( $ABSADR2=`sh $SKRIPTVERZ/ErsteEmpfaengerAdresse.sh "$ARGS"` );
    # might be empty if defective mail header
      if ( $ABSADR2 ne "" ) { $ABSADR=$ABSADR2; }
      $UMGEKEHRT=1;
      #print "Erste Empfängeradresse ist: $ABSADR\n";
  }
    chomp( $KONTAKTVERZ=`sh $SKRIPTVERZ/../Kontakte/VerzZuAdresseErmitteln.sh "$ABSADR" "$ZIELVERZ/$LISTEADRESSEZUVERZ"` );
    #print "******** Kontaktverzeichnis zu $ABSADR ermittelt: $KONTAKTVERZ *********\n";
  if ( $KONTAKTVERZ eq "" )
{
    #echo Erstelle neuen Kontakt für $ABSADR
    chomp( $KONTAKTVERZ=`sh $SKRIPTVERZ/../Kontakte/NeuErstellenAusMail.sh "$ARGS" "$ZIELVERZ" $LISTEADRESSEZUVERZ $UMGEKEHRT` );
    #print "Neuer Kontakt \"$KONTAKTVERZ\" erstellt aus $ARGS\n";
}
  print "Kontaktverz. nach neu erstellen: $KONTAKTVERZ\n";
  system("sh $SKRIPTVERZ/EineEntpacken.sh \"$ARGS\" \"$ZIELVERZ/$KONTAKTVERZ\" \"$LISTEMESSAGEIDS\"");
  print "ID: "; print `tail -n 1 $ZIELVERZ/$LISTEMESSAGEIDS`;
  $N=$N + 1;
  print "."; 
}

#done < /tmp/lst

#my $N = 1;
# Make the file filter regex-compatible:
$DATEINAMENFILTER =~ s/\*/\.\*/;

#print "Dateinamenfilter ist: $DATEINAMENFILTER\n";
find( \&HandleFile, $POSTVERZ);

print "\n".($N - 1)." messages found\n";
