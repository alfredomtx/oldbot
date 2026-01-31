

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\_AbstractAction.ahk

class _ReleaseModifierKeys extends _AbstractAction
{
    /**
    * @return void
    */
    __New()
    {
        static keys
        if (!keys) {
            modifierKeys := {}
            modifierKeys.Push("Ctrl", "Shift", "Alt")

            keys := {}
            for _, key in movementKeys {
                keys.Push(new _Key(key))
            }
        }

        try {
            for _, key in keys {
                key.release()
                Send, {%key% up}
            }
        } catch e {
            this.handleException(e, this)
            ; throw e ; swallow
        }
    }
}