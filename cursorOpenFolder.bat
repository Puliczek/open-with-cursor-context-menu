@echo off
setlocal enabledelayedexpansion

:: Find Cursor.exe path
set "cursor_path="
for %%i in (Cursor.exe) do set "cursor_path=%%~$PATH:i"
if not defined cursor_path (
    set "cursor_path=%LOCALAPPDATA%\Programs\Cursor\Cursor.exe"
)

if not exist "!cursor_path!" (
    echo Cursor.exe not found. Please ensure it's installed and in the PATH.
    pause
    exit /b 1
)

:: Escape backslashes in the path
set "cursor_path_escaped=!cursor_path:\=\\!"

:: Define registry operations
(
echo Windows Registry Editor Version 5.00

echo [HKEY_CLASSES_ROOT\*\shell\Open with Cursor]
echo @="Edit with Cursor"
echo "Icon"="!cursor_path_escaped!,0"
echo "Position"=""

echo [HKEY_CLASSES_ROOT\*\shell\Open with Cursor\command]
echo @="\"!cursor_path_escaped!\" \"%%1\""

echo [HKEY_CLASSES_ROOT\Directory\shell\Cursor]
echo @="Open Folder as Cursor Project"
echo "Icon"="\"!cursor_path_escaped!\",0"
echo "Position"=""

echo [HKEY_CLASSES_ROOT\Directory\shell\Cursor\command]
echo @="\"!cursor_path_escaped!\" \"%%1\""

echo [HKEY_CLASSES_ROOT\Directory\Background\shell\Cursor]
echo @="Open Folder as Cursor Project"
echo "Icon"="\"!cursor_path_escaped!\",0"
echo "Position"=""

echo [HKEY_CLASSES_ROOT\Directory\Background\shell\Cursor\command]
echo @="\"!cursor_path_escaped!\" \"%%V\""
) > temp.reg

:: Import registry file
reg import temp.reg
if %errorlevel% neq 0 (
    echo Failed to import registry entries.
    goto cleanup
)

echo Registry entries added successfully.
echo Cursor.exe path: !cursor_path!

:cleanup
:: Delete temporary file
@REM del temp.reg
del temp.reg

pause
