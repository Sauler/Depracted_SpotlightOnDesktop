######################################### CONSTANTS #########################################

$global:LocalAppdata = $env:localappdata
$global:SpotlightAssets = "$LocalAppdata\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"
$global:DWallpapers = "$SpotlightAssets\Wallpapers"
$global:ToolsPath = "$PSScriptRoot\Tools"

#Function that just sets wallpapaper
function global:Set-Wallpaper($Path)
{
    Set-Location -Path "$ToolsPath"
    $Tool = "Set-Wallpaper.ps1"
    & ".\$tool" "$Path"
}

#Function creates copy of file with extesion change
function global:Move-File ($SourcePath, $Extension) {
    $Name = Get-NameFromPath -Path "$SourcePath"
    $NewName = "$DWallpapers\$Name.$Extension"
    if (!($NewName -eq "$DWallpapers\Wallpapers.$Extension")) {
            $success = Copy-Item "$SourcePath" -Destination "$NewName" -Force -ErrorAction silentlyContinue -Passthru
            if ($success) {
                return $NewName
            } else {
                return 1
            }   
        } 
}

function Get-LockscreenWallpaperPath1 () {
    $null = [Windows.System.UserProfile.LockScreen,Windows.System.UserProfile,ContentType=WindowsRuntime]
    $Path = [Windows.System.UserProfile.LockScreen]::OriginalImageFile.AbsolutePath
    return $Path
}

#Function gets Path to Spotlight wallpaper
function global:Get-LockscreenWallpaperPath () {
    $RegistryKey = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lock Screen\Creative'
    
    $Path = (Get-ItemProperty -Path $RegistryKey -Name LandscapeAssetPath).LandscapeAssetPath  
    return $Path 
}

#Function returns file name from path
function global:Get-NameFromPath ($Path) {
    $Name = Split-Path -Path "$Path" -Leaf -Resolve
    return $Name
}

#Function that is called on registry value change event
function global:OnLockscreenWalpaperChange () {
    Write-Host "Wallpaper changed!"
    $Path = Get-LockscreenWallpaperPath 
    if ($Path -eq "") {
        $Path = Get-LockscreenWallpaperPath1
        $Path = $Path -replace "%7B","{"
        $Path = $Path -replace "%7D","}"
        $Path = $Path -replace "%20"," "
        Write-Host "Path: "$Path
        Set-Wallpaper -Path "$Path" 
    }
    else {
        $Name = Get-NameFromPath -Path "$Path"
        $WallpaperPath = Move-File -SourcePath "$Path" -Extension "jpg"
        if ($Name -eq "asset.jpg") {
            Set-Wallpaper -Path "$Path"    
        } else {
            Set-Wallpaper -Path "$WallpaperPath"
        }
    }
}

#Function returns current user SID
function Get-CurrentUserSid () {
   Add-Type -AssemblyName "System.DirectoryServices.AccountManagement"
    $user = [System.DirectoryServices.AccountManagement.UserPrincipal]::Current

    return $user.Sid
}

#Function registers event handler. 
function Register-EventSubscriber () {
    $Sid = Get-CurrentUserSid
    $EventQuery = "SELECT * FROM RegistryValueChangeEvent  WHERE Hive='HKEY_USERS' AND KeyPath='$Sid\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Lock Screen\\Creative' AND ValueName='LandscapeAssetPath'"
    Register-WmiEvent -Query $EventQuery -SourceIdentifier LockScreenWallpaperListener -Action {OnLockscreenWalpaperChange}   

    $EventQuery = "SELECT * FROM RegistryTreeChangeEvent  WHERE Hive='HKEY_LOCAL_MACHINE' AND RootPath='SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\SystemProtectedUserData\\$Sid\\AnyoneRead\\LockScreen'"
    Register-WmiEvent -Query $EventQuery -SourceIdentifier LockScreenWallpaperListener1 -Action {OnLockscreenWalpaperChange}   
}

#Run script
OnLockscreenWalpaperChange
Register-EventSubscriber
while ($true) {
    Wait-Event -SourceIdentifier "LockScreenWallpaperListener"
}