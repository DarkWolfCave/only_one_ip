#!/bin/bash
#-----------------------------------------#
# DarkWolfCave.de  Tutorials und Snippets #
#                                         #
# check IP and start another sh script    #
# over ssh with the new IP                #
# Version 0.1                             #
#-----------------------------------------#

MY_IP_FILE="/home/pi/test/my_ip.txt"
TEST_IP=$(wget -O - -q icanhazip.com)

echo "TestIP: $TEST_IP"

if [ -f "$MY_IP_FILE" ];then
        echo "Datei vorhanden"

        while read ZEILE; do

                if [ $ZEILE != $TEST_IP ]; then
                echo "letzte IP: $ZEILE und neue IP: $TEST_IP"
                echo "$TEST_IP" > "$MY_IP_FILE"
                ssh -n dwc-tut "/dwc-test/dwc-test.sh $TEST_IP"
                else
                echo "Keine Änderung der IP: $TEST_IP"
                fi
        done < "$MY_IP_FILE"

else
        echo "Datei nicht vorhanden"
        echo "$TEST_IP" > "$MY_IP_FILE"

fi