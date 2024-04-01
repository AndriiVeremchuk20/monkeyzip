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
figlet -c "Monkeyzip"
echo -e "${NC}"

# ----------------  End of welcome text ----------------

# ---------------- Base attr args ----------------------

use_dictionary=false
use_brute_force=false

archive_path=""
dictionary_path=""

MMAX_PASSWORD_LENGTH=6
password=""

#------------------------------------------------------- 

# ----------------------- FUNCTIONS --------------------

#dispaly help menu
display_help () {
   echo "Monkey Zip - a utility for cracking password-protected ZIP archives using a dictionary."
   echo -e "\n"
   echo "Usege"
   echo -e "\t $0 [options] <path>"
   echo
   echo -e "Options"
   echo -e "\t-a <path> Path to target archive"
   echo -e "\t-d <path> Path to dictionary."
   echo -e "\t-h print help and exit"
   echo
}

bruteforce_password() {
    local chars="$1"
    local max_length="$2"

    # Loop through each character in chars and start brute force from there
    for ((i=0; i<${#chars}; i++)); do
        start_char="${chars:$i:1}"
        echo "Starting from '$start_char':"
        
        # Loop through each length up to max_length
        for ((length=1; length<=max_length; length++)); do
            # Loop through each prefix of the current length
            for ((j=0; j<${#chars}; j++)); do
                prefix="${chars:$j:1}"
                if [ "$length" -eq 1 ] || [ "$prefix" != "0" ]; then
                    bruteforce_recursive "$prefix" "$chars" "$length"
                fi
            done
        done
    done
}

# Function to recursively generate passwords
bruteforce_recursive() {
    local prefix="$1"
    local chars="$2"
    local max_length="$3"

    # If prefix length equals desired length, print password
    if [ ${#prefix} -eq "$max_length" ]; then
        echo -ne "Trying password: $prefix \r"
        if attempt_extraction "$prefix" "$archive_path"; then
            echo "Success! Password is: $prefix"
            exit 0
        fi
    else
        for ((i=0; i<${#chars}; i++)); do
            next_char="${chars:$i:1}"
            bruteforce_recursive "$prefix$next_char" "$chars" "$max_length"
        done
    fi
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

while getopts ":ha:d:b:" opt; do
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
		b )
			use_brute_force=true
			MAX_PASSWORD_LENGTH="$OPTARG"
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
    
	echo -e "Attempting to extract archive: $archive_path using dictionary: $dictionary_path\n"

    # Get the total number of passwords in the dictionary
    totalPasswords=$(wc -l <"$dictionary_path")
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

    done <"$dictionary_path"

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

	echo "Attempting to extract archive: $archive_path using brute force"
	
	echo "Max password length $MAX_PASSWORD_LENGTH"

	bruteforce_password "$CHARS" "$MAX_PASSWORD_LENGTH"
fi

# ---------------- end brute force block -------------------

echo "Brute force mode complete"
exit 0
