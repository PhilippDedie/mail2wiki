#!/bin/sh

# Eingabe:
# $1: "update" oder "create"
# und Konfiguration

# Ausgabe:
# $ZIELVERZ mit dem Post-Archiv als Wiki

#################
# Konfiguration:
##################

# Message directory in which all files will be read as input e-mails.
# Subdirectories will also be searched.
#POSTVERZ=/home/kunibert/net_sik/Maildir-sik/\[Gmail\].Alle\ Nachrichten/cur
#POSTVERZ=/home/kunibert/Dateien/andreaarch/Dokumente/Texte/Mails
#POSTVERZ=/home/kunibert/Dateien/andreaarch/JSO/Mails
#POSTVERZ=/home/kunibert/mail2wiki/AndreaMail
POSTVERZ=/home/kunibert/mail2wiki/PhilippMail

# Optionaler Filter fuer Dateinamen im POSTVERZ. Kann leergelassen werden.
# Falls nicht leergelassen, werden auch alle Unterverzeichnisse von POSTVERZ
# durchsucht.
DATEINAMENFILTER=
#DATEINAMENFILTER="*.eml"

# Message count -- so many e-mails will be read:
#POSTZAHL=30000
POSTZAHL=300

# Library subdirectory containing the subroutines:
BIB=lib

# VCF-Datei leer lassen, falls nicht vorhanden:
#QUELLVCF=
QUELLVCF=/home/kunibert/mail2wiki/philipps-kontakte.vcf

# Destination directory in which the extracted files (messages
# and attachments as well as wiki markup files) will be stored:
ZIELVERZ=/home/kunibert/mail2wiki/ablage

# CSV filename for assigning e-mail addresses to contact folders
# within the destination directory:
LISTEADRESSEZUVERZ=AdresseZuVerz.csv

# CSV filename for storing known message IDs:
LISTEMESSAGEIDS=MessageIds.csv

POSTABSENDER="Philipp Dedié"
#POSTABSENDER="Andrea Dick"
# Name des Kontaktes, der der Postabsender ist.
# Das ist der Eigentuemer des zu erstellenden Postkastens.

TXTORHTML="txt"
# Whether to prefer text or HTML message bodies in the
# output. Defaults to HTML. Possible values "txt" or "html".

LANGUAGE="DE"
# HTML index file language. Possible values are currently DE or EN.

######################
# Ende Konfiguration
####################


if [ "$1" = "create" ]
  then LOESCHEN=1
elif [ "$1" = "update" ]
  then LOESCHEN=0
else 
  echo "Argument muß \"update\" oder \"create\" sein."; exit
fi

if [ $LOESCHEN -eq 1 ]
then 
  echo Preparing target directory
  echo "Deleting $ZIELVERZ; Press Ctrl-C to abort"
  rm -r $ZIELVERZ; mkdir $ZIELVERZ
  if [ "$QUELLVCF" != "" ]
  then
    echo Creating Contacts
    sh $BIB/Kontakte/VerzeichnisseErzeugen.sh $QUELLVCF $ZIELVERZ
    sh $BIB/Kontakte/ErzeugeListeAdresseZuVerz.sh $ZIELVERZ $LISTEADRESSEZUVERZ
  fi
  sh $BIB/Kontakte/PostabsenderEinrichten.sh $ZIELVERZ "$POSTABSENDER"
fi

echo Importing messages
perl $BIB/Mail/ImportMails.pl \
  "$POSTVERZ" $POSTZAHL $ZIELVERZ $LISTEADRESSEZUVERZ \
  $LISTEMESSAGEIDS "$DATEINAMENFILTER" $TXTORHTML $LANGUAGE
# Hierbei koennen weitere Kontakte erzeugt worden sein.

echo Finishing HTML index
perl $BIB/Wiki/CreateIndexFiles.pl "$ZIELVERZ" "$POSTABSENDER" $TXTORHTML $LANGUAGE
