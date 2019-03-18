#!/bin/bash

# Defines path of test folder where files will be created
if [ -z "$1" ]; then
    TEST_FOLDER=$HOME/test
else
    TEST_FOLDER=$1
fi

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
    NUMBER_OF_FILES_TO_BE_DELETED=1
else
    NUMBER_OF_FILES_TO_BE_DELETED=$4
    if [ $NUMBER_OF_FILES_TO_BE_DELETED -ge $NUMBER_OF_FILES_CREATED ]; then
        echo "Number of files to be deleted is invalid!"
        exit 1
    fi
fi

# Defines number of test files to be modified
if [ -z "$5" ]; then
    NUMBER_OF_FILES_TO_BE_MODIFIED=2
else
    NUMBER_OF_FILES_TO_BE_MODIFIED=$5 
    VALID_NUMBER=$(($NUMBER_OF_FILES_CREATED - $NUMBER_OF_FILES_TO_BE_DELETED))
    if [ $NUMBER_OF_FILES_TO_BE_MODIFIED -ge $VALID_NUMBER ]; then
        echo "Number of files to be modified is invalid!"
        exit 1
    fi
fi

# Checks if folder where files will be created exists
# If folder doesn't exist, creates folder
if [ ! -d "$TEST_FOLDER" ]; then
    if [ ! -L "$LINK_OR_DIR" ]; then
        mkdir $TEST_FOLDER
    fi
fi

# Creates test files
# Files are named as UUID if uuidgen is avail, otherwise files are named
# using date + random
while [ $NUMBER_OF_FILES_CREATED -gt 0 ]; do
    if [ -z $(command -v uuidgen) ]; then
        DATE=$(date +%s)
        FILENAME=$(($DATE + $RANDOM))
    else
        FILENAME=$(uuidgen)
    fi

    dd if=/dev/urandom of=$TEST_FOLDER/$FILENAME bs=1024 count=$FILE_SIZE

    NUMBER_OF_FILES_CREATED=$(($NUMBER_OF_FILES_CREATED-1))
done

# Deletes random files from test folder
while [ $NUMBER_OF_FILES_TO_BE_DELETED -gt 0 ]; do
    NUMBER_OF_FILES_AVAIL=$(ls -1 $TEST_FOLDER | wc -l)
    FILES=($TEST_FOLDER/*)
    FILE_TO_DELETE="${FILES[$RANDOM % $NUMBER_OF_FILES_AVAIL]}"
    if [[ -d $FILE_TO_DELETE ]]; then
        rm -rf $FILE_TO_DELETE
    else
        rm $FILE_TO_DELETE
    fi
    NUMBER_OF_FILES_TO_BE_DELETED=$(($NUMBER_OF_FILES_TO_BE_DELETED-1))
done

# Modifies random files from test folder
while [ $NUMBER_OF_FILES_TO_BE_MODIFIED -gt 0 ]; do
    NUMBER_OF_FILES_AVAIL=$(ls -1 $TEST_FOLDER | wc -l)
    FILES=($TEST_FOLDER/*)
    FILE_TO_MODIFY="${FILES[$RANDOM % $NUMBER_OF_FILES_AVAIL]}"
    if [[ -d $FILE_TO_MODIFY ]]; then
        continue
    fi
    dd if=/dev/urandom of=$FILE_TO_MODIFY bs=1024 count=$FILE_SIZE
    NUMBER_OF_FILES_TO_BE_MODIFIED=$(($NUMBER_OF_FILES_TO_BE_MODIFIED-1))
done