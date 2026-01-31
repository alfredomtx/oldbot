

moduleUploadSelect:
    Gui, ScriptAtributesGUI:Submit, NoHide
    module := StrReplace(A_GuiControl, "module", "")
    IniWrite, % %A_GuiControl%, %DefaultProfile%, script_upload, % module
return


moduleSelectAll:
    GuiControlGet, moduleSelectAll

    for key, module in ScriptListGUI.objectsList
    {
        GuiControl, ScriptAtributesGUI:, module%module%, % moduleSelectAll
        IniWrite, % moduleSelectAll, %DefaultProfile%, script_upload, % module
    }

return


LimparNomeScript:
    NomeScript := ""
    PesquisarLV_Scripts := ""
    GuiControl, CavebotGUI:, NomeScript, %NomeScript%
    GuiControl, CavebotGUI:, PesquisarLV_Scripts, %PesquisarLV_Scripts%
return


CreateNewScriptFromMenu:
    InputBox, NewScriptName, % "Create Cavebot Script", % "The new script will be created with all the default settings(reseted).`n`nScript name:",,300,175
    if ErrorLevel = 1
        return
    if (NewScriptName = "") {
        Msgbox, 48,, % "Write a name for the script to save."
    return
}
try
    CavebotScript.createNewScript(NewScriptName)
catch e {
    if (A_IsCompiled)
        Msgbox, 48,, % e.message
    else
        Msgbox, 48,, % e.message "`n" e.What "`n" e.File "`n" e.Line "`n`n" serialize(e)
    return
}
Gui, Carregando:Destroy
Goto, CavebotGUI
return

SaveScriptAsNew:
    try selectedScript := ScriptListGUI.getSelectedScript()
    catch 
    return

InputBox, NewScriptName, % "Save selected script as... (" selectedScript ")", % "The selected script will be copied to the creating a new script with other name.`n`nNew Script name:",,350,175, x:="", y:="",,, % selectedScript
if ErrorLevel = 1
    return
if (NewScriptName = "") {
    Msgbox, 48,, % "Write a name for the script to save."
    return
}
CavebotScript.saveScriptAs(selectedScript, NewScriptName)
return


OpenScript:
    try selectedScript := ScriptListGUI.getSelectedScript()
    catch 
    return

try 
    Run, % "Cavebot\" selectedScript ".json"
catch, {
    msgbox, 48,, % "Error opening script file: Cavebot\" selectedScript ".json"
}
return

CleanScriptName:
    scriptManageName := ""
    scriptNameSearch := ""
    GuiControl, ScriptListGUI:, scriptManageName, %scriptManageName%
    GuiControl, ScriptListGUI:, scriptNameSearch, %scriptNameSearch%
    ScriptListGUI.filterLV_Scripts()
return


ImportCavebotScript:
    try CavebotScript.importScript()
    catch e {
        if (e.What = "aborted")
            return
        Msgbox, 48,, % e.Message
    return
}
selectedScript := StrReplace(selectedScript, ".json", "")
if (selectedScript = "")
    return

gosub, LoadSelectedScriptFromHotkey
ScriptListGUI.filterLV_Scripts()

return

downloadSelectedScript:
    GuiControl, ScriptListGUI:Disable, downloadSelectedScript
    GuiControl, ScriptListGUI:, downloadSelectedScript, % "Downloading..."
    ScriptCloud.downloadScript()

    enableButtonTimer := Func("enableButton").bind("ScriptListGUI", "downloadSelectedScript", "Download script")
    SetTimer, % enableButtonTimer, Delete
    SetTimer, % enableButtonTimer, -300
return

updateScriptsList:
    GuiControl, ScriptListGUI:Disable, updateScriptList
    GuiControl, ScriptListGUI:, updateScriptList, % "Updating..."
    ScriptCloud.updateScriptList(true)

    enableButtonTimer := Func("enableButton").bind("ScriptListGUI", "updateScriptList", txt("Atualizar lista", "Update list"))
    SetTimer, % enableButtonTimer, Delete
    SetTimer, % enableButtonTimer, -300
return 

selectVocationScript:
    Gui, ScriptAtributesGUI:Submit, NoHide

    atributeValue := %A_GuiControl%
    %A_GuiControl%Atribute := atributeValue
    IniWrite, % atributeValue, %DefaultProfile%, script_list_atributes, % A_GuiControl "Atribute"
    ; m(A_GuiControl " = " atributeValue)



    switch A_GuiControl {
        case "vocationAll":
            GuiControlGet, vocationAll
            for key, vocation in ScriptListGUI.vocationList
            {
                if (vocation = "All")
                    continue
                ; msgbox, % vocationAll "`n" vocation
                if (vocationAll = 1) {
                    GuiControl, ScriptAtributesGUI:, % "vocation" vocation, 1
                    GuiControl, ScriptAtributesGUI:Disable, % "vocation" vocation

                } else {
                    GuiControl, ScriptAtributesGUI:, % "vocation" vocation, 0
                    GuiControl, ScriptAtributesGUI:Enable, % "vocation" vocation
                }
            }
    }


return


uploadSelectedScript:
    ScriptCloud.uploadScriptName := {}
    ; msgbox, % A_ThisLabel
    ; msgbox, % serialize(ScriptListGUI)
    ScriptListGUI.createScriptAtributesGUI()
return


ScriptAtributesGUIGuiEscape:
ScriptAtributesGUIGuiClose:
    Gui, ScriptAtributesGUI:Destroy
return

submitUploadScript:
    ScriptCloud.uploadScript()
return

LoadSelectedScript:
    try {
        selectedScript := ScriptListGUI.getSelectedScript()
    } catch {
    return
}
LoadSelectedScriptFromHotkey:
    Gui, CavebotGUI:Destroy
    ; Gosub, CavebotGUIGuiClose
    CavebotScript.loadScript(selectedScript)
    CavebotGUI.closeCavebotChildWindows()
    Gosub, CavebotGUI
    if (CavebotScript.scriptHasBackup() = false) {
        CavebotScript.backupScript()
        CavebotScript.checkScriptBackups()
    }

    CavebotScript.deleteAllTempScriptFiles()

return

DeleteSelectedScript:
    gotoCavebotGUI := CavebotScript.deleteScript()
    if (gotoCavebotGUI = true)
        Goto, CavebotGUI
return



;ScriptListGUI:
ScriptListGUIToScriptCloud:
    global chooseScriptCloudTab := true
ScriptListGUI:
    ScriptListGUI.createScriptListGUI()
    if (chooseScriptCloudTab = true) {
        GuiControl, ScriptListGUI:Choose, ScriptsListTab, % "Scripts Cloud"

        global chooseScriptCloudTab := false
    }
return
ScriptListGUIGuiEscape:
ScriptListGUIGuiClose:
    Gui, ScriptListGUI:Destroy
return

LV_Scripts:
    switch A_GuiEvent {
        Case "Normal":
            selectedScript :=  _ListviewHandler.getSelectedItemOnLV("LV_Scripts", 2, "ScriptListGUI")
            if (selectedScript = "" OR selectedScript = "Name")
                return
            scriptManageName := selectedScript
            GuiControl, ScriptListGUI:, scriptManageName, %scriptManageName%
        Case "DoubleClick":
            goto, LoadSelectedScript
    }
return


LV_ScriptsCloud:
    switch A_GuiEvent {
        Case "Normal":
            selectedScript :=  _ListviewHandler.getSelectedItemOnLV("LV_ScriptsCloud", 2, "ScriptListGUI")
            if (selectedScript = "" OR selectedScript = "Name")
                return
            scriptManageName := selectedScript
            GuiControl, ScriptListGUI:, scriptManageName, %scriptManageName%
        Case "DoubleClick":
            goto, LoadSelectedScript
    }
return


applyFilterScriptList:
    Gui, ScriptListGUI:Submit, NoHide
    filterName := StrReplace(A_GuiControl, "LV_Scripts", "")
    filterName := StrReplace(filterName, "Cloud", "")
    filterLV := StrReplace(A_GuiControl, filterName, "")

    filterValue := %A_GuiControl%
    filterName := StrReplace(filterName, "Filter", "")


    IniWrite, % filterValue, %DefaultProfile%, script_list_filters, % A_GuiControl
    ; m(A_GuiControl " = " filterValue)



    if (InStr(filterName, "vocation")) {
        if (filterName = "vocationAll") {
            GuiControlGet, vocationAllFilter%filterLV%
            for key, vocation in ScriptListGUI.vocationList
            {
                if (vocation = "All")
                    continue
                ; msgbox, % vocationAll "`n" vocation
                if (vocationAllFilter%filterLV% = 1) {
                    GuiControl, ScriptListGUI:, vocation%vocation%Filter%filterLV%, 1
                    GuiControl, ScriptListGUI:Disable, vocation%vocation%Filter%filterLV%

                } else {
                    GuiControl, ScriptListGUI:, vocation%vocation%Filter%filterLV%, 0
                    GuiControl, ScriptListGUI:Enable, vocation%vocation%Filter%filterLV%
                }
            }
        }
        ; msgbox, % A_GuiControl "`n" filterName "`n" filterValue "`n" filterLV
        ScriptListGUI.applyFilterCondition(filterLV, filterName, filterValue)
    } else { 
        SetTimer, applyFilterTimer, Delete
        SetTimer, applyFilterTimer, -200
    }

return

saveScriptAtribute:
    Gui, ScriptAtributesGUI:Submit, NoHide
    atributeValue := %A_GuiControl%
    ; m(A_GuiControl " = " atributeValue)
    %A_GuiControl%Atribute := atributeValue
    IniWrite, % atributeValue, %DefaultProfile%, script_list_atributes, % A_GuiControl "Atribute"
return

applyFilterTimer:
    ScriptListGUI.applyFilterCondition(filterLV, filterName, filterValue)
return


SearchScript:
    ; msgbox, % %A_GuiControl%
    Gui, ScriptListGUI:Submit, NoHide
    scriptNameSearch := %A_GuiControl%
    searchLV := StrReplace(A_GuiControl, "scriptNameSearch", "")
    SetTimer, SearchScriptTimer, Delete
    SetTimer, SearchScriptTimer, -200
return

SearchScriptTimer:
    IniWrite, % scriptNameSearch%searchLV%, %DefaultProfile%, script_list_filters, % "scriptNameSearch" searchLV

    ScriptListGUI.applyFilterCondition(searchLV, "name", scriptNameSearch)
return
