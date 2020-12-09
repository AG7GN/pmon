#!/bin/bash

VERSION="1.0.6" 

# This script allows the user to change the title bar of Fldigi suite and Direwolf
# applications so they say something other than "Left Radio" or "Right Radio"

TITLE="PACTOR Monitor $VERSION"
CONFIG_FILE="$HOME/pmon.conf"
NAMES_CONFIG_FILE="$HOME/radionames.conf"

trap errorReport INT

function errorReport () {
	EXIT_CODE=${2:-1}
   echo
   if [[ $1 == "" ]]
   then
      exit 0
   else
		yad --center --title="$TITLE" --text "<b><big>ERROR: $1</big></b>" \
  			--question --no-wrap \
  			--borders=20 \
  			--buttons-layout=center \
  			--text-align=center \
  			--align=right \
  			--button=Close:$EXIT_CODE
   fi         
}


function configAlsa () {
   if ! grep -q "pmon-right"
   then 
	   CARD="$($(command -v pmon) -a ? | grep -m1 -o "^hw:[0-9],[0-9]")"
   	[[ -f $HOME/.asoundrc ]] && mv $HOME/.asoundrc $HOME/.asoundrc-backup
   	cat >> $HOME/.asoundrc <<EOF
pcm.pmon-right {
   type asym
   capture.pcm {
      type route
      slave.pcm "$CARD"
      ttable {
         0.1 1
         1.0 1
      }
   }
   playback.pcm {
      type route
      slave.pcm "$CARD"
      ttable {
         0.1 1
         1.0 1
      }
   }
}
pcm.pmon-left {
   type plug
   slave.pcm "hw:1,0"
}
EOF
	fi
}

command -v pmon || errorReport "pmon not found" 1

if [ -s "$CONFIG_FILE" ]
then # There is a config file
   echo "$CONFIG_FILE found."
	source "$CONFIG_FILE"
else # Set some default values in a new config file
   echo "Config file $CONFIG_FILE not found.  Creating a new one with default values."
	echo "declare -A F" > "$CONFIG_FILE"
	echo "F[_AUDIO_]='left:'" >> "$CONFIG_FILE"
   echo "F[_PACKETS_]='1: Traffic+Request'" >> "$CONFIG_FILE"
   echo "F[_VERBOSE_]='0: No'" >> "$CONFIG_FILE"
   echo "F[_HEX_]='1: On'" >> "$CONFIG_FILE"
	source "$CONFIG_FILE"
fi

if [ -s "$NAMES_CONFIG_FILE" ]
then # There is a config file
   source "$NAMES_CONFIG_FILE"
else 
   LEFT_RADIO_NAME="Left Radio"
   RIGHT_RADIO_NAME="Right Radio"
fi

AUDIOs="left: ${LEFT_RADIO_NAME}!right: ${RIGHT_RADIO_NAME}"
PACKETs="0: Traffic!1: Traffic+Request"
VERBOSEs="0: No!1: Yes"
HEXs="0: Off!1: On"

MESSAGE="pmon does not use PulseAudio and must\n \
have exclusive control of the sound card.\n  \
Close all other applications that use the sound card!\n\n \
Once pmon is running, press Ctrl-C to quit - don't just close the window."

AUDIOs="$(echo "$AUDIOs" | sed "s/${F[_AUDIO_]}/\^${F[_AUDIO_]}/")"
PACKETs="$(echo "$PACKETs" | sed "s/${F[_PACKETS_]}/\^${F[_PACKETS_]}/")"
VERBOSEs="$(echo "$VERBOSEs" | sed "s/${F[_VERBOSE_]}/\^${F[_VERBOSE_]}/")"
HEXs="$(echo "$HEXs" | sed "s/${F[_HEX_]}/\^${F[_HEX_]}/")"

ANS=""
ANS="$(yad --title="$TITLE" \
   --text="<b><big><big>PMON Configuration Parameters</big></big></b>\n\n \
<b><span color='red'>IMPORTANT: </span>$MESSAGE</b>\n\n" \
   --item-separator="!" \
   --center \
   --buttons-layout=center \
   --text-align=center \
   --align=right \
   --borders=20 \
   --form \
   --field="Radio":CB "$AUDIOs" \
   --field="Decode":CB "$PACKETs" \
   --field="Verbose":CB "$VERBOSEs" \
   --field="HEX Decode":CB "$HEXs" \
   --focus-field 1 \
)"

[[ $? == 1 || $? == 252 ]] && errorReport  # User has cancelled.

[[ $ANS == "" ]] && errorReport "Error." 1

IFS='|' read -r -a TF <<< "$ANS"

echo "declare -A F" > "$CONFIG_FILE"
echo "F[_AUDIO_]='$(echo ${TF[0]} | cut -d: -f1):'" >> "$CONFIG_FILE"
echo "F[_PACKETS_]='${TF[1]}'" >> "$CONFIG_FILE"
echo "F[_VERBOSE_]='${TF[2]}'" >> "$CONFIG_FILE"
echo "F[_HEX_]='${TF[3]}'" >> "$CONFIG_FILE"

AUDIO="$(echo ${TF[0]} | cut -d: -f1)"
PACKET="$(echo ${TF[1]} | cut -d: -f1)"
VERBOSE="$(echo ${TF[2]} | cut -d: -f1)"
HEX="$(echo ${TF[3]} | cut -d: -f1)"

for P in $(pgrep $(command -v pmon))
do
	sudo kill -9 $P
done

configAlsa
$(command -v pasuspender) -- $(command -v pmon) -a pmon-$AUDIO -p $PACKET -v $VERBOSE -h $HEX
rm $HOME/.asoundrc
[ -f $HOME/.asoundrc-backup ] && mv $HOME/.asoundrc-backup $HOME/.asoundrc
