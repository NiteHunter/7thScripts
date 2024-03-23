Close Compere, MediaLogsistics
Open "Services" and "Stop" Stack Express

Approved Files and Locations
    C:/7thSense
        compere
            [REMOVE] ALL ROLLBACK DIRs (might have issue with 1 folder "in use", that's ok to just leave it)
        PTP Logs [leave_alone]
        SDPs [leave_alone]
        Software & Drivers
            Compere
                [7thSense] to clear these out regularly
            Drivers
                Audio [REMOVE] all dirs except 2 Dante folders
                Graphics [leave_alone]
                Network Adapter [leave_alone]
                Storage [leave_alone]
            Software
                PTP [leave_alone]
                Remote Access [leave_alone]
                Test Utilities [leave_alone]
                other installers can't be left alone, but [Remove] extra folders of logs or the like
        ServerConfig (file) [leave_alone]
        startupScript-Windowed.ps1 [leave_alone]
    C:/7thSense Data
        7thSense (C) [shortcut] [leave_alone]
        Additional Folders
            Backups [shortcut] [leave_alone]
            Batch Scripts [shortcut] [leave_alone]
            Compere (Appdata) [shortcut] [leave_alone]
            Desktop (7thSense Design Ltd) [shortcut]
                Actor Shortcut
                [Remove] everything else. The 3 icons remaining on Desktop will be Actor, MY PC, and Recycle Bin
            Desktop (All Users) [shortcut] [leave_alone]
            Startup (7thSense Design Ltd) [shortcut] [leave_alone]
            Startup (All Users) [shortcut] [leave_alone]
        Software & Drivers [shortcut] [leave_alone]
        Z8 DP_2023-04-07.txt [EDID_file] [leave_alone]
    C:/AMD
    C:/automatedDeploy
    C:/Backups
    C:/Backups & Logs
    C:/Batch Scripts
    C:/DPU
    C:/PerfLogs
    C:/Program Files
    C:/Program Files (x86)
    C:/Program Data (hidden)
    C:/Temp
    C:/Users
    C:/Windows

Approved Programs and Features
    Adobe Acrobat Reader DC
    Advanced IP Scanner
    AMD Chipset
    Apache CouchDB
    Apple Bonjour
    ASIO4ALL
    ATTO Disk Benchmark
    Codemeter Runtime Kit
    Compere [REMOVE_extra_instances] [see_notes_below]
    CrystalDiskInfo
    Dante Control and Monitoring
    Dante Controller
    Dante Discovery
    Dante Update Helper
    Dante Updater
    Dante Virtual Soundcard
    FileZilla Server 1.5.1
    Google Chrome
    Intel(R) Network Connections 26.3.0.2
    ISAAC Remote version 1.0
    Java 8 Update 144 (64-bit)
    LSI Storage Authority
    Medialon AppRemote
    Microsoft Visual C++ Redistributables [all_versions_ok]
    MLNX_WinOF2
    NDI 4 Runtime
    NDI 5 Tools
    NetTime
    NewTek SpeedHQ Video Codec (x64) (Remove Only)
    NewTek SpeedHQ Video Codec (x86) (Remove Only)
    Npcap
    NVIDIA Graphics Driver 512.78
    NVIDIA HD Audio Driver 1.3.39.3
    openslp_2.0.0_0_x86
    PUTTY release 0.78 (64-bit)
    Python 3.10.6 (64-bit)
    Python 3.11.1 (64-bit)
    Python 3.12.1 (64-bit)
    Python Launcher
    Realtek USB Audio
    Rivermax
    Teamviewer
    UltraVnc
    Watchdog
    WinMFT64
    WinSCP
    Wireshark

Task Manager -> Startup [Allowed_apps]
    Cleanup inband device.... NVIDIA
    Codemeter Control Center
    Filezilla Server Administration [DISABLE]
    Medialon XObject Module
    Network Time Synchronizer [DISABLE]
    Realtek HD Audio Universal
    startDVS.bat
    startupBatch.bat
    Windows Powershell

Removing extra Compere instances
    1. Confirm version running via Compere GUI/Network Discovery (look for build ID)
    2. Close Compere and Media Logistics
    3. Rename C:\7thSense\compere to C:\7thsense\compere-temp or something like that
    4. Go to the bottom of the Apps and Features List and click on "Programs & Features"
    5. Uninstall all versions except the one that matches the build ID from above. It will say that it's already uninstalled, click yes to remove from list.

Additional Edits
    CouchDB Log level:
        Change to use a log level of "err" from default, done in the file here:
        "C:\Program Files\Apache CouchDB\etc\default.ini"
    Stop NetTime from Starting automatically
        Go to Task Manager -> Startup tab
        Disable NetTime and Filezilla Administrator Client

Restart Medialogistics and Compere