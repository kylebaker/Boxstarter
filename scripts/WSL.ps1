#Referenced heavily from: https://github.com/Microsoft/windows-dev-box-setup-scripts/blob/master/scripts/WSL.ps1

write-host "Pre install of WSL"

choco install -y Microsoft-Windows-Subsystem-Linux -source windowsfeatures

write-host "Post install of WSL"

#--- Ubuntu ---
# TODO: Move this to choco install once --root is included in that package

write-host "Pre invoke of webrequest"

if (Test-PendingReboot) { Invoke-Reboot }

Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile ~/Ubuntu.appx -UseBasicParsing

write-host "Post invoke of webrequest"
write-host "Pre add of package add"

Add-AppxPackage -Path ~/Ubuntu.appx
if (Test-PendingReboot) { Invoke-Reboot }

write-host "post add of package add"
# run the distro once and have it install locally with root user, unset password

write-host "Pre updating ubu"

write-host "RefreshEnv"
RefreshEnv
write-host "Ubuntu1804 install --root"
Ubuntu1804 install --root
write-host "Ubuntu1804 run apt update"
Ubuntu1804 run apt update
write-host "Ubuntu1804 run apt upgrade -y"
Ubuntu1804 run apt upgrade -y

write-host "post updating ubu"