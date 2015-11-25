#!/bin/sh

# Eingabe:
# $1 - Dateiname der E-Mail
# $2 - Zielverzeichnis
# $3 - Name of the mail directory to be created
#      (currently the message ID)

# Ausgabe:
# Als Unterverzeichnis des Absender-Kontaktes 
#   (des Zielverzeichnisses) abgelegte E-Mail


ABLAGEVERZ="$2"
MESSAGEID=$3
SKRIPTVERZ=`dirname $0`

MAILVERZ=$MESSAGEID
#MAILVERZ=$LFDNR
#echo "Erstelle Mailverz. $MAILVERZ"
mkdir -p "$ABLAGEVERZ/$MAILVERZ"

DATE=`cat "$1" \
| reformail -x Date:`
cat "$1" \
| reformail -x Subject: \
| sh $SKRIPTVERZ/HeaderfeldDekodieren.sh \
> $ABLAGEVERZ/$MAILVERZ/subject

#LFDNR=`echo "$1" | sed 's/^.*,U=//;s/,FMD5=.*$//'`

#DEKODIERER=`echo uudeview -p "$ABLAGEVERZ/$MAILVERZ" -t -`
DEKODIERER=`echo munpack -f -t -C $ABLAGEVERZ/$MAILVERZ`

sh $SKRIPTVERZ/catNachStdUtf8.sh "$1" \
| $DEKODIERER > "$ABLAGEVERZ/$MAILVERZ/log" 2>&1
sh $SKRIPTVERZ/DekodiererbugsEntfernen.sh "$ABLAGEVERZ/$MAILVERZ"

cp "$1" "$ABLAGEVERZ/$MAILVERZ/src"

sh $SKRIPTVERZ/catNachStdUtf8.sh "$1" \
| sed -e '/^$/ q' \
> "$ABLAGEVERZ/$MAILVERZ/hdr"

grep -qi "^Content-Type:" "$1" \
&& CONTENTTYPE=$(cat "$1" \
| reformail -x Content-Type: \
| sed 's/;.*$//' \
) \
|| CONTENTTYPE=unbekannt


#echo Content-Type from mail header: $CONTENTTYPE
#echo Content-Type from unpacker log: $(sed '/^part1/{s/^.*(//;s/)$//;n}; d' $ABLAGEVERZ/$MAILVERZ/log)
if [ ! -f "$ABLAGEVERZ/$MAILVERZ/part1" ]; then
  #echo $MAILVERZ: part1 missing
  sh $SKRIPTVERZ/catNachStdUtf8.sh "$ABLAGEVERZ/$MAILVERZ/src" \
  | sed '1,/^$/d' \
  > "$ABLAGEVERZ/$MAILVERZ/part1"
fi

# part1 exists now but might have size 0
if [ ! -s "$ABLAGEVERZ/$MAILVERZ/part1" ]
then
  sed 's/\r$//; 1,/^$/d' "$1" > "$ABLAGEVERZ/$MAILVERZ/part1"
fi

# Determine the file type for the part1 of the message:
if [ "$CONTENTTYPE" = "text/html" ]; then
    PART1TYPE=html
elif [ "$CONTENTTYPE" = "text/plain" ]; then
    PART1TYPE=txt
elif [ "`sed '/^part1/{s/^.*(//;s/)$//;n}; d' $ABLAGEVERZ/$MAILVERZ/log`" = "text/html" ]; then
    PART1TYPE=html
else
    PART1TYPE=txt
fi

# Determine which source to use for the message body:
if [ -f "$ABLAGEVERZ/$MAILVERZ/part2" ]
then
  BODYSOURCE=part2
else
  BODYSOURCE=part1
fi

# Determine whether HTML has to be converted to text:
if [ "$BODYSOURCE" = "part2" -o "$PART1TYPE" = "html" ]
then
  HTMLFILTER="html2text -utf8"
else
  HTMLFILTER="cat"
fi

# Write message body file:
sh $SKRIPTVERZ/catNachStdUtf8.sh "$ABLAGEVERZ/$MAILVERZ/$BODYSOURCE" \
| $HTMLFILTER \
> "$ABLAGEVERZ/$MAILVERZ/bodysource.txt.bak"
cat "$ABLAGEVERZ/$MAILVERZ/bodysource.txt.bak" \
| sh $SKRIPTVERZ/UntereZitateAusblenden.sh \
| sh $SKRIPTVERZ/Textumbruch.sh \
> "$ABLAGEVERZ/$MAILVERZ/message.txt"


# Keep HTML file, if existing, for the record.
if [ "$BODYSOURCE" = "part2" ]
then
  mv "$ABLAGEVERZ/$MAILVERZ/part2" "$ABLAGEVERZ/$MAILVERZ/message.html"
  rm "$ABLAGEVERZ/$MAILVERZ/part1"
elif [ "$PART1TYPE" = "html" ]
then
  mv "$ABLAGEVERZ/$MAILVERZ/part1" "$ABLAGEVERZ/$MAILVERZ/message.html"
else
  rm "$ABLAGEVERZ/$MAILVERZ/part1"
fi
  
