#!/bin/sh

# Eingabe:
# $1 - Verzeichnis, in dem gerade von munpack eine E-Mail entpackt (dekodiert) wurde

# Ausgabe:
# Bugbereinigtes Verzeichnis, siehe hierunter

MAILVERZ=$1
SKRIPTVERZ=`dirname $0`

for DATEI in `ls -1 $MAILVERZ`
do
  DATEINEU=
  DATEIALT=`basename "$DATEI"`
  # BUG 0 #########
  # munpack does nor recognize WINDOWS-1252 encoding, which results in
  # creating this directory containing this file:
  #  =_WINDOWS-1252_B_S29uZ3Jlc3NfTWV0YXBoZXJfT3NuYWJy/GNrLnBkZg==X=
  # when receiving this filename:
  #  filename="=?WINDOWS-1252?b?S29uZ3Jlc3NfTWV0YXBoZXJfT3NuYWJy/GNrLnBkZg==?="
  # because there is a slash in the encoded filename.
  # Bugfix:
  #echo "DATEIALT = " "$DATEIALT"
  if [ -d "$DATEIALT" ]
  then
    DATEINEU=`echo "$DATEIALT"/* \
      | sed 's/^=X/=?/; s/X[Qq]X/?Q?/g; s/X[Bb]X/?B?/; s/X=XX=X/?==?/g; s/X=$/?=/' \
      | sh $SKRIPTVERZ/HeaderfeldDekodieren.sh`
    mv "$DATEIALT"/* "$DATEINEU"
    rmdir "$DATEIALT"
    DATEINEU=

  # BUG 1 #########
  # munpack erkennt keine kodierten Anhangsnamen, sondern speichert
  # die Dateinamen in kodierter Form ab, wobei ? durch X ersetzt ist.
  # Korrektur:
  elif [ `echo "$DATEIALT" | grep -c '^=X'` -ne 0 ]
  then
    DATEINEU=`echo "$DATEIALT" \
      | sed 's/^=X/=?/; s/X[Qq]X/?Q?/g; s/X[Bb]X/?B?/; s/X=XX=X/?==?/g; s/X=$/?=/' \
      | sh $SKRIPTVERZ/HeaderfeldDekodieren.sh`
  # Substitution von X=XX=X ist erforderlich, weil munpack einen
  # Zeilenumbruch im MIME-Dateinamen, z.B. 
  # "=?UTF-8?Q?Barockw_Kurse-Vortr=C3=A4ge-Konzerte.?="
  # "=?UTF-8?Q?doc?="
  # damit ersetzt ("?=\n=?" -> "X=XX=X" -> "?==?")

  # BUG 1.1
  # If munpack receives this filename information:
  #  name="arbeit Nr. 3 =?ISO-8859-15?Q?Er=F6rterung=2Epdf?="
  # it creates this filename:
  #  arbeitXNr.X3X=XISO-8859-15XQXEr=F6rterung=2EpdfX=
  # which is a bug related to bug 1, but does not start with "=X"
  # in the resulting filename.
  elif [ `echo "$DATEIALT" | grep -c 'X=$'` -ne 0 ]
  then
    DATEINEU=`echo "$DATEIALT" \
      | sed 's/=X/=?/; s/X[Qq]X/?Q?/g; s/X[Bb]X/?B?/; s/X=XX=X/?==?/g; s/X=$/?=/; s/X/ /g' \
      | sh $SKRIPTVERZ/HeaderfeldDekodieren.sh`

  # BUG 1.2
  # If munpack receives this filename information:
  #   name="Studieninformation  akustisch-visuelle und =?ISO-8859-1?Q?Graphem-Farb-Sy?==?ISO-8859-1?Q?n=E4sthesie=2Epdf?="
  # it creates this filename:
  # Studieninformation  akustisch-visuelle und Graphem-Farb-Sy == ISO-8859-1?Q?nästhesie.pdf
  elif [ `echo "$DATEIALT" | grep -c ' == [^?]*?[QqBb]?'` -ne 0 ]
  then
    DATEINEU=`echo "§DATEIALT" \
      | sed 's/ == [^?]*?[QqBb]?//'`

  # BUG 2 ########
  # munpack replaces ? and & characters in filenames by X.
  # Here, we also replace = characters by _.
  elif [ `echo "$DATEIALT" | grep -c '='` -ne 0 ]
  then
    DATEINEU=`echo "$DATEIALT" | sed 's/=/_/g'`

  fi

  if [ "$DATEINEU" != "" ]
  then
    SAUBERNAME=`echo $DATEINEU | perl $SKRIPTVERZ/../Wiki/CleanFilenames.pl`
    mv "$MAILVERZ/$DATEIALT" "$MAILVERZ/$SAUBERNAME"
  fi

done
