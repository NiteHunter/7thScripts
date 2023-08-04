if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")){   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}
$nics_new_friendly = @()
$ips = @()

Add-Type -AssemblyName System.Windows.Forms
$file_dialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{InitialDirectory = [Environment]::GetFolderPath('Desktop')}
$file_path = $file_dialog.ShowDialog()
$csv = Import-Csv -Path $file_dialog.FileName

ForEach($server in $csv){
    if($server.'TLA' -eq $env:COMPUTERNAME){
        if(!($server.'Switch Port'.Contains("/"))){
            $ips += $server
        }
    }
}

ForEach($ip in $ips){
    if(!($nics_new_friendly.Contains($ip.'Network Port'))){
        $nics_new_friendly += $ip.'Network Port'
    }
}

$nics_new_friendly = $nics_new_friendly | Sort-Object

ForEach($nic in $nics_new_friendly){
    ForEach($ip in $ips){
        if($ip.'Network Port' -eq $nic){
            Write-Host "Setting $($nic): $($ip.'IP ADDRESS') $($ip.'GW Full') $($ip.Mask.Replace('/', ''))"
            try{
                New-NetIPAddress -InterfaceAlias $nic -IPAddress $ip.'IP ADDRESS' -DefaultGateway $ip.'GW Full' -PrefixLength $ip.Mask.Replace("/","") -ErrorAction SilentlyContinue | Out-Null
            }catch{
                Write-Error "Failed to Set $($nic)"
            }
        }
    }
}
Read-Host "Press Enter to Terminate..."