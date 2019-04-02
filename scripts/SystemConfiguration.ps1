# Taken direclty from: https://github.com/Microsoft/windows-dev-box-setup-scripts/blob/master/scripts/SystemConfiguration.ps1

#--- Enable developer mode on the system ---
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1