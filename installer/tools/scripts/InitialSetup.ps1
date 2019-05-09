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