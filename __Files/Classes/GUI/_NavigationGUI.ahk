
class _NavigationGUI
{
    static ACTION_HOTKEYS := 3

    static HOTKEY_WALK_COMMAND := "walkCommandHotkey"
    static HOTKEY_STAND_COMMAND := "standCommandHotkey"
    static HOTKEY_USE_COMMAND := "useCommandHotkey"
    static HOTKEY_USE_ROPE_COMMAND := "useRopeCommandHotkey"
    static HOTKEY_USE_SHOVEL_COMMAND := "useShovelCommandHotkey"
    static HOTKEY_ACTION_1_COMMAND := "action1CommandHotkey"
    static HOTKEY_ACTION_2_COMMAND := "action2CommandHotkey"
    static HOTKEY_ACTION_3_COMMAND := "action3CommandHotkey"

    __New()
    {
        static INSTANCE
        if (INSTANCE)
        {
            return INSTANCE
        }

        this.settings := new _NavigationSettings()

        INSTANCE := this
    }

    /**
    * @return void
    */
    postCreate()
    {
        this.updateWindowsList()

        _HotkeyRegister.register(this.settings.get(this.HOTKEY_WALK_COMMAND), _Navigation[this.HOTKEY_WALK_COMMAND].bind(_Navigation), this.HOTKEY_WALK_COMMAND)
        _HotkeyRegister.register(this.settings.get(this.HOTKEY_STAND_COMMAND), _Navigation[this.HOTKEY_STAND_COMMAND].bind(_Navigation), this.HOTKEY_STAND_COMMAND)
        _HotkeyRegister.register(this.settings.get(this.HOTKEY_USE_COMMAND), _Navigation[this.HOTKEY_USE_COMMAND].bind(_Navigation), this.HOTKEY_USE_COMMAND)
        _HotkeyRegister.register(this.settings.get(this.HOTKEY_USE_ROPE_COMMAND), _Navigation[this.HOTKEY_USE_ROPE_COMMAND].bind(_Navigation), this.HOTKEY_USE_ROPE_COMMAND)
        _HotkeyRegister.register(this.settings.get(this.HOTKEY_USE_SHOVEL_COMMAND), _Navigation[this.HOTKEY_USE_SHOVEL_COMMAND].bind(_Navigation), this.HOTKEY_USE_SHOVEL_COMMAND)

        loop, % this.ACTION_HOTKEYS {
            controlName := this["HOTKEY_ACTION_" A_Index "_COMMAND"]

            _HotkeyRegister.register(this.settings.get(controlName), _Navigation.actionCommandHotkey.bind(_Navigation, A_Index), controlName)
        }
    }

    createNavigationGUI()
    {
        global

        main_tab := "Navigation"
        child_tabs_%main_tab% := "Settings"

        Gui, CavebotGUI:Add, Tab2, x6 vTab_%main_tab% y%y_tab% w%tabsWidth% h%tabsHeight% hWndhTab_%main_tab% %TabStyle% +Theme, % child_tabs_%main_tab%
        if (load_order[1] != main_tab)
            GuiControl, Hide, Tab_%main_tab% ; esconder a tab antes de adicionar os elementos a ela

        Loop, parse, child_tabs_%main_tab%, |
        {
            current_child_tab := A_LoopField
            ; msgbox, % child_tabs_%main_tab%
            Gui, CavebotGUI:Tab, %current_child_tab%
            switch current_child_tab
            {
                case "Settings":
                    this.create()
            }
        }
    }

    isDisabled() {
        return !CavebotScript.isCoordinate() || !CavebotScript.isMemoryCoords()
    }

    /**
    * @return this
    */
    create()
    {
        w := tabsWidth - 20
        this.h := tabsHeight - 75
        this.topY := 58

        this.halfW := w / 2 - 5

            new _Groupbox()
            .x(15).y(this.topY).w(this.halfW).h(this.h)
            .option("Section")
            .add()

        this.disabledMemoryCoordinate := this.isDisabled()

        _Navigation.CHECKBOX := new _Checkbox().name(_Navigation.CHECKBOX_NAME)
            .title("Leader Enabled")
            .tt("Ativar/desativar o envio das coordenadas atuais do Leader para o Follower(seguidor).", "Enable/disable sending the current Leader's position to the Follower.")
            .x("s+10").y("s+0")
            .disabled(this.disabledMemoryCoordinate)
            .state(_NavigationSettings)
            .event(_Navigation.toggle.bind(_Navigation))
            .add()

        if (this.disabledMemoryCoordinate)
        {
                new _Text().title("Habilite o ""Modo de Coordenadas"" para usar o Navigation.", "Enable the ""Coordinates Mode"" to use the Navigation.")
                .x("+5").y("p+0")
                .color("red")
                .add()
        }

        this.hotkeyTooltip := txt("Hotkey de atalho para enviar a ação.", "Shortcut hotkey to send the action.")

        this.actionsSection()
        this.optionsSection()
        this.followerSection()

        _GuiHandler.tutorialButtonModule("Navigation")

        return this
    }

    actionsSection()
    {
        this.buttonsW := 120
        this.hotkeysW := 110

            new _Groupbox().title("Ações", "Actions")
            .x("s+10").y("+5").w(this.halfW - 20).h(225)
            .add()

        this.walk()
        this.stand()
        this.use()
        this.useRope()
        this.useShovel()

        loop, % this.ACTION_HOTKEYS {
            this.action(A_Index)
        }
    }

    walk()
    {
            new _Button().title("Walk")
            .x("s+20").y("p+18").w(this.buttonsW)
            .tt(txt("Enviar o comando de ""Walk"" para o Follower andar até o SQM definido.", "Send the ""Walk"" command to the Follower to walk to the defined SQM."))
            .disabled(this.disabledMemoryCoordinate)
            .event(_Navigation.walkCommand.bind(_Navigation))
            .add()

            new _Text().title("Hotkey:")
            .x("+5").y("p+5")
            .add()

        this[this.HOTKEY_WALK_COMMAND] := new _Hotkey().name(this.HOTKEY_WALK_COMMAND)
            .x("+3").y("p-3").w(this.hotkeysW)
            .tt(this.hotkeyTooltip)
            .state(_NavigationSettings)
            .event(this.getWalkHotkeyEvent())
            .add()
    }

    stand()
    {
            new _Button().title("Stand")
            .x("s+20").y("+2").w(this.buttonsW)
            .tt(txt("Enviar o comando de ""Stand"" para o Follower andar até o SQM definido.", "Send the ""Stand"" command to the Follower to walk to the defined SQM."))
            .disabled(this.disabledMemoryCoordinate)
            .event(_Navigation.standCommand.bind(_Navigation))
            .add()

            new _Text().title("Hotkey:")
            .x("+5").y("p+5")
            .add()

        this[this.HOTKEY_STAND_COMMAND] := new _Hotkey().name(this.HOTKEY_STAND_COMMAND)
            .x("+3").y("p-3").w(this.hotkeysW)
            .tt(this.hotkeyTooltip)
            .state(_NavigationSettings)
            .event(this.getStandHotkeyEvent())
            .add()
    }

    use()
    {
            new _Button().title("Use")
            .x("s+20").y("+2").w(this.buttonsW)
            .tt(txt("Enviar o comando para o Follower realizar ação de ""Use"" no o SQM definido.", "Send the command to the Follower to perform the ""Use"" action on the defined SQM."))
            .disabled(this.disabledMemoryCoordinate)
            .event(_Navigation.useCommand.bind(_Navigation))
            .add()

            new _Text().title("Hotkey:")
            .x("+5").y("p+5")
            .add()

        this[this.HOTKEY_USE_COMMAND] := new _Hotkey().name(this.HOTKEY_USE_COMMAND)
            .x("+3").y("p-3").w(this.hotkeysW)
            .option("center")
            .tt(this.hotkeyTooltip)
            .state(_NavigationSettings)
            .event(this.getUseHotkeyEvent())
            .add()
    }

    useRope()
    {
            new _Button().title("Use Rope")
            .x("s+20").y("+2").w(this.buttonsW)
            .tt(txt("Enviar o comando para o Follower usar a ""Rope"" no o SQM definido.", "Send the command to the Follower to use the ""Rope"" on the defined SQM."))
            .disabled(this.disabledMemoryCoordinate)
            .event(_Navigation.useRopeCommand.bind(_Navigation))
            .add()

            new _Text().title("Hotkey:")
            .x("+5").y("p+5")
            .add()

        this[this.HOTKEY_USE_ROPE_COMMAND] := new _Hotkey().name(this.HOTKEY_USE_ROPE_COMMAND)
            .x("+3").y("p-3").w(this.hotkeysW)
            .option("center")
            .tt(this.hotkeyTooltip)
            .state(_NavigationSettings)
            .event(this.getUseHotkeyEvent())
            .add()
    }

    useShovel()
    {
            new _Button().title("Use Shovel")
            .x("s+20").y("+2").w(this.buttonsW)
            .tt(txt("Enviar o comando para o Follower usar a ""Shovel"" no o SQM definido.", "Send the command to the Follower to use the ""Shovel"" on the defined SQM."))
            .disabled(this.disabledMemoryCoordinate)
            .event(_Navigation.useShovelCommand.bind(_Navigation))
            .add()

            new _Text().title("Hotkey:")
            .x("+5").y("p+5")
            .add()

        this[this.HOTKEY_USE_SHOVEL_COMMAND] := new _Hotkey().name(this.HOTKEY_USE_SHOVEL_COMMAND)
            .x("+3").y("p-3").w(this.hotkeysW)
            .option("center")
            .tt(this.hotkeyTooltip)
            .state(_NavigationSettings)
            .event(this.getUseHotkeyEvent())
            .add()
    }

    action(number)
    {
            new _Button().title("Action Script " number)
            .x("s+20").y("+2").w(this.buttonsW)
            .tt(txt("Enviar o comando para o Follower executar a Action Script com label ""Navigation" number """.`n`nOBS: Irá executar o waypoint com o label ""Navigation" number """ na aba ""Special"".", "Send the command to the Follower to run the Action Script with label ""Navigation" number """.`n`nPS: It will run the waypoint with label ""Navigation" number """ in the ""Special"" tab."))
            .disabled(this.disabledMemoryCoordinate)
            .event(_Navigation.actionCommand.bind(_Navigation, number))
            .add()

            new _Text().title("Hotkey:")
            .x("+5").y("p+5")
            .add()

        controlName := this.getActionControlName(number)

        this[controlName] := new _Hotkey().name(controlName)
            .x("+3").y("p-3").w(this.hotkeysW)
            .option("center")
            .tt(this.hotkeyTooltip)
            .state(_NavigationSettings)
            .event(this.getActionHotkeyEvent(number))
            .add()
    }

    optionsSection()
    {
        group := new _Groupbox().title("Opções", "Options")
            .xs(10).y(310).w(this.halfW - 25).h(207)
            .section()
            .add()

            new _Checkbox().name("showLeaderWaypoints")
            .title("Mostrar waypoints na tela", "Show waypoints on screen")
            .xs(10).yp(20)
            .state(_NavigationSettings)
            .add()

            new _Text().title("Distância em SQMs:", "Distance in SQMs:")
            .xs(10).yadd(10)
            .add()

            new _Edit().name("distance")
            .xadd(5).yp(-2).h(18).w(50)
            .numeric()
            .tt(txt("Distancia minima que o Leader precisa estar da sua posição anterior para enviar as coordenadas para o Follower.`n`nAo deixar em 0, irá enviar constantemente a posição e o Follower ficará sempre nos SQMS em volta ou as vezes no mesmo SQM do Leader.", ""))
            .limit(2)
            .state(_NavigationSettings)
            .rule(new _ControlRule().min(0).max(50))
            .add()


            new _Text().title("Selecione a janela do Multi Client(MC):", "Select the Multi Client(MC) window:")
            .xs(10).yadd(10)
            .add()

        this.availableWindowsList := new _Listview().name("targetWindow")
            .x("p+0").yadd(3).w(group.getW() - 20).r(5)
            .checked()
            .event(_Navigation.setFollowerWindow.bind(_Navigation))
            .add()

            new _Button().name("updateWindowsList").title("Atualizar lista", "Update list")
            .w(this.buttonsW).y("+3")
            .tt(txt("Atualiza a lista de janelas(instâncias) do OldBot abertas.`n`nO Leader enviará a sua posição para instância da janela selecionada.", "Update the list of OldBot windows(instances) opened.`n`nThe Leader will send its position to the instance of the selected window."))
            .event(this.updateWindowsList.bind(this))
            .icon(_Icon.get(_Icon.RELOAD), "a0 l3 b0 s16")
            .add()




            new _Button().title(txt("Abrir logs", "Open logs") " (DebugView)")
            .x("m+5").y("m+525").w(150)
            .event("OpenDebugView")
            .add()

    }

    followerSection()
    {
            new _Groupbox()
            .x(this.halfW + 25).y(this.topY).w(this.halfW - 20).h(this.h)
            .option("Section")
            .add()

        _Follower.CHECKBOX := new _Checkbox().name(_Follower.CHECKBOX_NAME)
            .title("Follower Enabled")
            .x("s+10").y("s+0")
            .disabled(this.disabledMemoryCoordinate)
            .event(_Follower.toggle.bind(_Follower))
            .tt(txt("Quando ativado, irá caminhar até as coordenadas recebidas por outra instância do OldBot.", "When enabled, it will walk to the received coordinate from another OldBot instance."))
            .state(_NavigationSettings)
            .add()

            new _Groupbox().title("Opções", "Options")
            .xs(10).yadd(5).w(this.halfW - 40).r(2)
            .section()
            .add()

            new _Checkbox().name("showFollowerWaypoints")
            .title("Mostrar waypoints na tela", "Show waypoints on screen")
            .xs(10).yp(20)
            .state(_NavigationSettings)
            .add()

            new _Text().title("Navigation está em fase BETA.", "Navigation is in BETA phase.")
            .x("170").y("m+530").w(500)
            .option("Center")
            .color("Red")
            .add()
    }

    /**
    * @return void
    */
    updateWindowsList()
    {
        this.availableWindowsList.list(this.getWindowsList())

        _Navigation.resetFollowerWindows()

        Loop, % this.availableWindowsList.getRows().Count()
        {
            this.availableWindowsList.checkRow(A_Index, false)
        }
    }

    /**
    * @return array<_Row>
    */
    getWindowsList()
    {
        winGet, winList, list, % mainGuiPrefix

        windowsList := {}
        number := 1
        Loop, %winList% {
            if (winList%A_Index% = "") {
                break
            }

            WinGetTitle, title%A_Index%, % "ahk_id " winList%A_Index%
            title := title%A_Index%

            if (title = MAIN_GUI_TITLE) {
                continue
            }


            WinGetClass, windowClass,  % "ahk_id " winList%A_Index%
            if (!InStr(windowClass, "AutoHotkeyGUI") && !InStr(windowClass, _App.GUI_CLASS)) {
                continue
            }

            row := new _Row()
                .add(title)
                .setNumber(number)
            number++

            windowsList.Push(row)
        }

        return windowsList
    }

    /**
    * @return _Hotkey
    */
    getWalkHotkeyControl()
    {
        return this[this.HOTKEY_WALK_COMMAND]
    }

    /**
    * @return BoundFunc
    */
    getWalkHotkeyEvent()
    {
        ; @var BoundFunc:_Hotkey hotkeyControl
        hotkeyControl := this.getWalkHotkeyControl.bind(this)
        eventFunction := _Navigation[this.HOTKEY_WALK_COMMAND].bind(_Navigation)
        ; @var BoundFunc:string oldHotkey
        oldHotkey := this.settings.get.bind(this.settings, this.HOTKEY_WALK_COMMAND)

        return _HotkeyRegister.registerFromControl.bind(_HotkeyRegister, hotkeyControl, eventFunction, this.HOTKEY_WALK_COMMAND, oldHotkey)
    }

    /**
    * @return _Hotkey
    */
    getStandHotkeyControl()
    {
        return this[this.HOTKEY_STAND_COMMAND]
    }

    /**
    * @return BoundFunc
    */
    getStandHotkeyEvent()
    {
        ; @var BoundFunc:_Hotkey hotkeyControl
        hotkeyControl := this.getStandHotkeyControl.bind(this)
        eventFunction := _Navigation[this.HOTKEY_STAND_COMMAND].bind(_Navigation)
        ; @var BoundFunc:string oldHotkey
        oldHotkey := this.settings.get.bind(this.settings, this.HOTKEY_STAND_COMMAND)

        return _HotkeyRegister.registerFromControl.bind(_HotkeyRegister, hotkeyControl, eventFunction, this.HOTKEY_STAND_COMMAND, oldHotkey)
    }

    /**
    * @return _Hotkey
    */
    getUseHotkeyControl()
    {
        return this[this.HOTKEY_USE_COMMAND]
    }

    /**
    * @return BoundFunc
    */
    getUseHotkeyEvent()
    {
        ; @var BoundFunc:_Hotkey hotkeyControl
        hotkeyControl := this.getUseHotkeyControl.bind(this)
        eventFunction := _Navigation[this.HOTKEY_USE_COMMAND].bind(_Navigation)
        ; @var BoundFunc:string oldHotkey
        oldHotkey := this.settings.get.bind(this.settings, this.HOTKEY_USE_COMMAND)

        return _HotkeyRegister.registerFromControl.bind(_HotkeyRegister, hotkeyControl, eventFunction, this.HOTKEY_USE_COMMAND, oldHotkey)
    }

    /**
    * @return _Hotkey
    */
    getUseRopeHotkeyControl()
    {
        return this[this.HOTKEY_USE_ROPE_COMMAND]
    }

    /**
    * @return BoundFunc
    */
    getUseRopeHotkeyEvent()
    {
        ; @var BoundFunc:_Hotkey hotkeyControl
        hotkeyControl := this.getUseRopeHotkeyControl.bind(this)
        eventFunction := _Navigation[this.HOTKEY_USE_ROPE_COMMAND].bind(_Navigation)
        ; @var BoundFunc:string oldHotkey
        oldHotkey := this.settings.get.bind(this.settings, this.HOTKEY_USE_ROPE_COMMAND)

        return _HotkeyRegister.registerFromControl.bind(_HotkeyRegister, hotkeyControl, eventFunction, this.HOTKEY_USE_ROPE_COMMAND, oldHotkey)
    }

    /**
    * @return _Hotkey
    */
    getUseShovelHotkeyControl()
    {
        return this[this.HOTKEY_USE_SHOVEL_COMMAND]
    }

    /**
    * @return BoundFunc
    */
    getUseShovelHotkeyEvent()
    {
        ; @var BoundFunc:_Hotkey hotkeyControl
        hotkeyControl := this.getUseShovelHotkeyControl.bind(this)
        eventFunction := _Navigation[this.HOTKEY_USE_SHOVEL_COMMAND].bind(_Navigation)
        ; @var BoundFunc:string oldHotkey
        oldHotkey := this.settings.get.bind(this.settings, this.HOTKEY_USE_SHOVEL_COMMAND)

        return _HotkeyRegister.registerFromControl.bind(_HotkeyRegister, hotkeyControl, eventFunction, this.HOTKEY_USE_SHOVEL_COMMAND, oldHotkey)
    }

    /**
    * @return _Hotkey
    */
    getActionHotkeyControl(number)
    {
        controlName := this.getActionControlName(number)
        return this[controlName]
    }

    /**
    * @return BoundFunc
    */
    getActionHotkeyEvent(number)
    {
        controlName := this.getActionControlName(number)
        ; @var BoundFunc:_Hotkey hotkeyControl
        hotkeyControl := this.getActionHotkeyControl.bind(this, number)
        eventFunction := _Navigation.actionCommand.bind(_Navigation.number)
        ; @var BoundFunc:string oldHotkey
        oldHotkey := this.settings.get.bind(this.settings, controlName)

        return _HotkeyRegister.registerFromControl.bind(_HotkeyRegister, hotkeyControl, eventFunction, controlName, oldHotkey)
    }

    getActionControlName(number)
    {
        return this["HOTKEY_ACTION_" number "_COMMAND"]
    }

}