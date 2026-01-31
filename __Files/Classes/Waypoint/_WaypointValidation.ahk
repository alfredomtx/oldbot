

Class _WaypointValidation {


    validateWaypoint(waypointAtributesObj, tabName, waypointNumber := "") {
        ; m(serialize(waypointAtributesObj))
        validation := this.validateWaypointAtribute("range", {"rangeX": waypointAtributesObj.rangeX, "rangeY": waypointAtributesObj.rangeY}, tabName, waypointNumber)
        if (validation != "")
            throw Exception(validation)

        switch waypointAtributesObj.type {
            case "Walk", case "Stand", case "Node", case "Ladder", case "Rope":
                validation := this.validateWalkableSQM()
                if (validation != "")
                    throw Exception(validation, "NotWalkable")
        }

        if (waypointNumber = "") {
            waypointNumber := WaypointHandler.getLastWaypoint(tabName) + 1
        }
        if (waypointNumber > 1) {
            try this.isWaypointTooFarFromPrevious(tabName, waypointNumber, waypointAtributesObj.coordinates.x, waypointAtributesObj.coordinates.y, waypointAtributesObj.coordinates.z, waypointAtributesObj.type, true, true)
            catch e
                throw e
        }

        ; msgbox, % waypointsObj[tab].Count()
        if (waypointsObj[tabName].Count() > 0) {
            coordinates := this.getAtribute("coordinates", waypointsObj[tabName].Count())
            CavebotWalker.isWaypointTooFar(coordinates.x, coordinates.y, coordinates.z)

        }

        if (CavebotScript.isMarker()) {
            if (waypointAtributesObj.marker < 1 OR waypointAtributesObj.marker > 20)
                throw Exception("Invalid marker: " waypointAtributesObj.marker)
        }

    }

    isWaypointTooFarFromPrevious(tabName, waypointNumber, waypointX, waypointY, waypointZ, type := "", throwException := false, ignoreAction := false) {


        /**
        if the previous waypoint is action or current is action return false (ignore)
        */
        if (waypointsObj[tabName][waypointNumber].type = "Action" || waypointsObj[tabName][waypointNumber - 1].type = "Action")
            return false

        limitX := minimapWidth / 2 - 3, limitY := minimapHeight / 2 - 3
        distance := CavebotWalker.distanceCoordFromOtherCoord(waypointsObj[tabName][waypointNumber - 1].coordinates.x, waypointsObj[tabName][waypointNumber - 1].coordinates.y, waypointX, waypointY)

        if (distance.x > limitX OR distance.y > limitY) && (waypointsObj[tabName][waypointNumber - 1].coordinates.z = waypointZ) {
            if (throwException) {
                msg := (LANGUAGE = "PT-BR" ? "Coordenadas desse Waypoint estão muito longe do último waypoint." : "Coordinates of this Waypoint are too far from last waypoint.")
                throw Exception(msg "`n`nCoordinates x: " waypointX ", y: " waypointY "`nLast waypoint(" waypointNumber - 1 ") x: " waypointsObj[tabName][waypointNumber - 1].coordinates.x ", y: " waypointsObj[tabName][waypointNumber - 1].coordinates.y "`n`nDistance x: " distance.x " (limit: "  limitX ")`nDistance y: " distance.y " (limit " limitY ")", "TooFar")
            }

            return true
        }

        return false
    }

    validateWaypointAtribute(atributeName, atributeValue, tabName, waypointNumber := "") {
        switch atributeName {
            case "Type":  return this.validateType(atributeValue)
            case "Label": return this.validateLabel(atributeValue, waypointNumber, tabName)
            case "Coordinates": return this.validateCoordinates(atributeValue)
            case "Range": return this.validateRange(atributeValue.rangeX, atributeValue.rangeY)
            case "Action":
                if (waypointNumber = "")
                    return "Empty waypoint number on Action Waypoint."
                return this.validateAction(atributeValue, tabName, waypointNumber)
        }
    }

    validateWalkableSQM() {
        if (scriptSettingsObj.charCoordsFromMemory = true)
                && (isNotTibia13())
            return

        try isWalkable := CavebotWalker.isCoordWalkable(posx, posy, posz, true)
        catch {
            throw Exception("Error checking if coordinate is walkable, x: " posx ", y: " posy ", z: " posz)
        }

        if (isWalkable = false) {
            ; gosub, minimapViewer
            ; clipboard := "https://tibiamaps.io/map#" posx "," posy "," posz ":2"
            string1 := (LANGUAGE = "PT-BR" ? "Coordenadas do personagem detectada não é caminhável(walkable)" : "Detected character coordinates is not walkable")

            switch scriptSettingsObj.charCoordsFromMemory {
                case true:
                    string3 := (LANGUAGE = "PT-BR" ? "O Cavebot está configurado para obter as coordenadas da memória do cliente(aba Settings), então você pode ignorar esse aviso caso a coordenada detectada esteja fora do limite de coordenadas do Map Viewer ou o mapa mostrado no viewer esteja diferente na mesma coordenada no Tibia." : "The Cavebot is configured to get the coordinates from the client memory(Settings tab), so you can ignore this warn in case the detected coordinate is out of the limits of the Map Viewer or the map shown in the viewer is different in the same coordinate in Tibia." )
                    string2 := ""
                case false:
                    string2 := (LANGUAGE = "PT-BR" ? "Se essa coordenada não está precisa(correta), pode ser por diferenças no mapa(ou marcadores visíveis no local)." : "If this position is not accurate, it could be due to differences in the minimap(or markers visible).")
                    string3 := (LANGUAGE = "PT-BR" ? string2 "`nTente gerar o mapa novamente clicando no botão ""Map viewer"" > ""Generate from Minimap folder""." : string2 "`nTry to Generate the map again clicking in the ""Map viewer"" > ""Generate from Minimap folder"" button.")
            }
            if (OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection = true) {
                return string1 ", x: " posx ", y: " posy ", z: " posz "`n`n" string3
            } else {
                return string1 ", x: " posx ", y: " posy ", z: " posz "`n`n" string2
            }
        }
    }

    fixRangeValue(range) {
        rangeStr := StrSplit(range, " ")
        return StrReplace(rangeStr.1, " ") " x " StrReplace(rangeStr.3, " ")
    }

    validateRange(rangeX, rangeY) {
        if (rangeX = "")
            return "Empty range X."
        if (rangeY = "")
            return "Empty range Y."

        if (rangeX < 1)
            return "Range X lower than 1."
        if (rangeY < 1)
            return "Range Y lower than 1."
        if (rangeX > 99)
            return "Range X higher than 99."
        if (rangeY > 99)
            return "Range Y higher than 99."
    }

    validateType(type) {

        if (OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection = true) {
            switch type {
                case "Walk": return
                case "Stand": return
                case "Door": return
                case "Use": return
                case "Ladder": return
                case "Ladder Up", case "Ladder Down": return
                case "Stair Up", case "Stair Down": return
                case "Rope": return
                case "Shovel": return
                case "Machete": return
                case "Action": return
            }
        } else {
            /**
            OTClientV8
            */
            switch type {
                case "Walk": return
                case "Stand": return
                case "Door": return
                case "Use": return
                case "Ladder Up", case "Ladder Down": return
                case "Stair Up", case "Stair Down": return
                case "Rope": return
                case "Shovel": return
                case "Machete": return
                case "Action": return
            }
        }

        return "Wrong waypoint type: """ type """."
    }

    validateLabel(label, waypointNumber, tabName) {
        if (label = "")
            return
        result := ""

        if (label != "" && StrLen(label) < 3)
            result := LANGUAGE = "PT-BR" ? "O nome deve ter no mínimo 3 caractéres (" label ")." : "The name of must have at least 3 characters (" label ")."

        try,
            var_value := %label%
        catch
            var_value := ""
        if (var_value != "") {
            result := LANGUAGE = "PT-BR" ? "O nome do Label não pode ser o mesmo nome de uma variável do Script, existe uma variável com o nome """ label """.`n`nUtilize outro nome para o Label." : "The name of the Label can't be the same name of a Script variable, there is a variable with the name """ label """.`n`nUse another name for the Label."
            return result
        }

        if (InArray(CavebotSystem.specialLabels, label) != 0) && (tabName != "Special") {
            result := txt("Label com o nome de um ""Special Label""(""" label """) deve ser adicionado em waypoint de Action em uma aba com o nome ""Special"" para funcionar.", "A Label with the name of a ""Special Label""(""" label """) must be added on a Action waypoint in a tab named ""Special"" for it to work.")
            return result
        }

        findLabelResult := this.findLabel(label)

        if (findLabelResult.labelFound = false)
            return result

        if (findLabelResult.tabFound = tabName) && (findLabelResult.waypointFound = waypointNumber)
            return result
        else
            result := LANGUAGE = "PT-BR" ? "Já existe um label com o nome """ label """, na aba """ findLabelResult.tabFound """, waypoint número: " findLabelResult.waypointFound ".`n`nUtilize outro name para o label." : "There is already a label with the name """ label """, on the tab """ findLabelResult.tabFound """, waypoint number: " findLabelResult.waypointFound ".`n`nUse another name for the label."
        return result
    }

    validateCoordinates(coordinates) {
        if (!InStr(coordinates, "x") OR !InStr(coordinates, "y") OR !InStr(coordinates, "z"))
            return "Waypoint coordinates has no x, y or z letters: '" coordinates "'."

        x := this.getCoordFromString("x", coordinates)
        y := this.getCoordFromString("y", coordinates)
        z := this.getCoordFromString("z", coordinates)

        if (x = "")
            return "Empty X coordinate: """ coordinates """."
        if (y = "")
            return "Empty Y coordinate: """ coordinates """."
        if (z = "")
            return "Empty Z coordinate: """ coordinates """."
        ; if (x < tibiaMapX1)
        ;     return "Wrong X coordinate: """ coordinates """."
        ; if (y < tibiaMapY1)
        ;     return "Wrong Y coordinate: """ coordinates """."
        if (z > 15 OR z < 0)
            return "Invalid Z coordinate: """ coordinates """."
    }

    validateAction(actionScriptCode, tabName, waypointNumber) {
        global initialString
        script_lines := []
        ArrayVars := StrSplit(StrReplace(actionScriptCode, "`n", "<br>"), "<br>")

        for line, lineContent in ArrayVars
        {
            if (lineContent = "" OR lineContent = A_Space)
                continue


            hashtag := SubStr(lineContent, 1, 1)
            if (hashtag = "#")
                continue

            initialString := LANGUAGE = "PT-BR" ? "Linha: " line "`nFunção: " lineContent "`n`n[ ERRO: ]`n" : "Line: " line "`nFunction: """ lineContent """`n`n[ ERRO: ]`n"

            spaceLeft := SubStr(lineContent, 1, 1)
            /**
            check if first character of the line is a space
            */
            if (spaceLeft = " ") {
                return initialString "The first character of the line " line " is a ""Space"", remove the space."
            }

            if (lineContent = "return")
                continue

            switch (_ActionScriptValidation.isVariableString(lineContent)) {
                case true:
                case false:
                    if (!InStr(lineContent, ")"))
                        return initialString (LANGUAGE = "PT-BR" ? "Erro de sintáxe, faltando o caractére "")""." : "Syntax error, missing the character "")"".")

                    if (!InStr(lineContent, "("))
                        return initialString (LANGUAGE = "PT-BR" ? "Erro de sintáxe, faltando o caractére ""(""." : "Syntax error, missing the character ""("".")
            }

            ifString := SubStr(lineContent, 1, 2)
            if (ifString = "if") {
                validation := this.validateIfAction(actionScriptCode, lineContent, tabName, waypointNumber)
                if (validation != "")
                    return initialString "" validation
                continue
            }
            if (this.validateActionExists(lineContent) = false)
                return initialString (LANGUAGE = "PT-BR" ? "Não é uma função válida." : "Is not a valid function")

            validation := this.validateLineWithTwoActions(lineContent)
            if (validation != "")
                return initialString "" validation

            validation := _ActionScriptValidation.validateActionScript(lineContent, actionScriptCode, tabName, waypointNumber)
            if (validation != "")
                return initialString "" validation
        }
    }

    /**
    validate 2 actions in the same line, example:
    turn(N) say(exani hur DOWN)
    */
    validateLineWithTwoActions(lineContent) {
        StrReplace(lineContent, "(", "(", openingParens)
        if (openingParens >= 2)
            return txt("Há mais de uma action na mesma linha, uma linha só pode conter 1 action(quando não possui ""if"").", "There is more than one action in the same line, a line can only have 1 action(when it doesn't have ""if"").")
    }

    formatActionToSave(actionScriptCode, type := "") {

        scriptLines := []
        ArrayVars := StrSplit(actionScriptCode, "`n")
        for line, lineContent in ArrayVars
        {
            if (lineContent = "" OR lineContent = A_Space) {
                scriptLines .= "<br>"
                continue
            }
            hashtag := SubStr(lineContent, 1, 1)
            if (hashtag = "#") {
                scriptLines .= lineContent "`n"
                continue
            }
            ifString := SubStr(lineContent, 1, 2)
            if (ifString = "if") {
                ifStatement := this.getifStatement(lineContent)
                thenStatement := this.getThenStatement(lineContent)

                if (InStr(lineContent, " else ")) {
                    ; recordar a string até antes de checar no else
                    stringBeforeElse := SubStr(lineContent, 1, InStr(lineContent, " else "))
                    thenStatement := this.getThenStatement(stringBeforeElse)
                    elseStatement := this.getElseStatement(lineContent)
                }
                /**
                converter a action até o "(" para lwoer
                */
                ; ifLower := SubStr(lineContent, 1, (InStr(ifStatement, "(") - 1))
                ; msgbox, % ifLower

                ; msgbox, % ifStatement "`n" thenStatement "`n" elseStatement
            } else {
                ; msgbox, % "action lineContent = " lineContent
                switch type {
                    case "hotkey":
                        if (InStr(lineContent, "gotolabel(")) {
                            msgbox, 48, % "Action Script validation", % txt("A action gotolabel() não pode ser usada em " type ", somente no Cavebot.", "The action gotolabel() cannot be used in " type ", only in the Cavebot."), 10
                        }

                }
                action := SubStr(lineContent, 1, InStr(lineContent, "(") - 1)

            }
            scriptLines .= lineContent "`n"
        }

        actionScriptCode := scriptLines

        actionScriptCode := StrReplace(actionScriptCode, "`n","<br>")
        StringReplace, actionScriptCode,actionScriptCode,`", , All
        ; StringReplace, actionScriptCode,actionScriptCode,`', , All  ; can't remove because of items such as "kongra's shoulderpad"
        actionScriptCode := StrReplace(actionScriptCode, "if ","if ")
        actionScriptCode := StrReplace(actionScriptCode, " if (","if (") ; if there is a space before "if", it bugs the function, " if (...)"
        actionScriptCode := StrReplace(actionScriptCode, " else "," else ")
        actionScriptCode := StrReplace(actionScriptCode, " then "," then ")
        actionScriptCode := StrReplace(actionScriptCode, " then  "," then ")
        actionScriptCode := StrReplace(actionScriptCode, ")  then",") then")
        return actionScriptCode
    }


    validateIfAction(actionScriptCode, lineContent, tabName, waypointNumber) {
        if (InStr(lineContent, "then") && !InStr(lineContent, " then "))
            return LANGUAGE = "PT-BR" ? "Existe algum ""then"" mal formatado, sem Espaço antes ou depois." : "There is some ""then"" bad formated, with no Space before or after."
        if (!InStr(lineContent, " then "))
            return LANGUAGE = "PT-BR" ? "A linha não possui a palavra ""then""." : "The line does not have the word ""then""."

        if (InStr(lineContent, "else") && !InStr(lineContent, " else "))
            return LANGUAGE = "PT-BR" ? "Existe algum ""else"" mal formatado, sem Espaço antes ou depois." : "There is some ""else"" bad formated, with no Space before or after."

        if (InStr(lineContent, "if") && !InStr(lineContent, "if "))
            return LANGUAGE = "PT-BR" ? "O ""if"" está mal formatado, sem um espaço à direita." : "The ""if"" is bad formated, without a space on the right."


        lineStrSpaces := StrSplit(lineContent, "  ")
        if (lineStrSpaces.MaxIndex() > 1) {
            spaceString := SubStr(lineContent, 1, InStr(lineContent, "  ") + 1)
            return (LANGUAGE = "PT-BR" ? "Encontrado 2 caractéres de espaço na linha:" : "Found 2 characters of space in the line:") "`n`n""" spaceString """`n`n" InStr(lineContent, "  ")

        }


        ifStatement := this.getifStatement(lineContent)
        thenStatement := this.getThenStatement(lineContent)

        if (!InStr(ifStatement, ")"))
            return (LANGUAGE = "PT-BR" ? "Erro de sintáxe, faltando o caractére" : "Syntax error, missing the character") """)"":`n`n" ifStatement

        if (!InStr(ifStatement, "("))
            return (LANGUAGE = "PT-BR" ? "Erro de sintáxe, faltando o caractére" : "Syntax error, missing the character") """("":`n`n" ifStatement

        if (InStr(lineContent, " else ")) {
            elseStatement := this.getElseStatement(lineContent)
            validation := this.validateElseStatement(elseStatement)
            if (validation != "")
                return validation
        }

        if (thenStatement = "")
            return LANGUAGE = "PT-BR" ? """then"" mal formatado, certifique-se de que está na mesma linha e minúsculo." : """then"" bad formatted, ensure that the complete statement is in the same and lowercase line."

        if (ifStatement = "")
            return LANGUAGE = "PT-BR" ? """if"" mal formatado, certifique-se de que está na mesma linha e minúsculo." : """if"" bad formatted, ensure that the complete statement is in the same line and lowercase."



        validation := this.validateItemCountIfStatement(actionScriptCode, ifStatement, tabName, waypointNumber)
        if (validation != "")
            return validation

        conditionStatement := this.getConditionParams(ifStatement)
        ; msgbox, % ifStatement "`n" thenStatement "`n" serialize(conditionStatement)

        validation := this.validateConditionParams(conditionStatement)
        if (validation != "")
            return validation

        if (this.validateActionExists(thenStatement) = false)
            return LANGUAGE = "PT-BR" ?  """" thenStatement """ Não é uma função válida." : "Is not a valid function"

        if (this.validateActionExists(elseStatement) = false)
            return LANGUAGE = "PT-BR" ? """" elseStatement """ Não é uma função válida." : "Is not a valid function"
    }

    getElseStatement(lineContent) {
        lineStr := StrSplit(lineContent, " else ", "`t")
        elseStatement := lineStr.2
        return elseStatement

    }

    validateElseStatement(elseStatement) {
        if (elseStatement = "")
            return LANGUAGE = "PT-BR" ? """else"" vazio, certifique-se de que está na mesma linha e minúsculo.": "empty ""else"", ensure that the complete statement is in the same line and lowercase."

        if (!InStr(elseStatement, ")"))
            return (LANGUAGE = "PT-BR" ? "Erro de sintáxe, faltando o caractére "")"" no ""else""" : "Syntax error, missing the character "")"" on ""else""") ":`n`n" elseStatement
        if (!InStr(elseStatement, "("))
            return (LANGUAGE = "PT-BR" ? "Erro de sintáxe, faltando o caractére ""("" no ""else""" : "Syntax error, missing the character ""("" on ""else""") ":`n`n" elseStatement
        if (InStr(elseStatement, "if"))
            return LANGUAGE = "PT-BR" ? "Não é permitido ""if"" logo após o ""else""." : "It is not allowed ""if"" right after the ""else""."
    }

    validateActionExists(lineContent) {
        /**
        checar se o nome da função é o mesmo de uma das funções no array de action_scripts
        */
        action_exists := false
        action := _ActionScriptValidation.getFunctionNameNoParenthesis(lineContent)
        for key, value in action_scripts
        {
            if (value = value) {
                ; msgbox,  exists  action% = %value%
                action_exists := true
                return
            }
        }

        return action_exists

    }

    validateConditionParams(conditionStatement) {
        ; msgbox, % serialize(conditionStatement)
        conditionValue1 := conditionStatement.2
        condition := conditionStatement.3
        conditionValue2 := conditionStatement.4
        ; if (InStr(conditionValue1, " "))
        ; return LANGUAGE = "PT-BR" ? "Há um caractere de espaço na condição 1 """ conditionValue1 """." : "There is a space character in the condition 1 """ conditionValue1 """."
        if (InStr(condition, " "))
            return LANGUAGE = "PT-BR" ? "Há um caractere de espaço no operador da condição """ condition """." : "There is a space character in the condition operator """ condition """."

        if (_ActionScriptValidation.isVariableString(conditionValue1) = true) {
            if (containsSpecialCharacter(StrReplace(conditionValue1, "$", "")))
                return "There are special characters in the condition 1 """ conditionValue1 """."
        }

        allowedConditionOperators := {}
        allowedConditionOperators.Push(">")
        allowedConditionOperators.Push("<")
        allowedConditionOperators.Push("=")
        allowedConditionOperators.Push("!=")
        allowedConditionOperators.Push(">=")
        allowedConditionOperators.Push("<=")

        operatorsString := ""
        for key, operator in allowedConditionOperators
            operatorsString .= operator ", "
        StringTrimRight, operatorsString, operatorsString, 2

        conditionAllowed := false
        for key, operator in allowedConditionOperators
        {
            if (condition = operator) {
                conditionAllowed := true
                return
            }
        }

        if (conditionAllowed = false)
            return (LANGUAGE = "PT-BR" ? "O operador da condição """ condition """ não é nenhum dos permitidos " : "The condition operator """ condition """ is none of the allowed ") "(" operatorsString ")."
    }
    getThenStatement(lineContent) {
        lineStr := StrSplit(lineContent, " then ", "`t")

        return lineStr.2
    }

    getIfStatement(lineContent) {
        lineStr := StrSplit(lineContent, " then ", "`t")
        return lineStr.1
    }

    getNewIfStatementAndItemCount(ifStatement) {

        string := StrSplit(ifStatement, "itemcount")

        ifWord := string.1
        itemCountString := string.2

        newString := StrSplit(itemCountString, ")")
        itemCountParam := StrReplace(newString.1, "(", "")

        ; if has item count, must replace spaces of the itemcount() param, so the getConditionParams() function works as it's supposed to
        itemCountParamNew := StrReplace(itemCountParam, " ", "_")

        newIfStatement := string.1 "itemcount(" itemCountParamNew ")" newString.2 ")"

        ; msgbox, % serialize(string) "`n`n" serialize(newString) "`n`n" itemCountParam "`n" itemCountParamNew "`n`n" newIfStatement "`n" ifStatement
        return {ifStatement: newIfStatement, item: itemCountParam, itemNoSpaces: itemCountParamNew}
    }

    ; validate the itemcount() atributes of the if statement
    validateItemCountIfStatement(actionScriptCode, ifStatement, tabName, waypointNumber) {
        if (!InStr(ifStatement, "itemcount"))
            return

        ifStatementInfo := this.getNewIfStatementAndItemCount(ifStatement)
        paramItem := ifStatementInfo.item
        newIfStatement := ifStatementInfo.ifStatement
        if (newIfStatement = "")
            return "Validation of if statement with itemcount() didn't pass, wasn't able to recognize if statement properly(empty)."

        if (paramItem = "")
            return "Validation of if statement with itemcount() didn't pass, wasn't able to recognize item param properly(empty)."

        ; if the itemcount() param is a variable itemcount($var), validate if the variable item exists on itemsImageObj
        if (_ActionScriptValidation.isVariableString(paramItem)) {
            userOptionName := ""
            if (!actionScriptsVariablesObj[tabName][waypointNumber][paramItem]) {
                ; msgbox, % paramItem "= " serialize(actionScriptsVariablesObj[tabName][waypointNumber])
                ; the actionScriptsVariablesObj is created only when saving a action script, so need to find the new variable in the script when the variable is being created together with the "action function" that is using it
                value := _ActionScriptValidation.findVariableName(actionScriptCode, paramItem)
                if (value = "")
                    return "Validation of if statement with itemcount() didn't pass.`nVariable """ paramItem """ not found in the action script."
                userOptionName := value
            }
            if (userOptionName = "")
                userOptionName := actionScriptsVariablesObj[tabName][waypointNumber][paramItem]
            ; msgbox, % userOptionName "= " serialize(userOptionVariablesObj)
            if (!userOptionVariablesObj[userOptionName])
                return "Validation of if statement with itemcount() didn't pass.`nUser option name """ useOptionName """ of variable """ paramItem """ not found on user options."
            itemName := userOptionVariablesObj[userOptionName]

            if (itemsImageObj) && (!itemsImageObj[itemName])
                return "Validation of if statement with itemcount() didn't pass.`nOtem """ itemName """ of variable """ paramItem """ doesn't exist on items list."
        } else {
            ; is a written item name, ex: itemcount(great mana potion)
            if (itemsImageObj) && (!itemsImageObj[paramItem])
                return "Validation of if statement with itemcount() didn't pass.`nOtem """ paramItem """ doesn't exist on items list."
        }
    }

    getConditionParams(ifStatement) {
        /**
        if has item count, must replace spaces of the itemcount() param
        */
        if (InStr(ifStatement, "itemcount")) {
            ifStatementInfo := this.getNewIfStatementAndItemCount(ifStatement)
            ifStatement := ifStatementInfo.ifStatement
        }


        stringParenthesis := StrSplit(ifStatement, "if (")
        ; msgbox,, % "stringParenthesis", % serialize(stringParenthesis)



        isFunctionParam := (InStr(stringParenthesis.2, "(") > 0) ? true : false
        ; msgbox, % isFunctionParam
        switch isFunctionParam {
                /**
                if is a condition with function, like
                if (itemcount(mana potion) = 0)...
                */
            case true:
                conditionStatementString := StrSplit(stringParenthesis.2, "(")
                ; msgbox,, % "conditionStatementString", % serialize(conditionStatementString)
                conditionStatementParametersString := StrSplit(conditionStatementString.2, ")")
                ; msgbox,, % "conditionStatementParametersString", % serialize(conditionStatementParametersString)
                conditionStatementParameters := conditionStatementParametersString.1
                conditionStatement := conditionStatementString.1 "(" conditionStatementParameters ")"
                ; msgbox, % serialize(conditionStatementString) "`n`n" conditionStatement
                ; msgbox, % serialize(conditionOperatorAndValueString)
                conditionOperatorAndValueString := StrSplit(conditionStatementString.2, ")")
                conditionOperatorAndValueString2 := StrSplit(conditionOperatorAndValueString.2, " ")
                conditionOperator := conditionOperatorAndValueString2.2
                conditionValue := conditionOperatorAndValueString2.3

                /**
                if is a condition with variable, like
                if ($hasMana = 0)...
                if ($amountOfPotions >= $manaPotionAmount)...
                */
            case false:
                conditionStatementString := stringParenthesis.2
                ; msgbox,, % "conditionStatementString", % conditionStatementString
                conditionStatementString2 := StrSplit(conditionStatementString, " ")
                ; msgbox,, % "conditionStatementString2", % serialize(conditionStatementString2)
                conditionStatement := conditionStatementString2.1

                conditionOperator := conditionStatementString2.2
                conditionValue := conditionStatementString2.3
                /**
                remove the ")" from the condition value $manaPotionAmount)
                if ($amountOfPotions >= $manaPotionAmount)
                */
                conditionValue := StrReplace(conditionValue, ")", "")

        }

        lineStr := {}
        lineStr[1] := "if"
        lineStr[2] := conditionStatement
        lineStr[3] := conditionOperator
        lineStr[4] := conditionValue
        ; msgbox,, % "lineStr", %  serialize(lineStr)
        return lineStr
    }

    formatCoordinatesValue(coords) {
        x := this.getCoordFromString("x", coords)
            , y := this.getCoordFromString("y", coords)
            , z := this.getCoordFromString("z", coords)
        return {x: x += 0, y: y += 0, z: z += 0}
    }
}