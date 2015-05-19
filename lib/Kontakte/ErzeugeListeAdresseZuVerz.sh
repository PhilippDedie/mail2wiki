#!/bin/sh

# Eingabe:
# $1 - Kontakte-Basisverzeichnis
# $2 - Dateiname der Ergebnisliste

# Ausgabe:
# (1) Ergebnisliste im Kontakte-Basisverzeichnis

BASISVERZ=$1
LISTEADRESSEZUVERZ=$2
SKRIPTVERZ=`dirname $0`

ls "$BASISVERZ" \
| xargs -n 1 \
| while read ARGS; do
    if [ -d "$BASISVERZ/$ARGS" ]; then
      sh $SKRIPTVERZ/CsvDatensatzAdresseZuVerz.sh "$BASISVERZ/$ARGS/$ARGS.vcf" \
	>> $BASISVERZ/$LISTEADRESSEZUVERZ
    fi
  done
