#!/bin/bash
# The file names
#TODO Define all file names used for this project
DATABASE_CSV="database.csv"
DATABASE_LOG="database.log"

# The file paths
#TODO Define all file paths here
DATABASE_DIR="./ECEP/LinuxSystems/Projects"

# The globals
#TODO Define all global variables required
RED='\033[0;31m'
NC='\033[0m'

# Time out periods
#TODO Define all timeout values here
timeout=10

echo -e "\e[1;42m Bourouba Mohamed El Khalil M1-CS || Shell Database Project \e[0m"

function read_input() {
    #Setting a timeout each time the script wants a new insertion
    local message="$1"
    local variable="$2"
    read -t "$timeout" -p "$message" "$variable"
}

function print_header() {
    clear
    echo -e "\e[1m================================================="
    echo -e "||             Welcome to My Database           ||"
    echo -e "=================================================\e[0m"
}

function log()
{
   #TODO Write activities to log files along with timestamp, pass argument as a string
   echo "$stdres" >> database.log
}

function menu_header() {
    while true
    do
        print_header
        echo "1. Add Entry"
        echo "2. Search / Edit Entry"
        echo -e "${RED}X${NC}. Exit"
        #Giving the user the choice to navigate between the scenes
        if read_input "Please choose your option: " choice; then
            case $choice in
                1)
					clear
                    add_entry
                    ;;
                2)
					clear
                    search_and_edit
                    ;;
                [Xx])
                    echo "Exiting..."
                    exit 0
                    ;;
                *)
                    echo "Invalid choice!"
                    ;;
            esac
        else
            echo -e "\e[1;31m Timeout: No input received for 10 seconds. Exiting... \e[0m"
            exit 1
        fi
    done
}

function field_menu()
{
	# TODO to print a selected user information 
	# Name, Email, Tel no, Mob num, Address, Message
	echo -e "\e[1;34m Selected User Information: \e[0m"
    echo "==============================="
    echo -e "\e[1m1: Name         : \e[0m$name"
    echo -e "\e[1m2: Email        : \e[0m$email"
    echo -e "\e[1m3: Tel no       : \e[0m$tel"
    echo -e "\e[1m4: Mob no       : \e[0m$mob"
    echo -e "\e[1m5: Place        : \e[0m$place"
    echo -e "\e[1m6: Message      : \e[0m$msg"
    echo -e "\e[1m7: Created_at   : \e[0m$timestamp"
}

function edit_operation()
{
	# TODO Provide an option to change fields of an entry
	# 1. Ask user about the field to edit
	# 2. As per user selection, prompt a message to enter respected value
	# 3. Verify the user entry to field for matching. Eg mob number only 10 digits to enter
    # 4. Prompt error in case any mismatch of entered data and fields
    local line_number="$1" 
	echo "My database Project"
	echo "Please choose the below options:"
	echo -n

	echo -e "Search / ${RED}Edit${NC} by:"

    name="$2"
    email="$3"
    tel="$4"
    mob="$5"
    place="$6"
    msg="$7"
    timestamp="$8"

    while true; do
    
        field_menu

        echo "8: Save"
        echo -e "${RED}X${NC}: Exit"

        if read_input "Please choose the field to be edited: " choice
        then
            case $choice in
                1) read_input "Please enter the new name: " name ;;
                2) read_input "Please enter the new email: " email ;;
                3) read_input "Please enter the new telephone number: " tel ;;
                4) read_input "Please enter the new mobile number: " mob ;;
                5) read_input "Please enter the new place: " place ;;
                6) read_input "Please enter the new message: " msg ;;
                7) echo -e "\e[1;31m You can't change the timestamp! \e[0m"
                    ;;
                8)
                    #The old pre-modified data
                    old_data="$2,$3,$4,$5,$6,$7,$8"
                    #The post-modified data
                    new_data="$name|$email|$tel|$mob|$place|$msg|$timestamp"
                    #Replace the old data with the new one according to the corresponding line number from the table
                    sed -i "${line_number}s/.*/$new_data/" database.csv
                    echo -e "\e[1;32m Data updated! Record $line_number: [$old_data] updated to [$new_data] at $(date) \e[0m"
                    stdres="Data updated! Record $line_number: [$old_data] updated to [$new_data] at $(date)"
                    log
                    ;;
                [Xx])
                    clear
                    menu_header
                    exit 0
                    ;;
                *)
                    echo -e "\e[1;31m Invalid choice! \e[0m"
                    ;;
            esac
        else
            echo -e "\e[1;31m Timeout: No input received for 10 seconds. Exiting... \e[0m"
            exit 1
        fi
    done
}

function search_operation() {
    local column_number="$1"
    local pattern="$2"

    # Search for the pattern in the specified column
    search_result=$(awk -F'|' -v col="$column_number" -v pat="$pattern" '$col == pat {print NR}' database.csv)

    if [ -n "$search_result" ]; then
        if [ $(echo "$search_result" | wc -l) -eq 1 ]; then
            line_number=$(echo "$search_result")
        else
            echo "Multiple records found. Displaying details:"
            awk -F'|' -v col="$column_number" -v pat="$pattern" 'BEGIN {OFS=" : "} {if ($col == pat) print $0}' database.csv | cat -n
            if read_input "Select the user number to be displayed: " record_number
            then
                # Validate the user input against the available options
                valid_input=$(awk -F'|' -v col="$column_number" -v pat="$pattern" '{if ($col == pat) print NR}' database.csv | wc -l)
                if [[ "$record_number" -le "$valid_input" ]]; then
                    line_number=$(awk -F'|' -v col="$column_number" -v pat="$pattern" '{if ($col == pat) print NR}' database.csv | sed -n "${record_number}p")
                else
                    echo -e "\e[1;31m Invalid selection! Please choose a valid number. \e[0m"
                    return 1
                fi
            else
                echo -e "\e[1;31m Timeout: No input received for 10 seconds. Exiting... \e[0m"
                exit 1
            fi
        fi

        # Fetch the entire record based on the line number
        data=$(awk -F'|' -v line="$line_number" 'NR == line {print}' database.csv)
        selected_user=$(echo "$data")
        IFS='|' read -r name email tel mob place msg timestamp <<< "$selected_user"
        clear
        edit_operation "$line_number" "$name" "$email" "$tel" "$mob" "$place" "$msg" "$timestamp"
    else
        echo -e "\e[1;31m No record found with the specified pattern in column $column_number \e[0m"
    fi
}

function search_and_edit() {
    clear
    echo -e "\e[1;44m*******************************\e[0m"
    echo -e "\e[1;44m*    Search / Edit Entry      *\e[0m"
    echo -e "\e[1;44m*******************************\e[0m"
    echo ""
    echo "Please choose the below options:"

    # Initialize variables for fields
    name=""
    email=""
    tel=""
    mob=""
    place=""
    msg=""

    while true; do
        echo "1: Name      : $name"
        echo "2: Email     : $email"
        echo "3: Tel no    : $tel"
        echo "4: Mob no    : $mob"
        echo "5: Place     : $place"
        echo "6: Message   : $msg"
        echo "7: All"
        echo -e "${RED}X${NC}: Exit"

        if read_input "Please choose the field to be searched: " choice
        then
            case $choice in
                1) read_input "Please enter the name: " name
                    search_operation 1 "$name"
                    ;;
                2) read_input "Please enter the email: " email
                    search_operation 2 "$email"
                    ;;
                3) read_input "Please enter the telephone number: " tel
                    search_operation 3 "$tel"
                    ;;
                4) read_input "Please enter the mobile number: " mob
                    search_operation 4 "$mob"
                    ;;
                5) read_input "Please enter the place: " place
                    search_operation 5 "$place"
                    ;;
                6) read_input "Please enter the message: " msg
                    search_operation 6 "$msg"
                    ;;
                7)
                    echo "All"
                    # Perform the operation for all fields
                    if search_operation; then
                        edit_operation "$name" "$email" "$tel" "$mob" "$place" "$msg"
                    else
                        echo -e "\e[1;31m There is no such record with this name \e[0m"
                    fi
                    ;;
                [Xx])
                    clear
                    menu_header
                    exit 0
                    ;;
                *)
                    echo -e "\e[1;31m Invalid choice! \e[0m"
                    ;;
            esac
        else
            echo -e "\e[1;31m Timeout: No input received for 10 seconds. Exiting... \e[0m"
            exit 1
        fi
    done
}


function database_entry()
{
	# TODO user inputs will be written to database file
	# 1. If some fields are missing add consicutive ','. Eg: user,,,,,
    timestamp=$(date)
	echo "$name|$email|$tel|+213-$mob|$place|$msg|$timestamp" >> database.csv
    echo -e "\e[1;32m Adding the user $name with success, $(date) \e[0m"
	stdres="Adding the user $name with success, $(date)"
	log
}

function validate_entry() {
    # TODO Inputs entered by user must be verified and validated as per fields
    # 1. Names should have only alphabets
    if [[ -z "$name" ]]; then
        name=""
    elif [[ ! "$name" =~ ^[a-zA-Z\ ]+$ ]]; then
        echo -e "\e[1;31m Invalid name! It must contain only alphabets and spaces. \e[0m"
        return 1
    fi

    # 2. Emails must have a @ symbols and ending with .<domain>
    if [[ -z "$email" ]]; then
        email=""
    elif ! [[ "$email" =~ .*@.*\..* ]]; then
        echo -e "\e[1;31m Invalid email format! Emails must have '@' and end with '.<domain>'. \e[0m"
        return 1
    fi

    # 3. Mobile numbers must have 9 digits / Telephone one must have 10 digits.
    if [[ -z "$tel" ]]; then
        tel=""
    elif [[ "$tel" != "" && ! "$tel" =~ ^[0-9]{10}$ ]]; then
        echo -e "\e[1;31m Invalid telephone number! Must have exactly 10 digits. \e[0m"
        return 1
    fi

    if [[ -z "$mob" ]]; then
        mob=""
    elif [[ "$mob" != "" && ! "$mob" =~ ^[0-9]{9}$ ]]; then
        echo -e "\e[1;31m Invalid mobile number! Must have exactly 9 digits. \e[0m"
        return 1
    fi

    # 4. Place must have only alphabets and spaces
    if [[ -z "$place" ]]; then
        place=""
    elif ! [[ "$place" =~ ^[a-zA-Z\ ]+$ ]]; then
        echo -e "\e[1;31m Invalid place! Place must have only alphabets. \e[0m"
        return 1
    fi

    # 5. Any character allowed
    if [[ -z "$msg" ]]; then
        msg=""
    fi

    return 0
}

function add_entry() {
	clear
    echo -e "\e[1;44m*****************************\e[0m"
    echo -e "\e[1;44m*       Add New Entry       *\e[0m"
    echo -e "\e[1;44m*****************************\e[0m"
    echo ""
    
	echo "Please choose the below options:"
	echo -n
    echo "Add New Entry Screen:"

    name=""
    email=""
    tel=""
    mob=""
    place=""
    msg=""

    while true; do
        echo "1: Name      : $name"
        echo "2: Email     : $email"
        echo "3: Tel no    : $tel"
        echo "4: Mob no    : $mob"
        echo "5: Place     : $place"
        echo "6: Message   : $msg"
		echo "7: Save"
        echo -e "${RED}X${NC}: Exit"

        if read_input "Please choose your option: " choice; then
            case $choice in
                1) read_input "Please enter the name: " name 
                    if validate_entry; then
                        clear
                        continue
                    fi
                ;;
                2) read_input "Please enter the email: " email
                    if validate_entry; then
                        clear
                        continue
                    fi
                ;;
                3) read_input "Please enter the telephone number (ex: 0563567899): " tel
                    if validate_entry; then
                        clear
                        continue
                    fi
                ;;
                4) read_input "Please enter the mobile number (ex: 563567899): " mob 
                    if validate_entry; then
                        clear
                        continue
                    fi
                ;;
                5) read_input "Please enter the place: " place 
                    if validate_entry; then
                        clear
                        continue
                    fi
                ;;
                6) read_input "Please enter the message: " msg 
                    if validate_entry; then
                        clear
                        continue
                    fi
                ;;
                7)  
                    clear
                    echo -e "\e[1;32m Validation successful! Adding entry to the database. \e[0m"
                    database_entry
                ;;
                [Xx])
                    clear
                    menu_header
                    exit 0
                    ;;
                *)
                    echo -e "\e[1;31m Invalid choice! \e[0m"
                    ;;
            esac
        else
            echo -e "\e[1;31m Timeout: No input received for 10 seconds. Exiting... \e[0m"
            exit 1
        fi
    done
}

# TODO Your main scropt starts here 
# 1. Creating a database directory if it doesn't exist
# 2. Creating a database.csv file if it doesn't exist
# Just loop till user exits

while [ 1 ]
do
    #Checks for the existence of the directory
	if [ ! -d $DATABASE_DIR ]
	then
		mkdir -p "$DATABASE_DIR"
	fi

    cd "$DATABASE_DIR"
	
	while true
    do
        #Checks for the existence of the csv file of the database
        if [ ! -f $DATABASE_CSV ]
        then
            touch "$DATABASE_CSV"
            echo "CSV file database.csv created."
        fi

        #Checks for the existence of the csv file of the database
		if [ ! -f $DATABASE_LOG ]
        then
			touch "$DATABASE_LOG"
            echo "Log file database.log created."
        fi

        break
    done
	
	menu_header

done
