#!/bin/sh

# Input:
# $1 - Base directory for $2
# $2 - filename of file containing each mbox file in a separate line
#      filenames are relative to $1
# $3 - output directory. Will be overwritten!

# Output:
# Output directory with subdirectories for every mbox file
# and every mail as a numbered .eml file in the subdirectories

BASEDIR=$1
TARGET=$3
FILELIST=$2

if [ ! -d "$BASEDIR" ]
then
  echo "$BASEDIR" is not a directory.
  exit
fi

read -p "Will delete $TARGET. Press Ctrl-C to abort or Return to continue!" DUMMY
rm -r $TARGET
mkdir $TARGET

while IFS='|' read MBOXNAME
do
  MBOXDIR=$(echo "$MBOXNAME" | sed 's|[/ ]|_|g')
  echo Creating $MBOXDIR
  mkdir $TARGET/$MBOXDIR
  cd $TARGET/$MBOXDIR
  cat "$BASEDIR"/"$MBOXNAME" | reformail -s sh -c 'cat > $FILENO.eml'
done < $FILELIST
