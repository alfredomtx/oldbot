class _GetAvailableVersionsRequest extends _AbstractRequest
{
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New(receiveBeta)
    {
        base.__New()

        this.receiveBeta := receiveBeta
        this.disableLog()
    }

    execute()
    {
        try {
            return base.execute()
        } catch e {
            if (e.What == "UnauthorizedStatusCode") {
                    ; new _LoginRequest().execute()
            }

            throw e
        }
    }


    getRoute()
    {
        return "/api/updater/getVersions"
    }

    getMethod()
    {
        return "GET"
    }
}