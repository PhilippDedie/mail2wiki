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
SKRIPTVERZ=`dirname $0`

if [ "$(cat "$MAILDATEI" | reformail -x "To:")" != "" ]
then
  TO_EXISTS=1
else
  TO_EXISTS=0
fi
if [ "$(cat "$MAILDATEI" | reformail -x "From:")" != "" ]
then
  FROM_EXISTS=1
else
  FROM_EXISTS=0
fi

if [ $UMGEKEHRT -eq 1 -a $TO_EXISTS -eq 1 ]
then
  QUELLFELD=To:
elif [ $UMGEKEHRT -eq 0 -a $FROM_EXISTS -eq 1 ]
then
  QUELLFELD=From:
elif [ $UMGEKEHRT -eq 1 ]
then
  #TO_EXISTS is 0 (maybe FROM_EXISTS also, but we do not care)
  QUELLFELD=From:
else
  #FROM_EXISTS is 0 (maybe TO_EXISTS also, but we do not care)
  QUELLFELD=To:
fi

FROM=`cat "$MAILDATEI" \
| reformail -x $QUELLFELD \
| sh $SKRIPTVERZ/../Mail/HeaderfeldDekodieren.sh`

ADRESSE=`echo "$FROM" | sh $SKRIPTVERZ/../Mail/AdresseAusHeaderfeldLesen.sh`
if [ "$ADRESSE" = "" ]
then
  # Big problem, but unlikely.
  ADRESSE=unknown
fi

NAME=`echo "$FROM" | sh $SKRIPTVERZ/../Mail/NameAusHeaderfeldLesen.sh`
if [ "$NAME" = "" ]
then
  NAME=unknown
fi

SAUBERNAME=`echo $NAME | awk -e '{print SaubereKontaktnamen($0)}' -f $SKRIPTVERZ/SaubereNamen.awk`



#echo Erstelle neuen Kontakt fuer "$FROM"
#echo Adresse ist: "$ADRESSE"
#echo Name ist: "$NAME"
#echo Sauberer Name ist: $SAUBERNAME

mkdir -p "$ZIELVERZ/$SAUBERNAME"
echo "$ADRESSE\t$SAUBERNAME" >> $ZIELVERZ/$LISTEADRESSEZUVERZ
echo "$SAUBERNAME"
