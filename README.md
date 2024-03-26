# MonkeyZip

Simple utility for cracking password-protected ZIP archives using a dictionary.

## Before start

Before using this script, you need to create or download a dictionary containing possible or popular passwords. You can use well-known lists like [Rockyou](https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt).

## Run from Folder
1. Clone this repository: `git clone https://github.com/AndriiVeremchuk20/monkeyzip.git`

2. Change directory to monkeyzip: `cd monkeyzip` 

3. Start the help command to get details: `bash ./monkeyzip.sh --help`


## How to Install

1. The first two steps from the section 'How to use from Folder'.

2. Make the file executable: `chmod +x ./monkeyzip.sh`

3. Move the script to a directory included in your PATH: `sudo mv myscript.sh /usr/local/bin/monkeyzip`

4. Now, you can run the script from any directory without specifying the .sh extension: `monkeyzip`



