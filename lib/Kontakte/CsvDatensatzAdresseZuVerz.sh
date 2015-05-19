#!/bin/sh

# Eingabe:
# $1 - .vcf-Dateiname

# Ausgabe:
# stdout - Datensaetze E-Mail-Adresse - Tabulator - Verzeichnisname

KONTAKTVERZNAME=`basename $1 .vcf`

cat "$1" \
| sed "/^EMAIL.*:/{s/^EMAIL.*://;s/,[^@]*$//;s/$/\t$KONTAKTVERZNAME/;p;d};d"
