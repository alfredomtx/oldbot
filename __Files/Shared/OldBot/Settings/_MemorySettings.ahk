#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\_AbstractSettings.ahk

class _MemorySettings extends _AbstractSettings
{
    static DATA := {}

    /**
    * @param string key
    * @param null|string|function nested
    * @return string
    */
    get(key, nested := "")
    {
        key := this.resolveNestedKey(key, nested)

        value := this.getCurrentValue(key)

        return value
    }

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
    * @return object
    */
    getObject()
    {
        return _MemorySettings.DATA
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
    }

    /**
    * @abstract
    * @return void
    */
    setAttributes()
    {
    }

    /**
    * @abstract
    * @return void
    */
    loadSettings()
    {
    }
}