#!/bin/bash
bashortcut(){
    ### SETTINGS
    local SHORTCUT_KEYS="hjklasdfguiopqwertzbnmyxcv"
    local DO_CLEAR_MENU=true
    local DEFAULT_COMMANDS_SOURCE=~/.bashortcuts
    local SEARCH_IN_PARENT_DIRECTORIES_AFTER_SOMETHING_WAS_FOUND=true
    local SEARCH_IN_HOME_AFTER_SOMETHING_WAS_FOUND=true

    # Set up shortcut keys
    local i
    for i in $(seq 0 ${#SHORTCUT_KEYS})
        do local shortcuts[$i]=${SHORTCUT_KEYS:$i:1}
    done

    # Verify menu deletion can work
    if ! command -v tput &> /dev/null
    then
        echo "'tput' not found, disabling menu deletion"
        echo "set DO_CLEAR_MENU to false to prevent future warnings"
        DO_CLEAR_MENU=false
    fi

    ### END SETTINGS

    ### SET UP COMMANDS
    local commands
    local isHomeReadAlready=false

    # search this directory and parent directories
    local directoryToSearch=$PWD
    while [ ! "$directoryToSearch" = "" ] ; do
        if [ "$directoryToSearch" = ~ ] ; then
            isHomeReadAlready=true
        fi

        local shortcutsFile="${directoryToSearch}/.bashortcuts"
        # search in parent directory for next iteration
        directoryToSearch="${directoryToSearch%/}"
        directoryToSearch="${directoryToSearch%/*}"

        if [ ! -e "${shortcutsFile}" ] ; then
            continue
        fi

        local newCommands
        readarray -t newCommands < "${shortcutsFile}"
        if [ ${#newCommands[@]} = 0 ] ; then
            echo "You haven't defined any commands inside ${shortcutsFile}"
            echo "Edit it with a text editor to get started"
            continue
        fi
        commands+=("${newCommands[@]}")

        if [ ${#newCommands[@]} != 0 ] && [ "${SEARCH_IN_PARENT_DIRECTORIES_AFTER_SOMETHING_WAS_FOUND}" = false ] ; then
            break
        fi
    done

    # Search home directory for defaults
    # (if home is not searched yet) && ((commands=0) || (commands!=0 && keepsearching))
    if [ "$isHomeReadAlready" = false ] ; then
        if (([ ${#commands[@]} = 0 ]) || ([ ${#commands[@]} != 0 ] && [ "$SEARCH_IN_HOME_AFTER_SOMETHING_WAS_FOUND" = true ])) ; then
            if  [ -e ${DEFAULT_COMMANDS_SOURCE} ] ; then
                readarray -t newCommands < "${DEFAULT_COMMANDS_SOURCE}"
                commands+=("${newCommands[@]}")
            fi
        fi
    fi
    
    # Verify there are any commands 
    local commandsLength=${#commands[@]}
    if [ $commandsLength = 0 ] ; then
        echo "You haven't defined any commands inside $DEFAULT_COMMANDS_SOURCE"
        echo "Edit it with a text editor to get started"
        return 1
    fi
    local shortcutsLength=$(( ${#shortcuts[@]} - 1)) # null terminated string??
    ### END SET UP COMMANDS
    
    # Set up offers
    if (( commandsLength > shortcutsLength )); then
        echo "there are more commands than shortcuts, some commands will not be shown!"
    fi
    local offerCount=$((commandsLength < shortcutsLength ? commandsLength : shortcutsLength))
    
    # Offer options
    for ((i=0; i<$offerCount; ++i)) do
        printf '[ %s ]   %s\n' "${shortcuts[${i}]}" "${commands[${i}]}"  
    done
    echo "which command do you want to run? press the shown key (case sensitive!) or Ctrl-C to cancel"
    local selectedKey
    read -rsn1 selectedKey
    
    # Clear offer menu
    if [ "$DO_CLEAR_MENU" = true ] ; then 
        local currentLine
        local currentColumn
        IFS='[;' read -p $'\e[6n' -d R -rs _ currentLine currentColumn _ # source: https://www.reddit.com/r/bash/comments/139hvju/finding_the_current_cursor_position_in_bash/
        local deleteLineStart=$(( ${currentLine} - ${offerCount} - 2))
        local deleteLineStart=$(( deleteLineStart < 0 ? 0 : deleteLineStart ))
        tput cup $deleteLineStart 0
        tput ed
    fi
    
    # Find chosen command
    for ((i=0; i<$offerCount; ++i)) do
        if [ ${selectedKey} == ${shortcuts[${i}]} ]; then 
            local executedCommand="${commands[${i}]}"
            break
        fi
    done
    
    # Display & run chosen command
    echo "${executedCommand}"
    eval "${executedCommand}"
    return 0
}

bashortcut
