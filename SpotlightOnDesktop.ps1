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

function global:Move-File ($SourcePath, $Extension) {
    $Name = Get-NameFromPath -Path "$SourcePath"
    Write-Host "Name: " + $Name
    $NewName = "$DWallpapers\$Name.$Extension"
    Write-Host "NewName: " + $NewName
    if (!($NewName -eq "$DWallpapers\Wallpapers.$Extension")) {
            $success = Copy-Item "$SourcePath" -Destination "$NewName" -Force -ErrorAction silentlyContinue -Passthru
            if ($success) {
                return $NewName
            } else {
                return 1
            }   
        } 
}

function global:Get-LockscreenWallpaperPath () {
    $RegistryKey = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lock Screen\Creative'
    
    $Path = (Get-ItemProperty -Path $RegistryKey -Name LandscapeAssetPath).LandscapeAssetPath  
    return $Path 
}

function global:Get-NameFromPath ($Path) {
    $Name = Split-Path -Path "$Path" -Leaf -Resolve
    return $Name
}

function global:OnLockscreenWalpaperChange () {
    $Path = Get-LockscreenWallpaperPath  
    if ($Path -eq "") {return}
    $Name = Get-NameFromPath -Path "$Path"
    $WallpaperPath = Move-File -SourcePath "$Path" -Extension "jpg"
    Write-Host $WallpaperPath

    if ($Name -eq "asset.jpg") {
        Set-Wallpaper -Path "$Path"    
    } else {
        Set-Wallpaper -Path "$WallpaperPath"
    }
}

function Get-CurrentUserSid () {
   Add-Type -AssemblyName "System.DirectoryServices.AccountManagement"
    $user = [System.DirectoryServices.AccountManagement.UserPrincipal]::Current

    return $user.Sid
}

function Register-EventSubscriber () {
    $Sid = Get-CurrentUserSid
    $EventQuery = "SELECT * FROM RegistryValueChangeEvent  WHERE Hive='HKEY_USERS' AND KeyPath='$Sid\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Lock Screen\\Creative' AND ValueName='LandscapeAssetPath'"
    Register-WmiEvent -Query $EventQuery -SourceIdentifier LockScreenWallpaperListener -Action { OnLockscreenWalpaperChange}   
}

Register-EventSubscriber