#!/bin/bash
shortcutKeys="hjklasdfguiopqwertzbnmyxcv"

for i in $(seq 0 ${#shortcutKeys})
    do shortcuts[$i]=${shortcutKeys:$i:1}
done

echo "reading commands from ~/.bashortcuts"
readarray -t commands < ~/.bashortcuts
echo "finished reading"
echo "read commands:"
printf '%s\n' "${commands[@]}"

commandsLength=${#commands[@]}
shortcutsLength=${#shortcuts[@]}

echo "commandsLength: ${commandsLength}"
echo "shortcutsLength: ${shortcutsLength}"

if (( commandsLength > shortcutsLength )); then
    echo "there are more commands than shortcuts, some commands will not be shown!"
fi

offerCount=$((commandsLength < shortcutsLength ? commandsLength : shortcutsLength))
echo "number of offers: ${offerCount}"

for ((i=0; i<$offerCount; ++i))
    do printf '[ %s ]   %s\n' "${shortcuts[${i}]}" "${commands[${i}]}"  
done
