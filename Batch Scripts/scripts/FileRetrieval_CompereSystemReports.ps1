##############################
##     Edit values here     ##
##############################

$type = "folder" #folder, file
#$file = "7thSense Data\Additional Folders\Compere (Appdata)\Profiles\Server\logs" #folder or file itself
$file = "7thSense Data\Additional Folders\Compere (Appdata)\SystemReports\" #folder or file itself
$SCPpath = ":/7thApps/compere/bin/SystemReports"
$fileNew = "" #only for file
$pathNew = "C:\Backups & Logs"
$includeServersACT01 = 1
$includeServersACT02 = 0
$includeServersCNJ01 = 0
$includeServersCNJ02 = 0
$includeServersCTL01 = 1
$includeServersDMS01 = 0
$includeServersJUG01 = 1
$includeServersJUG02 = 0

# Path to Plink.exe - update this if necessary!
$plinkPath = "C:\Batch Scripts\"
$sshPort = 22
$sshUser = "root"
$sshPassword = "7thJuggler"

##############################
##       Script Block       ##
##############################

Set-Location $plinkPath
$date = Get-Date -format yyyyMMdd-hhmmss

# ACT01-nn servers
$startHost = 1
$endHost = 28
if ($includeServersACT01 -eq 1) {
    for ($i = $startHost; $i -le $endHost; $i++) {
        $index="{0:d2}" -f $i
        if ($type -eq "folder") {
            $path="$pathNew\$date-FullSystemReport\ACT01-$index\"
            try {   
                Copy-Item "\\ACT01-$index\$file" $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
        if ($type -eq "file") {
            $path="$pathNew\$date-FullSystemReport\ACT01-$index\"
            try {   
                Copy-Item "\\ACT01-$index\$file" "$path\$fileNew" -errorAction 'stop'
                Write-Host "Copied $fileNew to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
    }
}

# ACT02-nn servers
$startHost = 2
$endHost = 2
if ($includeServersACT02 -eq 1) {
    for ($i = $startHost; $i -le $endHost; $i++) {
        $index="{0:d2}" -f $i
        if ($type -eq "folder") {
            $path="$pathNew\$date\ACT02-$index\"
            try {   
                Copy-Item "\\ACT02-$index-FullSystemReport\$file" $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
        if ($type -eq "file") {
            $path="$pathNew\$date-FullSystemReport\ACT02-$index\"
            try {   
                Copy-Item "\\ACT02-$index\$file" "$path\$fileNew" -errorAction 'stop'
                Write-Host "Copied $fileNew to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
    }
}

# CNJ01-nn servers
$startHost = 1
$endHost = 54
if ($includeServersCNJ01 -eq 1) {
    for ($i = $startHost; $i -le $endHost; $i++) {
        $index="{0:d2}" -f $i
        if ($type -eq "folder") {
            $path="$pathNew\$date-FullSystemReport\CNJ01-$index\"
            try {   
                Copy-Item $file $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
        if ($type -eq "file") {
            $path="$pathNew\$date-FullSystemReport\CNJ01-$index\"
            try {   
                Copy-Item $file "$path\$fileNew" -errorAction 'stop'
                Write-Host "Copied $fileNew to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
    }
}

# CNJ02-nn servers
$startHost = 1
$endHost = 4
if ($includeServersCNJ02 -eq 1) {
    for ($i = $startHost; $i -le $endHost; $i++) {
        $index="{0:d2}" -f $i
        if ($type -eq "folder") {
            $path="$pathNew\$date-FullSystemReport\CNJ02-$index\"
            try {   
                Copy-Item $file $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
        if ($type -eq "file") {
            $path="$pathNew\$date-FullSystemReport\CNJ02-$index\"
            try {   
                Copy-Item $file "$path\$fileNew" -errorAction 'stop'
                Write-Host "Copied $fileNew to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
    }
}

# CTL01-nn servers
$startHost = 1
$endHost = 2
if ($includeServersCTL01 -eq 1) {
    for ($i = $startHost; $i -le $endHost; $i++) {
        $index="{0:d2}" -f $i
        if ($type -eq "folder") {
            $path="$pathNew\$date-FullSystemReport\CTL01-$index\"
            try {   
                Copy-Item "\\CTL01-$index\$file" $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to copy from CTL01-$index"
            }
        }
        if ($type -eq "file") {
            $path="$pathNew\$date-FullSystemReport\CTL01-$index\"
            try {   
                Copy-Item "\\CTL01-$index\$file" "$path\$fileNew" -errorAction 'stop'
                Write-Host "Copied $fileNew to $path"
            } catch {
                Write-Host "Failed to copy from CTL01-$index"
            }
        }
    }
}

# DMS01-nn servers
$startHost = 1
$endHost = 2
if ($includeServersDMS01 -eq 1) {
    for ($i = $startHost; $i -le $endHost; $i++) {
        $index="{0:d2}" -f $i
        if ($type -eq "folder") {
            $path="$pathNew\$date-FullSystemReport\DMS01-$index\"
            try {   
                Copy-Item $file $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
        if ($type -eq "file") {
            $path="$pathNew\$date-FullSystemReport\DMS01-$index\"
            try {   
                Copy-Item $file "$path\$fileNew" -errorAction 'stop'
                Write-Host "Copied $fileNew to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
    }
}

# JUG01-nn servers
$startHost = 22
$endHost = 49
$HostValue = 1
if ($includeServersJUG01 -eq 1) {
    for ($i = $startHost; $i -le $endHost; $i++) {
        $index="{0:d2}" -f $HostValue
        $HostValue++
        $j = "10.232.130.$i"
        New-Item -ItemType Directory -Path "C:\Backups & Logs\$date-FullSystemReport\JUG01-$index"
        .\pscp.exe -scp -l root -pw 7thJuggler -r root@$j`:/7thApps/compere/bin/SystemReports "C:/Backups & Logs/$date-FullSystemReport\JUG01-$index"
        # $source = "10.232.130.$i$SCPpath"
        # if ($type -eq "folder") {
        #     $path="$pathNew\$date-FullSystemReport\JUG01-$index\"
        #     try {   
        #         Write-Host $path
        #         Write-Host "$sshUser@$source"
        #         New-Item -ItemType Directory -Path $path
        #         .\pscp.exe -scp -l $sshUser -pw $sshPassword -r "$sshUser@$source" $path
        #         Write-Host "Copied $file to $path"
        #     } catch {
        #         Write-Host "Failed to copy from 10.232.130.$i"
        #     }
        # }
        # if ($type -eq "file") {
        #     $path="$pathNew\$date-FullSystemReport\JUG01-$index\"
        #     try {   
        #         New-Item -ItemType Directory -Path $path
        #         .\pscp.exe -scp -l $sshUser -pw $sshPassword -r "$sshUser@$source" $path
        #         Write-Host "Copied $fileNew to $path"
        #     } catch {
        #         Write-Host "Failed to copy from 10.232.130.$i"
        #     }
        # }
    }
}

# New-Item -ItemType Directory -Path "C:\Backups & Logs\$date-FullSystemReport\JUG01-$index"
# .\pscp.exe -scp -l root -pw 7thJuggler -r root@$i`:/7thApps/compere/bin/SystemReports "C:/Backups & Logs/$date-FullSystemReport\JUG01-$index"