

global waypointRecorderType
global waypointRecorderIntervalSqms
global waypointRecorderRangeX
global waypointRecorderRangeY

global waypointRecorderRunning := false

class _WaypointRecorder
{
    __New()
    {
        this.readIniWaypointRecorderSettings()

        this.validateWaypointRecorderSettings()
    }

    validateWaypointRecorderSettings()
    {
        if (waypointRecorderIntervalSqms < 1)
            waypointRecorderIntervalSqms := min(OldbotSettings.settingsJsonObj.options.horizontalSqms, OldbotSettings.settingsJsonObj.options.verticalSqms)

        if (waypointRecorderRangeX < 1)
            waypointRecorderRangeX := 3
        if (waypointRecorderRangeY < 1)
            waypointRecorderRangeY := 3

        if waypointRecorderType not in Walk,Stand
            waypointRecorderType := "Walk"
    }


    autoRecordWaypointsSettings() {
        global
        w := 150

        Gui, recordWaypointSettingsGUI:Destroy
        Gui, recordWaypointSettingsGUI:+AlwaysOnTop -MinimizeBox +Owner
        Gui, recordWaypointSettingsGUI:Add, Text, x10 y+5, % txt("Intervalo de SQMs:", "Interval of SQMs:")	
        Gui, recordWaypointSettingsGUI:Add, Edit, x10 y+3 Section w%w% 0x2000 Limit2 vwaypointRecorderIntervalSqms hwndhwaypointRecorderIntervalSqms, % waypointRecorderIntervalSqms
        Gui, recordWaypointSettingsGUI:Add, UpDown, Range1-99, % waypointRecorderIntervalSqms
        TT.Add(hwaypointRecorderIntervalSqms, txt("Valor padrão: " waypointRecorderIntervalSqms ".`nDistância em SQMs para que seja adicionado um novo waypoint.`nExemplo: se setado " waypointRecorderIntervalSqms ", irá adicionar um novo waypoint sempre que a distância do ultimo waypoint for " waypointRecorderIntervalSqms " ou mais SQMS.", "Default value: " waypointRecorderIntervalSqms ".`nDistance in SQMs for a new waypoint to be added.`nExample: if set " waypointRecorderIntervalSqms ", it will add a new waypoint whenever the distance from the past waypoint is " waypointRecorderIntervalSqms " or more SQMs."))

        w2 := w / 2 - 10

        Gui, recordWaypointSettingsGUI:Add, Text, x10 ys+30, % "Range X:"
        Gui, recordWaypointSettingsGUI:Add, Edit, x10 y+3 w%w2% 0x2000 Limit2 vwaypointRecorderRangeX hwndhwaypointRecorderRangeX, % waypointRecorderRangeX
        Gui, recordWaypointSettingsGUI:Add, UpDown, Range1-99, % waypointRecorderRangeX

        Gui, recordWaypointSettingsGUI:Add, Text, x+20 ys+30, % "Range Y:"
        Gui, recordWaypointSettingsGUI:Add, Edit, xp+0 y+3  w%w2% 0x2000 Limit2 vwaypointRecorderRangeY hwndhwaypointRecorderRangeY, % waypointRecorderRangeY
        Gui, recordWaypointSettingsGUI:Add, UpDown, Range1-99, % waypointRecorderRangeY

        Gui, recordWaypointSettingsGUI:Add, Text, x10 y+10, % txt("Tipo do waypoint:", "Waypoint type:")
        Gui, recordWaypointSettingsGUI:Add, ListBox, x10 y+3 vwaypointRecorderType gsubmitWaypointRecorderSetting w%w% r2, % "Walk|Stand"

            new _Button().title("Tutorial auto record waypoints")
            .x("10").y("+10").w(w).h(30)
            .event(Func("openUrl").bind(LinksHandler.Cavebot.waypointRecorder))
            .gui("recordWaypointSettingsGUI")
            .icon(_Icon.get(_Icon.YOUTUBE), "a0 l5 b0 s16")
            .add()

        Gui, recordWaypointSettingsGUI:Show,, % txt("Configurações - Waypoint Recorder", "Settings - Waypoint Recorder")

        GuiControl, recordWaypointSettingsGUI:ChooseString, waypointRecorderType, % waypointRecorderType

        GuiControl, recordWaypointSettingsGUI:+gsubmitWaypointRecorderSetting, waypointRecorderIntervalSqms
        GuiControl, recordWaypointSettingsGUI:+gsubmitWaypointRecorderSetting, waypointRecorderRangeX
        GuiControl, recordWaypointSettingsGUI:+gsubmitWaypointRecorderSetting, waypointRecorderRangeY

    }

    autoRecordWaypoints() {

        if (this.checksBeforeEnablingRecorder() = false)
            return

        this.coords := {}

        waypointRecorderRunning := true

        WinActivate()
        Loop, {
            Tooltip, % txt("Gravando waypoints...`nSegure ""Esc"" para parar.", "Auto recording waypoints...`nHold ""Esc"" to stop.")
            if (GetKeyState("Esc") = true) {
                this.stopAutoRecordWaypoint()
                break
            }

            Sleep, 75

            try {
                CavebotWalker.getCharCoords(false, firstTryCavebot)
            } catch e {
                this.stopAutoRecordWaypoint()
                msgbox, 16, % A_ThisFunc "(" _Version.getDisplayVersion() ")", % e.Message, 30
                return
            }

            if (this.skipWaypointTooClose() = true) {
                continue
            }
            this.coords.Push({x: posx, y: posy, z: posz})

            waypointAtributesObj := WaypointHandler.createWaypointAtributesObj(waypointRecorderType, waypointRecorderRangeX, waypointRecorderRangeY)
            ; msgbox, % serialize(waypointAtributesObj) "`n`n" tab

            WaypointHandler.add(waypointAtributesObj, tab, save := true)

            if (GetKeyState("Esc") = true) {
                this.stopAutoRecordWaypoint()
                break
            }

            CavebotGUI.loadLV(tab)

            ; _ListviewHandler.selectRow(LV_Waypoints_%tab%, waypointsObj[tab].MaxIndex())
        }

        this.stopAutoRecordWaypoint()
    }

    skipWaypointTooClose() {
        if (this.coords.MaxIndex() < 1)
            return false
        if (this.coords[this.coords.MaxIndex()].z != posz) {
            ; m("different floor")
            return false
        }

        distX := abs(this.coords[this.coords.MaxIndex()].x - posx)
        distY := abs(this.coords[this.coords.MaxIndex()].y - posy)
        if (distY < waypointRecorderIntervalSqms) && (distX < waypointRecorderIntervalSqms) {
            ; m("distX " distX ", distY " distY)
            return true
        }
        return false
    }

    checksBeforeEnablingRecorder() {
        if (scriptSettingsObj.charCoordsFromMemory = false) {
            if (OldBotSettings.settingsJsonObj.configFile = "settings.json") {
                TibiaClient.listTibiaClientsGUI()
                msgbox, 64,, % txt("Escolha o OT Server na lista em ""Selecionar Client"" para habilitar a opção ""Coordenadas do char da memória do cliente"".", "Choose the OT Server in the list on ""Select client"" to enable the ""Char coordinates from client memory"" option.")
                return false
            }

            msgbox, 48,, % txt("É necessário ativar a opção " """", "It is needed to enable the option ") txt("Coordenadas do char da memória do cliente", "Char coords from client memory") """" txt("`n`nSe a opção esta desabilitada(cinza), o cliente atual não possui suporte para injeção de memória, verifique com o suporte(Admin) a possibilidade de adaptação do OldBot.", "`n`nIf the option is disabled(gray), the current client does not have support for memory injection, check with the support(Admin) the possibility to adapt OldBot.")
            return false
        }

        if (TibiaClient.isClientClosed() = true) {
            Msgbox, 64,, % txt("O cliente do Tibia está fechado.", "Tibia client is closed."), 2
            return false
        }
        if (isDisconnected()) {
            Msgbox, 48,, % "Char must be logged in.", 2
            return false
        }
        if (TibiaClient.getClientArea() = false)
            return false

        GuiControl, CavebotGUI:Disable, autoRecordWaypointsButton

        return true
    }

    stopAutoRecordWaypoint() {
        waypointRecorderRunning := false

        GuiControl, CavebotGUI:Enable, autoRecordWaypointsButton

        WaypointHandler.saveWaypoints(true, A_ThisFunc)

        Tooltip
        Gui, CavebotGUI:Show
        OldBotSettings.enableGuisLoading()

    }

    writeIniWaypointRecorderSettings(setting, value := "") {
        IniWrite, % value, %DefaultProfile%, waypoint_recorder_settings, % setting
    }

    readIniWaypointRecorderSettings() {
        global

        IniRead, waypointRecorderType, %DefaultProfile%, waypoint_recorder_settings, waypointRecorderType, Walk
        IniRead, waypointRecorderIntervalSqms, %DefaultProfile%, waypoint_recorder_settings, waypointRecorderIntervalSqms, % min(OldbotSettings.settingsJsonObj.options.horizontalSqms, OldbotSettings.settingsJsonObj.options.verticalSqms)
        IniRead, waypointRecorderRangeX, %DefaultProfile%, waypoint_recorder_settings, waypointRecorderRangeX, 3
        IniRead, waypointRecorderRangeY, %DefaultProfile%, waypoint_recorder_settings, waypointRecorderRangeY, 3
    }
}