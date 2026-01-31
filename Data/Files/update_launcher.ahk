#SingleInstance force

global launcherName := "OldBot Launcher"

Gui, -Caption
Gui, Add, Text,, Updating Launcher, please wait...
Gui, Show,, Updating Launcher

Sleep, 2000

try {
    FileMove, % launcherName ".temp.exe", % launcherName ".exe", true
} catch e {
    Gui, Destroy
    MsgBox, 16, Updating Launcher, % "Error updating launcher: " e.Message "`nError: " ErrorLevel "`n" A_LastError "`n`nTry again and if the error persists please contact support."

    runLauncher()

    ExitApp
}

Sleep, 1000

runLauncher()

Sleep, 1000

ExitApp


runLauncher()
{
    exeName := launcherName ".exe"
    path := A_WorkingDir "\" exeName 
    if (!FileExist(exeName)) {
        msgbox, 16, Error, % "OldBot Launcher executable file does not exist, your antivirus may have deleted it.`n`nPath:" path
        ExitApp
    }

    try {
        Run, % exeName
    } catch e {
        msgbox, 16, Error, % "Failed to run OldBot Launcher`n`nPath:" path "`n`nError: " e.Message "`nErrorLevel: " ErrorLevel "`n`nPlease contact support."
    }
}