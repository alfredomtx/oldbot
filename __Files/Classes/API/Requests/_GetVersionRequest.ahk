class _GetVersionRequest extends _AbstractRequest
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

    getRoute()
    {
        return "/api/updater/version?beta=" this.receiveBeta
    }

    getMethod()
    {
        return "GET"
    }
}