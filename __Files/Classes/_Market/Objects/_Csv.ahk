
/**
* @property string filePath
* @property string header
*/
class _Csv extends _BaseClass
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(filePath, header)
    {
        this.header := header
        this.filePath := filePath

        try {
            if (!FileExist(this.filePath)) {
                FileAppend, % this.header "`n", % this.filePath 
            }
        }

        _Validation.fileExists("this.filePath", this.filePath)
    }

    PATH(fileName)
    {
        return _Folders.MARKET_ROOT "\" fileName
    }

    log(line)
    {
        try {
            FileAppend, % line "`n", % this.filePath 
        }

        return this
    }

    ;#region Getters
    ;#endregion

    ;#region Setters
    ;#endregion
}