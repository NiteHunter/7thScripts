##############################
##     Edit values here     ##
##############################

$type = "folder" #folder, file
#$file = "7thSense Data\Additional Folders\Compere (Appdata)\Profiles\Server\logs" #folder or file itself
$file = "7thSense Data\Additional Folders\Compere (Appdata)\logs" #folder or file itself
$fileNew = "" #only for file
$pathNew = "C:\Backups & Logs"
$includeServersACT01 = 1
$includeServersACT02 = 1
$includeServersCNJ01 = 0
$includeServersCNJ02 = 0
$includeServersCTL01 = 1
$includeServersDMS01 = 0


##############################
##       Script Block       ##
##############################

$date = Get-Date -format yyyymmdd-hhmmss

# ACT01-nn servers
$startHost = 26
$endHost = 50
if ($includeServersACT01 -eq 1) {
    for ($i = $startHost; $i -le $endHost; $i++) {
        $index="{0:d2}" -f $i
        if ($type -eq "folder") {
            $path="$pathNew\$date\ACT01-$index\"
            try {   
                Copy-Item "\\ACT01-$index\$file" $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
        if ($type -eq "file") {
            $path="$pathNew\$date\ACT01-$index\"
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
                Copy-Item "\\ACT02-$index\$file" $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
        if ($type -eq "file") {
            $path="$pathNew\$date\ACT02-$index\"
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
            $path="$pathNew\$date\CNJ01-$index\"
            try {   
                Copy-Item $file $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
        if ($type -eq "file") {
            $path="$pathNew\$date\CNJ01-$index\"
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
            $path="$pathNew\$date\CNJ02-$index\"
            try {   
                Copy-Item $file $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
        if ($type -eq "file") {
            $path="$pathNew\$date\CNJ02-$index\"
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
$startHost = 4
$endHost = 4
if ($includeServersCTL01 -eq 1) {
    for ($i = $startHost; $i -le $endHost; $i++) {
        $index="{0:d2}" -f $i
        if ($type -eq "folder") {
            $path="$pathNew\$date\CTL01-$index\"
            try {   
                Copy-Item "\\CTL01-$index\$file" $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to copy from CTL01-$index"
            }
        }
        if ($type -eq "file") {
            $path="$pathNew\$date\CTL01-$index\"
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
            $path="$pathNew\$date\DMS01-$index\"
            try {   
                Copy-Item $file $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
        if ($type -eq "file") {
            $path="$pathNew\$date\DMS01-$index\"
            try {   
                Copy-Item $file "$path\$fileNew" -errorAction 'stop'
                Write-Host "Copied $fileNew to $path"
            } catch {
                Write-Host "Failed to copy from ACT01-$index"
            }
        }
    }
}