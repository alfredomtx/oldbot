
class _AbstractUpdaterRequest extends _AbstractRequest
{
    setVersion(version)
    {
        this.version := version

        return this
    }

    getHost()
    {
        return _AbstractRequest.WS2_HOST
    }

    getRequestBody()
    {
        body := this.getBody()

        _Validation.isObject("body", body)
        _Validation.empty("this.version", this.version)

        body.version := "" this.version ""

        return body
    }

}