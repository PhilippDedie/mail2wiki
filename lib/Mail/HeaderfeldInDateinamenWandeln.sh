#!/bin/sh

# Eingabe:
# stdin - E-Mail-Kopffeld (z.B. Betreff)

# Ausgabe:
# stdout - Dateinamentaugliches Feld (z.B. Betreff)

cat | sed 's/[^-[:alnum:]+.~:,_@ ]//g'
