#!/bin/sh

# Eingabe:
# stdin - Kopffeld der Form "Max Mustermann <max.mustermann@mail.org>, Frieda Musterfrau <f.m@m.org>"

# Ausgabe:
# stdout - Erster Klarname (im Beispiel "Max Mustermann"). Ist in der Eingabe kein Klarname enthalten
#          (z.B. "max.mustermann@mail.org, f.m@m.org"), wird die erste Mailadresse als Name geliefert.

EINGABE=`cat`
if [ `echo $EINGABE | grep -c '^[^<][^<]*<.*>'` -ge 1 ]
then
  echo "$EINGABE" | sed 's/^\([^<]*\) *<.*$/\1/; s/"//g; s/\\//g'
else
  echo "$EINGABE" | sed 's/[<>]//g; s/,.*$//'
fi
