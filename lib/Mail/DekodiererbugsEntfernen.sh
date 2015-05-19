#!/bin/sh

# Eingabe:
# $1 - Verzeichnis, in dem gerade von munpack eine E-Mail entpackt (dekodiert) wurde

# Ausgabe:
# Bugbereinigtes Verzeichnis, siehe hierunter

MAILVERZ=$1
SKRIPTVERZ=`dirname $0`

# BUG 1 #########
# munpack erkennt keine kodierten Anhangsnamen, sondern speichert
# die Dateinamen in kodierter Form ab, wobei ? durch X ersetzt ist.
# Korrektur:
for DATEI in `ls -1 $MAILVERZ`
do
  DATEIALT=`basename $DATEI`
  if [ `echo "$DATEIALT" | grep -c '^=X'` -ne 0 ]
  then
    DATEINEU=`echo "$DATEIALT" \
      | sed 's/^=X/=?/; s/XQX/?Q?/g; s/X=XX=X/?==?/g; s/X=$/?=/' \
      | sh $SKRIPTVERZ/HeaderfeldDekodieren.sh`
    mv "$MAILVERZ/$DATEIALT" "$MAILVERZ/$DATEINEU"
  fi
done
# Substitution von X=XX=X ist erforderlich, weil munpack einen
# Zeilenumbruch im MIME-Dateinamen, z.B. 
# "=?UTF-8?Q?Barockw_Kurse-Vortr=C3=A4ge-Konzerte.?="
# "=?UTF-8?Q?doc?="
# damit ersetzt ("?=\n=?" -> "X=XX=X" -> "?==?")
