#!/bin/sh

# Eingabe:
# $1 - VCF-Quelldatei
# $2 - Zielverzeichnis

# Ausgabe:
# Kontakt-Verzeichnisse in $ZIELVERZ

STARTVERZ=$PWD/`dirname $0`
ZIELVERZ=$2
QUELLVCF=$1

cd $ZIELVERZ
cat $QUELLVCF \
| awk -f $STARTVERZ/QuellVcfZerteilen.awk -f $STARTVERZ/SaubereNamen.awk
