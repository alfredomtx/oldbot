
class _ClientJson extends _BaseClass
{
    ;#Region Getters
    get(key, default := "")
    {
        ; FIXME: use entire file path to append to dot key instead of just the file name
        return jconfig(this.getFile() "." key, default, this.getFolder())
    }

    load()
    {
        return _Json.load(this.getFolder() "\" this.getFile() ".json")
    }

    getFolder()
    {
        abstractMethod()
    }

    getFile()
    {
        abstractMethod()
    }
    ;#EndRegion

    ;#Region Setters
    ;#EndRegion

    ;#Region Predicates
    ;#EndRegion

    ;#Region Factory
    ;#EndRegion
}