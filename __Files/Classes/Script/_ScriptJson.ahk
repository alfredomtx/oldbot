Class _ScriptJson extends _ScriptJsonValidation {



    saveScriptVariables(newScriptVariablesObj) {
        scriptFile.scriptVariables := newScriptVariablesObj
        scriptVariablesObj := newScriptVariablesObj
        CavebotScript.saveSettings(A_ThisFunc)
        CavebotScript.createUserOptionVariablesObj()
    }

    submitControl(controlName := "", controlValue := "") {
        try
            this.validateSubmit(controlName)
        catch 
            throw e

        groupName := this.getGroupName(controlName)
        elementName := this.getElementName(controlName)


        ; msgbox, % controlName " = " controlValue
        /**
        get the index number of the gropbox in the scriptVariablesObj array
        */
        groupIndex := ""
        for key, value in scriptVariablesObj
        {
            if (groupName = value.name) {
                groupIndex := key
                break
            }
        }

        ; msgbox, % groupName "`n" elementName "`n" groupIndex

        elementIndex := ""
        for key1, children in scriptVariablesObj[groupIndex]
        {
            for key, value in children
            {
                ; msgbox, % key1 "`n" key "`n" elementName "`n" value.name
                if (elementName = value.name) {
                    elementIndex := key
                    break
                }

            }
        }

        if (scriptVariablesObj[groupIndex]["children"][elementIndex]["name"] != elementName) {
            throw Exception("No children key with name """ elementName """ (" elementIndex ") on group """ groupName """ (" groupIndex ")" )
        }

        try this.validateIfHotkey(groupIndex, elementIndex, controlName, controlValue)
        catch e 
            throw e



        ; msgbox, % serialize(scriptVariablesObj[groupIndex]["children"][elementIndex])
        ; msgbox, % " old value =  " scriptVariablesObj[groupIndex]["children"][elementIndex]["value"]
        scriptVariablesObj[groupIndex]["children"][elementIndex]["value"] := controlValue
        ; msgbox, % " new value =  " scriptVariablesObj[groupIndex]["children"][elementIndex]["value"]
        scriptVariablesObj[groupIndex].Delete("height")
        scriptFile.scriptVariables := scriptVariablesObj
        ; msgbox, % serialize(scriptVariablesObj[groupIndex]["children"][elementIndex])


        CavebotScript.saveSettingsTimer()
        Gui, ScriptVariablesJsonGUI:Destroy

    }

    validateIfHotkey(groupIndex, elementIndex, controlName, controlValue) {
        ; msgbox, % serialize(scriptVariablesObj[groupIndex]["children"][elementIndex])
        if (scriptVariablesObj[groupIndex]["children"][elementIndex].type != "hotkey")
            return

        vars := ValidateHotkey("", controlName, controlValue)
        if (vars.erro > 0)
            throw Exception(vars.msg)

    }

    getElementName(controlName) {
        string := StrSplit(controlName, "__")
        return string.3
    }
    getGroupName(controlName) {
        string := StrSplit(controlName, "__")
        return string.2
    }

} ; Class _ScriptJson

Class _ScriptJsonValidation {




    validateSubmit(controlName) {
        string := StrSplit(controlName, "__")
        if (string.MaxIndex() != 3)
            throw Exception("Wrong element name: " controlName)

        groupName := this.getGroupName(controlName)
        elementName := this.getElementName(controlName)

        this.validateNames(groupName, elementName, controlName)

    }

    validateNames(groupName, elementName, controlName) {
        if (groupName = "")
            throw Exception("Empty group name.`n`Control: " controlName)
        if (elementName = "")
            throw Exception("Empty element name.`n`Control: " controlName)

        if (InStr(groupName, " "))
            throw Exception("Cannot have a Space in the group name.`n`Control: " controlName)

        if (InStr(elementName, " "))
            throw Exception("Cannot have a Space in the element name.`n`Control: " controlName)


    }


    validateUserOptions(newScriptVariablesObj, tempJsonFileDir := "") {
        if (tempJsonFileDir = "") {
            throw Exception("Empty temp JSON file directory.")
        }
        ; msgbox, % A_ThisFunc "`n" serialize(newScriptVariablesObj)
        ; msgbox, % A_ThisFunc


        this.newScriptVariablesObj := newScriptVariablesObj

        createdVariables := {}

        for key1, groupboxObj in newScriptVariablesObj
        {   
            /**
            type: The widget type; "group" in this case.
            name: The name of the widget. It's used to retrieve its current value.
            text: The title of the group box; if none is provided, name is used.
            description: The description to be displayed on info box; if none is provided, text is used.
            checkable: Whether the widget should be checkable; a checkbox will appear beside it and checking/unchecking enables/disables the groupbox and its children.
            column: The column the group box should be place on; 1 for first column, 2 for second.
            children: The widgets the group box will contain.
            */

            stringGroup := "Group: " groupboxObj.name


            ; msgbox, % serialize(groupboxObj) "`n name = " groupboxObj.name "`n description = " groupboxObj.description

            try
                this.validateGroupbox(groupboxObj)
            catch e {
                throw Exception(stringGroup "`n`n" e.Message)
            }

            for key2, children in groupboxObj
            {

                for key3, childrenElements in children
                {
                    stringElement := "Field: " childrenElements.name
                    ; msgbox,% "Group: " groupboxObj.name "`n" serialize(childrenElements) "`n" "`n" serialize(children)
                    ; msgbox, % childrenElements.name

                    /**
                    text element has no variable name
                    */
                    if (childrenElements.type = "text")
                        continue

                    if (childrenElements.name = "") 
                        throw Exception(stringGroup "`n" stringElement "`n`nEmpty variable name.")

                    if (InArray(createdVariables, childrenElements.name))
                        throw Exception(stringGroup "`n" stringElement "`n`nThere is already a variable named """ childrenElements.name """." )

                    createdVariables.Push(childrenElements.name)

                    try this.validateElements(groupboxObj)
                    catch e {
                        throw Exception(stringGroup "`n" stringElement "`n`n" e.Message)
                    }

                }


            }

        }


        this.validateReadableJSON(newScriptVariablesObj)

    }

    validateReadableJSON(newScriptVariablesObj, tempJsonFileDir) {
        FileDelete, %tempJsonFileDir%
        scriptVariablesFile := ""
        scriptVariablesFile := new JSONFile(tempJsonFileDir)
        scriptVariablesFile.Fill(newScriptVariablesObj)
        scriptVariablesFile.Save(true)

        ; read the JSOn file again to see if there is some syntax error
        scriptVariablesFile := ""
        if (!FileExist(tempJsonFileDir))
            throw Exception("JSON file doesn't exist: " tempJsonFileDir)
        try
            scriptVariablesFile := new JSONFile(tempJsonFileDir)
        catch, e {
            Run, https://jsonlint.com/
            Sleep, 1000
            FileRead, fileContent, % tempJsonFileDir
            try {
                ClipBoard := fileContent
                Send, ^v
            }
            catch {
            }
            throw Exception("Error loading JSON.`nProbably there are syntax erros in the file, copy its contents into JSONLint to check.`n`nError details:`n" e.Message "`n`n" e.What "`n`n" e.Extra)
        }
        scriptVariablesFile := ""
        FileDelete, %tempJsonFileDir%
    }


    validateGroupbox(groupbox) {
        try this.validateGroupType(groupbox.type)
        catch e 
            throw e

        if (!groupbox.HasKey("name"))
            throw Exception("Missing atribute ""name"".")
        try this.validateGroupName(groupbox.name)
        catch e 
            throw e

        try this.validateGroupText(groupbox.text)
        catch e 
            throw e

        try this.validateGroupDescription(groupbox.description)
        catch e 
            throw e

        try this.validateGroupCheckable(groupbox.checkable)
        catch e 
            throw e

        try this.validateGroupColumn(groupbox.column)
        catch e 
            throw e

        try this.validateGroupChildren(groupbox.children)
        catch e 
            throw e
    }

    validateGroupType(groupType := "") {

    }   
    validateGroupName(groupName := "") {
        if (groupName = "")
            throw Exception("Empty groupbox name.")

        this.validateGroupboxName(groupName)
        /**
        validate if there is already a groupbox with the same name
        if there is, will find more than 1 index
        */
        groupIndex := {}
        for key, value in this.newScriptVariablesObj
        {
            if (groupName = value.name) {
                groupIndex.Push(key)
            }
        }

        if (groupIndex.Count() > 1) {
            throw Exception("There are " groupIndex.Count() " groupboxes with the same ""name"" atribute """ groupName """.`nThe name atribute must be unique.")
        }


    }
    validateGroupText(groupText := "") {

    }
    validateGroupDescription(groupDescription := "") {

    }
    validateGroupCheckable(groupCheckable := "") {

    }
    validateGroupColumn(groupColumn := "") {

    }
    validateGroupChildren(groupChildren := "") {

    }

    validateElements(groupboxObj) {

        for children, childrenObj in groupboxObj
        {
            for key, elementsObj in childrenObj
            {

                for elementName, elementValue in elementsObj
                {
                    switch elementName {
                            /**
                            variable name
                            */
                        case "name":
                            if (InStr(elementValue, " "))
                                throw Exception("Variable ""name"" can't have ""Space"" characters.`nname: " elementValue)
                    }
                    ; Msgbox % elementName " = " elementValue "`n" serialize(elementValue)

                }

            }
        }

    }





}
