#!/bin/sh

# Eingabe:
# $1 - Pfad zur Liste der bekannten Message-IDs
# $2 - Message-ID zur Ueberpruefung

# Ausgabe:
# Rueckgabewert - 0, falls Message-ID gefunden, sonst 1

echo Pruefe auf $2

if [ "cat \"$1\" | grep $2" ]; then
  exit 0
else
  exit 1
fi
