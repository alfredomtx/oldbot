/**
* @property array<_DefaultValue> attributes
*/
class _AbstractSettings extends _BaseClass
{
    static EXCEPTION_NO_SUCH_KEY := "NoSuchKey"
    static ENABLED_KEY := "enabled"

    ; call(method, args*)
    ; {
    ;     if (_AbstractSettings.HasKey(method)) {
    ;         return _AbstractSettings[method].Call(this, args*)
    ;     }

    ;     class := iterateChildClasses(_AbstractSettings, method)
    ;     if (class) {
    ;         return callClassMethod(this, class, method, args*)
    ;     }

    ;     throw Exception("Non-existent method: " method ", args: " serialize(args))
    ; }

    __New()
    {
        this.setAttributes()
        this.loadSettings()
    }

    /**
    * @param string key
    */
    defaultValue(key)
    {
        if (this.attributes.HasKey(key)) {
            return this.attributes[key].defaultValue
        }
    }

    /**
    * @return void
    */
    loadSettings()
    {
        _Validation.isObject("this.attributes", this.attributes)

        for key, _ in this.attributes {
            value := this.getCurrentValue(key)
            try {
                this.loadSingleSetting(key, value, A_ThisFunc)
            } catch e {
                if (e.Message == "continue") {
                    continue
                }

                throw e
            }
        }
    }

    /**
    * @param string key
    * @param mixed value
    * @return void
    * @throws
    */
    loadSingleSetting(key, value, origin := "")
    {
        if (IsObject(value)) {
            throw Exception("continue")
        }

        try {
            currentValue := this.get(key)
        } catch e {
            if (e.What == this.EXCEPTION_NO_SUCH_KEY) {
                throw Exception("continue")
            }

            throw e
        }

        if (empty(currentValue)) {
            throw Exception("continue")
        }

        this.set(key, this.getDefaultValue(key, A_ThisFunc))
    }

    /**
    * @param string key
    * @param null|string|function nested
    * @return string
    */
    resolveNestedKey(key, nested)
    {
        return nested ? this.getNestedKey(key, nested) : key
    }

    /**
    * @return void
    */
    save()
    {
        identifier := this.getIdentifier()
        scriptFile[identifier] := %identifier%Obj

        CavebotScript.saveScriptFile(A_ThisFunc)
        Sleep, 25
    }

    ;#region Getters
    /**
    * @param string key
    * @param null|string|function nested
    * @return string
    */
    get(key, nested := "")
    {
        if (instanceOf(key, _AbstractControl)) {
            key := key.getName()
        }

        key := this.resolveNestedKey(key, nested)

        return this.getDefaultValue(key, A_ThisFunc)
    }

    /**
    * @abstract
    * @return string
    */
    getIdentifier()
    {
        abstractMethod()
    }

    /**
    * @return object
    */
    getObject()
    {
        if (!IsObject(scriptFileObj[this.getIdentifier()])) {
            scriptFileObj[this.getIdentifier()] := {}
        }

        return scriptFileObj[this.getIdentifier()]
        ; class := this.__Class
        ; staticInstance := %class%

        ; if (!IsObject(staticInstance.DATA)) {
        ;     staticInstance.DATA := {}
        ; }

        ; return staticInstance.DATA
    }

    /**
    * @param string key
    * @param null|string|function nested
    * @return string
    */
    getNestedKey(key, nested := "")
    {
        if (IsFunction(nested)) {
            nested := %nested%()
        }

        return nested ? nested "." key : key
    }

    /**
    * @param string key
    * @return ?_DefaultValue
    */
    getAttribute(key)
    {
        variableKey := ""
        try {
            _Validation.hasKey(this.getIdentifier() "." key, this.attributes, key)
        } catch {
            /*
            handle *.key settings
            */
            key := _Arr.last(StrSplit(key, "."))
            variableKey := "*." key
            _Validation.hasKey(this.getIdentifier() "." variableKey, this.attributes, variableKey)
        }


        return this.attributes[variableKey ? variableKey : key]
    }

    /**
    * @return array<string,
    */
    getAttributes()
    {
        return this.attributes
    }

    /**
    * @param string key
    * @return ?string
    */
    getDefaultValue(key, origin := "")
    {
        value := this.getCurrentValue(key)
        attribute := this.getAttribute(key)

        return attribute ? attribute.resolve(value) : value
    }

    /**
    * Get the current value from the original source (json or ini file)
    * @param string key - can be json-like nested (e.g. "key1.key2.key3")
    * @return string
    * @throws
    */
    getCurrentValue(key)
    {
        object := this.getObject()

        nested := StrSplit(key, ".")
        switch nested.Count() {
            case 1:
                if (object.HasKey(nested.1)) {
                    return object[nested.1]
                }

                this.throwNoSuchKeyException(key)

            case 2:
                if (object[nested.1].HasKey(nested.2)) {
                    return object[nested.1][nested.2]
                }

                this.throwNoSuchKeyException(key)

            case 3:
                if (object[nested.1][nested.2].HasKey(nested.3)) {
                    return object[nested.1][nested.2][nested.3]
                }

                this.throwNoSuchKeyException(key)

            default:
                this.throwNestedSettingException(nested, key)
        }
    }
    ;#endregion

    ;#region Setters
    /**
    * Set the value in the object in memory
    * @param string key - can be json-like nested (e.g. "key1.key2.key3")
    * @param mixed value
    * @return void
    */
    set(key, value)
    {
        nested := StrSplit(key, ".")
        object := this.getObject()
        ; _Logger.log(A_ThisFunc, "key: " key ", value: " value ", nested: " serialize(nested) ", object: " serialize(object))

        switch nested.Count() {
            case 1:
                object[nested.1] := value
            case 2:
                if (!IsObject(object[nested.1])) {
                    object[nested.1] := {}
                }

                ; _Logger.log(A_ThisFunc, "before object[nested.1][nested.2]: " object[nested.1][nested.2])
                object[nested.1][nested.2] := value
                ; _Logger.log(A_ThisFunc, "after object[nested.1][nested.2]: " object[nested.1][nested.2])
            case 3:
                if (!IsObject(object[nested.1])) {
                    object[nested.1] := {}
                }

                if (!IsObject(object[nested.1][nested.2])) {
                    object[nested.1][nested.2] := {}
                }

                object[nested.1][nested.2][nested.3] := value
            default:
                this.throwNestedSettingException(nested, key)
        }
    }

    /**
    * @abstract
    * @return void
    */
    setAttributes()
    {
        abstractMethod()
    }
    ;#endregion

    ;#region Throws
    /**
    * @param array nestedSetting
    * @param string key
    * @return void
    * @throws
    */
    throwNestedSettingException(nestedSetting, key)
    {
        throw Exception("Invalid setting level: " nestedSetting.Count() "`nKey: " key)
    }

    /**
    * @throws
    */
    throwNoSuchKeyException(key)
    {
        throw Exception("No such key: " key, this.EXCEPTION_NO_SUCH_KEY)
    }
    ;#endregion
}