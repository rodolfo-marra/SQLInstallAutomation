#
# SQL Server Installation Script
#
# Script tasks:
# 1- Verify if there is SQL Server instance running.
# 2- Install SQL Server 2014 STD x64 with "SPConfigurationFile.ini"
#    Principal parameters:
#    - Action: Install
#    - UpdateSource: .\SQL-Updates
#    - InstanceName: SHAREPOINT
#    - InstanceID: SHAREPOINT
#    - ASCollation: Latin1_General_CI_AS
#    - SQLSysAdminAccounts: Defined by parameters (SQL Server Sysadmin)
#    - ASSysAdminAccounts: Defined by parameters (SQL Server Analysis Server Sysadmin)
#    - SQLSVCACCOUNT: Defined by parameters (SQL Server Services)
#    - AGTSVCACCOUNT: Defined by parameters (SQL Agent Services)
#    - ASSVCACCOUNT: Defined by parameters (SQL Server Analysis Services)
#    - FTSVCACCOUNT: NT Service\MSSQLFDLauncher$SHAREPOINT (SQL Full-text Filter Daemon Launcher)
#    - Features: SQLENGINE,FULLTEXT,AS,RS_SHP,RS_SHPWFE,SSMS,ADV_SSMS
#       - SQLENGINE - SQL Server Database Engine
#       - FULLTEXT - FullText component along with SQL Server Database Engine
#       - AS - Analysis Services components
#       - RS_SHP - Reporting Services components for SharePoint
#       - RS_SHPWFE - Reporting Services Add-In for SharePoint products
#       - SSMS - SQL Server Management Tools
#       - ADV_SSMS - SQL Server Management Tools - Advanced features
# 3- Verify if SQL Server is running.
#
# Command structure: 
# .\2-SQLInstallation.ps1 [-SQLSYSADMINACCOUNTS] <string> [-ASSYSADMINACCOUNTS] <string> [-SQLSVCACCOUNT] <string> [-SQLSVCPASSWORD] <string> [-AGTSVCACCOUNT] <string> [-AGTSVCPASSWORD] <string> [-ASSVCACCOUNT] <string> [-ASSVCPASSWORD] <string> [[-Path] <string>] [<CommonParameters>]
# 
# Command parameters:
# -SQLSYSADMINACCOUNTS [mandatory] : SQL Server SysAdmin domain group that will be used in SQL Server installation. For exemple: Contoso\GRP-ADM-SQL
# -ASSYSADMINACCOUNTS [mandatory] : SQL Analysis Server SysAdmin domain group that will be used in SQL Server installation. For exemple: Contoso\GRP-ADM-SQL
# -SQLSVCACCOUNT [mandatory] : SQL Service domain user that will be used in SQL Server installation. For exemple: Contoso\adm-sql
# -SQLSVCPASSWORD [mandatory] : SQL Service domain user password that will be used in SQL Server installation.
# -AGTSVCACCOUNT [mandatory] : SQL Agent Service domain user that will be used in SQL Server installation. For exemple: Contoso\adm-sql
# -AGTSVCPASSWORD [mandatory] : SQL Agent Service domain user password that will be used in SQL Server installation.
# -ASSVCACCOUNT [mandatory] : SQL Analysis Service domain user that will be used in SQL Server installation. For exemple: Contoso\adm-sql
# -ASSVCPASSWORD [mandatory] : SQL Analysis Service domain user password that will be used in SQL Server installation.
# -Path [optional] : Path location for automation and SQL Server files. For exemple: C:\Automation
# 
# Command exemples:
# Without define Path location:
# .\2-SQLInstallation.ps1 -SQLSYSADMINACCOUNTS Contoso\GRP-ADM-SQL -ASSYSADMINACCOUNTS Contoso\GRP-ADM-SQL -SQLSVCACCOUNT Contoso\adm-sql -SQLSVCPASSWORD P@ssw0rd -AGTSVCACCOUNT Contoso\adm-sql -AGTSVCPASSWORD P@ssw0rd -ASSVCACCOUNT Contoso\adm-sql -ASSVCPASSWORD P@ssw0rd
#
# Define Path location:
# .\2-SQLInstallation.ps1 -SQLSYSADMINACCOUNTS Contoso\GRP-ADM-SQL -ASSYSADMINACCOUNTS Contoso\GRP-ADM-SQL -SQLSVCACCOUNT Contoso\adm-sql -SQLSVCPASSWORD P@ssw0rd -AGTSVCACCOUNT Contoso\adm-sql -AGTSVCPASSWORD P@ssw0rd -ASSVCACCOUNT Contoso\adm-sql -ASSVCPASSWORD P@ssw0rd -Path C:\Automation
#


# Custom parameters
[CmdletBinding()]
param (
    [Parameter(Mandatory=$True, HelpMessage="Input SQL Server SysAdmin domain group that will be used in SQL Server installation.`nFor exemple: Contoso\GRP-ADM-SQL`n")][ValidateNotNullOrEmpty()][string]$SQLSYSADMINACCOUNTS = $( Read-Host "Input SQL Sys Admin domain group, eg: Contoso\GRP-ADM-SQL" ),
    [Parameter(Mandatory=$True, HelpMessage="Input SQL Analysis Server SysAdmin domain group that will be used in SQL Server installation.`nFor exemple: Contoso\GRP-ADM-SQL`n")][ValidateNotNullOrEmpty()][string]$ASSYSADMINACCOUNTS = $( Read-Host "Input SQL Sys Admin domain group, eg: Contoso\GRP-ADM-SQL" ),
    
    [Parameter(Mandatory=$True, HelpMessage="Input SQL Service domain user that will be used in SQL Server installation.`nFor exemple: Contoso\adm-sql`n")][ValidateNotNullOrEmpty()][string]$SQLSVCACCOUNT = $( Read-Host "Input SQL Service domain user, eg: Contoso\adm-sql" ),
    [Parameter(Mandatory=$True, HelpMessage="Input SQL Service domain user password that will be used in SQL Server installation.`n")][ValidateNotNullOrEmpty()][string]$SQLSVCPASSWORD = $( Read-Host "Input SQL Service domain user password" ),

    [Parameter(Mandatory=$True, HelpMessage="Input SQL Agent Service domain user that will be used in SQL Server installation.`nFor exemple: Contoso\adm-sql`n")][ValidateNotNullOrEmpty()][string]$AGTSVCACCOUNT = $( Read-Host "Input SQL Agent Service domain user, eg: Contoso\adm-sql" ),
    [Parameter(Mandatory=$True, HelpMessage="Input SQL Agent Service domain user password that will be used in SQL Server installation.`n")][ValidateNotNullOrEmpty()][string]$AGTSVCPASSWORD = $( Read-Host "Input SQL Agent Service domain user password" ),

    [Parameter(Mandatory=$True, HelpMessage="Input SQL Analysis Service domain user that will be used in SQL Server installation.`nFor exemple: Contoso\adm-sql`n")][ValidateNotNullOrEmpty()][string]$ASSVCACCOUNT = $( Read-Host "Input SQL Analysis Service domain user, eg: Contoso\adm-sql" ),
    [Parameter(Mandatory=$True, HelpMessage="Input SQL Analysis Service domain user password that will be used in SQL Server installation.`n")][ValidateNotNullOrEmpty()][string]$ASSVCPASSWORD = $( Read-Host "Input SQL Analysis Service domain user password" ),
    [string]$Path = "C:\Automation"
 )

# Parameters
Set-Location $Path
Write-Output "[SQL SERVER INSTALLATION SCRIPT]"
Write-Host "`nCustom Parameters:"
Write-Host "SQLSYSADMINACCOUNTS: $SQLSYSADMINACCOUNTS`nASSYSADMINACCOUNTS: $ASSYSADMINACCOUNTS`nSQLSVCACCOUNT: $SQLSVCACCOUNT`nAGTSVCACCOUNT: $AGTSVCACCOUNT`nASSVCACCOUNT: $ASSVCACCOUNT`nPath: $Path"

# Verify if SQL Server is running
Write-Host "`n1- VERIFYING SQL SERVER INSTALLATION..."
$sqlInstances = gwmi win32_service -computerName localhost | ? { $_.displayname -notmatch "Windows Internal Database" -and $_.Name -match "mssql*" -and $_.PathName -match "sqlservr.exe" } | % { $_.Caption }
$res = $sqlInstances -ne $null -and $sqlInstances -gt 0
if ($res) {
    Write-Host "SQL Server is already installed." -ForegroundColor Green
}
else {
    Write-Host "SQL Server is not installed. Installing..." -ForegroundColor Yellow
    # Install SQL Server "SPConfigurationFile.ini" in silent mode
    .\SQL\setup.exe /ConfigurationFile=.\SQL\SPConfigurationFile.ini /SQLSYSADMINACCOUNTS=$SQLSYSADMINACCOUNTS /ASSYSADMINACCOUNTS=$ASSYSADMINACCOUNTS /SQLSVCACCOUNT=$SQLSVCACCOUNT /SQLSVCPASSWORD=$SQLSVCPASSWORD /AGTSVCACCOUNT=$AGTSVCACCOUNT /AGTSVCPASSWORD=$AGTSVCPASSWORD /ASSVCACCOUNT=$ASSVCACCOUNT /ASSVCPASSWORD=$ASSVCPASSWORD
    
    # Verify if SQL Server is running
    $sqlInstances = gwmi win32_service -computerName localhost | ? { $_.displayname -notmatch "Windows Internal Database" -and $_.Name -match "mssql*" -and $_.PathName -match "sqlservr.exe" } | % { $_.Caption }
    $res = $sqlInstances -ne $null -and $sqlInstances -gt 0
    if ($res) {
        Write-Host "SQL Server was installed." -ForegroundColor Green
    }
    else {
        Write-Host "[ERROR] SQL Server is not installed! Run this script again..." -ForegroundColor Red
    }
}
Write-Host "`n[SCRIPT FINISHED...]"
Write-Host "`nSQL Server 2014 is installed and running. You can install SharePoint 2016 now!`n"
Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
