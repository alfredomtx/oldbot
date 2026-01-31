
class _Ini extends _BaseClass
{
    static DEFAULT_SECTION := "settings"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __Init()
    {
        static validated
        if (!validated) {
            _Validation.empty("DefaultProfile", DefaultProfile)

            validated := true
        }
    }

    __New()
    {
        guardAgainstInstantiation(this)
    }

    /**
    * @param string valu
    * @return void
    */
    setDefaultSection(value)
    {
        _Validation.string("value", value)

        this.DEFAULT_SECTION := value
    }

    /**
    * @return void
    */
    resetDefaultSection()
    {
        this.DEFAULT_SECTION := "settings"
    }

    /**
    * @param string key
    * @param string section
    * @param ?mixed default
    * @param ?string filePath
    * @return mixed
    */
    read(key, section := "", default := "", filePath := "")
    {
        local value
        if (!section) {
            section := this.DEFAULT_SECTION
        }

        IniRead, value, % this.resolveFilePath(filePath), % section, % key, % A_Space
        if (empty(value)) {
            return default
        }

        return value
    }

    /**
    * @param string section
    * @param ?mixed default
    * @param ?string filePath
    * @return Object
    */
    readSection(section, filePath := "")
    {
        local value
        IniRead, value, % this.resolveFilePath(filePath), % section
        return StrSplit(value, "`n")
    }

    /**
    * @param ?string filePath
    * @return string
    */
    resolveFilePath(filePath)
    {
        return filePath ? filePath : DefaultProfile
    }

    /**
    * @param _DefaultValue defaultValue
    * @param ?string section
    * @return ?string
    */
    readDefault(defaultValue, section := "")
    {
        if (!section) {
            section := this.DEFAULT_SECTION
        }

        _Validation.instanceOf("defaultValue", defaultValue, _DefaultValue)

        return defaultValue.resolve(this.read(defaultValue.identifier, section))
    }

    /**
    * @param string key
    * @param ?string section
    * @return ?string
    */
    readBoolean(key, section := "", default := false)
    {
        value := this.read(key, section)
        if (value = "") {
            return default
        }

        return value ? true : false
    }

    /**
    * @param string key
    * @param string value
    * @param ?string section
    * @param ?string filePath
    * @return string
    * @?throws
    */
    write(key, value, section := "", filePath := "")
    {
        _Validation.string("key", key)
        if (value) {
            _Validation.stringOrNumber("value", value)
        }

        if (!section) {
            section := this.DEFAULT_SECTION
        }

        IniWrite, % value, % this.resolveFilePath(filePath), % section, % key

        return value
    }

    /**
    * @param string key
    * @param ?string section
    * @param ?string filePath
    * @return void
    */
    delete(key, section := "", filePath := "")
    {
        if (!section) {
            section := this.DEFAULT_SECTION
        }

        IniDelete, % this.resolveFilePath(filePath), % section, % key
    }

    /**
    * @param string section
    * @param ?string filePath
    * @return void
    */
    deleteSection(section, filePath := "")
    {
        IniDelete, % this.resolveFilePath(filePath), % section
    }
}