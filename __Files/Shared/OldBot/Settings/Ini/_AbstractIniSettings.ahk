#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\_AbstractSettings.ahk

class _AbstractIniSettings extends _AbstractSettings
{
    /**
    * @param string key - can be json-like nested (e.g. "key1.key2.key3")
    * @return string
    * @throws
    */
    getCurrentValue(key)
    {
        try {
            return base.getCurrentValue(key)
        } catch e {
            if (e.What == _AbstractSettings.EXCEPTION_NO_SUCH_KEY) {
                return this.read(key)
            }

            throw e
        }
    }

    /**
    * @return object
    */
    getObject()
    {
        identifier := this.getIdentifier()
        return %identifier%Ini
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

        this.write(key, value)
    }

    /**
    * @return void
    */
    save()
    {
    }

    /**
    * @param string key
    */
    read(key) 
    {
        return _Ini.read(key, this.getIdentifier())
    }


    /**
    * @param string key
    * @param ?string section
    * @return void
    */
    delete(key, section := "") 
    {
        _Ini.delete(key, section ? section : this.getIdentifier())
    }

    /**
    * @param ?string section
    */
    readSection(section := "")
    {
        return _Ini.readSection(section ? section : this.getIdentifier())
    }

    /**
    * @param string key
    * @param mixed value
    * @return void
    */
    write(key, value)
    {
        _Ini.write(key, value, this.getIdentifier())
    }
}