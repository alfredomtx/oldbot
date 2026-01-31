#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\_AbstractSettings.ahk

class _AbstractJsonSettings extends _AbstractSettings
{
    getCurrentValue(key)
    {
        try {
            return base.getCurrentValue(key)
        } catch e {
            if (e.What == _AbstractSettings.EXCEPTION_NO_SUCH_KEY) {
                return ""
            }

            throw e
        }
    }

    /**
    * @param string key
    * @param mixed value
    */
    set(key, value)
    {
        if value is number
        {
            /*
            adding 0 to a float number is messing it
            */
            if (!InStr(value, ".")) {
                value += 0
            }
        }

        base.set(key, value)
    }

    /**
    * @return object
    */
    getObject()
    {
        identifier := this.getIdentifier()

        if (IsObject(%identifier%Obj)) {
            return %identifier%Obj
        }

        return base.getObject()
    }

    /**
    * @param string key
    * @param mixed value
    * @param null|string|function nested
    * @return void
    */
    submit(key, value, nested := "")
    {
        key := this.resolveNestedKey(key, nested)

        this.set(key, value)
        this.save()
    }

    /**
    * @return void
    */
    save()
    {
        ; scriptFile[identifier] := %identifier%Obj
        i := this.getIdentifier()
        v := scriptFile[this.getIdentifier()]
        obj := this.getObject()
        scriptFile[this.getIdentifier()] := this.getObject()

        CavebotScript.saveScriptFile(A_ThisFunc)
        Sleep, 25
    }
}