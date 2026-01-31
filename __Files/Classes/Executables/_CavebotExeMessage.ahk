
class _CavebotExeMessage extends _CavebotExeMessage.Getters
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    sendMessage(string, timeout := 2000)
    {
        try {
            _Logger.log(A_ThisFunc, "Window: " _CavebotHUD.getWindowTitle() " | Data:" string)
            return Send_WM_COPYDATA(string, _CavebotHUD.getWindowTitle(), timeout)
        } catch e {
            _Logger.exception(e, A_ThisFunc, "Window: " _CavebotHUD.getWindowTitle() " | Data:" string)
            throw e
        }
    }

    handle(data)
    {
        _Logger.log(A_ThisFunc, data)
        if (InStr(data, "/")) {
            commandObj := StrSplit(data, "/")
            command := commandObj.1
        } else {
            command := data
        }

        switch command {
            case "gotolabel":
                return _GoToLabelAction.handleMessage(commandObj.2)
        }

        return true
    }

    pause(origin := "")
    {
        return this.sendMessage("Pause", 500)
    }

    unpause(origin := "")
    {
        return this.sendMessage("Unpause", 500)
    }

    /**
    * @return bool
    * @throws
    */
    goToLabel(value, timeout := 2000, writeIni := true)
    {
        if (writeIni) {
            try {
                _Ini.write("gotolabel", value, "temp_cavebot")
            } catch e {
                _Logger.exception(e, A_ThisFunc, "_Ini.write:" value)
                ; throw e
            }
        }

        return this.sendMessage("gotolabel/" value, timeout)
    }

    class Getters extends _CavebotExeMessage.Setters
    {
    }

    class Setters extends _CavebotExeMessage.Predicates
    {
    }

    class Predicates extends _CavebotExeMessage.Factory
    {
    }

    class Factory extends _CavebotExeMessage.Base
    {
    }

    class Base extends _BaseClass
    {
    }
}