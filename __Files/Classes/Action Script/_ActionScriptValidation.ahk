
Class _ActionScriptValidation extends _BaseClass
{
    static actionScriptCode := ""

    __New()
    {
        this.actionScriptCode := ""

        ; msgbox, % A_ThisFunc

    }

    validateActionScript(lineContent, actionScriptCode, tabName, waypointNumber) {
        ; msgbox, % A_ThisFunc ": " tabName " / " waypointNumber

        this.actionScriptCode := actionScriptCode
        functionValues := this.getFunctionValues(lineContent)
        ; msgbox, % lineContent "`n`n" serialize(functionValues)

        if (this.isVariableString(lineContent) = true) {
            validation := this.validateUserOptionVariable(lineContent)
            return validation
        }

        validation := this.validate_noParamValues(lineContent, functionValues)
        if (validation != "")
            return validation

        validation := this.validateActionVariable(actionScriptCode, lineContent, functionValues)
        if (validation != "")
            return validation

        functionName := this.getFunctionNameNoParenthesis(lineContent)
        validation := this.validateActionScriptFunction(functionName, functionValues, tabName, waypointNumber)
        if (validation != "")
            return validation

        this.actionScriptCode := ""

    }

    validateActionVariable(actionScriptCode, lineContent, functionValues) {
        ; msgbox, % A_ThisFunc,, % serialize(functionValues)

        Loop, % functionParamsNumber {
            if (_ActionScriptValidation.isVariableString(functionValues[A_Index]) = true) {



                /*
                check if the variable of the function has value
                */
                ; msgbox, % functionValues[A_Index] "`n." serialize(actionScriptsVariablesObj[tabName][waypointNumber]) "`n." actionScriptsVariablesObj[tabName][waypointNumber][functionValues[A_Index]]
                ; if (!actionScriptsVariablesObj[tabName][waypointNumber][functionValues[A_Index]]) {
                ; msgbox, % serialize(actionScriptsVariablesObj[tabName][waypointNumber])
                ; the actionScriptsVariablesObj is created only when saving a action script, so need to find the new variable in the script when the variable is being created together with the "action function" that is using it
                value := this.findVariableName(actionScriptCode, functionValues[A_Index])
                ; msgbox, % value " / " functionValues[A_Index]
                if (value = "")
                    return LANGUAGE = "PT-BR" ? "Variável """ functionValues[A_Index] """ não possui valor(ou não existe)." : "Variable """ functionValues[A_Index] """ has no value(or doesn't exist)."
                ; }

                functionValues[A_Index] := _ActionScriptValidation.getValueFromActionScriptVariable(functionValues[A_Index], tabName, waypointNumber)

                ; msgbox, % functionValues[A_Index] "`n" serialize(userOptionVariablesObj)
            }
        }
    }

    getValueFromActionScriptVariable(variableName, tabName := "", waypointNumber := "") {
        switch ActionScript.actionScriptType {
            case "hotkey", case "persistent":
                variableValue := actionScriptsVariablesObj[ActionScript.actionScriptType][waypointNumber][variableName]
            default:
                variableValue := actionScriptsVariablesObj[tabName][waypointNumber][variableName]
        }
        /*
        if has slash, it is a getsetting() function
        */
        if (InStr(variableValue, "/")) {
            return ActionScript.getsetting(variableValue)
        }

        /*
        otherwise, will be a getuseroption() or action script variable
        */
        functionName := "getuseroption"

        /*
        if is a checkbox unchecked, gets value 0(false) and is considered as empty
        */
        if (userOptionVariablesObj[variableValue] != "" OR userOptionVariablesObj[variableValue] = false) {
            return userOptionVariablesObj[variableValue]
        }
        /*
        if the variable name is an action script variable
        */
        switch ActionScript.actionScriptType {
            case "hotkey", case "persistent":
                variableValue := actionScriptsVariablesObj[ActionScript.actionScriptType][waypointNumber][variableName]
                if (actionScriptsVariablesObj[ActionScript.actionScriptType][waypointNumber][variableName] != "" OR actionScriptsVariablesObj[ActionScript.actionScriptType][waypointNumber][variableName] = false) {
                    return actionScriptsVariablesObj[ActionScript.actionScriptType][waypointNumber][variableName]
                }
            default:
                if (actionScriptsVariablesObj[tabName][waypointNumber][variableName] != "" OR actionScriptsVariablesObj[tabName][waypointNumber][variableName] = false) {
                    return actionScriptsVariablesObj[tabName][waypointNumber][variableName]
                }
        }

        writeCavebotLog("ERROR", (functionName ": ") "User option """ variableValue """ doesn't exist, check if the variable is correct (""" variableName """)")
        return -1
    }

    findVariableName(actionScriptCode, variableName) {
        ArrayVars := StrSplit(StrReplace(actionScriptCode, "`n", "<br>"), "<br>")
        for line, lineContent in ArrayVars
        {
            if (InStr(lineContent, variableName)) {
                variableNameFound := this.getVariableName(lineContent)
                if (variableNameFound != variableName)
                    continue
                variableValue := this.getVariableFunctionName(lineContent)
                    , variableFunctionParam := this.getVariableFunctionParam(variableValue)

                /*
                if variableFunctionParam is empty, that means the variable receiving a string not a function
                so return the variableValue
                example:
                $item = mana potion
                */
                if (variableFunctionParam = "")
                    return variableValue
                ; msgbox, % variableValue "`n." variableFunctionParam

                /*
                if the variable is receiving a function that has no params, return true
                example: $teste = capacity()
                */
                if (InArray(action_scripts_no_params, StrReplace(variableValue, "()", "")) > 0)
                    return true
                ; msgbox, % lineContent " = " variableName " / " variableNameFound "`n variableValue = " variableValue "`n variableFunctionParam = " variableFunctionParam
                ; msgbox, % variableValue " = " variableUserOption
                return variableFunctionParam

            }
        }


    }

    getSqmFromDirection(direction) {
        switch direction {
            case "SW": return 1
            case "S": return 2
            case "SE": return 3
            case "W": return 4
            case "C": return 5
            case "E": return 6
            case "NW": return 7
            case "N": return 8
            case "NE": return 9
        }
    }

    isVariableString(lineContent) {
        if (SubStr(lineContent, 1, 1) = "$")
            return true
        return false
    }

    isVariableAndPeformAction(lineContent, line := "", performAction := false, tabName := "", waypointNumber := "") {
        if (SubStr(lineContent, 1, 1) = "$") {
            if (performAction = false)
                return true
            if (InStr(lineContent, "getsetting") OR InStr(lineContent, "getuseroption"))
                return true

            this.setValueToVariableFunction(lineContent, line, tabName, waypointNumber)
            return true
        }
        return false
    }

    getVariableFunctionValue(functionName, tabName, waypointNumber, variableName := "") {

        functionValues := this.getFunctionValues(functionName)
        ; msgbox, % functionName "`n`n" serialize(functionValues)
        ; the getConditionParams() function returns the function params with underlines instead of spaces
        for key, value in functionValues
            functionValues[key] := StrReplace(functionValues[key], "_", " ")
        ; msgbox, % serialize(functionValues)

        /*
        if the variable is receiving a simple string, return the functionName as value
        because there is no function to run and return the result
        example
        $item = mana potion
        */
        if (!InStr(functionName, "(")) {
            writeCavebotLog("Action", ActionScript.string_log " Assigning value to variable, " variableName " = """ functionName """")
            /*
            if it is a global variable, example
            $x = posx
            */
            try {
                value := %functionName%
                if (value) {
                    return value
                }
            } catch {
            }
            return functionName
        }

        functionNameNoParenthesis := this.getFunctionNameNoParenthesis(functionName)
        ; msgbox, % "functionNameNoParenthesis = " functionNameNoParenthesis

        result := _ActionScript.performActionScriptFunction(functionNameNoParenthesis, functionValues, A_ThisFunc)
        ; msgbox, % "result = " result

        ; msgbox, % "before check " serialize(actionScriptsVariablesObj[tabName][waypointNumber])
        ; msgbox, % functionParam " = " functionParamValue " = " result

        return result
    }

    setValueToVariableFunction(lineContent, line, tabName, waypointNumber) {
        variableName := this.getVariableName(lineContent)
        functionName := this.getVariableFunctionName(lineContent)

        ; msgbox, % A_ThisFunc "`n" lineContent "`n`n" functionName "`n" variableName "`n waypointNumber " waypointNumber "`n ActionScript.actionScriptType " ActionScript.actionScriptType

        ActionScript.string_log := "[L: " line ", F: " lineContent "]"
        switch ActionScript.actionScriptType {
            case "hotkey", case "persistent":
                actionScriptsVariablesObj[ActionScript.actionScriptType][waypointNumber][variableName] := this.getVariableFunctionValue(functionName, tabName, waypointNumber, variableName)
            default:
                actionScriptsVariablesObj[tabName][waypointNumber][variableName] := this.getVariableFunctionValue(functionName, tabName, waypointNumber, variableName)

        }
        return
    }

    getVariableName(lineContent) {
        string := StrSplit(lineContent, " = ")
        return string.1
    }

    getVariableFunctionName(lineContent) {
        string := StrSplit(lineContent, " = ")
        variableName := string.1
        variableValue := string.2
        return string.2
    }

    getVariableFunctionParam(variableValue) {
        string := StrSplit(variableValue, "(")
        return StrReplace(string.2, ")", "")

    }

    validateUserOptionVariable(lineContent) {
        ; validate if there is a =
        if (!InStr(lineContent, " = ")) {
            return LANGUAGE = "PT-BR" ? "Não há o caractére de igual "" = "" formatado corretamente(com espaço antes e depois) na linha." : "There is the equal character "" = "" formatted correctly(with space before and after) in the line."
        }

        variableName := this.getVariableName(lineContent)
        variableValue := this.getVariableFunctionName(lineContent)

        if (InStr(variableValue, "getuseroption")) {
            validation := this.validateGetUserOption(variableName, variableValue)
            if (validation != "")
                return validation

        }
    }

    getFunctionValues(lineContent) {
        /*
        checar está passando algum valor dentro dos paranteses para a função
        */

        ; msgbox, % lineContent
        string := StrSplit(lineContent, "(")
        ; msgbox, % serialize(string)
        func_params := StrSplit(string.2, ")")
        ; msgbox, % serialize(func_params)
        func_values := StrSplit(func_params.1, ",")
        ; msgbox, % serialize(func_values)
        functionName := string.1

        functionValues := {}

        ; remove white spaces from the left and right of the string
        cleanedValues := {}

        Loop, % functionParamsNumber
            cleanedValues[A_Index] := LTrim(RTrim(func_values[A_Index]))

        Loop, % functionParamsNumber
            functionValues[A_Index] := cleanedValues[A_Index]
        return functionValues

    }

    getFunctionNameNoParenthesis(lineContent) {
        return SubStr(lineContent, 1, InStr(lineContent, "(") - 1)
    }

    validateGetUserOption(variableName, variableValue) {
        if (!InStr(variableValue, "(") OR !InStr(variableValue, ")"))
            return LANGUAGE = "PT-BR" ? "Função getuseroption() da variável """ variableName """ não está com o valor setado dentro dos parênteses." : "Function getuseroption() of variable """ variableName """ has no value set in the parentheses."

        variableUserOption := this.getVariableFunctionParam(variableValue)

        if (variableUserOption = "")
            return LANGUAGE = "PT-BR" ? "Função getuseroption() da variável """ variableName """ não está com o valor setado dentro dos parênteses." : "Function getuseroption() of variable """ variableName """ has no value set in the parentheses."

        if (containsSpecialCharacter(variableUserOption) = true)
            return LANGUAGE = "PT-BR" ? "Função getuseroption() da variável """ variableName """ possui caratéres especiais." : "Function getuseroption() of variable """ variableName """ has special characters."

        validation := this.validateUserOptionVariableExists(variableName, variableUserOption)

        if (validation != "")
            return validation

    }

    getUserOptionValue(variableName) {
        for key1, groupName in scriptVariablesObj
        {
            ; msgbox, % "group " key " = " serialize(groupName)
            for key2, children in groupName
            {
                ; msgbox, % "children " key2 " = " serialize(children)
                for key3, childrenElements in children
                {
                    ; msgbox, % childrenElements.name " = " variableName "`n" optionValue " / " serialize(optionValue)
                    if (childrenElements.name = variableName)
                        return childrenElements.value
                }
            }
        }
    }

    validateUserOptionVariableExists(variableName, variableUserOption) {
        for key1, groupName in scriptVariablesObj
        {
            ; msgbox, % "group " key " = " serialize(groupName)
            for key2, children in groupName
            {
                ; msgbox, % "children " key2 " = " serialize(children)
                for key3, childrenElements in children
                {
                    ; msgbox, % childrenElements.name " = " variableUserOption "`n" optionValue " / " serialize(optionValue)
                    if (childrenElements.name = variableUserOption)
                        return
                }
            }
        }
        return LANGUAGE = "PT-BR" ? "Função getuseroption() da variável """ variableName """, não existe nenhuma variável com o nome """ variableUserOption """." : "Function getuseroption() of variable """ variableName """, there is no user option variable with the name """ variableUserOption """."
    }

    validateActionScriptFunction(functionName, functionValues, tabName := "", waypointNumber := "") {
        switch functionName {
            case "clickonsqm":              return this.validate_clickonsqm(functionValues)
            case "clickonimage":            return this.validate_clickonimage(functionValues)
            case "clickonitem":             return this.validate_clickonitem(functionValues)
            case "clickonposition":         return this.validate_clickonposition(functionValues)
            case "convertgold":            return this.validate_convertgold(functionValues)
            case "exitgame":                return this.validate_exitgame(functionValues)
            case "follownpc":               return this.validate_follownpc(functionValues)
            case "gotolabel":               return this.validate_gotolabel(functionValues)
            case "gotowaypoint":            return this.validate_gotowaypoint(functionValues)
            case "log":                     return this.validate_log(functionValues)
            case "imagesearch":             return this.validate_imagesearch(functionValues)
            case "messagebox":              return this.validate_messagebox(functionValues)
            case "mousedrag":               return this.validate_mousedrag(functionValues)
            case "mousedragitem":           return this.validate_mousedragitem(functionValues)
            case "mousedragitemposition":   return this.validate_mousedragitemposition(functionValues)
            case "mousemove":               return this.validate_mousemove(functionValues)
            case "presskey":                return this.validate_presskey(functionValues)
            case "reopencavebot":           return this.validate_reopencavebot(functionValues)
            case "runahkscript":            return this.validate_runahkscript(functionValues)
            case "runcommand":              return this.validate_runcommand(functionValues)
            case "screenshot":              return this.validate_screenshot(functionValues)
            case "startlure":               return this.validate_startlure(functionValues)
            case "say":                     return this.validate_say(functionValues)
            case "setsetting":              return this.validate_setsetting(functionValues, tabName, waypointNumber)
            case "traytip":                 return this.validate_traytip(functionValues)
            case "turn":                    return this.validate_turn(functionValues)
            case "variabledecrement":       return this.validate_variabledecrement(functionValues)
            case "variableincrement":       return this.validate_variableincrement(functionValues)
            case "usesqm":                  return this.validate_usesqm(functionValues)
            case "variable":                return this.validate_variable(functionValues)
                ; case "wait":                    return this.validate_wait(functionValues)
        }

    }

    validateFunctionValueVariable(functionValue, returnValue := false) {
        ; msgbox, % A_ThisFunc, % functionValue
        value := this.getUserOptionValue(StrReplace(functionValue, "$", ""))
        if (empty(value)) {
            ; the userOptionVariablesObj is created only when start/loading a script, so it's needed to recreate again to include the newly created variables
            ; CavebotScript.createUserOptionVariablesObj()
            ; value := this.getUserOptionValue(StrReplace(functionValue, "$", ""))
            ; if (value = "")
            return {error: LANGUAGE = "PT-BR" ? "Variável """ functionValue """ não possui valor(ou não existe)." : "Variable """ functionValue """ has no value(or doesn't exist)."}
        }

        if (returnValue = true)
            return {error: "", value: value}
        return
    }

    validate_noParamValues(lineContent, functionValues) {
        if (functionValues.1 = "") && (InArray(action_scripts_no_params, StrReplace(lineContent, "()", "")) = 0)
            return LANGUAGE = "PT-BR" ? "Não está com o valor setado dentro dos parênteses." : "There is no value setted between the parentheses."
    }

    validate_functionValue(functionValues, paramNumber) {
        ; msgbox, % A_ThisFunc, % serialize(functionValues)
        if (InStr(functionValues[paramNumber], "$")) {
            var_name := StrReplace(functionValues[paramNumber], "$")
            ; msgbox, % functionValues[paramNumber] "`n" paramNumber
            try
                var_value := %var_name%
            catch
                var_value := ""
            return LANGUAGE = "PT-BR" ? "Variável """ functionValues[paramNumber] """ não possui valor(ou não existe)." : "Variable """ functionValues[paramNumber] """ has no value(or doesn't exist)."
            functionValues[paramNumber] := var_value
        }
        return true
    }

    validate_clickonimage(functionValues) {
        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)

        if (!scriptImagesObj[functionValues.1]) {
            CavebotGUI.createScriptImagesGUI()
            return "Image """ functionValues.1 """ doesn't exist in the Script Images list."
        }


        paramN := 2
        try this.validateMouseClick(functionValues[paramN], paramN)
        catch e
            return e.Message

        if (functionValues.3 != "") {
            if (functionValues.3 < 1)
                return this.warnNotNumber(functionValues.3, 4)
        }

        if (functionValues.4 != "") {
            if (functionValues.4 < 1)
                return this.warnNotNumber(functionValues.4, 4)
        }

        paramN := 5
        if (functionValues[paramN] != "") && (functionValues[paramN] < 1 OR functionValues[paramN] > 80) {
            return LANGUAGE = "PT-BR" ? "O parâmetro " paramN " (" functionValues[paramN] ") não está dentro dos valores permitidos(de 1 a 80)." : "The param " paramN " (" functionValues[paramN] ") must be between the allowed values(from 1 to 80)."
        }
    }

    validate_clickonitem(functionValues) {
        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)

        if (functionValues.1 = -1)
            return

        if (!itemsImageObj[functionValues.1])
            return "Item """ functionValues.1 """ doesn't exist in the items list"

        paramN := 2
        try this.validateMouseClick(functionValues[paramN], paramN)
        catch e
            return e.Message

        if (functionValues.3 != "") {
            if (functionValues.3 < 1)
                return this.warnNotNumber(functionValues.3, 4)
        }

        if (functionValues.4 != "") {
            if (functionValues.4 < 1)
                return this.warnNotNumber(functionValues.4, 4)
        }

        paramN := 5
        if (functionValues[paramN] != "") && (functionValues[paramN] < 1 OR functionValues[paramN] > 80) {
            return LANGUAGE = "PT-BR" ? "O parâmetro " paramN " (" functionValues[paramN] ") não está dentro dos valores permitidos(de 1 a 80)." : "The param " paramN " (" functionValues[paramN] ") must be between the allowed values(from 1 to 80)."
        }
    }

    validate_clickonposition(functionValues) {
        paramN := 1
        try this.validateMouseClick(functionValues[paramN], paramN)
        catch e
            return e.Message

        if (functionValues.2 < 1) {
            return this.warnNotNumber(functionValues.2, 2)
        }
        if (functionValues.3 < 1) {
            return this.warnNotNumber(functionValues.3, 3)
        }
        if (functionValues.4 && functionValues.4 < 1) {
            return this.warnLowerThanOne(functionValues.4, 4)
        }
        if (functionValues.5 != "") {
            if (functionValues.5 < 1) {
                return this.warnLowerThanOne(functionValues.5, 5)
            }
        }
    }

    validate_convertgold(functionValues) {
        hotkey := functionValues.1
        if (hotkey != "") {
            try this.validateHotkey(hotkey)
            catch e
                return e.Message
        }
    }

    validate_clickonsqm(functionValues) {
        paramN := 1
        try this.validateMouseClick(functionValues[paramN], paramN)
        catch e
            return e.Message

        try {
            _Validation.string("functionValues.2", functionValues.2)
        } catch {
            return this.warnIsNumber(functionValues.2, 2)
        }

        if (functionValues.3 != "" && functionValues.3 < 1) {
            return this.warnLowerThanOne(functionValues.3, 3)
        }
        if (functionValues.4 != "") {
            if (functionValues.4 < 1) {
                return this.warnLowerThanOne(functionValues.4, 4)
            }
        }

        is_valid := this.isValidSQM(functionValues.2)
        if (is_valid = false) {
            return LANGUAGE = "PT-BR" ? "Valor do primeiro parâmetro(" functionValues.2 "), não é um dos SQMs válidos." : "Value of the first parameter (" functionValues.2 "), is not one of the valid SQMs."
        }
    }

    validate_exitgame(functionValues) {
        if (functionValues.1 != "" && functionValues.1 != "1" && functionValues.1 != "0") {
            paramN := 1
            return LANGUAGE = "PT-BR" ? "O parâmetro " paramN " (" functionValues[paramN] ") é diferente de 0 ou 1." : "The param " paramN " (" functionValues[paramN] ") if different than 0 and 1."
        }
    }

    validate_follownpc(functionValues) {
        npc := functionValues.1
        StringLower, npc, npc


        if (scriptImagesObj.HasKey(npc) = false) && (!FileExist(ImagesConfig.npcsFolder "\" npc ".png")) {
            CavebotGUI.createScriptImagesGUI()
            ; Sleep, 1000
            return LANGUAGE = "PT-BR" ? "Não há imagem do NPC (" functionValues.1 ") nas Script Images.`nAdicione a Script Image com a ""Category"" NPC e tente novamente." : "There is no image of the NPC (" functionValues.1 ") in the Script Images.`nAdd the Script image with the NPC ""Category"" and try again."
        }
    }

    validate_log(functionValues) {
        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)
    }

    validate_gotolabel(functionValues) {
        if (empty(functionValues.1)) {
            return this.warnEmptyValue(functionValues.1, 1)
        }

        if (functionValues.2 != "" && functionValues.2 != "1" && functionValues.2 != "0") {
            paramN := 2
            return LANGUAGE = "PT-BR" ? "O parâmetro abortar ações (" functionValues[paramN] ") é diferente de 0 ou 1." : "The abort actions param (" functionValues[paramN] ") if different than 0 and 1."
        }
    }

    validate_gotowaypoint(functionValues) {
        if (functionValues.1 = "") {
            return this.warnEmptyValue(functionValues.1, 1)
        }
        if (functionValues.2 != "" && functionValues.2 != "1" && functionValues.2 != "0") {
            try {
                _Validation.string("functionValues.1", functionValues.1)
            } catch {
                return this.warnNotNumber(functionValues.1, 1)
            }
            paramN := 2
            return LANGUAGE = "PT-BR" ? "O parâmetro abortar ações (" functionValues[paramN] ") é diferente de 0 ou 1." : "The abort actions param (" functionValues[paramN] ") if different than 0 and 1."
        }
    }

    validate_imagesearch(functionValues) {
        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)

        if (!scriptImagesObj[functionValues.1]) {
            CavebotGUI.createScriptImagesGUI()
            return "Image """ functionValues.1 """ doesn't exist in the Script Images list."
        }


        paramN := 3
        if (functionValues[paramN] != "") && (functionValues[paramN] < 1 OR functionValues[paramN] > 80) {

            try {
                _Validation.number("functionValues.paramN", functionValues.paramN)
            } catch {
                return this.warnIsNumber(functionValues.paramN, paramN)
            }

            return LANGUAGE = "PT-BR" ? "O parâmetro " paramN " (" functionValues[paramN] ") não está dentro dos valores permitidos(de 1 a 80)." : "The param " paramN " (" functionValues[paramN] ") must be between the allowed values(from 1 to 80)."
        }
    }

    validate_telegrammessage(functionValues) {
        if (containsSpecialCharacter(string) = true)
            return "The message can't contain any special character, just letters and numbers."
        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)
    }

    validate_traytip(functionValues) {
        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)
    }

    validate_messagebox(functionValues) {
        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)
    }

    validate_mousemove(functionValues) {
        ; try {
        ;     _Validation.number("functionValues.1", functionValues.1)
        ; } catch {
        ;     return this.warnIsNumber(functionValues.1, 1)
        ; }
        ; try {
        ;     _Validation.number("functionValues.2", functionValues.2)
        ; } catch {
        ;     return this.warnIsNumber(functionValues.2, 2)
        ; }
    }

    validate_mousedrag(functionValues) {
        if (functionValues.1 < 1)
            return this.warnNotNumber(functionValues.1, 1)
        if (functionValues.2 < 1)
            return this.warnNotNumber(functionValues.2, 2)
        if (functionValues.3 < 1)
            return this.warnNotNumber(functionValues.3, 3)
        if (functionValues.4 < 1)
            return this.warnNotNumber(functionValues.4, 4)
        if (functionValues.5 != "") {
            if (functionValues.5 < 1)
                return this.warnLowerThanOne(functionValues.5, 5)
        }
    }

    validate_mousedragitem(functionValues) {
        Loop, 2 {
            if (functionValues[A_Index] = "")
                return this.warnEmptyValue(functionValues[A_Index], A_Index)

            if (this.isVariableString(functionValues[A_Index]) = true)
                continue

            /*
            $HPType = getuseroption(potion)
            mousedragitem($HPType, backpack, 10, 100)
            */
            if (functionValues[A_Index] = -1)
                continue

            if (!itemsImageObj[functionValues[A_Index]])
                return "Item """ functionValues[A_Index] """ param " A_Index " doesn't exist in the items list"

        }


        if (functionValues.3 != "") {
            if (functionValues.3 < 1)
                return this.warnLowerThanOne(functionValues.3, 3)
        }
        ; if (functionValues.4 != "") && (functionValues.4 < 1 OR functionValues.4 > 80) {
        ;     if functionValues.4 is not number
        ;         return this.warnNotNumber(functionValues.4, 4)
        ;     paramN := 4
        ;     return LANGUAGE = "PT-BR" ? "O parâmetro " paramN " (" functionValues[paramN] ") não está dentro dos valores permitidos(de 1 a 80)." : "The param " paramN " (" functionValues[paramN] ") must be between the allowed values(from 1 to 80)."
        ; }
    }

    validate_mousedragitemposition(functionValues) {

        paramN := 1
        if (functionValues[paramN] = "")
            return this.warnEmptyValue(functionValues[paramN], paramN)


        if (functionValues[paramN] = -1)
            return

        if (!itemsImageObj[functionValues[paramN]])
            return "Item """ functionValues[paramN] """ param " paramN " doesn't exist in the items list"

        if (functionValues.2 < 1)
            return this.warnLowerThanOne(functionValues.2, 2)

        if (functionValues.3 < 1)
            return this.warnLowerThanOne(functionValues.3, 3)

        if (functionValues.4 != "") {
            if (functionValues.4 < 1)
                return this.warnLowerThanOne(functionValues.4, 4)
        }

        if (functionValues.5 != "") && (functionValues.5 < 1 OR functionValues.5 > 80) {
            paramN := 5
            return LANGUAGE = "PT-BR" ? "O parâmetro " paramN " (" functionValues[paramN] ") não está dentro dos valores permitidos(de 1 a 80)." : "The param " paramN " (" functionValues[paramN] ") must be between the allowed values(from 1 to 80)."
        }
    }

    validateHotkey(hotkey) {
        if (InStr(hotkey, "{") or  InStr(hotkey, "}"))
            throw Exception(LANGUAGE = "PT-BR" ? "Não é permitido/necessário colocar os caractéres ""{"" e ""}"" na tecla para pressionar." : "It is not allowed/necessary to put the ""{"" and ""}"" characters in the key to press.")


        allowed_character := false
        ; if (InStr(hotkey, "Num"))
        ; Throw Exception(LANGUAGE = "PT-BR" ? "Hotkeys com Numpad não são permitidas." : "Hotkeys with Numpad are not allowed.")
        if (RegExMatch(hotkey,"(Caps|Tab|Back|Space)"))
            Throw Exception(LANGUAGE = "PT-BR" ? "Hotkey inválida." : "Invalid hotkey.")
        if (InStr(hotkey, "^"))
            allowed_character := true
        if (InStr(hotkey, "+"))
            allowed_character := true
        if (InStr(hotkey, "!"))
            allowed_character := true
        if (InStr(hotkey, "$"))
            allowed_character := true
        if (InStr(hotkey, "-1")) ;  for some reason when using variable is getting -1
            allowed_character := true

        special_char := containsSpecialCharacter(hotkey)

        if (special_char =  1) && (allowed_character = false)
            Throw Exception(LANGUAGE = "PT-BR" ? "Caractéres especiais não são permitidos como hotkey." : "Special characters are not allowed as hotkey.")
    }

    /*
    se for uma pressionar_tecla(), checar se a hotkey passa nas validações
    */
    validate_presskey(functionValues) {
        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)

        if (functionValues.3 && functionValues.2 < 1)
            return this.warnNotNumber(functionValues.2, 2)

        if (functionValues.3 != "") {
            if (functionValues.3 < 1)
                return this.warnLowerThanOne(functionValues.3, 3)
        }

        try this.validateHotkey(functionValues.1)
        catch e
            return e.Message
    }

    validate_removemonsterfromlist(functionValues) {
        if (functionName = "") {
            if (functionValues.1 = "")
                return this.warnEmptyValue(functionValues.1, 1)
        }
    }

    validate_runahkscript(functionValues) {
        if (functionValues.1 = "") {
            return this.warnEmptyValue(functionValues.1, 1)
        }
        script_dir := "AHK Scripts\" functionValues.1 "\" functionValues.1 ".ahk"
        if !FileExist(script_dir) {
            return LANGUAGE = "PT-BR" ? "Não existe o AHK Script com o nome do parâmetro(" functionValues.1 ") em " script_dir "." : "The AHK Script with the param name (" functionValues.1 ") doesn't exist on " script_dir "."
        }
    }

    validate_runcommand(functionValues) {
        if (functionValues.1 = "") {
            return this.warnEmptyValue(functionValues.1, 1)
        }
    }

    validate_setsetting(functionValues, tabName := "", waypointNumber := "") {

        if (!InStr(functionValues.1, "/"))
            return "Wrong setting path format."
        settingPath := StrSplit(functionValues.1, "/")

        if (settingPath.1 = "")
            return "Empty setting settingPath."

        lastChildNumber := settingPath.Count() - 1
        /*
        allow empty value
        */
        ; if (functionValues.2 = "")
        ; return "Empty value."

        mainSetting := settingPath.1

        /*
        validation if the main setting exists/is valid to use
        */
        switch mainSetting {
                /*
                this setting only exists and have value when the cavebot system starts,
                so there is no need to validate it
                */
            case "cavebotSystem", case "targetingSystem": return
            default:
                if (!%mainSetting%Obj)
                    return "Setting """ mainSetting """ doesn't exist."
        }

        childSettings := this.createChildSettings(settingPath, tabName, waypointNumber)


        ; msgbox, % serialize(settingPath) "`n`n" serialize(childSettings)

        ; msgbox, % mainSetting "`n.`n" childSettings.1 "`n" childSettings.2 "`n" childSettings.3 "`n" childSettings.4 "`n" childSettings.5

        ; msgbox, % serialize(lootingObj[childSetting1])
        ; msgbox, % serialize(%mainSetting%Obj[childSetting1])
        ; msgbox, % serialize(%mainSetting%Obj[childSetting1][childSetting2])
        validation := this.validateChildSetting(1, mainSetting, childSettings.1, childSettings.2, childSettings.3, childSettings.4, childSettings.5)
        if (validation != "")
            return validation
        validation := this.validateChildSetting(2, mainSetting, childSettings.1, childSettings.2, childSettings.3, childSettings.4, childSettings.5)
        if (validation != "")
            return validation
        validation := this.validateChildSetting(3, mainSetting, childSettings.1, childSettings.2, childSettings.3, childSettings.4, childSettings.5)
        if (validation != "")
            return validation
        validation := this.validateChildSetting(4, mainSetting, childSettings.1, childSettings.2, childSettings.3, childSettings.4, childSettings.5)
        if (validation != "")
            return validation
        validation := this.validateChildSetting(5, mainSetting, childSettings.1, childSettings.2, childSettings.3, childSettings.4, childSettings.5)
        if (validation != "")
            return validation

    }

    validate_say(functionValues) {
        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)
    }

    validate_startlure(functionValues) {
        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)
        if (functionValues.1 < 1) {
            return this.warnLowerThanOne(functionValues.1, 1)
        }

    }

    validate_variaveldecrement(functionValues) {
        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)
        if (functionValues.2 != "") {
            if (functionValues.2 < 1)
                return this.warnLowerThanOne(functionValues.2, 2)
        }
    }

    validate_variavelincrement(functionValues) {
        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)
        if (functionValues.2 != "") {
            if (functionValues.2 < 1)
                return this.warnLowerThanOne(functionValues.2, 2)
        }
    }

    validate_variavelsetvalue(functionValues) {
        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)
        if (functionValues.2 = "")
            return this.warnEmptyValue(functionValues.2, 2)
    }

    validate_turn(functionValues) {
        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)

        possible_values := {}
        possible_values.Push("S")
        possible_values.Push("N")
        possible_values.Push("W")
        possible_values.Push("E")

        is_valid := false
        valid_values := ""
        for key, value in possible_values
        {
            if (valid_values = "")
                valid_values := value
            else
                valid_values :=  valid_values ", " value
            if (functionValues.1 = value) {
                is_valid := true
                return
            }
        }
        if (is_valid = false) {
            paramN := 1
            return (LANGUAGE = "PT-BR" ? "Valor do parâmetro " paramN " (" functionValues[paramN] "), não é um dos valores válidos" : "Value of the first parameter (" functionValues[paramN] "), is not one of the valid values ") "(" valid_values ")."
        }
    }


    /*
    se for uma clicar_sqm(), checar se o valor é um dos valores aceitos
    */
    validate_usesqm(functionValues) {
        try {
            _Validation.string("functionValues.1", functionValues.1)
        } catch {
            return this.warnIsNumber(functionValues.1, 1)
        }

        is_valid := this.isValidSQM(functionValues.1)
        if (is_valid = false) {
            return LANGUAGE = "PT-BR" ? "Valor do primeiro parâmetro(" functionValues.2 "), não é um dos SQMs válidos." : "Value of the first parameter (" functionValues.2 "), is not one of the valid SQMs."
        }
    }

    validate_variable(functionValues) {
        try {
            _Validation.string("functionValues.1", functionValues.1)
        } catch {
            return this.warnIsNumber(functionValues.1, 1)
        }

        if (functionValues.1 = "")
            return this.warnEmptyValue(functionValues.1, 1)

        if (containsSpecialCharacter(functionValues.1) = true)
            return "Special characters are not allowed as variable name."

    }

    validateMouseClick(functionValue, param) {
        if (functionValue != "Left" && functionValue != "Right")
            Throw Exception(LANGUAGE = "PT-BR" ? "Valor do parâmetro " param " (" functionValue "), deve ser ""Right"" ou ""Left""." : "Value of the parameter " param " (" functionValue "), must be ""Right"" or ""Left"".")
    }

    validate_functionName(functionValues) {
        try {
            _Validation.number("functionValues.1", functionValues.1)
        } catch {
            return this.warnNotNumber(functionValues.1, 1)
        }
    }

    validateChildSetting(childNumber, mainSetting, childSetting1 := "", childSetting2 := "", childSetting3 := "", childSetting4 := "", childSetting5 := "") {
        switch childNumber {
            case 1:
                if (childSetting1 = "")
                    return "Empty child setting 1: """ mainSetting "/" childSetting1 """"

                if (!%mainSetting%Obj[childSetting1] && %mainSetting%Obj[childSetting1] != false) {
                    childsString := ""
                    Loop 1
                        childsString .= "/" childSetting%A_Index%
                    return "Setting """ mainSetting childsString """ doesn't exist(child setting: 1)."
                }
            case 2:
                if (childSetting2 != "") && (!%mainSetting%Obj[childSetting1].HasKey(childSetting2)) {
                    childsString := ""
                    Loop 2
                        childsString .= "/" childSetting%A_Index%
                    return "Setting """ mainSetting childsString """ doesn't exist(child setting: 2)."
                }
            case 3:
                if (childSetting3 != "") && (!%mainSetting%Obj[childSetting1][childSetting2].HasKey(childSetting3)) {
                    childsString := ""
                    Loop 3
                        childsString .= "/" childSetting%A_Index%
                    return "Setting """ mainSetting childsString """ doesn't exist(child setting: 3)."
                }
            case 4:
                if (childSetting4 != "") && (!%mainSetting%Obj[childSetting1][childSetting2][childSetting3].HasKey(childSetting4)) {
                    childsString := ""
                    Loop 4
                        childsString .= "/" childSetting%A_Index%
                    return "Setting """ mainSetting childsString """ doesn't exist(child setting: 4)."
                }
            case 5:
                if (childSetting5 != "") && (!%mainSetting%Obj[childSetting1][childSetting2][childSetting3][childSetting4].HasKey(childSetting5)) {
                    childsString := ""
                    Loop 5
                        childsString .= "/" childSetting%A_Index%
                    return "Setting """ mainSetting childsString """ doesn't exist(child setting: 5)."
                }
        }

    }

    createChildSettings(settingPath, currentTab := "", currentWaypoint := "") {
        ; msgbox, % A_ThisFunc "`n" serialize(settingPath)
        vars := {}
        ; validate up to 5 childen setting
        Loop, 5 {
            setting := settingPath[A_Index + 1]

            if (currentTab != "" && currentWaypoint != "") && (this.isVariableString(setting) = true) {
                ; msgbox, % currentTab " / " currentWaypoint
                value := _ActionScriptValidation.getValueFromActionScriptVariable(setting, currentTab, currentWaypoint)
                ; msgbox, % setting " / " value

                /*
                when creating variables to use in setsetting action
                the variable won't exist because the action has not been saved yet
                so search for the variable value in the current action code
                */
                if (value = -1) {
                    value := this.findVariableName(this.actionScriptCode, setting)
                    ; msgbox, % setting " / " value
                }
                setting := value
                ; msgbox, % setting
            }

            vars.Push(setting)
        }
        return vars
    }

    isValidSQM(direction) {
        possible_values := {}
        possible_values.Push("SW")
        possible_values.Push("S")
        possible_values.Push("SE")
        possible_values.Push("W")
        possible_values.Push("C")
        possible_values.Push("E")
        possible_values.Push("NW")
        possible_values.Push("N")
        possible_values.Push("NE")

        is_valid := false
        for key, value in possible_values
        {
            if (direction = value) {
                is_valid := true
                break
            }
        }
        return is_valid
    }

    isNumber(value, defaultValue := 0) {
        if value is number
            return value
        return defaultValue
    }

    validateUserDefinedSearchArea(functionName, params) {
        if (params.x1 < 0)
            return false

        if (params.x2 < params.x1) {
            writeCavebotLog("ERROR", functionName ": Invalid search area, x2 lower than x1. x1: " params.x1 ", x2: " params.x2)
            return false
        }
        if (params.y2 < params.y1) {
            writeCavebotLog("ERROR", functionName ": Invalid search area, y2 lower than y1. y2: " params.y2 ", y2: " params.y2)
            return false
        }
        return true
    }

    warnIsNumber(functionValue, param) {
        return LANGUAGE = "PT-BR" ? "O parâmetro " param " (" functionValue ") da função não pode ser um número." : "The param " param " (" functionValue ") can not be a number"
    }
    warnNotNumber(functionValue, param) {
        return LANGUAGE = "PT-BR" ? "O parâmetro " param " (" functionValue ") da função não é um número." : "The param " param " (" functionValue ") is not a number."
    }

    warnLowerThanOne(functionValue, param) {
        return LANGUAGE = "PT-BR" ? "O parâmetro " param " (" functionValue ") da função é menor do que 1." : "The param " param " (" functionValue ") is lower than 1."
    }

    warnEmptyValue(functionValue, param) {
        return LANGUAGE = "PT-BR" ? "O parâmetro " param " (" functionValue ") da função não pode ser vazio." : "The param " param " (" functionValue ") can not be empty."
    }

} ; Class _ActionScriptValidation
