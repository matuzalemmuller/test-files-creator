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
#   - [REQUIRED] -o,   --output:   folder where files will be saved
#   - [REQUIRED] -s,   --size:     size of the files to be created
#   - [REQUIRED] -n,   --n_files:  number of files to create
#   - [OPTIONAL] -v,   --verbose:  prints verbose output
#   - [OPTIONAL] -p,   --progress: shows progress bar
#   - [OPTIONAL] -l,   --log:      log file location
#   - [OPTIONAL] -csv, --csv:      log file output in csv format
#   - [OPTIONAL] -h,   --hash:     includes hash in log file in csv format
#                                  Supported values: md5 and sha256
#   - [OPTIONAL] --help:           prints help
#
# Example:
#   Create 5 files in the folder 'test-folder', with 1 MB of size each.
#   ./test-files-creator.sh -o=/tmp -s=1024 -c=5 -l=/tmp/log.csv -csv -h=md5 -p
###############################################################################

# Parses arguments. Based on https://stackoverflow.com/a/14203146
for i in "$@"; do
  case $i in
    -o=*|--output=*)
      OUTPUT_FOLDER="${i#*=}"
      shift
      ;;
    -o|--output)
      echo "Missing parameter for -o/--output"
      exit 1
      ;;
    -s=*|--size=*)
      FILE_SIZE="${i#*=}"
      shift
      ;;
    -s|--size)
      echo "Missing parameter for -s/--size"
      exit 1
      ;;
    -n=*|--n_files=*)
      CREATE="${i#*=}"
      shift
      ;;
    -n|--n_files)
      echo "Missing parameter for -n/--n_files"
      exit 1
      ;;
    -l=*|--log=*)
      LOG_FILE="${i#*=}"
      shift
      ;;
    -l|--log)
      echo "Missing parameter for -l/--log"
      exit 1
      ;;
    -csv|--csv)
      LOG_FORMAT=CSV
      shift
      ;;
    -h=*|--hash=*)
      HASH_ALG="${i#*=}"
      shift
      ;;
    -h|--hash)
      echo "Missing parameter for -h/--hash"
      exit 1
      ;;
    -v|--verbose)
      VERBOSE=YES
      shift
      ;;
    -p|--progress)
      PRINT_PROGRESS=YES
      shift
      ;;
    --help)
      PRINT_HELP=YES
      shift
      ;;
    -*|--*)
      echo "Unknown option $i. See --help for manual."
      exit 1
      ;;
    *)
      ;;
  esac
done

########################### ARGUMENT VALIDATION ###############################

if [ -n "$PRINT_HELP" ]; then
  echo " Description"
  echo "   Creates files with random content using common bash expressions and"
  echo "   tools. The size of the files is specified in **bytes**."
  echo ""
  echo " Parameters:"
  echo "  - [REQUIRED] -o,   --output:   folder where files will be saved"
  echo "  - [REQUIRED] -s,   --size:     size of the files to be created"
  echo "  - [REQUIRED] -n,   --n_files:  number of files to create"
  echo "  - [OPTIONAL] -v,   --verbose:  prints verbose output"
  echo "  - [OPTIONAL] -p,   --progress: shows progress bar"
  echo "  - [OPTIONAL] -l,   --log:      log file location"
  echo "  - [OPTIONAL] -csv, --csv:      log file output in csv format"
  echo "  - [OPTIONAL] -h,   --hash:     includes hash in log file in csv format"
  echo "                                 Supported values: md5 and sha256"
  echo "  - [OPTIONAL] --help:           prints help"
  echo ""
  echo " Example:"
  echo "   Create 5 files in the folder 'test-folder', with 1 MB of size each."
  echo "   ./test-files-creator.sh -o=/tmp -s=1024 -c=5 -l=/tmp/log.csv -csv -h=md5 -p"
  exit 0
fi

# Check if file size is integer and greater than 0
if ! [ -n "$FILE_SIZE" ]; then
  echo "Missing argument for -s/--size. See --help for manual."
  exit 1
fi

# Check if number of files to be created is integer and greater than 0
if ! [ -n "$CREATE" ]; then
  echo "Missing argument for -n/--n_files. See --help for manual."
  exit 1
fi

# Check if argument for folder output was provided
if ! [ -n "$OUTPUT_FOLDER" ]; then
  echo "Missing argument for -o/--output. See --help for manual."
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
  LOG_FILE=$(realpath ${LOG_FILE})
  touch ${LOG_FILE} > /dev/null 2>&1
  if ! [ -f ${LOG_FILE} ]; then
    echo "Log output cannot be saved at ${LOG_FILE}. See --help for manual."
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
      echo "Hash algorithm not supported. See --help for manual."
      exit 1
    fi
  fi
else
  if [ -n "$HASH_ALG" ]; then
    echo "Ignoring --hash, --log is not enabled. See --help for manual."
  fi
  if [ "$LOG_FORMAT" = "CSV" ]; then
    echo "Ignoring --csv, --log is not enabled. See --help for manual."
  fi
fi

# Progress bars
if [ "$PRINT_PROGRESS" = "YES" ]; then
  if [ $(command -v bc) ]; then
    PRINT_PROGRESS="YES"
    PROGRESS_0_5='[#....................]'
    PROGRESS_5_10='[##...................]'
    PROGRESS_10_15='[###..................]'
    PROGRESS_15_20='[####.................]'
    PROGRESS_20_25='[#####................]'
    PROGRESS_25_30='[######...............]'
    PROGRESS_30_35='[#######..............]'
    PROGRESS_35_40='[########.............]'
    PROGRESS_40_45='[##########...........]'
    PROGRESS_45_50='[###########..........]'
    PROGRESS_50_55='[############.........]'
    PROGRESS_55_60='[#############........]'
    PROGRESS_60_65='[##############.......]'
    PROGRESS_65_70='[###############......]'
    PROGRESS_70_75='[################.....]'
    PROGRESS_75_80='[#################....]'
    PROGRESS_80_85='[##################...]'
    PROGRESS_85_90='[###################..]'
    PROGRESS_90_95='[####################.]'
    PROGRESS_95_100='[#####################]'
    TOTAL=$CREATE
  else
    PRINT_PROGRESS="NO"
  fi
else
  PRINT_PROGRESS="NO"
fi

# Verbose output
if [ "$VERBOSE" = "YES" ]; then
  echo "-------------------------------------------------------------"
  echo "OUTPUT FOLDER    = ${OUTPUT_FOLDER}"
  echo "SIZE (BYTES)     = ${FILE_SIZE}"
  echo "CREATE # FILES   = ${CREATE}"
  echo "LOG FILE         = ${LOG_FILE}"
  echo "LOG FORMAT       = ${LOG_FORMAT}"
  echo "HASH_ALG         = ${HASH_ALG}"
  echo "PRINT_PROGRESS   = ${PRINT_PROGRESS}"
  echo "VERBOSE          = ${VERBOSE}"
  echo "-------------------------------------------------------------"
  TOTAL=$CREATE
fi

############################ FILE CREATION ####################################

# Creates test files
while [ $CREATE -gt 0 ]; do
  # If uuidgen is not available, names files based on date and random
  if [ -z $(command -v uuidgen) ]; then
    DATE=$(date +%s)
    FILE_NAME="$(($DATE + $RANDOM))$RANDOM.dummy"
  else
    FILE_NAME="$(uuidgen).dummy"
  fi

  # Creates file
  dd if=/dev/urandom of=$OUTPUT_FOLDER/$FILE_NAME bs=1024 count=$FILE_SIZE status=none

  # Logs file creation
  if [ -n "$LOG_FILE" ]; then
    # Calculates hash
    if [ -n "$HASH_ALG" ]; then
      if [ "$HASH_ALG" = "md5" ]; then
        hash=$(md5sum ${OUTPUT_FOLDER}/${FILE_NAME} | awk '{ print $1 }')
      elif [ "$HASH_ALG" = "sha256" ]; then
        hash=$(sha256sum ${OUTPUT_FOLDER}/${FILE_NAME} | awk '{ print $1 }')
      fi
    fi
    # Saves log to file
    if [ "$LOG_FORMAT" = "TXT" ]; then
      date +"%H:%M:%S %D - CREATE - $FILE_SIZE KB - $OUTPUT_FOLDER/$FILE_NAME" >> $LOG_FILE
    elif [ "$LOG_FORMAT" = "CSV" ]; then
      date +'"%H:%M:%S %D";'$FILE_SIZE' KB;"'$OUTPUT_FOLDER'/'$FILE_NAME'";'${hash}'' >> $LOG_FILE
    fi
  fi

  CREATE=$(($CREATE-1))

  # Print verbose output
  if [ "$VERBOSE" = "YES" ]; then
    CREATED=$(($TOTAL - $CREATE))
    echo "($CREATED/$TOTAL) - $OUTPUT_FOLDER/$FILE_NAME"
  fi

  # Print progress bar
  if [ "$PRINT_PROGRESS" = "YES" ]; then
    CREATED=$(($TOTAL - $CREATE))
    PERCENTAGE=$(echo "scale = 2; (( $TOTAL - $CREATE ) / $TOTAL) * 100" | bc)
    PERCENTAGE=${PERCENTAGE%%.*}
    if [ $PERCENTAGE -lt 5 ]; then
      printf "$PROGRESS_0_5($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 10 ]; then
      printf "$PROGRESS_5_10($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 15 ]; then
      printf "$PROGRESS_10_15($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 20 ]; then
      printf "$PROGRESS_15_20($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 25 ]; then
      printf "$PROGRESS_20_25($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 30 ]; then
      printf "$PROGRESS_25_30($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 35 ]; then
      printf "$PROGRESS_30_35($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 40 ]; then
      printf "$PROGRESS_35_40($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 45 ]; then
      printf "$PROGRESS_40_45($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 50 ]; then
      printf "$PROGRESS_45_50($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 55 ]; then
      printf "$PROGRESS_50_55($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 60 ]; then
      printf "$PROGRESS_55_60($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 65 ]; then
      printf "$PROGRESS_60_65($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 70 ]; then
      printf "$PROGRESS_65_70($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 75 ]; then
      printf "$PROGRESS_70_75($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 80 ]; then
      printf "$PROGRESS_75_80($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 85 ]; then
      printf "$PROGRESS_80_85($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 90 ]; then
      printf "$PROGRESS_85_90($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    elif [ $PERCENTAGE -lt 95 ]; then
      printf "$PROGRESS_90_95($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    else
      printf "$PROGRESS_95_100($PERCENTAGE%%)($CREATED/$TOTAL)\r"
    fi
  fi
done

printf "\nDone\n"
