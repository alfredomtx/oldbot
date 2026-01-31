#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_GUI.ahk


class _ActionScriptGUI extends _GUI
{
    static INSTANCE

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?string title
    */
    __New(tabName := "", waypoint := "", code := "")
    {
        tabName := tabName ? tabName : tab
        waypoint := waypoint ? waypoint : selectedWaypointEdit
        code := code ? code : WaypointHandler.getAtribute("action", waypoint)

        if (_ActionScriptGUI.INSTANCE) {
            instance := _ActionScriptGUI.INSTANCE

            instance.setData(tabName, waypoint, code)
            instance.updateCode(code)
            instance.show(instance.getWindowTitle())

            return instance
        }

        this.setData(tabName, waypoint, code)


        base.__New("actionScript", "Action Script")

        this.iniName("actionScript")
        this.title(this.getWindowTitle())

        this.guiW := 700
        this.guiH := 500
        this.textW := 100

        this.rightW := 150
        this.editW := this.guiW - this.rightW - 25
        this.editH := this.guiH - 100


        this.onCreate(this.create.bind(this))
            .afterCreate(this.after.bind(this))
            .y(10).w(this.guiW).h(this.guiH)
        ; .withoutMinimizeButton()
        ; .alwaysOnTop()
        ; .withoutWindowButtons(

        _ActionScriptGUI.INSTANCE := this
    }

    open()
    {
        if (this.isCreated()) {
            return this
        }

        return base.open()
    }

    getWindowTitle()
    {
        return "Action Script - " this.waypoint " (" this.tab ")"
    }

    setData(tab, waypoint, code)
    {
        this.waypoint := waypoint
        this.tab := tab
        this.waypointCode := code
    }

    destroy(resetCreated := true)
    {
        this.hide()
    }

    /**
    * @return void
    */
    createControls()
    {
        this.top()
        Gui, Font, s11

        this.code := new _Edit()
            .name("code")
            .x(10).yadd(5).w(this.editW).h(this.editH)
            .add()
        Gui, Font

        this.right()
    }

    top()
    {
        h := 50
        w := 60
        w2 := 100

            new _Button().title("Salvar", "Save")
            .x(10).y(5).w(80).h(h)
            .event(this.saveActionScript.bind(this))
            .icon(_Icon.get(_Icon.CHECK), "a0 l5 s24 b0 t1")
            .tt(txt("Salvar", "Save") " action script`n[ Ctrl + S ]")
            .add()

            new _Button().title("Salvar`n&& Fechar", "Save`n&& Close")
            .x().yp().w(w).h(h)
            .event(this.saveAndClose.bind(this))
            .tt(txt("Salvar", "Save") " action script`n[ Ctrl + S ]")
            .add()

            new _Button().title("Script`nImages")
            .x().yp().w(w2).h(h)
            .tt("Visualizar e gerenciar as imagens do script`nImagens pode ser usadas em várias funções no bot, tal como as Action Scripts clickonimage() e imagesearch().", "View and manage images of the script`nImages can be used on many functions in the bot, such as Action Scripts such as clickonimage() and imagesearch().")
            .event("ScriptImagesGUI")
            .icon(_Icon.get(_Icon.IMAGE), "a0 l5 s24 b0 t1")
            .add()

            new _Button().title("Obter ""x, y""`nparams", "Get X, Y`nparams")
            .x().yp().w(w2).h(h)
            .tt("Capturar as coordenadas x e y do mouse na janela do cliente do Tibia.`nAs coordenadas ficam salvas no Clipboard(Ctrl+V).", "Capture the x and y coordinates of the mouse on the Tibia client window.`nThe coordinates are saved in the Clipboard(Ctrl+V).")
            .icon(_Icon.get(_Icon.MOUSE_POINTER), "a0 l5 s24 b0 t1")
            .event(this.getMouseCoordinatesAction.bind(this))
            .add()

            new _Button().title("Abrir`nDocumentação", "Open`nDocumentation")
            .x().yp().w(115).h(h)
            .event("OldBotDocsLink")
            .icon(_Icon.get(_Icon.EXCLAMATION), "a0 l5 s24 b0 t1")
            .add()

            new _Button().title(lang("open") "`nWindow Spy")
            .x().yp().w(80).h(h)
            .event("OpenWindowSpy")
            .add()

            new _Groupbox().title("")
            .x(10).yadd(1).w(766).h(8)
            .color("black")
            .add()
    }

    right()
    {
            new _Checkbox().title("Add Action com exemplos", "Add Action with examples")
            .name("addActionWithExamples")
            .state(_CavebotIniSettings)
            .x().yp()
        ; .event()
            .add()

        this.filter := new _Edit()
            .name("filter")
            .xp().y().w(this.rightW).h(18)
            .event(this.filterActions.bind(this))
            .placeholder("Pesquisar action...", "Search action...")
            .add()

        this.actionsList := new _Listbox()
            .name("actionsList")
            .xp().y().w(this.rightW).h(this.editH - 40)
            .event(this.selectAction.bind(this))
            .add()
    }

    updateCode(code)
    {
        this.code.set(this.sanitizeCode(code))
    }

    selectAction()
    {
        global ActionScriptNew
        global ActionScriptList := this.actionsList.get()
        global actionScriptCode := this.code.get()
        gosub, UseActionScriptNew

        this.updateCode(ActionScriptNew)

        try {
            SendMessage, 0x0115, 7, 0,, % "ahk_id " this.code.getHwnd()
        } catch {
        }

    }

    filterActions()
    {
        this.actionsList.list(this.getActionsList(this.filter.get()))
    }

    /**
    * @return array<_ListOption>
    */
    getActionsList(filter := "")
    {
        list := {}

        actionScriptsList := ""
        for key, value in action_scripts
        {
            uncompatible := false
            for key, action in CavebotSystem.cavebotJsonObj.uncompatibleActions
            {
                if (value = action) {
                    uncompatible := true
                    break
                }
            }

            if (filter != "") && (!InStr(value, filter))
                continue
            if (value = "m")
                continue

            list.Push(new _ListOption(value "()" (uncompatible = true ?  ActionScript.uncompatibleString : "") ))
        }

        return list
    }


    /**
    * @abstract
    * @return void
    */
    create()
    {
        _AbstractControl.SET_DEFAULT_GUI(this)

        this.createControls()

        _AbstractControl.RESET_DEFAULT_GUI()
    }

    /**
    * @return void
    */
    after()
    {
        this.updateCode(this.waypointCode)
        this.actionsList.list(this.getActionsList())
    }

    sanitizeCode(code)
    {
        return StrReplace(code, "<br>", "`n")
    }

    saveActionScript()
    {
        if (!this.waypoint) {
            Msgbox, 48,, No Action Script waypoint selected.
            return
        }

        ; setSystemCursor("IDC_WAIT")
        ; SetListView()

        switch (this.tab) {
            case "persistent": 
                this.saveActionScriptPersistent()
            case "hotkey": 
                this.saveActionScriptHotkey()
            default:
                this.saveActionScriptWaypoint() 
        }

        ; restoreCursor() 
    }

    saveAndClose()
    {
        this.saveActionScript()
        this.close()
    }

    saveActionScriptWaypoint()
    {
        ; msgbox, %  actionScriptCode "," actionScriptWaypoint "," actionScriptTab

        try
            WaypointHandler.editAtribute("action", this.code.get(), this.waypoint, this.tab)
        catch e {
            ; Msgbox, 52,, % e.Message (LANGUAGE = "PT-BR" ? "`n`nContinuar edição?" : "`n`nContinue editing?")
            Msgbox, 48,, % e.Message
        }

        CavebotGUI.loadLV()
    }

    saveActionScriptHotkey()
    {
        hotkeysObj[this.waypoint].actionScript := WaypointValidation.formatActionToSave(this.code.get(), "Hotkey")
        HotkeysHandler.saveHotkeys()
    }

    saveActionScriptPersistent()
    {
        persistentObj[this.waypoint].actionScript := WaypointValidation.formatActionToSave(this.code.get(), "Persistent")
        PersistentHandler.savePersistent()
    }


    abordGetMouseCoordsAction()
    {
        CoordMode, Mouse, Screen
        ToolTip
    }

    checkTibiaWindowFocused()
    {
        Loop {
            if (GetKeyState("Esc") = true)
                return false

            WinGetClass, class, A
            if (InStr(class, OldbotSettings.settingsJsonObj.tibiaClient.windowClassFilter))
                break

            Tooltip, % txt("Clique na janela do Tibia para ativá-la.`n""Esc"" para abortar.", "Click in the Tibia window to activate it.`n""Esc"" to abort.")
            Sleep, 50
        }

        return true
    }

    getMouseCoordinatesAction()
    {
        WinActivate()
        sleep, 100
        this.checkTibiaWindowFocused()

        CoordMode, Mouse, Relative
        Loop {
            if (GetKeyState("Esc") = true)
                return false

            MouseGetPos, x, y
            Tooltip, % ("x: " x ", y: " y) txt("`nClique ou pressione ""Space"".`n""Esc"" para abortar.", "`nClick or press ""Space"".`n""Esc"" to abort.")

            if (GetKeyState("LButton") = true)
                break

            if (GetKeyState("Space") = true)
                break
            Sleep, 25
        }

        ToolTip

        copyToClipboard(x ", " y)

        Gui, ActionScriptGUI:Show
        Sleep, 50

        _ActionScriptGUI.INSTANCE.code.focus()
        Sleep, 50
        Send, ^{v}

        return true
    }

}