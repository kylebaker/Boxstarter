# Description: Boxstarter Script to setup internally used computers
# Author: Kyle Baker
# For: Aquaveo
# Referencing heavily from: https://github.com/Microsoft/windows-dev-box-setup-scripts/
# and
# Referenceing heavily from: https://github.com/fireeye/commando-vm


# The following is needed to take the input string from the batch file
# and put it into a variable string that we can then use to set as the
# current working directory

param(
        [Parameter(
                    Mandatory=$true,
                    Position=0,
                    HelpMessage='Set path variable')]
        [string] $w
)

# Sets the current directory to the input above

set-location $w

# This function installs BoxStarter

function installBoxStarter()
{
  <#
  .SYNOPSIS
  Install BoxStarter on the current system  
  .DESCRIPTION
  Install BoxStarter on the current system. Returns $true or $false to indicate success or failure. On
  fresh windows 7 systems, some root certificates are not installed and updated properly. Therefore,
  this funciton also temporarily trust all certificates before installing BoxStarter.  
  #>  
  # https://stackoverflow.com/questions/11696944/powershell-v3-invoke-webrequest-https-error
  # Allows current PowerShell session to trust all certificates
  # Also a good find: https://www.briantist.com/errors/could-not-establish-trust-relationship-for-the-ssltls-secure-channel/
  try {
  Add-Type @"
  using System.Net;
  using System.Security.Cryptography.X509Certificates;
  public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
  }
"@
  } catch {
    Write-Debug "Failed to add new type"
  }  
  try {
    $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
  } catch {
    Write-Debug "Failed to find SSL type...1"
  }  
  try {
    $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls'
  } catch {
    Write-Debug "Failed to find SSL type...2"
  }  
  $prevSecProtocol = [System.Net.ServicePointManager]::SecurityProtocol
  $prevCertPolicy = [System.Net.ServicePointManager]::CertificatePolicy  
  Write-Host "[ * ] Installing Boxstarter"
  # Become overly trusting
  [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
  [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy  
  # download and instal boxstarter
  iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1')); get-boxstarter -Force  
  # Restore previous trust settings for this PowerShell session
  # Note: SSL certs trusted from installing BoxStarter above will be trusted for the remaining PS session
  [System.Net.ServicePointManager]::SecurityProtocol = $prevSecProtocol
  [System.Net.ServicePointManager]::CertificatePolicy = $prevCertPolicy
  return $true
}

Write-Host "[+] Beginning install..."
Write-Host " ____________________________________________________________________________ " -ForegroundColor Red 
Write-Host "|                                                                            |" -ForegroundColor Red 
Write-Host "|               "  -ForegroundColor Red -NoNewline; Write-Host "                  " -ForegroundColor Green -NoNewline; Write-Host "                                           |" -ForegroundColor Red 
Write-Host "|               "  -ForegroundColor Red -NoNewline; Write-Host "  ____        _             _    " -ForegroundColor Green -NoNewline; Write-Host "                            |" -ForegroundColor Red 
Write-Host "|               "  -ForegroundColor Red -NoNewline; Write-Host " |  _ \      | |           ( )   " -ForegroundColor Green -NoNewline; Write-Host "                            |" -ForegroundColor Red 
Write-Host "|               "  -ForegroundColor Red -NoNewline; Write-Host " | |_) | __ _| | _____ _ __|/ ___" -ForegroundColor Green -NoNewline; Write-Host "                            |" -ForegroundColor Red 
Write-Host "|               "  -ForegroundColor Red -NoNewline; Write-Host " |  _ < / _' | |/ / _ \ '__| / __|" -ForegroundColor Green -NoNewline; Write-Host "                           |" -ForegroundColor Red 
Write-Host "|               "  -ForegroundColor Red -NoNewline; Write-Host " | |_) | (_| |   <  __/ |    \__ \" -ForegroundColor Green -NoNewline; Write-Host "                           |" -ForegroundColor Red 
Write-Host "|               "  -ForegroundColor Red -NoNewline; Write-Host " |____/ \__,_|_|\_\___|_|    |___/  _ " -ForegroundColor Green -NoNewline; Write-Host "                       |" -ForegroundColor Red 
Write-Host "|               "  -ForegroundColor Red -NoNewline; Write-Host " |  _ \              | |           | |" -ForegroundColor Green -NoNewline; Write-Host "                       |" -ForegroundColor Red 
Write-Host "|               "  -ForegroundColor Red -NoNewline; Write-Host " | |_) | _____  _____| |_ __ _ _ __| |_ ___ _ __ " -ForegroundColor Green -NoNewline; Write-Host "            |" -ForegroundColor Red 
Write-Host "|               "  -ForegroundColor Red -NoNewline; Write-Host " |  _ < / _ \ \/ / __| __/ _' | '__| __/ _ \ '__|" -ForegroundColor Green -NoNewline; Write-Host "            |" -ForegroundColor Red 
Write-Host "|               "  -ForegroundColor Red -NoNewline; Write-Host " | |_) | (_) >  <\__ \ || (_| | |  | ||  __/ |  " -ForegroundColor Green -NoNewline; Write-Host "             |" -ForegroundColor Red 
Write-Host "|               "  -ForegroundColor Red -NoNewline; Write-Host " |____/ \___/_/\_\___/\__\__,_|_|   \__\___|_|  " -ForegroundColor Green -NoNewline; Write-Host "             |" -ForegroundColor Red 
Write-Host "|                            Pesrsonal AutoInstaller                         |" -ForegroundColor Red 
Write-Host "|                                                                            |" -ForegroundColor Red 
Write-Host "|                                  Version 1.3                               |" -ForegroundColor Red 
Write-Host "|____________________________________________________________________________|" -ForegroundColor Red 
Write-Host "|                                                                            |" -ForegroundColor Red 
Write-Host "|                                  Developed by                              |" -ForegroundColor Red 
Write-Host "|                                   Kyle Baker                               |" -ForegroundColor Red 
Write-Host "|____________________________________________________________________________|" -ForegroundColor Red 
Write-Host ""

# Check to make sure script is run as administrator
Write-Host "[+] Checking if script is running as administrator.."
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )
if (-Not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "`t[ERR] Please run this script as administrator`n" -ForegroundColor Red
  Read-Host  "Press any key to continue"
  exit
}
else {
  Write-Host "`tRuning as Administrator" -ForegroundColor Magenta
}

Write-Host ""
Write-Host "[ * ] Getting installer preference ..."
Write-Host ""
Write-Host "`t1) Desktop Config"
Write-Host "`t2) Laptop Config"
Write-Host "`t3) Intel Nuc Config"
Write-Host ""
Write-Host "`tn/N) No Config installer"

$optionSelected = Read-Host "Which installer would you like to use? (1/2/3/quit/q)"

$package = switch ($optionSelected){
    { '1' -contains $_ }          { "desktop" }
    { '2' -contains $_ }          { "laptop" }
    { '3' -contains $_ }          { "nuc" }
    { 'n', 'N', 'no', 'NO' -contains $_ }          { "noconfig" }
  }

  Write-Host ""
  Write-Host $package
  Write-Host ""


# Get user credentials for autologin during reboots
Write-Host "[ * ] Getting user credentials ..."
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds" -Name "ConsolePrompting" -Value $True


if ([string]::IsNullOrEmpty($password)) {
    $cred=Get-Credential $env:username
} else {
    $spasswd=ConvertTo-SecureString -String $password -AsPlainText -Force
    $cred=New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $env:username, $spasswd
}

# Install Boxstarter
Write-Host "[ * ] Installing Boxstarter"
try {
  iex ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1')); get-boxstarter -Force
} catch {
  $rc = installBoxStarter
  if (-Not $rc) {
    Write-Host "[ERR] Failed to install BoxStarter"
    Read-Host  "      Press ANY key to continue..."
    exit
  }
}

# Boxstarter options
$Boxstarter.RebootOk = $true    # Allow reboots?
$Boxstarter.NoPassword = $false # Is this a machine with no login password?
$Boxstarter.AutoLogin = $true   # Save my password securely and auto-login after a reboot

# Make a new direcotry for where the packages will be placed once made
# Used this stite for the following section:
# https://www.powershelladmin.com/wiki/Powershell_check_if_folder_exists

if (-not (Test-Path -LiteralPath C:\packages)){
  try {
    New-Item -Path C:\packages -ItemType Directory -ErrorAction Stop | Out-Null #-Force
  }
  catch {
    Write-Error -Message "Unable to create directory C:\packages. Error was $_" -ErrorAction Stop
  }
  "Successfully created directory C:\packages"
}
else {
  "Directory C:\packages already existed"
}

Set-BoxstarterConfig -LocalRepo "C:\packages\"

# Needed for many applications
iex "cinst -y powershell"

# Make the pacakges and place them in the directory created above

iex "choco pack installer\$package.nuspec --outputdirectory C:\packages\"

# Start the Boxstarter install

choco config set cacheLocation ${Env:TEMP}
Install-BoxstarterPackage -PackageName $package -Credential $cred