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
