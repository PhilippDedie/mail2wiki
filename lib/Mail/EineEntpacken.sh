#!/bin/sh

# Eingabe:
# $1 - Dateiname der E-Mail
# $2 - Zielverzeichnis
# $3 - Dateiname der Liste der bekannten Message-IDs
#      (musz sich im Verzeichnis oberhalb des Zielverzeichnisses befinden)

# Ausgabe:
# Als Unterverzeichnis des Absender-Kontaktes 
#   (des Zielverzeichnisses) abgelegte E-Mail


ABLAGEVERZ=$2
LISTEMESSAGEIDS=$3
SKRIPTVERZ=$PWD/`dirname $0`

#echo Bearbeite "$1"
MESSAGEID=$( cat "$1" \
| sed '/^$/q; /^Message-/{ s/^Message-Id:.<//i; s/>$//; q}; d' \
| sh $SKRIPTVERZ/HeaderfeldInDateinamenWandeln.sh
)
#MESSAGEID=`cat "$1" \
#| reformail -x Message-Id:`
if [ "$MESSAGEID" = "" ]
then
  # Datum als Ersatz
  MESSAGEID=$(cat "$1" \
  | reformail -x Date: \
  | sh $SKRIPTVERZ/HeaderfeldInDateinamenWandeln.sh \
  | tr ' ' '_'
  )
fi

if [ -f $ABLAGEVERZ/../$LISTEMESSAGEIDS ]; then
  cat $ABLAGEVERZ/../$LISTEMESSAGEIDS | grep "$MESSAGEID" > /dev/null \
  && {
    #echo Message-ID bekannt
    exit
  }
fi

DATE=`cat "$1" \
| reformail -x Date:`
SUBJECT=`cat "$1" \
| reformail -x Subject: \
| sh $SKRIPTVERZ/HeaderfeldDekodieren.sh \
| sh $SKRIPTVERZ/HeaderfeldInDateinamenWandeln.sh`
#echo Betreff: "$SUBJECT"
if [ "$SUBJECT" = "" ]
then
  SUBJECT=Unbenannt
fi

#LFDNR=`echo "$1" | sed 's/^.*,U=//;s/,FMD5=.*$//'`

MAILVERZ=$MESSAGEID
#MAILVERZ=$LFDNR
#DEKODIERER=`echo uudeview -p "$ABLAGEVERZ/$MAILVERZ" -t -`
DEKODIERER=`echo munpack -f -t -C $ABLAGEVERZ/$MAILVERZ`

#echo "Erstelle Mailverz. $MAILVERZ"
mkdir -p "$ABLAGEVERZ/$MAILVERZ"

sh $SKRIPTVERZ/catNachStdUtf8.sh "$1" \
| $DEKODIERER > "$ABLAGEVERZ/$MAILVERZ/log" 2>&1
sh $SKRIPTVERZ/DekodiererbugsEntfernen.sh "$ABLAGEVERZ/$MAILVERZ"

cp "$1" "$ABLAGEVERZ/$MAILVERZ/src"

cat "$1" \
| sed -e '/^$/ q' \
> "$ABLAGEVERZ/$MAILVERZ/hdr"

grep -qi "^Content-Type:" "$1" \
&& CONTENTTYPE=$(cat "$1" \
| reformail -x Content-Type: \
| sed 's/;.*$//' \
) \
|| CONTENTTYPE=unbekannt


  #echo Content-Type aus dem Nachrichtenkopf: $CONTENTTYPE
  #echo Content-Type aus dem Entpacker-Log: $(sed '/^part1/{s/^.*(//;s/)$//;n}; d' $ABLAGEVERZ/$MAILVERZ/log)
  if [ ! -f "$ABLAGEVERZ/$MAILVERZ/part1" ]; then
    #echo $MAILVERZ: part1 fehlt
    diff -n "$ABLAGEVERZ/$MAILVERZ/hdr" "$1" \
    | sed '1d' \
    > "$ABLAGEVERZ/$MAILVERZ/part1"
  fi
  # part1 existiert jetzt, koennte aber Groesze 0 haben
  if [ ! -s "$ABLAGEVERZ/$MAILVERZ/part1" ]
  then
    sed 's/\r$//; 1,/^$/d' "$1" > "$ABLAGEVERZ/$MAILVERZ/part1"
  fi
  #echo $LFDNR: $CONTENTTYPE
  if [ "$CONTENTTYPE" = "text/html" ]; then
    ENDUNG=html
  elif [ "$CONTENTTYPE" = "text/plain" ]; then
    ENDUNG=txt
  elif [ "`sed '/^part1/{s/^.*(//;s/)$//;n}; d' $ABLAGEVERZ/$MAILVERZ/log`" = "text/html" ]; then
    ENDUNG=html
  else
    ENDUNG=txt
  fi
  if [ "$ENDUNG" = "txt" ]; then
    sh $SKRIPTVERZ/catNachStdUtf8.sh "$ABLAGEVERZ/$MAILVERZ/part1" \
    | sh $SKRIPTVERZ/UntereZitateAusblenden.sh \
    | sh $SKRIPTVERZ/Textumbruch.sh \
    > "$ABLAGEVERZ/$MAILVERZ/$SUBJECT".txt
    rm -f "$ABLAGEVERZ/$MAILVERZ/part1"
  else
    mv "$ABLAGEVERZ/$MAILVERZ/part1" "$ABLAGEVERZ/$MAILVERZ/$SUBJECT.$ENDUNG"
  fi

## part2 (html) statt part1 verwenden, deaktiviert:
if [ -f "$ABLAGEVERZ/$MAILVERZ/part2" ]; then
#  mv "$ABLAGEVERZ/$MAILVERZ/part2" "$ABLAGEVERZ/$MAILVERZ/$SUBJECT.html"
#  #touch -d "$DATE" "$ABLAGEVERZ/$MAILVERZ/$SUBJECT.html"
#  rm -f "$ABLAGEVERZ/$MAILVERZ/part1"
  mv "$ABLAGEVERZ/$MAILVERZ/part2" "$ABLAGEVERZ/$MAILVERZ/$SUBJECT.html"
fi

DATE_EPOCH=$(date --date="$DATE" +%s)
DATE_PLUS_EINS=$(expr $DATE_EPOCH + 1)
# Das ist, um die Anhaenge im Wiki unterhalb (spaeter)
# als den Nachrichtentext darzustellen.
ls -1 "$ABLAGEVERZ/$MAILVERZ" > /tmp/lst2
while read FILE
do
  echo "$FILE" | egrep "\.(txt|html)$" > /dev/null \
  && touch -d "$DATE" "$ABLAGEVERZ/$MAILVERZ/$FILE" \
  || touch -d @$DATE_PLUS_EINS "$ABLAGEVERZ/$MAILVERZ/$FILE"
done < /tmp/lst2

echo $MESSAGEID >> $ABLAGEVERZ/../$LISTEMESSAGEIDS
