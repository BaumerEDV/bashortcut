#!/bin/bash
bashortcut(){
    local SHORTCUT_KEYS="hjklasdfguiopqwertzbnmyxcv"
    local DO_CLEAR_MENU=true
    local DEFAULT_COMMANDS_SOURCE=~/.bashortcuts

    local i
    for i in $(seq 0 ${#SHORTCUT_KEYS})
        do local shortcuts[$i]=${SHORTCUT_KEYS:$i:1}
    done

    if [ ! -e ${DEFAULT_COMMANDS_SOURCE} ] ; then
        echo "You haven't created a file containing commands yet. Create $DEFAULT_COMMANDS_SOURCE"
        return 1
    fi
    local commands
    readarray -t commands < "${DEFAULT_COMMANDS_SOURCE}"
    
    local commandsLength=${#commands[@]}
    local shortcutsLength=$(( ${#shortcuts[@]} - 1)) # null terminated string??
    
    if (( commandsLength > shortcutsLength )); then
        echo "there are more commands than shortcuts, some commands will not be shown!"
    fi
    
    local offerCount=$((commandsLength < shortcutsLength ? commandsLength : shortcutsLength))
    
    for ((i=0; i<$offerCount; ++i)) do
        printf '[ %s ]   %s\n' "${shortcuts[${i}]}" "${commands[${i}]}"  
    done
    
    echo "which command do you want to run? press the shown key (case sensitive!) or Ctrl-C to cancel"
    local selectedKey
    read -rsn1 selectedKey
    
    if [ "$DO_CLEAR_MENU" = true ] ; then 
        local currentLine
        local currentColumn
        IFS='[;' read -p $'\e[6n' -d R -rs _ currentLine currentColumn _ # https://www.reddit.com/r/bash/comments/139hvju/finding_the_current_cursor_position_in_bash/
        local deleteLineStart=$(( ${currentLine} - ${offerCount} - 2))
        local deleteLineStart=$(( deleteLineStart < 0 ? 0 : deleteLineStart ))
        tput cup $deleteLineStart 0
        tput ed
    fi
    
    for ((i=0; i<$offerCount; ++i)) do
        if [ ${selectedKey} == ${shortcuts[${i}]} ]; then 
            local executedCommand="${commands[${i}]}"
            break
        fi
    done
    
    echo "${executedCommand}"
    eval "${executedCommand}"
    return 0
}

bashortcut
