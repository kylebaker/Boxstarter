# Boxstarter-Personal

A script desgined to help with setting up my personal windows devices. It's a hybrid of [Windows Dev Box Setup Scripts](https://github.com/Microsoft/windows-dev-box-setup-scripts/) and [Commando VM](https://github.com/fireeye/commando-vm/blob/master/README.md) scripts.

## Installation Instructions

1. Clone this repository
2. Double-click the `install.bat` file
3. UAC will pop up, click yes
4. The script will ask for the user password for reboots, type it
5. Let it run, it'll reboot A LOT before it finishes.

-Sidenote: If you run this off a USB, after the first reboot, you can safely remove the USB without breaking the script. The needed files are saved on the host machine once the first reboot has occured. 

## How it works

This uses [Boxstarter](https://boxstarter.org/) and [Chocolatey](https://chocolatey.org/) in combination to automate the install of windows applications, windows updates and a slew of configuration changes to Windows. The **main.ps1** script gets everything going and I've tried to organize it all to be modular and easy to follow.

## The **.bat** file

To run **main.ps1**, Windows needs to have it's Execution Policy set to Unrestricted. As well, the script needs to be run as Administrator. This requires that you open Powershell and type the commands manually. I didn't like that, so I made this batch file to automate it.

1. It auto sets the Execution Policy to Unrestricted
2. It calls **main.ps1** as Administrator
3. It passes the current working directory to **main.ps1** (otherwise, **main.ps1** thinks it's in C:\Windows\System32\ which breaks the script)

## **main.ps1** Script

Heavily modified from the Commando VM. The **param** grabs the passed current directory from the batch file and sets it as the current working directory. The user will be asked for the windows account password so reboots can happen unattended. Once the initial install is done, the script will reboot and begin the **installer** script

## **installer** Script

This is the main meat of it all. This script is the orchestrartor that calls out on all other scripts as configured by you. The **InitalSetup** is just that, it gets the computer ready for the rest of the scripts (since reboots might default them back to normal). As well, the [Disassembler Script](https://github.com/Disassembler0/Win10-Initial-Setup-Script) that Commando VM uses has been relocated into this section. 

Once the **InitalSetup** is complete, the modular bits of the script are run. You can pick and choose which will run before hand by commenting/uncommenting the lines as needed.

**CleanUp** re-enables the settings that were turned off during the install process (they were needed to make this script autopiolet). It will also do any of the Windows Updates that need to be done and reboot as needed. 

## When the script finishes 

The computer needs to be rebooted once more to allow the clean-up configs above to take effect (else things like UAC are broken). That's it. You are done.