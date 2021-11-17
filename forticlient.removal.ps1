$SearchApplicationName = "FortiClient SSLVPN v4.0.2303"
$SearchApplicationVersion = "4.0.2303"
$OutputCodeSuccess = "1"
$OutputCodeFailure = "2"
$UninstallAlreadyRan = 'false'

function Detect-Application 
{
$my_check = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, InstallDate | Where -property displayName -Match $SearchApplicationName
#If program is found ($my_check not null), check for specific version match
    if ($my_check) 
    {
        $versionNumber = $my_check.DisplayVersion
            if ($versionnumber.Equals($SearchApplicationVersion))
            {
                #We wouldn't want to get stuck in a loop, would we? Aborts if we made it here before.
                if ($UninstallAlreadyRan -eq 'true')
                {
                   write-output $OutputCodeFailure
                   exit 2
                }
                else
                {
                    #Program with specific version found. Calling uninstall function.
                    Uninstall-Application
                }
            }
        }
    else
    {
        #Program with specific version isn't installed. Writing output for MEM to pick up.
        write-output $OutputCodeSuccess
        exit 0
    }
}

function Uninstall-Application
{
#Stopping the FortiClient service
Get-Service -DisplayName "FortiClient SSLVPN" | Stop-Service -ErrorAction Ignore

#Force closing running programs
Stop-Process -Name "FortiSSLVPNclient" -Force -ErrorAction Ignore
Stop-Process -Name "FortiSSLVPNdaemon" -Force -ErrorAction Ignore

#This uninstalls 'FortiClient SSLVPN v4.0.2302'
Start-Process msiexec.exe -Wait -ArgumentList '/x {A34DCE59-0004-0000-2303-3F8A9926B752} /qn'

#Cleans up the directory in case it is left behind
Remove-Item -Path "C:\Program Files (x86)\Fortinet\" -Confirm:$false -Recurse -ErrorAction Ignore

#We wouldn't want to get stuck in a loop, would we?
$UninstallAlreadyRan = 'true'

#Re-run application check to make sure it's gone.
Detect-Application
}

#This starts the process. Checks for the application, and, if found, calls the uninstall script block. 
Detect-Application
#We shouldn't get to this point. If we do, error!
write-output $OutputCodeFailure
