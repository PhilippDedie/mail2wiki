#!/bin/sh

# Eingabe:
# $1 - Dateiname der E-Mail (musz im Internet-Format vorliegen)
# $2 - Kontakte-Basisverzeichnis
# $3 - Dateiname der CSV-Zuordnungsliste Adresse - Kontaktverzeichnis
#      (musz sich im Kontakte-Basisverzeichnis befinden)
# $4 - Indikator fuer "umgekehrt". 0 bedeutet: Informationen im
#      From:-Feld suchen. 1 bedeutet: Informationen im To:-Feld
#      suchen.

# Ausgabe:
# (1) Neu erstelltes Kontaktverzeichnis
# (2) Aktualisierte CSV-Zuordnungsliste
# (3) stdout - Name des neuen Kontaktverzeichnisses

MAILDATEI="$1"
ZIELVERZ=$2
LISTEADRESSEZUVERZ=$3
UMGEKEHRT=$4
SKRIPTVERZ=$PWD/`dirname $0`
if [ $UMGEKEHRT -eq 1 ]
then
  QUELLFELD=To:
else
  QUELLFELD=From:
fi

FROM=`cat "$MAILDATEI" \
| reformail -x $QUELLFELD \
| sh $SKRIPTVERZ/../Mail/HeaderfeldDekodieren.sh`

ADRESSE=`echo "$FROM" | sh $SKRIPTVERZ/../Mail/AdresseAusHeaderfeldLesen.sh`

NAME=`echo "$FROM" | sh $SKRIPTVERZ/../Mail/NameAusHeaderfeldLesen.sh`
SAUBERNAME=`echo $NAME | awk -e '{print SaubereKontaktnamen($0)}' -f $SKRIPTVERZ/SaubereNamen.awk`

#echo Erstelle neuen Kontakt fuer "$FROM"
#echo Adresse ist: "$ADRESSE"
#echo Name ist: "$NAME"
#echo Sauberer Name ist: $SAUBERNAME

mkdir -p "$ZIELVERZ/$SAUBERNAME"
echo "$ADRESSE\t$SAUBERNAME" >> $ZIELVERZ/$LISTEADRESSEZUVERZ
echo "$SAUBERNAME"
