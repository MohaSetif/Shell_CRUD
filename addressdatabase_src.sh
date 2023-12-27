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

function log()
{
   #TODO Write activities to log files along with timestamp, pass argument as a string
   echo "$stdres" | tee -a database.log
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
            echo "Timeout: No input received for 10 seconds. Exiting..."
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
	echo "My database Project"
	echo "Please choose the below options:"
	echo -n

	echo -e "Search / ${RED}Edit${NC} by:"

    name="$1"
    email="$2"
    tel="$3"
    mob="$4"
    place="$5"
    msg="$6"

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
				old_data=$(grep "^$1," database.csv)
				new_data="$name,$email,$tel,$mob,$place,$msg"
                sed -i "s|$old_data|$new_data|g" database.csv
				stdres="Data updated! $old_data got updated to $new_data at $(date)"
				log
				;;
            [Xx])
                clear
                menu_header
                exit 0
                ;;
            *)
                echo "Invalid choice!"
                ;;
        esac
    done
}

function search_operation()
{
	# TODO Ask user for a value to search
	# 1. Value can be from any field of an entry.
	# 2. One by one iterate through each line of database file and search for the entry
	# 3. If available display all fiels for that entry
	# 4. Prompt error incase not available
	if grep $1 database.csv
	then
		return 0
	else
		return 1
	fi
}

function search_and_edit()
{
	# TODO UI for editing and searching 
	# 1. Show realtime changes while editing
	# 2. Call above functions respectively

	echo "My database Project"
	echo "Please choose the below options:"
	echo -n

	echo -e "${RED}Search${NC} / Edit by:"
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
				search_result=$(grep -c "$name" database.csv)

                if [ "$search_result" -eq 1 ]; then
                    data=$(grep "$name" database.csv)
                    selected_user=$(echo "$data")
                    IFS=',' read -r name email tel mob place msg <<< "$selected_user"
                    clear
                    edit_operation "$name" "$email" "$tel" "$mob" "$place" "$msg"
                elif [ "$search_result" -gt 1 ]; then
                    data=$(grep "$name" database.csv)
                    field_menu
                    read -p "Select the user number to be displayed: " record_number
                    selected_user=$(echo "$data" | sed -n "${record_number}p")
                    IFS=',' read -r name email tel mob place msg <<< "$selected_user"
                    clear
                    edit_operation "$name" "$email" "$tel" "$mob" "$place" "$msg"
                else
                    echo "There is no such record with this name"
                fi
			   ;;
            2) read -p "Please enter the email: " email 
				search_result=$(grep -c "$email" database.csv)

                if [ "$search_result" -eq 1 ]; then
                    data=$(grep "$email" database.csv)
                    selected_user=$(echo "$data")
                    IFS=',' read -r name email tel mob place msg <<< "$selected_user"
                    clear
                    edit_operation "$name" "$email" "$tel" "$mob" "$place" "$msg"
                elif [ "$search_result" -gt 1 ]; then
                    data=$(grep "$email" database.csv)
                    field_menu
                    read -p "Select the user number to be displayed: " record_number
                    selected_user=$(echo "$data" | sed -n "${record_number}p")
                    IFS=',' read -r name email tel mob place msg <<< "$selected_user"
                    clear
                    edit_operation "$name" "$email" "$tel" "$mob" "$place" "$msg"
                else
                    echo "There is no such record with this name"
                fi
			   ;;
            3) read -p "Please enter the telephone number: " tel 
				search_result=$(grep -c "$tel" database.csv)

                if [ "$search_result" -eq 1 ]; then
                    data=$(grep "$tel" database.csv)
                    selected_user=$(echo "$data")
                    IFS=',' read -r name email tel mob place msg <<< "$selected_user"
                    clear
                    edit_operation "$name" "$email" "$tel" "$mob" "$place" "$msg"
                elif [ "$search_result" -gt 1 ]; then
                    data=$(grep "$tel" database.csv)
                    field_menu
                    read -p "Select the user number to be displayed: " record_number
                    selected_user=$(echo "$data" | sed -n "${record_number}p")
                    IFS=',' read -r name email tel mob place msg <<< "$selected_user"
                    clear
                    edit_operation "$name" "$email" "$tel" "$mob" "$place" "$msg"
                else
                    echo "There is no such record with this name"
                fi
				;;
            4) read -p "Please enter the mobile number: " mob 
				search_result=$(grep -c "$mob" database.csv)
                if [ "$search_result" -eq 1 ]; then
                    data=$(grep "$mob" database.csv)
                    selected_user=$(echo "$data")
                    IFS=',' read -r name email tel mob place msg <<< "$selected_user"
                    clear
                    edit_operation "$name" "$email" "$tel" "$mob" "$place" "$msg"
                elif [ "$search_result" -gt 1 ]; then
                    data=$(grep "$mob" database.csv)
                    field_menu
                    read -p "Select the user number to be displayed: " record_number
                    selected_user=$(echo "$data" | sed -n "${record_number}p")
                    IFS=',' read -r name email tel mob place msg <<< "$selected_user"
                    clear
                    edit_operation "$name" "$email" "$tel" "$mob" "$place" "$msg"
                else
                    echo "There is no such record with this name"
                fi
			   ;;
            5) read -p "Please enter the place: " place 
				search_result=$(grep -c "$place" database.csv)

                if [ "$search_result" -eq 1 ]; then
                    data=$(grep "$place" database.csv)
                    selected_user=$(echo "$data")
                    IFS=',' read -r name email tel mob place msg <<< "$selected_user"
                    clear
                    edit_operation "$name" "$email" "$tel" "$mob" "$place" "$msg"
                elif [ "$search_result" -gt 1 ]; then
                    data=$(grep "$place" database.csv)
                    field_menu
                    read -p "Select the user number to be displayed: " record_number
                    selected_user=$(echo "$data" | sed -n "${record_number}p")
                    IFS=',' read -r name email tel mob place msg <<< "$selected_user"
                    clear
                    edit_operation "$name" "$email" "$tel" "$mob" "$place" "$msg"
                else
                    echo "There is no such record with this name"
                fi
			   ;;
            6) read -p "Please enter the message: " msg 
				search_result=$(grep -c "$msg" database.csv)
                if [ "$search_result" -eq 1 ]; then
                    data=$(grep "$msg" database.csv)
                    selected_user=$(echo "$data")
                    IFS=',' read -r name email tel mob place msg <<< "$selected_user"
                    clear
                    edit_operation "$name" "$email" "$tel" "$mob" "$place" "$msg"
                elif [ "$search_result" -gt 1 ]; then
                    data=$(grep "$msg" database.csv)
                    field_menu
                    read -p "Select the user number to be displayed: " record_number
                    selected_user=$(echo "$data" | sed -n "${record_number}p")
                    IFS=',' read -r name email tel mob place msg <<< "$selected_user"
                    clear
                    edit_operation "$name" "$email" "$tel" "$mob" "$place" "$msg"
                else
                    echo "There is no such record with this name"
                fi
			   ;;
			7)  echo "All"
				if search_operation; then
					edit_operation "$name" "$email" "$tel" "$mob" "$place" "$msg"
				else
					echo "There is no such record with these information"
				fi
			   ;;
            [Xx])
                clear
				menu_header
                exit 0
                ;;
            *)
                echo "Invalid choice!"
                ;;
        esac
    done
}

function database_entry()
{
	# TODO user inputs will be written to database file
	# 1. If some fields are missing add consicutive ','. Eg: user,,,,,
	echo "$name,$email,+213-$tel,+213-$mob,$place,$msg,$(date)" >> database.csv
	stdres="Adding the user $name with success, $(date)"
	log
}

function validate_entry()
{
	# TODO Inputs entered by user must be verified and validated as per fields
	# 1. Names should have only alphabets
	if [[ ! "$name" =~ ^[a-zA-Z]+$ || -z "$name" ]]
	then
		echo "Reset your name"
		return 1
	fi

	# 2. Emails must have a @ symbols and ending with .<domain> Eg: user@mail.com
	if [[ -z "$email" ]]
	then
		email=" "
	else
		if ! [[ "$email" =~ .*@.*\..* ]]; then
			echo "Invalid email format! Emails must have '@' and end with '.<domain>'."
			return 1
		fi
	fi

	# 3. Mobile/Tel numbers must have 10 digits.
	if [[ -z "$mob" ]]
	then
		mob=" "
	fi

	if [[ -z "$tel" ]]
	then
		tel=" "
	fi

	if [[ "$mob" != " " && ! "$mob" =~ ^[0-9]{9}$ ]] ||
       [[ "$tel" != " " && ! "$tel" =~ ^[0-9]{9}$ ]]; then
        echo "Invalid telephone or mobile number! Must have 9 digits."
        return 1
    fi

	# 4. Place must have only alphabets
	if [[ -z "$place" ]]
	then
		place=" "
	else
		if ! [[ "$place" =~ ^[a-zA-Z]+$ ]]; then
			echo "Invalid place! Place must have only alphabets."
			return 1
		fi
	fi

	if [[ -z "$msg" ]]
	then
		msg=" "
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
					echo "Validation successful! Adding entry to the database."
					database_entry
				else
					echo "Validation failed! Please check your inputs."
					echo "Resetting data..."
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
                echo "Invalid choice!"
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
            echo "name,email,tel_no,mob_no,place,message,timestamps" > database.csv
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
