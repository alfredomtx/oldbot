saveCavebotScriptTimer() {
    CavebotScript.saveSettings(A_ThisLabel)
    return
}

copyToClipboard(string) {
    Loop, 3 {
        try {
            Clipboard := string
            break
        } catch {
            Sleep, 100
            if (A_index = 3)
                return false
        }
    }
    return true
}

VerificarOldBotAberto(message := false) {
    if (InStr(A_ScriptName, "$77")) {
        return
    }

    PID := _ProcessHandler.readExePID("OldBotExeName")
    if (empty(PID)) {
        if (message = true) {
            Msgbox, 48,, OldBot is not opened.
        }
        ExitApp
    }

    Process,Exist,%PID%
    ; msgbox, %PID% %ErrorLevel%
    If (ErrorLevel = 0) {
        if (message = true) {
            Msgbox, 48,, OldBot is not opened.
        }
        ExitApp
    }

    if ErrorLevel = 1
        return
}

; hide tray tip and keep no tray icon
HideTrayTipFunctions() {
    Menu, Tray, Icon
    TrayTip ; Attempt to hide it the normal way.
    if SubStr(A_OSVersion,1,3) = "10." {
        Menu Tray, NoIcon
        Sleep 200 ; It may be necessary to adjust this sleep.
        Menu Tray, Icon
    }
    Menu, Tray, NoIcon
    return
}

CriarVariavel(var, value, debug := false) {
    global
    if (debug)
        msgbox, var = %var%
    if (var = "")
        return
    StringReplace, var, var, %A_Space%,, All
    IfInString, var, ischeckbox_
        StringReplace, var, var, ischeckbox_,, All
    IfInString, var, isnumber_
        StringReplace, var, var, isnumber_,, All
    IfInString, var, ishotkey_
        StringReplace, var, var, ishotkey_,, All
    IfInString, var, ispotion_
        StringReplace, var, var, ispotion_,, All
    IfInString, var, issupply_
        StringReplace, var, var, issupply_,, All
    IfInString, var, isvocation_
        StringReplace, var, var, isvocation_,, All
    IfInString, var, isvocation2_
        StringReplace, var, var, isvocation2_,, All
    IfInString, var, ishidden_
        StringReplace, var, var, ishidden_,, All
    try
        %var% := value
    catch
        return
    if (debug)
        msgbox, %var% = %value%
    return
}

ValidateHotkey(GUI := "", varname := "", hotkey_ := "") {
    result := []
    result["erro"] := 0
    result["msg"] := ""
    if (hotkey_ = "") {
        return %result%
    }

    IfInString, hotkey_, ^
    {
        result["erro"]++
        result["msg"] := LANGUAGE = "PT-BR" ? "Hotkeys com Ctrl, Shift ou Alt não são permitidas." : "Hotkeys with Ctrl, Shift or Alt are not allowed."
    }
    IfInString, hotkey_, !
    {
        result["erro"]++
        result["msg"] := LANGUAGE = "PT-BR" ? "Hotkeys com Ctrl, Shift ou Alt não são permitidas." : "Hotkeys with Ctrl, Shift or Alt are not allowed."
    }
    ifInString, hotkey_, +
    {
        result["erro"]++
        result["msg"] := LANGUAGE = "PT-BR" ? "Hotkeys com Ctrl, Shift ou Alt não são permitidas." : "Hotkeys with Ctrl, Shift or Alt are not allowed."
    }
    ; ifInString, hotkey_, Num
    ; {
    ;     result["erro"]++
    ;     result["msg"] := LANGUAGE = "PT-BR" ? "Hotkeys com Numpad não são permitidas." : "Hotkeys with Numpad are not allowed."
    ; }
    if (RegExMatch(hotkey_,"(Caps|Tab|Back|Space)")) {
        result["erro"]++
        result["msg"] := LANGUAGE = "PT-BR" ? "Hotkey inválida." : "Invalid hotkey."
    }
    special_char := containsSpecialCharacter(hotkey_)
    if (special_char = 1) {
        result["erro"]++
        result["msg"] := LANGUAGE = "PT-BR" ? "Caractéres especiais não são permitidos como hotkey." : "Special characters are not allowed as hotkey."
    }

    if (result["erro"] > 0) {
        try {
            if (GUI != "")
                GuiControl, %GUI%:, %varname%, % ""
            else
                GuiControl,, %varname%, % ""
        }
        catch
            return
    }
    return %result%

}

WinActivate() {
    WinActivate, ahk_id %TibiaClientID%
    return
}

WinWaitActive() {
    WinWaitActive, ahk_id %TibiaClientID%
    return
}

InfoCarregando(text)
{
    try {
        GuiControl, Carregando:, info, %text%
    } catch {
    }
}

CarregandoGUI(text, text_width := 150, progress_width := 150, gui_color := "", font_color := "", x := "", y := 10, show_bar := false) {
    global
    Gui, Carregando:Destroy
    Gui, Carregando:-Caption +Border +Toolwindow +AlwaysOnTop
    ; if (gui_color != "")
    ; Gui, Carregando:Color, %gui_color%
    if (font_color != "")
        Gui, Carregando:Font, c%font_color%
    Gui, Carregando:Add, Text, vinfo w%text_width% r1, %text%
    if (show_bar = true) {
        Gui, Carregando:Add, Progress, y+10 HwndpHwnd1 +0x8 w%progress_width%
        PostMessage,0x40a,1,38,, ahk_id %pHwnd1%
    }
    if (x != "" && y != "")
        Gui, Carregando:Show, x%x% y%y% NoActivate,
    else if (x != "")
        Gui, Carregando:Show, x%x% NoActivate,
    else if (y != "")
        Gui, Carregando:Show, y%y% NoActivate,
    else
        Gui, Carregando:Show, NoActivate,

    return
}

CarregandoGUI2(text, text_width := 150, progress_width := 150, x := "", y := 10) {
    global
    Gui, Carregando2:Destroy
    Gui, Carregando2:-Caption +Border +Toolwindow +AlwaysOnTop
    Gui, Carregando2:Add, Text, vinfo w%text_width%, %text%
    Gui, Carregando2:Add, Progress, y+10 HwndpHwnd1 +0x8 w%progress_width%
    PostMessage,0x40a,1,38,, ahk_id %pHwnd1%
    if (x != "" && y != "")
        Gui, Carregando2:Show, x%x% y%y% NoActivate,
    else if (x != "")
        Gui, Carregando2:Show, x%x% NoActivate,
    else if (y != "")
        Gui, Carregando2:Show, y%y% NoActivate,
    else
        Gui, Carregando2:Show, NoActivate,

    return
}

FileToBase64(file_to_read) {
    try FileGetSize, nBytes, %file_to_read%
    catch e {
        Msgbox, 48, % A_ThisFunc, % "Failed to get file size: " file_to_read "`nError: " A_LastError
        return false
    }
    FileRead, Bin, *c %file_to_read%
    B64Data := Base64Enc( Bin, nBytes, 100, 2 )
    StringReplace, B64Data, B64Data, `n,, All
    StringReplace, B64Data, B64Data, %A_Space%,, All

    ; MsgBox % Clipboard := B64Data
    return %B64Data%
}

GdipCreateFromBase64(ByRef Base64, HICON := 0) {
    if (!DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &Base64, "UInt", 0, "UInt", 0x01, "Ptr", 0, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)) {
        return False
    }

    VarSetCapacity(Dec, DecLen, 0)

    if (!DllCall("Crypt32.dll\CryptStringToBinary", "Ptr", &Base64, "UInt", 0, "UInt", 0x01, "Ptr", &Dec, "UIntP", DecLen, "Ptr", 0, "Ptr", 0)) {
        return False
    }

    pStream := DllCall("Shlwapi.dll\SHCreateMemStream", "Ptr", &Dec, "UInt", DecLen, "UPtr")
    DllCall("Gdiplus.dll\GdipCreateBitmapFromStreamICM", "Ptr", pStream, "PtrP", pBitmap)

    if (HICON) {
        DllCall("Gdiplus.dll\GdipCreateHICONFromBitmap", "Ptr", pBitmap, "PtrP", hBitmap, "UInt", 0)
    }

    ObjRelease(pStream)

    return (HICON ? hBitmap : pBitmap)
}

Base64ToFile(Base64Var, outfile) {
    ; outfile := "ahkiconnew.png"
    if (Base64Var = "")
        throw Exception("Empty image hash to convert.")

    pBitmap := GdipCreateFromBase64(Base64Var) ; 640x384 Base64 encoded PNG image string returned as HBITMAP

    Gdip_SaveBitmapToFile(pBitmap, outfile, 100)

    Gdip_DisposeImage(pBitmap), DeleteObject(pBitmap), pBitmap := ""
    ; Gui, base64image:Add, Picture,, %outfile%
    ; Gui, base64image:Show
    return
}

Base64encUTF8( ByRef OutData, ByRef InData ) { ; by SKAN + my modifications to encode to UTF-8
    InDataLen := StrPutVar(InData, InData, "UTF-8") - 1
    DllCall( "Crypt32.dll\CryptBinaryToStringW", UInt,&InData, UInt,InDataLen, UInt,1, UInt,0, UIntP,TChars, "CDECL Int" )
    VarSetCapacity( OutData, Req := TChars * ( A_IsUnicode ? 2 : 1 ), 0 )
    DllCall( "Crypt32.dll\CryptBinaryToStringW", UInt,&InData, UInt,InDataLen, UInt,1, Str,OutData, UIntP,Req, "CDECL Int" )
    return TChars
}

Base64decUTF8( ByRef OutData, ByRef InData ) { ; by SKAN + my modifications to decode base64 whose text was encoded to utf-8 beforehand
    DllCall( "Crypt32.dll\CryptStringToBinaryW", UInt,&InData, UInt,StrLen(InData), UInt,1, UInt,0, UIntP,Bytes, Int,0, Int,0, "CDECL Int" )
    VarSetCapacity( OutData, Req := Bytes * ( A_IsUnicode ? 2 : 1 ), 0 )
    DllCall( "Crypt32.dll\CryptStringToBinaryW", UInt,&InData, UInt,StrLen(InData), UInt,1, Str,OutData, UIntP,Req, Int,0, Int,0, "CDECL Int" )
    OutData := StrGet(&OutData, "cp0")
    return Bytes
}

Base64Dec( ByRef B64, ByRef Bin ) { ; By SKAN / 18-Aug-2017
    Local Rqd := 0, BLen := StrLen(B64) ; CRYPT_STRING_BASE64 := 0x1
    DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
        , "UInt",0, "UIntP",Rqd, "Int",0, "Int",0 )
    VarSetCapacity( Bin, 128 ), VarSetCapacity( Bin, 0 ), VarSetCapacity( Bin, Rqd, 0 )
    DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
        , "Ptr",&Bin, "UIntP",Rqd, "Int",0, "Int",0 )
    return Rqd
}

Base64Enc( ByRef Bin, nBytes, LineLength := 64, LeadingSpaces := 0 ) { ; By SKAN / 18-Aug-2017
    Local Rqd := 0, B64, B := "", N := 0 - LineLength + 1 ; CRYPT_STRING_BASE64 := 0x1
    DllCall( "Crypt32.dll\CryptBinaryToString", "Ptr",&Bin ,"UInt",nBytes, "UInt",0x1, "Ptr",0, "UIntP",Rqd )
    VarSetCapacity( B64, Rqd * ( A_Isunicode ? 2 : 1 ), 0 )
    DllCall( "Crypt32.dll\CryptBinaryToString", "Ptr",&Bin, "UInt",nBytes, "UInt",0x1, "Str",B64, "UIntP",Rqd )
    If ( LineLength = 64 and ! LeadingSpaces )
        return B64
    B64 := StrReplace( B64, "`r`n" )
    Loop % Ceil( StrLen(B64) / LineLength )
        B .= Format("{1:" LeadingSpaces "s}","" ) . SubStr( B64, N += LineLength, LineLength ) . "`n"
    return RTrim( B,"`n" )
}

;GuiControlEdit
GuiControlEdit(GUI, vName, NewValue, gLabel := "") {
    GuiControl, %GUI%:-g, %vName%
    GuiControl, %GUI%:, %vName%, %NewValue%
    try {
        if (gLabel = "") {
            try GuiControl, %GUI%:+g%vName%, %vName%
            catch {
            }
        } else{
            try GuiControl, %GUI%:+g%gLabel%, %vName%
            catch {
            }
        }
    } catch e {
        ; if (!A_IsCompiled)
        ; Msgbox,48,, % A_ThisFunc "`n`n" GUI ", " vName ", " NewValue ", " gLabel "`n`n" e.Message "`n" e.What "`n" e.Line "`n" e.File
        return
    }
    try
        HwndVar := h%vName%
    catch
        return
    if (HwndVar != "") {
        HwndText := %vName%_HwndText
        SetEditCueBanner(%HwndVar%, "" HwndText "")
    }
    return
}

CheckEditValue(EditControl, MinValue, MaxValue, GUI, gLabel := "", triggerLabelOnChange := false) {
    try control_value := %EditControl%
    catch
        return
    changeControl := false
    if (control_value < MinValue) OR (control_value > MaxValue) {
        if (control_value < MinValue) {
            value := MinValue
            changeControl := true
        }
        if (control_value > MaxValue) {
            value := MaxValue
            changeControl := true
        }
        if (changeControl = false)
            return

        if (triggerLabelOnChange = false)
            GuiControlEdit(GUI, EditControl, value, gLabel)
        else
            GuiControl, %GUI%:, %EditControl%, % value
    }
    return
}

checkPrefixEdit(GUI, control, prefix, minValue, maxValue, gLabel := "", ClassControl := "") {
    Gui, %GUI%:Default
    GuiControlGet, %control%

    value := %control%

    ; msgbox, % GUI "`n control = " control "`n value = " value "`n prefix = " prefix "`n minValue = " minValue "`n maxValue = " maxValue "`n gLabel = " gLabel
    value := LTrim(RTrim(value))
    if (InStr(value, prefix)) {
        string := StrSplit(value, prefix)
        value := LTrim(RTrim(string.1))
    }

    if (InStr(value, " ")) {
        string := StrSplit(value, " ")
        value := LTrim(RTrim(string.1))
    }

    if value is not number
        value := minValue

    if (value < minValue)
        value := minValue

    if (value > maxValue)
        value := maxValue

    ; value += 5
    ; GuiControl, %GUI%:, %control%, % value " " prefix
    GuiControlEdit(GUI, control, value " " prefix, gLabel)
    switch ClassControl {
        case "Healing":
            HealingHandler.submitHealingOption(control, false)

    }
    return

}

SetEditCueBanner(HWND, Cue) { ; requires AHL_L

    Static EM_SETCUEBANNER := (0x1500 + 1)

    return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)

}

msgbox_image(text, image_path, rows := 2) {
    global
    Gui, Carregando:Destroy
    Gui, MessageBox:Destroy
    Gui, MessageBox:-MinimizeBox +AlwaysOnTop

    Gui, MessageBox:Add, Picture, x20 y20 vmsg_img_hidden hidden, %image_path%
    GuiControlGet, pos_img_hidden, MessageBox:Pos, msg_img_hidden
    if (pos_img_hiddenW < 250)
        text_width := 250
    else
        text_width := pos_img_hiddenW - 25

    ; aumentar as rows do texto e ajustar de acordo com o tamanho
    if (rows > 2)
        y1 := 25, y2 := 20
    else
        y1 := 20, y2 := 25
    Gui, MessageBox:Add, Picture, x20 y%y1%, Data\Files\Images\GUI\Others\warning_icon.png
    Gui, MessageBox:Add, text, x+15 y%y2% w%text_width% vmsg_text r%rows%, %text%
    GuiControlGet, pos_text, MessageBox:Pos, msg_text
    if (pos_textH < 30)
        y := "+25"
    else
        y := "+15"
    Gui, MessageBox:Add, Picture, x20 y%y% vmsg_img, %image_path%
    GuiControlGet, pos_img, MessageBox:Pos, msg_img
    ; msgbox, % pos_imgW
    Gui, MessageBox:Add, Groupbox, x20 y+3 w%pos_imgW% h8 cBlack
    Gui, MessageBox:Add, Button, x20 y+5 w135 h30 vmsg_button hwndFecharMsg_Button gMessageBoxGuiClose, % LANGUAGE = "PT-BR" ? "Fechar mensagem" : "Close message"
    ; GuiButtonIconOriginal(FecharMsg_Button, "imageres.dll", 260, "a0 l5 s20 b0")
    GuiControlGet, pos_bt, MessageBox:Pos, msg_text
    ; msgbox, %posY%
    height := pos_btY + 70
    SoundPlay, *48
    Gui, MessageBox:Show, , % LANGUAGE = "PT-BR" ? "Aviso OldBot" : "Warn OldBot"
    Loop, {
        Sleep, 200
        WinGetTitle, MsgboxTitle, % LANGUAGE = "PT-BR" ? "Aviso OldBot" : "Warn OldBot"
        if (MsgboxTitle = "") {
            break
        }
    }
    return
    MessageBoxGuiEscape:
    MessageBoxGuiClose:
    Gui, MessageBox:Destroy
    return
}

ImageClick(params) {
    /**
    default var values
    */
    params.x1 := (params.x1 = "") ? 0 : params.x1
        , params.y1 := (params.y1 = "") ? 0 : params.y1
        , params.x2 := (params.x2 = "") ? 0 : params.x2
        , params.y2 := (params.y2 = "") ? 0 : params.y2
        , params.variation := (params.variation = "") ? 1 : params.variation
        , params.firstResult := (params.firstResult = "") ? true : params.firstResult
        , params.funcOrigin := (params.funcOrigin = "") ? "ImageClick" : params.funcOrigin
        , params.menuClickDefaultMethod := (params.menuClickDefaultMethod = "") ? true : params.menuClickDefaultMethod
        , params.debug := (params.debug = "") ? false : params.debug

    _Validation.empty("params.image", params.image)

    if (!RegExMatch(params.image,"(.png)"))
        params.image .= ".png"

    filePath := (params.directory = "" ? "" : params.directory "\") params.image
    _Validation.fileExists("filePath", filePath)

    if (isAnyEmpty(params.x2, params.y2)) {
        coordinates := new _WindowArea().getCoordinates()
    } else {
        try {
            c1 := new _Coordinate(params.x1, params.y1)
            c2 := new _Coordinate(params.x2, params.y2)
            coordinates := new _Coordinates(c1, c2)
            coordinates.validate()
        } catch e {
            throw e
        }
    }

    try {
        _search := new _ImageSearch()
            .setPath(filePath)
            .setVariation(params.variation)
            .setTransColor(params.transColor)
            .setAllResults(!params.firstResult)
            .setCoordinates(coordinates)
            .setDebug(params.debug)
            .search()
    } catch e {
        error := A_Hour ":" A_Min ":" A_Sec " " A_MDay "/" A_Mon " | [ERROR] " A_ScriptName "." A_ThisFunc " origin: " funcOrigin " | " e.Message " | " e.What " | " e.Extra " | " e.Line
        OutputDebug(A_ThisFunc, error)
        FileAppend, % error "`n", Data\Files\logs_error_imagesearch.txt
        throw e
    }

    if (params.click != "") {
        if (params.firstResult = false)
            throw Exception("Click param is set (" params.click ") and first result param is not.")

        _search
            .setClickOffsetX(params.offsetX)
            .setClickOffsetY(params.offsetY)
            .click(params.click)
    }

    return _search.getResult()
}


ImageList_Create(cx,cy,flags,cInitial,cGrow) {
    return DllCall("comctl32.dll\ImageList_Create", "int", cx, "int", cy, "uint", flags, "int", cInitial, "int", cGrow)
}

ConvertARGB(ARGB) {
    SetFormat, IntegerFast, Hex
    RGB += ARGB
    RGB := RGB & 0x00FFFFFF
    return RGB
}

GuiButtonIcon(Handle, File, Index := 1, Options := "") {

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
    NumPut( normal_il%ICON_COUNTER% := DllCall( "ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1 ), button_il, 0, Ptr ) ; Width & Height
    NumPut( L, button_il, 0 + Psz, DW ) ; Left Margin
    NumPut( T, button_il, 4 + Psz, DW ) ; Top Margin
    NumPut( R, button_il, 8 + Psz, DW ) ; Right Margin
    NumPut( B, button_il, 12 + Psz, DW ) ; Bottom Margin
    NumPut( A, button_il, 16 + Psz, DW ) ; Alignment
    SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %Handle%
    IL_Add( normal_il%ICON_COUNTER%, File, Index )
    CriarVariavel("normal_il" ICON_COUNTER, normal_il%ICON_COUNTER%)
    ICON_COUNTER++
    ; return IL_Add( normal_il, File, Index )
    return
}

SleepR(min, max) {
    random, delay, %min%, %max%
    sleep, %delay%
    return
}

IsBlacklistVar(variable_name) {
    blacklist_var := false
    for key, value in blacklist_variables_read
    {

        if (variable_name = value) && (value != "")
            blacklist_var := true

    }
    return %blacklist_var%
}

;ScreenshotTela()
ScreenshotTela(img_filename, clientScreenshot := false) {
    outfile := "Data\Screenshots\" . img_filename . ".png"
    if (clientScreenshot = true) {
        if (backgroundImageSearch = false)
            Bm := Gdip_BitmapFromScreen(WindowX "|" WindowY "|" WindowWidth "|" WindowHeight)
        else
            Bm := _BitmapEngine.getClientBitmap().get()
        if (Bm = 0 OR Bm = "") {
            ; msgbox, % " aaaaaaaaa Bm = " Bm " | pToken = " pToken " | TibiaClientTitle = " TibiaClientTitle
            Loop, {
                Gdip_DisposeImage(pBitmap)
                Gdip_DisposeImage(Bm)
                DeleteObject(Bm)
                DeleteObject(ErrorLevel)
                Sleep, 100
                ; Bm := Gdip_BitmapFromScreen(WindowX "|" WindowY "|" WindowWidth "|" WindowHeight)
                if (backgroundImageSearch = false)
                    Bm := Gdip_BitmapFromScreen(WindowX "|" WindowY "|" WindowWidth "|" WindowHeight)
                else
                    Bm := BitmapEngine.getClientBitmap().get()
                ; msgbox, % " bbbbbbbbbb Bm = " Bm " | pToken = " pToken " | TibiaClientTitle = " TibiaClientTitle
                if (Bm != 0 && Bm != "")
                    break
            }
        }
        Gdip_SaveBitmapToFile(Bm, outfile, 100)
    } else {
        pBitmap:=Gdip_BitmapFromScreen(0 "|" 0 "|" A_ScreenWidth "|" A_ScreenHeight)
        if (pBitmap = 0 OR pBitmap = "0" OR pBitmap = "-1") {
            return
        }
        Gdip_SaveBitmapToFile(pBitmap, outfile, 100)
    }
    Gdip_DisposeImage(pBitmap)
    Gdip_DisposeImage(Bm)
    DeleteObject(Bm)
    DeleteObject(ErrorLevel)
    return
}

IsSettingScriptTab(tab_name) {
    if (tab_name = "Configurações Script" OR tab_name = "Script Settings")
        return true
    else
        return false
}

;tirar_screenshot()
tirar_screenshot(CustomGUIName, filename, width, height,foldername, Cor := "Red", Transparencia := 120, mov_mouse_left := false, dont_control := false) {
    global img_filename := filename
    global img_width := width
    global img_height := height
    global folder := foldername
    global guiname := CustomGUIName
    global move_mouse_left := mov_mouse_left
    global dont_change_control := dont_control
    MouseGetPos, actual_pos_x, actual_pos_y
    actual_pos_x = % actual_pos_x - img_width/2+1
    actual_pos_y = % (actual_pos_y - img_height/2+1)
    global colorGUI := Cor
    global transparency := Transparencia
    ; Gui screen_box: +alwaysontop -Caption +Border +ToolWindow +LastFound
    ; Gui, screen_box: Color, %Cor%
    ; WinSet, Transparent, %Transparencia% ; Else Add transparency
    ; Gui, screen_box: Show, w%img_width% h%img_height% x%actual_pos_x% y%actual_pos_y% NoActivate, ScreenBoxID
    sleep, 20
    SetTimer, move_box, 100
    WinActivate()
    Loop {
        Tooltip, % (LANGUAGE = "PT-BR" ? "Pressione ""Esc"" para cancelar`n""Espaço"" para capturar" : "Press ""Esc"" to cancel`n""Space"" to take")
        Sleep, 25
        if (GetKeyState("LButton") = true)
            break
        if (GetKeyState("Space") = true)
            break

        if (GetKeyState("Esc") = true) {
            Tooltip
            SetTimer, move_box, Off
            Gui, screen_box: Cancel
            Gui, screen_box: Destroy
            return false
        }

    }
    Tooltip
    Goto, take_screen_shot
    return
    move_box:
    MouseGetPos, even_more_actual_pos_x, even_more_actual_pos_y
    even_more_actual_pos_x = % even_more_actual_pos_x - img_width/2
    even_more_actual_pos_y = % (even_more_actual_pos_y - img_height/2)
    Sleep, 25
    Gui screen_box: +alwaysontop -Caption +Border +ToolWindow +LastFound
    Gui, screen_box: Color, %colorGUI%
    Sleep, 25
    WinSet, Transparent, %transparency% ; Else Add transparency
    Gui, screen_box: Show, w%img_width% h%img_height% x%even_more_actual_pos_x% y%even_more_actual_pos_y% NoActivate, ScreenBoxID
    ; WinMove, ScreenBoxID,, %even_more_actual_pos_x%, %even_more_actual_pos_y%
    return
    take_screen_shot:
    CoordMode, Mouse, Screen
    MouseGetPos, X, Y
    MouseGetPos, ss_x, ss_y
    ess_x := ss_x - img_width/2 + 1
    ess_y := ss_y - img_height/2 + 1
    Hotkey, LButton, take_screen_shot, Off
    SetTimer, move_box, Off
    Gui, screen_box: Cancel
    Gui, screen_box: Destroy

    switch folder
    {
        case "Images": outfile := "Data\Files\Images\" . img_filename . ".png"
        case "Sio Friend": outfile := "Data\Files\Images\Sio Friend\" . img_filename . ".png"
        case "Cavebot": outfile := "Cavebot\" . currentScript . "\" . img_filename . ".png"
        case "Special Action Cavebot": outfile := "Cavebot\" currentScript "\Special Actions\" . img_filename . ".png"
        case "Cavebot Global": outfile := "Data\Files\Images\Cavebot\" . img_filename . ".png"
        case "Looter": outfile := "Cavebot\" . currentScript . "\Looter\" . img_filename . ".png"
        case "Script Info": outfile := "Cavebot\" . currentScript . "\Script Info\" . img_filename . ".png"
        case "Monstros": outfile := "Cavebot\" . currentScript . "\Monstros\" . img_filename . ".png"
        case "Backpacks": outfile := "Cavebot\" . currentScript . "\Depositer\Backpacks\" . img_filename . ".png"
        case "Targeting": outfile := "Data\Files\Images\Targeting\" . img_filename . ".png"
        case "Sio": outfile := "Data\Sio\" . img_filename . ".png"
        case "TempMonster": outfile := _TargetingHandler.TEMP_IMAGE_PATH
    }

    if (move_mouse_left = true) {
        ; msgbox, %X%, %Y%
        X := X - 200
        if (X < WindowX)
            MouseMove, X + 400, Y
        else
            MouseMove, X, Y
        Sleep, 500
    }
    ; if (!pToken) {
    ;     pToken:=Gdip_Startup()
    ; }
    pBitmap:=Gdip_BitmapFromScreen(ess_x "|" ess_y "|" img_width "|" img_height)
    if (pBitmap = 0 OR pBitmap = "0" OR pBitmap = "-1") {
        ; Gdip_Shutdown(pToken)
        GuiControl,%guiname%:, %img_filename%, %outfile%
        Gui, Show
        return true
    }
    Gdip_SaveBitmapToFile(pBitmap, outfile, 100)
    ; Gdip_Shutdown(pToken)
    if (dont_change_control != false)
        GuiControl,%guiname%:, %img_filename%, %outfile%
    Gui, Show
    return true
    take_screen_shot_off:
    Hotkey, LButton, take_screen_shot, Off
    Hotkey, Esc, take_screen_shot_off, Off
    Gui, screen_box: Cancel
    SetTimer, move_box, Off
    Gui, Show
    return
}

CloseAllProcesses(closeProcessMonitor := false) {
    if (closeProcessMonitor = true)
        ProcessExistClose(processMonitorExeName, "processMonitorExeName")

    for key, moduleName in OldBotSettings.modulesList
        ProcessExistClose(%moduleName%ExeName, moduleName "ExeName")

    Process, Close, Alarm.exe

    _Executables.stopAllExceptOldBot()

    _AbstractExe.closeAllTemp()
}

ProcessExistClose(Name, ExeIdentifier) {
    PID := _ProcessHandler.readExePID(ExeIdentifier)

    if (empty(PID))
        return _ProcessHandler.deleteExePID(ExeIdentifier)

    Process,Exist,%PID%
    if (ErrorLevel = PID)
        Process, Close, %PID%
    ; msgbox, % ProcessToClose "`n" ExeIdentifier "`n" %ExeIdentifier%_Process
    return _ProcessHandler.deleteExePID(ExeIdentifier)
}

countScreenshots(string, folder := "") {
    Path := "Data\Screenshots\" (folder != "" ? folder "\" : "") string "*.png", Number := 0
    Loop, %Path%
        Number++
    return Number
}

; Copy this function into your script to use it.
;HideTrayTip()

TrayTipMessage(title, message, timeout := 2, warningIcon := false) {
    Menu Tray, Icon

    iconType := warningIcon = true ? 2 : 1
    TrayTip, % title, % message, % timeout, % iconType
    SetTimer, HideTrayTip, Delete
    SetTimer, HideTrayTip, % "-" timeout * 1000
    return
}

HideTrayTip() {
    TrayTip ; Attempt to hide it the normal way.
    if SubStr(A_OSVersion,1,3) = "10." {
        Menu Tray, NoIcon
        Sleep 200 ; It may be necessary to adjust this sleep.
        Menu Tray, Icon
    }
    return
}

checkbox_setvalue(ByRef var, ByRef var_value, button_image := false, checked_image := "", unchecked_image := "") {
    %var% := var_value
    if (button_image != true) {
        checked_image := checked_img
        unchecked_image := unchecked_img
    }
    ; msgbox, %var%  = %var_value%,  %button_image%, checked_img = %checked_img%

    if (%var% = 1) {
        try GuiControl, ShortcutScripts:, %var%, %checked_img%
        catch {
        }
    } else {
        try GuiControl, ShortcutScripts:, %var%, %unchecked_img%
        catch {
        }
    }
    return
}

checkbox_change(ByRef var) {
    global
    var_value := %var%
    ; msgbox, %var% = %var_value% old
    var_value:=!var_value ; invert state
    %var% := var_value
    ; msgbox, %var% = %var_value% new

    IfInString, var, _2
    {
        StringReplace, var_2, var, _2,, All
        %var_2% := var_value
    }

    switch var {
        case "MostrarShortcut_Cavebot", case "MostrarShortcut_Healer", case "MostrarShortcut_ItemRefill", case "MostrarShortcut_Support", case "MostrarShortcut_Misc", case "MostrarShortcut_Hotkeys", case "MostrarShortcut_Alerts":
            checkbox_setvalue(var, var_value, true, checked_%var%, unchecked_%var%)
        default: checkbox_setvalue(var, var_value)
    }

    ; msgbox, %var% = %var_value% new
    ; msgbox, %var_2% = %var_value% new
    ; ifEqual, %var%, 1, GuiControl, ShortcutScripts:, %var%, %checked_img%
    ; else GuiControl, ShortcutScripts:, %var%, %unchecked_img%
    return
}

startingModuleMessage(moduleName) {
    CarregandoGUI(txt("Iniciando módulo: " , "Starting module: ") moduleName "...")
}

stoppingModuleMessage(moduleName) {
    CarregandoGUI(txt("Parando módulo: " , "Stopping module: ") moduleName "...")
}

ProcessExistOpenOldBot(ExeName, ExeIdentifier, closeProcess := false) {
    ExePID := _ProcessHandler.readExePID(ExeIdentifier)

    _ProcessQueue.add(new _Process(ExeName, ExePID))

    _ProcessQueue.setTimer()
}

getStringNoSpecialCharacters(string, replaceSpace := true) {
    if (replaceSpace = true)
        string := StrReplace(string, " ", "_")
    ; remove any special characters
    return RegExReplace(string,"[^\w]","")
}

CheckClientMC() {
    try TibiaClient.checkClientSelected()
    catch e {
        MsgBox, 64,, % e.Message, 2
        return false
    }
    return true
}

validateInvalidWindowPos(X := "", Y := "") {
    if (X != "") {
        X := (X > A_ScreenWidth - 100) ? 10 : X
            , X := X < -3000 ? 10 : X
    }
    if (Y != "") {
        Y := (Y > A_ScreenHeight - 100) ? 10 : Y
            , Y := Y < -3000 ? 10 : Y
    }

    return {x: X, y: Y}
}

buttonPress(GUI, buttonControl, imageName, press := true, sleep := 50) {
    Gui, %GUI%:Default
    if (press = true) {
        GuiControl,, %buttonControl%, % ImagesConfig.folder "\GUI\Buttons\" imageName "_P.png"
        Sleep, % sleep
    } else {
        Sleep, 100
        GuiControl,, %buttonControl%, % ImagesConfig.folder "\GUI\Buttons\" imageName ".png"
    }
    ; msgbox, % imageName "_P.png"
    return
}

; ByRef saves a little memory in this case.
; This function sends the specified string to the specified window and returns the reply.
; The reply is 1 if the target window processed the message, or 0 if it ignored it.
Send_WM_COPYDATA(ByRef StringToSend, ByRef SendMessageTargetWindowTitle, TimeOutTime := 1) {
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0) ; Set up the structure's memory area.
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize) ; OS requires that this be done.
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize) ; Set lpData to point to the string itself.
    ; Prev_DetectHiddenWindows := A_DetectHiddenWindows
    ; Prev_TitleMatchMode := A_TitleMatchMode
    ; DetectHiddenWindows On
    ; SetTitleMatchMode 2

    /**
    timeout as param
    TimeOutTime := 1  ; Optional. Milliseconds to wait for response from receiver.ahk. Default is 5000
    */

    ; Must use SendMessage not PostMessage.
    try SendMessage, 0x4a, 0, &CopyDataStruct,, %SendMessageTargetWindowTitle%,,,, %TimeOutTime% ; 0x4a is WM_COPYDATA.
    catch {
    }
    ; DetectHiddenWindows %Prev_DetectHiddenWindows%  ; Restore original setting for the caller.
    ; SetTitleMatchMode %Prev_TitleMatchMode%         ; Same.
    return ErrorLevel ; return SendMessage's reply back to our caller.
}

createItemsBitmaps(itemsArray) {
    ; msgbox, % serialize(itemsArray)
    if (itemsArray.Count() < 1)
        return
    for itemName, atributes in itemsArray
    {
        ; msgbox, % itemName
        if (!itemsImageObj[itemName])
            continue
        ; bitmap of items with more sprites
        Loop, 10 {
            item := itemName "_" A_Index
            ; msgbox, % item
            if (itemsImageObj[item]) {
                try itemsImageObj[item].bitmap := GdipCreateFromBase64(itemsImageObj[item]["image"])
                catch e {
                    if (!A_IsCompiled)
                        msgbox, 16,, % e.Message "`n" e.What
                    OutputDebug(A_ThisFunc, e.Message " | " e.What)
                }
                try itemsImageObj[item].bitmapFull := GdipCreateFromBase64(itemsImageObj[item]["image_full"])
                catch e {
                    if (!A_IsCompiled)
                        msgbox, 16,, % e.Message "`n" e.What
                    OutputDebug(A_ThisFunc, e.Message " | " e.What)
                }
                try itemsImageObj[item].bitmapFull := GdipCreateFromBase64(itemsImageObj[item]["image_full"])
                catch e {
                    if (!A_IsCompiled)
                        msgbox, 16,, % e.Message "`n" e.What
                    OutputDebug(A_ThisFunc, e.Message " | " e.What)
                }
            }
        }

        try itemsImageObj[itemName].bitmap := GdipCreateFromBase64(itemsImageObj[itemName].image)
        catch e {
            if (!A_IsCompiled)
                msgbox, 16,, % e.Message "`n" e.What
            OutputDebug(A_ThisFunc, e.Message " | " e.What)
        }

        try itemsImageObj[itemName].bitmapFull := GdipCreateFromBase64(itemsImageObj[itemName].image_full)
        catch e {
            if (!A_IsCompiled)
                msgbox, 16,, % e.Message "`n" e.What
            OutputDebug(A_ThisFunc, e.Message " | " e.What)
        }

        if (!InStr(itemName, "ring")) {
            continue
        }

        try itemsImageObj[itemName].bitmapQuarter := Gdip_CropBitmap(GdipCreateFromBase64(itemsImageObj[itemName].image), left := 0, right := 16, up := 0, down := 5, false)
        catch e {
            if (!A_IsCompiled)
                msgbox, 16,, % e.Message "`n" e.What
            OutputDebug(A_ThisFunc, e.Message " | " e.What)
        }

        ; Gdip_SetBitmapToClipboard(itemsImageObj[itemName].bitmapQuarter)
        ; msgbox, a
    }

}

changeButton(GUI, button, action := "Enable", changeText := "") {
    GuiControl, %GUI%:%action%, % button
    if (changeText != "")
        GuiControl, %GUI%:, % button, % changeText
}

enableButton(GUI, button, changeText := "") {
    GuiControl, %GUI%:Enable, % button
    if (changeText != "")
        GuiControl, %GUI%:, % button, % changeText
}

randomId() {
    return A_TickCount "" random(1, 9999999) "" random(1, 9999999)
}

openURL(URL) {
    GetKeyState, CtrlPressed, Ctrl, D
    if (CtrlPressed = "D") {
        copyToClipboard(URL)
        TrayTip, % "Clipboard", % "URL copied to clipboard", 2, 1
        SetTimer, HideTrayTipFunctions, -2000
        return
    }

    try {
        Run, % URL
        Sleep, 1000
    } catch {
        copyToClipboard(URL)
        msgbox, 48, % "Open URL", % "Failed to open URL on browser, URL copied to the clipboard:`n" URL, 6
    }
    return
}

resetCavebotSession() {
    global
    sessionHour := 0
    sessionMinute := 0
    sessionSecond := 0
    SB_SetText(sessionString ": " sessionHour "h " sessionMinute "m " sessionSecond "s ", sessionCounterPart)
    return
}

InfoCarregandoPercent(text, line_number) {
    Percent := (line_number * 100) / last_loading_line
    ; msgbox,% line_number "/" last_loading_line
    GuiControl, Carregando:, info, [%Percent%`%] %text%
    return
}

EnableGavebotGUI() {
    try Gui, CavebotGUI:-Disabled
    catch {
    }
}

coordinateViewerTimer()
{
    CoordinateViewer.updateVisibleElements()
}

destroyCoordinateViewerTimer()
{
    CoordinateViewer.destroyAllElements()
    return
}

/**
* @return bool
*/
isTibia13Or14()
{
    return isTibia13() || isTibia14()
}

/**
* @return bool
*/
isTibia13()
{
    static value
    if (!value) {
        value := TibiaClient.getClientIdentifier() = "rltibia" || OldbotSettings.settingsJsonObj.tibiaClient.tibia12
    }

    return value
}

/**
* @return bool
*/
isTibia74()
{
    static value
    return value ? value : value := bool(OldbotSettings.settingsJsonObj.tibiaClient.tibia7x)
}

/**
* @return bool
*/
isMiracle74()
{
    static value
    return value ? value : value := InStr(OldBotSettings.settingsJsonObj.configFile, "miracle")
}

/**
* @return bool
*/
isTibia14()
{
    static value
    if (!value) {
        value := InStr(OldbotSettings.settingsJsonObj.tibiaClient.windowClassFilter, "Qt6")
    }

    return value
}

/**
* @return bool
*/
isNotTibia13()
{
    return !isTibia13()
}

/**
* @return bool
*/
isInProtectionZone()
{
    return new _SearchProtectionZone().found()
}

/**
* @return bool
*/
isMemoryCoordinates()
{
    return scriptSettingsObj.charCoordsFromMemory ? true : false
}

/**
* @param string module
* @return bool
*/
uncompatibleModule(module)
{
    return OldbotSettings.uncompatibleModule(module)
}

/**
* @param string module
* @param string function
* @return bool
*/
uncompatibleFunction(module, function)
{
    return OldbotSettings.uncompatibleModuleFunction(module, function)
}


isRavendawn()
{
    return false
}


isWideMarket()
{
    return _MarketWindowArea.IS_WIDE
}


/*
remove special characters from string
*/
removeSpecialCharacters(string, exceptionArray := "", replaceBy := "") {
    static specialChars
    if (specialChars = "") {
        specialChars := {}
        specialChars.Push("±")
        specialChars.Push("!")
        specialChars.Push("@")
        specialChars.Push("#")
        specialChars.Push("$")
        specialChars.Push("%")
        specialChars.Push("^")
        specialChars.Push("&")
        specialChars.Push("*")
        specialChars.Push("(")
        specialChars.Push(")")
        specialChars.Push("+")
        specialChars.Push("=")
        specialChars.Push("-")
        specialChars.Push(";")
        specialChars.Push(",")
        specialChars.Push(".")
        specialChars.Push("<")
        specialChars.Push("/")
        specialChars.Push("?")
        specialChars.Push("\")
        specialChars.Push(":")
        quote = `"
        specialChars.Push(quote)
        specialChars.Push("'")
        specialChars.Push("|")
        specialChars.Push("[")
        specialChars.Push("]")
        specialChars.Push("{")
        specialChars.Push("}")
        specialChars.Push("`")
        specialChars.Push("´")
        specialChars.Push("~")
    }

    ; msgbox, % serialize(exceptionArray)

    for _, char in specialChars
    {
        ignore := false
        for _, excpetionChar in exceptionArray
        {
            if (char = excpetionChar) {
                ignore := true
                break
            }
        }
        if (ignore = true)
            continue
        string := StrReplace(string, char, replaceBy)
    }

    letters := {}
    letters.Push(Object("ç", "c"))
    letters.Push(Object("ã", "a"))
    letters.Push(Object("é", "e"))

    for _, value in letters
    {
        for letter, replace in value
        {
            string := StrReplace(string, letter, replace)
        }
    }
    return string
}
