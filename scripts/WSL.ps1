#Referenced heavily from: https://github.com/Microsoft/windows-dev-box-setup-scripts/blob/master/scripts/WSL.ps1

choco install -y Microsoft-Windows-Subsystem-Linux -source windowsfeatures

Invoke-Reboot

#--- Ubuntu ---
# TODO: Move this to choco install once --root is included in that package
Invoke-WebRequest https://aka.ms/wsl-ubuntu-1804 -out ubuntu.zip -UseBasicParsing
Expand-Archive .\ubuntu.zip
# run the distro once and have it install locally with root user, unset password

RefreshEnv
Ubuntu1804 install --root
Ubuntu1804 run apt update
Ubuntu1804 run apt upgrade -y