# February 5 2024
# Luke Huapaya

Write-Host "Set w32tm Time"

#Restart-Service w32time

# Get the current status of w32tm
w32tm /query /status /verbose

#--------
# Get NTP Server and Time
#--------

# Path to Registry
$ntpRegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters"
$configPath = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config"
$pollRegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient"
$enabledPath = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient"

$ntpProperties = Get-ItemProperty -Path $ntpRegistryPath

# Output
Write-Host "NTP Server Information:"
Write-Host "    NTP Server Address: $($ntpProperties.NtpServer)"
$pollProperties = Get-ItemProperty -Path $pollRegistryPath
Write-Host "    Poll Interval: $($pollProperties.SpecialPollInterval)"

$currentDateTime = [System.DateTime]::Now

# format time output
$currentTimeFormatted = $currentDateTime.ToString("yyyy-MM-dd HH:mm:ss.fff")

Write-Host "Current System Time: $currentTimeFormatted <----"

#--------
# Set new NTP Server in Registry
#--------

$ntpServerAddress = "10.232.130.171"

# is this necesary? already defined above
$ntpRegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters"

# Set NTP Registry Value
Set-ItemProperty -Path $ntpRegistryPath -Name NtpServer -Value $ntpServerAddress

# MinPollInterval = 2^6 = 64 seconds
Set-ItemProperty -Path $configPath -Name MinPollInterval -Value 6

# MaxPollInterval = 2^7 = 128 seconds
Set-ItemProperty -Path $configPath -Name MaxPollInterval -Value 7

# UpdateInterval = 100 clock ticks between phase correction
Set-ItemProperty -Path $configPath -Name UpdateInterval -Value 100

# Set SpecialPollInterval to 60 seconds
Set-ItemProperty -Path $pollRegistryPath -Name SpecialPollInterval -Value 60

# Set Enable to 1
Set-ItemProperty -Name Enabled -Path $enabledPath -Value 1

# Restart Windows Time Service for changes to take effect
Write-Host "Restarting w32time Service... (5 seconds)..."
Restart-Service w32time
Sleep(5)

w32tm /config /update

# Get the current status of w32tm
Write-Host "w32tm Status: "
w32tm /query /status /verbose

#--------
# Get NTP Server and Time
#--------

# Output
Write-Host "NTP Server Information:"
Write-Host "    NTP Server Address: $($ntpProperties.NtpServer)"
$pollProperties = Get-ItemProperty -Path $pollRegistryPath
Write-Host "    Poll Interval: $($pollProperties.SpecialPollInterval)"

$currentDateTime = [System.DateTime]::Now

# format time output
$currentTimeFormatted = $currentDateTime.ToString("yyyy-MM-dd HH:mm:ss.fff")

Write-Host "Current System Time: $currentTimeFormatted <----"

#--------

Write-Host "Done"
