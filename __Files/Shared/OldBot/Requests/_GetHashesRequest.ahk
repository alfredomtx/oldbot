class _GetHashesRequest extends _AbstractUpdaterRequest
{
    __New()
    {
        base.__New()

        this.disableLog()
    }

    getRoute()
    {
        return "/api/updater/hashes"
    }
}