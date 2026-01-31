


global minimapViewerGUI_ICON_COUNTER := 0
global minimapViewer_ICONBUTTONS

global viewerCoordinates

IniRead, ignoreWrongCoordinateMinimapFiles, %DefaultProfile%, mapViewer, ignoreWrongCoordinateMinimapFiles, 1
global ignoreWrongCoordinateMinimapFiles


global minimapGuiWindowX
global minimapGuiWindowY
IniRead, minimapGuiWindowX, %DefaultProfile%, mapViewer, minimapGuiWindowX, %A_Space%
IniRead, minimapGuiWindowY, %DefaultProfile%, mapViewer, minimapGuiWindowY, %A_Space%
pos := validateInvalidWindowPos(minimapGuiWindowX, minimapGuiWindowY)
minimapGuiWindowX := pos.x
minimapGuiWindowY := pos.y

IniRead, lastCreatedMinimapFolder, %DefaultProfile%, mapViewer, lastCreatedMinimapFolder, %A_Space%
global lastCreatedMinimapFolder


Class _MinimapGUI
{
    __New()
    {


        this.imgCoords := {}


        this.showCostFiles := false
        this.showGrayFiles := false
        this.showCrosshair := true
        this.minimapImagesString := TibiaClient.clientMinimapPath "\Minimap_" (this.showCostFiles = false ? "Color" : "WaypointCost")

        this.minimapGuiTitle := "Map viewer"

        this.zoomLevel := 5
        this.minZoomLevel := 1
        this.maxZoomLevel := 7

        this.createMinimapViewerMenu()

        this.cyan := "0xFF00ecff"
        this.pink := "0xFFFF00FF"
        this.white := "0xFFFFFFFF"
        this.crossHairColor := this.cyan


        this.mapViewerGuiTitle := "Map Viewer"

        this.showGrayCheckbox := 0




    }

    createMinimapViewerMenu() {
        Menu, minimapViewerMenu, Add, % "Add Action `tAlt+A", minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add,
        Menu, minimapViewerMenu, Add, % "Add Walk `tAlt+W", minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add, % "Add Stand `tAlt+S", minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add,
        Menu, minimapViewerMenu, Add, % "Add Door `tAlt+D", minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add, % "Add Ladder `tAlt+L", minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add, % "Add Use `tAlt+U", minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add,
        Menu, minimapViewerMenu, Add, % "Add Rope `tAlt+R", minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add, % "Add Shovel `tAlt+H", minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add, % "Add Machete `tAlt+M", minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add,
        Menu, minimapViewerMenu, Add, % "Navigation - Walk `tW" , minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add, % "Navigation - Stand `tS" , minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add, % "Navigation - Use `tU" , minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add, % "Navigation - Rope `tR" , minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add, % "Navigation - Shovel `tH" , minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add, % "Navigation - Action 1 `t1" , minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add, % "Navigation - Action 2 `t2" , minimapViewerMenuHandler
        Menu, minimapViewerMenu, Add, % "Navigation - Action 3 `t3" , minimapViewerMenuHandler
    }

    minimapViewerGUI() {
        global

        this.cavebotGUI := false
        this.destroyButtonIcons()

        this.guiOptions := {}
        this.guiOptions.w := 735
        this.guiOptions.borderPx := 2

        this.guiElements := {}
        this.guiElements.minimapImageSize := 512
        this.guiElements.minimapImagesX := this.guiOptions.w - (this.guiElements.minimapImageSize) - this.guiOptions.borderPx

        this.guiOptions.h := (this.guiElements.minimapImageSize) + (this.guiOptions.borderPx * 2)


        Gui, minimapViewerGUI:Destroy
        ; Gui, minimapViewerGUI:+AlwaysOnTop -Caption +Border
        Gui, minimapViewerGUI:-Caption +Border


        this.groupboxW := abs(this.guiOptions.w - this.guiElements.minimapImageSize) - 20


        this.viewerX := this.viewerX = "" ? (posx = "" ? OldBotSettings.settingsJsonObj.map.viewer.defaultCoordX : posx) : this.viewerX
        this.viewerY := this.viewerY = "" ? (posy = "" ? OldBotSettings.settingsJsonObj.map.viewer.defaultCoordY : posy) : this.viewerY
        this.viewerZ := this.viewerZ = "" ? (posz = "" ? 7 : posz) : this.viewerZ

        this.viewerControls()

        this.viewerOptions()

        this.viewerMinimapImages()


        sizeString := "w" this.guiOptions.w " h" this.guiOptions.h + 23
        positionString := (minimapGuiWindowX != "" ? "x" minimapGuiWindowX : "") " " (minimapGuiWindowY != "" ? "y" minimapGuiWindowY : "")

        try Gui, minimapViewerGUI:Add, StatusBar, vStatusBarMapViewer gchangeMinimapFolder,
        catch {
        }


        Gui, minimapViewerGUI:Show, %  positionString " " sizeString, % this.mapViewerGuiTitle

        this.minimapViewerStatusBar()
    }

    viewerControls() {
        global


            new _ControlFactory(_ControlFactory.HOTKEYS_BUTTON)
            .x(this.guiElements.minimapImageSize + 10).y(5).h(25)
            .focused()
            .event("MinimapViewerHotkeysGUI")
            .gui("minimapViewerGUI")
            .add()

        checked := this.showCostFiles
        Gui, minimapViewerGUI:Add, Checkbox, x+10 yp+5 gshowCostFiles vshowCostFiles Checked%checked% %DisabledNotTibia12%, Show Cost




        Gui, minimapViewerGUI:Add, Button, % "xm+" this.guiOptions.w - 45 " y5 w25 h25 gminimapViewerGUIGuiClose hwndhcloseMinimapViewer"

        iconNumber := (isWin11() = true) ? 261 : 260
        this.minimapGuiButtonIcon(hcloseMinimapViewer, "imageres.dll", iconNumber, "a0 l1 b1 s18")

        TT.Add(hcloseMinimapViewer, "Close window`n[ Shift + Esc  | Ctrl + Esc ]")


        buttonSize := 40

        spaceButtons := buttonSize


        slidersWidth := (this.groupboxW - 20) - 20
        sliderHeight := 55

        Gui, minimapViewerGUI:Add, GroupBox, % "x" this.guiElements.minimapImageSize + 10 " y+5 vfloorLevelGroupbox Section h77 w" this.groupboxW " Section ", % "Floor Level (" this.viewerZ ")"

        Gui, minimapViewerGUI:Font, cGray
        Gui, minimapViewerGUI:Add, Text, xs+10 ys+35, 0
        Gui, minimapViewerGUI:Font,

        Gui, minimapViewerGUI:Add, Slider, % "xs+" 18 " ys+" 20 " h" sliderHeight " w" slidersWidth " vfloorLevel gchangeFloor Range0-15 AltSubmit TickInterval1 Center", 7

        Gui, minimapViewerGUI:Font, cGray
        Gui, minimapViewerGUI:Add, Text, x+1 ys+35, 15
        Gui, minimapViewerGUI:Font,


        Gui, minimapViewerGUI:Add, GroupBox, % "x" this.guiElements.minimapImageSize + 10 " y+33 h77 w" this.groupboxW " vzoomLevelGroupbox Section ", % "Zoom (" this.zoomLevel ")"

        Gui, minimapViewerGUI:Font, cGray
        Gui, minimapViewerGUI:Add, Text, xs+10 ys+35, 1
        Gui, minimapViewerGUI:Font,

        Gui, minimapViewerGUI:Add, Slider, % "xs+" 18 " ys+" 20 " vzoomLevel h" sliderHeight " w" slidersWidth " gchangeZoom Range" this.minZoomLevel "-" this.maxZoomLevel " AltSubmit TickInterval1 Center", % this.zoomLevel

        Gui, minimapViewerGUI:Font, cGray
        Gui, minimapViewerGUI:Add, Text, x+1 ys+35, 6
        Gui, minimapViewerGUI:Font,



        ; Gui, minimapViewerGUI:Add, Button, % "xs+" spaceButtons * 2 " ys+" 0 " w" buttonSize " h" buttonSize " gfloorUp ", Floor Up
        ; Gui, minimapViewerGUI:Add, Button, % "xp+" 0 " y+" 5 " w" buttonSize " h" buttonSize " gfloorDown ", Floor Down

        ; Gui, minimapViewerGUI:Add, Text, % "xs+5 ys-20 vfloorLevelTop", aaa
        ; Gui, minimapViewerGUI:Add, Text, % "xs+5 ys+" sliderHeight + 20 " vfloorLevelBottom", bbb
    }

    viewerOptions() {
        global

        disabledNotCoordinates := (CavebotScript.isMarker()) ? "Disabled" : ""
        DisabledNotTibia12 := (isTibia13()) ? "" : "Disabled"
        disabledMemoryCoordinates := (scriptSettingsObj.charCoordsFromMemory = true) ? "Disabled" : ""
        DisabledNotSupportCoordinatesFromMemory := (OldBotSettings.settingsJsonObj.settings.cavebot.getCharCoordinatesFromMemory = true) ? "" : "Disabled"
        DisabledMarkersMode := (CavebotScript.isMarker()) ? "Disabled" : ""

        Gui, minimapViewerGUI:Add, GroupBox, % "x" this.guiElements.minimapImageSize + 10 " y198 Section h317 w" this.groupboxW " ", % "Options"

        ; checked := this.showCrosshair
        ; Gui, minimapViewerGUI:Add, Checkbox, xs+10 ys+25 gshowCrosshair vshowCrosshair Checked%checked%, Crosshair

        Gui, minimapViewerGUI:Add, Checkbox, xs+10 ys+20 gignoreWrongCoordinateMinimapFiles vignoreWrongCoordinateMinimapFiles hwndhignoreWrongCoordinateMinimapFiles Checked%ignoreWrongCoordinateMinimapFiles%, % "Ignore custom map files"
        TT.Add(hignoreWrongCoordinateMinimapFiles, (LANGUAGE = "PT-BR" ? "Há OTs com as coordenadas os arquivos de minimap menor do que o padrão para o mapa do Tibia Global, que começa em x: 31744, y: 30976.`nCom essa opção marcada, ao gerar o mapa da pasta do minimap(generate from minimap folder), irá procurar por arquivos com as coordenadas menor do que essas, e converter para as coordenadas ""reais""(30k+).`nIsso pode fazer com que os arquivos customizados sobrescrevam áreas padrões do mapa ddo Tibia, então a não ser que você esteja usando em um mapa 100% custom, você deve manter essa opção desmarcada." : "There are OTs with minimap files in coordinates lower than the default for Real Tibia map, which starts at x: 31744, y: 30976.`nWith this option checked, when generating the map from minimap folder, it will look for files in coordinates lower than these, and convert it to the ""real"" coordinates(30k+).`nThis may cause the custom files to override default map areas of Tibia, so unless you are using in a 100% custom map, you should keep this option unchecked."))

        higherMapTolerancyPositionSearchMapViewer := higherMapTolerancyPositionSearch
        Gui, minimapViewerGUI:Add, Checkbox, xp+0 y+6 w180 vhigherMapTolerancyPositionSearchMapViewer ghigherMapTolerancyPositionSearchMapViewer hwndhhigherMapTolerancyPositionSearchMapViewer Checked%higherMapTolerancyPositionSearchMapViewer% %disabledNotCoordinates% %disabledMemoryCoordinates%, % "Higher map tolerancy when searching for character position"
        TT.Add(hhigherMapTolerancyPositionSearchMapViewer, tooltip_higherMapTolerancyPositionSearch)

        charCoordsFromMemory := scriptSettingsObj.charCoordsFromMemory
        Gui, minimapViewerGUI:Add, Checkbox, xp+0 y+4 w180 vcharCoordsFromMemory gcharCoordsFromMemory hwndhcharCoordsFromMemory Checked%charCoordsFromMemory% %DisabledMarkersMode% %DisabledNotSupportCoordinatesFromMemory%,% (LANGUAGE = "PT-BR" ? "Coordenadas do char da memória do cliente" : "Char coords from client memory")


        if (!A_IsCompiled) && (this.showGrayCheckbox = true) {
            checked := this.showGrayFiles
            Gui, minimapViewerGUI:Add, Checkbox, x+1 yp+0 gshowGrayFiles vshowGrayFiles Checked%checked%, Gray
        }


        Gui, minimapViewerGUI:Add, Text, xs+10 y+5, % LANGUAGE = "PT-BR" ? "Coordenadas:" : "Coordinates:"
        Gui, minimapViewerGUI:Add, Edit, % "xp+0 y+3 vviewerCoordinates gviewerCoordinates h18 w" this.groupboxW - 20 " ", % this.viewerX "," this.viewerY "," this.viewerZ




        buttonSize := 25

        Gui, minimapViewerGUI:Add, Button, % "xs+10 y+3 w" 40 " h" buttonSize " gshowMinimapCoord hwndhgoToCoord Section", % "Go to"
        ; this.minimapGuiButtonIcon(hgoToCoord, "imageres.dll", 272, "a0 l1 s26")
        ; TT.Add(hgoToCoord, "Go to coordinates")

        ; Gui, minimapViewerGUI:Add, Button, % "x+5 yp+0 w" buttonSize " h" buttonSize " gopenCoordMinimapFile hwndhopenCoordMinimapFile " DisabledNotTibia12 " "
        ;     this.minimapGuiButtonIcon(hopenCoordMinimapFile, "imageres.dll", 14, "a0 l0 s28")
        ;     TT.Add(hopenCoordMinimapFile, "Open minimap file")



        Gui, minimapViewerGUI:Add, Button, % "x+5 yp+0 w138 h" buttonSize " vcharacterPositionMapViewer gcharacterPositionMapViewer " disabledNotCoordinates " ", % "Character position"

        switch scriptSettingsObj.cavebotFunctioningMode {
            case "markers":
                Gui, minimapViewerGUI:Font, cRed
                Gui, minimapViewerGUI:Add, Text, % "xs+0 y+8 w" this.groupboxW - 20, % LANGUAGE = "PT-BR" ? "Cavebot está no modo de Markers." : "Cavebot is in Markers mode."
                Gui, minimapViewerGUI:Font,

            default:
                switch scriptSettingsObj.charCoordsFromMemory {
                    case true:
                        Gui, minimapViewerGUI:Font, cRed
                        Gui, minimapViewerGUI:Add, Text, % "xs+0 y+3 w" this.groupboxW - 20, % this.getCoordsFromMemoryText()
                        Gui, minimapViewerGUI:Font,
                    default:
                        Gui, minimapViewerGUI:Add, Text, xs+0 y+7, % LANGUAGE = "PT-BR" ? "Última coordenadas do char:" : "Last character coordinates:"
                        lastCoords := (posz = "") ? "None" : "x: " posx ", y: " posy ", z: " posz
                        Gui, minimapViewerGUI:Add, Edit, % "xp+0 y+3 vlastCharacterCoordinates h18 w" this.groupboxW - 20 " Disabled", % lastCoords

                        Gui, minimapViewerGUI:Add, Button, % "xp+0 y+3 w" 40 " h" buttonSize " ggotoLastCharCoords " disabledNotCoordinates " ", % "Go to"
                        Gui, minimapViewerGUI:Add, Button, % "x+5 yp+0 w138 h" buttonSize " gresetCharacterCoords " disabledNotCoordinates " " disabledMemoryCoordinates " ", % LANGUAGE = "PT-BR" ? "Resetar coordenadas" : "Reset coordinates"
                }
        }


        w_buttons := 183

        /**
        if it is not tibia 12 or is coords from memory only show option to change minimap folder
        */
        if (isNotTibia13())
                OR (scriptSettingsObj.charCoordsFromMemory = true) {
                Gui, minimapViewerGUI:Add, Button, % "xs+0 y+5 w" w_buttons " gchangeMinimapFolder " disabledNotCoordinates " ",% LANGUAGE = "PT-BR" ? "Alterar diretório da pasta Minimap" : "Change Minimap folder directory"
            if (isTibia13())
                Gui, minimapViewerGUI:Add, Button, % "xs+0 y+3 w" w_buttons " ggenerateCustomMapFromMinimapFolder hwndgenerateCustomMapFromMinimapFolder " disabledNotCoordinates " ", % LANGUAGE = "PT-BR" ? "Gerar mapa da pasta Minimap" : "Generate map from Minimap folder"
        } else {
            Gui, minimapViewerGUI:Add, Button, % "xs+0 y+7 w" w_buttons " ggenerateCustomMapFromMinimapFolder hwndgenerateCustomMapFromMinimapFolder " disabledNotCoordinates " ", % LANGUAGE = "PT-BR" ? "Gerar mapa da pasta Minimap" : "Generate map from Minimap folder"
            Gui, minimapViewerGUI:Add, Button, % "xs+0 y+2 w" w_buttons " gresetDefaultMinimap hwndresetDefaultMinimap " disabledNotCoordinates " ", % LANGUAGE = "PT-BR" ? "Resetar para o mapa padrão" : "Reset to default map"
            TT.Add(resetDefaultMinimap, LANGUAGE = "PT-BR" ? "Reseta para o mapa padrão que vai com o bot quando é instalado, isto irá desfazer o mapa gerado pelo botão ""Generated from Minimap folder""." : "Reset to default map that comes with the bot when it is installed, this will undo the map generated from ""Generated from Minimap folder"" button.")
            Gui, minimapViewerGUI:Add, Button, % "xs+0 y+2 w" w_buttons " gchangeMinimapFolder " disabledNotCoordinates " ", % LANGUAGE = "PT-BR" ? "Alterar diretório da pasta Minimap" : "Change Minimap folder directory"
        }

        clientTooltip := TibiaClient.clientMinimapPath = "" ? "Minimap folder path not set" : TibiaClient.clientMinimapPath

        TT.Add(generateCustomMapFromMinimapFolder, (LANGUAGE = "PT-BR" ? "Gera um mapa customizado utilizando os arquivos da pasta Minimap do cliente do Tibia. Esse mapa customizado é utilizado para o bot localizar as coordenadas do personagem.`n`nPasta do minimap:`n" : "Generate a new custom map using the files from the Tibia client's minimap folder. This map is used by the bot to find the character coordinates.`n`nMinimap folder:`n") clientTooltip)

    }

    viewerMinimapImages() {
        global

        centerImageX := 32246
        centerImageY := 32223


        imageSize := this.guiElements.minimapImageSize

        spaceBetweenImages := 0

        Gui, minimapViewerGUI:Add, Picture, % "x" this.guiOptions.borderPx " y" this.guiOptions.borderPx " w" imageSize " h" imageSize " vminimapViewerImage gclickOnViewerMap AltSubmit Section",
        /**
        Gui, minimapViewerGUI:Add, Picture, % "x" this.guiElements.minimapImagesX " y" this.guiOptions.borderPx " w" imageSize " h" imageSize " vminimapImage1 Section", % this.minimapImagesString "_" this.imgCoords.1.x "_" this.imgCoords.1.y "_" this.imgCoords.1.z ".png"
        Gui, minimapViewerGUI:Add, Picture, x+%spaceBetweenImages% yp+0 w%imageSize% h%imageSize% vminimapImage2, % this.minimapImagesString "_" this.imgCoords.2.x "_" this.imgCoords.2.y "_" this.imgCoords.2.z ".png"
        Gui, minimapViewerGUI:Add, Picture, xs+0 y+%spaceBetweenImages% w%imageSize% h%imageSize% vminimapImage3, % this.minimapImagesString "_" this.imgCoords.3.x "_" this.imgCoords.3.y "_" this.imgCoords.3.z ".png"
        Gui, minimapViewerGUI:Add, Picture, x+%spaceBetweenImages% yp+0 w%imageSize% h%imageSize% vminimapImage4, % this.minimapImagesString "_" this.imgCoords.4.x "_" this.imgCoords.4.y "_" this.imgCoords.4.z ".png"
        */


    }

    minimapViewerCavebotGUI() {
        global

        this.cavebotGUI := true

        this.destroyButtonIcons()

        this.guiOptions := {}
        this.guiOptions.w := 735
        this.guiOptions.borderPx := 2

        this.guiElements := {}
        this.guiElements.minimapImageSize := 512
        this.guiElements.minimapImagesX := this.guiOptions.w - (this.guiElements.minimapImageSize) - this.guiOptions.borderPx

        this.guiOptions.h := (this.guiElements.minimapImageSize) + (this.guiOptions.borderPx * 2)


        Gui, minimapViewerGUI:Destroy
        Gui, minimapViewerCavebotGUI:Destroy
        ; Gui, minimapViewerCavebotGUI:+AlwaysOnTop -Caption +Border
        Gui, minimapViewerCavebotGUI:-Caption +Border


        this.groupboxW := abs(this.guiOptions.w - this.guiElements.minimapImageSize) - 20


        this.viewerX := this.viewerX = "" ? (posx = "" ? OldBotSettings.settingsJsonObj.map.viewer.defaultCoordX : posx) : this.viewerX
        this.viewerY := this.viewerY = "" ? (posy = "" ? OldBotSettings.settingsJsonObj.map.viewer.defaultCoordY : posy) : this.viewerY
        this.viewerZ := this.viewerZ = "" ? (posz = "" ? 7 : posz) : this.viewerZ

        this.viewerControlsCavebot()

        this.viewerOptionsCavebot()

        this.viewerMinimapImagesCavebot()


        sizeString := "w" this.guiOptions.w " h" this.guiOptions.h
        positionString := (minimapGuiWindowX != "" ? "x" minimapGuiWindowX : "") " " (minimapGuiWindowY != "" ? "y" minimapGuiWindowY : "")

        Gui, minimapViewerCavebotGUI:Show, % positionString " " sizeString, % this.mapViewerGuiTitle

        ; this.minimapViewerStatusBar()
    }

    viewerControlsCavebot() {
        global

        ; Gui, minimapViewerCavebotGUI:Add, Button, % "x" this.guiElements.minimapImageSize + 10 " y5 h25 gMinimapViewerHotkeysGUI 0x1", Hotkeys



        Gui, minimapViewerCavebotGUI:Add, Button, % "xm+" this.guiOptions.w - 45 " y5 w25 h25 gminimapViewerCavebotGUIGuiClose hwndhcloseMinimapViewer Disabled"
        this.minimapGuiButtonIcon(hcloseMinimapViewer, "imageres.dll", 260, "a0 l1 b1 s18")
        TT.Add(hcloseMinimapViewer, "Close window`n[ Shift + Esc  | Ctrl + Esc ]")


        buttonSize := 40

        spaceButtons := buttonSize


        slidersWidth := (this.groupboxW - 20) - 20
        sliderHeight := 55



        Gui, minimapViewerCavebotGUI:Add, GroupBox, % "x" this.guiElements.minimapImageSize + 10 " y+5 h78 w" this.groupboxW " vzoomLevelGroupbox Section ", % "Zoom (" this.zoomLevel ")"

        Gui, minimapViewerCavebotGUI:Font, cGray
        Gui, minimapViewerCavebotGUI:Add, Text, xs+10 ys+35, 1
        Gui, minimapViewerCavebotGUI:Font,

        Gui, minimapViewerCavebotGUI:Add, Slider, % "xs+" 18 " ys+" 20 " vzoomLevel h" sliderHeight " w" slidersWidth " gchangeZoom Range" this.minZoomLevel "-" this.maxZoomLevel " AltSubmit TickInterval1 Center", % this.zoomLevel

        Gui, minimapViewerCavebotGUI:Font, cGray
        Gui, minimapViewerCavebotGUI:Add, Text, x+1 ys+35, 6

        Gui, minimapViewerCavebotGUI:Add, GroupBox, % "x" this.guiElements.minimapImageSize + 10 " y+35 vfloorLevelGroupbox Section h78 w" this.groupboxW " Section ", % "Floor Level (" this.viewerZ ")"

        Gui, minimapViewerCavebotGUI:Font, cGray
        Gui, minimapViewerCavebotGUI:Add, Text, xs+10 ys+35, 0
        Gui, minimapViewerCavebotGUI:Font,

        Gui, minimapViewerCavebotGUI:Add, Slider, % "xs+" 18 " ys+" 20 " h" sliderHeight " w" slidersWidth " vfloorLevel gchangeFloor Range0-15 AltSubmit TickInterval1 Center", 7

        Gui, minimapViewerCavebotGUI:Font, cGray
        Gui, minimapViewerCavebotGUI:Add, Text, x+1 ys+35, 15
        Gui, minimapViewerCavebotGUI:Font,

        Gui, minimapViewerCavebotGUI:Font,


        Gui, minimapViewerCavebotGUI:Add, Button, % "x" this.guiElements.minimapImageSize + 10 " w" this.groupboxW " y+35 h35 0x1 vsetCavebotFloorLevel gsetCavebotFloorLevel ", % (LANGUAGE = "PT-BR" ? "Definir Cavebot Floor Level" : "Set Cavebot Floor Level)") " (" this.viewerZ ")"


        ; Gui, minimapViewerCavebotGUI:Add, Button, % "xs+" spaceButtons * 2 " ys+" 0 " w" buttonSize " h" buttonSize " gfloorUp ", Floor Up
        ; Gui, minimapViewerCavebotGUI:Add, Button, % "xp+" 0 " y+" 5 " w" buttonSize " h" buttonSize " gfloorDown ", Floor Down

        ; Gui, minimapViewerCavebotGUI:Add, Text, % "xs+5 ys-20 vfloorLevelTop", aaa
        ; Gui, minimapViewerCavebotGUI:Add, Text, % "xs+5 ys+" sliderHeight + 20 " vfloorLevelBottom", bbb
    }

    viewerOptionsCavebot() {
        global


        ; Gui, minimapViewerCavebotGUI:Add, GroupBox, % "x" this.guiElements.minimapImageSize + 10 " y283 Section h227 w" this.groupboxW " ", Options

        ;     checked := this.showCrosshair
        ;     Gui, minimapViewerCavebotGUI:Add, Checkbox, xs+10 ys+25 gshowCrosshair vshowCrosshair Checked%checked%, Crosshair

        ;     checked := this.showCostFiles
        ;     Gui, minimapViewerCavebotGUI:Add, Checkbox, x+15 yp+0 gshowCostFiles vshowCostFiles Checked%checked%, Cost files

        ;     if (!A_IsCompiled) && (this.showGrayCheckbox = true) {
        ;         checked := this.showGrayFiles
        ;         Gui, minimapViewerCavebotGUI:Add, Checkbox, x+1 yp+0 gshowGrayFiles vshowGrayFiles Checked%checked%, Gray
        ;     }


        Gui, minimapViewerCavebotGUI:Add, Text, % "xs+0 ym+" this.guiOptions.h - 50, % (LANGUAGE = "PT-BR" ? "Coordenadas:" : "Coordinates:")
        Gui, minimapViewerCavebotGUI:Add, Edit, % "xp+0 y+3 vviewerCoordinates gviewerCoordinates h18 w" this.groupboxW - 20 " ReadOnly", % this.viewerX "," this.viewerY "," this.viewerZ

        return

    }

    viewerMinimapImagesCavebot() {
        global

        centerImageX := 32246
        centerImageY := 32223


        imageSize := this.guiElements.minimapImageSize

        spaceBetweenImages := 0

        Gui, minimapViewerCavebotGUI:Add, Picture, % "x" this.guiOptions.borderPx " y" this.guiOptions.borderPx " w" imageSize " h" imageSize " vminimapViewerImage gclickOnViewerMap AltSubmit Section",
        /**
        Gui, minimapViewerCavebotGUI:Add, Picture, % "x" this.guiElements.minimapImagesX " y" this.guiOptions.borderPx " w" imageSize " h" imageSize " vminimapImage1 Section", % this.minimapImagesString "_" this.imgCoords.1.x "_" this.imgCoords.1.y "_" this.imgCoords.1.z ".png"
        Gui, minimapViewerCavebotGUI:Add, Picture, x+%spaceBetweenImages% yp+0 w%imageSize% h%imageSize% vminimapImage2, % this.minimapImagesString "_" this.imgCoords.2.x "_" this.imgCoords.2.y "_" this.imgCoords.2.z ".png"
        Gui, minimapViewerCavebotGUI:Add, Picture, xs+0 y+%spaceBetweenImages% w%imageSize% h%imageSize% vminimapImage3, % this.minimapImagesString "_" this.imgCoords.3.x "_" this.imgCoords.3.y "_" this.imgCoords.3.z ".png"
        Gui, minimapViewerCavebotGUI:Add, Picture, x+%spaceBetweenImages% yp+0 w%imageSize% h%imageSize% vminimapImage4, % this.minimapImagesString "_" this.imgCoords.4.x "_" this.imgCoords.4.y "_" this.imgCoords.4.z ".png"
        */


    }

    imagePathParam(x, y, z) {
        ; MsgBox, % x "," y "," z
        this.minimapImagesString := TibiaClient.clientMinimapPath "\Minimap_" (this.showCostFiles = false ? "Color" : "WaypointCost")
        return this.minimapImagesString "_" x "_" y "_" z ".png"

    }

    updateImages() {
        this.guiControlGetCoordinates()
        this.changeImage(this.viewerX, this.viewerY, this.viewerZ)
    }

    changeImage(x, y, z) {
        this.cropFromMinimapImage(x, y, z)
    }

    navigateUp(amount := "") {
        amount := amount = "" ? this.zoomValue() : amount
        this.changeImage(this.viewerX, this.viewerY -= amount, this.viewerZ)
    }
    navigateDown(amount := "") {
        amount := amount = "" ? this.zoomValue() : amount
        this.changeImage(this.viewerX, this.viewerY += amount, this.viewerZ)
    }
    navigateLeft(amount := "") {
        amount := amount = "" ? this.zoomValue() : amount
        this.changeImage(this.viewerX -= amount, this.viewerY, this.viewerZ)
    }
    navigateRight(amount := "") {
        amount := amount = "" ? this.zoomValue() : amount
        this.changeImage(this.viewerX += amount, this.viewerY, this.viewerZ)
    }

    floorUp() {
        z := this.viewerZ + 1
        if (z > 15)
            return
        this.viewerZ += 1
        this.changeImage(this.viewerX, this.viewerY, this.viewerZ)
    }
    floorDown() {
        z := this.viewerZ - 1
        if (z < 0)
            return
        this.viewerZ -= 1
        this.changeImage(this.viewerX, this.viewerY, this.viewerZ)
    }

    updateFloorGui() {
        GuiControl, % (this.cavebotGUI = false ? "minimapViewerGUI:" : "minimapViewerCavebotGUI:"), floorLevel, % this.viewerZ
        GuiControl, % (this.cavebotGUI = false ? "minimapViewerGUI:" : "minimapViewerCavebotGUI:"), floorLevelGroupbox, % "Floor Level (" this.viewerZ ")"
    }

    changeFloorSlider() {
        this.setDefaultMinimapGUI()
        GuiControlGet, floorLevel
        if (floorLevel = this.viewerZ)
            return
        this.viewerZ := floorLevel
        this.changeImage(this.viewerX, this.viewerY, this.viewerZ)
    }

    updateZoomGui() {
        GuiControl, % (this.cavebotGUI = false ? "minimapViewerGUI:" : "minimapViewerCavebotGUI:"), zoomLevel, % this.zoomLevel
        GuiControl, % (this.cavebotGUI = false ? "minimapViewerGUI:" : "minimapViewerCavebotGUI:"), zoomLevelGroupbox, % "Zoom (" this.zoomLevel ")"
    }

    changeZoomLevel(value, changeControl := false) {
        if (value < this.minZoomLevel)
            value := this.minZoomLevel
        if (value > this.maxZoomLevel)
            value := this.maxZoomLevel

        if (value = this.zoomLevel)
            return

        this.zoomLevel := value
        this.updateImages()
    }

    zoomValue() {

        switch this.zoomLevel {
            case 1: return MinimapFiles.mapHeight / 2
            case 2: return MinimapFiles.mapHeight / 4
            case 3: return MinimapFiles.mapHeight / 8
            case 4: return MinimapFiles.mapHeight / 16
            case 5: return MinimapFiles.mapHeight / 32
            case 6: return MinimapFiles.mapHeight / 64
            case 7: return MinimapFiles.mapHeight / 128
            default:
                Msgbox, 48, % A_ThisFunc, % "Invalid zoom level: " this.zoomLevel
        }

    }

    getCoordinatesFromMousePosition() {

        this.setDefaultMinimapGUI()
        CoordMode, Mouse, Relative
        MouseGetPos, pictureX, pictureY, OutputVarWin, OutputVarControl
        pictureX -= this.guiOptions.borderPx * 2
        pictureY -= this.guiOptions.borderPx * 2

        size := this.zoomValue()
        size512 := size * 2

        switch MinimapFiles.mapHeight {
            case 2048:
                switch this.zoomLevel {
                    case 1:
                        pictureX := pictureX * 4
                        pictureY := pictureY * 4
                    case 2:
                        pictureX := pictureX * 2
                        pictureY := pictureY * 2
                    case 4:
                        pictureX := pictureX / 2
                        pictureY := pictureY / 2
                    case 5:
                        pictureX := pictureX / 4
                        pictureY := pictureY / 4
                    case 6:
                        pictureX := pictureX / 8
                        pictureY := pictureY / 8
                    case 7:
                        pictureX := pictureX / 16
                        pictureY := pictureY / 16
                }
            case 1536:
                switch this.zoomLevel {
                    case 1:
                        pictureX := pictureX * 3
                        pictureY := pictureY * 3
                    case 2:
                        pictureX := pictureX * 1.5
                        pictureY := pictureY * 1.5
                    case 3:
                        pictureX := pictureX * 0.75
                        pictureY := pictureY * 0.75
                    case 4:
                        pictureX := pictureX * 0.375
                        pictureY := pictureY * 0.375
                    case 5:
                        pictureX := pictureX / 5.333
                        pictureY := pictureY / 5.333
                    case 6:
                        pictureX := pictureX / 10.8
                        pictureY := pictureY / 10.8
                    case 7:
                        pictureX := pictureX / 22
                        pictureY := pictureY / 22
                }
        }

        ; msgbox, % this.currentCentral.x1 "`npic old:" pic "`npic new:" pictureX "`nzoom: " this.zoomLevel "`ndiff: " abs(pic - pictureX)
        minimapFileCoordX := this.currentCentral.x1 + pictureX
        minimapFileCoordY := this.currentCentral.y1 + pictureY
        CoordMode, Mouse, Screen

        ; msgbox, % serialize(this.currentCentral) "`n" pictureX "," pictureX "`n" minimapFileCoordX "," minimapFileCoordY


        return {x: minimapFileCoordX, y: minimapFileCoordY}
    }

    checkboxCostFiles() {
        this.showCostFiles := !this.showCostFiles
        this.updateImages()
    }

    checkboxGrayFiles() {
        this.showGrayFiles := !this.showGrayFiles
        this.updateImages()
    }

    checkboxShowCrosshair() {
        this.showCrosshair := !this.showCrosshair
        this.updateImages()
    }


    navigateFloor(direction) {
        switch direction {
            case "Up":
                this.floorUp()
            case "Down":
                this.floorDown()
        }

    }

    changeButton(action, direction) {
        GuiControl, minimapViewerGUI:%action%, minimapButton%direction%
    }

    enableAllButtonsButCurrent(current) {
        buttons := {}
        buttons.Push("Up")
        buttons.Push("Down")
        buttons.Push("Left")
        buttons.Push("Right")

        for key, direction in buttons
        {
            if (direction = current)
                continue
            GuiControl, minimapViewerGUI:Enable, minimapButton%direction%
        }
    }

    navigate(direction, sqms := 1) {
        this.guiControlGetCoordinates()

        switch direction {
            case "Up":
                this.navigateUp(sqms)
                ; this.enableAllButtonsButCurrent(direction)
            case "Down":
                this.navigateDown(sqms)
                ; this.enableAllButtonsButCurrent(direction)
            case "Left":
                this.navigateLeft(sqms)
                ; this.enableAllButtonsButCurrent(direction)
            case "Right":
                this.navigateRight(sqms)
                ; this.enableAllButtonsButCurrent(direction)
        }

    }

    waypointFilesPath(x, y, z) {
        ret := {}

        try waypointFile1 := MinimapFiles.getWaypointFileName(x, y, z, "Color")
        catch e
            throw e
        ret.Push(waypointFile1)

        try waypointFile2 := MinimapFiles.getWaypointFileName(x + this.zoomValue(), y, z, "Color")
        catch e
            throw e
        ret.Push(waypointFile2)

        try waypointFile3 := MinimapFiles.getWaypointFileName(x, y + this.zoomValue(), z, "Color")
        catch e
            throw e
        ret.Push(waypointFile3)

        try waypointFile4 := MinimapFiles.getWaypointFileName(x + this.zoomValue(), y + this.zoomValue(), z, "Color")
        catch e
            throw e
        ret.Push(waypointFile4)
        return ret
    }

    cropFromMinimapImage(x, y, z) {
        if (this.drawingActions = true)
            return


        this.drawingActions := true



        size := this.zoomValue()
        size512 := size * 2


        verticalLimit := MinimapFiles.mapHeight - (size512)
        horizontalLimit := MinimapFiles.mapWidth - (size512)

        clickOnImage := false
        if (x < 3000)
            clickOnImage := true


        ; m( "x: " x ", y:" y  "`n" clickOnImage)

        if (clickOnImage = false) {

            coordX := x
            coordY := y
            try this.validateCoords(x, y, z)
            catch e {
                this.drawingActions := false
                msgbox, 48,, % e.Message, 6
                return
            }
            coords := MinimapFiles.getWaypointFilePosition(x, y)
        } else {
            coordX := tibiaMapX1 + x
            coordY := tibiaMapY1 + y

            coords := {}
            coords.x := x
            coords.y := y
        }


        try MinimapFiles.createSingleBitmapFloorsGraphic(z, this.showCostFiles = false ? "Color" : "Cost", deletePrevious := true)
        catch e {
            this.drawingActions := false
            return
            if (A_IsCompiled)
                Msgbox, 64, % "Map viewer", % "Could not render map for this floor level.", 2
            else
                Msgbox, 64, % "Map viewer", % e.Message, 2
            return
        }

        coords.x := coords.x > MinimapFiles.mapWidth ? MinimapFiles.mapWidth : coords.x
        coords.y := coords.y > MinimapFiles.mapHeight ? MinimapFiles.mapHeight : coords.y

        this.currentCentral := {}
        this.currentCentral.x := coords.x
        this.currentCentral.y := coords.y


        ; msgbox, % abs((coords.x + 256) - MinimapFiles.mapWidth)




        crops := {}
        crops.left := (coords.x - size)
        crops.right := abs((coords.x + size) - MinimapFiles.mapWidth)
        crops.up := (coords.y - size)
        crops.down := (coords.y + size) - MinimapFiles.mapHeight

        crops.up := crops.up < 0 ? 0 : crops.up
        crops.left := crops.left < 0 ? 0 : crops.left

        crops.down := crops.down < 0 ? abs(crops.down) : 0
        crops.right := crops.right < 0 ? 0 : crops.right


        value := abs(crops.down - MinimapFiles.mapHeight)
        ; msgbox, % crops.down " / " value
        if (value < size512)
            crops.down -= abs(size512 - value)

        value := abs(crops.right - MinimapFiles.mapWidth)
        ; msgbox, % crops.right " / " value
        if (value < size512)
            crops.right -= abs(size512 - value)



        ; msgbox, % serialize(this.currentCentral)


        verticalValid := abs(crops.down - crops.up)
        if (verticalValid > verticalLimit) {
            if (crops.up > verticalLimit)
                crops.up := verticalLimit
        }


        horizontalValid := abs(crops.left - crops.right)
        if (crops.left > horizontalLimit) {
            crops.left := horizontalLimit

            crops.right := crops.left >= horizontalLimit ? 0 : crops.right

        }

        this.currentCentral.x1 := crops.left
        this.currentCentral.y1 := crops.up



        ; msgbox, % serialize(coords) "`n`n"  serialize(crops)  "`n`nv: " verticalValid " / " verticalLimit "`nh: " horizontalValid " / " horizontalLimit

        floorString := (StrLen(z) = 1) ? "0" z : z
        try this.pBitmapViewerImage := Gdip_CropBitmap(MinimapFiles.pMinimapFloors[floorString]
            , Left := crops.left
            , Right := crops.right
            , Up := crops.up
            , Down := crops.down
            , true)
        catch e {
            this.drawingActions := false
            MinimapFiles.deleteSingleBitmapFloorsGraphic(z)
            Msgbox,64,, % e.Message, 6
            return
        }

        G := Gdip_GraphicsFromImage(this.pBitmapViewerImage), Gdip_SetSmoothingMode(G, 4), Gdip_SetInterpolationMode(G, 7)

        bitmapWidth := 512
        bitmapHeight := 512

        this.drawImages := {}
        this.drawImages.x := 0
        this.drawImages.y := 0

        Gdip_DrawImage(G, this.pBitmapViewerImage, this.drawImages.x, this.drawImages.y, bitmapWidth, bitmapWidth, 0, 0, bitmapWidth, bitmapHeight)

        ; Gdip_SetBitmapToClipboard(this.pBitmapViewerImage)
        ; msgbox, % "Gdip_SetBitmapToClipboard(this.pBitmapViewerImage)`nfloorString: " floorString

        this.drawCrosshair(coords)


        hBitmapGUI:=Gdip_CreateHBITMAPFromBitmap(this.pBitmapViewerImage)
        GuiControl, % (this.cavebotGUI = false ? "minimapViewerGUI:" : "minimapViewerCavebotGUI:"), minimapViewerImage, % "HBITMAP:*" hBitmapGUI
        DeleteObject(hBitmapGUI), hBitmapGUI := ""

        Gdip_DeleteGraphics(G)

        ; Gdip_SaveBitmapToFile(this.pBitmapViewerImage, (costFiles = false) ? MinimapFiles.minimapImagesFolder "\floor-" floorString "-map" worldChangeString "-new.png" : MinimapFiles.minimapImagesFolder "\floor-" floorString "-path" worldChangeString "-new.png")

        Gdip_DisposeImage(this.pBitmapViewerImage), this.pBitmapViewerImage := ""

        ; msgbox, % serialize(crops) "`n`n" serialize(this.currentCentral)

        this.changeCoordinatesControl(coordX, coordY, z)
        this.updateFloorGui()
        this.updateZoomGui()
        if (this.cavebotGUI = true) {
            GuiControl, minimapViewerCavebotGUI:, setCavebotFloorLevel, % "Set Cavebot Floor Level (" this.viewerZ ")"
        }
        Sleep, 50
        this.drawingActions := false
    }

    drawCrosshair(coords) {
        if (this.showCrosshair = false)
            return



        pinCoords := {}
        size := this.zoomValue()
        size512 := size * 2


        verticalLimit := MinimapFiles.mapHeight - (size512)

        horizontalLimit := MinimapFiles.mapWidth - (size512)

        ; pinCoords.x := size
        ; pinCoords.y := size
        startX := size > coords.x ? coords.x : size
        startY := size > coords.y ? coords.y : size


        bottomCorner := verticalLimit - coords.y
        rightCorner := horizontalLimit - coords.x
        negativeSize := "-" size
        if (bottomCorner < negativeSize)
            startY := abs(bottomCorner)
        if (rightCorner < negativeSize)
            startX := abs(rightCorner)
        ; Gdip_SetBitmapToClipboard(this.pBitmapViewerImage)
        ; msgbox, % startX "," startY "`n`n"  serialize(coords) "`n" size "`n" rightCorner
        ; startY := coords.y > 512 ? (coords.y) : startY

        /**1234567
        1    *
        2    *
        3 *** ***
        4    *
        5    *
        */
        switch this.zoomLevel {
            case 7, case 6, case 5, case 4: pinSize := 3
            case 3:  pinSize := 5
            case 2: pinSize := 10
            case 1: pinSize := 20
        }
        pinCenter := pinSize / 2

        startX -= pinSize / 2
        startY -= pinSize / 2

        rows := {}
        Loop, % pinSize {
            rows[A_Index] := {}
        }

        switch pinSize {
            case 3:
                rowNumber := 1
                Loop, % pinSize {
                    trans := (A_Index = pinCenter) ? false : true
                    rows[rowNumber].Push({x: A_Index, y: rowNumber, transparent: trans})
                }
                rowNumber := 2
                Loop, % pinSize {
                    trans := (A_Index = pinCenter) ? true : false
                    rows[rowNumber].Push({x: A_Index, y: rowNumber, transparent: trans})
                }
                rowNumber := 3
                Loop, % pinSize {
                    trans := (A_Index = pinCenter) ? false : true
                    rows[rowNumber].Push({x: A_Index, y: rowNumber, transparent: trans})
                }

            case 5:
                lastRow := 0
                Loop, 2 {
                    rowNumber := lastRow + A_Index
                    Loop, % pinSize {
                        trans := (A_Index = pinCenter) ? false : true
                        rows[rowNumber].Push({x: A_Index, y: rowNumber, transparent: trans})
                    }
                }
                rowNumber := 3
                Loop, % pinSize {
                    trans := (A_Index = pinCenter) ? true : false
                    rows[rowNumber].Push({x: A_Index, y: rowNumber, transparent: trans})
                }
                lastRow := 3
                Loop, 2 {
                    rowNumber := lastRow + A_Index
                    Loop, % pinSize {
                        trans := (A_Index = pinCenter) ? false : true
                        rows[rowNumber].Push({x: A_Index, y: rowNumber, transparent: trans})
                    }
                }

            case 10:
                lastRow := 0
                Loop, 4 {
                    rowNumber := lastRow + A_Index
                    Loop, % pinSize {
                        trans := (A_Index = pinCenter) ? false : true
                        rows[rowNumber].Push({x: A_Index, y: rowNumber, transparent: trans})
                        rows[rowNumber].Push({x: A_Index + 1, y: rowNumber, transparent: trans})
                    }
                }
                lastRow := 4
                Loop, 2 {
                    rowNumber := lastRow + A_Index
                    Loop, % pinSize {
                        trans := (A_Index = pinCenter) ? true : false
                        rows[rowNumber].Push({x: A_Index, y: rowNumber, transparent: trans})
                    }
                }
                lastRow := 6
                Loop, 4 {
                    rowNumber := lastRow + A_Index
                    Loop, % pinSize {
                        trans := (A_Index = pinCenter) ? false : true
                        rows[rowNumber].Push({x: A_Index, y: rowNumber, transparent: trans})
                        rows[rowNumber].Push({x: A_Index + 1, y: rowNumber, transparent: trans})
                    }
                }

            case 20:
                lastRow := 0
                Loop, 8 {
                    rowNumber := lastRow + A_Index
                    Loop, % pinSize {
                        trans := (A_Index = pinCenter) ? false : true
                        rows[rowNumber].Push({x: A_Index, y: rowNumber, transparent: trans})
                        rows[rowNumber].Push({x: A_Index + 1, y: rowNumber, transparent: trans})
                        rows[rowNumber].Push({x: A_Index + 2, y: rowNumber, transparent: trans})
                        rows[rowNumber].Push({x: A_Index + 3, y: rowNumber, transparent: trans})
                    }
                }
                lastRow := 8
                Loop, 4 {

                    rowNumber := lastRow + A_Index
                    Loop, % pinSize {
                        trans := (A_Index = pinCenter) ? true : false
                        rows[rowNumber].Push({x: A_Index, y: rowNumber, transparent: trans})
                    }

                }
                lastRow := 12
                Loop, 8 {
                    rowNumber := lastRow + A_Index
                    Loop, % pinSize {
                        trans := (A_Index = pinCenter) ? false : true
                        rows[rowNumber].Push({x: A_Index, y: rowNumber, transparent: trans})
                        rows[rowNumber].Push({x: A_Index + 1, y: rowNumber, transparent: trans})
                        rows[rowNumber].Push({x: A_Index + 2, y: rowNumber, transparent: trans})
                        rows[rowNumber].Push({x: A_Index + 3, y: rowNumber, transparent: trans})
                    }
                }
        } ; switch



        for k, row in rows
        {
            for key, value in row
            {
                ; color := this.viewerZ = 7 ? "0xFF000000" : "0xFFFFFFFF"
                color := this.crossHairColor
                if (value.transparent = true) {
                    try {
                        color := Gdip_GetPixel(this.pBitmapViewerImage, startX + value.x, startY + value.y, A_ThisFunc)
                    } catch {
                    }
                    SetFormat, Integer, D
                }
                try Gdip_SetPixel(this.pBitmapViewerImage, startX + value.x, startY + value.y, color)
                catch {
                }
            }

        }
    }

    validateCoords(x := "", y := "", z := "") {
        _Validation.mapCoordinates("", x, y, z)
    }

    setDefaultMinimapGUI() {
        if (this.cavebotGUI = false)
            Gui, minimapViewerGUI:Default
        else
            Gui, minimapViewerCavebotGUI:Default

    }

    guiControlGetCoordinates() {
        this.setDefaultMinimapGUI()

        GuiControlGet, viewerCoordinates

        coords := StrSplit(viewerCoordinates, ",")

        this.viewerX := coords.1
        this.viewerY := coords.2
        this.viewerZ := coords.3
    }

    changeCoordinatesControl(x, y, z := "") {
        if (z = "") {
            this.guiControlGetCoordinates()
            z := this.viewerZ
        }
        this.viewerX := x
        this.viewerY := y
        this.viewerZ := z
        GuiControl, % (this.cavebotGUI = false ? "minimapViewerGUI:" : "minimapViewerCavebotGUI:"), viewerCoordinates, % this.viewerX "," this.viewerY "," this.viewerZ
    }

    minimapViewerMenu() {
        Menu, minimapViewerMenu, Show
    }

    addWaypointFromViewer(type) {
        if (tab = "") {
            Msgbox, 48, Add waypoint, No tab selected.
            return false
        }

        Gui, CavebotGUI:Default
        GuiControlGet, RangeWaypointWidth
        GuiControlGet, RangeWaypointHeight

        GUIControl := "AddWaypoint_" type
        CavebotGUI.beforeAddWaypointGuiControls(GUIControl)

        this.guiControlGetCoordinates()
        posx := this.viewerX
        posy := this.viewerY
        posz := this.viewerZ
        try WaypointHandler.addWaypointValidation(tabName = "" ? tab : tabName, type, RangeWaypointWidth ? RangeWaypointWidth : 3, RangeWaypointHeight ? RangeWaypointHeight : 3)
        catch, e {
            CavebotGUI.addWaypointException(e)
            CavebotGUI.afterAddWaypointGuiControls(GUIControl)
            return false
        }

        CavebotGUI.afterAddWaypointGuiControls(GUIControl)

        return true
    }


    copyToCustomMinimapFolder() {
        Gui, minimapViewerGUI:Submit, NoHide
        this.guiControlGetCoordinates()

        try this.validateCoords(this.viewerX, this.viewerY, this.viewerZ)
        catch e {
            msgbox, 48,, % e.Message, 6
            return
        }

        try waypointFile := MinimapFiles.getWaypointFileName(this.viewerX, this.viewerY, this.viewerZ, "Color")
        catch e {
            Msgbox,48,, % e.Message, 6
            return
        }
        try waypointCostFile := MinimapFiles.getWaypointFileName(this.viewerX, this.viewerY, this.viewerZ, "Cost")
        catch e {
            Msgbox,48,, % e.Message, 6
            return
        }
        try customFolderName := this.createCustomMinimapFolder()
        catch e {
            Msgbox,48,, % e.Message, 6
            return
        }
        if (customFolderName = "")
            return


        try FileCopy, % waypointFile, % customFolderName, 1
        catch e {
            Msgbox,48,, % "Failed to copy waypoint file to folder.`nFile: " waypointFile "`nFolder: " customFolderName "`n`nDetails: " e.Message " | " e.What, 6
            return
        }
        try FileCopy, % waypointCostFile, % customFolderName, 1
        catch e {
            Msgbox,48,, % "Failed to copy waypoint file to folder.`nFile: " waypointCostFile "`nFolder: " customFolderName "`n`nDetails: " e.Message " | " e.What, 6
            return
        }
        TrayTipMessage("Success", "Minimap filed copied.")
    }


    createCustomMinimapFolder() {
        InputBox, customFolderName, Custom folder name, Waypoint files must be stored inside a folder in the "Custom Minimap" folder.`nEnter any name for the folder to create and copy the image to.`n`nFolder name:,, 300, 207,,,,, %lastCreatedMinimapFolder%
        if (customFolderName = "")
            return
        if (StrLen(customFolderName) < 4)
            throw Exception("The name must have at least 3 letters.")

        lastCreatedMinimapFolder := customFolderName
        IniWrite, % lastCreatedMinimapFolder, %DefaultProfile%, mapViewer, lastCreatedMinimapFolder

        dir := MinimapFiles.customMinimapFolder "\" customFolderName
        try FileCreateDir, % dir
        catch e
            throw Exception("Failed to create folder")

        return dir

    }

    destroyButtonIcons() {

        Loop, % minimapViewerGUI_ICON_COUNTER {
            ; msgbox, % "a " minimapViewer_ICONBUTTONS%A_Index%
            IL_Destroy(minimapViewer_ICONBUTTONS%A_Index%)
            minimapViewer_ICONBUTTONS%A_Index% := ""
            ; msgbox, % "b " minimapViewer_ICONBUTTONS%A_Index%
        }
        minimapViewerGUI_ICON_COUNTER := 0
    }


    minimapGuiButtonIcon(Handle, File, Index := 1, Options := "") {
        global
        RegExMatch(Options, "i)w\K\d+", W), (W="") ? W := 16 :
        RegExMatch(Options, "i)h\K\d+", H), (H="") ? H := 16 :
        RegExMatch(Options, "i)s\K\d+", S), S ? W := H := S :
        RegExMatch(Options, "i)l\K\d+", L), (L="") ? L := 0 :
        RegExMatch(Options, "i)t\K\d+", T), (T="") ? T := 0 :
        RegExMatch(Options, "i)r\K\d+", R), (R="") ? R := 0 :
        RegExMatch(Options, "i)b\K\d+", B), (B="") ? B := 0 :
        RegExMatch(Options, "i)a\K\d+", A), (A="") ? A := 4 :
        Psz := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"
        VarSetCapacity( button_il, 20 + Psz, 0 )
        NumPut( minimapViewer_ICONBUTTONS%minimapViewerGUI_ICON_COUNTER% := DllCall( "ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1 ), button_il, 0, Ptr )   ; Width & Height
        NumPut( L, button_il, 0 + Psz, DW )     ; Left Margin
        NumPut( T, button_il, 4 + Psz, DW )     ; Top Margin
        NumPut( R, button_il, 8 + Psz, DW )     ; Right Margin
        NumPut( B, button_il, 12 + Psz, DW )    ; Bottom Margin
        NumPut( A, button_il, 16 + Psz, DW )    ; Alignment
        SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %Handle%
        IL_Add( minimapViewer_ICONBUTTONS%minimapViewerGUI_ICON_COUNTER%, File, Index )
        minimapViewerGUI_ICON_COUNTER++
        ; msgbox, % minimapViewerGUI_ICON_COUNTER
        ; return IL_Add( minimapViewer_ICONBUTTONS, File, Index )        return
    }


    MinimapViewerHotkeysGUI() {
        guiW := 480

        fontSize := 10

        Gui, MinimapViewerHotkeysGUI:Destroy
        Gui, MinimapViewerHotkeysGUI:+AlwaysOnTop +Owner -MinimizeBox +0x200000
        Gui, MinimapViewerHotkeysGUI:Font, s%fontSize%

        hotkeys := {}
        hotkeys.Push("Title: Move map")
        hotkeys.Push({hotkey: "Scroll Up/Down", desc: "Change Zoom"})
        hotkeys.Push({hotkey: "Ctrl + Scroll Up/Down", desc: "Change Zoom focusing in mouse position"})
        hotkeys.Push({hotkey: "Alt + Scroll Up/Down", desc: "Change Floor Level"})
        hotkeys.Push({hotkey: "Arrows", desc: "Move 1 sqm"})
        hotkeys.Push({hotkey: "Ctrl + Arrows", desc: "Move 5 sqms"})
        hotkeys.Push({hotkey: "Shift + WASD", desc: "Move 1 sqm"})
        hotkeys.Push({hotkey: "Ctrl + WASD", desc: "Move 5 sqms"})
        hotkeys.Push("<br>")
        hotkeys.Push("Title: Add Waypoint")
        hotkeys.Push({hotkey: "W || Middle Button", desc: "Add ""Walk"" waypoint"})
        hotkeys.Push({hotkey: "S || Shift + Middle Button", desc: "Add ""Stand"" waypoint"})
        hotkeys.Push({hotkey: "L || Ctrl + Middle Button", desc: "Add ""Ladder"" waypoint"})
        hotkeys.Push({hotkey: "R || Alt + Middle Button", desc: "Add ""Rope"" waypoint"})
        hotkeys.Push("<br>")
        hotkeys.Push({hotkey: "A", desc: "Add ""Action"" waypoint"})
        hotkeys.Push({hotkey: "D", desc: "Add ""Door"" waypoint"})
        hotkeys.Push({hotkey: "U", desc: "Add ""Use"" waypoint"})
        hotkeys.Push({hotkey: "R", desc: "Add ""Rope"" waypoint"})
        hotkeys.Push({hotkey: "H", desc: "Add ""Shovel"" waypoint"})
        hotkeys.Push({hotkey: "M", desc: "Add ""Machete"" waypoint"})
        hotkeys.Push("<br>")
        hotkeys.Push("Title: Navigation")
        hotkeys.Push({hotkey: "Alt + W", desc: "Send ""Walk"""})
        hotkeys.Push({hotkey: "Alt + S", desc: "Send ""Stand"""})
        hotkeys.Push({hotkey: "Alt + Shift + R", desc: "Send ""Rope"""})
        hotkeys.Push({hotkey: "Alt + H", desc: "Send ""Shovel"""})
        hotkeys.Push({hotkey: "Alt + 1", desc: "Send ""Action 1"""})
        hotkeys.Push({hotkey: "Alt + 2", desc: "Send ""Action 2"""})
        hotkeys.Push({hotkey: "Alt + 3", desc: "Send ""Action 3"""})

        w := 185
        for key, value in hotkeys
        {
            if (value = "<br>") {
                Gui, MinimapViewerHotkeysGUI:Add, Text, x10 y+1 w%w% Section, % ""
                continue
            }
            if (InStr(value, "Title: ")) {
                title := StrReplace(value, "Title: ", "")

                Gui, MinimapViewerHotkeysGUI:Font, s16 bold
                Gui, MinimapViewerHotkeysGUI:Add, Text, x10 y+5 w250 Section, % title
                Gui, MinimapViewerHotkeysGUI:Font, norm
                Gui, MinimapViewerHotkeysGUI:Font, s%fontSize%
                continue

            }
            Gui, MinimapViewerHotkeysGUI:Add, Text, x10 y+5 w%w% Section, % "[ " value.hotkey " ]"
            Gui, MinimapViewerHotkeysGUI:Add, Text, x+5 yp+0, % value.desc

        }

            new _Text().title("As hotkeys tem efeito somente quando a janela do Map Viewer está em foco", "The hotkeys have effect only when the Map Viewer window is focused")
            .x(10).y("+10").w(guiW - 20)
            .center()
            .color("gray")
            .gui("MinimapViewerHotkeysGUI")
            .add()



        Gui, MinimapViewerHotkeysGUI:Show, w%guiW% h600, Map Viewer Hotkeys
    }


    minimapViewerStatusBar() {
        Gui, minimapViewerGUI:Default


        clientTooltip := TibiaClient.clientMinimapPath = "" ? "Minimap folder path not set" : TibiaClient.clientMinimapPath
        SB_SetText("Minimap folder: " clientTooltip, 1)
    }

    minimapDirectoryGUI() {
        global
        Gui, minimapDirectoryGUI:Destroy
        Gui, minimapDirectoryGUI:+AlwaysOnTop -MinimizeBox +Owner

        w := 450
        if (isTibia13()) {
            Gui, minimapDirectoryGUI:Add, Text, x10 y+5, % (LANGUAGE = "PT-BR" ? "Copie e cole (Ctrl+V) o diretório da pasta ""minimap"":" : "Copy and paste (Ctrl+V) the ""minimap"" folder directory:")
        } else {
            Gui, minimapDirectoryGUI:Add, Text, x10 y+5, % (LANGUAGE = "PT-BR" ? "Copie e cole (Ctrl+V) o diretório da pasta onde o arquivo ""minimap.otmm"" está:" : "Copy and paste (Ctrl+V) the directory where the ""minimap.otmm"" file is:")
        }
        Gui, minimapDirectoryGUI:Add, Edit, x10 y+3 vclientMinimapDirectory w%w% h22, % minimapFolder
        Gui, minimapDirectoryGUI:Add, Button, x10 y+5 0x1 w150 h25 gsubmitMinimapFolder, % "Save Directory"

        Gui, minimapDirectoryGUI:Font, cGray
        if (isTibia13()) {
            ; Gui, minimapDirectoryGUI:Add, Text, x10 y+10, % (LANGUAGE = "PT-BR" ? "Exemplo para " TibiaClient.Tibia13Identifier " (global):" : "Example for " TibiaClient.Tibia13Identifier " (global):")
            ; Gui, minimapDirectoryGUI:Add, Edit, x10 y+3 ReadOnly h20 w%w% -VScroll, % "C:\Users\XXXXX\AppData\Local\Tibia\packages\Tibia\minimap"
            Gui, minimapDirectoryGUI:Add, Text, x10 y+10, % (LANGUAGE = "PT-BR" ? "Exemplo para " TibiaClient.Tibia13Identifier " (Taleon OT):" : "Example for " TibiaClient.Tibia13Identifier " (Taleon OT):")
            Gui, minimapDirectoryGUI:Add, Edit, x10 y+3 ReadOnly h20 w%w% -VScroll, % "C:\Users\XXXXX\Documents\TaleonClient\minimap"
        } else {
            Gui, minimapDirectoryGUI:Add, Text, x10 y+10, % (LANGUAGE = "PT-BR" ? "Exemplo para KingdomSwap:" : "Example for KingdomSwap:")
            Gui, minimapDirectoryGUI:Add, Edit, x10 y+3 ReadOnly h20 w%w% -VScroll, % "C:\Users\XXXXX\AppData\Roaming\OTClientV8\KingdomSwapATS"

            Gui, minimapDirectoryGUI:Add, Text, x10 y+10, % (LANGUAGE = "PT-BR" ? "Exemplo para Nostalrius:" : "Example for Nostalrius:")
            Gui, minimapDirectoryGUI:Add, Edit, x10 y+3 ReadOnly h20 w%w% -VScroll, % "C:\Users\XXXXX\AppData\Roaming\Nostalrius\Nostalrius_V01"
        }
        Gui, minimapDirectoryGUI:Font
        Gui, minimapDirectoryGUI:Show,, % (LANGUAGE = "PT-BR" ? "Diretório da pasta do Minimap" : "Minimap folder directory")
    }

    loadingDisableMinimapGUI(startLoading := true) {
        switch startLoading {
            case true:
                ; Gui, minimapViewerGUI:+Disabled
                OldBotSettings.disableGuisLoading()
            default:
                ; Gui, minimapViewerGUI:-Disabled
                OldBotSettings.enableGuisLoading()
        }
    }

    getCoordsFromMemoryText() {
        switch (OldbotSettings.settingsJsonObj.tibiaClient.tibia12) {
            case true:
                return (LANGUAGE = "PT-BR" ? "As coordenadas são obtidas da memória do cliente para o cliente atual(" OldbotSettings.settingsJsonObj.tibiaClient.memoryIdentifier "), o mapa mostrado no Map Viewer é de um mapa padrão do " TibiaClient.Tibia13Identifier "(ou o último mapa gerado da pasta minimap) e pode não ser igual ao mapa real do cliente."  : "The coordinates are obtained from the memory for the current client(" OldbotSettings.settingsJsonObj.tibiaClient.memoryIdentifier "), the map shown in the Map Viewer is just a ilustration of a default map from 12 and can be different from the real map of the client.")
            default:
                return (LANGUAGE = "PT-BR" ? "As coordenadas são obtidas da memória do cliente para o cliente atual(" OldbotSettings.settingsJsonObj.tibiaClient.memoryIdentifier "), o mapa mostrado no Map Viewer é de um mapa padrão do Tibia 7.4 e pode não ser igual ao mapa real do cliente."  : "The coordinates are obtained from the memory for the current client(" OldbotSettings.settingsJsonObj.tibiaClient.memoryIdentifier "), the map shown in the Map Viewer is just a ilustration of a default map from Tibia 7.4 and can be different from the real map of the client.")
        }
    }

    sendNavigation(action)
    {
        MinimapGUI.guiControlGetCoordinates()
        range := instanceOf(action, _NavigationStand) ? 1 : 2
        try {
            _Navigation.sendFromMapViewer(action, new _MapCoordinate(MinimapGUI.viewerX, MinimapGUI.viewerY, MinimapGUI.viewerZ, range))
        } catch e {
            TrayTipMessage("Map Viewer", e.Message, 4, true)
        }
    }
} ; Class