#!/bin/sh

# Eingabe:
# $1 - E-Mail-Adresse
# $2 - Pfad zur CSV-Datei mit der Zuordnung Adresse zu Verzeichnis

# Ausgabe:
# stdout - Name des Kontaktverzeichnisses
# Eventuelle weitere Ergebnisse nach dem ersten werden entfernt.

MAILADR=$1
LISTEADRESSEZUVERZ=$2

if [ ! -f $LISTEADRESSEZUVERZ ]
then
  exit
fi

cat $LISTEADRESSEZUVERZ \
| grep -i $MAILADR \
| sed '1s/^.*\t//; 2,$d'

# grep -i: ignore letter case
