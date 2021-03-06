# Needed to continue on errors
$ErrorActionPreference = 'Continue'

# import the boxstarter bits needed foe the rest of the script
Import-Module Boxstarter.Chocolatey
Import-Module "$($Boxstarter.BaseDir)\Boxstarter.Common\boxstarter.common.psd1"

# Declare some variables we will use later
$packageName      = 'desktop'
$toolsDir         = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$cache            =  "$env:userprofile\AppData\Local\ChocoCache"
$ps1 = Join-Path $toolsDir '\scripts\Win10.ps1'
$psm1 = Join-Path $toolsDir '\scripts\Win10.psm1'
$preset = Join-Path $toolsDir '\scripts\Default.preset'

# Get the base URI path from the ScriptToCall value
$bstrappackage = "-bootstrapPackage"
$helperUri = $Boxstarter['ScriptToCall']
$strpos = $helperUri.IndexOf($bstrappackage)
$helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
$helperUri = $helperUri.TrimStart("'", " ")
$helperUri = $helperUri.TrimEnd("'", " ")
$helperUri += "/tools/scripts"


function executeScript {
    Param ([string]$script)
    write-host "executing $helperUri/$script ..."
    iex "C:\ProgramData\chocolatey\lib\$helperUri\$script"
}


function Main {
  # Script to set up the host computer for the rest of the script after a reboot
  executeScript "InitialSetup.ps1";

  # Script from https://github.com/Disassembler0/Win10-Initial-Setup-Script that removes a ton 
  # of Windows garbage. The default.preset has been edited from the orignal to match my
  # use case.
  powershell.exe -NoProfile -File "$ps1" -include "$psm1" -preset "$preset"

  # stock. Should be used for all configs
  executeScript "SystemConfiguration.ps1";
  executeScript "SetWallpaper.ps1";
  
  # Unique for this package
  executeScript "CapsToCtl.ps1";
  #executeScript "WSL.ps1"; #takes too long. Testing for the moment
  executeScript "desktop.ps1";

  # Re-enables all the stuff that was turned off during autoinstalls and does
  # the rest of the windows updates
  executeScript "CleanUp.ps1";
  Import-StartLayout -LayoutPath "C:\ProgramData\chocolatey\lib\$helperUri\taskbar_main.xml" -MountPath "C:\"

  write-host "Please restart the computer manually so the Clean Up settings applied can take effect"
  return 0
}

Main