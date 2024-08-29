# Check if running with administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # Relaunch the script with admin rights
    Start-Process powershell.exe -Verb RunAs -ArgumentList ("-File", $MyInvocation.MyCommand.Path)
    exit
}

function Run-RegCommand {
    param (
        [string]$command
    )
    $process = Start-Process -FilePath "reg.exe" -ArgumentList $command -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        Write-Host "Failed to execute: reg.exe $command"
        exit 1
    }
}

# Remove context menu for background
$backgroundPath = "HKEY_CLASSES_ROOT\Directory\Background\shell\Open with Cursor"
Run-RegCommand "DELETE `"$backgroundPath`" /f"
Write-Host "Context menu for background removed successfully."

# Remove context menu for folders
$folderPath = "HKEY_CLASSES_ROOT\Directory\shell\Open with Cursor"
Run-RegCommand "DELETE `"$folderPath`" /f"
Write-Host "Context menu for folders removed successfully."

# Remove context menu for files
$filePath = "HKEY_CLASSES_ROOT\*\shell\Open with Cursor"
Run-RegCommand "DELETE `"$filePath`" /f"
Write-Host "Context menu for files removed successfully."

Write-Host "Cursor context menu entries have been removed."
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
