# Description: Boxstarter Script to setup internally used computers
# Author: Kyle Baker
# For: Aquaveo
# Referencing heavily from: https://github.com/Microsoft/windows-dev-box-setup-scripts/blob/master/dev_app_desktop_.NET.ps1


#This allows boxstarter/chocolatey to run commands without being interrupted
Disable-UAC

# Get the base URI path from the ScriptToCall value
$bstrappackage = "-bootstrapPackage"
$helperUri = $Boxstarter['ScriptToCall']
$strpos = $helperUri.IndexOf($bstrappackage)
$helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
$helperUri = $helperUri.TrimStart("'", " ")
$helperUri = $helperUri.TrimEnd("'", " ")
$helperUri = $helperUri.Substring(0, $helperUri.LastIndexOf("/"))
$helperUri += "/scripts"
write-host "helper script base URI is $helperUri"

function executeScript {
    Param ([string]$script)
    write-host "executing $helperUri/$script ..."
    iex ((new-object net.webclient).DownloadString("$helperUri/$script"))
}



#--- Setting Up Windows ---
# These are the scripts that are to be used. They are modular and if you don't need one, comment the line out.

#stock. Should not change
executeScript "FileExplorerSettings.ps1";
executeScript "SystemConfiguration.ps1";
executeScript "RemoveDefaultApps.ps1";


#executeScript "WSL.ps1";
executeScript "Developer.ps1";
#executeScript "EssentialApps.ps1";


#--- reenabling critial items ---

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
if (Test-PendingReboot) { Invoke-Reboot }

# Remove desktop.ini files
Get-ChildItem -Path (Join-Path ${Env:UserProfile} "Desktop") -Hidden -Filter "desktop.ini" -Force | foreach {$_.Delete()}
Get-ChildItem -Path (Join-Path ${Env:Public} "Desktop") -Hidden -Filter "desktop.ini" -Force | foreach {$_.Delete()}
