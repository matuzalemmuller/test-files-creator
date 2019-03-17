#!/bin/bash

# Defines path of test folder where files will be created
if [ -z "$1" ]; then
    TEST_FOLDER=$HOME/test
else
    TEST_FOLDER=$1
fi

# Defines number of test files created
if [ -z "$2" ]; then
    NUMBER_OF_FILES_CREATED=2
else
    NUMBER_OF_FILES_CREATED=$2
fi

# Defines size of test files in KB
if [ -z "$3" ]; then
    FILE_SIZE=50000
else
    FILE_SIZE=$3
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
while [  $NUMBER_OF_FILES_CREATED -gt 0 ]; do
    if [ -z $(command -v uuidgen) ]; then
        DATE=$(date +%s)
        FILENAME=$(($DATE+$RANDOM))
    else
        FILENAME=$(uuidgen)
    fi

    dd if=/dev/zero of=$TEST_FOLDER/$FILENAME bs=1024 count=$FILE_SIZE

    NUMBER_OF_FILES_CREATED=$(($NUMBER_OF_FILES_CREATED-1))
done

# Deletes random file from test folder
FILE_TO_DELETE=$(ls $TEST_FOLDER | sort -g | head -1)
rm $TEST_FOLDER/$FILE_TO_DELETE

# Modifies random file from test folder
FILE_TO_MODIFY=$(ls $TEST_FOLDER | sort -g | head -1)
dd if=/dev/zero of=$TEST_FOLDER/$FILE_TO_MODIFY bs=1024 count=$FILE_SIZE