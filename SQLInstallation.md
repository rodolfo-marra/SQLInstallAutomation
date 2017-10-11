# SQLInstallation script description
Deploy SQL Server 2014 customized instances for SharePoint 2016.

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
