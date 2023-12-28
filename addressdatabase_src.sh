#!/bin/bash
# The file names
#TODO Define all file names used for this project
# The file paths
#TODO Define all file paths here
# The globals
RED='\033[0;31m'
NC='\033[0m'
#TODO Define all global variables required
# Time out periods
#TODO Define all timeout values here
timeout=10

echo -e "\e[1;42m Bourouba Mohamed El Khalil M1-CS || Shell Database Project \e[0m"

function log()
{
   #TODO Write activities to log files along with timestamp, pass argument as a string
   echo -e "$stdres" | tee -a database.log
}

function menu_header() {
    while true
    do
        echo "1. Add Entry"
        echo "2. Search / Edit Entry"
        echo -e "${RED}X${NC}. Exit"

        if read -t "$timeout" -p "Please choose your option: " choice; then
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
            echo -n
            echo -e "\e[1;31m Timeout: No input received for 10 seconds. Exiting... \e[0m"
            exit 1
        fi
    done
}

function field_menu()
{
	# TODO to print a selected user information 
	# Name, Email, Tel no, Mob num, Address, Message
	awk '{print "["NR"]", $0}' <<< "$data"
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

    while true; do
        echo "1: Name      : $name"
        echo "2: Email     : $email"
        echo "3: Tel no    : $tel"
        echo "4: Mob no    : $mob"
        echo "5: Place     : $place"
        echo "6: Message   : $msg"
        echo "7: Save"
        echo -e "${RED}X${NC}: Exit"

        read -p "Please choose the field to be edited: " choice

        case $choice in
            1) read -p "Please enter the new name: " name ;;
            2) read -p "Please enter the new email: " email ;;
            3) read -p "Please enter the new telephone number: " tel ;;
            4) read -p "Please enter the new mobile number: " mob ;;
            5) read -p "Please enter the new place: " place ;;
            6) read -p "Please enter the new message: " msg ;;
            7)
				timestamp=$(awk -F',' -v line="$line_number" 'NR == line {print $7}' database.csv)
                new_data="$name,$email,$tel,$mob,$place,$msg,$timestamp"
                sed -i "${line_number}s/.*/$new_data/" database.csv
                echo -e "\e[1;32m Data updated! Record $line_number updated to $new_data at $(date) \e[0m"
                stdres="Data updated! Record $line_number updated to $new_data at $(date)"
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
    done
}

function search_operation() {
    local column_number="$1"
    local pattern="$2"

    # Search for the pattern in the specified column
    search_result=$(awk -F',' -v col="$column_number" -v pat="$pattern" '$col == pat {print NR}' database.csv)

    if [ -n "$search_result" ]; then
        if [ $(echo "$search_result" | wc -l) -eq 1 ]; then
            line_number=$(echo "$search_result")
        else
            echo "Multiple records found. Displaying details:"
            awk -F',' -v col="$column_number" -v pat="$pattern" 'BEGIN {OFS=" : "} {if ($col == pat) print $0}' database.csv | cat -n
            read -p "Select the user number to be displayed: " record_number

            # Validate the user input against the available options
            valid_input=$(awk -F',' -v col="$column_number" -v pat="$pattern" '{if ($col == pat) print NR}' database.csv | wc -l)
            if [[ "$record_number" -le "$valid_input" ]]; then
                line_number=$(awk -F',' -v col="$column_number" -v pat="$pattern" '{if ($col == pat) print NR}' database.csv | sed -n "${record_number}p")
            else
                echo -e "\e[1;31m Invalid selection! Please choose a valid number. \e[0m"
                return 1
            fi
        fi

        # Fetch the entire record based on the line number
        data=$(awk -F',' -v line="$line_number" 'NR == line {print}' database.csv)
        selected_user=$(echo "$data")
        IFS=',' read -r name email tel mob place msg <<< "$selected_user"
        clear
        edit_operation "$line_number" "$name" "$email" "$tel" "$mob" "$place" "$msg"
    else
        echo -e "\e[1;31m No record found with the specified pattern in column $column_number \e[0m"
    fi
}

function search_and_edit() {
    echo "My database Project"
    echo "Please choose the below options:"
    echo -n

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

        read -p "Please choose the field to be searched: " choice

        case $choice in
            1) read -p "Please enter the name: " name
                search_operation 1 "$name"
                ;;
            2) read -p "Please enter the email: " email
                search_operation 2 "$email"
                ;;
            3) read -p "Please enter the telephone number: " tel
                search_operation 3 "$tel"
                ;;
            4) read -p "Please enter the mobile number: " mob
                search_operation 4 "$mob"
                ;;
            5) read -p "Please enter the place: " place
                search_operation 5 "$place"
                ;;
            6) read -p "Please enter the message: " msg
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
    done
}


function database_entry()
{
	# TODO user inputs will be written to database file
	# 1. If some fields are missing add consicutive ','. Eg: user,,,,,
	echo "$name,$email,+213-$tel,+213-$mob,$place,$msg,$(date)" >> database.csv
    echo -e "\e[1;32m Adding the user $name with success, $(date) \e[0m"
	stdres="Adding the user $name with success, $(date)"
	log
}

function validate_entry()
{
	# TODO Inputs entered by user must be verified and validated as per fields
	# 1. Names should have only alphabets
	if [[ -z "$name" ]]
	then
		name=""
    elif [[ ! "$name" =~ ^[a-zA-Z]+$ ]]
	then
		echo -e "\e[1;31m Reset your name! \e[0m"
		return 1
	fi

	# 2. Emails must have a @ symbols and ending with .<domain> Eg: user@mail.com
	if [[ -z "$email" ]]
	then
		email=""
	elif ! [[ "$email" =~ .*@.*\..* ]]; then
        echo -e "\e[1;31m Invalid email format! Emails must have '@' and end with '.<domain>'. \e[0m"
        return 1
	fi

	# 3. Mobile/Tel numbers must have 10 digits.
	if [[ -z "$mob" ]]
	then
		mob=""
	fi

	if [[ -z "$tel" ]]
	then
		tel=""
	fi

	if [[ "$mob" != "" && ! "$mob" =~ ^[0-9]{9}$ ]] ||
       [[ "$tel" != "" && ! "$tel" =~ ^[0-9]{9}$ ]]; then
        echo -e "\e[1;31m Invalid telephone or mobile number! Must have 9 digits. \e[0m"
        return 1
    fi

	# 4. Place must have only alphabets
	if [[ -z "$place" ]]
	then
		place=""
	elif ! [[ "$place" =~ ^[a-zA-Z]+$ ]]; then
        echo -e "\e[1;31m Invalid place! Place must have only alphabets. \e[0m"
        return 1
	fi

	if [[ -z "$msg" ]]
	then
		msg=""
	fi

    return 0
}

function add_entry() {
	echo "My database Project"
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

        read -p "Please choose the field to be added: " choice

        case $choice in
            1) read -p "Please enter the name: " name 
			   ;;
            2) read -p "Please enter the email: " email 
			   ;;
            3) read -p "Please enter the telephone number: " tel 
			   ;;
            4) read -p "Please enter the mobile number: " mob 
			   ;;
            5) read -p "Please enter the place: " place 
			   ;;
            6) read -p "Please enter the message: " msg 
			   ;;
			7)  if validate_entry; then
					echo -e "\e[1;32m Validation successful! Adding entry to the database. \e[0m"
					database_entry
				else
                    echo -e "\e[1;31m Validation failed! Please check your inputs. Resetting data... \e[0m"
					name=""
					email=""
					tel=""
					mob=""
					place=""
					msg=""
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
    done
}

# TODO Your main scropt starts here 
# 1. Creating a database directory if it doesn't exist
# 2. Creating a database.csv file if it doesn't exist
# Just loop till user exits

while [ 1 ]
do
	if [ ! -d ECEP/LinuxSystems/Projects ]
	then
		mkdir -p "$HOME/ECEP/LinuxSystems/Projects"
		cd "$HOME/ECEP/LinuxSystems/Projects" || exit 1
	fi

	
	while true
    do
        if [ ! -f database.csv ]
        then
            touch database.csv
			touch database.log
            echo "CSV file database.csv created."
			break
		else
			break
        fi
		if [ ! -f database.log ]
        then
			touch database.log
            echo "Log file database.log created."
        	break
		else
			break
        fi
    done
	
	menu_header

done
