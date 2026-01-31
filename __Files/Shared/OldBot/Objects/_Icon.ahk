
class _Icon
{
    static LIST 

    static ARROW_DOWN := "arrowDown"
    static ARROW_UP := "arrowUp"
    static AUTO_RECORD := "autoRecord"
    static CAMERA := "camera"
    static CHECK := "check"
    static CHECK_RED := "checkRed"
    static CHECK_ROUND := "checkRound"
    static CHECK_ROUND_WHITE := "checkRoundWhite"
    static CHECK_SETTINGS := "checkSettings"
    static CLOUD := "cloud"
    static DELETE := "delete"
    static DELETE_ROUND := "deleteRound"
    static DELETE_SQUARE := "deleteSquare"
    static DUPLICATE := "duplicate"
    static EYE := "eye"
    static EXCLAMATION := "exclamation"
    static FOLDER := "folder"
    static OPEN_FILE := "fileArrowRight"
    static LAPTOP := "laptop"
    static KEYBOARD := "keyboard"
    static INTERROGATION := "interrogation"
    static IMAGE := "image"
    static MAP := "map"
    static MOUSE := "mouse"
    static MOUSE_POINTER := "mousePointer"
    static MOVE_ITEM := "moveItem"
    static MULTI_MONITOR := "multiMonitor"
    static MONEY := "money"
    static MONITOR := "monitor"
    static OLDBOT := "oldbot"
    static PLUS := "plus"
    static PIN := "pin"
    static REDUCE := "reduce"
    static RELOAD := "reload"
    static SETTINGS := "settings"
    static STAR := "star"
    static SQUARE := "square"
    static SQUARES := "squares"
    static TIBIA := "tibia"
    static TIBIA_CHECK := "tibiaCheck"
    static USER := "user"
    static UNDO := "undo"
    static YOUTUBE := "youtube"
    static WARNING := "warning"


    __New(dllName, number)
    {
        this.dllName := dllName
        this.number := number
    }

    VIEW()
    {
        Gui, Icons:+AlwaysOnTop, 

        size := 40
        button := new _Button()
            .x().yp().size(size)
            .gui("Icons")

        index := 0
        for name, icon in this.getList()
        {
            btn := button.clone()
            (index = 20) ? btn.xs().y() : btn.yp()

            btn.icon(icon, options := "a0 l0 b0 s" size - 6)
                .add()

            index++
        }

        Gui, Icons:Show, h100, Icons
    }

    getList()
    {
        if (_Icon.LIST) {
            return _Icon.LIST
        }

        list := {}
        list[_Icon.ARROW_DOWN] := new this("shell32.dll", 248)
        list[_Icon.ARROW_UP] := new this("shell32.dll", 247)
        list[_Icon.AUTO_RECORD] := new this("shell32.dll", 294)
        list[_Icon.CAMERA] := new this("shell32.dll", 196)
        list[_Icon.CLOUD] := new this("imageres.dll", isWin11() ? 233 : 232)
        list[_Icon.CHECK] := new this("shell32.dll", isWin11() ? 295 : 297)
        list[_Icon.CHECK_RED] := new this("shell32.dll", 145)
        list[_Icon.CHECK_ROUND] := new this("imageres.dll", isWin11() ? 234 : 233)
        list[_Icon.CHECK_ROUND_WHITE] := new this("imageres.dll", isWin11() ? 229 : 228)
        list[_Icon.CHECK_SETTINGS] := new this("imageres.dll", 110)
        list[_Icon.DELETE] := new this("imageres.dll", isWin11() ? 261 : 260)
        list[_Icon.DELETE_ROUND] := new this("imageres.dll", isWin11() ? 231 : 230)
        list[_Icon.DELETE_SQUARE] := new this("imageres.dll", isWin11() ? 237 : 236)
        list[_Icon.DUPLICATE] := new this("imageres.dll", isWin11() ? 298 : 297)
        list[_Icon.EXCLAMATION] := new this("shell32.dll", 278)
        list[_Icon.FOLDER] := new this("shell32.dll", 5)
        list[_Icon.KEYBOARD] := new this("ddores.dll", (A_OSVersion >= "10.0.22631") ? 31: 29)
        list[_Icon.LAPTOP] := new this("ddores.dll", 13)
        list[_Icon.INTERROGATION] := new this("shell32.dll", 24)
        list[_Icon.IMAGE] := new this("imageres.dll", 109)
        list[_Icon.EYE] := new this("Data\Files\Images\GUI\icons\emojis\eye.png", 0)
        list[_Icon.PLUS] := new this("Data\Files\Images\GUI\icons\emojis\plus.png", 0)
        list[_Icon.PIN] := new this("imageres.dll", isWin11() ? 235 : 234)
        list[_Icon.REDUCE] := new this("imageres.dll", isWin11() ? 227 : 226)
        list[_Icon.RELOAD] := new this("imageres.dll", isWin11() ? 230 : 229)
        list[_Icon.MAP] := new this("ieframe.dll", 35)
        list[_Icon.MOUSE_POINTER] := new this("accessibilitycpl.dll", isWin11() ? 15 : 17)
        list[_Icon.MOVE_ITEM] := new this("imageres.dll", isWin11() ? 281 : 280)
        list[_Icon.MULTI_MONITOR] := new this("shell32.dll", 19)
        list[_Icon.MONITOR] := new this("setupapi.dll", 32)
        list[_Icon.MONEY] := new this("mmcndmgr.dll", 109)
        list[_Icon.SETTINGS] := new this("shell32.dll", isWin11() ? 315 : 317)
        list[_Icon.STAR] := new this("shell32.dll", 209)
        list[_Icon.SQUARE] := new this("shell32.dll", 246)
        list[_Icon.SQUARES] := new this("imageres.dll", isWin11() ? 250 : 249)
        list[_Icon.OLDBOT] := new this("Data\Files\Images\GUI\icons\icon.ico", 0)
        list[_Icon.OPEN_FILE] := new this("imageres.dll", isWin11() ? 279 : 278)
        list[_Icon.TIBIA_CHECK] := new this("Data\Files\Images\GUI\icons\icon_tibia_check.png", 0)
        list[_Icon.USER] := new this("imageres.dll", isWin11() ? 84 : 209)
        list[_Icon.UNDO] := new this("imageres.dll", isWin11() ? 257 : 256)
        list[_Icon.YOUTUBE] := new this("Data\Files\Images\GUI\Icons\third_part\youtube.ico", 0)
        list[_Icon.WARNING] := new this("imageres.dll", isWin11() ? 232 : 231)
        list[_Icon.TIBIA] := new this("Data\Files\Images\GUI\icons\icon_ravendawn.ico", 0)

        return _Icon.LIST := list
    }

    get(name)
    {
        icon := this.getList()[name]
        if (!icon) {
            throw Exception("Icon not found: " name)
        }

        return icon 
    }
}