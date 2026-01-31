/*
File purpose:
Include all the common functions that are used on all scripts (exception for Cavebot.ahk)
*/
#WarnContinuableException Off

#SingleInstance, Force
#MaxMem 2048
#NoTrayIcon
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#KeyHistory 0
#MaxHotkeysPerInterval 200
#HotkeyInterval 200
#MaxThreadsPerHotkey 1

;@Ahk2Exe-IgnoreBegin
#Warn, ClassOverwrite, MsgBox
;@Ahk2Exe-IgnoreEnd

#MaxThreads 100 ; changed on 28/07/2020
SendMode Input
SetDefaultMouseSpeed, 0
SetBatchLines, -1
FileEncoding, UTF-8
DetectHiddenWindows On  ; Allows a script's hidden main window to be detected.
SetTitleMatchMode 2  ; Avoids the need to specify the full path of the file below.
CoordMode, Mouse, Screen
CoordMode Pixel ; https://autohotkey.com/board/topic/118912-imagesearch-errorlevel-2/
CoordMode, Tooltip, Screen
SetFormat, Float, 0.0
if (A_IsCompiled) {
    ListLines Off
}
SetWinDelay, -1 ; ADDED ON 17/06/2023
SetControlDelay, -1 ; ADDED ON

#Include default_profile.ahk
