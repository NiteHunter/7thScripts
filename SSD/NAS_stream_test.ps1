param([string]$string="Error") 

#Server number from HostName 
$serverName = [system.net.DNS]::GetHostName() 
$serverNumber = $serverName.trim("server") 
Write-Host "Hostname is" $serverName 
#Write-Host "Server number is"  $serverNumber 

<#Splits test criteria into an array of Strings: 
    Test Number 
    XML filename 
    Num of servers in test.  ##Archived: Bitwise value of servers to include 
    Frames per second 
    Test duration in minutes 
#> 

$stringArray = $string.Split(".") 
Write-Host "Test criteria is" $stringArray 

#XML path setup 
$xmlPath = "C:\7thSense\SSD\XML\" + $stringArray[1] + ".xml" 
Write-Host "XML Path is" $xmlPath 
[xml]$xml = Get-Content $xmlPath 
$threadsCheck = $stringArray[1].Trim("abcdefghijklmnopqrstuvwxyz") 
Write-Host "Number of threads in test per server is" $threadsCheck 

<#Convert Bitwise value to binary array 
$servers = [Convert]::ToString($stringArray[2],2).PadLeft(8,'0') 
$serversArray = $servers.ToCharArray() 

#Count number of servers in test 
$serverCount = 0 
ForEach ($char in [char[]]$serversArray) 
{ 
    If($char -eq "1") 
    {
        $serverCount++ 
    } 
} 
#>

$serverCount = $stringArray[2] ## Archived: $serverCount.ToString() 

#Sanity check values 
#Write-Host "Bitwise server inclusion" $stringArray[2] 
#Write-Host "Servers in test" $serversArray 
Write-Host "Server total is" $serverCount 

#Checks if server is included in testing criteria 

<#If($serversArray[$serverNumber] -eq "0") 
{ 
    Write-Host "This Server is not required in test" 
    #Script stops if server is not included 
    exit 
} Else 

{ 
Write-Host "This Server is included!" 
} 
#>

#Results path creation 
$date = Get-Date -Format "yyyy-MM-dd" 
$resultsPath = "C:\7thSense\SSD\Results\" + $date + "\" 
Write-Host "Results pathname is" $resultsPath 

#Checks if the path already exists and creates it if it doesn't 
If(!(test-path $resultsPath)) 
{ 
      New-Item -ItemType Directory -Force -Path $resultsPath 
} 


#Checks number of threads for this test 
$threads = 0 
ForEach ($directory in $xml.settings.$($serverName).d) 
{ 
    $threads++ 
} 

#Parses other test criteria 
$testNumber = $stringArray[0] 
Write-Host "Test number is" $testNumber 
$fps = $stringArray[3] 
Write-Host "Frames per second per thread," $fps 
$minutes = $stringArray[4] 
Write-Host "Length of test is" $minutes "minutes" 

#Hard coded values 
$dma = "1048576" 
Write-Host "DMA value is" $dma 
$qd = "1" 
Write-Host "MacConcurrency value is" $qd 
$fileNameInclusion = "1" 
Write-Host "If this value is 1:" $fileNameInclusion ": include the rame filenames in the log" 
$diskSize = "1048576" 
Write-Host "BlockSize value is" $diskSize 
$method="true" 
Write-Host "IOCompletion Read Method is $method, (false is Kernel Event Mode)" 

#Starts instances of the 7thSSDReadEndurance.exe utility for each thread specified in the XML file 
$threadNum = 1 
ForEach ($directory in $xml.settings.$($serverName).d) 
{ 
    $threadName = $threadNum.ToString() 
    $threadName = $threadName.PadLeft(2, '0') 
    $sourceFolder = "`"" + $directory + "`"" 
    $comment = "`"" + "Test_Number_" + $testNumber + "_tests_" + $threads + "_threads_on_" + $serverCount + "_Servers_at_" + $fps + "_fps_for_" + $minutes + "_minutes" + "`"" 
    $results = "`"" + "Results\" + $date + "\" + $string + "_" + $serverName + ".thread" + $threadName + "`"" 
    $threadNum++ 
    Write-Host $results 
    Write-host $sourceFolder 
    Write-host $comment 
    Start-Process -FilePath C:\7thSense\SSD\7thReadTest_MED201_920.exe -ArgumentList "--output $results --sourcefolder $sourceFolder --nummins $minutes --fps $fps --inclfilenamesinlog $fileNameInclusion --dmasize=$dma --overridedisksectorsize=$diskSize --iocompletionport=$method --maxconcurrency=$qd --comment $comment" 
} 