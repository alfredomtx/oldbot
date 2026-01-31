global threads := {}

Class _ThreadManager  {


    insertThread(threadName) {
        threads.Push(threadName)
    }

    releaseThread(threadName) {
        %threadName%.ahkassign("releaseThread","1")
    }

    createThread(threadName, script, criticalObj := "") {
        global
        threads.Push(threadName)
        if (!script) {
            return
        }
        try {
            if (criticalObj) {
                return ahkThread(script, &criticalObj "")
            }

            return ahkThread(script)
        } catch e {
            threads.Delete(threadName)
            throw Exception(e)
        }
    }

    checkThreadFinished(threadName, finishThread := true, debug := false) {
        if (debug) {
            msgbox, % A_ThisFunc "`nthreadName = " threadName "`nstate = " %threadName%.ahkReady()
        }

        try { 
            return %threadName%.ahkReady()
        } catch e {
            Msgbox, 48, % A_ThisFunc, % e.Message "`n" e.What
            return
        }

        threadNumber := this.getThreadNumber(threadName)

        finished := %threadName%.ahkgetvar.threadFinished
        if (!finishThread) {
            return finished
        }

        if (finished) {
            this.finishThread(threadName, threadNumber)
        }
    }

    showThreads() {
        msgbox, % serialize(threads)
    }

    /**
    * @throws
    */
    getThreadNumber(threadName) {
        for key, value in threads {
            if (value = threadName) {
                return key
            }
        }

        throw Exception("Thread not found: " threadName "`n`n" serialize(threads))
    }

    finishThread(threadName, threadNumber := "") {
        if (!threadNumber) {
            threadNumber := this.getThreadNumber(threadName)
        }

        threadToFinish := threads[threadNumber]
        ahkthread_free(%threadToFinish%)

        %threadToFinish%.ahkTerminate() 
        %threadToFinish% := ""

        threads.RemoveAt(threadNumber)
    }

}
