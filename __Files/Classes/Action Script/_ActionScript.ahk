#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\action_scripts_list.ahk

global NO_LOGS := false


global returnLabelWaypoint := false

global functionParamsNumber := 10

global lastImageSearchX
global lastImageSearchY
global lastItemSearchX
global lastItemSearchY

global actionScriptsVariablesObj


class _ActionScript extends _ActionScriptValidation
{

    __New()
    {
        classLoaded("_ActionScriptValidation", _ActionScriptValidation)

        functionParamsNumber := 10

        this.tradeWindow := {}

        this.settingsWriteJson := {}
        this.settingsWriteJson.Push("alerts")
        this.settingsWriteJson.Push("fishing")
        this.settingsWriteJson.Push("fullLight")
        this.settingsWriteJson.Push("healing")
        this.settingsWriteJson.Push("looting")
        this.settingsWriteJson.Push("itemRefill")
        this.settingsWriteJson.Push("navigation")
        this.settingsWriteJson.Push("scriptVariables")
        this.settingsWriteJson.Push("scriptSettings")
        this.settingsWriteJson.Push("selectedFunctions")
        this.settingsWriteJson.Push("sioFriend")
        this.settingsWriteJson.Push("support")
        this.settingsWriteJson.Push("persistent")
        this.settingsWriteJson.Push("reconnect")
        this.settingsWriteJson.Push("targeting")
        this.settingsWriteJson.Push("waypoints")

        this.scriptVariables := {}

        this.uncompatibleString := " @uncompatible"


        this.pauseModuleManager := {}
        this.tradeListScriptImageItems := {}

        _Logger.SET_CALLBACK(this.logger.bind(this))
    }

    logger(identifier, msg)
    {
        writeCavebotLog(identifier, msg)
    }

    ActionScriptWaypoint(Waypoint, actionExternalCode := "", type := "") {
        global initialString

        this.actionScriptType := type
        switch this.actionScriptType {
            case "hotkey", case "persistent":
                tab := ""
                ArrayVars := StrSplit(StrReplace(actionExternalCode, "`n", "<br>"), "<br>")
            default:
                ArrayVars := StrSplit(StrReplace(waypointsObj[tab][Waypoint]["action"], "`n", "<br>"), "<br>")
        }

        if (!IsObject(WaypointHandler)) {
            writeCavebotLog("ERROR", "WaypointHandler not initialized")
            return false
        }

        ; m(serialize(ArrayVars))


        for line, lineContent in ArrayVars
        {
            lineContent := LTrim(RTrim(lineContent))
            ; msgbox, % line "`n" """" lineContent """"
            if (lineContent = "" OR lineContent = A_Space)
                continue

            hashtag := SubStr(lineContent, 1, 1)
            if (hashtag = "#")
                continue

            ; msgbox, % Waypoint "`n" lineContent
            if (lineContent = "return")
                return

            returnLabelWaypoint := false

            if (_ActionScriptValidation.isVariableAndPeformAction(lineContent, line, true, tab, Waypoint) = true)
                continue

            initialString := LANGUAGE = "PT-BR" ? "Linha: " line "`nFunção: " lineContent "`n`n[ ERRO: ]`n" : "Line: " line "`nFunction: " lineContent "`n`n[ ERRO: ]`n"

            if (!InStr(lineContent, ")")) {
                writeCavebotLog("Action", this.string_log (LANGUAGE = "PT-BR" ? "Erro de sintáxe, faltando o caractére "")""." : "Syntax error, missing the character "")""."))
                continue
            }

            if (!InStr(lineContent, "(")) {
                writeCavebotLog("Action", this.string_log (LANGUAGE = "PT-BR" ? "Erro de sintáxe, faltando o caractére ""(""." : "Syntax error, missing the character ""(""."))
                continue
            }

            this.string_log := "[L: " line ", F: " lineContent "] "

            ; writeCavebotLog("Action", this.string_log (LANGUAGE = "PT-BR" ? " Iniciando ações.." : "Starting actions.." ))

            ifString := SubStr(lineContent, 1, 2)
            ; msgbox, % ifString "`n`n" lineContent
            if (ifString = "if")
            {
                ; validation := _ActionScriptValidation.validateIfStatement(lineContent)
                ; if (validation != "") {
                ;     writeCavebotLog("ERROR", this.string_log "" validation)
                ;     continue
                ; }
                this.actionIfFunction(lineContent, line, tab, Waypoint)
                if (returnLabelWaypoint = true)
                    return
                continue

            }

            try { ; added on 25/06
                this.performActionScript(lineContent, A_ThisFunc)
            } catch e {
                writeCavebotLog("ERROR", "[Perform action] " this.string_log "" e.Message " | " e.what)
                _Logger.exception(e, "[Perform action] " this.string_log, lineContent)
            }

            if (returnLabelWaypoint = true)
                return

        }
    }

    /*
    perform the action script function
    return:
    -1 - function doesn't exist
    */
    performActionScript(lineContent, funcOrigin)
    {
        functionValues := _ActionScriptValidation.getFunctionValues(lineContent)
        functionName := _ActionScriptValidation.getFunctionNameNoParenthesis(lineContent)
        return this.performActionScriptFunction(functionName, functionValues, A_ThisFunc)
    }

    performActionScriptFunction(functionName, functionValues, funcOrigin)
    {
        /*
        disable targeting for the action if is not "wait" action
        */
        if (functionName != "wait") {
            targetingSystemObj.targetingDisabledAction := true
            TargetingSystem.setStatusBarIcon("imageres.dll", isWin11() ? 313 : 312)
        }

        if (!isCavebotExecutable()) {
            IniRead, Waypoint, %DefaultProfile%, cavebot, CurrentWaypoint, %A_Space%
            IniRead, tab, %DefaultProfile%, cavebot, CurrentWaypointTab, %A_Space%
        }

        action := ""
        try {
            action := new _ActionScriptFactory(functionName)
        } catch e {
        }

        if (action) {
            try {
                actionResult := action
                    .setValues(functionValues)
                    .run()
            } catch e {
                _Logger.exception(e, A_ThisFunc, functionName)
            }

            goto, _actionRan
        }

        switch functionName {
            case "alarmplay":               actionResult := this.alarmplay(functionValues)
            case "alarmstop":               actionResult := this.alarmstop(functionValues)
            case "battlelistchangeorder":   actionResult := this.battlelistchangeorder(functionValues)
            case "battlelistchangesize":    actionResult := this.battlelistchangesize(functionValues)
            case "buyitemnpc":              actionResult := this.buyitemnpc(functionValues)
            case "capacity":                actionResult := this.capacity()
            case "chatcontains":            actionResult := this.chatcontains(functionValues)
            case "cleardefaultchat":        actionResult := this.cleardefaultchat(functionValues)
            case "clearserverlogchat":      actionResult := this.clearserverlogchat(functionValues)
            case "clickonfollowoption":     actionResult := this.clickonfollowoption(functionValues)
            case "clickonitem":             actionResult := this.clickonitem(functionValues)
            case "clickonimage":            actionResult := this.clickonimage(functionValues)
            case "clickonposition":         actionResult := this.clickonposition(functionValues)
            case "clickonsqm":              actionResult := this.clickonsqm(functionValues)
            case "closebackpack":           actionResult := this.closebackpack(functionValues)
            case "closecavebot":            actionResult := this.closecavebot(functionValues)
            case "convertgold":             actionResult := this.convertgold(functionValues)
            case "creaturesbattlelist":     actionResult := this.creaturesbattlelist(functionValues)
            case "creaturesaround":         actionResult := this.creaturesaround(functionValues)
            case "deposittostash":          actionResult := this.deposittostash(functionValues)
            case "depositmoney":            actionResult := this.depositmoney()
            case "distancelooting":         actionResult := this.distancelooting(functionValues)
            case "droplootonground":        actionResult := this.droplootonground(functionValues)
            case "droptrash":               actionResult := this.droptrash(functionValues)
            case "exitgame":                actionResult := this.exitgame(functionValues)
            case "focusclient":             actionResult := this.focusclient(functionValues)
            case "follow":                  actionResult := this.follow(functionValues)
            case "follownpc":               actionResult := this.follownpc(functionValues)
            case "forcewalkarrow":          actionResult := this.forcewalkarrow(functionValues)
            case "forcewalkarrowstop":      actionResult := this.forcewalkarrowstop(functionValues)
            case "getbalance":              actionResult := this.getbalance(functionValues)
            case "gotolabel":               actionResult := this.gotolabel(functionValues)
            case "hascooldown":             actionResult := this.hascooldown(functionValues)
            case "isattacking":             actionResult := this.isattacking(functionValues)
            case "isbattlelistempty":       actionResult := this.isbattlelistempty(functionValues)
            case "isplayersbattlelistempty":actionResult := this.isplayersbattlelistempty()
            case "isdisconnected":          actionResult := this.isdisconnected(functionValues)
            case "isfollowing":             actionResult := this.isfollowing(functionValues)
            case "islocation":              actionResult := this.islocation(functionValues)
            case "itemcount":               actionResult := this.itemcount(functionValues)
            case "itemsearch":              actionResult := this.itemsearch(functionValues)
            case "imagesearch":             actionResult := this.imagesearch(functionValues)
            case "level":                   actionResult := this.level(functionValues)
            case "lifepercent":             actionResult := this.lifepercent(functionValues)
            case "luremode":                actionResult := this.luremode(functionValues)
            case "luremodestop":            actionResult := this.luremodestop()
            case "luremodewalkingattack":   actionResult := this.luremodewalkingattack(functionValues)
            case "luremodewalkingattackstop":   actionResult := this.luremodewalkingattackstop()
            case "log":                     actionResult := this.log(functionValues)
            case "lootaround":              actionResult := this.lootaround(functionValues)
            case "manapercent":             actionResult := this.manapercent(functionValues)
            case "math":                    actionResult := this.math(functionValues)
            case "m":                       actionResult := this.messagebox(functionValues)
            case "messagebox":              actionResult := this.messagebox(functionValues)
            case "minimapheight":           actionResult := this.minimapheight(functionValues)
            case "minimapcenter":           actionResult := this.minimapcenter(functionValues)
            case "minimapzoom":             actionResult := this.minimapzoom(functionValues)
            case "mousedrag":               actionResult := this.mousedrag(functionValues)
            case "mousedragimage":          actionResult := this.mousedragimage(functionValues)
            case "mousedragimageitem":      actionResult := this.mousedragimageitem(functionValues)
            case "mousedragimageposition":  actionResult := this.mousedragimageposition(functionValues)
            case "mousedragitem":           actionResult := this.mousedragitem(functionValues)
            case "mousedragitemimage":      actionResult := this.mousedragitemimage(functionValues)
            case "mousedragitemposition":   actionResult := this.mousedragitemposition(functionValues)
            case "mousemove":               actionResult := this.mousemove(functionValues)
            case "notification":            actionResult := this.traytip(functionValues)
            case "npchi":                   actionResult := this.npchi(log := true)
            case "npctrade":                actionResult := this.npctrade(log := true)
            case "openbackpack":            actionResult := this.openbackpack(functionValues)
            case "pausemodule":             actionResult := this.pausemodule(functionValues)
            case "presskey":                actionResult := this.presskey(functionValues)
            case "say":                     actionResult := this.say(functionValues, log := true)
            case "screenshot":              actionResult := this.screenshot(functionValues)
            case "randomnumber":            actionResult := this.randomnumber(functionValues)
            case "reloadcavebot":           actionResult := this.reloadcavebot(functionValues)
            case "resetsession":            actionResult := this.resetsession(functionValues)
            case "reachlocation":           actionResult := this.reachlocation(functionValues)
            case "runactionwaypoint":       actionResult := this.runactionwaypoint(functionValues)
            case "sellitemnpc":             actionResult := this.sellitemnpc(functionValues)
            case "sellallitemsnpc":         actionResult := this.sellallitemsnpc(functionValues)
            case "setlocation":             actionResult := this.setlocation(functionValues)
            case "setsetting":              actionResult := this.setsetting(functionValues)
            case "soulpoints":              actionResult := this.soulpoints(functionValues)
            case "stamina":                 actionResult := this.stamina(functionValues)
            case "takeitemfromstash":       actionResult := this.takeitemfromstash(functionValues)
            case "targetingenable":         actionResult := this.targetingenable(functionValues)
            case "targetingdisable":        actionResult := this.targetingdisable(functionValues)
            case "telegrammessage":         actionResult := this.telegrammessage(functionValues)
            case "telegramscreenshot":      actionResult := this.telegramscreenshot(functionValues)
            case "transfergold":            actionResult := this.transfergold(functionValues)
            case "travel":                  actionResult := this.travel(functionValues)
            case "traytip":                 actionResult := this.traytip(functionValues)
            case "turn":                    actionResult := this.turn(functionValues)
            case "turnchaton":              actionResult := this.turnchaton(functionValues)
            case "turnchatoff":             actionResult := this.turnchatoff(functionValues)
            case "useitem":                 actionResult := this.useitem(functionValues)
            case "useitemoncorpses":        actionResult := this.useitemoncorpses(functionValues)
            case "usesqm":                  actionResult := this.usesqm(functionValues)
            case "unpausemodule":           actionResult := this.unpausemodule(functionValues)
            case "variable":                actionResult := this.variable(functionValues)
            case "variableshowall":         actionResult := this.variableshowall(functionValues)
            case "wait":                    actionResult := this.wait(functionValues)
            case "waypointdistance":        actionResult := this.waypointdistance(functionValues)
            case "write":                   actionResult := this.write(functionValues, true)
            default:
                targetingSystemObj.targetingDisabledAction := false
                restoreTargetingIcon()
                writeCavebotLog("ERROR", this.string_log " function """ functionName """ doesn't exist")
                return -1
        }

        _actionRan:

        targetingSystemObj.targetingDisabledAction := false
        restoreTargetingIcon()

        return actionResult
    }

    actionIfFunction(lineContent, line, tabName, waypointNumber) {
        ifStatement := WaypointHandler.getifStatement(lineContent)
        thenStatement := WaypointHandler.getThenStatement(lineContent)

        conditionStatement := WaypointHandler.getConditionParams(ifStatement)
        ; msgbox, % serialize(conditionStatement)

        validation := WaypointHandler.validateConditionParams(conditionStatement)
        if (validation != "") {
            writeCavebotLog("ERROR", this.string_log "" validation)
            return false
        }

        if (InStr(lineContent, " else ")) {
            elseStatement := WaypointHandler.getElseStatement(lineContent)
            validation := WaypointHandler.validateElseStatement(elseStatement)
            if (validation != "") {
                writeCavebotLog("ERROR", this.string_log "" validation)
                return false
            }
        }

        conditionValue1 := conditionStatement.2
        condition := conditionStatement.3
        conditionValue2 := conditionStatement.4

        ; msgbox, % conditionValue1 "," condition "," conditionValue2

        writeCavebotLog("Condition", "if (" conditionValue1 " " condition " " conditionValue2 ")")

        if (InStr(conditionValue1, "(") && InStr(conditionValue1, ")")) { ; if it is a function and not a variable/word
            conditionValue1 := _ActionScriptValidation.getVariableFunctionValue(conditionValue1, tabName, waypointNumber)
            ; msgbox, % conditionValue1
        }
        /*
        if is a variable: $teste
        */
        else if (_ActionScriptValidation.isVariableString(conditionValue1) = true) {
            ; msgbox, % conditionValue1
            conditionValue1 := _ActionScriptValidation.getValueFromActionScriptVariable(conditionValue1, tabName, waypointNumber)
            ; msgbox, conditionValue1 is variable: %conditionValue1%
        } else { ; if is a word, example: A_Hour
            varName := conditionValue1
            try conditionValue1 := %conditionValue1%
            catch {
            }
            if (conditionValue1 = "")
                writeCavebotLog("Condition", "variable """ varName """ has no value")
        }
        if (_ActionScriptValidation.isVariableString(conditionValue2) = true) {
            ; msgbox, conditionValue2 is variable
            conditionValue2 := _ActionScriptValidation.getValueFromActionScriptVariable(conditionValue2, tabName, waypointNumber)
        }
        conditionStatus := this.checkActionCondition(conditionValue1, condition, conditionValue2)

        writeCavebotLog("Condition", "condition " (conditionStatus = true ? "true" : "false") ": if (" conditionValue1 " " condition " " conditionValue2 ")")
        ; msgbox, % "conditionStatus = " conditionStatus "`n" conditionValue1 "," condition "," conditionValue2

        actionStatement := ""
        switch conditionStatus {
                ; do the then statement
            case true:
                ; msgbox, % thenStatement
                string := "then"
                actionStatement := thenStatement
                ; msgbox, % "functionName = " functionName "`n" serialize(functionValues)

                ; do the else statement
            case false:
                actionStatement := elseStatement
                string := "else"
                ; msgbox, % elseStatement
        }
        ; msgbox, % ifStatement "`nconditionStatus = " conditionStatus  "`nthenStatement = '" thenStatement "'`nelseStatement = '" elseStatement "'`nactionStatement = '" actionStatement "'"

        this.string_log := "[L: " line ", F: (" string ") " actionStatement "] "

        if (conditionStatus = true) && (thenStatement = "return" OR elseStatement = "return") {
            ; msgbox, return
            returnLabelWaypoint := true
            this.string_log := "[L: " line ", F: (" string ") return] "
            writeCavebotLog("Action", this.string_log)
            return true
        }
        if (actionStatement = "") ; no else after the IF
            return true

        return this.performActionScript(actionStatement, A_ThisFunc)
    }

    checkActionCondition(conditionValue1, condition, conditionValue2) {
        if (conditionValue2 = "true")
            conditionValue2 := true
        if (conditionValue2 = "false")
            conditionValue2 := false
        if (conditionValue2 = "null")
            conditionValue2 := ""
        ; msgbox, % "checkActionCondition`n`n" conditionValue1 "," condition "," conditionValue2
        switch condition {
            case "<":
                if (conditionValue1 < conditionValue2)
                    return true
            case ">":
                if (conditionValue1 > conditionValue2)
                    return true
            case "=":
                if (conditionValue1 = conditionValue2)
                    return true
            case "!=":
                if (conditionValue1 != conditionValue2) {
                    return true
                }
            case ">=":
                if (conditionValue1 >= conditionValue2)
                    return true
            case "<=":
                if (conditionValue1 <= conditionValue2)
                    return true
        }
        return false
    }

    alarmplay(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "alarmplay"

        try Run, % "Data\Executables\Alarm.exe"
        catch e {
            writeCavebotLog("ERROR", (functionName ": ")  "Failed to open alarm at Data\Executables\Alarm.exe")
            return false
        }

        writeCavebotLog("Action", (functionName ": ") "Alarm started, press Shift+Esc to stop it")
        return true
    }

    alarmstop(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "alarmstop"

        Process, Close, Alarm.exe
    }

    battlelistchangeorder(functionValues := "", sendEsc := true) {
        writeCavebotLog("Action", this.string_log)
        functionName := "battlelistchangeorder"

        params := {}
            , params.order := functionValues.1

            , params := this.checkParamsVariables(params)
            , params.order := params.order < 1 ? 3 : params.order

        if (sendEsc = true)
            Send("Esc")

        battleListArea := new _BattleListArea()

        Loop, 2 {
            vars := ""
            try {
                vars := ImageClick({"x1": battleListArea.position.getX(), "y1": battleListArea.position.getY() - 5, "x2": battleListArea.position.getX() + 175, "y2": battleListArea.position.getY() + 25
                        , "image": "change_order_" A_Index
                        , "directory": ImagesConfig.battleListFolder
                        , "variation": 20
                        , "funcOrigin": A_ThisFunc
                        , "debug": false})
            } catch e {
                _Logger.exception(e, A_ThisFunc)
            }
            if (vars.x)
                break
        }
        if (!vars.x) {
            writeCavebotLog("ERROR", (functionName ": ")  "Battle List change order button not found")
            return false
        }

        MouseClick("Left", vars.x + 4, vars.y + 4)

        Sleep, 150
        vars := ""
        try {
            vars := ImageClick({"image": "edit_name"
                    , "directory": ImagesConfig.battleListFolder
                    , "variation": ImagesConfig.battleList.editNameVAR
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }
        if (!vars.x) {
            writeCavebotLog("ERROR", (functionName ": ")  "Battle List options menu didn't open")
            return false
        }
        ; Sleep, 100

        switch params.order {
            case 1:
                writeCavebotLog("Action", functionName ": " params.order " (Sort Ascending by Display Time)")
            case 2:
                writeCavebotLog("Action", functionName ": " params.order " (Sort Descending by Display Time)")
            case 3:
                writeCavebotLog("Action", functionName ": " params.order " (Sort Ascending by Distance)")
            case 4:
                writeCavebotLog("Action", functionName ": " params.order " (Sort Descending by Distance)")
            case 5:
                writeCavebotLog("Action", functionName ": " params.order " (Sort Ascending by Hit Points)")
            case 6:
                writeCavebotLog("Action", functionName ": " params.order " (Sort Descending by Hit Points)")
            case 7:
                writeCavebotLog("Action", functionName ": " params.order " (Sort Ascending by Name)")
            case 8:
                writeCavebotLog("Action", functionName ": " params.order " (Sort Descending by Name)")

        }
        mod := 19 * params.order
        ; mousemove, WindowX + vars.x + 7, WindowY + vars.y + 36 + mod
        ; msgbox, % "order = " params.order
        MouseClick("Left", vars.x + 7, vars.y + 36 + mod)
        Sleep, 25
        return true

    }

    battlelistchangesize(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "battlelistchangesize"

        params := {}
            , params.size := functionValues.1

            , params := this.checkParamsVariables(params)
            , params.size := params.size < 2 ? 4 : params.size
            , params.size := params.size > 8 ? 8 : params.size

        writeCavebotLog("Action", functionName ": " params.size)

        battleListArea := new _BattleListArea()
        battleListArea.battleWindowHeight()

        border := new _Cooordinate(battleListArea.getPosition().getX(), battleListArea.getPosition().getY())

        height := 13 + (22 * params.size)

        sizeDiff := height - battleListArea.getHeight()
        if (sizeDiff = 0) {
            return
        }

        if (sizeDiff < 0) {
            MouseDrag(border.getX(), border.getY(), border.getX(), battleListArea.getPosition().getY() + battleListArea.getHeight() - abs(sizeDiff))
        } else {
            MouseDrag(border.getX(), border.getY(), border.getX(), battleListArea.getPosition().getY() + battleListArea.getHeight() + sizeDiff)
        }
        ;Sleep, 50
        return true
    }

    buyitemactionnewtrade(params, buyAmount) {
        functionName := "buyitemnpc"

        buyAmountOriginal := buyAmount

        if (this.tradeWindow.button_x = "") {
            writeCavebotLog("ERROR", (functionName ": ") "Trade window OK button position not set")
            return false
        }

        Loop, {
            buyAmount := buyAmountOriginal
            if (buyAmount > 999)
                buyAmount := 999

            writeCavebotLog("Action", functionName ": buying """ params.item """, amount: " buyAmountOriginal "/" params.amount)
            if (buyAmount >= 1) {
                vars := this.searchAmountFieldTrade(functionName)
                if (vars = false)
                    return false

                this.writeOnInputField(buyAmount, click := true, vars.x + 65, vars.y + 5, deleteContents := true)
            }

            Sleep, 100
            buyAmountOriginal -= buyAmount
            buyAmount := buyAmountOriginal

            if (this.okButton() = false)
                return false

            Sleep, % cavebotSystemObj.buyItemDelay

            if (buyAmount < 1) {
                this.scrollWindowSlider("Up")
                Sleep, 25
                MouseMove(CHAR_POS_X, CHAR_POS_Y)
                ; this.scrollWindow("Up", 50)
                break
            }
        }

        writeCavebotLog("Action", functionName ": finished purchase of """ params.item """, amount: " params.amount)
        ; msgbox, finished buy, buyAmount = %buyAmount%
        return true
    }

    /**
    * @return _Coordinate
    */
    searchAmountFieldTrade(functionName) {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFile((isRubinot() ? "amount_tradewindow_1290_rubinot" : "amount_tradewindow_1290"))
                .setFolder(ImagesConfig.npcTradeFolder)
                .setVariation(40)
        }

        _search := searchCache
        _search.setCoordinates(_Coordinates.FROM_ARRAY(this.tradeWindow))
            .search()

        if (_search.notFound()) {
            writeCavebotLog("ERROR", (functionName ": ") """Amount"" image not found")
            return false
        }

        return _search.getResult()
    }


    writeOnInputField(text, click := false, x := "", y := "", deleteContents := true) {
        if (click = true) {
            this.clickOnInputField(x, y, deleteContents)
        }

        write(text, TibiaClientID)
        Sleep, 250
    }

    clickOnInputField(x, y, deleteContents := true) {
        static searchCache

        loop, 2 {
            MouseClick("Left", x, y, debug := false)
            Sleep, 75
        }
        if (deleteContents = false)
            return

        loop, 3 {
            Send("Delete")
            Send("Backspace")
        }
        Sleep, 100
    }

    buyitemnpc(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "buyitemnpc"

        params := {}
            , params.item := functionValues.1
            , params.amount := this.getNumberParam(functionValues.2)
            , params.amountDecrease := this.getNumberParam(functionValues.3)
            , params.tradeFilter := functionValues.4
            , params.tradeMessage := functionValues.5

            , params := this.checkParamsVariables(params)

            , params.amountDecrease := params.amountDecrease < 0 ? 0 : params.amountDecrease

        this.npcTradeMessage := params.tradeMessage
        if (this.npcTradeMessage = "")
            this.npcTradeMessage := "trade"
        writeCavebotLog("Action", functionName ": " params.item " | " params.amount " | " params.amountDecrease " | filter: " params.tradeFilter (this.npcTradeMessage != "trade" ? " | trade message: """ this.npcTradeMessage """" : "") )

        if (isNotTibia13())
            return this.buyitemnpcoldtibia(functionValues)

        buyAmount := params.amount - params.amountDecrease
        if (buyAmount < 1)
            return true

        if (params.amount < 1) {
            writeCavebotLog("ERROR", (functionName ": ")  "Amount of items to buy """ params.amount """ lower than one")
            return false
        }

        if (!itemsImageObj[params.item]) {
            writeCavebotLog("ERROR", (functionName ": ")  "Item """ params.item """ doesn't exist in the items list")
            return false
        }

        ; writeCavebotLog("Action", (functionName ": ") "Scroll down limit (scrollSellLimit): " cavebotSystemObj.scrollSellLimit )

        if (this.npctrade(false, this.npcTradeMessage) = false)
            return false

        if (this.checkTradeWindow() = false)
            return false

        filter := true
        if (filter = true) {
            if (params.tradeFilter != "") {
                this.say({1: params.tradeFilter})
                Sleep, 250
            } else {
                ; to not say potions twice that can make the trade window appear in a new position and mess everything
                if (InStr(params.item, "potion") && this.npcTradeMessage != "potions") {
                    this.say({1: "potions"})
                    Sleep, 250
                }
            }
        }

        /*
        click on Buy item position to go back to the start of the list
        */
        MouseClick("Left", this.tradeWindow.x2 - 15, this.tradeWindow.y1 + 25, debug := false)
        Sleep, 100


        if (OldBotSettings.settingsJsonObj.settings.cavebot.tradeWindowSummerUpdate1290 = true) && (cavebotSystemObj.tradeWindowWithSearchBox = true)
            this.filterItemNameFilter(functionName, params.item)

        Loop, % (cavebotSystemObj.scrollDownLimit < 1 ? 1 : cavebotSystemObj.scrollDownLimit) { ; scroll 60 times
            /*
            with lower delay is bugging when fps is 10
            ; delay to try to fix error of buying supreme health potion instead of strong mana(supreme is right below strong mana)
            */
            Sleep, 50
            timeItemSearch := A_TickCount

            vars := this.searchItemTradeWindow(functionName, params)
            if (vars.x)
                break
            elapsedItemSearch := A_TickCount - timeItemSearch
            Sleep, elapsedItemSearch < 25 ? 10 : 0
            ; msgbox, % elapsedItemSearch
            if (this.scrollWindow("down") = false)
                return false
        }
        if (vars = false OR vars.x = "") {
            writeCavebotLog("ERROR", functionName ": """ params.item """ not found")
            return false
        }
        /*
        wait a little bit for the screen update and then search for the item again, to confirm its position
        */
        Sleep, 200
        vars := this.searchItemTradeWindow(functionName, params)
        if (vars = false OR vars.x = "") {
            writeCavebotLog("ERROR", functionName ": """ params.item """ not found")
            return false
        }

        MouseClick("Left", vars.x + 50, vars.y, false)
        Sleep, 100

        ; mouseMove, WindowX + vars.x, WindowY + vars.Y
        ; msgbox, % "item found`n" serialize(vars)
        ; m(cavebotSystemObj.buyItemDelay)

        if (OldBotSettings.settingsJsonObj.settings.cavebot.tradeWindowSummerUpdate1290 = true) && (cavebotSystemObj.tradeWindowWithSearchBox = true)
            return this.buyitemactionnewtrade(params, buyAmount)

        Loop, {
            writeCavebotLog("Action", functionName ": buying """ params.item """, amount: " buyAmount "/" params.amount)
            if (buyAmount >= 100) {
                units100 := Floor(buyAmount / 100)
                ; if (this.amountButton("increment", 100, delay := 50) = false)
                if (this.scrollWindowSlider("Right") = false) {
                    writeCavebotLog("Action", functionName ": horizontal scroll(right) not found, unable to buy more """ params.item """")
                    goto, finishPurchase
                    ; return false ; if horizontal scroll is not found, it's because have no cap or no money to keep buying
                }
                ; msgbox, % units100
                Loop, % units100 {
                    if (this.okButton() = false)
                        return false
                    buyAmount -= 100
                    /*
                    delay after clicking to by item
                    some ot servers has a higher delay like 1 sec (Safebra)
                    */
                    Sleep, % cavebotSystemObj.buyItemDelay
                    ; msgbox, % "buyAmount = " buyAmount
                }
                ; if (this.amountButton("decrement", 100, delay := 50) = false)
                if (this.scrollWindowSlider("Left") = false) {
                    writeCavebotLog("Action", functionName ": horizontal scroll(left) not found, unable to buy more """ params.item """")
                    goto, finishPurchase
                    ; return false
                }
                ; msgbox, decremented
            }
            if (buyAmount < 100) {
                if (this.amountButton("increment", buyAmount - 1, delay := 50) = false)
                    return false
                if (this.okButton() = false)
                    return false
                buyAmount -= buyAmount
                Sleep, % cavebotSystemObj.buyItemDelay
            }
            if (buyAmount < 1) {
                this.scrollWindowSlider("Up")
                Sleep, 25
                MouseMove(CHAR_POS_X, CHAR_POS_Y)
                ; this.scrollWindow("Up", 50)
                break
            }
        }

        finishPurchase:

        writeCavebotLog("Action", functionName ": finished purchase of """ params.item """, amount: " params.amount)
        ; msgbox, finished buy, buyAmount = %buyAmount%
        return true
    }

    filterItemNameFilter(functionName, itemName) {
        try {
            vars := ImageClick({"x1": PotX, "y1": PotY, "x2": PotX + 40, "y2": PotY + PotY3
                    , "image": (isRubinot() ? "amount_tradewindow_1290_rubinot.png" : "amount_tradewindow_1290.png")
                    , "directory": ImagesConfig.npcTradeFolder
                    , "variation": 40
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            writeCavebotLog("ERROR", (functionName ": ") e.Message " | " e.What)
        }
        if (!vars.x) {
            writeCavebotLog("ERROR", (functionName ": ") """Amount"" image not found")
            return false
        }


        if (isRubinot()) {
            if (!searchCache) {
                searchCache := new _ImageSearch()
                    .setFile("clear_input_rubinot")
                    .setFolder(ImagesConfig.npcTradeFolder)
                    .setVariation(40)
                    .setClickOffsets(2)
            }

            _search := searchCache
                .setCoordinates(_Coordinates.FROM_ARRAY(this.tradeWindow))
                .search()
                .click()
            Sleep, 100
        }


        this.writeOnInputField(itemName, click := true, vars.x + 65, vars.y - 25, deleteContents := true)
    }

    buyitemnpcoldtibia(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "buyitemnpcoldtibia"

        params := {}
            , params.item := functionValues.1
            , params.amount := this.getNumberParam(functionValues.2)
            , params.amountDecrease := this.getNumberParam(functionValues.3)
            , params.tradeFilter := functionValues.4

            , params := this.checkParamsVariables(params)

            , params.amountDecrease := params.amountDecrease < 0 ? 0 : params.amountDecrease

        writeCavebotLog("Action", functionName ": buying """ params.item """, amount: " buyAmount "/" params.amount)

        buyAmount := params.amount - params.amountDecrease
        if (buyAmount < 1) {
            ; writeCavebotLog("Action", functionName ": have enough supply""" params.item """, amount: " params.amount)
            return true
        }

        if (params.amount < 1) {
            writeCavebotLog("ERROR", (functionName ": ")  "Amount of items to buy """ params.amount """ lower than one")
            return false
        }

        if (!itemsImageObj[params.item]) {
            writeCavebotLog("ERROR", (functionName ": ")  "Item """ params.item """ doesn't exist in the items list")
            return false
        }


        dialog := "buy " buyAmount " " params.item
        writeCavebotLog("Action", functionName ": say to NPC: """ dialog """")

        this.say({1: "hi"})
        Sleep, 500
        this.say({1: "hi"})
        Sleep, 750

        this.say({1: dialog})
        this.say({1: "yes"})

        return true
    }

    getSkillWindowImage(type) {
        image := (isTibia13()) ? ImagesConfig.skillWindow[type] : ImagesConfig.clientNumbersFolder "\" CavebotSystem.cavebotJsonObj.settings.numbersFolderNameClient "\sk\" type ".png"

        if (!FileExist(image))
            throw Exception("Action is not compatible, """ type """ image is not set for current client")
        return image
    }

    readSkillWindow(functionName, type)
    {
        try skillWindowImage := this.getSkillWindowImage(type)
        catch e {
            writeCavebotLog("ERROR", (functionName ": ") e.Message)
            return -1
        }

        StringUpper, text, type, T
        switch type {
            case "capacity":
                /*
                only for columns if not tibia 12 (Old tibia)
                */
                columns := 5
                if (isTibia13() = false)
                    columns := 4
            case "soulPoints":
                text := "Soul points"
                columns := 4
            case "stamina":
                columns := 2
            default:
                columns := 4
        }

        t1Check := A_TickCount
        ; msgbox, % skillWindowImage
        image := (isTibia13()) ? ImagesConfig.skillWindow[type] : CavebotSystem.cavebotJsonObj.settings.numbersFolderNameClient "\sk\" type ".png"
        vars := ""
        try {
            vars := ImageClick({"image": image
                    , "variation": OldBotSettings.settingsJsonObj.images.client.chat.chatImagesVariation
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }

        if (!vars.x) {
            writeCavebotLog("ERROR", text txt(" não está visível na janela de Skills.", " is not visible on Skills window"))
            return -1
        }


        PotX := vars.x + int(CavebotSystem.cavebotJsonObj.settings[type].offsetFromImageX)
        PotY := vars.y + int(CavebotSystem.cavebotJsonObj.settings[type].offsetFromImageY)

        PotX3 := 13, PotY3 := 16

        switch TibiaClient.getClientIdentifier() {
            case "olders":
                try {
                    vars := ImageClick({"x1": PotX, "y1": PotY, "x2": PotX + 40, "y2": PotY + PotY3
                            , "image": "dot.png"
                            , "directory": ImagesConfig.clientNumbersFolder "\" CavebotSystem.cavebotJsonObj.settings.numbersFolderNameClient "\sk"
                            , "variation": 1
                            , "funcOrigin": A_ThisFunc
                            , "debug": false})
                } catch e {
                    writeCavebotLog("ERROR", (functionName ": ") e.Message " | " e.What)
                }
                /*
                if dot is found, need to decrease PotX
                */
                if (vars.x) {
                    writeCavebotLog("Action", (functionName ": ") "dot found")
                    PotX -= PotX3
                }
        }
        result := this.readActionBarOCR(PotX, PotY, PotX + PotX3, PotY + PotY3, type, columns, debugNumbers := false, debugColumns := false)

        writeCavebotLog("Action", (functionName ": ") text " amount: " result " (" A_TickCount - t1Check " ms)")
        ; msgbox, % "cap = " cap
        return result

    }

    capacity()
    {
        functionName := "capacity"
        if (MemoryManager.memoryJsonFileObj.capacity) {
            static memory
            if (!memory) {
                memory := new _MemoryAddress(MemoryManager.localPlayerBaseAddress)
                    .setType("Double")
                    .addOffset(MemoryManager.memoryJsonFileObj.capacity)
            }

            SetFormat, Float, 0.2
            result := memory.read()
            result := StrReplace(result, ",", "")
            result := StrReplace(result, ".", "")
            SetFormat, Float, 0.0

            writeCavebotLog("Action", (functionName ": ") text " amount: " result)
            return result
        }

        return this.readSkillWindow(functionName, "capacity")
    }

    transfergold(functionValues := "")
    {
        functionName := "transfergold"

        params := {}
            , params.playerName := functionValues.1
            , params.subtract := this.getNumberParam(functionValues.2)

            , params := this.checkParamsVariables(params)

        if (params.playerName = "") {
            writeCavebotLog("ERROR", (functionName ": ") "empty player name")
            return false
        }

        balance := this.getbalance()
        if (balance = -1) {
            Send("Esc")
            Sleep, 250
            balance := this.getbalance()

            if (balance = -1) {
                writeCavebotLog("ERROR", (functionName ": ") "failed to get balance, aborting transfer")
                return false
            }
        }

        if (params.subtract > 0) {
            balance -= params.subtract
            writeCavebotLog("Action", (functionName ": ") "Subtracting """ params.subtract """, new balance: """ balance """")
        }

        if (balance <= 0) {
            writeCavebotLog("Action", (functionName ": ") "Balance is: """ balance """, aborting transfer")
            return false
        }

        this.clipboardOld := Clipboard
        Sleep, 50
        copyToClipboard("transfer " balance " to " params.playerName)
        this.turnChatButtonAction("on")
        Sleep, 100
        SendModifier("Ctrl", "v")
        ; this.clickOnPaste(functionName)
        Sleep, 100
        this.restoreClipboardAfterChatCopy()
        ; ReleaseModifierKey("Ctrl")
        ; Sleep, 50

        Send("Enter")
        Sleep, 100
        this.say({1: "yes"})

        writeCavebotLog("Action", (functionName ": ") "Transferred """ balance """ gold to player """ params.playerName """")

        return true
    }

    clickOnPaste(functionName) {
        static coord
        if (!coord) {
            windowArea := new _WindowArea()
            coord := new _Coordinate(windowArea.getWidth(), windowArea.getHeight())
                .divX(2)
                .subY(20)
        }

        if (OldBotSettings.settingsJsonObj.images.client.chat.paste = "") {
            SendModifier("Ctrl", "v")
            return true
        }

        coord.click("Right")

        Sleep, 50
        Loop 3 {
            Sleep, 100
            try {
                _search := new _ClickOnMenu(_ClickOnMenu.PASTE).run()
            } catch e {
                _Logger.error(e.Message, functionName, A_ThisFunc)
                return false
            }

            if (_search.found()) {
                return true
            }
        }

        writeCavebotLog("ERROR", (functionName ": ") """Paste"" option not found")
        Send("Esc")
        return false
    }

    getbalance(functionValues := "") {
        functionName := "getbalance"

        if (!this.npchi()) {
            return false
        }

        balance := ""
        Loop, 3 {
            this.say({1: "balance"})
            Sleep, 1000

            if (!this.selectAllAndCopyChatText(functionName)) {
                continue
            }

            balance := this.clipboardContent

            balance := StrReplace(balance, " gold", "")
            balance := StrReplace(balance, ".", "")
            balance := StrReplace(balance, "!", "")

            if balance is number
            {
                break
            }
        }

        this.restoreClipboardAfterChatCopy()

        if balance is not number
        {
            writeCavebotLog("ERROR", (functionName ": ") "Failed to get balance, string: """ SubStr(balance, 1, 20) "..."  """")
            return -1
        }

        writeCavebotLog("Action", (functionName ": ") "Balance is: """ balance """")

        return balance
    }

    chatcontains(functionValues := "") {
        functionName := "chatcontains"

        params := {}
            , params.string := functionValues.1

            , params := this.checkParamsVariables(params)

        if (params.string = "") {
            writeCavebotLog("ERROR", (functionName ": ") "empty string to search")
            return false
        }


        if (this.selectAllAndCopyChatText(functionName) = false) {
            this.restoreClipboardAfterChatCopy()
            return false
        }

        strings := StrSplit(params.string, "|")

        for key, string in strings
        {
            string := LTrim(RTrim(string))
            stringPos := InStr(this.clipboardContent, string)
            ; msgbox, % stringPos "`n" string
            if (stringPos) {
                stringSearchBreakline := SubStr(this.clipboardContent, stringPos - 1, StrLen(this.clipboardContent))
                ; m("stringSearchBreakline = " stringSearchBreakline)

                breakLineFound := InStr(stringSearchBreakline, "`n")
                ; m("breakLineFound = " breakLineFound)
                clipboardString := SubStr(stringSearchBreakline, 1, breakLineFound - 1)

                ; m("clipboardString = " clipboardString)
                writeCavebotLog("Action", (functionName ": ") "String """ string """ found(true): " clipboardString)
                this.restoreClipboardAfterChatCopy()
                return true
            }
        }

        writeCavebotLog("Action", (functionName ": ") "String """ params.string """ NOT found(false)")
        this.restoreClipboardAfterChatCopy()
        return false

    }

    restoreClipboardAfterChatCopy() {
        Clipboard := this.clipboardOld, this.clipboardOld := "", this.clipboardContent := ""
    }

    selectAllAndCopyChatText(functionName) {
        static searchCache
        if (!searchCache) {
            chatArea := new _ChatArea()
            c1 := new _Coordinate(chatArea.getX1(), new _ChatButtonArea().getY1())
                .subY(30)
            c2 := _Coordinate.FROM(chatArea.getC2())
            coordinates := new _Coordinates(c1, c2)

            searchCache := new _ImageSearch()
                .setFile("balance_is")
                .setFolder(ImagesConfig.npcTradeFolder)
                .setVariation(65)
                .setCoordinates(coordinates)
                .setClickOffsetX(isRubinot() ? 77 : 75)
                .setClickOffsetY(8)
        }

        Loop 3 {
            Sleep, 100
            try {
                _search := searchCache
                    .search()
            } catch e {
                _Logger.error(e.Message, functionName, A_ThisFunc)
                return false
            }

            if (_search.found()) {
                break
            }

            if (A_Index = 3) {
                writeCavebotLog("ERROR", (functionName ": ") "balance image not found.")
                return false
            }
        }

        Loop, 2 {
            _search.click(button := "Left", repeat := 1, delay := "", debug := false)
            Sleep, 100
        }

        this.clipboardOld := Clipboard
        Sleep, 50
        SendModifier("Ctrl", "c")
        Sleep, 100
        /*
        unselect text
        */
        _search.click()

        this.clipboardContent := Clipboard

        if (empty(this.clipboardContent)) {
            writeCavebotLog("ERROR", (functionName ": ") "Failed to get balance from chat")
            return false
        }

        return true
    }

    selectAndCopyChatText(functionName) {
        /*
        select text
        */

        if (ClientAreas.cooldownBarArea.y2 = "") {
            writeCavebotLog("ERROR", (functionName ": ") " Cooldon bar area is empty")
            return false
        }

        MouseDrag(this.chatCopyX, this.chatCopyY, 1, ClientAreas.cooldownBarArea.y2 + 52, "", debug := false)
        Sleep, 25

        this.clipboardOld := Clipboard
        SendModifier("Ctrl", "c")
        Sleep, 50
        /*
        unselect text
        */
        MouseClick("Left", this.chatCopyX, this.chatCopyY)

        this.clipboardContent := Clipboard
        return true
    }

    cleardefaultchat(functionValues := "") {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFile(OldBotSettings.settingsJsonObj.images.client.chat.clearMessages)
                .setFolder(ImagesConfig.clientChatFolder)
                .setVariation(OldBotSettings.settingsJsonObj.images.client.chat.chatImagesVariation)
                .setClickOffsetX(12)
                .setClickOffsetY(5)
        }

        functionName := "cleardefaultchat"

        if (this.activateDefaultChatTab(functionName) = false)
            return false

        MouseClick("Right", this.defaultChatPos.x + 12, this.defaultChatPos.y + 5, debug := false)

        Sleep, 50
        Loop, 3  {
            Sleep, 100
            try {
                _search := searchCache
                    .search()
                    .click()
            } catch e {
                _Logger.error(e.Message, functionName, A_ThisFunc)
                return false
            }

            if (_search.found()) {
                break
            }
        }

        if (_search.notFound()) {
            Sleep, 50
            Send("Esc")
            Sleep, 50
            writeCavebotLog("ERROR", (functionName ": ") " couldn't find the ""Clear messages"" option")
            return false
        }

        writeCavebotLog("Action", (functionName ": ")  "Chat cleared")
        return true
    }

    searchDefaultChatTab(functionName) {
        if (OldBotSettings.settingsJsonObj.images.client.chat.defaultChatTab = "") {
            writeCavebotLog("ERROR", (functionName ": ") " chat images are not configured for this client")
            return false
        }

        try {
            vars := ImageClick({"image": OldBotSettings.settingsJsonObj.images.client.chat.defaultChatTab
                    , "directory": ImagesConfig.clientChatFolder
                    , "variation": OldBotSettings.settingsJsonObj.images.client.chat.chatImagesVariation
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            _Logger.error(e.Message, functionName, A_ThisFunc)
            return false
        }
        Sleep, 50

        if (!vars.x) {
            try {
                vars := ImageClick({"image": OldBotSettings.settingsJsonObj.images.client.chat.defaultChatTabUnselected
                        , "directory": ImagesConfig.clientChatFolder
                        , "variation": OldBotSettings.settingsJsonObj.images.client.chat.chatImagesVariation
                        , "funcOrigin": A_ThisFunc
                        , "debug": false})
            } catch e {
                _Logger.error(e.Message, functionName, A_ThisFunc)
                return false
            }
            if (!vars.x) {
                Sleep, 25
                try {
                    vars := ImageClick({"image": OldBotSettings.settingsJsonObj.images.client.chat.defaultChatTabUnselectedRed
                            , "directory": ImagesConfig.clientChatFolder
                            , "variation": OldBotSettings.settingsJsonObj.images.client.chat.chatImagesVariation
                            , "funcOrigin": A_ThisFunc
                            , "debug": false})
                } catch e {
                    _Logger.error(e.Message, functionName, A_ThisFunc)
                    return false
                }
                if (!vars.x) {
                    writeCavebotLog("ERROR", (functionName ": ") " couldn't find the Default chat")
                    return false
                }
            }
        }

        return vars
    }

    activateDefaultChatTab(functionName) {

        this.defaultChatPos := this.searchDefaultChatTab(functionName)
        if (this.defaultChatPos = false)
            return false

        /*
        Click to active the chat first
        */
        MouseClick("Left", this.defaultChatPos.x + 12, this.defaultChatPos.y + 5)
        Sleep, 50

    }

    clearserverlogchat(functionValues := "")
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFolder(ImagesConfig.clientChatFolder)
                .setVariation(OldBotSettings.settingsJsonObj.images.client.chat.chatImagesVariation)
        }

        functionName := "clearserverlogchat"

        if (OldBotSettings.settingsJsonObj.images.client.chat.serverLogChatTab = "") {
            writeCavebotLog("ERROR", (functionName ": ") " chat images are not configured for this client")
            return false
        }

        try {
            _search := searchCache
                .setFile(OldBotSettings.settingsJsonObj.images.client.chat.serverLogChatTab)
                .search()
                .click("Right")

            if (_search.notFound()) {
                Loop, 4 {
                    Sleep, 100
                    _search := searchCache
                        .setFile(OldBotSettings.settingsJsonObj.images.client.chat.serverLogChatTabUnselectedRed)
                        .search()
                        .click("Right")

                    if (_search.found()) {
                        break
                    }

                    _search := searchCache
                        .setFile(OldBotSettings.settingsJsonObj.images.client.chat.serverLogChatTabUnselected)
                        .search()
                        .click("Right")

                    if (_search.found()) {
                        break
                    }
                }
            }
        } catch e {
            _Logger.error(e.Message, functionName, A_ThisFunc)
            return false
        }

        if (_search.notFound()) {
            writeCavebotLog("ERROR", (functionName ": ") " couldn't find the Server Log chat")
            return false
        }

        Sleep, 50

        Loop, 2 {
            try {
                _search := searchCache
                    .setFile(OldBotSettings.settingsJsonObj.images.client.chat.clearMessages)
                    .setClickOffsetX(12)
                    .setClickOffsetY(5)
                    .search()
                    .click()
            } catch e {
                _Logger.error(e.Message, functionName, A_ThisFunc)
                return false
            }

            if (_search.found()) {
                writeCavebotLog("Action", (functionName ": ")  "Chat cleared")
                return true
            }

            Sleep, 50
        }

        Sleep, 50
        Send("Esc")
        Sleep, 50
        writeCavebotLog("ERROR", (functionName ": ") " couldn't find the ""Clear messages"" option")
        return false
    }

    clickonposition(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "clickonposition"

        params := {}
            , params.click := functionValues.1
            , params.x := this.getNumberParam(functionValues.2)
            , params.y := this.getNumberParam(functionValues.3)
            , params.repeat := functionValues.4
            , params.delay := this.getNumberParam(functionValues.5)
            , params.holdCtrl := functionValues.6
            , params.holdShift := functionValues.7
            , params.debug := functionValues.8

            , params := this.checkParamsVariables(params)

            , params.delay := (params.delay < 1) ? 500 : params.delay
            , params.repeat := (params.repeat < 1) ? 1 : params.repeat
            , params.debug := stringToBool(params.debug)


        if (this.scriptVariables.modifierX != "") {
            value := this.scriptVariables.modifierX
            if value is number
            {
                writeCavebotLog("Action", functionName ": " "Using modifier X: " value)
                params.x := params.x + (value)
            }
        }

        if (this.scriptVariables.modifierY != "") {
            value := this.scriptVariables.modifierY
            if value is number
            {
                writeCavebotLog("Action", functionName ": " "Using modifier Y: " value)
                params.y := params.y + (value)
            }
        }

        ; msgbox, % serialize(params)

        writeCavebotLog("Action", functionName ": " params.click " | x: " params.x " | y: " params.y " | r: " params.repeat " | d: " params.delay " | c: " params.holdCtrl " | s: " params.holdShift " | dbg: " params.debug)

        Loop, % params.repeat {
            if (stringToBool(params.holdCtrl)) {
                MouseClickModifier("Ctrl", params.click, params.x, params.y, params.debug)
            } else if (stringToBool(params.holdShift)) {
                MouseClickModifier("Shift", params.click, params.x, params.y, params.debug)
            } else {
                MouseClick(params.click, params.x, params.y, params.debug)
            }

            if (A_Index > 1)
                Sleep, % params.delay
        }

        return true
    }

    clickonimage(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "clickonimage"

        params := {}
            , params.imageName := functionValues.1
            , params.click := functionValues.2
            , params.repeat := this.getNumberParam(functionValues.3)
            , params.delay := this.getNumberParam(functionValues.4)
            , params.variation := this.getNumberParam(functionValues.5)
            , params.holdCtrl := functionValues.6
            , params.holdShift := functionValues.7
            , params.offsetX := this.getNumberParam(functionValues.8)
            , params.offsetY := this.getNumberParam(functionValues.9)

            , params := this.checkParamsVariables(params)

            , params.delay := (params.delay < 1) ? 500 : params.delay
            , params.repeat := (params.repeat < 1) ? 1 : params.repeat
            , params.variation := (params.variation < 0) ? _ScriptImages.DEFAULT_VARIATION : params.variation
            , params.offsetX := _ActionScriptValidation.isNumber(params.offsetX)
            , params.offsetY := _ActionScriptValidation.isNumber(params.offsetY)

        writeCavebotLog("Action", functionName ": " params.imageName " | click: " params.click ", repeat: " params.repeat ", delay: " params.delay ", variation: " params.variation " | offsetX: " params.offsetX ", offsetY: " params.offsetY)

        Loop, % params.repeat {
            try {
                _search := _ScriptImages.search(params.imageName, params.variation,, true, debug := false)
            } catch e {
                writeCavebotLog("ERROR", (functionName ": ") e.Message)
                return false
            }
            if (_search.notFound()) {
                writeCavebotLog("Action", (functionName ": ")  "Image """ params.imageName """ not found on screen")
                return false
            }

            if (stringToBool(params.holdCtrl)) {
                MouseClickModifier("Ctrl", params.click, _search.getX() + params.offsetX, _search.getY() + params.offsetY)
            } else if (stringToBool(params.holdShift)) {
                MouseClickModifier("Shift", params.click, _search.getX() + params.offsetX, _search.getY() + params.offsetY)
            } else {
                MouseClick(params.click, _search.getX() + params.offsetX, _search.getY() + params.offsetY, debug := false)
            }

            Sleep, 100
            if (A_Index > 0) {
                delay := params.delay - 100
                Sleep, % (delay > 1) ? delay : 0
            }
        }

        return true
    }

    clickonitem(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "clickonitem"

        params := {}
            , params.item := functionValues.1
            , params.click := functionValues.2
            , params.repeat := this.getNumberParam(functionValues.3)
            , params.delay := this.getNumberParam(functionValues.4)

            , params := this.checkParamsVariables(params)

            , params.delay := (params.delay < 1) ? 500 : params.delay
            , params.repeat := (params.repeat < 1) ? 1 : params.repeat


        if (!itemsImageObj[params.item]) {
            writeCavebotLog("ERROR", (functionName ": ")  "Item """ params.item """ doesn't exist in the items list")
            return false
        }

        writeCavebotLog("Action", functionName ": " params.item " | " params.click " | " params.repeat " | " params.delay " | " params.tolerancy)

        item := new _ItemSearch()
            .setName(params.item)

        clicked := false

        Loop, % params.repeat {
            if (A_Index > 1) {
                Sleep, 50
            }

            item.search()
            if (item.notFound()) {
                _Logger.log("Item """ params.item """ not found on screen", functionName)
                break
            }

            item.click(params.click)

            clicked := true
            Sleep, % params.delay
        }

        return clicked
    }

    clickonsqm(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "clickonsqm"

        params := {}
            , params.click := functionValues.1
            , params.sqm := InStr(functionValues.2, "$") ? functionValues.2 : _ActionScriptValidation.getSqmFromDirection(functionValues.2)
            , params.repeat := this.getNumberParam(functionValues.3)
            , params.delay := this.getNumberParam(functionValues.4)
            , params.holdCtrl := functionValues.6
            , params.holdShift := functionValues.7

            , params := this.checkParamsVariables(params)

            , params.delay := (params.delay < 1) ? 500 : params.delay
            , params.repeat := (params.repeat < 1) ? 1 : params.repeat

        writeCavebotLog("Action", functionName ": button: " params.click " | sqm: " params.sqm " | repeat: " params.repeat " | delay: " params.delay)

        sqmNumber := params.sqm
        x := SQM%sqmNumber%X
        y := SQM%sqmNumber%Y

        Loop, % params.repeat {
            if (stringToBool(params.holdCtrl)) {
                MouseClickModifier("Ctrl", params.click, x, y)
            } else if (stringToBool(params.holdShift)) {
                MouseClickModifier("Shift", params.click, x, y)
            } else {
                MouseClick(params.click, x, y)
            }

            Sleep, % params.delay
        }

        return true
    }

    convertgold(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "convertgold"

        params := {}
            , params.hotkey := functionValues.1

            , params := this.checkParamsVariables(params)
        writeCavebotLog("Action", functionName ": Converter hotkey: " (params.hotkey = "" ? "no hotkey (use only)" : params.hotkey))

        click := "Right"
        if (params.hotkey != "")
            click := "Left"

        delay := 250

        Loop, 50 {
            vars := ""
            try {
                vars := ImageClick({"image": OldBotSettings.settingsJsonObj.images.convertGold.100goldCoin
                        , "directory": ImagesConfig.cavebotFolder
                        , "variation": OldBotSettings.settingsJsonObj.options.itemSearchVariation
                        , "funcOrigin": A_ThisFunc
                        , "debug": false})
            } catch e {
                _Logger.error(e.Message, functionName, A_ThisFunc)
                return false
            }
            if (!vars.x)
                break

            if (params.hotkey != "") {
                Send(params.hotkey)
                Sleep, 50
            }

            if (click = "Right") {
                rightClickUseClassicControl(vars.x + 4, vars.y + 4)
            } else{
                MouseClick("Left", vars.x + 4, vars.y + 4)
            }
            Sleep, % delay
        }

        Loop, 50 {
            vars := ""
            try {
                vars := ImageClick({"image": OldBotSettings.settingsJsonObj.images.convertGold.100platinumCoin
                        , "directory": ImagesConfig.cavebotFolder
                        , "variation": OldBotSettings.settingsJsonObj.options.itemSearchVariation
                        , "funcOrigin": A_ThisFunc
                        , "debug": false})
            } catch e {
                _Logger.error(e.Message, functionName, A_ThisFunc)
                return false
            }

            if (!vars.x)
                break

            if (params.hotkey != "") {
                Send(params.hotkey)
                Sleep, 50
            }

            if (click = "Right") {
                rightClickUseClassicControl(vars.x + 4, vars.y + 4)
            } else{
                MouseClick("Left", vars.x + 4, vars.y + 4)
            }

            Sleep, % delay
        }

        if (params.hotkey != "")
            Send("Esc") ; esc to cancel crosshair in case hotkey was pressed and failed to click
        return true
    }


    closecavebot(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "closecavebot"

        IniDelete, %DefaultProfile%, cavebot, CurrentWaypointTab
        IniDelete, %DefaultProfile%, cavebot, CurrentWaypoint
        ExitApp
    }

    creaturesbattlelist(functionValues := "")
    {
        writeCavebotLog("Action", this.string_log)
        functionName := "creaturesbattlelist"

        creatures := TargetingSystem.countAllCreaturesBattle()
        writeCavebotLog("Action", functionName ": Creatures count: " creatures)
        return creatures
    }

    creaturesaround(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "creaturesaround"

        creaturesAround := TargetingSystem.searchLifeBars()
        count := creaturesAround.Count()

        writeCavebotLog("Action", functionName ": Creatures around: " count)
        return count
    }

    walkToOrangeSQM()
    {
        if (CavebotScript.isMarker())
            return false

        sqmsDist := CavebotWalker.getSqmDistanceByScreenPos(this.orangeSqmX, this.orangeSqmY)

        getCharPos()

        if (sqmsDist.x < 0)
            mapX := posx + abs(sqmsDist.x)
        else
            mapX := posx - sqmsDist.x
        if (sqmsDist.y < 0)
            mapY := posy + abs(sqmsDist.y)
        else
            mapY := posy - sqmsDist.y

        mapZ := posz

        writeCavebotLog("Action", "Walking to depot sqm coordinates: " mapX "," mapY "," mapZ " (" sqmsDist.x "," sqmsDist.y " - " this.sqmImageIndex ")")

        if (checkArrivedOnCoord(mapX, mapY, mapZ, false) = true)
            return true

        mapCoord := new _MapCoordinate(mapX, mapY, mapZ)
            .setIdentifier("depotOrangeSqm")
        ; mapCoord.showOnScreen()
        if (!new _WalkToCoordinate(mapCoord, {}, {}).run()) {
            return false
        }

        return true
    }

    /**
    * @param string directiong
    * @return bool
    */
    scrollWindowSlider(direction) {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFolder(ImagesConfig.npcTradeFolder)
                .setVariation(15)
                .setResultOffsetX(3)
                .setResultOffsetY(3)
        }

        searchCache.setCoordinates(_Coordinates.FROM_ARRAY(this.tradeWindow))

        switch direction {
            case "Up", case "Down":
                try {
                    _search := searchCache
                        .setFile("slider_vertical")
                        .search()
                } catch e {
                    _Logger.exception(e, A_ThisFunc)
                    return false
                }

            case "Left", case "Right":
                try {
                    _search := searchCache
                        .setFile("slider")
                        .search()
                } catch e {
                    _Logger.exception(e, A_ThisFunc)
                    return false
                }
        }

        if (_search.notFound()) {
            if (direction = "Left" OR direction = "Right")
                return false ; don't throw error in horizontal slider

            writeCavebotLog("ERROR", "scroll " direction " slider not found on screen (" this.tradeWindow.x1 "," this.tradeWindow.y1 "," this.tradeWindow.x2 "," this.tradeWindow.y2 ")" )
            return false
            ; return false
        }

        switch direction {
            case "Up": dest := new _Coordinate(vars.x, vars.y - 300)
            case "Down": dest := new _Coordinate(vars.x, vars.y + 300)
            case "Left": dest := new _Coordinate(vars.x - 140, vars.y)
            case "Right": dest := new _Coordinate(vars.x + 140, vars.y)
        }

        _search.drag(dest)

        Sleep, 100
    }

    scrollWindow(direction, repeat := 2, delay := 50) {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFolder(ImagesConfig.npcTradeFolder)
                .setVariation(15)
                .setClickOffsets(6)
        }

        try {
            _search := searchCache
                .setFile("scroll" direction "_button")
                .setCoordinates(_Coordinates.FROM_ARRAY(this.tradeWindow))
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }

        if (_search.notFound()) {
            writeCavebotLog("ERROR", "scroll " direction " button not found on screen (" this.tradeWindow.x1 "," this.tradeWindow.y1 "," this.tradeWindow.x2 "," this.tradeWindow.y2 ")" )
            return false
        }

        Loop, % repeat {
            _search.click()
            Sleep, % delay
        }

        return true
    }

    closebackpack(functionValues) {
        writeCavebotLog("Action", this.string_log)
        functionName := "closebackpack"

        params := {}
            , params.backpack := functionValues.1

            , params := this.checkParamsVariables(params)

        if (params.backpack = "") {
            writeCavebotLog("ERROR", "Empty backpack param")
            return false
        }

        writeCavebotLog("Action", functionName ": backpack: " params.backpack)

        backpackImageName := StrReplace(params.backpack, " ", "_") ".png"
        if (!FileExist(ImagesConfig.mainBackpacksFolder "\" backpackImageName)) {
            writeCavebotLog("ERROR", (functionName ": ") "Main Backpack image file doesn't exist: " ImagesConfig.mainBackpacksFolder "\" backpackImageName)
            return false
        }

        vars := ""
        try {
            vars := ImageClick({"image": backpackImageName
                    , "directory": ImagesConfig.mainBackpacksFolder
                    , "variation": 50
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            _Logger.exception(e, A_ThisFunc)

            return false
        }
        if (!vars.x) {
            writeCavebotLog("WARNING", (functionName ": ") """" params.backpack """ not found, make sure the backpack is opened.")
            return false
        }

        MouseClick("Left", vars.x + 165, vars.y + 8)
        Sleep, 50

        return true
    }

    openbackpack(functionValues)
    {
        writeCavebotLog("Action", this.string_log)
        functionName := "openbackpack"

        params := {}
            , params.backpack := functionValues.1

            , params := this.checkParamsVariables(params)

        if (params.backpack = "") {
            writeCavebotLog("ERROR", "Empty backpack param")
            return false
        }

        writeCavebotLog("Action", functionName ": backpack: " params.backpack)

        try {
            _search := new _ItemSearch()
                .setName(params.backpack)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, params.backpack)
            return false
        }

        if (_search.notFound()) {
            _Logger.log(functionName, txt("Backpack """ params.backpack """ não encontrada na tela.", "Backpack """ params.backpack """ not found on screen."))
            return false
        }

        _search.useMenu()

        Sleep, 50

        Loop, 3 {
            Sleep, % (A_Index = 1) ? 100 : 50
            try {
                _search := new _ClickOnMenu(_ClickOnMenu.OPEN_BACKPACK).run()
            } catch e {
                _Logger.error(e.Message, functionName, A_ThisFunc)
                return false
            }

            if (_search.found()) {
                Sleep, 100
                return true
            }
        }

        writeCavebotLog("ERROR", (functionName ": ") "Failed to click on open backpack in new window option.")
        return false
    }

    openDepotAround(clickAround := true) {
        ; writeCavebotLog("Action", LANGUAGE = "PT-BR" ? "Procurando pelo depot box limpo em volta" : "Searching for a clean depot box around")
        vars := ""
        try {
            vars := ImageClick({"image": ImagesConfig.depositer.locker
                    , "directory": ImagesConfig.depositerFolder
                    , "variation": 40
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }

        if (vars.x) {
            return {x: vars.x, y: vars.y}
        }

        if (clickAround = true) {
            sqms := {1: "N", 2: "S", 3: "W", 4: "E"}
            for key, sqm in sqms
            {
                MouseClick("Right", SQM%sqm%X, SQM%sqm%Y, false)
                Sleep, 350
                Send("Esc")
                Sleep, 50
            }
        }

        Loop, 4 {
            vars := ""
            try {
                vars := ImageClick({"image": ImagesConfig.depositer.locker
                        , "directory": ImagesConfig.depositerFolder
                        , "variation": 40
                        , "funcOrigin": A_ThisFunc
                        , "debug": false})
            } catch e {
                _Logger.exception(e, A_ThisFunc)
            }
            if (vars.x)
                break
            Sleep, 250
        }
        Sleep, 100
        Send("Esc")
        Sleep, 100
        if (vars.x) {
            return {x: vars.x, y: vars.y}
        }

        return false
    }

    deposittostash(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "deposittostash"
        params := {}
            , params.stashBackpack := functionValues.1
        ; , params.delay := this.getNumberParam(functionValues.1)

            , params := this.checkParamsVariables(params)

        if (params.stashBackpack = "") {
            writeCavebotLog("ERROR", "Empty stash backpack")
            return false
        }

        if (!new _OpenDepotAction().run()) {
            return false
        }


        this.depositBackpackToStash(functionName, params.stashBackpack)
        return true
    }

    depositBackpackToStash(functionName, backpack) {
        static searchCache
        if (!searchCache) {
            searchCache := new _ItemSearch()
                .setArea(new _SideBarsArea())
        }

        stashBoxSearch := this.searchStashBox(false)
        if (stashBoxSearch.notFound()) {
            writeCavebotLog("ERROR", (functionName ": ") "Stash box not found")
            return false
        }

        _search := searchCache
            .setName(backpack)
            .search()

        if (_search.notFound()) {
            writeCavebotLog("Action", (functionName ": ")  "Backpack """ backpack """ not found")
            return false
        }

        writeCavebotLog("Action", (functionName ": ")  "Moving """ backpack """ to the Stash..")

        Loop, 2 {
            Send("Esc")
            Sleep, 50
            this.dragitem(_search.getX(), _search.getY(), stashBoxSearch.getX(), stashBoxSearch.getY(), holdshift := false, 400, debug := false)
            Send("Enter")
            Sleep, 100
        }

        Send("Esc")
        return true
    }


    randomnumber(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "randomnumber"


        params := {}
            , params.min := this.getNumberParam(functionValues.1)
            , params.max := this.getNumberParam(functionValues.2)

        Random, R, % params.min, % params.max
        writeCavebotLog("Action", functionName ": min: " params.min " | max: " params.max " | random: " R)

        return R
    }

    resetsession(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "resetsession"
        resetCavebotSession()
        return
    }

    reloadcavebot(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "reloadcavebot"
        Reload
    }

    reachlocation(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "reachlocation"

        params := {}
            , params.x := this.getNumberParam(functionValues.1)
            , params.y := this.getNumberParam(functionValues.2)
            , params.z := this.getNumberParam(functionValues.3)
            , params.rangeX := this.getNumberParam(functionValues.4)
            , params.rangeY := this.getNumberParam(functionValues.5)

            , params := this.checkParamsVariables(params)

            , params.rangeX :=  params.rangeX < 1 ? 1 : params.rangeX
            , params.rangeY :=  params.rangeY < 1 ? 1 : params.rangeY

        if (params.x = "") {
            writeCavebotLog("ERROR", functionName ": empty X coordinate", true)
            return false
        }
        if (params.y = "") {
            writeCavebotLog("ERROR", functionName ": empty Y coordinate", true)
            return false
        }
        if (params.z = "") {
            writeCavebotLog("ERROR", functionName ": empty Z coordinate", true)
            return false
        }

        mapX := params.x, mapY := params.y, mapZ := params.z
        waypointsObj[tab][Waypoint].rangeX := params.rangeX
        waypointsObj[tab][Waypoint].rangeY := params.rangeY

        writeCavebotLog("Action", functionName ": x: " params.x ", y: " params.y ", z: " params.z  " | rangeX: " params.rangeX  ", rangeY: " params.rangeY )

        if (checkArrivedOnCoord(mapX, mapY, mapZ, true) = true)
            return true

        if (walkToWaypoint() = false)
            return false

        return true
    }

    runactionwaypoint(functionValues := "", log := true) {
        functionName := "runactionwaypoint"
        if (log = true) {
            writeCavebotLog("Action", this.string_log)
        }


        params := {}
            , params.waypoint := functionValues.1
            , params.tab := functionValues.2

            , params := this.checkParamsVariables(params)

        if (this.labelsNotFound[params.tab][params.waypoint] = true) {
            if (log = true)
                writeCavebotLog("ERROR", functionName ": *waypoint doesn't exist*, waypoint: """ params.waypoint """ | tab: """ params.tab """")
            return false
        }

        labelSearch := WaypointHandler.findLabel(params.waypoint)

        /*
        if tab param is a label
        */
        if (labelSearch.labelFound = true) {
            params.label := params.waypoint
            params.waypoint := labelSearch.waypointFound
            params.tab := labelSearch.tabFound

            labelLogString :=  " | label: " params.label
        }

        ; m(serialize(params))
        if (log = true)
            writeCavebotLog("Action", functionName ": tab: " params.tab " | waypoint: " params.waypoint "" labelLogString)

        if (!waypointsObj[params.tab][params.waypoint]) {
            if (!IsObject(this.labelsNotFound)) {
                this.labelsNotFound := {}
            }

            if (!IsObject(this.labelsNotFound[params.tab])) {
                this.labelsNotFound[params.tab] := {}
            }

            this.labelsNotFound[params.tab][waypoint] := true

            if (log = true)
                writeCavebotLog("ERROR", functionName ": waypoint doesn't exist, waypoint: """ params.waypoint """ | tab: """ params.tab """")
            return false
        }


        if (WaypointHandler.getAtribute("type", params.waypoint, params.tab) != "Action") {
            ; if (log = true)
            writeCavebotLog("ERROR", functionName ": waypoint is not Type ""Action"", waypoint: " params.waypoint " | tab: " params.tab)
            return false
        }

        previousCurrentTab := tab
        previousCurrentWaypoint := Waypoint
        tab := params.tab
        Waypoint := params.waypoint


        this.gotolabelWaypointRan := false
        ActionScript.ActionScriptWaypoint(Waypoint)

        if (this.gotolabelWaypointRan = false) {
            returnLabelWaypoint := false
            tab := previousCurrentTab
            Waypoint := previousCurrentWaypoint
        }
        return true
    }

    depositmoney() {
        writeCavebotLog("Action", this.string_log)

        if (!this.npchi())
            return false
        this.say({1: "deposit all"})
        this.say({1: "yes"})
        this.say({1: "balance"})

        return true
    }

    droplootonground(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "droplootonground"

        for itemName, atributes in lootingObj.lootList
        {
            LootingSystem.dropItemInsteadOfLoot(itemName, functionName, searchAllScreen := true)
        }
    }

    droptrash(functionValues := "") {
        static searchCache
        if (!searchCache) {
            searchCache := new _ItemSearch()
                .setArea(new _SideBarsArea())
        }

        writeCavebotLog("Action", this.string_log)
        functionName := "droptrash"

        ; , params.delay := this.getNumberParam(functionValues.1)
        params := {}
            , params.delay := functionValues.1
            , params.enableTargeting := functionValues.2

            , params := this.checkParamsVariables(params)

            , params.delay := empty(params.delay) ? 600 : params.delay
            , params.delay := (params.delay < 100) ? 100 : params.delay

        writeCavebotLog("Action", (functionName ": ") "delay: " params.delay "ms")

        if (params.enableTargeting = true) {
            targetingSystemObj.targetingDisabledAction := false
            restoreTargetingIcon()
        }

        for itemName, atributes in lootingObj.trashList
        {
            try {
                _search := searchCache
                    .setName(itemName)
                    .search()
            } catch e {
                _Logger.exception(e, A_ThisFunc)
                continue
            }

            if (_search.notFound()) {
                writeCavebotLog("Action", """" itemName """ not found")
                continue
            }

            triesDrop := 1
            Loop {
                _search.search()
                if (_search.notFound()) {
                    break
                }

                if (triesDrop > 30) {
                    writeCavebotLog("Action", """" itemName """ Ignoring drop after 30 tries")
                    break
                }

                writeCavebotLog("Action", "Dropping """ itemName """ (" triesDrop "x), use: " (atributes.use = 1 ? "true" : "false") "..")
                triesDrop++
                if (atributes.use = 1) {
                    _search.click("Right")

                    Sleep, % params.delay

                    _search.search()
                }

                if (_search.notFound()) {
                    break
                }

                Send("Esc")
                Sleep, 300
                _search.drag(new _Coordinate(CHAR_POS_X, CHAR_POS_Y))

                /*
                press enter to confirm dialog in older clients
                */
                if (isNotTibia13()) {
                    Sleep, 100
                    Send("Enter")
                }

                Sleep, % params.delay - 200
            } ; loop
        }

        return true
    }

    exitgame(functionValues := "") {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFile(OldBotSettings.settingsJsonObj.images.client.buttons.exit)
                .setFolder(ImagesConfig.clientButtonsFolder "\exit")
                .setVariation(OldBotSettings.settingsJsonObj.images.client.buttons.exitVariation)
                .setClickOffsets(8)
        }

        writeCavebotLog("Action", this.string_log)
        functionName := "exitgame"

        params := {}
            , params.screenshot := functionValues.1 = "" ? true : functionValues.1

            , params := this.checkParamsVariables(params)


        Loop, 3 {
            if (isDisconnected()) {
                writeCavebotLog("Action", (functionName ": ") "Exit game action succeed")
                return true
            }

            if (params.screenshot = true) {
                Path := "Data\Screenshots\Screenshot_ExitGame*.png", Number := 1
                Loop, %Path%
                    Number++
                ScreenshotTela("Screenshot_ExitGame" Number)
                writeCavebotLog("Action", (functionName ": ") "Screenshot saved on: Data\Screenshots\Screenshot_ExitGame" Number ".png")
            }

            Send("Esc")
            Sleep, 200

            WinClose, ahk_id %TibiaClientID%
            Sleep, 200

            try {
                _search := searchCache
                    .search()
                    .click()
            } catch e {
                _Logger.exception(e, A_ThisFunc)
                return false
            }

            if (_search.notFound()) {
                writeCavebotLog("Action", LANGUAGE = "PT-BR" ? "Botão ""Exit"" não localizado" : """Exit"" button not found")
                Send("Esc")
            }

            Sleep, 300
        }

        writeCavebotLog("ERROR", (functionName ": ") "Exit unsuccessful")

        return false
    }

    forcewalkarrow(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "forcewalkarrow"

        cavebotSystemObj.forceWalk := true
        cavebotSystemObj.forceWalkReason := "forcewalkarrow"

        writeCavebotLog("Action", (functionName ": ") " enabled forced walk")
    }

    forcewalkarrowstop(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "forcewalkarrowstop"

        cavebotSystemObj.forceWalk := false
        cavebotSystemObj.forceWalkReason := ""

        writeCavebotLog("Action", (functionName ": ") " disabled forced walk")
    }

    focusclient(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "focusclient"
        WinActivate()
    }

    follow(functionValues := "", log := true) {
        if (log = true)
            writeCavebotLog("Action", this.string_log)
        functionName := "follow"

        params := {}
            , params.followImage := functionValues.1
            , params.holdCtrl := stringToBool(functionValues.2)

            , params := this.checkParamsVariables(params)

        if (params.followImage = "") {
            writeCavebotLog("ERROR", (functionName ": ") "Empty follow name name")
            return false
        }

        if (scriptImagesObj.HasKey(params.followImage) = false) && (!FileExist(ImagesConfig.npcsFolder "\" params.followImage ".png")) {
            writeCavebotLog("ERROR", (functionName ": ") (LANGUAGE = "PT-BR" ? "Imagem do follow """ params.followImage """ não existe nas Script Images, adicione com a ""category"" -> ""Follow""." :  "Follow image """ params.followImage """ in Script Images, add with the ""category"" -> ""Follow"".") )
            return false
        }

        followPos := ""
        switch scriptImagesObj.HasKey(params.followImage) {
            case true:
                try {
                    _search := _ScriptImages.search(params.followImage)
                    followPos := _search.getResult()
                } catch e {
                    writeCavebotLog("ERROR", e.Message)
                    return false
                }
            case false:
                try {
                    followPos := ImageClick({"image": params.followImage
                            , "directory": ImagesConfig.npcsFolder
                            , "variation": 40
                            , "funcOrigin": A_ThisFunc
                            , "debug": false})
                } catch e {
                    _Logger.exception(e, A_ThisFunc)

                    return false
                }
        }

        if (followPos.x = "") {
            writeCavebotLog("ERROR", txt("Imagem de follow não encontrada na tela", "Follow image not found on screen") )
            return false
        }

        Send("Esc")
        Sleep, 50
        ; MouseMove( followPos.x + 5, followPos.y + 3)
        if (params.holdCtrl = true) {
            rightClickUse(followPos.x, followPos.y)
        } else{
            MouseClick("Right", followPos.x + 5, followPos.y + 3, debug := false)
        }

        Sleep, 50

        if (this.clickonfollowoption(functionValues := "", functionName, params) = false)
            return false

        sleep, 50
        return true
    }

    follownpc(functionValues := "", log := true) {
        return this.follow(functionValues, log)
    }

    clickonfollowoption(functionValues := "", functionName := "", params := "")
    {
        if (functionName = "")
            functionName := "clickonfollowoption"

        Loop 3 {
            Sleep, 100
            try {
                _search := new _ClickOnMenu(_ClickOnMenu.FOLLOW).run()
            } catch e {
                _Logger.error(e.Message, functionName, A_ThisFunc)
                return false
            }

            if (_search.found()) {
                return true
            }
        }

        writeCavebotLog("ERROR",  (functionName ": ") """Follow"" option not found. Option hold ctrl: " (params.holdCtrl = true ? "true" : "false"))
        Send("Esc")
        return false
    }

    getsetting(path) {
        functionName := "getsetting"
        if (!InStr(path, "/")) {
            writeCavebotLog("ERROR", (functionName ": ") "Wrong setting path format(" path ")")
            return
        }

        ; msgbox, % A_ThisFunc "`n" settingPath

        settingPath := StrSplit(path, "/")
        mainSetting := settingPath.1
        lastChildNumber := settingPath.Count() - 1
        childSettings := _ActionScriptValidation.createChildSettings(settingPath)


        /*
        script variables created with variable() function
        */
        if (mainSetting = "scriptVariables") {
            if (!this.scriptVariables.HasKey(childSettings.1)) {
                writeCavebotLog("ERROR", (functionName ": ") "Variable doesn't exist or has not been created yet, check if path is correct (" path ")")
                return -1
            }
            return this.scriptVariables[childSettings.1]
        }

        ; msgbox, % A_ThisFunc "`n" serialize(childSettings)
        ; msgbox, % A_ThisFunc "`n" serialize(childSettings)

        ; writeCavebotLog("Action", functionName ": " mainSetting " | " lastChildNumber)
        value := this.getChildSettingValue(lastChildNumber, mainSetting, childSettings.1, childSettings.2, childSettings.3, childSettings.4, childSettings.5)
        if (value = -1) {
            writeCavebotLog("ERROR", (functionName ": ") "Setting doesn't exist, check if path is correct (" path ")")
        }
        ; msgbox, % A_ThisFunc " = " value
        ; writeCavebotLog("Action", functionName "- value: """ value """")
        return value
    }

    gotolabel(functionValues) {
        functionName := "gotolabel"

        params := {}
            , params.labelName := functionValues.1
            , params.abort := functionValues.2

            , params := this.checkParamsVariables(params)
            , params.abort := (params.abort = "" && params.abort != false) ? true : params.abort

        label := params.labelName


        if (this.actionScriptType = "persistent") {
            Send_WM_COPYDATA("gotolabel/" label, "Cavebot Logs", 2000)
            return true
        }

        writeCavebotLog("Action", functionName ": """ label """ | " params.abort)

        if label is number
        {
            if (!waypointsObj[tab][label]) {
                writeCavebotLog("ERROR", (functionName ": ") LANGUAGE = "PT-BR" ? "Não há waypoint número """ label """ na aba """ tab """" : "There is no waypoint number """ label """ in """ tab """ tab")
                return false
            }
            Waypoint := label - 1

            ; msgbox, waypoint %waypoint%
            returnLabelWaypoint := params.abort
            this.gotolabelWaypointRan := true
            _GoToLabelAction.stopWalkingToWaypointTimerLabel()
            return true
        } else {
            if (label = "CurrentWaypoint") {
                Waypoint--
                returnLabelWaypoint := true
                this.gotolabelWaypointRan := true
                _GoToLabelAction.stopWalkingToWaypointTimerLabel()

                targetingSystemObj.targetingDisabledAction := false
                restoreTargetingIcon()
                Sleep, % TargetingSystem.TargetingTimer + (TargetingSystem.TargetingTimer / 2)
                return
            }

            labelSearch := this.findWaypointWithLabel(label)
            if (labelSearch.labelFound = false) {
                return false
            }

            Waypoint := labelSearch.waypointFound
            tab := labelSearch.tabFound
            tab_prefix := labelSearch.tabFound "_"
            sessionString := "[" tab "]"
            writeCavebotLog("Action", (functionName ": ") LANGUAGE = "PT-BR" ? "Iniciando waypoint " Waypoint " do label """ label """, aba """ tab """" : "starting waypoint " Waypoint " of label """ label """, tab '" tab """")
            Waypoint--
            ; msgbox, label %waypoint% / tab: %tab%
            returnLabelWaypoint := params.abort
            IniWrite, % tab, %DefaultProfile%, cavebot, CurrentWaypointTab
            this.gotolabelWaypointRan := true
            _GoToLabelAction.stopWalkingToWaypointTimerLabel()
            return true
        }
        writeCavebotLog("ERROR", (functionName ": ") LANGUAGE = "PT-BR" ? "Label """ label """ não localizado**" : "Label """ label """ not found**")
        return false
    }

    findWaypointWithLabel(label) {
        labelSearch := WaypointHandler.findLabel(label)

        if (labelSearch.labelFound = false) {
            writeCavebotLog("ERROR", (functionName ": ") LANGUAGE = "PT-BR" ? "Label """ label """ não existe" : "Label """ label """ doesn't exist")
        }

        return labelSearch
    }

    lifepercent(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "lifepercent"

        params := {}
            , params.percent := this.getNumberParam(functionValues.1)

            , params := this.checkParamsVariables(params)

        if (params.percent < 1 OR params.percent > 100) {
            writeCavebotLog("ERROR", (functionName ": ") "Invalid percentage value to check: " params.percent)
            return false
        }

        if (!IsObject(HealingSystem)) {
            writeCavebotLog("ERROR", "HealingSystem not initialized")
            return false
        }

        result := HealingSystem.hasLifePercent(params.percent)
        writeCavebotLog("Action", (functionName ": ") "Life is at " params.percent "%: " (result = true ? "true" : "false"))
        return result
    }

    isbattlelistempty(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "isbattlelistempty"

        try battleEmpty := new _IsBattleListEmpty()
        catch e {
            writeCavebotLog("ERROR", (functionName ": ") e.Message)
            return -1
        }

        return battleEmpty
    }

    isplayersbattlelistempty() {
        writeCavebotLog("Action", this.string_log)
        functionName := "isplayersbattlelistempty"

        try {
            return new _SearchPlayersBattleList().found()
        } catch e {
            writeCavebotLog("ERROR", (functionName ": ") e.Message)
            return -1
        }

        return battleEmpty
    }

    hascooldown(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "hascooldown"

        params := {}
            , params.type := functionValues.1
            , params.spell := functionValues.2

            , params := this.checkParamsVariables(params)

        writeCavebotLog("Action", (functionName ": ") "Type: " params.type " | Spell: " params.spell)

        hasCooldown := AttackSpell.hasCooldown(0, false, false, false, {"type": params.type, "spell": params.spell})

        writeCavebotLog("Action", (functionName ": ") "Cooldown: " (hasCooldown = true ? "true" : "false"))

        return hasCooldown
    }

    isattacking(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "isattacking"

        isAttacking := new _IsAttacking().found()

        writeCavebotLog("Action", (functionName ": ") "Attacking: " (isAttacking = true ? "true" : "false"))

        return isAttacking
    }

    isdisconnected(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "isdisconnected"

        isDisconnected := isDisconnected()

        writeCavebotLog("Action", (functionName ": ") "Disconnected: " (isDisconnected = true ? "true" : "false"))

        return isDisconnected
    }

    isfollowing(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "isfollowing"

        _search := new _SioSystem().isFollowing()
        isFollowing := _search.found()

        writeCavebotLog("Action", (functionName ": ") "Following: " (isFollowing = true ? "true" : "false"))

        return isFollowing
    }

    islocation(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "islocation"

        params := {}
            , params.x := this.getNumberParam(functionValues.1)
            , params.y := this.getNumberParam(functionValues.2)
            , params.z := this.getNumberParam(functionValues.3)

            , params := this.checkParamsVariables(params)

        checkWaypointCoords := false
        if (params.x = "" OR params.y = "")
            params.x := mapX, params.y = mapY, params.z = mapZ, checkWaypointCoords := true

        getCharPos()

        isAtLocation := CavebotWalker.isSameCoords(params.x, params.y, params.z, posx, posy, posz)
        if (isAtLocation = false) && (checkWaypointCoords = true) {
            rangeX := WaypointHandler.getAtribute("rangeX", Waypoint, tab)
            rangeY := WaypointHandler.getAtribute("rangeY", Waypoint, tab)

            isAtLocation := CavebotWalker.isInWaypointRange(mapX, mapY, rangeX, rangeY)
        }

        writeCavebotLog("Action", (functionName ": ") (isAtLocation = true ? "true" : "false") " | Coords: " params.x "," params.y "," params.z ". Char: " posx "," posy "," posz)
        return isAtLocation
    }


    level(functionValues := "") {
        functionName := "level"

        return this.readSkillWindow(functionName, "level")
    }


    itemcount(functionValues, fromPersistent := false)
    {
        functionName := "itemcount"

        params := {}
            , params.itemName := functionValues.1
            , params := this.checkParamsVariables(params)

        itemName := params.itemName
        if (!itemsImageObj[itemName]) {
            _Logger.error(functionName, "item """ itemName """ doesn't exist in the items list")
            return -1
        }

        if (isNotTibia13()) {
            return new _ItemCountSlotsAction()
                .setValues(params)
                .run()
        }

        timer := new _Timer()

        _Logger.info(functionName, "Searching item """ itemName """...")

        try {
            _search := new _ItemSearch()
                .setName(itemName)
                .setArea(new _ActionBarArea())
                .setSize(_ItemSearch.SIZE_BAR)
                .setLoopCountAnimation(40)
                .setInvertOrder()
                .search()

            if (_search.notFound()) {
                Sleep, 500

                _search.search()
                if (_search.notFound()) {
                    _Logger.error(functionName, txt("item """ itemName """ não localizado na Action Bar", "item """ itemName """ not found on the Action Bar"))

                    return "0"
                }
            }
        } catch e {
            _Logger.exception(e, functionName, itemName)
            return -1
        }

        c1 := _search.getResult()
            .subX(isRubinot() ? 10 : 7)
            .addY(1)
        c2 := new _Coordinate(_search.getX(), _search.getY())
            .addX(9)
            .addY(isRubinot() ? 9 : 11)
        coordinates := new _Coordinates(c1, c2)
        ; coordinates.debug()

        itemAmount := this.readActionBarOCR(coordinates.getX1(), coordinates.getY1(), coordinates.getX2(), coordinates.getY2(), "actionbar", 4, debugNumbers := 0, debugColumns := false)

        _Logger.log("Action", """" itemName """, amount: " itemAmount " (" timer.elapsed() " ms)", functionName)

        return itemAmount
    }

    itemsearch(functionValues)
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _ItemSearch()
                .setAllResults(true)
        }

        writeCavebotLog("Action", this.string_log)
        functionName := "itemsearch"

        params := {}
            , params.item := functionValues.1
            , params.searchArea := functionValues.2
            , params.x1 := this.getNumberParam(functionValues.3)
            , params.y1 := this.getNumberParam(functionValues.4)
            , params.x2 := this.getNumberParam(functionValues.5)
            , params.y2 := this.getNumberParam(functionValues.6)

            , params := this.checkParamsVariables(params)

            , params.searchArea := (params.searchArea = "") ? _SideBarsArea.NAME : params.searchArea

        writeCavebotLog("Action", functionName ": " params.item )

        if (!itemsImageObj[params.item]) {
            writeCavebotLog("ERROR", (functionName ": ")  "Item """ params.item """ doesn't exist in the items list")
            return -1
        }

        try {
            _search := searchCache
                .setName(params.item)
                .setArea(new _ClientAreaFactory(params.searchArea))

            if (_ActionScriptValidation.validateUserDefinedSearchArea(functionName, params)) {
                _search.setCoordinates(_Coordinates.FROM_ARRAY(params))
                writeCavebotLog("Action", functionName ": x1: " params.x1 ", y1: " params.y1 ", x2: " params.x2 ", y2: " params.y2)
            }

            _search.search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, params.item)
            return -1
        }

        lastItemSearchX := _search.getResults()[1].getX()
        lastItemSearchY := _search.getResults()[1].getY()

        writeCavebotLog("Action", (functionName ": ") _search.getResultsCount() " """ params.item """ found on screen")
        return _search.getResultsCount()
    }

    takeitemfromstash(functionValues)
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _ItemSearch()
                .setSize(_ItemSearch.SIZE_BAR)
        }


        writeCavebotLog("Action", this.string_log)
        functionName := "takeitemfromstash"

        params := {}
            , params.item := functionValues.1
            , params.amountToTake := this.getNumberParam(functionValues.2)
            , params.amountDecrease := this.getNumberParam(functionValues.3)

            , params := this.checkParamsVariables(params)

            , params.amountDecrease := params.amountDecrease < 0 ? 0 : params.amountDecrease

        params.amountToTake -= params.amountDecrease
        if (params.amountToTake < 1) {
            writeCavebotLog("Action", functionName ": """ params.item """, amount to take lower than 1")
            return true
        }

        writeCavebotLog("Action", functionName ": " params.item " | " params.amountToTake " | " params.amountDecrease)

        if (!new _OpenDepotAction().run()) {
            return false
        }

        Loop, 3 {
            Send("Esc") ; close any window before opening
        }

        Sleep, 200

        if (!this.openStash(functionName)) {
            Send("Esc")
            return false
        }

        Loop, 2 {
            MouseClick("Left", this.stashWindowArea.getX2() + 10, this.stashWindowArea.getY1() - 15, false) ; clear search button
            Sleep, 50
        }

        Sleep, 50

            new _ImageSearch()
            .setFile("clear_input_field")
            .setFolder(ImagesConfig.clientButtonsFolder)
            .setVariation(50)
            .setClickOffsets(6)
            .search()
            .click()

        Sleep, 400
        Send(params.item)
        Sleep, 400

        try {
            _search := searchCache
                .setName(params.item)
                .setLoopCountAnimation(40)
                .setInvertOrder()
                .setCoordinates(this.stashWindowArea)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, params.item)
            return false
        }

        if (_search.notFound()) {
            Send("Esc")
            writeCavebotLog("Action", functionName ": item """ params.item """ not found in the Supply Stash")
            return false
        }

        _search.click()

        Sleep, 400
        if (!this.retrieveWindow(functionName)) {
            Send("Esc")
            return false
        }

        _search.setCoordinates(_Coordinates.FROM_ARRAY(this.retrieveWindowArea))
            .setSize(_ItemSearch.SIZE_HALF)
            .search()

        if (_search.notFound()) {
            Send("Esc")
            writeCavebotLog("Action", functionName ": item """ params.item """ not found in the Retrieve window")
            return false
        }

        c1 := _search.getResult()
            .subX(13)
            .addY(7)
        c2 := new _Coordinate(_search.getX(), _search.getY())
            .addX(isRubinot() ? 10 : 9)
            .addY(13)
        coordinates := new _Coordinates(c1, c2)

        timer := new _Timer()
        itemAmountTotal := this.readActionBarOCR(coordinates.getX1(), coordinates.getY1(), coordinates.getX2(), coordinates.getY2(), "stash", 4, debugNumbers := false, debugColumns := false)

        if (!itemAmountTotal) {
            Send("Esc")
            writeCavebotLog("ERROR", functionName ": item """ params.item """ failed to count total amount", true)
            return false
        }

        writeCavebotLog("Action", functionName ": """ params.item """, amount in stash: " itemAmountTotal " (" timer.elapsed() " ms)")

        if (params.amountToTake > itemAmountTotal) {
            params.amountToTake := itemAmountTotal
        }

        Send(params.amountToTake)
        Sleep, 200

        Send("Enter")
        Sleep, 300


        /*
        close stash window after items were taken
        */
        Loop, 3 {
            Send("Esc")
            Sleep, 100
        }

        writeCavebotLog("Action", functionName ": """ params.item """, amount taken: " params.amountToTake "/" itemAmountTotal)
        return true
    }

    retrieveWindow(functionName, fastCheck := false)
    {
        if (fastCheck = true) {
            _search := this.searchRetrieveWindow()
            if (_search.found()) {
                goto, retrieveWindowFound
            }

            return false
        }

        Loop, 4 {
            _search := this.searchRetrieveWindow()
            if (_search.found()) {
                break
            }

            Sleep, 250
        }

        if (_search.notFound()) {
            writeCavebotLog("ERROR", (functionName ": ") "Retrieve item window not found")
            return false
        }

        retrieveWindowFound:
        this.retrieveWindowArea := {}
        this.retrieveWindowArea.x1 := _search.getX() - 75
        this.retrieveWindowArea.y1 := _search.getY() + 20
        this.retrieveWindowArea.x2 := this.retrieveWindowArea.x1 + 240
        this.retrieveWindowArea.y2 := this.retrieveWindowArea.y1 + 100
        return true
    }

    /**
    * @param bool click
    * @return _ImageSearch
    */
    searchStashBox(click := true) {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFile(ImagesConfig.stash.stashBox)
                .setFolder(ImagesConfig.stashFolder)
                .setVariation(50)
                .setArea(new _SideBarsArea())
                .setResultOffsets(12)
        }

        Loop, 4 {
            _search := searchCache

            try {
                _search.search()

                if (click) {
                    _search.click("Right")
                }
            } catch e {
                _Logger.exception(e, A_ThisFunc)
                return _search
            }

            if (_search.found()) {
                break
            }

            Sleep, 250
        }

        return _search
    }

    openStash(functionName)
    {
        _search := this.searchStashWindow()

        if (_search.found()) {
            goto, stashWindowFound
        }

        if (this.searchStashBox().notFound()) {
            writeCavebotLog("ERROR", (functionName ": ") "Stash box not found")
            return false
        }

        Loop, 4 {
            _search := this.searchStashWindow()
            if (_search.found()) {
                break
            }

            Sleep, 250
        }

        if (_search.notFound()) {
            writeCavebotLog("ERROR", (functionName ": ") "Stash window not found")
            return false
        }

        stashWindowFound:
        c1 := _Coordinate.FROM(_search.getResult())
            .subX(240)
            .addY(60)
        c2 := _Coordinate.FROM(c1)
            .addX(555)
            .addY(320)

        this.stashWindowArea := new _Coordinates(c1, c2)
        return true
    }

    searchStashWindow()
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFolder(ImagesConfig.stashFolder)
                .setVariation(50)
        }

        _search := searchCache
            .setFile(ImagesConfig.stash.stashWindow)
            .search()

        if (_search.notFound()) {
            _search.setFile("stash_window_2")
                .search()
        }

        return _search
    }


    searchRetrieveWindow()
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFile("retrieve_items_window")
                .setFolder(ImagesConfig.stashFolder)
                .setVariation(50)
        }

        _search := searchCache
            .search()

        if (_search.notFound()) {
            _search.setFile("retrieve_items_window_2")
                .search()
        }

        return _search
    }

    imagesearch(functionValues := "") {
        static searchCache
        if (!searchCache) {
            searchCache := new _Base64ImageSearch()
                .setTransColor("0")
                .setAllResults(true)
        }

        timer := new _Timer()

        writeCavebotLog("Action", this.string_log)
        functionName := "imagesearch"

        params := {}
            , params.imageName := functionValues.1
            , params.searchArea := functionValues.2
            , params.variation := functionValues.3
            , params.x1 := this.getNumberParam(functionValues.4)
            , params.y1 := this.getNumberParam(functionValues.5)
            , params.x2 := this.getNumberParam(functionValues.6)
            , params.y2 := this.getNumberParam(functionValues.7)

            , params := this.checkParamsVariables(params)

            , params.variation := (params.variation < 1) ? _ScriptImages.DEFAULT_VARIATION : params.variation
            , params.searchArea := (params.searchArea = "") ? _WindowArea.NAME : params.searchArea

        if  (!IsObject(scriptImagesObj[params.imageName])) {
            writeCavebotLog("ERROR", (functionName ": ")  "Image """ params.imageName """ does not exist in Script images")
            return -1
        }

        try {
            _search := searchCache
                .setImage(new _ScriptImage(params.imageName))
                .setVariation(params.variation)
                .setArea(new _ClientAreaFactory(params.searchArea))

            if (_ActionScriptValidation.validateUserDefinedSearchArea(functionName, params)) {
                _search.setCoordinates(_Coordinates.FROM_ARRAY(params))
                writeCavebotLog("Action", functionName ": image: " params.imageName " | variation: " params.variation " | x1: " params.x1 ", y1: " params.y1 ", x2: " params.x2 ", y2: " params.y2)
            } else {
                writeCavebotLog("Action", functionName ": image: " params.imageName " | search area: " params.searchArea " | variation: " params.variation)
            }

            _search.search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, params.imageName)
            return -1
        }

        writeCavebotLog("Action", (functionName ": ") _search.getResultsCount() " """ params.imageName """ images found on screen (" timer.elapsed() "ms)")

        lastImageSearchX := _search.getResults()[1].getX()
        lastImageSearchY := _search.getResults()[1].getY()

        return _search.getResultsCount()
    }

    luremode(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "luremode"

        params := {}
            , params.creatures := this.getNumberParam(functionValues.1)
            , params.creaturesMinimum := this.getNumberParam(functionValues.2)

            , params := this.checkParamsVariables(params)

        writeCavebotLog("Action", functionName ": starting with " params.creatures " creatures")

        /*
        if attackAllMode is enabled and there is only the "all" creature, send an error
        */
        if (targetingObj.settings.attackAllMode = true) {
            writeCavebotLog("INFO", (functionName ": ") txt("O modo de attack All(todos) está ativo, o luremode irá contar qualquer criatura, player ou NPC que aparecer no Battle List", "The attack All mode is enabled, the luremode will count any creature, player or NPC that appears on the Battle List") )
        }


        targetingSystemObj.luremode.enabled := true
        targetingSystemObj.luremode.creatures := params.creatures
        targetingSystemObj.luremode.creaturesMinimum := params.creaturesMinimum > 0 ? params.creaturesMinimum : 0
        return true
    }

    luremodestop(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "luremodestop"

        targetingSystemObj.luremode.enabled := false
    }

    luremodewalkingattack(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "luremodewalkingattack"

        params := {}
            , params.hotkey1 := functionValues.1
            , params.spell1 := functionValues.2
            , params.hotkey2 := functionValues.3
            , params.spell2 := functionValues.4
            , params.hotkey3 := functionValues.5
            , params.spell3 := functionValues.6
            , params := this.checkParamsVariables(params)


        targetingSystemObj.luremode.timerAttack.spells.1.hotkey := params.hotkey1
            , targetingSystemObj.luremode.timerAttack.spells.1.spell := params.spell1
            , targetingSystemObj.luremode.timerAttack.spells.2.hotkey := params.hotkey2
            , targetingSystemObj.luremode.timerAttack.spells.2.spell := params.spell2
            , targetingSystemObj.luremode.timerAttack.spells.3.hotkey := params.hotkey3
            , targetingSystemObj.luremode.timerAttack.spells.3.spell := params.spell3

        if (!TargetingEnabled) {
            writeCavebotLog("WARNING", txt("O Targeting está desativado", "The Targeting disabled"), true)
            return
        }

        if (TargetingEnabled = 1) {
            if (!targetingSystemObj.luremode.enabled) {
                writeCavebotLog("WARNING", txt("O Lure Mode não está ativo", "The Lure Mode is not enabled"), true)
            }

            targetingSystemObj.luremode.timerAttack.enabled := true
            TargetingSystem.startLureModeTimerAttack()
        }
    }

    luremodewalkingattackstop(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "luremodewalkingattackstop"

        if (TargetingEnabled = 1) {
            targetingSystemObj.luremode.timerAttack.enabled := false
            TargetingSystem.stopLureModeTimerAttack()
        }
    }

    log(functionValues := "") {
        ; writeCavebotLog("Action", this.string_log)
        functionName := "log"

        params := {}
            , params.message := functionValues.1
            , params := this.checkParamsVariables(params)


        writeCavebotLog("Action", (functionName ": ") params.message)

    }

    distancelooting(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "distancelooting"

        if (lootingObj.settings.searchCorpseImages = true) {
            DistanceLooting.addCoordsFromCreatureCorpse(waitDelay := false)
        }

        DistanceLooting.runLootingQueue()
    }


    lootaround(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "lootaround"

        LootingSystem.lootAroundFromTargeting()
    }

    math(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "math"

        params := {}
            , params.operand1 := this.getNumberParam(functionValues.1)
            , params.operator := functionValues.2
            , params.operand2 := this.getNumberParam(functionValues.3)

            , params := this.checkParamsVariables(params)


        result := ""
        switch params.operator {
            case "add", case "+": result := params.operand1 + params.operand2
            case "sub", case "-": result := params.operand1 - params.operand2
            case "mul", case "*": result := params.operand1 * params.operand2
            case "div", case "/": result := params.operand1 / params.operand2
            default:
                writeCavebotLog("ERROR", (functionName ": ") "Invalid operator: """ params.operator """")
        }

        writeCavebotLog("Action", (functionName ": ") params.operand1 " " params.operator " " params.operand2 " = " result)
        return result
    }

    manapercent(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "manapercent"

        params := {}
            , params.percent := this.getNumberParam(functionValues.1)

            , params := this.checkParamsVariables(params)

        if (params.percent < 1 OR params.percent > 100) {
            writeCavebotLog("ERROR", (functionName ": ") "Invalid percentage value to check: " params.percent)
            return false
        }

        result := HealingSystem.hasManaPercent(params.percent)
        writeCavebotLog("Action", (functionName ": ") "Mana is at " params.percent "%: " (result = true ? "true" : "false"))
        return result
    }

    messagebox(functionValues := "") {
        writeCavebotLog("Action", this.string_log)

        params := {}
            , params.message := functionValues.1
        params := this.checkParamsVariables(params)

        ; MouseMove(lastImageSearchX, lastImageSearchY, debug := true)
        Msgbox, 64,, % params.message
    }

    minimapcenter(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "minimapcenter"

        try {
            area := CavebotSystem.cavebotJsonObj.minimap.options.searchCenterButtonEntireScreen ? new _WindowArea() : new _MinimapArea()

            _search := new _ImageSearch()
                .setFile(new _MinimapArea().images("center"))
                .setFolder(ImagesConfig.minimapCenterFolder)
                .setVariation(new _MinimapArea().images("variation"))
                .setCoordinates(area)
                .setClickOffsets(4)
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)

            return false
        }

        if (_search.notFound()) {
            return false
        }

        _search.click()
        Sleep, 25

        return true
    }

    minimapheight(functionValues := "")
    {
        writeCavebotLog("Action", this.string_log)
        functionName := "minimapheight"

        params := {}
            , params.height := this.getNumberParam(functionValues.1)

            , params := this.checkParamsVariables(params)


        minimumHeight := 80
        if (params.height < minimumHeight) {
            writeCavebotLog("ERROR", (functionName ": ") "Height " params.height " is lower than the minimum allowed " minimumHeight)
            return false
        }

        minimapArea := new _MinimapArea()

        currentHeight := minimapArea.getH()
            , diff := params.height - currentHeight
            , diff := (abs(diff) > 0 && abs(diff) <= 2) ? 0 : diff

        writeCavebotLog("Action", (functionName ": ") "Current height: " currentHeight ", height: " params.height ", difference: " abs(diff))

        if (diff = 0) {
            return true
        }

        if (diff < 0) {
            MouseDrag(minimapArea.getX1() + 10, minimapArea.getY2() + 1, minimapArea.getX1() + 2, minimapArea.getY2() - abs(diff))
        } else {
            MouseDrag(minimapArea.getX1() + 10, minimapArea.getY2() + 1, minimapArea.getX1() + 2, minimapArea.getY2() + diff)
        }

        Sleep, 50
        MouseMove(CHAR_POS_X, CHAR_POS_Y)
        Sleep, 25

        try  {
            _MinimapArea.INSTANCE := ""
                new _MinimapArea()
        } catch e {
            writeCavebotLog("ERROR", (functionName ": ") e.Message)
            return false
        }
        return true
    }

    minimapzoom(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "minimapzoom"

        params := {}
            , params.zoomLevel := functionValues.1
        params := this.checkParamsVariables(params)

        loopCount := abs(params.zoomLevel)
        imageMinimapButton := (params.zoomLevel < 0) ? "Minus" : "Plus"

        writeCavebotLog("Action", (functionName ": ") "Zoom: " params.zoomLevel)

        Loop, % loopCount {
            vars :=
            try {
                CavebotSystem.searchMinimapZoom(imageMinimapButton)
            } catch e {
                _Logger.exception(e, A_ThisFunc)
                return false
            }

            MouseClick("Left", vars.x + 4, vars.y + 4)
            Sleep, 50
            MouseClick("Left", CHAR_POS_X, CHAR_POS_Y)
            Sleep, 25
            ; msgbox, % A_Index
            ; mouseMove(CHAR_POS_X, CHAR_POS_Y)
        }
        Sleep, 25
    }

    mousemove(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "mousemove"

        params := {}
            , params.x := this.getNumberParam(functionValues.1)
            , params.y := this.getNumberParam(functionValues.2)
            , params.debug := this.getNumberParam(functionValues.3)

            , params := this.checkParamsVariables(params)

            , params.x := params.x
            , params.y := params.y
            , params.debug := (params.debug = "true" OR params.debug = 1) ? true : false

        writeCavebotLog("Action", functionName ": " params.x " | " params.y " | debug: " params.debug)

        MouseMove(params.x, params.y, params.debug)
    }

    mousedrag(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "mousedrag"

        params := {}
            , params.x1 := this.getNumberParam(functionValues.1)
            , params.y1 := this.getNumberParam(functionValues.2)
            , params.x2 := this.getNumberParam(functionValues.3)
            , params.y2 := this.getNumberParam(functionValues.4)
            , params.repeat := this.getNumberParam(functionValues.5)

            , params := this.checkParamsVariables(params)

            , params.repeat := (params.repeat < 1) ? 1 : params.repeat

            , params.x1 := params.x1
            , params.y1 := params.y1
            , params.x2 := params.x2
            , params.y2 := params.y2


        writeCavebotLog("Action", functionName ": " params.x1 " | " params.y1 " | " params.x2 " | " params.y2 " | " params.repeat)

        Loop, % params.repeat {
            MouseDrag(params.x1, params.y1, params.x2, params.y2)
            Sleep, 500
        }
    }

    mousedragitem(functionValues := "") {
        writeCavebotLog("Action", this.string_log)

        functionName := "mousedragitem"

        params := {}
            , params.item1 := functionValues.1
            , params.item2 := functionValues.2
            , params.repeat := this.getNumberParam(functionValues.3)
            , params.delay := this.getNumberParam(functionValues.4)
            , params.holdshift := this.getNumberParam(functionValues.5)

            , params := this.checkParamsVariables(params)

            , params.delay := (params.delay < 1) ? 500 : params.delay
            , params.repeat := (params.repeat < 1) ? 1 : params.repeat
            , params.holdshift := (params.holdshift = 1) ? true : false

        writeCavebotLog("Action", functionName ": item1: " params.item1 ", item2: " params.item2 ", repeat: " params.repeat ", delay: " params.delay ", shift: " params.holdshift)

        item1 := new _ItemSearch()
            .setName(params.item1)

        item2 := new _ItemSearch()
            .setName(params.item2)

        Loop, % params.repeat {
            if (A_Index > 1) {
                Sleep, 50
            }

            item1.search()
            if (item1.notFound()) {
                _Logger.log("Item """ params.item1 """ not found on screen", functionName)
                break
            }

            item2.search()
            if (item2.notFound()) {
                _Logger.log("Item """ params.item2 """ not found on screen", functionName)
                break
            }

            x1 := item1.getX()
            y1 := item1.getY()
            x2 := item2.getX()
            y2 := item2.getY()

            writeCavebotLog("Action", (functionName ": ") " x1: " x1 ", y1: " y1 ", x2: " x2 ", y2: " y2 ", times: " A_Index "/" params.repeat)

            this.dragitem(x1, y1, x2, y2, params.holdshift, params.delay - 50)
        }

        return true
    }

    mousedragitemimage(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "mousedragitemimage"

        params := {}
            , params.item := functionValues.1
            , params.image := functionValues.2
            , params.repeat := this.getNumberParam(functionValues.3)
            , params.delay := this.getNumberParam(functionValues.4)
            , params.holdshift := this.getNumberParam(functionValues.5)

            , params := this.checkParamsVariables(params)

            , params.delay := (params.delay < 1) ? 700 : params.delay
            , params.repeat := (params.repeat < 1) ? 1 : params.repeat
            , params.holdshift := (params.holdshift = 1) ? true : false

        if (!itemsImageObj[params.item]) {
            writeCavebotLog("ERROR", (functionName ": ")  "Item """ params.item """ doesn't exist in the items list")
            return false
        }

        writeCavebotLog("Action", functionName ": item: " params.item " | image: " params.image " | " params.repeat " | " params.delay "ms | " params.holdshift)

        item :=  new _ItemSearch()
            .setName(params.item)

        Loop, % params.repeat {
            if (A_Index > 1) {
                Sleep, 50
            }

            item.search()
            if (item.notFound()) {
                _Logger.log("Item """ params.item """ not found on screen", functionName)
                break
            }

            try  {
                _search := _ScriptImages.search(params.image)
            } catch e {
                writeCavebotLog("ERROR", e.Message)
                return false
            }

            this.dragitem(item.getX(), item.getY(), _search.getX(), _search.getY(), params.holdshift, params.delay - 50, false)
        }
        return true
    }

    mousedragimage(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "mousedragimage"

        params := {}
            , params.image1 := functionValues.1
            , params.image2 := functionValues.2
            , params.repeat := this.getNumberParam(functionValues.3)
            , params.delay := this.getNumberParam(functionValues.4)
            , params.holdshift := this.getNumberParam(functionValues.5)
            , params.variation := this.getNumberParam(functionValues.6)

            , params := this.checkParamsVariables(params)

            , params.delay := (params.delay < 1) ? 700 : params.delay
            , params.repeat := (params.repeat < 1) ? 1 : params.repeat
            , params.holdshift := (params.holdshift = 1) ? true : false
            , params.variation := (params.variation < 1) ? 40 : params.variation

        writeCavebotLog("Action", functionName ": image 1: " params.image1 " | image 2: " params.image2 " | variation: " params.variation " | repeat: " params.repeat " | " params.delay "ms | " params.holdshift)

        Loop, % params.repeat {
            Sleep, 50
            try {
                image1 := _ScriptImages.search(params.image1, params.variation)
            } catch e {
                writeCavebotLog("ERROR", e.Message)
                return false
            }
            if (image1.notFound()) {
                writeCavebotLog("Action", (functionName ": ")  "Image 1 """ params.image1 """ not found")
                break
            }

            try {
                image2 := _ScriptImages.search(params.image2, params.variation)
            } catch e {
                writeCavebotLog("ERROR", e.Message)
                return false
            }

            if (image2.notFound()) {
                writeCavebotLog("Action", (functionName ": ")  "Image 2 """ params.image2 """ not found")
                break
            }

            this.dragitem(image1.getX(), image1.getY(), image2.getX(), image2.getY(), params.holdshift, params.delay - 50, false)
        }
        return true
    }


    mousedragimageposition(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "mousedragimageposition"

        params := {}
            , params.image := functionValues.1
            , params.x := this.getNumberParam(functionValues.2)
            , params.y := this.getNumberParam(functionValues.3)
            , params.repeat := this.getNumberParam(functionValues.4)
            , params.delay := this.getNumberParam(functionValues.5)
            , params.holdshift := this.getNumberParam(functionValues.6)
            , params.variation := this.getNumberParam(functionValues.6)

            , params := this.checkParamsVariables(params)

            , params.delay := (params.delay < 1) ? 700 : params.delay
            , params.repeat := (params.repeat < 1) ? 1 : params.repeat
            , params.variation := (params.variation < 1) ? 40 : params.variation

        writeCavebotLog("Action", functionName ": " params.item " | x: " params.x ", y: " params.y " | " params.repeat " | " params.delay "ms | " params.holdshift)

        Loop, % params.repeat {
            Sleep, 50
            try {
                _search := _ScriptImages.search(params.image, params.variation)
            } catch e {
                writeCavebotLog("ERROR", e.Message)
                return false
            }
            if (_search.notFound()) {
                writeCavebotLog("Action", (functionName ": ")  "Image """ params.image """ not found")
                if (params.repeat = 1)
                    return false
                break
            }
            params := this.checkIfPositionParamIsRelative(params, _search)

            this.dragitem(_search.getX(), _search.getY(), params.x, params.y, params.holdshift, params.delay - 50, false)
        }
        return true
    }

    checkIfPositionParamIsRelative(params, relativePos) {
        if (InStr(params.x, "+"))
            params.x := relativePos.x + StrReplace(params.x, "+", "")
        if (InStr(params.y, "+"))
            params.y := relativePos.y + StrReplace(params.y, "+", "")
        if (InStr(params.x, "-"))
            params.x := relativePos.x - StrReplace(params.x, "-", "")
        if (InStr(params.y, "-"))
            params.y := relativePos.y - StrReplace(params.y, "-", "")
        return params
    }

    mousedragimageitem(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "mousedragimageitem"

        params := {}
            , params.image := functionValues.1
            , params.item := functionValues.2
            , params.repeat := this.getNumberParam(functionValues.3)
            , params.delay := this.getNumberParam(functionValues.4)
            , params.holdshift := this.getNumberParam(functionValues.5)

            , params := this.checkParamsVariables(params)

            , params.delay := (params.delay < 1) ? 700 : params.delay
            , params.repeat := (params.repeat < 1) ? 1 : params.repeat
            , params.holdshift := (params.holdshift = 1) ? true : false

        if (!itemsImageObj[params.item]) {
            writeCavebotLog("ERROR", (functionName ": ")  "Item """ params.item """ doesn't exist in the items list")
            return false
        }

        writeCavebotLog("Action", functionName ": item: " params.item " | image: " params.image " | " params.repeat " | " params.delay "ms | " params.holdshift)

        item := new _ItemSearch()
            .setName(params.item)

        Loop, % params.repeat {
            if (A_Index > 1) {
                Sleep, 50
            }

            item.search()
            if (item.notFound()) {
                _Logger.log("Item """ params.item """ not found on screen", functionName)
                break
            }

            try {
                _search := _ScriptImages.search(params.image, params.variation)
            } catch e {
                writeCavebotLog("ERROR", e.Message)
                return false
            }

            if (_search.notFound()) {
                writeCavebotLog("Action", (functionName ": ")  "Image """ params.image """ not found")
                break
            }

            this.dragitem(_search.getX(), _search.getY(), item.getX(), item.getY(), params.holdshift, params.delay - 50, false)
        }
        return true
    }

    mousedragitemposition(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "mousedragitemposition"

        params := {}
            , params.item := functionValues.1
            , params.x := this.getNumberParam(functionValues.2)
            , params.y := this.getNumberParam(functionValues.3)
            , params.repeat := this.getNumberParam(functionValues.4)
            , params.delay := this.getNumberParam(functionValues.5)
            , params.holdshift := this.getNumberParam(functionValues.6)

            , params := this.checkParamsVariables(params)

            , params.delay := (params.delay < 1) ? 700 : params.delay
            , params.repeat := (params.repeat < 1) ? 1 : params.repeat

        writeCavebotLog("Action", functionName ": " params.item " | x: " params.x ", y: " params.y " | " params.repeat " | " params.delay "ms | " params.holdshift)

        item := new _ItemSearch()
            .setName(params.item)

        Loop, % params.repeat {
            if (A_Index > 1) {
                Sleep, 50
            }

            item.search()
            if (item.notFound()) {
                _Logger.log("Item """ params.item """ not found on screen", functionName)
                break
            }

            params := this.checkIfPositionParamIsRelative(params, itemPos)

            this.dragitem(item.getX(), item.getY(), params.x, params.y, params.holdshift, params.delay - 50, false)
        }

        return true
    }

    npchi(logFunc := false) {
        if (logFunc = true)
            writeCavebotLog("Action", this.string_log)

        functionName := "npchi"
        vars := ""
        try {
            vars := ImageClick({"image": ImagesConfig.chatDisabled
                    , "directory": ImagesConfig.npcTradeFolder
                    , "click": "Left", "offsetX": 3, "offsetY": 3
                    , "variation": 40
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }

        this.say({1: "hi"})

        if (isNotTibia13())
            return true
        Sleep, 500

        Loop, 4 {
            vars := ""
            try {
                vars := ImageClick({"image": ImagesConfig.chatOpened
                        , "directory": ImagesConfig.npcTradeFolder
                        , "variation": 40
                        , "funcOrigin": A_ThisFunc
                        , "debug": false})
            } catch e {
                _Logger.exception(e, A_ThisFunc)
            }
            if (vars.x)
                break
            Sleep, 300
        }
        if (!vars.x) {
            this.say({1: "hi"})
            Sleep, 500
            Loop, 4 {
                Sleep, 300
                vars := ""
                try {
                    vars := ImageClick({"image": ImagesConfig.chatOpened
                            , "directory": ImagesConfig.npcTradeFolder
                            , "variation": 40
                            , "funcOrigin": A_ThisFunc
                            , "debug": false})
                } catch e {
                    _Logger.exception(e, A_ThisFunc)
                }
                if (vars.x)
                    break
            }

        }
        if (!vars.x) {
            writeCavebotLog("ERROR", (functionName ": ") "Failed to open NPC chat")
            return false
        }
        return true
    }

    npctrade(logFunc := false, tradeMessage := "trade") {
        if (logFunc = true)
            writeCavebotLog("Action", this.string_log)

        functionName := "npctrade"

        this.getTradeWindowPosition(false)
        if (this.tradeWindow.x1 != "")
            return true

        if (!this.npchi())
            return false

        this.say({1: tradeMessage})
        Loop, 4 {
            this.getTradeWindowPosition(false)
            if (this.tradeWindow.x1 != "")
                break
            Sleep, 250
        }
        if (this.tradeWindow.x1 = "") {
            Sleep, 200
            if (!this.npchi())
                return false
            this.say({1: tradeMessage})
            Loop, 4 {
                Sleep, 250
                this.getTradeWindowPosition(false)
                if (this.tradeWindow.x1 != "")
                    break
            }

        }
        if (this.tradeWindow.x1 = "") {
            writeCavebotLog("ERROR", (functionName ": ") "Failed to open NPC trade window")
            return false
        }

        return true
    }

    traytip(functionValues := "") {
        writeCavebotLog("Action", this.string_log)

        params := {}
            , params.message := functionValues.1 = "" ? "Empty message" : functionValues.1

            , params := this.checkParamsVariables(params)

        Menu, Tray, Icon
        TrayTip, % "Cavebot notification", % params.message, 2, 1
        Menu, Tray, NoIcon

        SetTimer, HideTrayTipFunctions, Delete
        SetTimer, HideTrayTipFunctions, -4000
    }

    pausemodule(functionValues) {
        writeCavebotLog("Action", this.string_log)
        functionName := "pausemodule"

        params := {}
        params.module := functionValues.1
        params := this.checkParamsVariables(params)

        if (this.validateModuleName(params.module) = false) {
            writeCavebotLog("ERROR", functionName ": " " invalid module: " params.module)
            return false
        }

        module := params.module
        exeName := %module%ExeName
        writeCavebotLog("Action", functionName ": " params.module " | " exeName " | " this.pauseModuleManager[params.module])

        if (this.pauseModuleManager[params.module]) {
            writeCavebotLog("Action", functionName txt(": o módulo """ params.module """ já está pausado", ": module """ params.module """ is already paused") )
            return false
        }

        Process, Exist, % exeName
        if (ErrorLevel = 0) {
            writeCavebotLog("Action", functionName ": module """ params.module """ currently not running, exe: " exeName)
            return false
        }
        PostMessage, 0x111, 65306,1,, % "Data\Executables\" exeName  ; Pause On.
        this.pauseModuleManager[params.module] := true
        return true
    }

    unpausemodule(functionValues) {
        writeCavebotLog("Action", this.string_log)
        functionName := "unpausemodule"

        params := {}
            , params.module := functionValues.1

            , params := this.checkParamsVariables(params)

        if (this.validateModuleName(params.module) = false) {
            writeCavebotLog("ERROR", functionName ": " " invalid module: " params.module)
            return false
        }

        module := params.module

        if (!this.pauseModuleManager[params.module]) {
            writeCavebotLog("Action", functionName txt(": o módulo """ params.module """ não foi pausado préviamente", ": module """ params.module """ has not been previously paused.") )
            return false
        }

        exeName := %module%ExeName
        writeCavebotLog("Action", functionName ": " params.module " | " exeName " | " this.pauseModuleManager[params.module])

        this.pauseModuleManager.Delete(params.module)

        Process, Exist, % exeName
        if (ErrorLevel = 0) {
            writeCavebotLog("Action", functionName ": module """ params.module """ currently not running, exe: " exeName)
            return false
        }

        PostMessage, 0x111, 65306, 2,, % "Data\Executables\" exeName ; Pause Off.
        return true
    }

    validateModuleName(module := "") {
        for key, moduleName in OldBotSettings.modulesList
        {
            if (module = moduleName)
                return true
        }
        return false
    }

    presskey(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "presskey"

        params := {}
            , params.hotkey := functionValues.1
            , params.repeat := this.getNumberParam(functionValues.2)
            , params.delay := this.getNumberParam(functionValues.3)

            , params := this.checkParamsVariables(params)

            , params.delay := (params.delay < 1) ? 250 : params.delay
            , params.repeat := (params.repeat < 1) ? 1 : params.repeat

        writeCavebotLog("Action", functionName ": " params.hotkey " | " params.repeat " | " params.delay)
        Loop, % params.repeat {
            if (InStr(params.hotkey, "^"))
                SendModifier("Ctrl", StrReplace(params.hotkey, "^", ""))
            else if (InStr(params.hotkey, "+"))
                SendModifier("Shift", StrReplace(params.hotkey, "+", ""))
            else if (InStr(params.hotkey, "!"))
                SendModifier("Alt", StrReplace(params.hotkey, "!", ""))
            else{
                ; msgbox, % params.hotkey
                ; switch params.hotkey {
                ;     Case "Down":
                ;         CavebotWalker.clickOnSQM(2, "Left")
                ;     Case "Up":
                ;         CavebotWalker.clickOnSQM(8, "Left")
                ;     Case "Left":
                ;         CavebotWalker.clickOnSQM(4, "Left")
                ;     Case "Right":
                ;         CavebotWalker.clickOnSQM(6, "Left")
                ; }

                Send(params.hotkey)
            }
            Sleep, 100
            if (A_Index > 0) {
                delay = params.delay - 100
                Sleep, % (delay > 1) ? delay : 0
            }
        }
    }

    write(functionValues := "", logFunc := false)
    {
        if (logFunc = true) {
            writeCavebotLog("Action", this.string_log)
        }

        functionName := "write"

        params := {}
            , params.message := functionValues.1

            , params := this.checkParamsVariables(params)

        /*
        remove line breaks from message
        */
        params.message := StrReplace(params.message, "`n", " ")
            , params.message := StrReplace(params.message, "`r", " ")
        /*
        words with '
        such as Ab'dendriel
        */
        switch (new _ClientInputIniSettings().get("writeMessagesWithPasteAction")) {
            case true: sendWithClipboard := true
            case false: sendWithClipboard := containsSpecialCharacter(params.message)
        }

        if (sendWithClipboard = true) {
            clipboardOld := Clipboard
            copyToClipboard(params.message)
            SendModifier("Ctrl", "v")
            copyToClipboard(clipboardOld)
        } else {
            Send(params.message)
        }

        return true
    }

    say(functionValues := "", logFunc := false)
    {
        if (logFunc = true)
            writeCavebotLog("Action", this.string_log)
        functionName := "say"

        params := {}
            , params.message := functionValues.1

            , params := this.checkParamsVariables(params)

        this.turnChatButtonAction("on")
        Sleep, 150

        this.write(functionValues, false)

        Sleep, 100
        Send("Enter")
        Sleep, 100

        if (new _CavebotIniSettings().get("turnChatOffAfterMessages")) {
            this.turnChatButtonAction("off")
        }

        Sleep, 75
        return true
    }

    screenshot(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "screenshot"

        Path := "Data\Screenshots\Screenshot_Action*.png", Number := 1
        Loop, %Path%
            Number++
        ScreenshotTela("Screenshot_Action" Number)

        writeCavebotLog("Action", (functionName ": ") "Screenshot saved on: Data\Screenshots\Screenshot_Action" Number ".png")


        return true
    }

    checkIsScriptImageTradeItem(itemName) {
        if (this.tradeListScriptImageItems[itemName] = true)
            return true

        /*
        if there is a script image with the item name and the "Item on trade category"
        do the script image search instead of imageSearchItem
        */
        for key, value in scriptImagesObj
        {
            if (value.category != "Item on Trade")
                continue
            if (key != itemName)
                continue
            if (!IsObject(this.tradeListScriptImageItems[itemName]))
                this.tradeListScriptImageItems[itemName] := {}
            this.tradeListScriptImageItems[itemName] := true

            ; msgbox, % key "`n" serialize(value)
            return true
        }
        return false
    }

    checkItemVisibleSellAction(itemName) {
        if (lootingObj.sellList[selectedItem].mustBeVisible = false)
            return true

        /*
        if the item is not visible on screen, continue
        */
    }

    /**
    * @return _Coordinate
    */
    searchItemOnTradeList(functionName, itemName, sellItemAction := false, tradeY2 := "", onlyFirstSprite := true) {
        /*
        if there is a script image with the item name and the "Item on trade" category
        do the script image search instead of imageSearchItem
        */
        if (this.checkIsScriptImageTradeItem(itemName) = true) {
            writeCavebotLog("ACTION", (functionName ": ") "Searching """ itemName """ using Script Image..")
            try {
                _search := _ScriptImages.search(itemName, params.variation)
            } catch e {
                writeCavebotLog("ERROR", (functionName ": ") e.Message)
            }
            return _search.getResult()
        }

        if (this.checkItemHasNameOnTradeListImage(itemName)) {
            return this.searchItemNameImageOnTradeList(itemName)
        }

        try {
            c1 := _Coordinate.FROM_ARRAY(this.tradeWindow, 1)
            c2 := new _Coordinate(this.tradeWindow.x2, (tradeY2 ? tradeY2 : this.tradeWindow.y2))
            coordinates := new _Coordinates(c1, c2)

            _search := new _ItemSearch()
                .setName(itemName)
                .setSize(_ItemSearch.SIZE_FULL)
                .setCoordinates(coordinates)
                .setOption("trade", true)

            if (onlyFirstSprite) {
                _search.setOnlyOneSprite()
            }

            _search.search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, itemName)
        }

        return _search.getResult()
    }

    checkItemHasNameOnTradeListImage(itemName) {
        /*
        if is a small enchanted ruby or others
        */
        if (InStr(itemName, "small enchanted "))
            return true
        if (FileExist(ImagesConfig.npcItemsFolder "\" itemName ".png"))
            return true

        return false
    }

    searchItemTradeWindow(functionName, params) {
        if (this.checkItemHasNameOnTradeListImage(itemName)) {
            vars := this.searchItemNameImageOnTradeList(params.item)
        } else {
            vars := this.searchItemOnTradeList(functionName, params.item)
        }

        if (vars.x) {
            return vars
        }

        return false
    }

    /**
    * @return _Coordinate
    */
    searchItemNameImageOnTradeList(itemName) {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFolder(ImagesConfig.npcItemsFolder)
        }

        if (InStr(itemName, "small enchanted ")) {
            itemName := "small enchanted"
        }

        try {
            _search := searchCache
                .setFile(itemName)
                .setCoordinates(_Coordinates.FROM_ARRAY(this.tradeWindow))
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, itemName)
        }

        return _search.getResult()
    }

    sellitemnpc(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "sellitemnpc"

        params := {}
            , params.item := functionValues.1
            , params.tradeMessage := functionValues.2

            , params := this.checkParamsVariables(params)

        if (!this.handleTradeSellItem(functionName, params)) {
            return false
        }

        if (params.item = "LootList" OR params.item = "SellList" OR params.item = "DepositList" OR params.item = "TrashList") {
            return this.sellItemListNpc(params.item)
        }

        if (!itemsImageObj[params.item]) {
            writeCavebotLog("ERROR", (functionName ": ")  "item """ params.item """ doesn't exist in the items list")
            return false
        }

        success := this.sellItemNpcAction(params.item)
        return success
    }

    sellallitemsnpc(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "sellallitemsnpc"

        params := {}
            , params.tradeMessage := functionValues.1

            , params := this.checkParamsVariables(params)

        if (!this.handleTradeSellItem(functionName, params)) {
            return false
        }

        if (!this.handleTradeWindowSellItem(functionName)) {
            return false
        }

        /*
        Search for the slider button, if it is found and amount zero is not, continue clicking on OK button
        */
        sellingTimes := 1
        Loop, {
            if (sellingTimes > cavebotSystemObj.sellAllItemsLimit) {
                break
            }

            /*
            click on the first item on trade window
            */
            coord := _Coordinate.FROM_ARRAY(this.tradeWindow)
                .addX(16)
                .addY(62)
                .click()

            Sleep, 150

            _search := this.searchInputWithAmountZero(functionName)
            if (_search.found()) {
                break
            }

            if (OldBotSettings.settingsJsonObj.settings.cavebot.tradeWindowSummerUpdate1290 && cavebotSystemObj.tradeWindowWithSearchBox) {
                vars := this.searchAmountFieldTrade(functionName)
                if (!vars) {
                    return false
                }

                this.writeOnInputField(999, click := true, vars.x + 65, vars.y + 5, deleteContents := false)
            }

            writeCavebotLog("Action", functionName ": Selling items, times: " sellingTimes "/" cavebotSystemObj.sellAllItemsLimit )

            if (!this.okButton()) {
                return false
            }

            Sleep, 250
            sellingTimes++

        }

        writeCavebotLog("Action", functionName ": finished selling items")

        return return true
    }

    /**
    * @param string functionName
    * @param array params
    * @return bool
    */
    handleTradeSellItem(functionName, params) {
        this.npcTradeMessage := !empty(params.tradeMessage) ? params.tradeMessage : "trade"

        if (this.npcTradeMessage != "trade") {
            writeCavebotLog("Action", (functionName ": ") "Scroll down limit (scrollDownSellLimit): " cavebotSystemObj.scrollDownSellLimit " | trade message: """ this.npcTradeMessage """" )
        }

        if (!this.checksTradeBeforeSell(functionName)) {
            return false
        }

        return true
    }

    sellItemListNpc(sellItemList := "") {
        functionName := "sellitemnpc"

        sellItemListObj := ""
        switch sellItemList {
            case "LootList":
                sellItemListObj := lootingObj[sellItemList]
            case "SellList":
                sellItemListObj := lootingObj[sellItemList]
            case "TrashList":
                sellItemListObj := lootingObj[sellItemList]
            case "DepositList":
                sellItemListObj := lootingObj[sellItemList]
            default:
                writeCavebotLog("ERROR", (functionName ": ")  "Invalid item list to sell: """ sellItemList """")
                return false

        }
        writeCavebotLog("Action", (functionName ": ") "Selling items of list: """ sellItemList """, items: " sellItemListObj.Count())

        /*
        new flow

        search for all the items without scrolling
        when a item is found, sell all of this items
        then restart the search again since the beginning of the list
        */
        itemListIndex := 1

        t1sellItemList := A_TickCount

        this.itemSellController := {}
        Loop, {
            itemNameSell := "", itemNameSellAtributes := ""
            /*
            get the item of the sell item list according to the current index of the loop
            */
            for itemName, atributes in sellItemListObj
            {
                if (A_Index = itemListIndex) {
                    itemNameSell := itemName
                        , itemNameSellAtributes := atributes
                    break
                }
            }

            if (!itemNameSell) {
                break
            }

            if (!IsObject(this.itemSellController[itemNameSell])) {
                this.itemSellController[itemNameSell] := {}
            }

            /*
            skip the current item if it has already been sold with success
            */
            if (this.itemSellController[itemNameSell].searchedOnList) {
                itemListIndex++
                continue
            }

            this.itemSellController[itemNameSell].searchedOnList := false
            if (this.sellItemNpcAction(itemNameSell, itemFromList := true)) {
                ; msgbox, sold %itemNameSell%
                this.itemSellController[itemNameSell].searchedOnList := true
                writeCavebotLog("Action", functionName ": finished selling """ itemNameSell """")

                /*
                when item is sold with success, the index must reset to one to search of all the
                items again from the start, expect with this current item
                */
                itemListIndex := 1
                continue
            }

            this.itemSellController[itemNameSell].searchedOnList := true

            itemListIndex++
        }

        sellItemListObj := ""
        this.itemSellController := ""
        writeCavebotLog("Action", functionName ": finished selling from list """ sellItemList """, elapsed: " ((A_TickCount - t1sellItemList) / 1000) " seconds" )
        return true

    }

    /**
    * @param string functionName
    * @return bool
    */
    handleTradeWindowSellItem(functionName) {
        if (!this.checkTradeWindow()) {
            return false
        }

        /*
        click on sell button again to go back to the start of the list
        */
        vars := this.clickOnSellButton(functionName)
        if (!vars) {
            return false
        }

        return true
    }

    sellItemNpcAction(itemName, itemFromList := false) {
        functionName := "sellitemnpc"

        if (!this.handleTradeWindowSellItem(functionName)) {
            return false
        }

        /*
        put the actual sell item actions in another function to be able to send trade after finishing the sell item action(when true or false)
        */
        success := this.sellItemToNPC(itemName, itemFromList)
        if (itemFromList) {
            return success
        }


        this.say({1: "trade"}) ; reset trade window to first state
        Sleep, 100
        this.resizeTradeWindow(2, true)

        Sleep, 25
        MouseMove(CHAR_POS_X, CHAR_POS_Y)

        return success
    }

    sellItemToNPC(itemNameSell, itemFromList := false) {
        functionName := "sellitemnpc"


        sellLoopCount := 1, itemIndex := 1, tradeY2 := this.tradeWindow.y2
        if (itemsImageObj[itemNameSell].sprites > 1) {
            sellLoopCount := 2
        }


        if (OldBotSettings.settingsJsonObj.settings.cavebot.tradeWindowSummerUpdate1290 && cavebotSystemObj.tradeWindowWithSearchBox) {
            this.filterItemNameFilter(functionName, itemNameSell)
            Sleep, 150 ; additional delay to wait for item to appear
        }

        /*
        if item has more than one sprite, try to search for it 2 times, one with the default trade window showing 2 items
        and again showing only one, this is needed to sell for example 2 different types of empty potion flask
        */
        _searchItemAgainToSell:
        logString := functionName ": searching """ itemNameSell """, scrollDownSellLimit: " cavebotSystemObj.scrollDownSellLimit ".."
        if (itemsImageObj[itemNameSell].animated_sprite) {
            hasItemNameImage := false
            if (FileExist(ImagesConfig.npcItemsFolder "\" itemNameSell ".png") OR this.checkIsScriptImageTradeItem(itemNameSell) = true) {
                hasItemNameImage := true
            }

            writeCavebotLog("Action", logString (hasItemNameImage = false ? ". (item with animation and no Script Image with ""Item on Trade"" category, slower search)" : ""))
        } else {
            writeCavebotLog("Action", logString)
        }

        Loop, % sellLoopCount {
            ; m("itemIndex " itemIndex ", sprites " itemsImageObj[itemNameSell].sprites)
            if (itemsImageObj[itemNameSell].sprites > 1) && (itemIndex = 2) {
                writeCavebotLog("Action", functionName ": searching """ itemNameSell """.. (second time)")
                this.say({1: this.npcTradeMessage})
                Sleep, 100
                this.resizeTradeWindow(1)
                Sleep, 100
                ; msgbox, resize1
                this.getTradeWindowPosition()
                if (this.tradeWindow.x1 = "") {
                    writeCavebotLog("ERROR", (functionName ": ") "Empty trade window position")
                    return false
                }
                Sleep, 100
                vars := this.clickOnSellButton(functionName)
                if (vars = "")
                    return false
            }

            itemIndex++
            vars := {}
            Loop, % (cavebotSystemObj.scrollDownSellLimit < 1 ? 1 : cavebotSystemObj.scrollDownSellLimit) {
                if (A_Index > 1)
                    Sleep, 75

                /*
                - 50 to not find the item right up the OK button
                */
                vars := this.searchItemOnTradeList(functionName, itemNameSell, sellItemAction := true, tradeY2, onlyFirstSprite := false)

                if (vars.x) {
                    break
                }

                if (!this.scrollWindow("down")) {
                    return false
                }
            }
            if (vars.x)
                break
        }

        if (!vars.x) {
            writeCavebotLog("Action", functionName ": """ itemNameSell """ not found")
            return false
        }

        MouseClick("Left", vars.x + 50, vars.y + 5)
        Sleep, 50

        /*
        Search for the slider button, if it is found and amount zero is not, continue clicking on OK button
        */
        sellingTimes := 1
        Loop, {
            if (sellingTimes > cavebotSystemObj.sellItemTimesLimit) {
                break
            }

            _search := this.searchAmountZero(functionName)
            if (_search.found()) {
                break
            }

            writeCavebotLog("Action", functionName ": Selling """ itemNameSell """, times: " sellingTimes "/" cavebotSystemObj.sellItemTimesLimit )

            if (OldBotSettings.settingsJsonObj.settings.cavebot.tradeWindowSummerUpdate1290 = true) && (cavebotSystemObj.tradeWindowWithSearchBox = true) {
                vars := this.searchAmountFieldTrade(functionName)
                if (vars = false) {
                    return false
                }

                this.writeOnInputField(999, click := true, vars.x + 65, vars.y + 5, deleteContents := false)
            }

            if (!this.okButton()) {
                return false
            }

            Sleep, 500
            sellingTimes++
            vars := this.searchSlider(functionName)
            if (!vars.x) {
                break
            }
        }
        /*
        if item has more than 1 sprite, go back to try and sell again(empty potion flask)
        */
        ; msgbox, % itemsImageObj[itemNameSell].sprites " /// " itemIndex
        if (itemsImageObj[itemNameSell].sprites > 1) && (itemIndex <= itemsImageObj[itemNameSell].sprites)
            goto, _searchItemAgainToSell
        ; msgbox, 16,, finished


        ; Sleep, 100

        finishSell:

        if (itemFromList = false)
            writeCavebotLog("Action", functionName ": finished selling """ itemNameSell """")
        ; msgbox, finished sell
        return true
    }

    checksTradeBeforeSell(functionName) {
        if (this.npctrade(false, this.npcTradeMessage) = false)
            return false

        if (this.checkTradeWindow() = false)
            return false

        this.say({1: this.npcTradeMessage})
        Sleep, 100

        /*
        click on sell button 2 times
        */
        vars := this.clickOnSellButton(functionName)
        if (vars = "")
            return false

        return true
    }

    clickOnSellButton(functionName) {
        Loop, 3 {
            vars := ""
            Loop, % ImagesConfig.npcTradeFolder "\" "sell_button" "*" {
                try {
                    vars := ImageClick({"x1": this.tradeWindow.x1, "y1": this.tradeWindow.y1, "x2": this.tradeWindow.x2, "y2": this.tradeWindow.y2
                            , "image": A_LoopFileFullPath
                            , "variation": 50
                            , "click": "Left", "offsetX": 6, "offsetY": 6
                            , "funcOrigin": A_ThisFunc
                            , "debug": false})
                } catch e {
                    _Logger.exception(e, A_ThisFunc)
                }
                if (vars.x) {
                    break
                }
            }

            if (A_index = 3) && (!vars.x) {
                writeCavebotLog("ERROR", (functionName ": ") "NPC ""sell"" button not found")
                return false
            }
            if (vars.x) {
                Sleep, 500
                break
            }
            Sleep, 100
        }
        return vars
    }

    /**
    * @return _Coordinate
    */
    searchSlider(functionName) {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFile("slider")
                .setFolder(ImagesConfig.npcTradeFolder)
                .setVariation(30)
                .setClickOffsets(6)
        }

        _search := searchCache
        try {
            _search.setCoordinates(_Coordinates.FROM_ARRAY(this.tradeWindow))
                .search()
                .click()
        } catch e {
            _Logger.exception(e, A_ThisFunc, functionName)
        }

        return _search.getResult()
    }

    /**
    * @return _ImageSearch
    */
    searchAmountZero(functionName) {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFile("amount0")
                .setFolder(ImagesConfig.npcTradeFolder)
                .setVariation(40)
        }

        _search := searchCache
        try {
            _search.setCoordinates(_Coordinates.FROM_ARRAY(this.tradeWindow))
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, functionName)
        }

        return _search
    }

    /**
    * @return _ImageSearch
    */
    searchInputWithAmountZero(functionName) {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFile("amount0_input")
                .setFolder(ImagesConfig.npcTradeFolder)
                .setVariation(50)
        }

        _search := searchCache
        try {
            _search.setCoordinates(_Coordinates.FROM_ARRAY(this.tradeWindow))
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc, functionName)
        }

        return _search
    }

    setlocation(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "setlocation"

        params := {}
            , params.x := functionValues.1
            , params.y := functionValues.2
            , params.z := functionValues.3

            , params := this.checkParamsVariables(params)

        try {
            _Validation.mapCoordinates("params", params.x, params.y, params.z)
        } catch e {
            _Logger.exception(e, functionName)
            return false
        }

        writeCavebotLog("Action", (functionName ": ") "x:"params.x ", y:" params.y ", z:" params.z)

        posx := params.x
        posy := params.y
        posz := params.z

        return true
    }

    setsetting(functionValues := "")
    {
        writeCavebotLog("Action", this.string_log)
        functionName := "setsetting"

        if (!InStr(functionValues.1, "/")) {
            writeCavebotLog("ERROR", (functionName ": ") "Wrong setting path format")
            return false
        }

        settingPath := StrSplit(functionValues.1, "/")
            , mainSetting := settingPath.1
            , lastChildNumber := settingPath.Count() - 1
            , childSettings := _ActionScriptValidation.createChildSettings(settingPath, tab, Waypoint)

        params := {}
            , params.value := functionValues.2
            , params := this.checkParamsVariables(params)

        writeCavebotLog("Action", (functionName ": ") mainSetting " | value: " params.value " | " lastChildNumber)
        try {
            success := this.setChildSettingValue(params.value, lastChildNumber, mainSetting, childSettings.1, childSettings.2, childSettings.3, childSettings.4, childSettings.5)
        } catch e {
            writeCavebotLog("ERROR", (functionName ": ") e.Message)
            return false
        }

        if (success != true) {
            writeCavebotLog("ERROR", (functionName ": ") "Error setting value to setting, status: " success)
            return false
        }

        if (InStr(functionValues.1, "targeting/") && InStr(functionValues.1, "/danger")) {
            TargetingSystem.createCreaturesDangerObj(loadImages := false)
        }

        if (params.value = 1) {
            for key, oldbotModule in OldBotSettings.modulesList
            {
                if (!InStr(mainSetting, oldbotModule)) {
                    continue
                }

                ProcessExistOpenOldBot(%oldbotModule%ExeName, oldbotModule "ExeName", true)
            }
        }

        ; writeCavebotLog("Action", (functionName ": ") "New value: " this.getChildSettingValue(lastChildNumber, mainSetting, childSettings.1, childSettings.2, childSettings.3, childSettings.4, childSettings.5))
        return true
    }

    soulpoints(functionValues := "")
    {
        functionName := "soulpoints"

        return this.readSkillWindow(functionName, "soulPoints")
    }

    stamina(functionValues := "") {
        functionName := "stamina"

        if (MemoryManager.memoryJsonFileObj.stamina) {
            static memory
            if (!memory) {
                memory := new _MemoryAddress(MemoryManager.localPlayerBaseAddress)
                    .setType("Double")
                    .addOffset(MemoryManager.memoryJsonFileObj.stamina)

            }

            result := memory.read()
            result := Format("{:0.2f}", result / 60)
            result := _Arr.first(StrSplit(result, "."))

            writeCavebotLog("Action", (functionName ": ") text " amount: " result " hours")
            return result
        }


        return this.readSkillWindow(functionName, "stamina")
    }

    targetingdisable(functionValues := "") {
        writeCavebotLog("Action", this.string_log)

        targetingSystemObj.targetingDisabled := true
        TargetingSystem.setStatusBarIcon(disabledIconDll, 208)
    }

    targetingenable(functionValues := "") {
        writeCavebotLog("Action", this.string_log)

        targetingSystemObj.targetingDisabled := false
        restoreTargetingIcon()
    }

    telegrammessage(functionValues) {
        writeCavebotLog("Action", this.string_log)
        functionName := "telegrammessage"

        params := {}
            , params.message := functionValues.1

            , params := this.checkParamsVariables(params)

        if (params.message = "") {
            writeCavebotLog("ERROR", (functionName ": ") "Empty message param")
            return false
        }

        writeCavebotLog("Action", (functionName ": ") params.message)

        try TelegramAPI.sendMessageTelegram(params.message, icon := "", waitThreadFinish := false)
        catch e {
            writeCavebotLog("ERROR", s e.Message)
            return false
        }
        Sleep, 500
    }


    telegramscreenshot(functionValues) {
        writeCavebotLog("Action", this.string_log)
        functionName := "telegramscreenshot"

        params := {}
            , params.caption := functionValues.1

            , params := this.checkParamsVariables(params)

        if (params.caption = "") {
            writeCavebotLog("ERROR", (functionName ": ") "Empty message param")
            return false
        }

        writeCavebotLog("Action", (functionName ": ") params.caption)

        outfile := A_Temp "\OldBot\telegramScreenshot.png"
        try {
            FileDelete, % outfile
        } catch e {
        }

        pBitmap := _BitmapEngine.getClientBitmap().get()
        Gdip_SaveBitmapToFile(pBitmap, outfile, 100)
        pBitmap.dispose()

        try TelegramAPI.sendFileTelegram(params.caption, outfile, photo := true, waitThreadFinish := false)
        catch e {
            writeCavebotLog("ERROR", (functionName ": ") e.Message)
            return false
        }
        Sleep, 1000
    }

    travel(functionValues) {
        writeCavebotLog("Action", this.string_log)
        functionName := "travel"

        params := {}
            , params.location := functionValues.1
            , params.npc := functionValues.2

            , params := this.checkParamsVariables(params)


        if (params.location = "") {
            writeCavebotLog("ERROR", (functionName ": ") "Empty location name")
            return false
        }


        if (params.npc != "") {
            this.follownpc({1: params.npc}, false)
        }

        if (!this.npchi())
            return false

        /*
        get minimap piece image to compare
        */
        ; try CavebotWalker.minimapBitmap()
        ; catch e {
        ;     writeCavebotLog("ERROR", (functionName ": ") e.Message)
        ;     return false
        ; }

        v := 46, h := 44
        ; minimapCropSuccess := true
        ; try  {
        ;     pBitmapLittlePiece := Gdip_CropBitmap(CavebotWalker.pBitmapMinimap, l := v + 1, r := v - 1, u := h + 1, d := h - 1, true, A_ThisFunc) ; returns resized bitmap. By Learning one.
        ; } catch {
        ;     writeCavebotLog("ERROR", (functionName ": ") e.Message " | " e.What)
        ;     minimapCropSuccess := false
        ; }

        switch params.location {
            case "Darashia": yesCount := 2
            default: yesCount := 1
        }

        this.say({1: params.location})
        Loop, % yesCount
            this.say({1: "yes"})
        Sleep, 200

        ; if (minimapCropSuccess = false) {
        ;     Gdip_DisposeImage(pBitmapLittlePiece)
        ;     return false
        ; }

        ; try {
        ;     _search := new _Base64ImageSearch()
        ;         .setBitmap(pBitmapLittlePiece)
        ;         .setArea(new _MinimapArea())
        ;         .setVariation(0)
        ;         .search()
        ;         .disposeImageBitmap()

        ; } catch e {
        ;     _BitmapEngine.disposeBitmap(pBitmapLittlePiece)
        ;     writeCavebotLog("ERROR", (functionName ": ") e.Message)
        ;     return false
        ; } finally {
        ;     Gdip_DisposeImage(pBitmapLittlePiece), DeleteObject(pBitmapLittlePiece), pBitmapLittlePiece := ""
        ; }
        ; msgbox, % serialize(vars)

        /*
        if found the minimap piece, that means the travel failed
        */


        /*
        if is not found, it means the char traveled
        now need to set the char position to the boat position
        so the offset will be there and the getCharPos() will finish faster
        */

        if (!CavebotWalker.cityBoatPos[params.location])
            return true

        posx := CavebotWalker.cityBoatPos[params.location].x
            , posy := CavebotWalker.cityBoatPos[params.location].y
            , posz := CavebotWalker.cityBoatPos[params.location].z
        writeCavebotLog("Action", (functionName ": ") "Travel succeed, new location: x:" posx ", y:" posy ", z:" posz)

        return true



    }

    turn(functionValues := "") {
        writeCavebotLog("Action", this.string_log)

        functionName := "turn"

        params := {}
            , params.direction := functionValues.1

            , params := this.checkParamsVariables(params)

        switch params.direction {
            case "S": key := "Down"
            case "N": key := "Up"
            case "W": key := "Left"
            case "E": key := "Right"
        }

        writeCavebotLog("Action", functionName ": " params.direction)
        SendModifier("Ctrl", key)
        Sleep, 200
    }

    turnchaton(functionValues := "") {
        writeCavebotLog("Action", this.string_log)

        functionName := "turnchaton"

        return this.turnChatButtonAction("on")
    }

    turnchatoff(functionValues := "") {
        writeCavebotLog("Action", this.string_log)

        functionName := "turnchatoff"

        return this.turnChatButtonAction("off")
    }

    useitem(functionValues) {
        writeCavebotLog("Action", this.string_log)
        functionName := "useitem"

        params := {}
            , params.itemName := functionValues.1
            , params.repeat := this.getNumberParam(functionValues.2)
            , params.delay := this.getNumberParam(functionValues.3)

            , params := this.checkParamsVariables(params)

            , params.delay := (params.delay < 1) ? 500 : params.delay
            , params.repeat := (params.repeat < 1) ? 1 : params.repeat


        if (!itemsImageObj[params.itemName]) {
            writeCavebotLog("ERROR", (functionName ": ")  "Item """ params.itemName """ doesn't exist in the items list")
            return false
        }

        writeCavebotLog("Action", functionName ": item: " params.itemName " | repeat: " params.repeat " | delay: " params.delay)

        item := new _ItemSearch()
            .setName(params.itemName)

        Loop, % params.repeat {
            if (A_Index > 1) {
                Sleep, 50
            }

            item.search()
            if (item.notFound()) {
                _Logger.log("Item """ params.itemName """ not found on screen", functionName)
                break
            }

            item.clickOnUse()
            Sleep, % params.delay
        }

        return true
    }

    useitemoncorpses(functionValues)
    {
        writeCavebotLog("Action", this.string_log)
        functionName := "useitemoncorpses"

        params := {}
            , params.hotkeyOrItem := functionValues.1

            , params := this.checkParamsVariables(params)

        writeCavebotLog("Action", functionName ": hotkey or item:" params.hotkeyOrItem, "click: " params.click)

        TargetingSystem.useItemOnCorpse("", params.hotkeyOrItem, fromAction := true)
    }

    usesqm(functionValues) {
        ; if (this.string_log != "")
        ; writeCavebotLog("Action", this.string_log)
        functionName := "usesqm"

        params := {}
            , params.direction := functionValues.1

            , params := this.checkParamsVariables(params)

        switch params.direction {
            case "SW": sqmNumber := 1
            case "S": sqmNumber := 2
            case "SE": sqmNumber := 3
            case "W": sqmNumber := 4
            case "C": sqmNumber := 5
            case "E": sqmNumber := 6
            case "NW": sqmNumber := 7
            case "N": sqmNumber := 8
            case "NE": sqmNumber := 9
            default:
                writeCavebotLog("ERROR", functionName ": Invalid direction: " params.direction)
                return false
        }

        writeCavebotLog("Action", functionName ": " params.direction)
        if (!new _UseSqm(new _Coordinate(SQM%sqmNumber%X, SQM%sqmNumber%Y), "action")) {
            writeCavebotLog("ERROR", functionName ": Failed to Use sqm")
            return false
        }
        return true
    }

    variable(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "variable"

        params := {}
            , params.variableName := functionValues.1
            , params.variableValue := functionValues.2
            , params.variableType := functionValues.3

            , params := this.checkParamsVariables(params)

        writeCavebotLog("Action", (functionName ": ") params.variableName " = " params.variableValue ", type: " params.variableType)

        switch params.variableValue {
                /*
                decrement
                */
            case "--":
                try {
                    if (this.scriptVariables[params.variableName] = "")
                        this.scriptVariables[params.variableName] := 0
                    this.scriptVariables[params.variableName]--
                } catch {
                    writeCavebotLog("ERROR", functionName ": Failed to create variable: " e.Message " | " e.What)
                    return false
                }

                /*
                increment
                */
            case "++":
                try {
                    if (this.scriptVariables[params.variableName] = "")
                        this.scriptVariables[params.variableName] := 0
                    this.scriptVariables[params.variableName]++
                } catch {
                    writeCavebotLog("ERROR", functionName ": Failed to create variable: " e.Message " | " e.What)
                    return false
                }

            default:
                switch params.variableType {
                    case "negative":
                        try {
                            this.scriptVariables[params.variableName] := "-" params.variableValue
                        } catch {
                            writeCavebotLog("ERROR", functionName ": Failed to create variable: " e.Message " | " e.What)
                            return false
                        }
                    default:
                        try {
                            this.scriptVariables[params.variableName] := params.variableValue
                        } catch {
                            writeCavebotLog("ERROR", functionName ": Failed to create variable: " e.Message " | " e.What)
                            return false
                        }
                }
        }

        if (params.variableName = "NO_LOGS") {
            global NO_LOGS := !params.variableValue
        }

        return true
    }

    variableshowall(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "variableshowall"

        writeCavebotLog("Action", (functionName ": ") serialize(this.scriptVariables))

        return true
    }

    wait(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "wait"

        params := {}
            , params.delay := this.getNumberParam(functionValues.1)
            , params.measure := functionValues.2

            , params := this.checkParamsVariables(params)

            , params.measure := empty(params.measure) ? "milisecond" : params.measure

        writeCavebotLog("Action", (functionName ": ") params.delay " " params.measure "(s)")

        this.second := params.delay * 1000
        this.minute := second * 60
        this.hour := minute * 60

        switch params.measure {
            case "second":
                Sleep, % this.second
            case "minute":
                Sleep, % this.minute
            case "hour":
                Sleep, % this.hour
            default:
                Sleep, % params.delay
        }
    }

    waypointdistance(functionValues := "") {
        writeCavebotLog("Action", this.string_log)
        functionName := "waypointdistance"

        params := {}
            , params.identifier := functionValues.1
            , params.tab := functionValues.2

            , params := this.checkParamsVariables(params)

            , params.tab := params.tab ? params.tab : tab

        writeCavebotLog("Action", (functionName ": ") "waypoint identifer: " params.identifier ", tab: " params.tab)

        if (empty(Waypoint)) {
            writeCavebotLog("ERROR", (functionName ": ") "Empty current caypoint, Cavebot is probably not running")
            return -1
        }

        identifier := params.identifier

        if identifier is number
        {
            if (waypointsObj[params.tab].HasKey(identifier)) {
                return -1
            }
        }

        switch (identifier) {
            case "NextWaypoint":
                if (!waypointsObj[tab].HasKey(Waypoint + 1)) {
                    return -1
                }

                coords := waypointsObj[tab][Waypoint + 1].coordinates

            default:
                labelSearch := this.findWaypointWithLabel(identifier)
                if (labelSearch.labelFound = false) {
                    return -1
                }

                coords := waypointsObj[labelSearch.tabFound][labelSearch.waypointFound].coordinates
        }

        getCharPos()
        distances := _CavebotWalker.distanceCoordFromOtherCoord(posx, posy, coords.x, coords.y)
        distance := Sqrt((distances.y - distances.x)**2)

        writeCavebotLog("Action", (functionName ": ") "distance: " distance)

        return distance
    }

    /**
    * @param int x1
    * @param int y1
    * @param int x2
    * @param int y2
    * @param bool holdshift
    * @param int delay
    * @param ?bool debug
    */
    dragitem(x1, y1, x2, y2, holdshift, delay, debug := false)
    {
        if (debug) {
            msgbox, % A_ThisFunc "`n`n" x1 "," y1 "," x2 "," y2 "," holdshift "," delay "," debug
            mousemove, WindowX + x1, WindowY + y1
            msgbox, a
            mousemove, WindowX + x2, WindowY + y2
            msgbox, a
        }

        if (holdshift = true)
            HoldShift()
        Sleep, 25 ; little delay for the client to recognize the input before other key stroke
        MouseDrag(x1, y1, x2, y2)
        if (holdshift = true) {
            sleep, 100
            ReleaseShift()
        }
        Sleep, % delay
    }

    ; check if it is a variable, if not, return "forced" number
    getNumberParam(value) {
        if (InStr(value, "$"))
            return value

        ; msgbox, % value " = " %value%

        ; if is a variable of the bot, such as "CHAR_POS_X"
        try
            var_value := %value%
        catch
            var_value := ""
        if (var_value != "")
            return var_value

        /*
        if there is a signal in the value, return without converting to number
        */
        if (InStr(value, "-") OR InStr(value, "+") ) {
            return value
        }
        return value += 0
    }

    /*
    check if the param is a variable created in the action script
    ex1:
    $hotkeyMachete = getuseroption(hotkeymachete)
    ex2:
    $lootingEnabled = getsetting(looting/settings/lootingEnabled)


    */
    checkParamsVariables(ByRef params) {
        for paramName, paramValue in params
        {
            if (!InStr(paramValue, "$"))
                continue

            firstChar := SubStr(paramValue, 1, 1)
            switch firstChar {
                case "$":
                    switch this.actionScriptType {
                        case "hotkey", case "persistent":
                            ; m(paramValue, actionScriptsVariablesObj[this.actionScriptType][Waypoint][paramValue], actionScriptsVariablesObj[this.actionScriptType][Waypoint])
                            if (!actionScriptsVariablesObj[this.actionScriptType][Waypoint][paramValue] && actionScriptsVariablesObj[this.actionScriptType][Waypoint][paramValue] != false) {
                                writeCavebotLog("ERROR", txt("Variável """ paramValue """ não possui valor(ou não existe).", "Variable """ paramValue """ has no value(or doesn't exist)."))
                                return
                            }

                        default:
                            if (!actionScriptsVariablesObj[tab][Waypoint][paramValue] && actionScriptsVariablesObj[tab][Waypoint][paramValue] != false) {
                                writeCavebotLog("ERROR", txt("Variável """ paramValue """ não possui valor(ou não existe).", "Variable """ paramValue """ has no value(or doesn't exist)."))
                                return
                            }
                    }

                    params[paramName] := _ActionScriptValidation.getValueFromActionScriptVariable(paramValue, tab, Waypoint)

                    /*
                    string with variable, example: s
                    say(sell $cheeseCount cheese)
                    */
                default:
                    symbolPos := InStr(paramValue, "$")

                    stringBeforeVariable := SubStr(paramValue, 1, symbolPos - 1)

                    StringTrimLeft, variableString, paramValue, symbolPos - 1
                    firstSpaceAfterSymbol := InStr(variableString, " ")

                    if (firstSpaceAfterSymbol > 0)
                        StringTrimLeft, stringAfterVariable, variableString, firstSpaceAfterSymbol - 1
                    else
                        stringAfterVariable := ""

                    if (firstSpaceAfterSymbol > 0)
                        variableName := SubStr(variableString, 1, firstSpaceAfterSymbol - 1)
                    else
                        variableName := variableString

                    variableValue := _ActionScriptValidation.getValueFromActionScriptVariable(variableName, tab, Waypoint)
                    params[paramName] := stringBeforeVariable "" variableValue "" stringAfterVariable
            }
        }
        return params
    }


    calcWindowHeight(gameWindowY1, gameWindowY2) {
        return abs(gameWindowY1 - gameWindowY2)
    }

    /*
    find the border of the window, and return its position, used to calculate window height and resize it

    gameWindowX will be the left border of the window (0 pix offset)
    gameWindowY will be the upper border of the window (0 pix offset)
    by pix offset I mean like the main backpack images, where they are cropped with no border and in a default pattern
    */
    findWindowBorder(gameWindowX, gameWindowY) {
        vars := ""
        try {
            vars := ImageClick({"x1": gameWindowX, "y1": gameWindowY, "x2": gameWindowX + 25, "y2": WindowHeight
                    , "image": "window_border"
                    , "directory": ImagesConfig.clientFolder
                    , "variation": 30
                    , "transColor": 0
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }
        if (!vars.x) {
            writeCavebotLog("ERROR", "Window border not found")
            return false
        }
        vars.y += 14 ; height of window_border.png
        return vars
    }

    resizeGameWindow(height, gameWindowX, gameWindowY, debug := false)
    {
        gameWindowBorder := this.findWindowBorder(gameWindowX, gameWindowY)
        ; mousemove, WindowX + gameWindowBorder.x, WindowY + gameWindowBorder.y
        ; msgbox, % serialize(gameWindowBorder)
        if (gameWindowBorder = false)
            return false

        gameWindowHeight := this.calcWindowHeight(gameWindowY, gameWindowBorder.y)
        ; msgbox, % gameWindowHeight " = " gameWindowHeight

        sizeDiff := height - gameWindowHeight
        ; msgbox, %  height "`n" sizeDiff "`n" gameWindowHeight
        if (sizeDiff = 0)
            return

        tradeRealHeight := this.tradeWindow.height + 30
        ; ; mouseMove, WindowX + gameWindowBorder.x + 5, WindowY + gameWindowBorder.y
        ; msgbox, a
        if (sizeDiff < 0) {
            ; mouseMove, WindowX + gameWindowBorder.x + 5, WindowY + gameWindowBorder.y - abs(sizeDiff)
            ; msgbox, b
            MouseDrag(gameWindowBorder.x + 5, gameWindowBorder.y, gameWindowBorder.x + 5, gameWindowBorder.y - abs(sizeDiff), "", debug)
        } else {
            ; mouseMove, WindowX + gameWindowBorder.x + 5, WindowY + gameWindowBorder.y + sizeDiff
            ; msgbox, b
            MouseDrag(gameWindowBorder.x + 5, gameWindowBorder.y, gameWindowBorder.x + 5, gameWindowBorder.y + sizeDiff, "", debug)
        }

        Sleep, 50
    }

    setTradeWindowDefaultHeights() {
        this.tradeWindowDefaultHeight := 104
        this.tradeWindowTwoItemsHeight := 174

        if (OldBotSettings.settingsJsonObj.settings.cavebot.tradeWindowSummerUpdate1290 = true) && (cavebotSystemObj.tradeWindowWithSearchBox = true) {
            this.tradeWindowDefaultHeight := 126
            this.tradeWindowTwoItemsHeight := 196
        }
    }

    resizeTradeWindow(size, getWindowPos := false) {

        this.setTradeWindowDefaultHeights()

        this.tradeWindowDefaultHeight
        height := this.tradeWindowDefaultHeight + (35 * size)

        if (getWindowPos = true)
            this.getTradeWindowPosition()

        this.tradeWindow.height := this.getTradeWindowHeight()

        sizeDiff := height - this.tradeWindow.height
        ; msgbox, % "size = " size "`n" sizeDiff "`n" this.tradeWindow.height "`n" height
        if (sizeDiff = 0)
            return

        mod := 25
        tradeRealHeight := this.tradeWindow.height + mod
        ; mouseMove, WindowX + this.tradeWindow.button_x, WindowY + tradeRealHeight
        if (sizeDiff < 0) {
            MouseDrag(this.tradeWindow.button_x, this.tradeWindow.button_y + mod, this.tradeWindow.button_x, this.tradeWindow.y1 + tradeRealHeight - abs(sizeDiff), "", false)
        } else {
            MouseDrag(this.tradeWindow.button_x, this.tradeWindow.button_y + mod, this.tradeWindow.button_x, this.tradeWindow.y1 + tradeRealHeight + sizeDiff)
        }
        Sleep, 50
        ; msgbox, done
    }

    getTradeWindowHeight(getWindowPos := false) {
        if (getWindowPos = true)
            this.getTradeWindowPosition()
        return abs(this.tradeWindow.y1 - this.tradeWindow.button_y)

    }

    getTradeWindowPosition(throwError := true) {
        this.tradeWindow := {}
        vars := ""
        try {
            vars := ImageClick({"x1": this.tradeWindow.x1, "y1": this.tradeWindow.y1, "x2": this.tradeWindow.x2, "y2": this.tradeWindow.y2
                    , "image": "trade_window"
                    , "directory": ImagesConfig.npcTradeFolder
                    , "variation": 65
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }
        if (!vars.x) {
            if (throwError = true)
                writeCavebotLog("ERROR", "NPC trade window not found")
            return false
        }
        this.tradeWindow.x1 := vars.x - 17
            , this.tradeWindow.y1 := vars.y
            , this.tradeWindow.x2 := this.tradeWindow.x1 + 175

        _search := new _SearchTradeConfirmationButton()

        if (_search.notFound()) {
            writeCavebotLog("ERROR", "NPC ""ok"" button not found")
            return false
        }

        this.tradeWindow.y2 := _search.getY()
            , this.tradeWindow.button_x := _search.getX()
            , this.tradeWindow.button_y := _search.getY()

        if (isRubinot()) {
            this.tradeWindow.button_y += 1
        }

        ; c1 := new _Coordinate(this.tradeWindow.x1, this.tradeWindow.y1)
        ; c2 := new _Coordinate(this.tradeWindow.x2, this.tradeWindow.y2)
        ; c := new _Coordinates(c1, c2).debug()

        return true
    }

    /**
    * @return _ImageSearch
    */
    searchOkButton() {
        if (this.tradeWindow.x1 = "") {
            writeCavebotLog("ERROR", (functionName ": ") "Empty trade window position")
            return
        }

        try {
            windowArea := new _WindowArea()
            c1 := new _Coordinate(this.tradeWindow.x1, this.tradeWindow.y1 )
            c2 := new _Coordinate(this.tradeWindow.x2, this.tradeWindow.y2 + 50)

            return new _SearchTradeConfirmationButton(new _Coordinates(c1, c2))
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return
        }
    }

    checkTradeWindow(resizeWindow := true, resizeSizeItems := 2, sleep := true) {
        this.getTradeWindowPosition()
        if (this.tradeWindow.x1 = "") {
            writeCavebotLog("ERROR", (functionName ": ") "Empty trade window position")
            return false
        }
        if (resizeWindow = true) {
            this.resizeTradeWindow(resizeSizeItems)
            Sleep, 100
        }
        if (sleep = true)
            Sleep, 100
        ; }
        if (resizeWindow = true) && (resizeSizeItems = 2) {
            /*
            check if trade window is with the correct height to show 2 items,
            if is not, resize function failed, possibly because there is not enough space in the screen
            where the trade window is
            */
            height := this.getTradeWindowHeight(true)
            if (height < this.tradeWindowTwoItemsHeight) ; size of trade window showing 2 items
                writeCavebotLog("WARNING", txt("Trade Window não tem espaço para mostrar 2 itens (altura: " height "/" this.tradeWindowTwoItemsHeight "px), mude a posição da janela ou libere mais espaço", "Trade Window has no space to show 2 items (height: " height "/" this.tradeWindowTwoItemsHeight "px), change the position of the window or free up more space"), true)
            if (height > this.tradeWindowTwoItemsHeight) ; size of trade window showing 2 items
                writeCavebotLog("WARNING", txt("Falha ao reajustar o Trade Window para mostrar 2 itens (height: " height "/" this.tradeWindowTwoItemsHeight "px)", "Failed to resize Trade Window to show 2 items (height: " height "/" this.tradeWindowTwoItemsHeight "px)"), true)
        }
        return true
    }

    /**
    * @return bool
    */
    okButton(delay := 250) {
        _search := this.searchOkButton()
        if (_search.notFound()) {
            writeCavebotLog("ERROR", "OK button not found")
            return false
        }

        _search
            .setClickOffsetX(15)
            .setClickOffsetY(10)
            .click()

        Sleep, % delay

        return true
    }

    amountButton(button, repeat, delay := 50) {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFolder(ImagesConfig.npcTradeFolder)
                .setVariation(10)
                .setClickOffsets(6)
        }

        try {
            _search := searchCache
                .setFile(button "_button")
                .setCoordinates(_Coordinates.FROM_ARRAY(this.tradeWindow))
                .search()
        } catch e {
            _Logger.exception(e, A_ThisFunc)
            return false
        }

        ; msgbox, % A_ThisFunc "`n" serialize(vars)
        if (_search.notFound()) {
            writeCavebotLog("ERROR", button " button not found on screen")
            return false
        }

        Loop, % repeat {
            _search.click()
            Sleep, % delay
        }

        return true
    }

    getChildSettingValue(childNumber, mainSetting, childSetting1 := "", childSetting2 := "", childSetting3 := "", childSetting4 := "", childSetting5 := "") {
        ; msgbox, % A_ThisFunc "`n childNumber = " childNumber "`n" mainSetting " / " childSetting1
        switch childNumber {
            case 1:
                if (%mainSetting%Obj[childSetting1] != "")
                    return %mainSetting%Obj[childSetting1]
            case 2:
                if (%mainSetting%Obj[childSetting1].HasKey(childSetting2))
                    return %mainSetting%Obj[childSetting1][childSetting2]
            case 3:
                if (%mainSetting%Obj[childSetting1][childSetting2].HasKey(childSetting3))
                    return %mainSetting%Obj[childSetting1][childSetting2][childSetting3]
            case 4:
                if (%mainSetting%Obj[childSetting1][childSetting2][childSetting3].HasKey(childSetting4))
                    return %mainSetting%Obj[childSetting1][childSetting2][childSetting3][childSetting4]
            case 5:
                if (%mainSetting%Obj[childSetting1][childSetting2][childSetting3][childSetting4].HasKey(childSetting5))
                    return %mainSetting%Obj[childSetting1][childSetting2][childSetting3][childSetting4][childSetting5]
        }

        /*
        Access other objects, without "Obj", such as ClientAreas.
        */
        switch childNumber {
            case 1:
                if (%mainSetting%[childSetting1] != "")
                    return %mainSetting%[childSetting1]
            case 2:
                if (%mainSetting%[childSetting1].HasKey(childSetting2))
                    return %mainSetting%[childSetting1][childSetting2]
            case 3:
                if (%mainSetting%[childSetting1][childSetting2].HasKey(childSetting3))
                    return %mainSetting%[childSetting1][childSetting2][childSetting3]
            case 4:
                if (%mainSetting%[childSetting1][childSetting2][childSetting3].HasKey(childSetting4))
                    return %mainSetting%[childSetting1][childSetting2][childSetting3][childSetting4]
            case 5:
                if (%mainSetting%[childSetting1][childSetting2][childSetting3][childSetting4].HasKey(childSetting5))
                    return %mainSetting%[childSetting1][childSetting2][childSetting3][childSetting4][childSetting5]
        }
        return -1
    }

    turnChatButtonAction(state := "on") {
        Try {
            _ := new _ToggleChat(state)
        } catch e {
            writeCavebotLog("ERROR", e.Message)
            return false
        }

        return true
    }

    readActionBarOCR(x1, y1, x2, y2, type := "", columnsCount := 4, debugNumbers := false, debugColumns := false)
    {
        ; debugNumbers := true, debugColumns := true

        this.ocr := {}
            , this.ocr.result := ""
            , this.ocr.columnNumber := 1 ; start column to search
            , this.ocr.columnsCount := columnsCount
            , this.ocr.variation := 70
            , this.ocr.numberImageWidth := 10

        switch type {
            case "actionbar":
                this.ocr.variation := 65 ;. changed from 65 on 16/05/21
                this.ocr.numberImageWidth := isRubinot() ? 9 : 8 ; width of the number image
                this.ocr.location := "actionbar"

            case "capacity", case "stamina", case "level", case "soulpoints":
                /*
                variation index, seems to need to search for X number variations
                20: 5 numbers]
                35: 4 numbers (3 works for most numbers but not for 28XX)
                35: 5 numbers - is failing with "50" and "383"
                35: 6 numbers - current
                */
                this.ocr.variation := 40
                    , this.ocr.location := "skillwindow"

            case "item":
                this.ocr.location := "stash"

            case "stash":
                this.ocr.location := "stash"
                thousands := this.searchThousandNumbers(x1, y1, y2)
                ; if (thousands) {
                ;     return thousands
                ; }

            default:
                writeCavebotLog("ERROR", "Invalid check type: " type)
                return -1
        }

        this.createNumbersBitmaps()
        if (this.numbersBitmap[this.ocr.location].Count() < 1) {
            writeCavebotLog("ERROR", "Numbers bmp not intialized, location: " this.ocr.location ".")
            return -1
            ; Throw Exception()
        }

        /*
        image of the numbers are from right to left, being the first number column(right) 1 and the last (4th column) 4
        as imagens devem todas ter 1 px de borda preta em volta do pixel do numero principalmente na parte esquerda, para não deixar o x1 1px menor quando localizado
        */
        Loop, % this.ocr.columnsCount {
            shown := false, this.ocr.numberSearchIndex := 1

            Loop, 10 { ; search from number 1 to 0
                this.ocr.numberToSearch := this.ocr.numberSearchIndex
                switch this.ocr.numberSearchIndex {
                    case 10: this.ocr.numberToSearch := 1
                    case 1: this.ocr.numberToSearch := 0

                        /*
                        when searching numbers in the stash, 3 is exactly the same shape as 8, so must search for 8 first

                        the same happens in OLDERS whe searching in skill window
                        */
                    case 3:
                        switch (isTibia13()) {
                            case false: this.ocr.numberToSearch := 8
                            case true: this.ocr.numberToSearch := (this.ocr.location = "stash" OR this.ocr.location = "actionbar") ? 8 : this.ocr.numberToSearch
                        }
                    case 8:
                        switch (isTibia13()) {
                            case false: this.ocr.numberToSearch := 3
                            case true: this.ocr.numberToSearch := (this.ocr.location = "stash" OR this.ocr.location = "actionbar") ? 3 : this.ocr.numberToSearch
                        }

                }

                if (shown = false && debugColumns = true) {
                    shown := true
                    coordinates := new _Coordinates(new _Coordinate(x1, y1), new _Coordinate(x2, y2))
                    coordinates.debug("this.ocr.columnNumber = " this.ocr.columnNumber, false)
                }

                for key, filePath in this.numbersBitmap[this.ocr.location][this.ocr.numberToSearch]
                {
                    indexFound := A_Index
                    /*
                    test - limiting the this.ocr.variation of each number when searching on actionbar after increased variation to 20
                    */
                    if (type = "actionbar" && A_Index > 6) {
                        break
                    }

                    try {
                        coordinates := new _Coordinates(new _Coordinate(x1, y1), new _Coordinate(x2, y2))

                        _search := new _ImageSearch()
                            .setPath(filePath)
                            .setVariation(this.ocr.variation)
                            .setTranscolor("0")
                            .setCoordinates(coordinates)
                            .search()
                    } catch e {
                        writeCavebotLog("Cavebot", e.Message " | " e.What " | " A_ThisFunc)
                        return -1
                    }

                    if (_search.found()) {
                        break
                    }
                }

                if (debugNumbers = true) {
                    msgbox, % ""
                        . "`n numberToSearch = " this.ocr.numberToSearch
                        . "`n result = " this.ocr.result
                        . "`n x = " _search.getX()
                        . "`n columnNumber = " this.ocr.columnNumber
                        . "`n numberImageWidth = " this.ocr.numberImageWidth
                        . "`n x1 = " x1 ", y1 = " y1
                        . "`n x2 = " x2 ", y2 = " y2
                        . "`n indexFound = " indexFound
                        . "`n variation = " this.ocr.variation
                        . "`n shown = " shown
                }

                if (_search.notFound()) {
                    this.ocr.numberSearchIndex++
                    continue
                }

                x1 := (isTibia13() = true) ? this.adjustX1NumberOcr(_search.getResult()) : this.adjustX1NumberOcrOTClient(_search.getResult())
                x2 := x1 + this.ocr.numberImageWidth

                this.ocr.result .= this.ocr.numberToSearch

                if (debugNumbers || debugColumns)
                    msgbox, 64,, % "number " this.ocr.numberToSearch " found (" this.ocr.numberToSearch "_" fileNumber "/" this.ocr.numberSearchIndex "), this.ocr.columnNumber = " this.ocr.columnNumber ", this.ocr.result = " this.ocr.result
                break
            }
            if (this.ocr.numberSearchIndex > 10) {
                shown := false
                if (this.ocr.location = "skillwindow") {
                    x2 += this.ocr.numberImageWidth - 1 ; -1 ao incrementar a area do X2 pra procurar na proxima casa decimal, se não deu pau no numero 400, onde não localiou o primeiro 0 (40)
                } else {
                    x2 += this.ocr.numberImageWidth - 2
                }

                if (debugNumbers || debugColumns)
                    msgbox,48,, % "All numbers not found(" this.ocr.numberSearchIndex "), this.ocr.columnNumber = " this.ocr.columnNumber ", this.ocr.result = " this.ocr.result
            }

            this.ocr.columnNumber++
        }

        if (thousands) {
            this.ocr.result *= 1000
        }

        return this.ocr.result
    }

    /**
    * @return ?int
    */
    searchThousandNumbers(x1, y1, y2)
    {
        try {
            coordinates := new _Coordinates(new _Coordinate(x1, y1), new _Coordinate(x1 + 36, y2))

            _search := new _ImageSearch()
                .setFile("k")
                .setFolder(ImagesConfig.cavebotNumbersFolder "\St")
                .setVariation(this.ocr.variation)
                .setTranscolor("0")
                .setCoordinates(coordinates)
                .search()
        } catch e {
            writeCavebotLog("Cavebot", e.Message " | " e.What " | " A_ThisFunc)
            return -1
        }

        if (_search.found()) {
            return 10000
        }
    }

    adjustX1NumberOcr(vars) {
        /*
        se for o numero 1, precisa diminuir o x1 em - 4 e não -2 pois o numero é muito "fino"
        e alguns numeros(tipo o 6) meio ficam muito colados no 1, visto no kingdomswap

        on kindgdom swap wasn't finding the zero on cap 108, so needed to change to -5 instead of default -4 it was

        on olders online numbers are more together so only worked with
        */

        x1 := vars.x + ((this.ocr.numberToSearch != 1) ? this.ocr.numberImageWidth - 3 : this.ocr.numberImageWidth - 4) ;

        /*
        increment space because of the comma (,)
        */
        switch this.ocr.columnsCount {
            case 5:
                if (this.ocr.columnNumber = 2) && (this.ocr.location = "skillwindow")
                    x1 += 3
            case 4:
                if (this.ocr.columnNumber = 1) && (this.ocr.location = "skillwindow")
                    x1 += 3
                if (this.ocr.columnNumber = 1) && (this.ocr.location = "stash" && !isRubinot())
                    x1 += 3
        }
        return x1
    }

    adjustX1NumberOcrOTClient(vars) {
        /*
        se for o numero 1, precisa diminuir o x1 em - 4 e não -2 pois o numero é muito "fino"
        e alguns numeros(tipo o 6) meio ficam muito colados no 1, visto no kingdomswap

        on kindgdom swap wasn't finding the zero on cap 108, so needed to change to -5 instead of default -4 it was

        on olders online numbers are more together so only worked with
        */

        x1ModNumber1 := 4
        x1ModOtherNumbers := 3
        x1IncreaseComma := 3
        switch TibiaClient.getClientIdentifier() {
            case "kingdomswap": x1ModNumber1 := 5
            case "olders":
                x1ModNumber1 := 6
                x1ModOtherNumbers := 5
        }

        x1 := vars.x + ((this.ocr.numberToSearch != 1) ? this.ocr.numberImageWidth - x1ModOtherNumbers : this.ocr.numberImageWidth - x1ModNumber1) ;

        /*
        increment space because of the comma (,)

        in olders there is a dot after the 4 column
        */
        switch TibiaClient.getClientIdentifier() {
            case "olders":

            default:
                switch this.ocr.columnsCount {
                    case 5:
                        if (this.ocr.columnNumber = 2) && (this.ocr.location = "skillwindow")
                            x1 += 3
                    case 4:
                        if (this.ocr.columnNumber = 1) && (this.ocr.location = "skillwindow")
                            x1 += 3
                }

        }
        return x1
    }



    setChildSettingValue(value, childNumber, mainSetting, childSetting1 := "", childSetting2 := "", childSetting3 := "", childSetting4 := "", childSetting5 := "") {
        ; msgbox, % value "/ " childNumber
        /*
        write in the JSON the new object if is not one of the Cavebot objects(that will have new new variable value read from memory)
        */

        writeJson := false
        if (InArray(this.settingsWriteJson, mainSetting) != 0)
            writeJson := true
        ; msgbox, % writeJson
        switch mainSetting {
            case "reconnect":
                if (childSetting1 = "autoReconnect")
                    IniWrite, % value, %DefaultProfile%, settings, autoReconnect
        }
        ; msgbox, % A_ThisFunc " " serialize(%mainSetting%Obj)
        switch childNumber {
            case 1:
                %mainSetting%Obj[childSetting1] := value
                ; msgbox, % %mainSetting%Obj[childSetting1]
                if (writeJson = true)
                    return this.writeJsonObject(mainSetting, mainSetting "/" childSetting1, value)
                return true
            case 2:
                %mainSetting%Obj[childSetting1][childSetting2] := value
                if (writeJson = true)
                    return this.writeJsonObject(mainSetting, mainSetting "/" childSetting1 "/" childSetting2, value)
                return true
            case 3:
                %mainSetting%Obj[childSetting1][childSetting2][childSetting3] := value
                if (writeJson = true)
                    return this.writeJsonObject(mainSetting, mainSetting "/" childSetting1 "/" childSetting2 "/" childSetting3, value)
                return true
            case 4:
                %mainSetting%Obj[childSetting1][childSetting2][childSetting3][childSetting4] := value
                if (writeJson = true)
                    return this.writeJsonObject(mainSetting, mainSetting "/" childSetting1 "/" childSetting2 "/" childSetting3 "/" childSetting4, value)
                return true
            case 5:
                %mainSetting%Obj[childSetting1][childSetting2][childSetting3][childSetting4][childSetting5] := value
                if (writeJson = true)
                    return this.writeJsonObject(mainSetting, mainSetting "/" childSetting1 "/" childSetting2 "/" childSetting3 "/" childSetting4 "/" childSetting5, value)
                return true
        }
        return false
    }

    writeJsonObject(setting, settingPath, value) {
        scriptFile[setting] := %setting%Obj
        ; CavebotScript.saveSettings(A_ThisFunc)
        Sleep, 1000
        /*
        return false from Send_WM_COPYDATA if OldBot.exe returns false in the message
        */
        ; msgbox, % A_ThisFunc "`n " setting " = " settingPath " = " value
        return Send_WM_COPYDATA("setsetting" "|" setting "|" settingPath "|" value, SendMessageTargetWindowTitle, 2000)
    }



    createNumbersBitmaps() {
        if (IsObject(this.numbersBitmap)) {
            return
        }

        this.numbersBitmap := {}

        indexNumber := 0

        numbersCount := 11 ; will load 11 different images for each number

        this.numbersBitmap["actionbar"] := {}
        folder := ImagesConfig.cavebotNumbersFolder "\Ac"
        Loop, % numbersCount {
            this.numbersBitmap["actionbar"][indexNumber] := {}
            Loop, % folder "\" indexNumber "_*.png" {
                this.numbersBitmap["actionbar"][indexNumber].Push(A_LoopFileFullPath)
                ; msgbox, % indexNumber "`n" A_LoopFileFullPath "`nbitmap: " this.numbersBitmap["actionbar"][indexNumber][A_Index]  "`nbitmap2: " Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
                ; Gdip_SetBitmapToClipboard(this.numbersBitmap["actionbar"][indexNumber][A_Index])
            }
            indexNumber++
        }

        indexNumber := 0, this.numbersBitmap["skillwindow"] := {}
        switch isTibia13() {
            case true:
                Loop, % numbersCount {
                    this.numbersBitmap["skillwindow"][indexNumber] := {}
                    Loop, % ImagesConfig.cavebotNumbersSkillWindowFolder "\" indexNumber "*.png" {
                        this.numbersBitmap["skillwindow"][indexNumber].Push(A_LoopFileFullPath)
                        ; msgbox, % indexNumber "`n" A_LoopFileFullPath "`nbitmap: " this.numbersBitmap["skillwindow"][indexNumber][A_Index]  "`nbitmap2: " Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
                    }
                    indexNumber++
                }
            case false:
                Loop, % numbersCount {
                    this.numbersBitmap["skillwindow"][indexNumber] := {}
                    folder := ImagesConfig.clientNumbersFolder "\" CavebotSystem.cavebotJsonObj.settings.numbersFolderNameClient "\sk"
                    ; msgbox, % folder
                    Loop, %  folder "\" indexNumber "*.png"
                        this.numbersBitmap["skillwindow"][indexNumber].Push(A_LoopFileFullPath)
                    indexNumber++
                }
        }


        indexNumber := 0, this.numbersBitmap["stash"] := {}
        Loop, % numbersCount {
            this.numbersBitmap["stash"][indexNumber] := {}
            ; msgbox, % ImagesConfig.cavebotNumbersFolder "\St\" indexNumber "*.png"
            Loop, % ImagesConfig.cavebotNumbersFolder "\St\" indexNumber "*.png"
                this.numbersBitmap["stash"][indexNumber].Push(A_LoopFileFullPath)
            indexNumber++
        }
    }

} ; Class _ActionScript
