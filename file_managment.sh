#!/bin/bash
trap 'error_handler $LINENO "$BASH_COMMAND"' ERR
source ./system_monitoring.sh
BACKUP_DIR="./BACKUP"
mkdir -p "$BACKUP_DIR"


# function display_menu() {
#   echo "1) File Managment Tool"
#   echo "2) System Monitoring"
#   read menu_choice
#   case $menu_choice in
#     1) display_file_management ;;
#     2) display_system_monitoring ;;
#     *) echo "Invalid choice" ;;
#   esac
# }

function display_menu() {
    menu_choice=$(yad --list --title="Menu" --column="Description" \
        --width=300 --height=200 \
         "File Management Tool" \
         "System Monitoring" \
        --button=gtk-ok:0 --button=Exit:1 )

    if [ $? -eq 0 ]; then
        case $(echo $menu_choice | cut -f1 -d"|") in
            "File Management Tool") display_file_management ;;
            "System Monitoring") display_system_monitoring ;;
            *) yad --info --title="Error" --text="Invalid choice" ;;
        esac
    else
        echo "Menu canceled."
        exit 0
    fi
}

# function display_file_management() {
#   while true; do
#   echo "1. Create"
#   echo "2. Copy"
#   echo "3. Move"
#   echo "4. Rename"
#   echo "5. Delete"
#   echo "6. Search"
#   echo "7. Perrmision Management"
#   echo "8. Backup and Restore files"
#   echo "9. Back"
#   read file_choice
#   case $file_choice in
#     1) create ;;
#     2) copy ;;
#     3) move ;;
#     4) rename ;;
#     5) delete ;;
#     6) search ;;
#     7) display_permission_managment ;;
#     8) display_backup_management ;;
#     9) break ;;
#     *) echo "Invalid choice" ;;
#   esac
#   done
# }

function display_file_management() {
    while true; do
        file_choice=$(yad --list --title="File Management" --column="Action" \
            --width=300 --height=300 \
             "Create" \
             "Copy" \
             "Move" \
             "Rename" \
             "Delete" \
             "Search" \
             "Permission Management" \
             "Backup and Restore files" \
            --button=gtk-ok:0 --button=gtk-cancel:1)

        if [ $? -eq 0 ]; then
            selected_option=$(echo $file_choice | awk -F '|' '{print $1}')

            case $selected_option in
                "Create") create ;;
                "Copy") copy ;;
                "Move") move ;;
                "Rename") rename ;;
                "Delete") delete ;;
                "Search") search ;;
                "Permission Management") display_permission_management ;;
                "Backup and Restore files") display_backup_management ;;
                *) yad --info --title="Error" --text="Invalid choice" ;;
            esac
        else
            break  
        fi
    done
}

# function display_backup_management() {
#   while true; do
#   echo "1. Backup files"
#   echo "2. Restore files"
#   case $choice in
#   1) createBackup ;;
#   2) restoreBackup ;;
#   *) echo "Invalid choice" ;;
#   esac
#   done
# }

function display_backup_management() {
    while true; do
        choice=$(yad --list --title="Backup Management"  --column="Action" \
            --width=300 --height=200 \
             "Backup files" \
             "Restore files" \
            --button=gtk-ok:0 --button=gtk-cancel:1)

        if [ $? -eq 0 ]; then
            selected_option=$(echo $choice | awk -F '|' '{print $1}')

            case $selected_option in
                "Backup files") createBackup ;;
                "Restore files") restoreBackup ;;
                *) yad --info --title="Error" --text="Invalid choice" ;;
            esac
        else
            break  
        fi
    done
}

# function create() {
#   while true; do
#   echo "Enter the number if you wish to create a file (1) or directory (2) or cancel(3):"
#   read choice
#   echo "Enter the path (optional):"
#   read path
#   case $choice in
#   	1)
#   	echo "Enter the file name"
#   	read name
#   	if [[ -z "$path" ]]; then
#         	if [[ -f "$name" ]]; then
#             		echo "This file does exist in this directory"
#           	else
#             		touch "$name"
#             		echo "The file has been created"
#             		echo "Returning to main menu"
# 	    		break
# 	    	fi
#         elif [[ -d "$path" ]]; then
#         	if [[ -f "$path/$name" ]]; then
#             		echo "This file does exist in this directory"
#           	else
# 			touch "$path/$name"
# 			echo "The file has been created"
# 			echo "Returning to main menu"
# 			break
# 		fi
#         else
# 		echo "This path does not exist in this directory"
#         fi
#         ;;
#         2)
#   	echo "Enter the folder name"
#   	read name
#   	if [[ -z "$path" ]]; then
#         	if [[ -f "$name" ]]; then
#             		echo "This folder does exist in this directory"
#           	else
#             		touch "$name"
#             		echo "The folder has been created"
#             		echo "Returning to main menu"
# 	    		break
# 	    	fi
#         elif [[ -d "$path" ]]; then
#         	if [[ -f "$path/$name" ]]; then
#             		echo "This folder does exist in this directory"
#           	else
# 			touch "$path/$name"
# 			echo "The folder has been created"
# 			echo "Returning to main menu"
# 			break
# 		fi
#         else
# 		echo "This path does not exist in this directory"
#         fi
#         ;;
#         3)
#         break
#         ;;
#         *)
#         echo "Invalid choice"
#   esac
#   done
# }

function create() {
    while true; do
        choice=$(yad --list --title="Create" --column="Option" --column="Action" \
            --width=400 --height=200 \
            1 "Create a file" \
            2 "Create a directory" \
            --button=gtk-ok:0 --button=gtk-cancel:1)

        if [ $? -eq 0 ]; then
            selected_option=$(echo $choice | awk -F '|' '{print $1}')
            path=$(yad --file-selection --directory --title="Select Directory" --text="Choose the directory:" --width=400 --height=150)
            case $selected_option in
                1)
                    name=$(yad --entry --title="File Name" --text="Enter the file name:")
                        if [[ -f "$path/$name" ]]; then
                            yad --info --title="Error" --text="This file already exists in this directory."
                        else
                            touch "$path/$name"
                            yad --info --title="Success" --text="The file has been created.\nReturning to the main menu."
                            break
                        fi
                    ;;
                2)
                    name=$(yad --entry --title="Directory Name" --text="Enter the directory name:")
                    if [[ -d "$path/$name" ]]; then
                            yad --info --title="Error" --text="This directory already exists."
                        else
                            mkdir "$path/$name"
                            yad --info --title="Success" --text="The directory has been created.\nReturning to the main menu."
                            break
                        fi
                    ;;
                *)
                    yad --info --title="Error" --text="Invalid choice"
                    ;;
            esac
        else
            break  
        fi
    done
}

# function copy() {
#   while true; do
#     echo "Enter the souce directory or enter cancel(3): "
#     read -e sourceDirectory
#     case $sourceDirectory in 
#     3) break;;
#     *) ;;
#     esac
#     if [[ -f "$sourceDirectory" ||  -d "$sourceDirectory" ]]; then
#       echo "Enter the destination directory or enter cancel(3):"
#       read -e destinationDirectory
#       case $destinationDirectory in 
#     3) break;;
#     *) ;;
#     esac
#       if [[ -f "$destinationDirectory" ||  -d "$destinationDirectory" ]]; then
#       cp -ri $sourceDirectory $destinationDirectory
#       break
#       else
#       echo "This path does not exist"
#       fi
#     else
#       echo "This path does not exist"
#     fi
#   done
# }

function copy() {
    while true; do
        sourceDirectory=$(yad --file-selection --title="Copy files" --text="Choose a file or directory:" \
            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)

        if [ $? -ne 0 ]; then
            break
        fi

        if [[ -f "$sourceDirectory" || -d "$sourceDirectory" ]]; then
            destinationDirectory=$(yad --file-selection --title="Copy files" --text="Choose the destination directory:" \
                --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)
            
            if [ $? -ne 0 ]; then
                break
            fi

            if [[ -d "$destinationDirectory" ]]; then
                cp -ri "$sourceDirectory" "$destinationDirectory"
                yad --info --title="Success" --text="Files have been copied successfully." --width=300 --height=150
                break
            else
                yad --error --title="Error" --text="The destination path does not exist." --width=300 --height=150
            fi
        else
            yad --error --title="Error" --text="The source path does not exist." --width=300 --height=150
        fi
    done
}



# function move() {
#   while true; do
#     echo "Enter the souce directory or enter cancel(3): "
#     read -e sourceDirectory
#     case $sourceDirectory in 
#     3) break;;
#     *) ;;
#     esac
#     if [[ -f "$sourceDirectory" ||  -d "$sourceDirectory" ]]; then
#       echo "Enter the destination directory or enter cancel(3):"
#       read -e destinationDirectory
#       case $destinationDirectory in 
#     3) break;;
#     *) ;;
#     esac
#       if [[ -f "$destinationDirectory" ||  -d "$destinationDirectory" ]]; then
#       cp -ri $sourceDirectory $destinationDirectory
#       rm -rf $sourceDirectory
#       break
#       else
#       echo "This path does not exist"
#       fi
#     else
#       echo "This path does not exist"
#     fi
#   done
# }

function move() {
    while true; do
        sourceDirectory=$(yad --file-selection --title="Move Files" --text="Choose the source directory or file path:" \
            --button=gtk-ok:0 --button=gtk-cancel:1)

        if [ $? -ne 0 ]; then
            break
        fi

        if [[ -f "$sourceDirectory" || -d "$sourceDirectory" ]]; then
            destinationDirectory=$(yad --file-selection --title="Move Files" --text="Choose the destination directory:" \
                --button=gtk-ok:0 --button=gtk-cancel:1)

            if [ $? -ne 0 ]; then
                break
            fi

            if [[ -f "$destinationDirectory" || -d "$destinationDirectory" ]]; then
                cp -ri "$sourceDirectory" "$destinationDirectory"
                rm -rf "$sourceDirectory"
                yad --info --title="Success" --text="Files have been moved successfully."
                break
            else
                yad --error --title="Error" --text="The destination path does not exist."
            fi
        else
            yad --error --title="Error" --text="The source path does not exist."
        fi
    done
}


# function rename() {
#   while true; do
#     echo "Enter the path where the file is located (optional) or cancel(3): "
#     read -e path
#     case $path in 
#     3) break;;
#     *) ;;
#     esac

#     echo "Enter the file/folder name to rename: " 
#     read -e old_name
#     echo "Enter the new file/folder name: " 
#     read -e new_name

#     if [[ -z "$path" ]]; then
#         	if [[ -f "$old_name" || -d "$old_name" ]]; then
#                 echo "Are you sure you want to rename yes(yY) no(nN)? " 
#                 read -e confirm
#                 if [[ "$confirm" =~ ^[Yy]$ ]]; then
#             		  mv "$old_name" "$new_name"
#                   break
#                 else
#                   echo "File/Folder renaming cancelled."
#                 fi
#           	else
#             		echo "This file/folder doesn't exist in this directory"
# 	    		break
# 	    	fi
#     elif [[ -d "$path" ]]; then
#       if [[ -f "$path$old_name" || -d "$path$old_name" ]]; then
#                 echo "Are you sure you want to rename yes(yY) no(nN)? " 
#                 read -e confirm
#                 if [[ "$confirm" =~ ^[Yy]$ ]]; then
#             		    mv "$path$old_name" "$path$new_name"
#                     break
#                 else
#                     echo "Folder renaming cancelled."
#                 fi
#       else
#           echo "This file/folder doesn't exist in this directory"
# 	    		break
#       fi
#     else
#       echo "This path doesn't exist"
#     fi
#   done
# }

function rename() {
    while true; do

        old_name=$(yad --file-selection --title="Rename File/Folder" --text="Choose the file/folder name to rename:" \
            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)
        
        if [ $? -ne 0 ]; then
            break
        fi

        new_name=$(yad --entry --title="Rename File/Folder" --text="Enter the new file/folder name:" \
            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)
        
        if [ $? -ne 0 ]; then
            break
        fi

        if [[ -f "$old_name" || -d "$old_name" ]]; then
                confirm=$(yad --question --title="Confirm Rename" --text="Are you sure you want to rename '$old_name' to '$new_name'?" \
                    --button=gtk-yes:0 --button=gtk-no:1 --width=300 --height=150)
                
                if [ $? -ne 0 ]; then
                    yad --info --title="Cancelled" --text="File/Folder renaming cancelled." --width=300 --height=150
                    continue
                fi
                
                mv "$old_name" "$new_name"
                yad --info --title="Success" --text="File/Folder has been renamed successfully." --width=300 --height=150
                break
        else
            yad --error --title="Error" --text="This file/folder doesn't exist in this directory." --width=300 --height=150
            break
        fi
        
        
    done
}

# function delete() {
#   while true; do
#     echo "Enter the path where the file is located (optional) or cancel(3): "
#     read -e path
#     case $path in 
#     3) break;;
#     *) ;;
#     esac
#     echo "Enter the file/folder name to delete: " 
#     read -e file_name
#     if [[ -z "$path" ]]; then
#         	if [[ -f "$file_name" || -d "$file_name" ]]; then
#                 echo "Are you sure you want to delete yes(yY) no(nN)? " 
#                 read -e confirm
#                 if [[ "$confirm" =~ ^[Yy]$ ]]; then
#             		    rm -rf "$file_name"
#                     break
#                 else
#                     echo "File/Folder deleting cancelled."
#                 fi
#           	else
#             		echo "This file/folder doesn't exist in this directory"
# 	    		break
# 	    	fi
#     elif [[ -d "$path" ]]; then
#       if [[ -f "$path$file_name" || -d "$path$file_name" ]]; then
#                 echo "Are you sure you want to delete yes(yY) no(nN)? " 
#                 read -e confirm
#                 case $confirm in
#                 "y" | "Y" )
#                   rm -rf "$path$file_name"
#                   break ;;
#                 "n" | "N" )
#                   echo "File/Folder deleting cancelled."
#                   break ;;
#                   *) echo "invalid option please try again from the beginning" ;;
#                   esac
#       else
#           echo "This file/folder doesn't exist in this directory"
# 	    		break
#       fi
#     else
#       echo "This path doesn't exist"
#     fi
#   done
# }

function delete() {
    while true; do
        

        file_name=$(yad --file-selection --title="Delete File/Folder" --text="Enter the file/folder name to delete:" \
            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)

        if [ $? -ne 0 ]; then
            break
        fi
            if [[ -f "$file_name" || -d "$file_name" ]]; then
                confirm=$(yad --question --title="Confirm Delete" --text="Are you sure you want to delete '$file_name'?" \
                    --button=gtk-yes:0 --button=gtk-no:1 --width=300 --height=150)
                
                if [ $? -ne 0 ]; then
                    yad --info --title="Cancelled" --text="File/Folder deleting cancelled." --width=300 --height=150
                    continue
                fi
                
                rm -rf "$file_name"
                yad --info --title="Success" --text="File/Folder has been deleted successfully." --width=300 --height=150
                break
            else
                yad --error --title="Error" --text="This file/folder doesn't exist in this directory." --width=300 --height=150
                break
            fi
    done
}

# function search() {
#   while true; do
#     read -ep "Enter the directory to search in (default is current directory): " directory
#     directory=${directory:-"."}  

#     read -p "Enter the file name pattern (e.g., *.txt, press Enter to skip): " name
#     read -p "Enter the file type (f for file, d for directory, press Enter to skip): " type
#     read -p "Enter the file size (e.g., +100M for files larger than 100MB, press Enter to skip): " size
#     read -p "Enter the modification time (e.g., -7 for files modified in the last 7 days, press Enter to skip): " date

#     find_command="find \"$directory\""

#     if [ -n "$name" ]; then
#         find_command+=" -name \"$name\""
#     fi

#     if [ -n "$type" ]; then
#         find_command+=" -type $type"
#     fi

#     if [ -n "$size" ]; then
#         find_command+=" -size $size"
#     fi

#     if [ -n "$date" ]; then
#         find_command+=" -mtime $date"
#     fi

#     echo "Executing: $find_command"
#     output=$(eval "$find_command")
#     if [ -n "$output" ]; then
#       echo $output | sed 's/ /\n/g'
#     else
#       echo "No file/folder has been found"
#     fi
#   done
# }

function search() {
    while true; do
        directory=$(yad --file-selection --directory --title="Search" --text="Enter the directory to search in:" \
            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)
        if [ $? -ne 0 ]; then
            break
        fi

        directory=${directory:-"."}
        
        results=$(yad --form --title="Search" --text="Enter your search criteria:" \
    --field="File Name Pattern (e.g., *.txt):" "" \
    --field="File Type (f for file, d for directory):" "" \
    --field="File Size (e.g., +100M):" "" \
    --field="Modification Time (e.g., -7):" "" \
    --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=300)

        if [ $? -ne 0 ]; then
            echo "Operation cancelled."
            break
        fi

        name=$(echo "$results" | cut -d '|' -f 1)
        type=$(echo "$results" | cut -d '|' -f 2)
        size=$(echo "$results" | cut -d '|' -f 3)
        date=$(echo "$results" | cut -d '|' -f 4)

        find_command="find \"$directory\""

        if [ -n "$name" ]; then
            find_command+=" -iname \"*$name*\""
        fi

        if [ -n "$type" ]; then
            find_command+=" -type $type"
        fi

        if [ -n "$size" ]; then
            find_command+=" -size $size"
        fi

        if [ -n "$date" ]; then
            find_command+=" -mtime $date"
        fi
        output=$(eval "$find_command")
        echo $output
        if [ -n "$output" ]; then
            yad --text-info --title="Search Results" --width=600 --height=400 --filename=<(echo "$output")
            break
        else
            yad --info --title="No Results" --text="No file/folder has been found." --width=300 --height=150
            break
        fi
    done
}



function error_handler() {
    echo "Error occurred in script at line: $1, command: '$2'"
}

# function display_permission_managment() {
#   while true; do
#     echo "1) File Permission"
#     echo "2) Ownership Permission"
#     echo "3) Back"
#     read permission_choice
#     case $permission_choice in
#       1) permission_files ;;
#       2) permission_ownership ;;
#       3) break ;;
#       *) echo "Invalid choice" ;;
#     esac
#   done
# }

function display_permission_management() {
    while true; do
        permission_choice=$(yad --list --title="Permission Management" --column="Choose" \
            "File Permission" \
            "Ownership Permission" \
            --width=300 --height=200 --button=gtk-ok:0 --button=gtk-cancel:1)

        if [ $? -ne 0 ]; then
            break
        fi
        echo $permission_choice
        case $permission_choice in
            "File Permission|")
                permission_files
                ;;
            "Ownership Permission|")
                permission_ownership
                ;;
            *)
                yad --error --title="Error" --text="Invalid choice. Please select a valid option." --width=300 --height=150
                ;;
        esac
    done
}


# function permission_ownership() {
#   while true; do
#   read -ep "Enter the file or directory path: " target

#   if [ ! -e "$target" ]; then
#       echo "Error: $target does not exist."
#       continue
#   fi

#   read -p "Enter the user ownership (e.g., john, press Enter to skip): " user_ownership
#   read -p "Enter the group ownership (e.g., staff, press Enter to skip): " group_ownership

#   if [[ -n "$user_ownership" || -n "$group_ownership" ]]; then
#     chown "$user_ownership:$group_ownership" "$target" 2>/dev/null
#     echo "Permission ownership has been successfully"
#     break
#   else
#     echo "Permission ownership has been cancelled"
#     break
#   fi
#   done
# }

function permission_ownership() {
    while true; do
        target=$(yad --file-selection --title="Permission Ownership" --text="Enter the file or directory path:" \
            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)
        
        if [ $? -ne 0 ]; then
            break
        fi

        if [ ! -e "$target" ]; then
            yad --error --title="Error" --text="$target does not exist." --width=300 --height=150
            continue
        fi

        user_ownership=$(yad --entry --title="Permission Ownership" --text="Enter the user ownership (e.g., john, press Enter to skip):" \
            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)
        
        if [ $? -ne 0 ]; then
            break
        fi

        group_ownership=$(yad --entry --title="Permission Ownership" --text="Enter the group ownership (e.g., staff, press Enter to skip):" \
            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)
        
        if [ $? -ne 0 ]; then
            break
        fi

        if [[ -n "$user_ownership" || -n "$group_ownership" ]]; then
            if sudo chown "$user_ownership:$group_ownership" "$target" 2>/dev/null; then
                yad --info --title="Success" --text="Permission ownership has been successfully changed." --width=300 --height=150
            else
                yad --error --title="Error" --text="Failed to change permission ownership. Check your input and try again." --width=300 --height=150
            fi
            break
        else
            yad --info --title="Cancelled" --text="Permission ownership change has been cancelled." --width=300 --height=150
            break
        fi
    done
}

# function permission_files() {
#   while true; do
#   read -ep "Enter the file or directory path: " target

#   if [ ! -e "$target" ]; then
#       echo "Error: $target does not exist."
#       continue
#   fi
#   read -p "Enter the permission modes (e.g., 755) or Enter permissions specifically (Enter sp),(press Enter to skip): " permissions
#   if [[ -n "$permissions" ]]; then
#     if [[ "$permissions" =~ ^[0-7]{1,3}$ ]]; then
#       chmod "$permissions" "$target" 2>/dev/null
#       echo "Permission has been changed"
#       break
#     else
#     case $permissions in
#       "sp") 
#         read -p "Enter the permission that you want to add/remove/set to the user (e.g +r-w=x, press Enter to skip): " user_permission
#         read -p "Enter the permission that you want to add/remove/set to the group  (e.g +r-w=x, press Enter to skip): " group_permission
#         read -p "Enter the permission that you want to add/remove/set to the others (e.g +r-w=x, press Enter to skip): " other_permission
        
#         if [[ -n "$user_permission" ]]; then
#           chmod "u$user_permission" "$target"
#         fi

#         if [[ -n "$group_permission" ]]; then
#           chmod "g$group_permission" "$target"
#         fi

#         if [[ -n "$other_permission" ]]; then
#           chmod "o$other_permission" "$target"
#         fi
#         echo "Permission has been changed"
#         break
#         ;;
#       *) echo "Invalid option please try again" ;;
#     esac
#     fi
#   fi
#   done
# }

function permission_files() {
    while true; do
        target=$(yad --file-selection --title="File Permission" --text="Chooose the file or directory path:" \
            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)

        if [ $? -ne 0 ]; then
            break
        fi

        if [ ! -e "$target" ]; then
            yad --error --title="Error" --text="$target does not exist." --width=300 --height=150
            continue
        fi

        permissions=$(yad --entry --title="File Permission" --text="Enter the permission modes (e.g., 755) or Enter permissions specifically (Enter sp), press Enter to skip:" \
            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)

        if [ $? -ne 0 ]; then
            break
        fi

        if [[ -n "$permissions" ]]; then
            if [[ "$permissions" =~ ^[0-7]{1,3}$ ]]; then
                chmod "$permissions" "$target" 2>/dev/null
                yad --info --title="Success" --text="Permission has been changed." --width=300 --height=150
                break
            else
                case $permissions in
                    "sp")
                        user_permission=$(yad --entry --title="File Permission" --text="Enter the permission to add/remove/set for the user (e.g., +r-w=x, press Enter to skip):" \
                            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)
                        
                        group_permission=$(yad --entry --title="File Permission" --text="Enter the permission to add/remove/set for the group (e.g., +r-w=x, press Enter to skip):" \
                            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)
                        
                        other_permission=$(yad --entry --title="File Permission" --text="Enter the permission to add/remove/set for others (e.g., +r-w=x, press Enter to skip):" \
                            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)
                        
                        if [[ -n "$user_permission" ]]; then
                            chmod "u$user_permission" "$target"
                        fi

                        if [[ -n "$group_permission" ]]; then
                            chmod "g$group_permission" "$target"
                        fi

                        if [[ -n "$other_permission" ]]; then
                            chmod "o$other_permission" "$target"
                        fi

                        yad --info --title="Success" --text="Permission has been changed." --width=300 --height=150
                        break
                        ;;
                    *)
                        yad --error --title="Error" --text="Invalid option. Please try again." --width=300 --height=150
                        ;;
                esac
            fi
        fi
    done
}


# createBackup() {
#     while true; do
#         clear
#         read -e -p "Enter the file path or (0) to back: " file_path
        
#         if [[ "$file_path" = 0 ]]; then
#             break
#         fi
        
#         if [[ ! -e "$file_path" ]]; then
#             echo "File not found"
#             continue
#         fi
        
#         backup_name=$(echo "$file_path" | awk -F'/' '{print $NF}').tar.gz
#         echo "$backup_name"
#         tar -czvf "$backup_name" "$file_path" 2>/dev/null
#         if [[ $? -ne 0 ]]; then
#             echo "Error: Failed to create backup."
#             continue
#         fi
        
#         clear
#         mv "$backup_name" "$BACKUP_DIR"
#         echo "Backup created successfully: $backup_name"
#         break
#     done
# }

function createBackup() {
    while true; do
        file_path=$(yad --file-selection --title="Create Backup" --text="Enter the file path to back up (or enter '0' to cancel):" \
            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)

        if [ $? -ne 0 ]; then
            break
        fi

        if [[ "$file_path" == "0" ]]; then
            break
        fi

        if [ ! -e "$file_path" ]; then
            yad --error --title="Error" --text="File not found." --width=300 --height=150
            continue
        fi

        backup_name=$(basename "$file_path").tar.gz

        tar -czvf "$backup_name" "$file_path" 2>/dev/null
        if [ $? -ne 0 ]; then
            yad --error --title="Error" --text="Failed to create backup." --width=300 --height=150
            continue
        fi

        mv "$backup_name" "$BACKUP_DIR"

        yad --info --title="Success" --text="Backup created successfully: $backup_name" --width=300 --height=150
        break
    done
}


# restoreBackup(){
#     clear
    
#     while true; do
        
#         read -e -p "Enter the file name (e.g. filename.tar.gz) or (0) or (L) to back: " file_path
        
#         if [[ "$file_path" = 0 ]]; then
#             break
#         fi
        
#         if [[ "$file_path" = "L" ]]; then
#             clear
#             ls -lh "$BACKUP_DIR"
#             continue
#         fi
        
#         echo "$BACKUP_DIR/$file_path"
        
#         if [[ ! -e "$BACKUP_DIR/$file_path" ]]; then
#             echo "File not found"
#             continue
#         fi
        
#         tar -xzvf "$BACKUP_DIR/$file_path" -C "$BACKUP_DIR/"
#         if [[ $? -ne 0 ]]; then
#             echo "Error: Failed to restore backup."
#             continue
#         fi
        
#         echo "Backup restored successfully to: $BACKUP_DIR"
#         break
        
#     done
# }

function restoreBackup() {
    while true; do
        file_path=$(yad --file-selection --title="Restore Backup" --text="Enter the file name (e.g., filename.tar.gz) or (0) to cancel, (L) to list files:" \
            --button=gtk-ok:0 --button=gtk-cancel:1 --width=400 --height=200)

        if [ $? -ne 0 ]; then
            break
        fi

        if [[ "$file_path" == "0" ]]; then
            break
        fi

        if [[ "$file_path" == "L" ]]; then
            yad --text-info --title="Backup Files" --width=600 --height=400 --text="$(ls -lh "$BACKUP_DIR")"
            continue
        fi

        

        tar -xzvf "$file_path" -C "$BACKUP_DIR/" 2>/dev/null
        if [ $? -ne 0 ]; then
            yad --error --title="Error" --text="Failed to restore backup." --width=300 --height=150
            continue
        fi

        yad --info --title="Success" --text="Backup restored successfully to: $BACKUP_DIR" --width=300 --height=150
        break
    done
}



while true; do
  display_menu
done
