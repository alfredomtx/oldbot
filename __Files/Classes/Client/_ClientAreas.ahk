#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

global battleListPosX
global battleListPosY


Class _ClientAreas extends _BaseClass
{
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    setupCommonAreas() {
        _ := new _WindowArea()
        _ := new _GameWindowArea()
        _ := new _CharPosition()
        _ := new _SideBarLeftArea()
        _ := new _SideBarRightArea()
        _ := new _StatusBarArea()
        _ := new _EquipmentArea()
        _ := new _ChatButtonArea()
        _ := new _RingArea()
        _ := new _AmuletArea()
    }

    setGameWindowArea()
    {
        if (!this.beforeSetArea()) {
            return
        }

        if (this.setScreenArea(_GameWindowArea.INI_CONFIG, _GameWindowArea.NAME, "Red", 180, _GameWindowArea.getMinWidth(), _GameWindowArea.getMinHeight()) = false) {
            Gui, Show
            return
        }

        this.showGameWindowArea()
    }

    showGameWindowArea()
    {
        try {
            _CharPosition.destroyInstance()
            _GameWindowArea.destroyInstance()
            gameWindowArea := new _GameWindowArea()

            this.showArea(gameWindowArea.getX1(), gameWindowArea.getY1(), gameWindowArea.getX2(), gameWindowArea.getY2())
        } catch e {
            _Logger.msgboxException(48, e, A_ThisFunc)
        }
    }

    beforeSetArea()
    {
        if (TibiaClient.getClientArea() = false)
            return false

        return true
    }

    setLootSearchArea()
    {
        if (this.beforeSetArea() = false)
            return

        minWidth := 0
        if (LootingSystem.lootingJsonObj.options.mininumLootSearchAreaWidth > 1)
            minWidth := LootingSystem.lootingJsonObj.options.mininumLootSearchAreaWidth

        defaultY2 := (WindowY + WindowHeight) - 10
        if (this.setScreenArea("looting", "lootSearchArea", "Red", 180, minWidth, 60, defaultY2) = false)
            return

        try this.readLootSearchArea()
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 48, % A_ThisFunc, % e.Message, 5
            return
        }

        this.showLootSearchArea()
    }

    showLootSearchArea()
    {
        try this.readLootSearchArea()
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 48, % A_ThisFunc, % e.Message, 5
            return
        }
        if (this.lootSearchArea.x1 = "") {
            Gui, Carregando:Destroy
            Msgbox, 48, % A_ThisFunc, % "Loot Search Area not set.", 5
            return
        }
        this.showArea(this.lootSearchArea.x1, this.lootSearchArea.y1, this.lootSearchArea.x2, this.lootSearchArea.y2)
    }

    readLootSearchArea()
    {
        IniRead, X1, %DefaultProfile%, % "looting", % "lootSearchAreaX1", %A_Space%
        IniRead, Y1, %DefaultProfile%, % "looting", % "lootSearchAreaY1", %A_Space%
        IniRead, X2, %DefaultProfile%, % "looting", % "lootSearchAreaX2", %A_Space%
        IniRead, Y2, %DefaultProfile%, % "looting", % "lootSearchAreaY2", %A_Space%

        this.lootSearchArea := {}
        this.lootSearchArea.x1 := X1
        this.lootSearchArea.y1 := Y1
        this.lootSearchArea.x2 := X2
        this.lootSearchArea.y2 := Y2

        if (this.lootSearchArea.x1 = "")
            throw Exception("""Loot Search Area"" " (LANGUAGE = "PT-BR" ? "não setada" : "not set."))
    }

    setLootBackpackPosition()
    {
        if (this.beforeSetArea() = false)
            return

        if (this.setScreenPosition("looting", "lootBackpackPosition") = false)
            return

        try this.readLootBackpackPosition()
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 48, % A_ThisFunc, % e.Message, 5
            return
        }
        ; msgbox, % serialize(this.gameWindowArea)
        this.showLootBackpackPosition()
    }

    showLootBackpackPosition()
    {
        try this.readLootBackpackPosition()
        catch e {
            Gui, Carregando:Destroy
            Msgbox, 48, % A_ThisFunc, % e.Message, 5
            return
        }
        if (this.lootBackpackPosition.x = "") {
            Gui, Carregando:Destroy
            Msgbox, 48, % A_ThisFunc, % """Loot Backpack Position"" " (LANGUAGE = "PT-BR" ? "não setada." : "not set."), 5
            return
        }
        this.showArea(this.lootBackpackPosition.x - 14, this.lootBackpackPosition.y - 14, this.lootBackpackPosition.x + 14, this.lootBackpackPosition.y + 14)
    }

    readLootBackpackPosition()
    {
        IniRead, X, %DefaultProfile%, % "looting", % "lootBackpackPositionX", %A_Space%
        IniRead, Y, %DefaultProfile%, % "looting", % "lootBackpackPositionY", %A_Space%

        this.lootBackpackPosition := {}
        this.lootBackpackPosition.x := X
        this.lootBackpackPosition.y := Y

        if (this.lootBackpackPosition.x = "")
            throw Exception("""Loot Backpack Position"" " (LANGUAGE = "PT-BR" ? "não setada." : "not set."))
    }

    showArea(X1 := "", Y1 := "", X2 := "", Y2 := "", color := "Green", transparency := 170)
    {
        try client := TibiaClient.getClientArea(false, throwException := true)
        catch {
            return
        }
        if (client = false)
            return

        if (X1 = "") OR (Y1 = "")  OR (X2 = "")  OR (Y2 = "") {
            Msgbox, 64,, % LANGUAGE = "PT-BR" ? "Defina a área na tela primeiro para poder vê-la." : "Set the area on screen first to be able to see it."
            return
        }
        WinActivate()
        X1 += WindowX, X2 += WindowX, Y1 += WindowY, Y2 += WindowY
        Gui, screen_box:Destroy
        Gui, screen_box: +alwaysontop -Caption +Border +ToolWindow +LastFound
        Gui, screen_box:Color, %color%
        Gui, screen_box:+Lastfound
        WinSet, Transparent, %transparency% ; Else Add transparency
        ; WinSet, TransColor, EEAA99
        Gui, screen_box:-Caption +Border
        w := X2 - X1
        h := Y2 - Y1
        try
            Gui, screen_box:Show, x%X1% y%Y1% w%w% h%h%
        catch {
            Msgbox, 16,, % LANGUAGE = "PT-BR" ? "Área inválida, defina novamente." : "Invalid area, set it again."
            Gui, screen_box:Destroy
            Gui, Show
            return
        }
        Sleep, 1000
        Gui, screen_box:Destroy
        Gui, Show
        return
    }

    setScreenPosition(section := "", varName := "")
    {
        setSystemCursor("IDC_CROSS")

        Loop {
            Tooltip, % (LANGUAGE = "PT-BR" ? "Click para setar a posição.`n""Esc"" para cancelar." : "Click to set the position.`n""Esc"" to cancel.")
            Sleep, 25
            if (GetKeyState("LButton"))
                break
            if (GetKeyState("Space"))
                break
            if (GetKeyState("Esc")) {
                restoreCursor()
                return false
            }
        }
        MouseGetPos, MX, MY
        X := MX - WindowX
        Y := MY - WindowY


        if (section && varName) {
            IniWrite, % X, %DefaultProfile%, % section, %varName%X
            IniWrite, % Y, %DefaultProfile%, % section, %varName%Y
        }

        Tooltip
        restoreCursor()

        return true
    }

    setScreenArea(section, varName, color := "Red", transparency := 180, minWidth := 0, minHeight := 0, defaultY2 := "")
    {
        if (WindowX = "" OR WindowY = "")
            throw Exception("Empty WindowX")
        setSystemCursor("IDC_CROSS")
        CoordMode, Mouse,Screen
        WinActivate()
        ; WinSet, TransColor, EEAA99
        ;Gui, screen_box:+Resize

        Loop {
            Tooltip, % LANGUAGE = "PT-BR" ? "Clique(sem segurar) para desenhar um retângulo e setar a área.`n""Esc"" para cancelar." : "Click(without holding) to draw a retangle and set the area.`n""Esc"" to cancel."
            Sleep, 80
            if (GetKeyState("LButton"))
                break
            if (GetKeyState("Space"))
                break

            if (GetKeyState("Esc")) {
                Tooltip
                restoreCursor()
                return false
            }
        }
        MouseGetPos, MX, MY
        KeyWait, LButton, T2
        Tooltip
        Gui, screen_box:Destroy
        Gui, screen_box:+alwaysontop -Caption +Border +ToolWindow +LastFound
        gui, screen_box:Color, %color%
        Gui, screen_box:+Lastfound
        WinSet, Transparent, %transparency% ; Else Add transparency

        /**
        move the mouse to the end of the minimum position
        */
        if (minWidth > 0 OR minHeight > 0) {
            MouseGetPos, MXend, MYend
            w := abs(MX - MXend)
            h := abs(MY - MYend)
            ; msgbox, % minWidth "," minHeight
            MouseMove, MXend + minWidth, MYend + minHeight
            ; msgbox, % MXend "," MYendminHeight
        }

        if (defaultY2) {
            MouseGetPos, x, y
            MouseMove, x, defaultY2
        }

        CoordMode, Mouse,Screen
        Loop {
            MouseGetPos, MXend, MYend

            w := abs(MX - MXend)
            h := abs(MY - MYend)

            Tooltip, % w "x" h (w < minWidth ? "`n(" txt("largura", "width") " min: " minWidth ")" : "") (h < minHeight ? "`n(" txt("altura", "height") " min: " minHeight ")" : "")
            Sleep, 25
            if (GetKeyState("LButton"))
                break
            if (GetKeyState("Space"))
                break
            if (GetKeyState("Esc")) {
                Gui, screen_box:Destroy
                restoreCursor()
                return false
            }


            if (w < minWidth)
                w := minWidth
            if (h < minHeight)
                h := minHeight
            if ( MX < MXend )
                X := MX
            Else
                X := MXend
            if ( MY < MYend )
                Y := MY
            Else
                Y := MYend
            Gui, screen_box:Show, x%X% y%Y% w%w% h%h%
        }

        MouseGetPos, MXend, MYend

        Tooltip
        Gui, screen_box:Destroy
        restoreCursor()

        X1 := MX - WindowX
        Y1 := MY - WindowY
        X2 := MXend - WindowX
        Y2 := MYend - WindowY
        w := abs(X2 - X1)
        if (w < minWidth)
            X2 := X1 + minWidth

        IniWrite, % X1, %DefaultProfile%, % section, % varName "X1"
        IniWrite, % Y1, %DefaultProfile%, % section, % varName "Y1"
        IniWrite, % X2, %DefaultProfile%, % section, % varName "X2"
        IniWrite, % Y2, %DefaultProfile%, % section, % varName "Y2"

        return true
    }
} ; Class