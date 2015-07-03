#!/bin/sh

# Eingabe:
# stdin - E-Mail-Kopffeld (z.B. Betreff)

# Ausgabe:
# stdout - Dateinamentaugliches Feld (z.B. Betreff)

cat | sed 's/[^-[:alnum:]+.~:,_@ ]/_/g' \
| cut -c1-100

# The last line prevents too long filenames
