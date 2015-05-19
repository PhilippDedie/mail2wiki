#!/bin/sh

# Eingabe:
# $1 - Dateiname der E-Mail

# Ausgabe:
# stdout - Absendername

SKRIPTVERZ=`dirname $0`

cat "$1" \
| reformail -x From: \
| sh $SKRIPTVERZ/HeaderfeldDekodieren.sh \
| sh $SKRIPTVERZ/NameAusHeaderfeldLesen.sh
