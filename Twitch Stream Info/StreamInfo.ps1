$baseFolder = $PSScriptRoot
$binFolder = Join-Path -Path $baseFolder -ChildPath "bin"
$logFile = Join-Path -Path $baseFolder -ChildPath "log.txt"

$configFile = Join-Path -Path $binFolder -ChildPath "config.json"
$systemLocale = (Get-WinSystemLocale).Name

#####################################################################################################
function Log-Error {
    param (
        [string]$logMessage = "No error message provided", 
        [string]$logType
    )
    $formattedError = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - [$logType] $logMessage"
    $formattedError | Out-File -FilePath $logFile -Append
    exit     
}
function File-Download {
    param (
        [string]$url, 
        [string]$filePath
    )
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, $filePath)  
}
#####################################################################################################
<# BIN CHECK #>
try {
    if (-not (Test-Path -Path $binFolder -PathType Container)) {
        New-Item -Path $binFolder -ItemType Directory | Out-Null

        $configOptions = [ordered]@{
            "version" = "1.0"
            "language" = "en-US"
            "font" = "Segoe UI"
            "theme" = "twitch"
        }
        $configOptions | ConvertTo-Json | Out-File -FilePath $configFile -Force

        $themeFolder = Join-Path -Path $binFolder -ChildPath "theme"
        New-Item -Path $themeFolder -ItemType Directory | Out-Null

        $themeUrl = "https://raw.githubusercontent.com/blushell/TP-Scripts/main/Stream%20Info/bin/theme/theme.json"
        File-Download -url $themeUrl -filePath $themeFolder

        $icons = @(
            @{name="kick.ico"; url="https://raw.githubusercontent.com/blushell/TP-Scripts/main/Stream%20Info/bin/theme/kick.ico"},
            @{name="twitch.ico"; url="https://raw.githubusercontent.com/blushell/TP-Scripts/main/Stream%20Info/bin/theme/twitch.ico"},
            @{name="youtube.ico"; url="https://raw.githubusercontent.com/blushell/TP-Scripts/main/Stream%20Info/bin/theme/youtube.ico"}
        )
        foreach ($icon in $icons) {
            $iconFilePath = Join-Path -Path $themeFolder -ChildPath $icon.name
            if (-not (Test-Path -Path $iconFilePath)) {
                File-Download -url $icon.url -filePath $iconFilePath
            }
        }

    } else {
        Write-Host "Folder already exists."
    }

} catch {
    $errorMessage = $_.Exception.Message
    Log-Error -logMessage $errorMessage -logType "ERROR"    
}

#####################################################################################################
Write-Host "Press any key to exit..."
$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit
