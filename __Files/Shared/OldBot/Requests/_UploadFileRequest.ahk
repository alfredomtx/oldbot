
class _UploadFileRequest extends _AbstractUpdaterRequest
{
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    setFile(file, hash)
    {
        _Validation.fileExists("file", file)
        this.file := file
        this.hash := hash

        return this
    }

    getBody()
    {
        SplitPath, % this.file, fileName, path
        return {"file": [this.file], "path": path, "hash": this.hash}
    }

    getRoute()
    {
        return "/api/updater/upload"
    }
}
