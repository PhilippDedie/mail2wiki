#!/bin/sh

# Eingabe:
# $1 - Zielverzeichnis (Ablageverzeichnis)
# $2 - Kontaktname des Postabsenders
#      (musz einem Verzeichnisnamen unterhalb des
#      Zielverzeichnisses entsprechen)

# Ausgabe:
# (1) VCF-Datei des Postabsenders im Zielverzeichnis
# (2) Geloeschtes Kontaktverzeichnis unterhalb des
#     Zielverzeichnisses

ZIELVERZ=$1
POSTABSENDER=$2
SKRIPTVERZ=`dirname $0`
POSTABSENDERVERZNAME=`echo "$POSTABSENDER" | awk -f $SKRIPTVERZ/SaubereNamen.awk --source '{print SaubereKontaktnamen($0);}'`

if [ ! -d "$ZIELVERZ/$POSTABSENDERVERZNAME" ]
then
  #echo Postabsender \"$POSTABSENDER\" nicht gefunden!
  #Nicht vorhanden. Erzeugen.
  VCF="$ZIELVERZ/$POSTABSENDERVERZNAME.vcf"
  echo BEGIN:VCARD > $VCF
  echo FN:$POSTABSENDER >> $VCF
  echo END:VCARD >> $VCF
  exit 1
fi

mv "$ZIELVERZ/$POSTABSENDERVERZNAME/$POSTABSENDERVERZNAME".vcf "$ZIELVERZ"
rmdir "$ZIELVERZ/$POSTABSENDERVERZNAME"
