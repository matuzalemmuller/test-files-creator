#!/usr/bin/env bash

########################## USAGE ##########################
#
# ./script.sh <folder> <file_size_KB> <files_created> <files_deleted> <files_modified> 
#
# Example
# ./script.sh test-folder 1024 10 2 8
###########################################################

# Checks if values for files to be created, deleted and modified are 0
if [ ! -z "$3" ] && [ ! -z "$4" ] && [ ! -z "$5" ]; then
  if [ "$3" -eq 0 ] && [ "$4" -eq 0 ] && [ "$5" -eq 0 ]; then
    echo "No changes"
    exit 0
  fi
fi

# Defines path of test folder where files will be created
if [ -z "$1" ]; then
  TEST_FOLDER=$HOME/test
else
  TEST_FOLDER=$1
fi

# Checks if folder where files will be created exists
# If folder doesn't exist, creates folder
if [ ! -d "$TEST_FOLDER" ]; then
  if [ ! -L "$LINK_OR_DIR" ]; then
    mkdir "$TEST_FOLDER"
    CREATE_FOLDER=1
  fi
else
  CREATE_FOLDER=0
fi
NUMBER_OF_FILES_AVAIL=$(ls -1 $TEST_FOLDER | wc -l)

# Defines size of test files in KB
if [ -z "$2" ]; then
  FILE_SIZE=50000
else
  FILE_SIZE=$2
fi

# Defines number of test files created
if [ -z "$3" ]; then
  NUMBER_OF_FILES_CREATED=5
else
  NUMBER_OF_FILES_CREATED=$3
fi

# Defines number of test files to be deleted
if [ -z "$4" ]; then
  NUMBER_OF_FILES_TO_BE_DELETED=0
else
  NUMBER_OF_FILES_TO_BE_DELETED=$4
  VALID_NUMBER=$((NUMBER_OF_FILES_AVAIL + NUMBER_OF_FILES_CREATED))
  if [ "$NUMBER_OF_FILES_TO_BE_DELETED" -gt "$VALID_NUMBER" ]; then
    echo "Number of files to be deleted is invalid!"
    if [ $CREATE_FOLDER -eq 1 ]; then
      rm -rf "$TEST_FOLDER"
    fi
    exit 1
  fi
fi

# Defines number of test files to be modified
if [ -z "$5" ]; then
  NUMBER_OF_FILES_TO_BE_MODIFIED=0
else
  NUMBER_OF_FILES_TO_BE_MODIFIED=$5 
  VALID_NUMBER=$((NUMBER_OF_FILES_AVAIL + NUMBER_OF_FILES_CREATED))
  VALID_NUMBER=$((VALID_NUMBER - NUMBER_OF_FILES_TO_BE_DELETED))
  if [ "$NUMBER_OF_FILES_TO_BE_MODIFIED" -gt "$VALID_NUMBER" ]; then
    echo "Number of files to be modified is invalid!"
    if [ $CREATE_FOLDER -eq 1 ]; then
      rm -rf $TEST_FOLDER
    fi
    exit 1
  fi
fi

# Get location of script so log file can be created
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# Creates test files
# Files are named as UUID if uuidgen is avail, otherwise files are named
# using date + random
while [ $NUMBER_OF_FILES_CREATED -gt 0 ]; do
  if [ -z $(command -v uuidgen) ]; then
    DATE=$(date +%s)
    FILE_TO_CREATE="$(($DATE + $RANDOM))$RANDOM"
  else
    FILE_TO_CREATE=$(uuidgen)
  fi

  dd if=/dev/urandom of=$TEST_FOLDER/$FILE_TO_CREATE bs=1024 count=$FILE_SIZE

  NUMBER_OF_FILES_CREATED=$(($NUMBER_OF_FILES_CREATED-1))
  date +"%H:%M:%S %D - CREATE - $TEST_FOLDER/$FILE_TO_CREATE - $FILE_SIZE KB" >> $DIR/script.log
done

# Deletes random files from test folder
while [ "$NUMBER_OF_FILES_TO_BE_DELETED" -gt 0 ]; do
  NUMBER_OF_FILES_AVAIL=$(ls -1 $TEST_FOLDER | wc -l)
  FILES=($TEST_FOLDER/*)
  FILE_TO_DELETE="${FILES[$RANDOM % $NUMBER_OF_FILES_AVAIL]}"
  if [[ -d "$FILE_TO_DELETE" ]]; then
    rm -rf "$FILE_TO_DELETE"
  else
    rm "$FILE_TO_DELETE"
  fi
  NUMBER_OF_FILES_TO_BE_DELETED=$(($NUMBER_OF_FILES_TO_BE_DELETED-1))
  date +"%H:%M:%S %D - DELETE - $FILE_TO_DELETE" >> $DIR/script.log
done

# Modifies random files from test folder
NUMBER_OF_FILES_AVAIL=$(ls -1 $TEST_FOLDER | wc -l)
while [ $NUMBER_OF_FILES_TO_BE_MODIFIED -gt 0 ]; do
  FILES=($TEST_FOLDER/*)
  FILE_TO_MODIFY="${FILES[$RANDOM % $NUMBER_OF_FILES_AVAIL]}"
  if [[ -d $FILE_TO_MODIFY ]]; then
    continue
  fi
  dd if=/dev/urandom of=$FILE_TO_MODIFY bs=1024 count=$FILE_SIZE
  NUMBER_OF_FILES_TO_BE_MODIFIED=$(($NUMBER_OF_FILES_TO_BE_MODIFIED-1))
  date +"%H:%M:%S %D - MODIFY - $FILE_TO_MODIFY" >> $DIR/script.log
done
