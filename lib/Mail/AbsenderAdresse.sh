#!/bin/sh

# Eingabe:
# $1 - Dateiname der E-Mail

# Ausgabe:
# stdout - Absenderadresse

SKRIPTVERZ=`dirname $0`

cat "$1" \
| reformail -x From: \
| sh $SKRIPTVERZ/AdresseAusHeaderfeldLesen.sh

