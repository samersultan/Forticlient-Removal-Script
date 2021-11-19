$list = Get-WmiObject Win32_Product

for($i=0; $i -lt $list.Count; $i++){
    if($list[$i].name -eq "FortiClient VPN"){
    msiexec /uninstall '$list[$i].IdentifyingNumber' /norestart /quiet
    }
}
