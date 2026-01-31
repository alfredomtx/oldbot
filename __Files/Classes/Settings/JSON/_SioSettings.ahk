#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\JSON\_AbstractJsonSettings.ahk

class _SioSettings extends _AbstractJsonSettings
{
    static INSTANCE
    static IDENTIFIER := "sioFriend"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        if (_SioSettings.INSTANCE) {
            return _SioSettings.INSTANCE
        }

        base.__New()

        _SioSettings.INSTANCE := this
    }

    /**
    * @return void
    */
    loadSettings()
    {
        identifier := this.getIdentifier()

        for player, settings in sioFriendObj {
            for key, defaultValue in this.attributes {
                value := sioFriendObj[player][key]
                try {
                    this.loadSingleSetting(player "." key, value)
                } catch e {
                    continue
                }
            }
        }
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _SioSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes["enabled"] := new _DefaultBoolean(false, "enabled")

        this.attributes["followPlayer"] := new _DefaultBoolean(false, "followPlayer")
        this.attributes["healWithRune"] := new _DefaultBoolean(false, "healWithRune")
        this.attributes["useAttackRune"] := new _DefaultBoolean(false, "useAttackRune")
        this.attributes["creatureCondition"] := new _DefaultBoolean(false, "creatureCondition")

        this.attributes["sioLife"] := new _DefaultValue(60, 5, 99, "sioLife")
        this.attributes["granSioLife"] := new _DefaultValue(20, 5, 99, "granSioLife")
        this.attributes["minLife"] := new _DefaultValue(40, 5, 99, "minLife")
        this.attributes["minMana"] := new _DefaultValue(20, 5, 99, "minMana")

        this.attributes["creatures"] := new _DefaultValue(1, 1, 8, "creatures")
    }

    /**
    * @param string key
    * @return ?_DefaultValue
    */
    getAttribute(key)
    {
        return this.attributes[_Arr.last(StrSplit(key, "."))]
    }

    /**
    * @param string name
    * @param mixed value
    * @param null|string|function nested
    * @return void
    */
    submit(name, value, nested := "")
    {
        _Validation.empty("nested", nested)

        base.submit(name, value, nested)
    }
}