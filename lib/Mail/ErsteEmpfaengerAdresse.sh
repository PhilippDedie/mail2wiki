#!/bin/sh

# Eingabe:
# $1 - Pfad zur Maildatei im Internet-Format

# Ausgabe:
# stdout - Die erste Empfaengeradresse aus der E-Mail

MAILDATEI=$1

cat "$1" \
| reformail -x To: \
| sed 's/^[^<]*<//; s/>.*//; s/,.*$//'

