#!/bin/bash
shortcutKeys="hjklasdfguiopqwertzbnmyxcv"

for i in $(seq 0 ${#shortcutKeys})
    do shortcuts[$i]=${shortcutKeys:$i:1}
done

readarray -t commands < ~/.bashortcuts

commandsLength=${#commands[@]}
shortcutsLength=$(( ${#shortcuts[@]} - 1)) # null terminated string??

if (( commandsLength > shortcutsLength )); then
    echo "there are more commands than shortcuts, some commands will not be shown!"
fi

offerCount=$((commandsLength < shortcutsLength ? commandsLength : shortcutsLength))

for ((i=0; i<$offerCount; ++i)) do
    printf '[ %s ]   %s\n' "${shortcuts[${i}]}" "${commands[${i}]}"  
done

echo "which command do you want to run? press the shown key (case sensitive!) or Ctrl-C to cancel"
read -rsn1 selectedKey

IFS='[;' read -p $'\e[6n' -d R -rs _ currentLine currentColumn _ # https://www.reddit.com/r/bash/comments/139hvju/finding_the_current_cursor_position_in_bash/

deleteLineStart=$(( ${currentLine} - ${offerCount} - 2))
deleteLineStart=$(( deleteLineStart < 0 ? 0 : deleteLineStart ))

tput cup $deleteLineStart 0
tput ed

for ((i=0; i<$offerCount; ++i)) do
    if [ ${selectedKey} == ${shortcuts[${i}]} ]; then 
        executedCommand="${commands[${i}]}"
        break
    fi
done

echo "${executedCommand}"
eval "${executedCommand}"
