

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

global queueThreadObj
/**
* @property array<string, ?int> queue
* @property array<string, ?int> runningQueue
* @property array<string> errors
*/
class _ProcessQueue extends _BaseClass
{
    static queue := {}
    static errors := {}
    static runningQueue

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    add(process)
    {
        _Validation.instanceOf("process", process, _Process)

        this.queue[process.getName()] := process.getPid()
    }

    run()
    {
        global queueThreadObj
        _Logger.log(A_ThisFunc)

        if (this.runningQueue.Count() > 0) {
            return
        }

        this.runningQueue := this.queue.Clone()
        queueThreadObj := CriticalObject({"queue": this.runningQueue, "test": 0, "executablesFolder": (_AbstractExe.usesRandomName() ? _Folders.EXECUTABLES_TEMP : _Folders.EXECUTABLES) })

        AhkThread("
        (
            #Persistent
            #NoTrayIcon

            t1 := A_TickCount
            data := CriticalObject(A_Args[1])
            count := data.queue.Count()
            data.test := 1
            executablesFolder := data.executablesFolder
            data.ran := {}

            ; OutputDebug, OldBot | Running queue: %count%

            for name, pid in data.queue {
                Process, Exist, % pid
                if (pid) {
                    OutputDebug, OldBot | Process Queue: Closing %name%: %pid%
                    Process, Close, % pid
                    Sleep, 500

                    Process, Exist, % pid
                    if (ErrorLevel) {
                        msgbox,16, PROCESS QUEUE ERROR: %name%, Failed to close process %name%: %pid%
                    }
                }

                try {
                    dir = %A_WorkingDir%\%executablesFolder%\%name%
                    msg = O executavel %dir% nao existe, o antivirus pode ter deletado o arquivo. Rode o instalador novamente na opcao REPARAR.
                    if (!FileExist(dir)) {
                        msgbox, 16, PROCESS QUEUE ERROR: %name%, %msg%
                    } else {
                        OutputDebug, OldBot | Running %name%
                        Run, %dir%
                        Sleep, 1000
                    }

                    data.ran[name] := true
                } catch e {
                    error := e.Message
                    OutputDebug, OldBot | PROCESS QUEUE ERROR: %name%, %error%
                    msgbox,16, Process Queue Error: %name%, %error%
                }
            }

            data.queue := {}


            elapsed := A_TickCount - t1
            ; OutputDebug, OldBot | Finished queue: %elapsed%ms
            ExitApp

            )", &queueThreadObj "")
    }

    checkEmptyQueue()
    {
        this.runningQueue := queueThreadObj.queue
        this.ran := queueThreadObj.ran
        ; OutputDebug("checking", this.runningQueue.Count() " | " se(this.queue) " | " se(this.ran))
        if (this.runningQueue.Count() == 0) {
            if (this.checkProcessesThatDidNotRun()) {
                this.deleteEmptyQueueTimer()
                return
            }

            ; OutputDebug("more processes pending to run", se(this.queue))
            this.run()
        }
    }

    checkProcessesThatDidNotRun()
    {
        removeFromQueue := {}
        for toRun, _ in this.queue {
            for didRun, _ in this.ran {
                if (toRun = didRun) {
                    removeFromQueue.Push(didRun)
                }
            }
        }

        for _, name in removeFromQueue {
            this.queue.Delete(name)
            ; OutputDebug("Deleting", name)
        }

        return this.queue.Count() == 0
    }

    setTimer()
    {
        queueTime := 500
        if (!this.runTimer) {
            this.runTimer := _ProcessQueue.run.bind(_ProcessQueue)
        }

        fn := this.runTimer
        settimer, % fn, Delete
        settimer, % fn, -%queueTime%

        this.deleteEmptyQueueTimer()

        fn := this.emptyQueueTimer
        settimer, % fn, % queueTime, 99
    }

    deleteEmptyQueueTimer()
    {
        if (!this.emptyQueueTimer) {
            this.emptyQueueTimer := _ProcessQueue.checkEmptyQueue.bind(_ProcessQueue)
        }

        fn := this.emptyQueueTimer
        settimer, % fn, Delete
    }

}