/*
OldBot é desenvolvido por Alfredo Menezes, Brasil.
Copyright © 2017. Todos os direitos reservados.

OldBot is developed by Alfredo Menezes, Brazil.
Copyright © 2017. All rights reserved.
*/
#WarnContinuableException Off
#SingleInstance, Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; Process, Priority, %PID%, High
; #NoTrayIcon
#KeyHistory 0
#MaxHotkeysPerInterval 200
#HotkeyInterval 200
#MaxThreadsPerHotkey 1
SetWorkingDir %A_WorkingDir%  ; Ensures a consistent starting directory.
; #MaxThreads 50
; SetWorkingDir %A_WorkingDir%  ; Ensures a consistent starting directory.
FileEncoding, UTF-8
ListLines Off

;@Ahk2Exe-IgnoreBegin
#Warn, ClassOverwrite
; #Warn, UseUnsetLocal
;@Ahk2Exe-IgnoreEnd

; OnExit("restoreCursor")
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\default_profile.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IBigA.ahk

_Launcher.onStart()

; msgbox started
; exitapp

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Launcher.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_ProcessHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Client\Json\_SettingsJson.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Core\_Version.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Executables\_LauncherExe.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\GUI\_UpdaterGUI.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Settings\Ini\_LauncherIniSettings.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IComponents.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IConfig.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IExecutables.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Includes\IRequests.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\libraries\JSON.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\Helpers\ISharedHelpers.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Objects\_Icon.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Ini\_GlobalIniSettings.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Ini\_OldBotIniSettings.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Objects\IObjects.ahk

_Launcher.initialize()

seconds := 0
return


GuiClose(GuiHwnd)
{
    ExitApp
}

WM_LBUTTONDOWN()
{
    PostMessage, 0xA1, 2 ; 0xA1 = WM_NCLBUTTONDOWN
    if (!_GUI.INSTANCES.HasKey(A_Gui)) {
        return
    }

    instance := _GUI.INSTANCES[A_Gui]
    fn := instance.savePosition.bind(instance)
    SetTimer, % fn, Delete
    SetTimer, % fn, -200
    SetTimer, % fn, -500
    SetTimer, % fn, -1000
}

checkOldBotOpened:
    seconds++
    exist := false
    IniRead, ProcessExist, %DefaultProfile%, settings, OldBotExeName_Process
    Process,Exist,%ProcessExist%

    exist := (ErrorLevel != 0)

    ; Process,Exist,% Launcher.OldBotExeName
    ; If (ErrorLevel != 0) {
    ;     Sleep, 500
    ;     exist := true
    ; }

    if (exist = true OR seconds > _Launcher.TIMEOUT) {
        Sleep, 1000
        if (seconds > _Launcher.TIMEOUT) {
            Gui, Destroy
            Gui, Watermark:Destroy
            Msgbox, 48,, % txt("Mais de " _Launcher.TIMEOUT " segundos tentando abrir o executável """ _OldBotExe.getName() """, algo deu errado.`nPor favor contate o suporte.", "More than " _Launcher.TIMEOUT " seconds trying to open """ _OldBotExe.getName() """ executable, something went wrong.`nPlease contact support.")
        }
        ExitApp
    }
return

Ready() {
    global req
    if (req.readyState != 4)  ; Not done yet.
        return
    if (req.status == 200) ; OK.
    {

        ; MsgBox % "Latest AutoHotkey version: " req.responseText
        ; MsgBox % "Latest AutoHotkey version: " req.ResponseBody
        ado := ComObjCreate("ADODB.Stream")
        ado.Type := 1 ; adTypeBinary
        ado.Open()
        ado.Write(req.responseText)
        ado.SaveToFile("__logo.png", 2)
        ado.Close()
    }
    else
        MsgBox 16,, % "Status " req.status
    ; ExitApp
}

Class CustomFont
{
    static FR_PRIVATE  := 0x10

    __New(FontFile, FontName="", FontSize=30) {
        if RegExMatch(FontFile, "i)res:\K.*", _FontFile)
            this.AddFromResource(_FontFile, FontName, FontSize)
        else
            this.AddFromFile(FontFile)
    }

    AddFromFile(FontFile) {
        if !FileExist(FontFile) {
            throw "Unable to find font file: " FontFile
        }
        DllCall( "AddFontResourceEx", "Str", FontFile, "UInt", this.FR_PRIVATE, "UInt", 0 )
        this.data := FontFile
    }

    AddFromResource(ResourceName, FontName, FontSize = 30) {
        static FW_NORMAL := 400, DEFAULT_CHARSET := 0x1

        nSize    := this.ResRead(fData, ResourceName)
        fh       := DllCall( "AddFontMemResourceEx", "Ptr", &fData, "UInt", nSize, "UInt", 0, "UIntP", nFonts )
        hFont    := DllCall( "CreateFont", Int,FontSize, Int,0, Int,0, Int,0, UInt,FW_NORMAL, UInt,0
            , Int,0, Int,0, UInt,DEFAULT_CHARSET, Int,0, Int,0, Int,0, Int,0, Str,FontName )

        this.data := {fh: fh, hFont: hFont}
    }

    ApplyTo(hCtrl) {
        SendMessage, 0x30, this.data.hFont, 1,, ahk_id %hCtrl%
    }

    __Delete() {
        if IsObject(this.data) {
            DllCall( "RemoveFontMemResourceEx", "UInt", this.data.fh    )
            DllCall( "DeleteObject"           , "UInt", this.data.hFont )
        } else {
            DllCall( "RemoveFontResourceEx"   , "Str", this.data, "UInt", this.FR_PRIVATE, "UInt", 0 )
        }
    }

    ; ResRead() By SKAN, from http://www.autohotkey.com/board/topic/57631-crazy-scripting-resource-only-dll-for-dummies-36l-v07/?p=609282
    ResRead( ByRef Var, Key ) {
        VarSetCapacity( Var, 128 ), VarSetCapacity( Var, 0 )
        If ! ( A_IsCompiled ) {
            FileGetSize, nSize, %Key%
            FileRead, Var, *c %Key%
            return nSize
        }

        If hMod := DllCall( "GetModuleHandle", UInt,0 )
            If hRes := DllCall( "FindResource", UInt,hMod, Str,Key, UInt,10 )
                If hData := DllCall( "LoadResource", UInt,hMod, UInt,hRes )
                    If pData := DllCall( "LockResource", UInt,hData )
                        return VarSetCapacity( Var, nSize := DllCall( "SizeofResource", UInt,hMod, UInt,hRes ) )
            ,  DllCall( "RtlMoveMemory", Str,Var, UInt,pData, UInt,nSize )
        return 0
    }
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


/**
* @return bool
*/
isRubinot()
{
    static value
    if (value = "") {
        value := clientIdentifier() = "Rubinot RTC"
    }

    return value
}

CarregandoGUI(text, text_width := 150, progress_width := 150, gui_color := "", font_color := "", x := "", y := 10, show_bar := true) {
}
writeCavebotLog(Status, Text, isError := false) {
}
CloseAllProcesses(_)
{
}
Reload() {
}
openURL(_) {
}
InfoCarregando(_)
{
}
