#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

class _Logger extends _BaseClass
{
    static CALLBACK

    SET_CALLBACK(callback)
    {
        _Validation.function("callback", callback)

        this.CALLBACK := callback
    }

    /**
    * @param string msg
    * @param ?string identifier
    * @param ?string extra
    * @return void
    */
    error(msg, identifier := "", extra := "")
    {
        return this.log("ERROR", this._formatIdentifier(identifier) this._formatMessage(msg, extra))
    }

    /**
    * @param string msg
    * @param ?string identifier
    * @param ?string extra
    * @return void
    */
    warning(msg, identifier := "", extra := "")
    {
        return this.log("WARNING", this._formatIdentifier(identifier) this._formatMessage(msg, extra))
    }

    /**
    * @param string title
    * @param ?string msg
    * @param ?string identifier
    * @param ?string extra
    * @return string
    */
    info(title, msg := "", identifier := "", extra := "")
    {
        return this.log(title, this._formatIdentifier(identifier) this._formatMessage(msg, extra))
    }

    /**
    * @param string msg
    * @param string identifier
    * @return void
    */
    runCallback(identifier, msg)
    {
        if (!this.CALLBACK) {
            return
        }

        try {
            this.CALLBACK.Call(identifier, msg)
        } catch e {
            this.out("ERROR", "Exception on callback: " e.Message " | " e.What, " | " A_ScriptName)
        }
    }

    /**
    * @param string msg
    * @param string identifier
    * @return string
    */
    log(identifier := "", msg := "")
    {
        try {
            this.out("[" A_ScriptName "] " identifier, msg)
        } catch {
        }

        this.runCallback(identifier, msg)

        return msg
    }

    /**
    * @param string identifier
    * @param string msg
    * @return void
    */
    out(identifier, msg)
    {
        OutputDebug(identifier, msg)
    }

    /**
    * @param Exception e
    * @param ?string identifier
    * @param ?string extra
    * @return string
    */
    exception(e, identifier := "", extra := "")
    {
        return this.error("Message: " e.Message " | What: " e.What, identifier, extra)
    }

    /**
    * @param int icon
    * @param Exception e
    * @param ?string identifier
    * @param ?string extra
    * @return string
    * @msgbox
    */
    msgboxException(icon, e, identifier := "", extra := "")
    {
        this.exception(e, identifier, extra)
        if (A_IsCompiled) {
            msgbox, % icon, % identifier, % e.Message (extra ? "`n" extra : "")
            msgbox, % icon, % identifier, % e.Message (extra ? "`n" extra : "") "`n" e.What
        } else {
            msgbox, % icon, % identifier, % e.Message "`n`n" e.What (extra ? "`n" extra : "")
        }
    }

    /**
    * @param int icon
    * @param Exception e
    * @param ?string identifier
    * @param ?string extra
    * @return string
    * @msgbox
    */
    msgboxExceptionOnLocal(e, identifier := "", extra := "")
    {
        this.exception(e, identifier, extra)
        if (A_IsCompiled) {
            return
        }

        msgbox, 16, % identifier, % e.Message "`n`n" e.What "`n" extra
    }

    /**
    * @param string msg
    * @param string extra
    * @return string
    */
    _formatMessage(msg, extra)
    {
        return msg .= extra ? " (Extra: " extra ")" : ""
    }

    /**
    * @param string identifier
    * @return string
    */
    _formatIdentifier(identifier)
    {
        return (identifier ? "[" identifier "] " : "")
    }
}