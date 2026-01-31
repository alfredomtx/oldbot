

global waypointAtributeTab
global waypointAtributeNumber
global waypointAtributeName
global waypointAtributeValue

Class _CavebotHandler
{

    getEditWaypointTypesOptions()
    {
        static waypointTypes
        if (waypointTypes) {
            return waypointTypes
        }

        waypointTypes := {}
        waypointTypes.Push("Action")
        waypointTypes.Push("Walk")
        waypointTypes.Push("Stand")

        if (isRavendawn()) {
            waypointTypes.Push("Ladder")

            return waypointTypes
        }

        if (!OldBotSettings.settingsJsonObj.settings.cavebot.automaticFloorDetection) {
            waypointTypes.Push("Ladder Up")
            waypointTypes.Push("Ladder Down")
            waypointTypes.Push("Stair Up")
            waypointTypes.Push("Stair Down")
        } else {
            waypointTypes.Push("Ladder")
        }

        waypointTypes.Push("Door")
        waypointTypes.Push("Use")
        waypointTypes.Push("Rope")
        waypointTypes.Push("Shovel")
        waypointTypes.Push("Machete")

        return waypointTypes
    }

    editWaypointAtributeGUI(waypointNumber, atribute)
    {
        global

        guiW := 170

        waypointAtributeName := atribute
        waypointAtributeNumber := waypointNumber
        waypointAtributeTab := tab

        Gui, editWaypointAtributeGUI:Destroy
        Gui, editWaypointAtributeGUI:+AlwaysOnTop -MinimizeBox +Owner

        saveButtonY := "+15"

        switch atribute {
            case "Label":
                saveButtonY := "45"

                Gui, editWaypointAtributeGUI:Add, Text, x10 y5, Label:
                Gui, editWaypointAtributeGUI:Add, Edit, x10 y+3 veditWaypointLabel h18 w150, % WaypointHandler.getAtribute("label", waypointAtributeNumber, waypointAtributeTab)

                Gui, editWaypointAtributeGUI:Add, Text, x170 y5 Section, Special Labels:

                labels := ""
                rows := CavebotSystem.specialLabels.Count()
                for key, label in CavebotSystem.specialLabels
                {
                    labels .= label "`n"
                }

                Gui, editWaypointAtributeGUI:Add, Edit, xs+0 y+5 w120 r%rows% -VScroll -Hscroll ReadOnly hwndhspecialLabels, % labels

                TT.Add(hspecialLabels, txt("Special Labels são usados para waypoints que serão executados em momentos específicos, e devem ser usados em waypoints de ""Action"" em uma aba com o nome ""Special"".`nPor exemplo, em um waypoint com o label ""BeforeAttack"", esse waypoint será executado sempre antes de o Targeting atacar um monstro"".", "Special Labels are used for waypoints that will be ran in specific moments, and must be used in ""Action"" waypoints in a tab named ""Special"".`n`nFor example, in a waypoint with the label ""BeforeAttack"", this waypoint will run everytime before the Targeting attacks a monster."))


            case "Range":
                Gui, editWaypointAtributeGUI:Add, Text, x10 y+5, Range:
                Gui, editWaypointAtributeGUI:Add, Edit, x10 y+3 veditWaypointRange h18 w150, % WaypointHandler.getDisplayRangeSize(waypointAtributeNumber, waypointAtributeTab)
                Gui, editWaypointAtributeGUI:Font, cGray
                Gui, editWaypointAtributeGUI:Add, Text, x10 y+5 w150, % "TIP: If you write ""3"", a ""3 x 3"" range will be set."
                Gui, editWaypointAtributeGUI:Font
            case "Coordinates":
                atributes := waypointsObj[tab][waypointNumber]
                switch scriptSettingsObj.cavebotFunctioningMode {
                    case "markers":
                        if (atributes.type = "Action")
                            return

                        waypointAtributeName := "marker"
                        if (waypointsObj[tab][waypointNumber].image != "")
                            waypointAtributeName := "image"

                        CavebotGUI.selectMarkerGUI(waypointAtributeNumber)
                        return

                    default:

                        c := atributes.coordinates
                        Gui, editWaypointAtributeGUI:Add, Text, x10 y+10, x:
                        Gui, editWaypointAtributeGUI:Add, Edit, x+5 yp-2 veditWaypointX h18 w135, % atributes.coordinates.x
                        Gui, editWaypointAtributeGUI:Add, Updown, 0x80 Range0-9999999, % atributes.coordinates.x

                        Gui, editWaypointAtributeGUI:Add, Text, x10 y+7, y:
                        Gui, editWaypointAtributeGUI:Add, Edit, x+5 yp-2 veditWaypointY h18 w135, % atributes.coordinates.y
                        Gui, editWaypointAtributeGUI:Add, Updown, 0x80 Range0-9999999, % atributes.coordinates.y

                        Gui, editWaypointAtributeGUI:Add, Text, x10 y+7, z:
                        Gui, editWaypointAtributeGUI:Add, Edit, x+5 yp-2 veditWaypointZ h18 w135, % atributes.coordinates.z
                        Gui, editWaypointAtributeGUI:Add, Updown, 0x80 Range0-15, % atributes.coordinates.z


                        if (isTibia13()) {
                            Gui, editWaypointAtributeGUI:Add, Button, x10 y+5 w150 gopenCoordsTibiaMapViewer, Open in Map Viewer
                            Gui, editWaypointAtributeGUI:Add, Button, x10 y+5 w150 gopenCoordsTibiaMaps, Open in TibiaMaps.io
                        }

                        Gui, editWaypointAtributeGUI:Add, Button, x10 y+5 w150 gcopyCoords, Copy Coordinates


                }
            case "Type":
                switch scriptSettingsObj.cavebotFunctioningMode {
                    case "markers":
                        return

                    default:
                        waypointTypes := this.getEditWaypointTypesOptions()
                        rows := waypointTypes.Count()

                        Gui, editWaypointAtributeGUI:Add, Text, x10 y+5, Type:
                        Gui, editWaypointAtributeGUI:Add, Listbox, x10 y+3 veditWaypointType w150 r%rows%, % _Arr.concat(waypointTypes, "|")
                        GuiControl, editWaypointAtributeGUI:ChooseString, editWaypointType, % WaypointHandler.getAtribute("type", waypointAtributeNumber, waypointAtributeTab)
                }
        }

        Gui, editWaypointAtributeGUI:Add, Button, x10 y%saveButtonY% 0x1 w150 geditWaypointAtributeLabel, Save %atribute%

        if (atribute = "Coordinates") {
            this.specialArea(c)
        }

        Gui, editWaypointAtributeGUI:Show, % "w" guiW, [WP %waypointAtributeNumber%] %atribute%
    }

    specialArea(c)
    {
        specialArea := _SpecialAreas.get(c.x, c.y, c.z)


        if (specialArea) {
            try {
                _AbstractControl.SET_DEFAULT_GUI_NAME("editWaypointAtributeGUI")

                    new _Groupbox().line()
                    .x(10).y().w(guiW)
                    .add()

                    new _Text().title("Special Area")
                    .xs().y()
                    .font("bold")
                    .font("s12")
                    .add()

                    new _Text().title("Tipo:", "Type:")
                    .xs().y()
                    .font("bold")
                    .add()
                    new _Text().title(specialArea.getType())
                    .xadd().yp()
                    .add()

                    new _Text().title("Caminhável:", "Walkable:")
                    .xs().y()
                    .font("bold")
                    .add()
                    new _Text().title(boolToString(specialArea.isWalkable()))
                    .xadd().yp()
                    .add()

                image := specialArea.getImage()
                if (image) {
                    this.image := new _Picture().name("specialAreaImage")
                        .xs().y()
                        .add()

                    this.bitmap := new _BitmapImage(image)

                    this.image.bitmap(this.bitmap)
                }
            } catch e {
                _Logger.msgboxException(16, e, A_ThisFunc)
            } finally {
                this.bitmap.dispose()
                _AbstractControl.RESET_DEFAULT_GUI()
            }
        }

    }
}