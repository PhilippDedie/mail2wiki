#!/bin/sh

# Eingabe:
# stdin - Kopffeld der Form "Max Mustermann <max.mustermann@mail.org>, Frieda Musterfrau <f.m@m.org>"

# Ausgabe:
# stdout - Erste Mailadresse (im Beispiel "max.mustermann@mail.org")

cat | sed 's/^[^<]*<\([^>]*\)>.*$/\1/; s/[, ].*$//'

# Eingabe kann auch sein:
# "M-M.Eickhorst@t-online.de (Eickhorst)"
# kaum zu glauben!
