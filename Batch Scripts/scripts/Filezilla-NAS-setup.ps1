param ([Parameter(Mandatory)]$UserName, [Parameter(Mandatory)]$Password, [Parameter(Mandatory)]$LocalPath)

function Add-RightToUser([string] $Username, $Right) {
    $tmp = New-TemporaryFile

    $TempConfigFile = "$tmp.inf"
    $TempDbFile = "$tmp.sdb"

    Write-Host "Getting current policy"
    secedit /export /cfg $TempConfigFile

    $sid = ((New-Object System.Security.Principal.NTAccount($Username)).Translate([System.Security.Principal.SecurityIdentifier])).Value

    $currentConfig = Get-Content -Encoding ascii $TempConfigFile

    $newConfig = $null

    if($currentConfig | Select-String -Pattern "^$Right = ") {
        if($currentConfig | Select-String -Pattern "^$Right .*$sid.*$") {
            Write-Host "Already has right"
        }
        else {
            Write-Host "Adding $Right to $Username"

            $newConfig = $currentConfig -replace "^$Right .+", "`$0,*$sid"
        }
    }
    else {
        Write-Host "Right $Right did not exist in config. Adding $Right to $Username."

        $newConfig = $currentConfig -replace "^\[Privilege Rights\]$", "`$0`n$Right = *$sid"
    }

    if ($newConfig) {
        Set-Content -Path $TempConfigFile -Encoding ascii -Value $newConfig

        Write-Host "Validating configuration"
        $validationResult = secedit /validate $TempConfigFile
        
        if ($validationResult | Select-String '.*invalid.*') {
            throw $validationResult;
        }
        else {
            Write-Host "Validation Succeeded"
        }

        Write-Host "Importing new policy on temp database"
        secedit /import /cfg $TempConfigFile /db $TempDbFile

        Write-Host "Applying new policy to machine"
        secedit /configure /db $TempDbFile /cfg $TempConfigFile

        Write-Host "Updating policy" 
        gpupdate /force

        Remove-Item $tmp* -ea 0
    }
}

#################################################################################################################
##
## Start of script
##
##################################################################################################################

# PowerShell version:
# $PSVersionTable
# Useful commands to remember while experimenting:
# Get-SmbMapping
# Remove-SmbMapping -LocalPath "N:"
# Remove-LocalUser -Name "AdminContoso02"
# Example command-line
# .\FileZilla-NAS-Setup.ps1 -UserName "7th" -Password "7th" -LocalPath "N:" -RemotePath "\\nas-hostname\share"
#

$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Description = "Autocreated user for network share"
$ServiceName = "filezilla-server"

$UserID = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
if (!$UserID) {
    New-LocalUser $UserName -Password $SecurePassword -Description $Description
}
else {
    Write-Host "User Exists"
}

Add-RightToUser -UserName $UserName -Right "SeServiceLogonRight"

$svc = Get-WmiObject win32_service -filter "name='$ServiceName '"

if (!$svc) {
    throw "Failed to get service object"
}

if (($svc.StopService()).ReturnValue -ne 0) {
    Write-Host "Failed to stop $ServiceName"
}
else {
    Write-Host "Stopped $ServiceName successfully"
}

if (($svc.change($null, $null, $null, $null, $null, $null, ".\$UserName", $Password, $null, $null, $null)).ReturnValue -ne 0) {
    Write-Host "Failed to set $UserName as logon user for service: $ServiceName"
}
else {
    Write-Host "Service: $ServiceName now run as User: $UserName"
}

if (($svc.StartService()).ReturnValue -ne 0) {
    Write-Host "Failed to start $ServiceName"
}
else {
    Write-Host "Started $ServiceName successfully"
}