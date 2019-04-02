# Description: Testing Boxstarter
# Author: Kyle Baker
# For: Aquaveo
# Referencing heavily from: https://github.com/Microsoft/windows-dev-box-setup-scripts/blob/master/dev_app_desktop_.NET.ps1

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

executeScript "FileExplorerSettings.ps1";
if (Test-PendingReboot) { Invoke-Reboot }
executeScript "SystemConfiguration.ps1";
if (Test-PendingReboot) { Invoke-Reboot }
executeScript "Browsers.ps1";
if (Test-PendingReboot) { Invoke-Reboot }
executeScript "RemoveDefaultApps.ps1";
executeScript "WSL.ps1";
executeScript "Browsers.ps1";
if (Test-PendingReboot) { Invoke-Reboot }

#--- reenabling critial items ---

Enable-UAC
Invoke-Reboot
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula