##############################
##     Edit values here     ##
##############################

$type = "folder"
$file = "C:\7thSense\Installers\20-Jul-23_stagingBuild"
$fileNew = ""
$pathNew = "7thSense Data\Software & Drivers\Compere"
$includeServersACT01 = 1
$includeServersACT02 = 1
$includeServersCNJ01 = 1
$includeServersCNJ02 = 1
$includeServersCTL01 = 1
$includeServersDMS01 = 1



##############################
##       Script Block       ##
##############################

# ACT01-nn servers
$startHost = 1
$endHost = 50
if ($includeServersACT01 -eq 1) {
    for ($i = $startHost; $i -le $endHost; $i++) {
        $index="{0:d2}" -f $i
        if ($type -eq "folder") {
            $path="\\ACT01-$index\$pathNew"
            try {   
                Copy-Item $file $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to write to ACT01-$index"
            }
        }
        if ($type -eq "file") {
            $path="\\ACT01-$index\$pathNew"
            Remove-Item "$path\$fileNew"
            try {   
                Copy-Item $file "$path\$fileNew" -errorAction 'stop'
                Write-Host "Copied $fileNew to $path"
            } catch {
                Write-Host "Failed to write to ACT01-$index"
            }
        }
    }
}

# ACT02-nn servers
$startHost = 1
$endHost = 5
if ($includeServersACT02 -eq 1) {
    for ($i = $startHost; $i -le $endHost; $i++) {
        $index="{0:d2}" -f $i
        if ($type -eq "folder") {
            $path="\\ACT02-$index\$pathNew"
            try {   
                Copy-Item $file $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to write to ACT02-$index"
            }
        }
        if ($type -eq "file") {
            $path="\\ACT02-$index\$pathNew"
            Remove-Item "$path\$fileNew"
            try {   
                Copy-Item $file "$path\$fileNew" -errorAction 'stop'
                Write-Host "Copied $fileNew to $path"
            } catch {
                Write-Host "Failed to write to ACT02-$index"
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
            $path="\\CNJ01-$index\$pathNew"
            try {   
                Copy-Item $file $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to write to CNJ01-$index"
            }
        }
        if ($type -eq "file") {
            $path="\\CNJ01-$index\$pathNew"
            Remove-Item "$path\$fileNew"
            try {   
                Copy-Item $file "$path\$fileNew" -errorAction 'stop'
                Write-Host "Copied $fileNew to $path"
            } catch {
                Write-Host "Failed to write to CNJ01-$index"
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
            $path="\\CNJ02-$index\$pathNew"
            try {   
                Copy-Item $file $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to write to CNJ02-$index"
            }
        }
        if ($type -eq "file") {
            $path="\\CNJ02-$index\$pathNew"
            Remove-Item "$path\$fileNew"
            try {   
                Copy-Item $file "$path\$fileNew" -errorAction 'stop'
                Write-Host "Copied $fileNew to $path"
            } catch {
                Write-Host "Failed to write to CNJ02-$index"
            }
        }
    }
}

# CTL01-nn servers
$startHost = 1
$endHost = 6
if ($includeServersCTL01 -eq 1) {
    for ($i = $startHost; $i -le $endHost; $i++) {
        $index="{0:d2}" -f $i
        if ($type -eq "folder") {
            $path="\\CTL01-$index\$pathNew"
            try {   
                Copy-Item $file $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to write to CTL01-$index"
            }
        }
        if ($type -eq "file") {
            $path="\\CTL01-$index\$pathNew"
            Remove-Item "$path\$fileNew"
            try {   
                Copy-Item $file "$path\$fileNew" -errorAction 'stop'
                Write-Host "Copied $fileNew to $path"
            } catch {
                Write-Host "Failed to write to CTL01-$index"
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
            $path="\\DMS01-$index\$pathNew"
            try {   
                Copy-Item $file $path -Recurse -errorAction 'stop'
                Write-Host "Copied $file to $path"
            } catch {
                Write-Host "Failed to write to DMS01-$index"
            }
        }
        if ($type -eq "file") {
            $path="\\DMS01-$index\$pathNew"
            Remove-Item "$path\$fileNew"
            try {   
                Copy-Item $file "$path\$fileNew" -errorAction 'stop'
                Write-Host "Copied $fileNew to $path"
            } catch {
                Write-Host "Failed to write to DMS01-$index"
            }
        }
    }
}