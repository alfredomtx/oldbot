
class _Thread extends _BaseClass
{
    static THREADS := {}

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        this.criticalObject := {}
    }

    setCode(code)
    {
        _Validation.string("code", code)
        this.code := code

        return this
    }

    setData(object)
    {
        _Validation.isObject("object", object)

        this.data := ""
        this.data := CriticalObject(object)

        return this
    }

    start()
    {
        static validated
        local data

        data := this.data

        this.thread := ahkThread(this.getDefaultCode() "`n" this.code, &data "")
        _Thread.THREADS[this.thread.hThread] := true

        return this
    }

    stop()
    {
        ahkthread_free(this.thread)
        this.thread.ahkTerminate()

        _Thread.THREADS.Delete(this.thread.hThread)

        this.thread := ""
        this.criticalObject := ""

        return this
    }

    getDefaultCode()
    {
        var := "
        (
            #NoTrayIcon
            #Persistent
            DATA := CriticalObject(A_Args[1])
        )"

        return var
    }

}