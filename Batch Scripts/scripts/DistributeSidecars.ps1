param([string]$param="Error") 

Add-Type -AssemblyName System.Windows.Forms

# Select Media
Write-Host "Select Media Location"
$folder_dialog = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{SelectedPath = "E:\Watch"}
$result = $folder_dialog.ShowDialog()

if ($result -eq 'OK') {
    $folder_path = $folder_dialog.SelectedPath
    $media = @()

    $subFolders = Get-ChildItem -Path $folder_path -Directory
    foreach ($folder in $subFolders) {
        $media += $folder.FullName
    }

    # Display the gathered sub-folder paths
    Write-Host "Sub-folder paths:"
    foreach ($path in $media) {
        Write-Host $path
    }

    # Select Media
    Write-Host "Select Sidecar Location"
    $folder_dialog2 = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{SelectedPath = "C:\Batch Scripts"}
    $result2 = $folder_dialog2.ShowDialog()

    if ($result2 -eq 'OK') {
        $folder_path2 = $folder_dialog2.SelectedPath
        $sidecars = @()

        $subFolders2 = Get-ChildItem -Path $folder_path2 -Directory
        foreach ($folder in $subFolders2) {
            $sidecars += $folder.FullName
        }

        # Display the gathered sub-folder paths
        Write-Host "Sub-folder paths:"
        foreach ($path in $sidecars) {
            Write-Host $path
        }

        # Script block to iterate folders and add sidecar.json files
        For ($i=0; $i -lt $sidecars.Length; $i++) {

            # Copy Sidecar files into Media
            Copy-Item -Path "$($sidecars[$i])\*" -Destination "$($media[$i])" -Recurse -Force
        }
    } else {
        Write-Host "No Sidecars folder selected."
    }
} else {
    Write-Host "No Media folder selected."
}

Read-Host "All done. Press Enter to terminate"