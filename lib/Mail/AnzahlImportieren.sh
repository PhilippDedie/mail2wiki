#/bin/sh

# Eingabe:
# $1 - Postverzeichnis mit den zu importierenden E-Mails im Internet-Format
# $2 - Anzahl der zu importierenden E-Mails aus dem Postverzeichnis
# $3 - Zielverzeichnis mit vorhandenen Kontakt-Unterverzeichnissen
# $4 - Dateiname der E-Mail-zu-Kontaktverzeichnis-CSV-Liste
#      ( musz sich im Zielverzeichnis befinden )
# $5 - Dateiname der Liste der bekannten Message-IDs
# $6 - Dateinamenfilter fuer find (darf leer sein)

# Ausgabe:
# Importierte E-Mails in den Kontaktverzeichnissen im Zielverzeichnis

POSTVERZ="$1"
POSTZAHL=$2
ZIELVERZ=$3
LISTEADRESSEZUVERZ=$4
LISTEMESSAGEIDS=$5
DATEINAMENFILTER=$6
SKRIPTVERZ=`dirname $0`

Schleife() {
  echo $N $ARGS;
  ABSADR=`sh $SKRIPTVERZ/AbsenderAdresse.sh "$ARGS"`
  ABSNAME=`sh $SKRIPTVERZ/AbsenderName.sh "$ARGS"`
  UMGEKEHRT=0
  #echo "******" Absenderadresse ermittelt: $ABSADR "*********"
  #echo "******" Absendernamen ermittelt: $ABSNAME "*********"
  POSTABSENDERADRESSEN=`sh $SKRIPTVERZ/../Kontakte/Postabsenderadressen.sh "$ZIELVERZ" "$LISTEADRESSEZUVERZ"`
  # --erst hier ermitteln, weil zum Absender_namen_ zur Laufzeit
  # --weitere Absender_adressen_ hinzugefuegt werden koennen
  #echo Postabsenderadressen sind:
  #echo $POSTABSENDERADRESSEN

  if [ `echo $POSTABSENDERADRESSEN | grep -c $ABSADR` -ne 0 \
       -o `echo $POSTABSENDERDRESSEN | grep -c "$ABSNAME"` -ne 0 ]
  then
    ABSADR2=`sh $SKRIPTVERZ/ErsteEmpfaengerAdresse.sh "$ARGS"`
    # might be empty if defective mail header
    if [ "ABSADR2" != "" ]; then ABSADR="$ABSADR2"; fi
    UMGEKEHRT=1
    #echo Erste Empfängeradresse ist: $ABSADR
  fi
  KONTAKTVERZ=`sh $SKRIPTVERZ/../Kontakte/VerzZuAdresseErmitteln.sh $ABSADR $ZIELVERZ/$LISTEADRESSEZUVERZ`
  #echo "********" Kontaktverzeichnis zu $ABSADR ermittelt: $KONTAKTVERZ "*********"
  if [ "$KONTAKTVERZ" = "" ]; then
    #echo Erstelle neuen Kontakt für $ABSADR
    KONTAKTVERZ=`sh $SKRIPTVERZ/../Kontakte/NeuErstellenAusMail.sh \
      "$ARGS" "$ZIELVERZ" $LISTEADRESSEZUVERZ $UMGEKEHRT`
    #echo Neuer Kontakt \"$KONTAKTVERZ\" erstellt aus $ARGS
  fi
  echo Kontaktverz. nach neu erstellen: $KONTAKTVERZ
  sh $SKRIPTVERZ/EineEntpacken.sh \
    "$ARGS" "$ZIELVERZ/$KONTAKTVERZ" $LISTEMESSAGEIDS;
  echo -n "ID: " ; tail -n 1 $ZIELVERZ/$LISTEMESSAGEIDS
  N=$(expr $N + 1);
  if [ $N -gt $POSTZAHL ]
  then
    break
  fi
  echo -n . 
}

if [ "$DATEINAMENFILTER" = "" ]
then
  find "$POSTVERZ" -type f > /tmp/lst
else
  find "$POSTVERZ" -iname "$DATEINAMENFILTER" -type f > /tmp/lst
fi

N=1
while read -r ARGS; do
  Schleife
done < /tmp/lst

echo
echo $(expr $N - 1) messages imported out of $(wc -l /tmp/lst | sed 's/ .*//') input files found
