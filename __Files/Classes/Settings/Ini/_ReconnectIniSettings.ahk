
identifier := _ReconnectIniSettings.getIdentifier()
%identifier%Ini := {}

class _ReconnectIniSettings extends _AbstractIniSettings
{
    static INSTANCE
    static IDENTIFIER := "reconnect"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        if (_ReconnectIniSettings.INSTANCE) {
            return _ReconnectIniSettings.INSTANCE
        }

        base.__New()

        _ReconnectIniSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _ReconnectIniSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes["autoLoginSelectClient"] := new _DefaultBoolean(1, "autoLoginSelectClient")
        this.attributes["autoLoginCharacterLogin"] := new _DefaultBoolean(0, "autoLoginCharacterLogin")
    }
}