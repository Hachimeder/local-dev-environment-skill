$ErrorActionPreference = 'SilentlyContinue'

$skillRoot = Split-Path -Parent $PSScriptRoot
$outputPath = Join-Path $skillRoot 'references\inventory.md'
$lines = [System.Collections.Generic.List[string]]::new()

function Add-Line([string]$Text = '') {
    $lines.Add((Normalize-Text $Text))
}

function Normalize-Text([object]$Value) {
    if ($null -eq $Value) { return '' }
    $text = [string]$Value
    $text = [regex]::Replace($text, 'C:\\Users\\[^\\\r\n]+', '%USERPROFILE%', 'IgnoreCase')
    $text = $text -replace "`0", ''
    return $text
}

function Escape-Cell([object]$Value) {
    if ($null -eq $Value) { return '' }
    return (Normalize-Text $Value).Replace('|', '\|').Replace("`r", ' ').Replace("`n", ' ').Trim()
}

function Get-VersionText([string]$CommandName) {
    try {
        $text = & $CommandName --version 2>&1 | Select-Object -First 1
        return (Escape-Cell $text)
    } catch {
        return ''
    }
}

function Add-Table($Rows, [string[]]$Columns) {
    if (-not $Rows -or @($Rows).Count -eq 0) {
        Add-Line '_None detected._'
        Add-Line
        return
    }
    Add-Line ('| ' + ($Columns -join ' | ') + ' |')
    Add-Line ('| ' + (($Columns | ForEach-Object { '---' }) -join ' | ') + ' |')
    foreach ($row in $Rows) {
        $cells = foreach ($column in $Columns) {
            Escape-Cell $row.$column
        }
        Add-Line ('| ' + ($cells -join ' | ') + ' |')
    }
    Add-Line
}

Add-Line '# Local Development Environment Inventory'
Add-Line
Add-Line ('Generated: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'))
Add-Line ('Computer: `' + [Environment]::MachineName + '`')
Add-Line 'User home: `%USERPROFILE%`'
Add-Line ('OS version: `' + [Environment]::OSVersion.VersionString + '`')
Add-Line
Add-Line '> This is a discovery snapshot. Verify paths and versions before use.'
Add-Line

Add-Line '## Storage'
Add-Line
$drives = Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object {
    [pscustomobject]@{
        Drive = $_.DeviceID
        Label = $_.VolumeName
        SizeGB = [math]::Round($_.Size / 1GB, 1)
        FreeGB = [math]::Round($_.FreeSpace / 1GB, 1)
    }
}
Add-Table $drives @('Drive', 'Label', 'SizeGB', 'FreeGB')

Add-Line '## Commands On PATH'
Add-Line
$commandNames = @(
    'python','py','pip','uv','node','npm','npx','bun',
    'java','javac','dotnet','go','rustc','cargo',
    'git','docker','code','mysql','redis-cli',
    'cmake','gcc','g++','clang','gradle','mvn',
    'php','ruby','perl','pwsh','powershell','adb',
    'flutter','dart','qmake','devenv','msbuild'
)
$commands = foreach ($name in $commandNames) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd) {
        [pscustomobject]@{
            Command = $name
            Version = Get-VersionText $name
            Path = $cmd.Source
        }
    }
}
Add-Table $commands @('Command', 'Version', 'Path')

Add-Line '## Language And Package Details'
Add-Line
Add-Line '### Python'
Add-Line
Add-Line '```text'
(& py -0p 2>&1) | ForEach-Object { Add-Line ([string]$_) }
Add-Line '```'
Add-Line

Add-Line '### .NET SDKs And Runtimes'
Add-Line
Add-Line '```text'
Add-Line 'SDKs:'
(& dotnet --list-sdks 2>&1) | ForEach-Object { Add-Line ([string]$_) }
Add-Line 'Runtimes:'
(& dotnet --list-runtimes 2>&1) | ForEach-Object { Add-Line ([string]$_) }
Add-Line '```'
Add-Line

Add-Line '### Rust Toolchains'
Add-Line
Add-Line '```text'
(& rustup toolchain list 2>&1) | ForEach-Object { Add-Line ([string]$_) }
Add-Line '```'
Add-Line

Add-Line '### Global npm Packages'
Add-Line
Add-Line '```text'
(& npm list -g --depth=0 2>&1) | ForEach-Object { Add-Line ([string]$_) }
Add-Line '```'
Add-Line

Add-Line '## WSL And Containers'
Add-Line
$wslRows = @()
$lxssRoot = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss'
if (Test-Path $lxssRoot) {
    foreach ($key in Get-ChildItem $lxssRoot) {
        $item = Get-ItemProperty $key.PSPath
        $wslRows += [pscustomobject]@{
            Distribution = $item.DistributionName
            Version = $item.Version
            BasePath = $item.BasePath
        }
    }
}
Add-Table $wslRows @('Distribution', 'Version', 'BasePath')

$dockerPath = (Get-Command docker -ErrorAction SilentlyContinue).Source
$dockerRows = @()
if ($dockerPath) {
    $dockerRows += [pscustomobject]@{
        Component = 'Docker CLI'
        Path = $dockerPath
        Status = Get-VersionText 'docker'
    }
}
$dockerDesktop = 'C:\Program Files\Docker\Docker\Docker Desktop.exe'
if (Test-Path -LiteralPath $dockerDesktop) {
    $dockerRows += [pscustomobject]@{
        Component = 'Docker Desktop'
        Path = $dockerDesktop
        Status = if (Get-Process 'Docker Desktop') { 'Running' } else { 'Installed, not running' }
    }
}
Add-Table $dockerRows @('Component', 'Path', 'Status')

Add-Line '## Installed Development Applications'
Add-Line
$uninstallRoots = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$devPattern = 'Visual Studio|Visual Studio Code|IntelliJ|DataGrip|PyCharm|CLion|Rider|WebStorm|Android Studio|Unity|Docker|Git$|GitHub Desktop|Python|Java|JDK|Node.js|\.NET SDK|\.NET Runtime|MySQL|Redis|PostgreSQL|SQL Server|VirtualBox|VMware|Qt|MATLAB|Quartus|Proteus|LINGO|Inno Setup|IIS|WSL'
$excludePattern = 'Redistributable|Targeting Pack|AppHost Pack|Host FX Resolver|Templates|Manifest|Intellisense|Bootstrapper|Shared Framework|Module for IIS|Setup Configuration|Setup WMI|Diagnostic Pack|Local Feed|System CLR Types|ODBC Driver|Command Line Utilities|vcpp_crt|Python .+ (Add to Path|Core Interpreter|Development Libraries|Documentation|Executables|pip Bootstrap|Standard Library|Tcl/Tk Support|Test Suite)'
$apps = Get-ItemProperty $uninstallRoots | Where-Object {
    $_.DisplayName -and $_.DisplayName -match $devPattern -and $_.DisplayName -notmatch $excludePattern
} | ForEach-Object {
    [pscustomobject]@{
        Name = $_.DisplayName
        Version = $_.DisplayVersion
        InstallLocation = $_.InstallLocation
    }
} | Sort-Object Name, Version -Unique
Add-Table $apps @('Name', 'Version', 'InstallLocation')

Add-Line '## Known Tool Locations'
Add-Line
$knownPaths = @(
    $apps.InstallLocation
    $commands.Path | ForEach-Object { Split-Path -Parent $_ }
    $env:ProgramFiles
    ${env:ProgramFiles(x86)}
    $env:LOCALAPPDATA
) | Where-Object { $_ } | Sort-Object -Unique
$locationRows = foreach ($path in $knownPaths) {
    if (Test-Path -LiteralPath $path) {
        [pscustomobject]@{
            Path = $path
            LastWrite = (Get-Item -LiteralPath $path -Force).LastWriteTime.ToString('yyyy-MM-dd')
        }
    }
}
Add-Table $locationRows @('Path', 'LastWrite')

Add-Line '## Portable Development Assets'
Add-Line
Add-Line 'These tools are callable even when they are not registered in Windows or available on `PATH`.'
Add-Line
$portableRows = @()

$scanRoots = @()
if ($env:LOCAL_DEV_SCAN_ROOTS) {
    $scanRoots += $env:LOCAL_DEV_SCAN_ROOTS -split ';'
}
foreach ($drive in Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3') {
    foreach ($name in @('tools', 'dev', 'development', 'sdk', 'models', 'ai', 'books')) {
        $candidate = Join-Path ($drive.DeviceID + '\') $name
        if (Test-Path -LiteralPath $candidate) { $scanRoots += $candidate }
    }
}
$scanRoots = $scanRoots | Where-Object { Test-Path -LiteralPath $_ } | Sort-Object -Unique
$portableItems = foreach ($root in $scanRoots) {
    Get-ChildItem -LiteralPath $root -Recurse -Depth 4 -Force -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Name -match '^(BaiduPCS-Go.*\.exe|baidu-dumpmeta\.exe|bookget\.exe|lid\..*\.bin)$' -or
            ($_.PSIsContainer -and $_.Name -match '^(PaddleOCR|BaiduPan|bookget|fasttext)')
        }
}
foreach ($item in $portableItems | Sort-Object FullName -Unique) {
    $runtime = if (-not $item.PSIsContainer -and $item.Extension -eq '.exe') {
        $item.VersionInfo.FileVersion
    } elseif (-not $item.PSIsContainer) {
        [math]::Round($item.Length / 1MB, 1).ToString() + ' MB'
    } else {
        ''
    }
    $portableRows += [pscustomobject]@{
        Asset = $item.BaseName
        EntryPoint = $item.FullName
        Runtime = $runtime
        Purpose = 'Portable development asset discovered outside PATH'
    }
}
Add-Table $portableRows @('Asset', 'EntryPoint', 'Runtime', 'Purpose')

Add-Line '### OCR Model Files'
Add-Line
$modelRows = @()
$modelRoots = $scanRoots | Where-Object { $_ -match 'model|ai|book|dev|tool' }
foreach ($modelRoot in $modelRoots) {
    $modelRows += Get-ChildItem -LiteralPath $modelRoot -Recurse -Depth 5 -File -Force -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Extension -match '^\.(bin|onnx|pdiparams|pdmodel|pth|pt|safetensors)$'
        } |
        ForEach-Object {
            [pscustomobject]@{
                File = $_.FullName
                SizeMB = [math]::Round($_.Length / 1MB, 1)
            }
        }
}
Add-Table ($modelRows | Sort-Object File -Unique) @('File', 'SizeMB')

Add-Line '## Database And Development Services'
Add-Line
$servicePattern = 'mysql|redis|postgres|sql|docker|wsl|ssh|iis|nginx|apache|mongodb'
$services = Get-CimInstance Win32_Service | Where-Object {
    $_.Name -match $servicePattern -or $_.DisplayName -match $servicePattern
} | ForEach-Object {
    [pscustomobject]@{
        Name = $_.Name
        DisplayName = $_.DisplayName
        State = $_.State
        StartMode = $_.StartMode
        Path = $_.PathName
    }
}
Add-Table $services @('Name', 'DisplayName', 'State', 'StartMode', 'Path')

Add-Line '## Environment Variables'
Add-Line
$envRows = Get-ChildItem Env: | Where-Object {
    $_.Name -match 'JAVA|JDK|PYTHON|NODE|NPM|CARGO|RUST|GRADLE|ANDROID|GOPATH|GOROOT|DOTNET|MYSQL|POSTGRES|CUDA|VULKAN'
} | ForEach-Object {
    [pscustomobject]@{ Name = $_.Name; Value = $_.Value }
}
Add-Table $envRows @('Name', 'Value')

Add-Line '## Important Usage Notes'
Add-Line
Add-Line '- Do not assume a service is running merely because its files are installed.'
Add-Line '- Set `LOCAL_DEV_SCAN_ROOTS` to a semicolon-separated list to scan additional portable-tool directories.'
Add-Line '- Re-run the refresh script after changing the development environment.'

[System.IO.File]::WriteAllLines($outputPath, $lines, [System.Text.UTF8Encoding]::new($false))
Write-Output "Inventory written to $outputPath"
