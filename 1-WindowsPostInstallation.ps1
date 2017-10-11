#
# Windows Post-Installation Script
#
# Script tasks:
# 1- Verify if Windows Feature NetFramework35Core is installed (if not, force install).
# 2- Verify if Windows Feature NetFramework45Core is installed (if not, force install).
# 3- Verify if Net Framework 4.7 update is installed (if not, force install).
# 4- Verify if domain group "Contoso\GRP-ADM-SQL" is member of "BUILTIN\Administrators" group (if not, force add).
#
# Command structure: 
# .\1-WindowsPostInstallation.ps1 [-Domain] <string> [-DomainGroup] <string> [[-Path] <string>] [<CommonParameters>]
# 
# Command parameters:
# -Domain [mandatory] : AD Domain where admin group is located. For exemple: Contoso
# -DomainGroup [mandatory] : AD Group that will be added to local admin group. For exemple: GRP-ADM-SQL
# -Path [optional] : Path location for automation and SQL Server files. For exemple: C:\Automation
#
# Command exemples:
# Without define Path location:
# .\1-WindowsPostInstallation.ps1 -Domain Contoso -DomainGroup GRP-ADM-SQL
#
# Define Path location:
# .\1-WindowsPostInstallation.ps1 -Domain Contoso -DomainGroup GRP-ADM-SQL -Path C:\Automation
#
 
# Custom parameters
[CmdletBinding()]
param (
    [Parameter(Mandatory=$True, HelpMessage="Input AD domain where admin group is located.`nFor exemple: Contoso`n")][ValidateNotNullOrEmpty()][string]$Domain = $( Read-Host "Input AD domain, eg. Contoso" ),
    [Parameter(Mandatory=$True, HelpMessage="Input AD Group that will be added to local admin group.`nFor exemple: GRP-ADM-SQL`n")][ValidateNotNullOrEmpty()][string]$DomainGroup = $( Read-Host "Input AD Group that will be added to local admin group, eg. GRP-ADM-SQL" ),
    [string]$Path = "C:\Automation"
 )

# Parameters
$DomainGroupString = "*" + $DomainGroup + "*"
$AdminGroupMemberList = $null
$Check = $null
Set-Location $Path
Write-Host "[WINDOWS POST-INSTALLATION SCRIPT]"
Write-Host "`nCustom Parameters:"
Write-Host "AD Domain: $Domain`nDomain Group: $domaingroup`nPath: $Path"

# Get domain credentials
#$Credentials = Get-Credential "canadasii\adm-sql"

# Verifying prerequisites
Write-Host "`n1- VERIFYING PREREQUISITES..."

# Verify if Windows Feature NetFramework35Core is installed (if not, force install)
$Net35 = $null
$Net35 = Get-WindowsFeature *NET-Framework-Core*
if ($Net35.Installed -eq "True"){
    Write-Host "The Windows Feature '.NET Framework 3.5' is already installed." -ForegroundColor Green
}
else{
    Write-Host "The Windows Feature '.NET Framework 3.5' is not installed. Installing..." -ForegroundColor Yellow
    Install-WindowsFeature -Name NET-Framework-Core
    Write-Host "The Windows Feature '.NET Framework 3.5' was installed." -ForegroundColor Green
}

# Verify if Windows Feature NetFramework45Core is installed (if not, force install)
$Net45 = $null
$Net45 = Get-WindowsFeature *NET-Framework-45-Features*
if ($Net45.Installed -eq "True"){
    Write-Host "The Windows Feature '.NET Framework 4.5' is already installed." -ForegroundColor Green
}
else{
    Write-Host "The Windows Feature '.NET Framework 4.5' is not installed. Installing..." -ForegroundColor Yellow
    Install-WindowsFeature -Name NET-Framework-Core
    Write-Host "The Windows Feature '.NET Framework 4.5' was installed." -ForegroundColor Green
}

# Verify if Net Framework 4.7 is installed (if not, force install).
$Net47 = $null
$ComputerName = $env:COMPUTERNAME
$dotNetRegistry  = 'SOFTWARE\Microsoft\NET Framework Setup\NDP'
$dotNet4Registry = 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
$dotNet4Builds = @{
    # Verify if there is a new version in https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
    # If there are newer version, please add after the last version listed above
	30319  = '.NET Framework 4.0'
	378389 = '.NET Framework 4.5'
	378675 = '.NET Framework 4.5.1'
	378758 = '.NET Framework 4.5.1'
	379893 = '.NET Framework 4.5.2' 
	380042 = '.NET Framework 4.5'
	393295 = '.NET Framework 4.6'
	393297 = '.NET Framework 4.6'
	394254 = '.NET Framework 4.6.1'
	394271 = '.NET Framework 4.6.1'
	394802 = '.NET Framework 4.6.2'
	394806 = '.NET Framework 4.6.2'
    460798 = '.NET Framework 4.6.2'
    460805 = '.NET Framework 4.7'
}

foreach($Computer in $ComputerName) {
    $Net47 = @()
	if($regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer)) {
		if ($netRegKey = $regKey.OpenSubKey("$dotNetRegistry")) {
			foreach ($versionKeyName in $netRegKey.GetSubKeyNames()) {
				if ($versionKeyName -match '^v[123]') {
					$versionKey = $netRegKey.OpenSubKey($versionKeyName)
					$version = [version]($versionKey.GetValue('Version', ''))
					$Net47 += New-Object -TypeName PSObject -Property @{
						ComputerName = $Computer
						NetFXBuild = $version.Build
						NetFXVersion = '.NET Framework ' + $version.Major + '.' + $version.Minor
					} | Select-Object ComputerName, NetFXVersion, NetFXBuild
				}
			}
		}

		if ($net4RegKey = $regKey.OpenSubKey("$dotNet4Registry")) {
			if(-not ($net4Release = $net4RegKey.GetValue('Release'))) {
				$net4Release = 30319
			}
			$Net47 += New-Object -TypeName PSObject -Property @{
				ComputerName = $Computer
				NetFXBuild = $net4Release
				NetFXVersion = $dotNet4Builds[$net4Release]
			} | Select-Object ComputerName, NetFXVersion, NetFXBuild
		}
	}
}

if ($Net47.NetFXVersion -eq ".NET Framework 4.7"){
    Write-Host "The update '.NET Framework 4.7' is already installed." -ForegroundColor Green
}
else {
    Write-Host "The update'.NET Framework 4.7' is not installed. Installing..." -ForegroundColor Yellow
    Start-Process -FilePath ".\WS-Updates\NDP47-KB3186497-x86-x64-AllOS-ENU.exe" -ArgumentList "/q /norestart /Log ""${Env:TEMP}\${packageName}.log""" -Wait
    Write-Host "The update '.NET Framework 4.7' was installed." -ForegroundColor Green
}

# Verify if domain group is member of "BUILTIN\Administrators" group (if not, force add).
$AdminGroupMemberList = Get-LocalGroupMember -Group "Administrators"
foreach($Member in $AdminGroupMemberList){
    if ($Member.name -like $DomainGroupString){ 
        $Check = $True
    }
}
if ($Check -eq $True){
    Write-Host "The domain group '$DomainGroup' is already added to BUILTIN\Administrator group." -ForegroundColor Green
}
else{
    # Add domain group in BUILTIN\Administrators
    Write-Host "The domain group '$DomainGroup' is not added to BUILTIN\Administrator group. Adding..." -ForegroundColor Yellow
    Add-LocalGroupMember -Group "Administrators" -Member "$Domain\$DomainGroup"
    Write-Host "The domain group '$DomainGroup' was added to BUILTIN\Administrator group." -ForegroundColor Green
} 
Write-Host "`n[SCRIPT FINISHED...]"
Write-Host "`nAll prerequisites are installed. You can install SQL Server 2014 now!`n"
Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
