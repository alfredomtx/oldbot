

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\_AbstractAction.ahk

class _ReleaseArrowKeys extends _AbstractAction
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return void
    */
    __New()
    {
        static keys
        if (!keys) {
            movementKeys := {}
            movementKeys.Push("Up", "Down", "Right", "Left")

            keys := {}
            for _, key in movementKeys {
                keys.Push(new _Key(key))
            }
        }

        try {
            for _, key in keys {
                key.release(sleep := false)
            }
        } catch e {
            this.handleException(e, this)
            ; throw e ; swallow
        }
    }
}