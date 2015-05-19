#!/bin/sh

# Von einem (hoffentlich) beliebigen Ausgangs-Text-Format
# auf Standard-UTF8 konvertieren, so dass Unix-Kommandozeilen-
# programme (insb. mysql) die Textdatei akzeptieren.
# Ungueltige UTF8-Zeichen werden entfernt!

# Eingabe: $1=Quelldatei
# Ausgabe: stdout - Zieldatei

#if [ $(file -i "$1" | egrep -c ': text/') = "0" ]
#then
  # Ist keine Textdatei (oder ex. nicht), normal kopieren
#  cat "$1" 
#elif [ $(file -i "$1" | egrep -c 'charset=unknown') = "1" ]
#then
  # Ist eine Textdatei, aber der Zeichensatz ist unbekannt:
  # CRLF durch CR ersetzen, UTF-BOM entfernen
#  sed '1 s/^\xef\xbb\xbf//; s/\r$//' "$1" \
#  iconv -f utf8 -t utf8 -c
  # letzteres, um ungueltige Zeichen zu entfernen
#else
  # 1. nach UTF8 konvertieren
  # 2. CRLF durch CR ersetzen
  # 3. UTF-BOM entfernen!
#  cat "$1" | tr -d '\000' > /tmp/eml
  cp "$1" /tmp/eml
FROM=`file -i /tmp/eml | sed 's/^.*charset=//'`
if [ "$FROM" = "unknown-8bit" -o "$FROM" = "binary" -o "$FROM" = "/tmp/eml: application/octet-stream" ]
then
  FROM=utf8
  strings "$1" -e S > /tmp/eml
fi
#echo "$FROM" >> ~/cat.log
#file -i /tmp/eml
  cat /tmp/eml \
  | iconv -f $FROM \
    -t utf8 -c \
    | sed '1 s/^\xef\xbb\xbf//; s/\r$//' 
  # vom Ergebnis sagt vim immer noch "NOEOL", aber mysql akzeptiert es
#fi
