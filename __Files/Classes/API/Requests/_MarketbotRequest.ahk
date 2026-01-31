#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Requests\_AbstractRequest.ahk

class _MarketbotRequest extends _AbstractRequest
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    getBody()
    {
        email := _Ini.read("loginEmail", "accountsettings")

        ;@Ahk2Exe-IgnoreBegin
        if (!A_IsCompiled) && (empty(email)) {
            email := ""
        }
        ;@Ahk2Exe-IgnoreEnd

        _Validation.empty("email", email)

        return {"email": email}
    }

    getHost()
    {
        return _AbstractRequest.WS_HOST
    }

    getRoute()
    {
        return "/api/marketbot/license"
    }
}