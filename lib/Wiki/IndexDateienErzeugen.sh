#!/bin/sh

# Eingabe:
# $1 - Basisverzeichnis, das nach Kontakte-Unterverzeichnissen
#      durchsucht werden soll
# $2 - Klartextname des Postabsenders

# Ausgabe:
# (1) index.mdwn im Zielverzeichnis
#     mit Verweisen auf alle Kontaktseiten
#     sowie die Postabsenderdaten auf dem Wiki-Seitenkopf
# (2) index.mdwn in jedem Unterverzeichnis des Zielverzeichnisses

BASISVERZ=$1
POSTABSENDERKLARTEXT=$2

POSTABSENDERVCFPFAD=`ls -1 $BASISVERZ/*.vcf | head -n 1 2>&1`
POSTABSENDERNAME=`echo $POSTABSENDERVCFPFAD | sed "s|^\$BASISVERZ/||; s/\.vcf$//"`

echo "# Kontakte von $POSTABSENDERKLARTEXT" > $BASISVERZ/index.mdwn
echo >> $BASISVERZ/index.mdwn
echo "[$POSTABSENDERNAME.vcf]($POSTABSENDERNAME.vcf)" >> $BASISVERZ/index.mdwn
echo >> $BASISVERZ/index.mdwn

ls "$BASISVERZ" \
| xargs -n 1 \
| while read ARGS; do
    if [ -d "$BASISVERZ/$ARGS" ]; then
      echo "* [$ARGS]($ARGS)" >> $BASISVERZ/index.mdwn
      echo "# Unterhaltung mit $ARGS" > $BASISVERZ/$ARGS/index.mdwn
      echo "[[!inline pages=\""$ARGS"/* and !*/hdr and !*/log and !*/src\" sort=\"-age\"]]" \
        >> $BASISVERZ/$ARGS/index.mdwn
    fi
  done


#    print f > f"/index.mdwn";
#    print "[[!inline pages=\""f"/* and !*/hdr and !*/log and !*/src\" sort=\"-age\"]]" > f"/index.mdwn";
