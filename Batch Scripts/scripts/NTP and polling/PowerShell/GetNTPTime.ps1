# February 5 2024
# Luke Huapaya

# Path to Registry
$ntpRegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters"

$pollRegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient"

$ntpProperties = Get-ItemProperty -Path $ntpRegistryPath

# Output
Write-Host "NTP Server Information:"
Write-Host "    NTP Server Address: $($ntpProperties.NtpServer)"
$pollProperties = Get-ItemProperty -Path $pollRegistryPath
Write-Host "    Poll Interval: $($pollProperties.SpecialPollInterval)"

# Get the current status of w32tm
Write-Host "w32tm Status: "
w32tm /query /status /verbose

$currentDateTime = [System.DateTime]::Now

# format time output
$currentTimeFormatted = $currentDateTime.ToString("yyyy-MM-dd HH:mm:ss.fff")

Write-Host "Current System Time: $currentTimeFormatted <----"

echo "Done"
