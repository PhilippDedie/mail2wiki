#!/bin/sh

# Eingabe:
#stdin: Kodiertes oder unkodiertes Feld aus dem Mail-Header

# Ausgabe:
#stdout: dekodiertes Feld

cat \
| perl -MEncode -ne 'print encode("utf8",decode("MIME-Header",$_))' \
| sed 's/\\xE9/é/'

# letzteres ein Bugfix, falls ein isolatin1-kodiertes e mit Akut-Akzent
# falsch als utf8-kodiert angegeben ist
