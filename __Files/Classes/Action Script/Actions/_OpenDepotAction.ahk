
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Action Script\Actions\_AbstractDepositAction.ahk

class _OpenDepotAction extends _AbstractDepositAction
{
    static IDENTIFIER := "opendepot"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    runAction()
    {
        this.info(ActionScript.string_log)

        /*
        check if the depot locker window is opened and click to return if it is
        */
        vars := ""
        try {
            vars := ImageClick({"image": ImagesConfig.depositer.depotWindow
                    , "directory": ImagesConfig.depositerFolder
                    , "variation": 40
                    , "funcOrigin": A_ThisFunc
                    , "debug": false})
        } catch e {
            _Logger.exception(e, A_ThisFunc)
        }
        if (vars.x) {
            MouseClick("Left", vars.x + 142, vars.y + 4)
            Sleep, 600
        }

        depotWindow := this.openDepotAround(false)

        if (depotWindow) {
            return depotWindow
        }

        if (!this.searchDepotSQM()) {
            msg := txt("Verifique se a opção do cliente ""Graphics"" > ""Scale Using Only Integral Multiples"" está MARCADA.", "Check if the client option ""Graphics"" > ""Scale Using Only Integral Multiples"" is CHECKED.")

                new _Notification().title(txt("Depot não encontrado", "Depot not found"))
                .message(msg)
                .timeout(12)
                .warning()
                .show()

            writeCavebotLog("ERROR", txt("Falha ao andar para o SQM de depot.", "Failed to walk to depot SQM.") " " msg)
            return false
        }
        /*
        wait a bit before clicking in the sqms around, to rist the char walk 1 sqm away from the orange sqm
        */
        Sleep, 500

        depotWindow := this.openDepotAround()
        if (depotWindow = false) {
            writeCavebotLog("ERROR", "Depot window not found")
            return false
        }

        return depotWindow
    }

    searchDepotSQM()
    {
        static gameWindowArea, images
        if (!gameWindowArea) {
            gameWindowArea := new _GameWindowArea()
        }

        if (!images) {
            images := {}
            images.Push("OSQ_1")
            images.Push("OSQ_2")
            images.Push("OSQ_3")
            images.Push("OSQ_4")
            images.Push("OSQ_5")
            images.Push("OSQ_6")
            images.Push("OSQ_7")
            images.Push("OSQ_8")
            images.Push("OSQ_9")
            images.Push("OSQ_10")
        }

        writeCavebotLog("Action", "Searching depot sqm..")
        Loop, 2 {
            index := A_Index
            for key, sqmImage in images
            {
                switch sqmImage {
                    case "OSQ_4":
                        variation := 1
                    case "OSQ_5", case "OSQ_6":
                        loopCount := 10
                        variation := 1
                    case "OSQ_9", case "OSQ_10":
                        loopCount := 1
                        variation := 6
                    default:
                        loopCount := 1
                        variation := 4
                }
                Loop, % loopCount {
                    this.sqmImageIndex := key
                    try {
                        _search := new _ImageSearch()
                            .setFile(sqmImage)
                            .setFolder(ImagesConfig.depositerFolder)
                            .setVariation(variation)
                            .setArea(gameWindowArea)
                            .search()
                    } catch e {
                        _Logger.exception(e, A_ThisFunc)
                    }

                    if (_search.found()) {
                        break
                    }

                    Sleep, loopCount = 1 ? 25 : 75
                }

                if (_search.found()) {
                    break
                }
            }

            if (_search.found()) {
                break
            }

            if (index = 2)
                Sleep, 500
        }

        if (_search.notFound()) {
            writeCavebotLog("ERROR", txt("Nenhum SQM de depot encontrado. Confirme que há algum SQM laranja de depot visível. Tente com a Configuração do Cliente em ""Graphics"" > ""Scale Using Only Integral Multiples"" MARCADA", "None depot SQMs found. Ensure that there is a free orange depot SQM visible. try with the Client Setting on ""Graphics"" > ""Scale Using Only Integral Multiples"" CHECKED"))
            return false
        }

        switch sqmImage {
                /*
                adjust for the sqm position found be in the center of the sqm
                */
            case "OSQ_5", case "OSQ_6":
                sqmModifierX += gameWindowArea.getSqmSize() / 2
                sqmModifierY += gameWindowArea.getSqmSize() / 2 - (gameWindowArea.getSqmSize() / 3)
            case "OSQ_7", case "OSQ_8":
                sqmModifierX -= 0
                sqmModifierY += gameWindowArea.getSqmSize() / 2
            default:
                sqmModifierX += gameWindowArea.getSqmSize() / 2
                sqmModifierY := gameWindowArea.getSqmSize() / 2
        }

        this.orangeSqmX := _search.getX() + sqmModifierX
        this.orangeSqmY := _search.getY() + sqmModifierY

        if (CavebotScript.isMarker()) {
            writeCavebotLog("Action", "Walking to depot sqm (" this.orangeSqmX "," this.orangeSqmY ")..")
            MouseClick("left", this.orangeSqmX, this.orangeSqmY)
            Sleep, 5000
            return true
        }
        ; mousemove, windowX + this.orangeSqmX,windowy + this.orangeSqmY
        ; msgbox, % "index: " this.sqmImageIndex
        this.walkToOrangeSQM()
    }
}