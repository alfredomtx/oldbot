

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

/**
* @property string name
* @property ?int pid
*/
class _Process extends _BaseClass
{
    __New(name, pid := "")
    {
        this.setName(name)
        this.setPid(pid)
    }

    FROM_HWID(hwid)
    {
        WinGet, processId, PID, % "ahk_id " hwid
        WinGet, exeName, ProcessName, % "ahk_id " hwid

        if (!processId || !exeName) {
            return
        }

        return new this(exeName, processId)
    }

    getName()
    {
        return this.name
    }

    getPid()
    {
        return this.pid
    }

    setName(name)
    {
        _Validation.empty("name", name)
        this.name := name

        return this
    }

    setPid(pid)
    {
        _Validation.numberOrEmpty("pid", pid)
        this.pid := pid

        return this
    }
}