#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Executables\_AbstractExe.ahk

class _CavebotExe extends _AbstractExe
{
    static NAME := "Cavebot"

    pause(origin := "")
    {
        _Logger.log(A_ThisFunc, "Pausing, origin: " origin)
        if (this.isPaused()) {
            return
        }

        _CavebotExeMessage.pause(A_ThisFunc)
    }

    unpause(origin := "")
    {
        _Logger.log(A_ThisFunc, "Unpausing, origin: " origin)

        if (!this.isPaused()) {
            return
        }

        title := _CavebotHUD.getWindowTitle()
        if (!WinExist(title)) {
            _Logger.warning(A_ThisFunc, _Str.quoted(title) " window does not exist.") 
            return
        }

        PostMessage, 0x111, 65306, 2,, % title ; Pause Off.
        if (ErrorLevel) {
            _Logger.warning(A_ThisFunc, "Failed to unpause " this.NAME)
        }

        _CavebotExeMessage.unpause(A_ThisFunc)
    }
}