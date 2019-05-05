# Needed to continue on errors

$ErrorActionPreference = 'Continue'

# import the boxstarter bits needed foe the rest of the script

Import-Module Boxstarter.Chocolatey
Import-Module "$($Boxstarter.BaseDir)\Boxstarter.Common\boxstarter.common.psd1"

# Declare some variables we will use later

$packageName      = 'installer'
$toolsDir         = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$cache            =  "$env:userprofile\AppData\Local\ChocoCache"
$ps1 = Join-Path $toolsDir '\scripts\Win10.ps1'
$psm1 = Join-Path $toolsDir '\scripts\Win10.psm1'
$preset = Join-Path $toolsDir '\scripts\Default.preset'

function InitialSetup {
  # Basic system setup
  Update-ExecutionPolicy Unrestricted
  Set-WindowsExplorerOptions -EnableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowHiddenFilesFoldersDrives
  Disable-MicrosoftUpdate
  Disable-BingSearch
  Disable-GameBarTips
  Disable-ComputerRestore -Drive ${Env:SystemDrive}

  # Chocolatey setup
  Write-Host "Initializing chocolatey"
  iex "choco feature enable -n allowGlobalConfirmation"
  iex "choco feature enable -n allowEmptyChecksums"

  # Create the cache directory
  New-Item -Path $cache -ItemType directory -Force

  # BoxStarter setup
  Set-BoxstarterConfig -LocalRepo "C:\packages\"

  # Tweak power options to prevent installs from timing out
  & powercfg -change -monitor-timeout-ac 0 | Out-Null
  & powercfg -change -monitor-timeout-dc 0 | Out-Null
  & powercfg -change -disk-timeout-ac 0 | Out-Null
  & powercfg -change -disk-timeout-dc 0 | Out-Null
  & powercfg -change -standby-timeout-ac 0 | Out-Null
  & powercfg -change -standby-timeout-dc 0 | Out-Null
  & powercfg -change -hibernate-timeout-ac 0 | Out-Null
  & powercfg -change -hibernate-timeout-dc 0 | Out-Null

  # Script from https://github.com/Disassembler0/Win10-Initial-Setup-Script that removes a ton 
  # of Windows garbage. The default.preset has been edited from the orignal to match our
  # use case.
  powershell.exe -NoProfile -File "$ps1" -include "$psm1" -preset "$preset"
}

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

# Re-enables all the stuff that was turned off during autoinstalls
function CleanUp
{
  Enable-UAC
  Enable-MicrosoftUpdate
  Install-WindowsUpdate -acceptEula
  if (Test-PendingReboot) { Invoke-Reboot }  

  # clean up the cache directory
  Remove-Item $cache -Recurse

  # Remove desktop.ini files
  Get-ChildItem -Path (Join-Path ${Env:UserProfile} "Desktop") -Hidden -Filter "desktop.ini" -Force | foreach {$_.Delete()}
  Get-ChildItem -Path (Join-Path ${Env:Public} "Desktop") -Hidden -Filter "desktop.ini" -Force | foreach {$_.Delete()}
}


function Main {
  InitialSetup

  #stock. Should not change
  executeScript "SystemConfiguration.ps1";
  executeScript "RemoveDefaultApps.ps1";
  

  #Unique for this Aquaveo package
  executeScript "Developer.ps1";

  CleanUp
  return 0
}

Main