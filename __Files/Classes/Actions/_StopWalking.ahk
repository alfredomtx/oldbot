

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\_AbstractAction.ahk

class _StopWalking extends _AbstractAction
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return void
    */
    __New(repeat := 2, delay := "")
    {
        if (!delay) {
            delay := new _CavebotIniSettings().get("stopWalkingDelay")
        }

        _Logger.log(this.__Class, delay * repeat "ms")
        try {
                new _ReleaseArrowKeys()

            Loop, % repeat {
                Send("Esc")
                sleep(delay)
            }
        } catch e {
            this.handleException(e, this)
            throw e
        }
    }
}