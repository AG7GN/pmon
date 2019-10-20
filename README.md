# Hampi scripts supporting PMON - An Independent Pactor/Winlink Monitor For The Raspberry Pi

Version 20191020

## Background

This GitHub repository contains a script and menu item that makes PMON easier to use with the Hampi image.

From the [PMON website](https://www.p4dragon.com/en/PMON.html):

"PMON allows the thorough observation and documentation of all presently available  PACTOR-1/2/3 transmissions (PACTOR-4 will follow in early 2020). PMON covers all PACTOR levels with the appropriate Speedlevels and packet variations. PMON will read in parallel PACTOR-2 and PACTOR-1. The very wide receiving range (frequency offset ±200 Hz), as well as the automatic sideband recognition, ease routine operation of PMON with PACTOR-2 and PACTOR-3 considerably.

PMON automatically decompresses LZHUF compressed messages on the fly. This is very useful for monitoring Winlink email transfers."


## Prerequisites

- Raspberry Pi 3B, 3B+ or 4 (NOTE: I have only tested this image with 3B and 3B+.) running the Hampi image

## Installation 

Pick either Easy or Manual Installation below.

### Easy Installation (Hampi Only)

1. Click __Raspberry > Hamradio > Update Pi and Ham Apps__.
1. Check __pmon__, click __OK__.

### Manual Installation

1. Open a Terminal and run these commands:

	- Run these commands the first time you install `pmon`.  They add the `pmon` repository to your Pi:
	
			echo "deb https://www.scs-ptc.com/repo/packages/ buster non-free" | sudo tee /etc/apt/sources.list.d/scs.list > /dev/null
			wget -q -O - https://www.scs-ptc.com/repo/packages/scs.gpg.key | sudo apt-key add -
			sudo apt update
			sudo apt install pmon
		
	- Thereafter, run these commands to keep `pmon` updated:
	
			sudo apt update
			sudo apt upgrade pmon
			
	- Run these commands the first time you install `pmon` and whenever you want to update the Hampi `pmon` script and menu item:
	
			cd ~
			rm -rf pmon/ 
			git clone https://github.com/AG7GN/pmon  
			sudo cp pmon/*.sh /usr/local/bin/
			sudo cp pmon/pmon.desktop /usr/local/share/applications/
			rm -rf pmon/
         
1. Close the Terminal by clicking __File > Close Window__ or typing `exit` and press __Enter__ in the Terminal window.

## Running `pmon`

1. To run `pmon`, click __Raspberry > Hamradio > PMON__.  Follow the instructions on the screen.

## Operational Notes

`pmon` does not work with PulseAudio, which Hampi uses extensively to support 2 radios with Fldigi and Direwolf and other ham applications.  The `pmon.sh` script in this repository, when used to start `pmon`, temporarily suspends PulseAudio's use of the Fe-Pi sound card, thereby giving `pmon` the exclusive use of the card.  When you quit `pmon`, PulseAudio automatically regains control of the sound card.  

I recommend always starting `pmon` from the menu, and always stop all other applications that use the sound card prior to running `pmon`.

