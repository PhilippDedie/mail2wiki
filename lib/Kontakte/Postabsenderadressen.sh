#!/bin/sh

# Eingabe:
# $1 - Basisverzeichnis, in dem sich genau eine VCF-Datei befinden musz, die den
#      Namen des Postabsenders enthaelt
# $2 - Dateiname der CSV-Liste (musz sich im Basisverzeichnis befinden)
#      mit Zeilen des Formats Mailadresse - Tabulator - Kontaktverzeichnisname

# Ausgabe:
# stdout - Mehrzeilige Liste aller E-Mail-Adressen des Postabsenders.

BASISVERZ=$1
LISTEADRESSEZUVERZ=$2
SKRIPTVERZ=$(dirname $0)

if [ ! -s $BASISVERZ/*.vcf -o ! -s $BASISVERZ/$LISTEADRESSEZUVERZ ]
then
  exit 1
fi
POSTABSVERZNAME=$(sed -n '/^FN:/{s/^FN://;p;q}' $BASISVERZ/*.vcf \
  | perl $SKRIPTVERZ/../Wiki/CleanFilenames.pl)

#echo $POSTABSVERZNAME
sed -n "/${POSTABSVERZNAME}\$/{s/\t${POSTABSVERZNAME}\$//;p}" "$BASISVERZ/$LISTEADRESSEZUVERZ"
