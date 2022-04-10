#!/usr/bin/env sh

###############################################################################
#
# Author : Matuzalem (Mat) Muller dos Santos
# URL    : https://github.com/matuzalemmuller/test-files-creator
#
# Description:
#   Creates files with random content using common bash expressions and tools.
#   The size of the files is specified in **bytes**.
#
# Parameters:
#   - [REQUIRED] -o, --output: folder where files will be saved
#   - [REQUIRED] -s, --size: size of the files to be created
#   - [REQUIRED] -c, --create: number of files to create
#   - [OPTIONAL] -l, --log: log file
#   - [OPTIONAL] --csv: log file output in csv format
#                            Supported values: md5 and sha256
#
# Example:
#   Create 10 files in the folder 'test-folder', with 1 MB of size each.
#   ./test-files-creator.sh -o=test-folder -s=1024 -c=10
###############################################################################

# Parses arguments. Based on https://stackoverflow.com/a/14203146
for i in "$@"; do
  case $i in
    -o=*|--output=*)
      OUTPUT_FOLDER="${i#*=}"
      shift # past argument=value
      ;;
    -o|--output)
      echo "Missing parameter for --output"
      exit 1
      ;;
    -s=*|--size=*)
      FILE_SIZE="${i#*=}"
      shift # past argument=value
      ;;
    -s|--size)
      echo "Missing parameter for --size"
      exit 1
      ;;
    -c=*|--create=*)
      CREATE="${i#*=}"
      shift # past argument=value
      ;;
    -c|--c)
      echo "Missing parameter for --create"
      exit 1
      ;;
    -l=*|--log=*)
      LOG_FILE="${i#*=}"
      shift # past argument=value
      ;;
    -l|--log)
      echo "Missing parameter for --log"
      exit 1
      ;;
    --csv)
      LOG_FORMAT=CSV
      shift
      ;;
    -h=*|--hash=*)
      HASH_ALG="${i#*=}"
      shift
      ;;
    -h|--hash)
      echo "Missing parameter for --hash"
      exit 1
      ;;
    -v|--verbose)
      VERBOSE=YES
      shift
      ;;
    -*|--*)
      echo "Unknown option $i"
      exit 1
      ;;
    *)
      ;;
  esac
done

# Verbose output
if [ "$VERBOSE" = "YES" ]; then
  echo "-------------------------------------------------------------"
  echo "OUTPUT FOLDER    = ${OUTPUT_FOLDER}"
  echo "SIZE (BYTES)     = ${FILE_SIZE}"
  echo "CREATE # FILES   = ${CREATE}"
  echo "LOG FILE         = ${LOG_FILE}"
  echo "LOG FORMAT       = ${LOG_FORMAT}"
  echo "HASH_ALG         = ${HASH_ALG}"
  echo "-------------------------------------------------------------"
fi

########################### ARGUMENT VALIDATION ###############################


# Check if file size is integer and greater than 0
if ! [ "$FILE_SIZE" -gt 0 > /dev/null 2>&1 ]; then
  echo "Invalid input argument for --size"
  exit 1
fi

# Check if number of files to be created is integer and greater than 0
if ! [ "$CREATE" -gt 0 > /dev/null 2>&1 ]; then
  echo "Invalid input argument for --create"
  exit 1
fi

# Check if argument for folder output was provided
if ! [ -n "$OUTPUT_FOLDER" ]; then
  echo "Missing argument --output"
  exit 1
fi

# Checks if folder where files will be created exists
# If folder doesn't exist, creates folder
if [ ! -d "$OUTPUT_FOLDER" ]; then
  if [ ! -L "$OUTPUT_FOLDER" ]; then
    mkdir "$OUTPUT_FOLDER"
  fi
fi

# Updates variable value to use absolute path (useful to log file path)
OUTPUT_FOLDER=$(realpath ${OUTPUT_FOLDER})

# Defaults log format to TXT is CSV is not defined
if ! [ -n "$LOG_FORMAT" ]; then
  LOG_FORMAT=TXT
fi

# Create log file
if [ -n "$LOG_FILE" ]; then
  touch ${LOG_FILE} > /dev/null 2>&1
  if ! [ -f ${LOG_FILE} ]; then
    echo "Log output cannot be saved at ${LOG_FILE}"
    exit 1
  fi

  # Checks if hash program is installed if hash logging is enabled
  if [ -n "$HASH_ALG" ]; then
    if [ "$HASH_ALG" = "md5" ]; then
      LOG_FORMAT=CSV
      if [ -z $(command -v md5sum) ]; then
        echo "Can't log hash because md5sum is not installed"
        exit 1
      fi
    elif [ "$HASH_ALG" = "sha256" ]; then
      LOG_FORMAT=CSV
      if [ -z $(command -v sha256sum) ]; then
        echo "Can't log hash because sha256sum is not installed"
        exit 1
      fi
    else
      echo "Hash algorithm not supported"
      exit 1
    fi
  fi
fi

###############################################################################

# Creates test files
while [ $CREATE -gt 0 ]; do
  # If uuidgen is not available, names files based on date and random
  if [ -z $(command -v uuidgen) ]; then
    DATE=$(date +%s)
    FILE_NAME="$(($DATE + $RANDOM))$RANDOM"
  else
    FILE_NAME=$(uuidgen)
  fi

  # Creates file
  dd if=/dev/urandom of=$OUTPUT_FOLDER/$FILE_NAME bs=1024 count=$FILE_SIZE status=none

  # Verbose output
  if [ "$VERBOSE" = "YES" ]; then
    echo "Created $OUTPUT_FOLDER/$FILE_NAME"
  fi

  # Logs file creation
  if [ -n "$LOG_FILE" ]; then
    # Calculates hash
    if [ -n "$HASH_ALG" ]; then
      if [ "$HASH_ALG" = "md5" ]; then
        hash=$(md5sum ${OUTPUT_FOLDER}/${FILE_NAME} | awk '{ print $1 }')
        hash=";${hash}"
      elif [ "$HASH_ALG" = "sha256" ]; then
        hash=$(sha256sum ${OUTPUT_FOLDER}/${FILE_NAME} | awk '{ print $1 }')
        hash=";${hash}"
      fi
    fi
    # Saves log to file
    if [ "$LOG_FORMAT" = "TXT" ]; then
      date +"%H:%M:%S %D - CREATE - $FILE_SIZE KB - $OUTPUT_FOLDER/$FILE_NAME" >> $LOG_FILE
    elif [ "$LOG_FORMAT" = "CSV" ]; then
      date +"%H:%M:%S %D;CREATE;$FILE_SIZE KB;$OUTPUT_FOLDER/$FILE_NAME${hash}" >> $LOG_FILE
    fi
  fi

  CREATE=$(($CREATE-1))
done