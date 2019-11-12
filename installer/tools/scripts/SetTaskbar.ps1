#### Pin Items to Taskbar ####
Write-Host "[-] Pinning items to Taskbar" -ForegroundColor Green

# Powershell
$target_file = Join-Path (Join-Path ${Env:WinDir} "system32\WindowsPowerShell\v1.0") "powershell.exe"
$target_dir = ${Env:UserProfile}
$target_args = '-NoExit -Command "cd ' + "${Env:UserProfile}" + '"'
$shortcut = Join-Path ${Env:UserProfile} "temp\PowerShell.lnk"
Install-ChocolateyShortcut -shortcutFilePath $shortcut -targetPath $target_file -Arguments $target_args -WorkingDirectory $target_dir -PinToTaskbar -RunasAdmin
try {
  PinToTaskbar $shortcut
} catch {
  Write-Host "Could not pin $target_file to the tasbar"
}
# Explorer
$target_file = Join-Path ${Env:WinDir} "explorer.exe"
try {
  PinToTaskbar $target_file
} catch {
  Write-Host "Could not pin $target_file to the tasbar"
}