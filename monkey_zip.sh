#!/bin/bash

# Define ANSI color codes
RED='\033[0;31m'    # Red color
GREEN='\033[0;32m'  # Green color
YELLOW='\033[0;33m' # Yellow color
ORANGE='\033[0;33m'  # Orange color
NC='\033[0m'        # No color

# Display Help
display_help () {
   echo "Monkey Zip - a utility for cracking password-protected ZIP archives using a dictionary."
   echo -e "\n"
   echo "Syntax: scriptTemplate monkey_zip < PATH_TO_ARCHIVE > < PATH_TO_DICTIONARY >"
   echo -e "\n\toptions:"
   echo -e "\t-h --help  Print this help"
   echo
}

echo -e "${ORANGE}"
figlet -c "Monkey zip"
echo -e "${NC}"

# Check if first arg "-h or --help"
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	display_help
	exit 0
fi

# Check number of args
if [ "$#" -ne 2 ]; then
	echo -e "${YELLOW}Warning Usage $0 <path to archive> <path to dictionary> Use '-h' to more information.${NC}"
	exit 1
fi

# Extract comand line args
archivePath="$1"
dictionaryPath="$2"

# Check if archive and dictionary exist
if [ ! -f "$archivePath" ]; then
    echo -e "${RED}Error: Archive file not found${NC}"
    exit 1
fi

# Check if archive and dictionary exist
if [ ! -f "$dictionaryPath" ]; then
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
    if unzip -P "$password" -t "$archivePath" &>/dev/null; then
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
