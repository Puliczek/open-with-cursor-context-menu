# Check if running with administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # Relaunch the script with admin rights
    Start-Process powershell.exe -Verb RunAs -ArgumentList ("-File", $MyInvocation.MyCommand.Path)
    exit
}

# Define the Cursor executable path
$cursorExePath = [System.IO.Path]::Combine($env:LOCALAPPDATA, "Programs", "cursor", "Cursor.exe")

# Check if the Cursor executable exists
if (Test-Path $cursorExePath) {

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

    # Install context menu for background
    $backgroundPath = "HKEY_CLASSES_ROOT\Directory\Background\shell\Open with Cursor"
    Run-RegCommand "ADD `"$backgroundPath`" /ve /d `"Open with Cursor`" /f"
    Run-RegCommand "ADD `"$backgroundPath`" /v Icon /d `"$cursorExePath`" /f"
    Run-RegCommand "ADD `"$backgroundPath\command`" /ve /d `"\`"$cursorExePath\`" \`"%V\`"`" /f"
    Write-Host "Context menu for background installed successfully."

    # # Install context menu for folders
    $folderPath = "HKEY_CLASSES_ROOT\Directory\shell\Open with Cursor"
    Run-RegCommand "ADD `"$folderPath`" /ve /d `"Open with Cursor`" /f"
    Run-RegCommand "ADD `"$folderPath`" /v Icon /d `"$cursorExePath`" /f"
    Run-RegCommand "ADD `"$folderPath\command`" /ve /d `"\`"$cursorExePath\`" \`"%1\`"`" /f"
    Write-Host "Context menu for folders installed successfully."

    # Install context menu for files
    $filePath = "HKEY_CLASSES_ROOT\*\shell\Open with Cursor"
    Run-RegCommand "ADD `"$filePath`" /ve /d `"Open with Cursor`" /f"
    Run-RegCommand "ADD `"$filePath`" /v Icon /d `"$cursorExePath`" /f"
    Run-RegCommand "ADD `"$filePath\command`" /ve /d `"\`"$cursorExePath\`" \`"%1\`"`" /f"
    Write-Host "Context menu for files installed successfully."

} else {
    Write-Host "Error: Cursor executable not found at $cursorExePath"
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
