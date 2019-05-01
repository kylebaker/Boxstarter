$ErrorActionPreference = 'Continue'

Import-Module Boxstarter.Chocolatey
Import-Module "$($Boxstarter.BaseDir)\Boxstarter.Common\boxstarter.common.psd1"

$packageName      = 'installer'
$toolsDir         = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$cache            =  "$env:userprofile\AppData\Local\ChocoCache"
$globalCinstArgs  = "--cacheLocation $cache -y"


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
}

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
  executeScript "FileExplorerSettings.ps1";
  executeScript "SystemConfiguration.ps1";
  executeScript "RemoveDefaultApps.ps1";


  #executeScript "WSL.ps1";
  executeScript "Developer.ps1";
  #executeScript "EssentialApps.ps1";

  CleanUp
  return 0
}

Main