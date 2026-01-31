
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Action Script\Actions\_AbstractActionScript.ahk

class _GoToLabelAction extends _AbstractActionScript
{
    static IDENTIFIER := "gotolabel"
    static LABEL_CURRENT_WAYPOINT := "CurrentWaypoint"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * FIMXE: it is not handling when it is from another exe like Persistent?o
    * @return bool
    */
    runAction()
    {
        functionValues := this.values
        this.info(ActionScript.string_log)
        functionName := "gotolabel"

        params := {}
            , params.labelName := functionValues.1
            , params.abort := functionValues.2

            , params := this.checkParamsVariables(params)
            , params.abort := (params.abort = "" && params.abort != false) ? true : params.abort

        label := params.labelName
        if (!label) {
            this.error(txt("Nenhum label foi especificado", "No label was specified"))

            return false
        }


        if (ActionScript.actionScriptType = "persistent") {
            _CavebotExeMessage.goToLabel(label, 2000)
            return true
        }

        this.info(_Str.quoted(label) " | " params.abort)

        if label is number
        {
            return this.handleNumberLabel(label, params)
        }

        if (label == this.LABEL_CURRENT_WAYPOINT) {
            Waypoint--
            returnLabelWaypoint := true
            ActionScript.gotolabelWaypointRan := true
            this.stopWalkingToWaypointTimerLabel()

            ; targetingSystemObj.targetingDisabledAction := false
            ; restoreTargetingIcon()
            ; Sleep, % TargetingSystem.TargetingTimer + (TargetingSystem.TargetingTimer / 2)
            return 
        }

        labelSearch := this.labelSearch(label)

        if (labelSearch.labelFound = false) {
            this.error(LANGUAGE = "PT-BR" ? "Label """ label """ não existe" : "Label """ label """ does not exist")

            return false
        }

        Waypoint := labelSearch.waypointFound
        tab := labelSearch.tabFound
        tab_prefix := labelSearch.tabFound "_"
        sessionString := "[" tab "]"

        this.info(LANGUAGE = "PT-BR" ? "Iniciando waypoint " Waypoint " do label """ label """, aba """ tab """" : "starting waypoint " Waypoint " of label """ label """, tab '" tab """")
        Waypoint--
        ; msgbox, label %waypoint% / tab: %tab%
        returnLabelWaypoint := params.abort
        IniWrite, % tab, %DefaultProfile%, cavebot, CurrentWaypointTab
        ActionScript.gotolabelWaypointRan := true
        this.stopWalkingToWaypointTimerLabel()
        return true
    }

    handleNumberLabel(label, params)
    {
        if (!waypointsObj[tab][label]) {
            this.error(txt("Não há waypoint número """ label """ na aba """ tab """", "There is no waypoint number """ label """ in """ tab """ tab"))

            return false
        }

        Waypoint := label - 1

        returnLabelWaypoint := params.abort
        ActionScript.gotolabelWaypointRan := true
        this.stopWalkingToWaypointTimerLabel()
        return true
    }


    stopWalkingToWaypointTimerLabel()
    {
        /*
        stop cavebot clicking on waypoint timer
        for when an external script makes the Cavebot run gotolabel action
        */
        CURRENT_WALK_TO_COORDINATE.destination.deleteTimer()
    }

    handleMessage(label)
    {
        this.warning("gotolabel """ label """ requested by external script", A_ThisFunc)
        _WalkToCoordinate.INSTANCE.destination.setIgnored("go to label external")

            new _StopWalking()



        return new this().setValues(Array(label)).run()
    }

    splitSlashLabel(label)
    {
        labelTab := _Arr.first(StrSplit(label, "/"))
        labelWaypoint := _Arr.last(StrSplit(label, "/"))

        return {"tab": labelTab, "waypoint": labelWaypoint}
    }

    labelSearch(label)
    {
        if (InStr(label, "/")) {
            label := this.splitSlashLabel(label)
            return WaypointHandler.findLabel(label.waypoint, label.tab)
        }

        return WaypointHandler.findLabel(label)
    }

}