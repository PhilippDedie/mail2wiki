#!/bin/sh

# Eingabe:
# stdin - E-Mail-Text

# Ausgabe:
# stdout - E-Mail-Text mit ausgeblendeten Zitaten

##### zunaechst nur mit Markierung des Ausblendungsstelle! #######

#DATEI=$1
#SKRIPTVERZ=`dirname $0`

WHITESPACEZEILENWEG='N; /^[ \t]*\n$/d; P; D'
#KRITERIUM1=':a /^\n*$/{N;b a}; /^\n\n*---*.*(Nachricht|Message)-*--$/{s/^/XXXXXXXXXXXXXXXXX/;}'
KRITERIUM2=':a /^\n*$/{N;b a}; /^\n\n*(On |At |Am |[0-9][0-9][0-9]*).*(@|schrieb|wrote).*$/{s/^/XXXXXXXXXXXXXXXXX/;}'
# ":" am Zeilenende wird nicht mehr gesucht. Das ist nur noetig, wenn ein
# uebereifriger Zeilenumbruch aktiv war (z.B.
#  "Am 01.06.10 schrieb Clara.Pelloquin@stud.unibas.ch"
#  "<Clara.Pelloquin@stud.unibas.ch>:")
KRITERIUM3=':a /^\n*$/{N;b a}; /^\n*[ \t]*(____*|----*)( .* ----*[ \t]*)?$/s/^/XXXXXXXXXXXXXXXXXXX/'
KRITERIUM4=':a /^\n*$/{N;b a}; /^\n\n*>? ?Date:/s/^/XXXXXXXXXXXXXXXXXX/'
KRITERIUM5=':a /^\n*$/{N;b a}; /^\n*.*(sagte|said|schrieb|wrote):$/{N; b a}; /^\n*.*(sagte|said|schrieb|wrote):\n>/s/^/XXXXXXXXXXXXXXXXXXXX/'
#KRITERIUM6=':a /^\n*$/{N;b a}; /^\n\n*.*(sagte|said):$/{N; b a}; /^\n\n*.*(sagte|said):\n>/s/^/XXXXXXXXXXXXXXXXXXXX/'
#KRITERIUM6='s/  ---* .* ---*

#sh $SKRIPTVERZ/catNachStdUtf8.sh "$DATEI" \
cat \
| sed "$WHITESPACEZEILENWEG" \
| sed -r "$KRITERIUM2" \
| sed -r "$KRITERIUM3" \
| sed -r "$KRITERIUM4" \
| sed -r "$KRITERIUM5" 
#| sed -r "$KRITERIUM6"
