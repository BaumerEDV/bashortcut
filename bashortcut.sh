#!/bin/bash
bashortcut(){
    local shortcutKeys="hjklasdfguiopqwertzbnmyxcv"
    
    local i
    for i in $(seq 0 ${#shortcutKeys})
        do local shortcuts[$i]=${shortcutKeys:$i:1}
    done
    
    local commands
    readarray -t commands < ~/.bashortcuts
    
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
    
    local currentLine
    local currentColumn
    IFS='[;' read -p $'\e[6n' -d R -rs _ currentLine currentColumn _ # https://www.reddit.com/r/bash/comments/139hvju/finding_the_current_cursor_position_in_bash/
    
    local deleteLineStart=$(( ${currentLine} - ${offerCount} - 2))
    local deleteLineStart=$(( deleteLineStart < 0 ? 0 : deleteLineStart ))
    
    tput cup $deleteLineStart 0
    tput ed
    
    for ((i=0; i<$offerCount; ++i)) do
        if [ ${selectedKey} == ${shortcuts[${i}]} ]; then 
            local executedCommand="${commands[${i}]}"
            break
        fi
    done
    
    echo "${executedCommand}"
    eval "${executedCommand}"
}

bashortcut
