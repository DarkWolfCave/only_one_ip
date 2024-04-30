#!/bin/bash
#-----------------------------------------#
# DarkWolfCave.de  Tutorials und Snippets #
#                                         #
# Allow only one IP to connect my Website #
# Version 0.1                             #
#-----------------------------------------#

HTACCESS_FILES_PATH="/dwc-test/htaccess_files.txt"
IP_ADDRESS=$1
LOG_FILES="/dwc-test/logs.txt"
NOW=$(date +"%d-%m-%Y")
COUNT_FILE='1'

#check if argument (IP) empty
if [ -z "$1" ] ; then echo "Falscher Aufruf! Benutze only_one_ip.sh <IP> (Beispiel: test.sh 1.1.1.1)" ; fi

#check if IP is a valid IP
if echo "$1" | grep -E -q '^(25[0-5]|(2[0-4]|1[0-9]|[1-9])?[0-9]\.){3}(25[0-5]|(2[0-4]|1[0-9]|[1-9])?[0-9])$'; then
  echo "Die IP-Adresse $1 ist gültig."
else
  echo "Die IP-Adresse $1 ist ungültig."
  exit 1
fi

printf '%s\n' \
            "--------------------" \
            "IP changed to: $IP_ADDRESS" \
            "Date: $NOW" \
            >> "$LOG_FILES"

echo "********************" &>> "$LOG_FILES"
while read -r htaccess_file; do
    # Lesen der Datei
    if [ -f "$htaccess_file" ]; then
        readarray -t lines < "$htaccess_file"
        echo "*** Nr. $COUNT_FILE - Bearbeite $htaccess_file: " &>> "$LOG_FILES"
    else
        echo "*** Nr. $COUNT_FILE - $htaccess_file nicht gefunden!" &>>"$LOG_FILES"
        continue
    fi

    # Suchen nach dem Beginn-Tag
    begin_tag="# Begin dwc only my IP"
    begin_line=$(grep -n "$begin_tag" "$htaccess_file" | cut -d: -f1)

    if [[ -n "$begin_line" ]]; then # Wenn der Beginn-Tag gefunden wurde
        # Suchen nach dem Ende-Tag
        end_tag="# END dwc only my IP"
        end_line=$(grep -n "$end_tag" "$htaccess_file" | cut -d: -f1)
        echo "*** Beginn Tag gefunden" &>>"$LOG_FILES"

        if [[ -n "$end_line" ]]; then # Wenn der Ende-Tag gefunden wurde
            # Ersetzen der IP-Adresse
            for (( i=$begin_line+1; i<$end_line; i++ )); do
                if [[ "${lines[i]}" == *"Allow from"* ]]; then
                    lines[i]="Allow from $IP_ADDRESS"
                    echo "*** ${lines[i]} gefunden und durch Allow from $IP_ADDRESS ersetzt" &>> "$LOG_FILES"
                    break
                fi
            done

            # Schreiben der Datei
            printf '%s\n' "${lines[@]}" > "$htaccess_file"
        else
            echo "*** Ende-Tag nicht gefunden in $htaccess_file!" &>>"$LOG_FILES"
        fi
    else # Wenn der Beginn-Tag nicht gefunden wurde
        # Hinzufügen des gewünschten Texts
        echo "*** Beginn-Tag nicht gefunden, füge erstmalig gesamten Eintrag hinzu: " &>> "$LOG_FILES"
        printf '%s\n' \
            "# Begin dwc only my IP" \
            "# allow only one IP " \
            "# and disallow all other requests" \
            "Order deny,allow" \
            "Deny from all" \
            "Allow from $IP_ADDRESS" \
            "# END dwc only my IP" \
            | cat - "$htaccess_file" > temp && mv temp "$htaccess_file"
    fi
echo "********************" &>> "$LOG_FILES"
((COUNT_FILE++))
done < "$HTACCESS_FILES_PATH"
echo "--------------------" &>> "$LOG_FILES"