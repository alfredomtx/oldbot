
Class _ProcessHandler
{
    __New()
    {
    }

    /**
    returns array of process or false in case none is found
    */
    findProcessByName(exeName)
    {
        processes := {}
        for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where CommandLine like '%" exeName "%'")
        {      
            if (InStr(process.Name, exeName)) {
                processes[process.ProcessId] := {}
                    , processes[process.ProcessId].name := process.Name
                    , processes[process.ProcessId].xcommandLine := process.CommandLine
                    , processes[process.ProcessId].description := process.description
                ; , processes[process.ProcessId].pid := process.ProcessId
            }
        }

        return processes.Count() < 1 ? false : processes
    }

    readExePID(exeIdentifier, debug := false)
    {
        IniRead, ExePID, %DefaultProfile%, settings, %exeIdentifier%_Process, %A_Space%
        if (debug) {
            msgbox, % exeIdentifier "`npid: " ExePID
        }

        return (ExePID = A_Space) ? "" : ExePID
    }

    readExeName(ExeIdentifier)
    {
        exeName := ""
        switch ExeIdentifier {
            case "alertsExeName":
                IniRead, exeName, %DefaultProfile%, settings, %ExeIdentifier%, Alerts.exe
            case "cavebotExeName":
                IniRead, exeName, %DefaultProfile%, settings, %ExeIdentifier%, Cavebot.exe
            case "fishingExeName":
                IniRead, exeName, %DefaultProfile%, settings, %ExeIdentifier%, Fishing.exe
            case "fullLightExeName":
                IniRead, exeName, %DefaultProfile%, settings, %ExeIdentifier%, FullLight.exe
            case "healingExeName":
                IniRead, exeName, %DefaultProfile%, settings, %ExeIdentifier%, Healing.exe
            case "hotkeysExeName":
                IniRead, exeName, %DefaultProfile%, settings, %ExeIdentifier%, Hotkeys.exe
            case "itemRefillExeName":
                IniRead, exeName, %DefaultProfile%, settings, %ExeIdentifier%, ItemRefill.exe
            case "reconnectExeName":
                IniRead, exeName, %DefaultProfile%, settings, %ExeIdentifier%, Reconnect.exe
            case "sioFriendExeName":
                IniRead, exeName, %DefaultProfile%, settings, %ExeIdentifier%, SioFriend.exe
            case "supportExeName":
                IniRead, exeName, %DefaultProfile%, settings, %ExeIdentifier%, Support.exe
            case "persistentExeName":
                IniRead, exeName, %DefaultProfile%, settings, %ExeIdentifier%, Persistent.exe
        }

        return exeName
    }

    deleteExePID(ExeIdentifier)
    {
        IniDelete, %DefaultProfile%, settings, %ExeIdentifier%_Process
    }

    writeExePID(ExeIdentifier)
    {
        PID := DllCall("GetCurrentProcessId")
        IniWrite, % PID, %DefaultProfile%, settings, %ExeIdentifier%_Process
        return PID
    }

    writeModuleExePID(moduleName)
    {
        return this.writeExePID(moduleName "ExeName")
    }

    openProcess(exeName)
    {

    }


}