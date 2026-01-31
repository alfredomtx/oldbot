; Setup.ahk - Run this once after cloning/extracting OldBot Pro
; This script updates all hardcoded paths to match your installation directory

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

; Get current directory as the new base path
newPath := A_ScriptDir . "\"
oldPath := "C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\"

; Check if already configured
if (newPath = oldPath) {
    MsgBox, 64, OldBot Pro Setup, Paths are already configured for this location.`n`nYou can run OldBot Pro.ahk now.
    ExitApp
}

MsgBox, 4, OldBot Pro Setup, This will configure OldBot Pro for your system.`n`nCurrent location:`n%newPath%`n`nThis will update all script files to use your path.`n`nContinue?
IfMsgBox No
    ExitApp

; Progress indicator
Progress, M, Scanning files..., OldBot Pro Setup, Configuring...

; Find and replace in all .ahk files
fileCount := 0
totalFiles := 0

; First count total files
Loop, Files, %A_ScriptDir%\*.ahk, R
    totalFiles++

currentFile := 0
Loop, Files, %A_ScriptDir%\*.ahk, R
{
    currentFile++
    Progress, % Round(currentFile / totalFiles * 100), % "Processing: " A_LoopFileName

    FileRead, content, %A_LoopFilePath%
    if InStr(content, oldPath)
    {
        StringReplace, content, content, %oldPath%, %newPath%, All
        FileDelete, %A_LoopFilePath%
        FileAppend, %content%, %A_LoopFilePath%
        fileCount++
    }
}

Progress, Off

MsgBox, 64, Setup Complete, OldBot Pro has been configured!`n`nUpdated %fileCount% files.`n`nYou can now run OldBot Pro.ahk
ExitApp
