# SQLInstallAutomation description
PowerShell script for automate the deployment of prerequisites and parametrized SQL Server 2014 for SharePoint 2016.

# Prerequisites:
1) Create a new server with Windows Server 2016.
2) Install all available Windows Update.
3) Download SQLInstallAutomation files from GitHub.
4) Create the folder "C:\Automation"
5) Create te sub-folder "SQL" inside "C:\Automation"
6) Create te sub-folder "SQL-Updates" inside ".\Automation\SQL"
7) Create te sub-folder "SP" inside "C:\Automation"
8) Create te sub-folder "WS-Updates" inside "C:\Automation"
9) Put file "1-WindowsPostInstallation.ps1" in "C:\Automation"
10) Put file "2-SQLInstallation.ps1" in "C:\Automation"

# "1-WindowsPostInstallation.ps1" script tasks:
1) Verify if Windows Feature NetFramework35Core is installed (if not, force install).
2) Verify if Windows Feature NetFramework45Core is installed (if not, force install).
3) Verify if Net Framework 4.7 update is installed (if not, force install).
4) Verify if domain group "Contoso\GRP-ADM-SQL" is member of "BUILTIN\Administrators" group (if not, force add).

# "2-SQLInstallation.ps1" script tasks:
1) Verify if there is SQL Server instance running.
2) Install SQL Server 2014 STD x64 with "SPConfigurationFile.ini"
3) Verify if SQL Server is running.

## Principal parameters defined in SPConfigurationFile.ini:
- Action: Install
- UpdateSource: .\SQL-Updates
- InstanceName: SHAREPOINT
- InstanceID: SHAREPOINT
- ASCollation: Latin1_General_CI_AS
- SQLSysAdminAccounts: Defined by parameters (SQL Server Sysadmin)
- ASSysAdminAccounts: Defined by parameters (SQL Server Analysis Server Sysadmin)
- SQLSVCACCOUNT: Defined by parameters (SQL Server Services)
- AGTSVCACCOUNT: Defined by parameters (SQL Agent Services)
- ASSVCACCOUNT: Defined by parameters (SQL Server Analysis Services)
- FTSVCACCOUNT: NT Service\MSSQLFDLauncher$SHAREPOINT (SQL Full-text Filter Daemon Launcher)
- Features: SQLENGINE,FULLTEXT,AS,RS_SHP,RS_SHPWFE,SSMS,ADV_SSMS
- SQLENGINE - SQL Server Database Engine
- FULLTEXT - FullText component along with SQL Server Database Engine
- AS - Analysis Services components
- RS_SHP - Reporting Services components for SharePoint
- RS_SHPWFE - Reporting Services Add-In for SharePoint products
- SSMS - SQL Server Management Tools
- ADV_SSMS - SQL Server Management Tools - Advanced features

# Command structure: 
.\2-SQLInstallation.ps1 [-SQLSYSADMINACCOUNTS] <string> [-ASSYSADMINACCOUNTS] <string> [-SQLSVCACCOUNT] <string> [-SQLSVCPASSWORD] <string> [-AGTSVCACCOUNT] <string> [-AGTSVCPASSWORD] <string> [-ASSVCACCOUNT] <string> [-ASSVCPASSWORD] <string> [[-Path] <string>] [<CommonParameters>]

# Command parameters:
- -SQLSYSADMINACCOUNTS [mandatory] : SQL Server SysAdmin domain group that will be used in SQL Server installation. For exemple: Contoso\GRP-ADM-SQL
- -ASSYSADMINACCOUNTS [mandatory] : SQL Analysis Server SysAdmin domain group that will be used in SQL Server installation. For exemple: Contoso\GRP-ADM-SQL
- -SQLSVCACCOUNT [mandatory] : SQL Service domain user that will be used in SQL Server installation. For exemple: Contoso\adm-sql
- -SQLSVCPASSWORD [mandatory] : SQL Service domain user password that will be used in SQL Server installation.
- -AGTSVCACCOUNT [mandatory] : SQL Agent Service domain user that will be used in SQL Server installation. For exemple: Contoso\adm-sql
- -AGTSVCPASSWORD [mandatory] : SQL Agent Service domain user password that will be used in SQL Server installation.
- -ASSVCACCOUNT [mandatory] : SQL Analysis Service domain user that will be used in SQL Server installation. For exemple: Contoso\adm-sql
- -ASSVCPASSWORD [mandatory] : SQL Analysis Service domain user password that will be used in SQL Server installation.
- -Path [optional] : Path location for automation and SQL Server files. For exemple: C:\Automation

# Command exemples:
Without define Path location:
.\2-SQLInstallation.ps1 -SQLSYSADMINACCOUNTS Contoso\GRP-ADM-SQL -ASSYSADMINACCOUNTS Contoso\GRP-ADM-SQL -SQLSVCACCOUNT Contoso\adm-sql -SQLSVCPASSWORD P@ssw0rd -AGTSVCACCOUNT Contoso\adm-sql -AGTSVCPASSWORD P@ssw0rd -ASSVCACCOUNT Contoso\adm-sql -ASSVCPASSWORD P@ssw0rd

Define Path location:
.\2-SQLInstallation.ps1 -SQLSYSADMINACCOUNTS Contoso\GRP-ADM-SQL -ASSYSADMINACCOUNTS Contoso\GRP-ADM-SQL -SQLSVCACCOUNT Contoso\adm-sql -SQLSVCPASSWORD P@ssw0rd -AGTSVCACCOUNT Contoso\adm-sql -AGTSVCPASSWORD P@ssw0rd -ASSVCACCOUNT Contoso\adm-sql -ASSVCPASSWORD P@ssw0rd -Path C:\Automation
