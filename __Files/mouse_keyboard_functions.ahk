/*
Mouse and Keyboard Functions

Note: This file uses mousehook64.dll (Data\Files\Others\mousehook64.dll) for
direct mouse input injection. The DLL provides LeftClick, RightClick, and
dragDrop functions that send mouse input directly to the target window
without moving the user's cursor.
*/

; ######################## KEYBOARD ########################

paramClientID(clientWindowID := "") {
    return (clientWindowID = "" OR clientWindowID = 0) ? TibiaClientID : clientWindowID
}

SendModifier(modifierKey, Key, clientWindowID := "")
{

    if (backgroundKeyboardInput = false) && (OldbotSettings.settingsJsonObj.input.physicalPressModifierKeys = false)
        OldbotSettings.settingsJsonObj.input.physicalPressModifierKeys := true

    PressModifierKey(modifierKey, Key, clientWindowID)

    /**
    Needed sleep after pressing with modifier key
    Without the sleep Ctrl+K for example is failing sometimes in TIbia 11/12+
    */
    Sleep, 25
    Send(Key, clientWindowID, modifierKeyHold := true, waitModifierKeys := false)
    /**
    Needed sleep after pressing with modifier key
    */
    Sleep, 25
    ; Sleep, 50 ; changed on 26/06/2024 to test to test if there is less intereference and still works fine

    Loop, 2
        ReleaseModifierKey(modifierKey, clientWindowID)

    return
}

PressModifierKey(modifierKey, Key, clientWindowID := "") {
    switch modifierKey {
        case "Shift":
            if (OldbotSettings.settingsJsonObj.input.physicalPressModifierKeys = true)
                KeyWait, Shift, T2
            HoldShift(clientWindowID)
        case "Ctrl":
            if (OldbotSettings.settingsJsonObj.input.physicalPressModifierKeys = true)
                KeyWait, Control, T2
            HoldCtrl(clientWindowID)
        default:
            if (OldbotSettings.settingsJsonObj.input.physicalPressModifierKeys = true)
                KeyWait, %modifierKey%, T2
            ControlSend,, {%modifierKey% down}, % "ahk_id " paramClientID(clientWindowID)
            if (ErrorLevel = 1) {
                Sleep, 25
                Loop, 50 {
                    ControlSend,, {%modifierKey% down}, % "ahk_id " paramClientID(clientWindowID)
                    if (ErrorLevel = 0)
                        break
                }
            }
    }
    return
}

ReleaseModifierKey(modifierKey, clientWindowID := "") {
    switch modifierKey {
        case "Shift":
            ReleaseShift(clientWindowID)
        case "Ctrl":
            ReleaseCtrl(clientWindowID)
        default:
            ControlSend,, {%modifierKey% up}, % "ahk_id " paramClientID(clientWindowID)
            if (ErrorLevel = 1) {
                Sleep, 25
                Loop, 50 {
                    ControlSend,, {%modifierKey% up}, % "ahk_id " paramClientID(clientWindowID)
                    if (ErrorLevel = 0)
                        break
                }
            }
    }
}

HoldShift(clientWindowID := "") {
    if (backgroundKeyboardInput = false) OR (OldbotSettings.settingsJsonObj.input.physicalPressModifierKeys = true) OR (isTibia13()) {
        Send, {Shift Down}
        Sleep, 25
        return
    }

    PostMessage 0x07, , , , % "ahk_id " paramClientID(clientWindowID) ; WM_SETFOCUS
    Loop, 2
        PostMessage,0x100, 0x10, 0x02A0001,, % "ahk_id " paramClientID(clientWindowID) ;WM_KEYDOWN := 0x100
    return
}

ReleaseShift(clientWindowID := "") {
    if (backgroundKeyboardInput = false) OR (OldbotSettings.settingsJsonObj.input.physicalPressModifierKeys = true) OR (isTibia13()) {
        Send, {Shift Up}
        return
    }

    PostMessage 0x07, , , , % "ahk_id " paramClientID(clientWindowID) ; WM_SETFOCUS
    Loop, 2
        PostMessage, 0x101, 0x10, 1,, % "ahk_id " paramClientID(clientWindowID) ;WM_KEYUP := 0x0115
    return
}

HoldCtrl(clientWindowID := "") {
    if (backgroundKeyboardInput = false) OR (OldbotSettings.settingsJsonObj.input.physicalPressModifierKeys = true) OR (isTibia13()) {
        Send, {Ctrl Down}
        return
    }

    ; PostMessage 0x07, , , , % "ahk_id " paramClientID(clientWindowID) ; WM_SETFOCUS
    Loop, 2
        PostMessage,0x100, 0x11, 0x021D0001,, % "ahk_id " paramClientID(clientWindowID) ;WM_KEYDOWN := 0x100
    return
}

ReleaseCtrl(clientWindowID := "") {
    if (backgroundKeyboardInput = false) OR (OldbotSettings.settingsJsonObj.input.physicalPressModifierKeys = true) OR (isTibia13()) {
        Send, {Ctrl Up}
        return
    }

    PostMessage 0x07, , , , % "ahk_id " paramClientID(clientWindowID) ; WM_SETFOCUS
    Loop, 2
        PostMessage, 0x101, 0x11, 0x021D0001,, % "ahk_id " paramClientID(clientWindowID) ;WM_KEYUP := 0x0115
    return
}

write(text, clientWindowID) {
    ; WinGetTitle, TibiaClientTitle, % "ahk_id " clientWindowID
    ControlSend,, %text%, % "ahk_id " clientWindowID
    return
}

SendMessageKeyUp(vk, clientWindowID := "") {
    if (OldbotSettings.settingsJsonObj.input.keyPressDelay > 1) {
        Random, keyRandomDelay, % OldbotSettings.settingsJsonObj.input.keyPressDelay - 10, % OldbotSettings.settingsJsonObj.input.keyPressDelay + 20
        Sleep, % keyRandomDelay
    }
    SendMessage, 0x101, %vk%, 1,, % "ahk_id " clientWindowID
}

SendDown(Key)
{
    clientWindowID := paramClientID(clientWindowID)

    ; PostMessage 0x07, , , , % "ahk_id " clientWindowID ; WM_SETFOCUS (https://autohotkey.com/board/topic/64721-howto-send-keys-to-background-window-lotro/)
    switch key {
        case "w":
            vk := 0x57
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0110001,, % "ahk_id " clientWindowID
        case "a":
            vk := 0x41
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x01E0001,, % "ahk_id " clientWindowID
            SendMessage, 0x101, %vk%, 0x01E0001,, % "ahk_id " clientWindowID
        case "s":
            vk := 0x53
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x01F0001,, % "ahk_id " clientWindowID
        case "d":
            vk := 0x44
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0200001,, % "ahk_id " clientWindowID
    }
}


Send(Key, clientWindowID := "", modifierKeyHold := false, waitModifierKeys := true) {
    if (empty(Key)) {
        return
    }


    if (waitModifierKeys) {
        KeyWait, Control, T5
        KeyWait, Shift, T5
        KeyWait, Alt, T5
    }

    if (false) {
        WinActivate()
    }


    firstChar := SubStr(Key, 1, 1)
    if (firstChar = "^")
        return SendModifier("Ctrl", SubStr(Key, 2, StrLen(Key) - 1), clientWindowID)
    if (firstChar = "+")
        return SendModifier("Shift", SubStr(Key, 2, StrLen(Key) - 1), clientWindowID)
    if (firstChar = "!")
        return SendModifier("Alt", SubStr(Key, 2, StrLen(Key) - 1), clientWindowID)

    if (!backgroundKeyboardInput) {
        If (StrLen(Key) = 1 OR RegExMatch(Key, _Key.keysRegex())) {
            if (OldbotSettings.settingsJsonObj.input.keyPressDelay = 0) {
                Send, {%key%}
            } else {
                Send, {%Key% down}
                Sleep, % OldbotSettings.settingsJsonObj.input.keyPressDelay
                Send, {%Key% up}
            }
        } else {
            Send, %key%
        }
        return
    }


    clientWindowID := paramClientID(clientWindowID)

    PostMessage 0x07, , , , % "ahk_id " clientWindowID ; WM_SETFOCUS (https://autohotkey.com/board/topic/64721-howto-send-keys-to-background-window-lotro/)

    /**
    For medivia only ControlSend is working, SendMessage is spamming like the key is not being released
    */
    if (OldBotSettings.settingsJsonObj.input.useCSend) {
        If (RegExMatch(Key,"(F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|Enter|Esc|Space|Del|Tab|Home|End|Insert|PgUp|PgDown|Up|Down|Left|Right|Num |Numpad)"))
            ControlSend,, {%key%}, % "ahk_id " clientWindowID
        else
            write(key, clientWindowID)
        return
    }

    switch key {
            /**
            F1 - F12
            */
        case "F1":
            vk := 0x70
            SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x03B0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "F2":
            vk := 0x71
            SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x03C0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "F3":
            vk := 0x72
            SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x03D0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "F4":
            vk := 0x73
            SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x03E0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "F5":
            vk := 0x74
            SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x03F0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "F6":
            vk := 0x75
            SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x0400001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "F7":
            vk := 0x76
            SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x0410001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "F8":
            vk := 0x77
            SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x0420001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "F9":
            vk := 0x78
            SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x0430001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "F10":
            vk := 0x79
            SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x0440001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "F11":
            vk := 0x7A
            SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x0570001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "F12":
            vk := 0x7B
            SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x0580001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)

            /**
            numbers
            1 on KEYDOWN param because if sent the 0xC$keycode was sending multiple times in tibia
            */
        case "0":
            vk := 0x30
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0B0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "1":
            vk := 0x31
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x020001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "2":
            vk := 0x32
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x030001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "3":
            vk := 0x33
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x040001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "4":
            vk := 0x34
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x050001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "5":
            vk := 0x35
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x060001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "6":
            vk := 0x36
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x070001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "7":
            vk := 0x37
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x080001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "8":
            vk := 0x38
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x090001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "9":
            vk := 0x39
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0A0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)

            /**
            letters
            */
        case "a":
            vk := 0x41
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x01E0001,, % "ahk_id " clientWindowID
            ; SendMessage, 0x101, %vk%, 0x01E0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "b":
            vk := 0x42
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0300001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "c":
            vk := 0x43
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x02E0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "d":
            vk := 0x44
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0200001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "e":
            vk := 0x45
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0120001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "f":
            vk := 0x46
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0210001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "g":
            vk := 0x47
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0220001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "h":
            vk := 0x48
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0230001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "i":
            vk := 0x49
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0170001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "j":
            vk := 0x4A
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0240001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "k":
            vk := 0x4B
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0250001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "l":
            vk := 0x4C
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0260001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "m":
            vk := 0x4D
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0320001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "n":
            vk := 0x4E
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0310001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "o":
            vk := 0x4F
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0180001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "p":
            vk := 0x50
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0190001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "q":
            vk := 0x51
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0100001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "r":
            vk := 0x52
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0130001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "s":
            vk := 0x53
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x01F0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "t":
            vk := 0x54
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0140001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "u":
            vk := 0x55
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0160001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "v":
            vk := 0x56
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x02F0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "w":
            vk := 0x57
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0110001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "x":
            vk := 0x58
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x02D0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "y":
            vk := 0x59
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x0150001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "z":
            vk := 0x5A
            msgParam := (OldbotSettings.settingsJsonObj.input.pressLetterKeysDefaultMethod = true OR modifierKeyHold = true) ? 0x100 : 0x102
            SendMessage, % msgParam, %vk%, 0x02C0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)

            /**
            arrows
            */
        case "Up":
            vk := 0x26
            switch OldbotSettings.settingsJsonObj.input.postMsgArrowKeys {
                case true:
                    ; PostMessage, % OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x01480001,, % "ahk_id " clientWindowID
                    PostMessage, 0x100, %vk%, 0x01480001,, % "ahk_id " clientWindowID
                    PostMessage, 0x101, %vk%, 0x01480001,, % "ahk_id " clientWindowID
                case false:
                    SendMessage, 0x100, %vk%, 0x01480001,, % "ahk_id " clientWindowID
                    SendMessage, 0x101, %vk%, 0x01480001,, % "ahk_id " clientWindowID
            }
        case "Down":
            vk := 0x28
            switch OldbotSettings.settingsJsonObj.input.postMsgArrowKeys {
                case true:
                    PostMessage, 0x100, %vk% , 0x01500001,, % "ahk_id " clientWindowID
                    PostMessage, 0x101, %vk% , 0x01500001,, % "ahk_id " clientWindowID
                case false:
                    SendMessage, 0x100, %vk%, 0x01500001,, % "ahk_id " clientWindowID
                    SendMessage, 0x101, %vk%, 0x01500001,, % "ahk_id " clientWindowID
            }
        case "Left":
            vk := 0x25
            switch OldbotSettings.settingsJsonObj.input.postMsgArrowKeys {
                case true:
                    PostMessage, 0x100, %vk%, 0x014B0001,, % "ahk_id " clientWindowID
                    PostMessage, 0x101, %vk%, 0x014B0001,, % "ahk_id " clientWindowID
                case false:
                    SendMessage, 0x100, %vk%, 0x014B0001,, % "ahk_id " clientWindowID
                    SendMessage, 0x101, %vk%, 0x014B0001,, % "ahk_id " clientWindowID
            }
        case "Right":
            vk := 0x27
            switch OldbotSettings.settingsJsonObj.input.postMsgArrowKeys {
                case true:
                    PostMessage, 0x100, %vk%, 0x014D0001,, % "ahk_id " clientWindowID
                    PostMessage, 0x101, %vk%, 0x014D0001,, % "ahk_id " clientWindowID
                case false:
                    SendMessage, 0x100, %vk%, 0x014D0001,, % "ahk_id " clientWindowID
                    SendMessage, 0x101, %vk%, 0x014D0001,, % "ahk_id " clientWindowID
            }

            /**
            other keys
            */
        case "Enter":
            vk := 0x0D
            SendMessage, % OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x01C0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Esc":
            vk := 0x1B
            switch OldbotSettings.settingsJsonObj.input.postMsgEscKey {
                case true:
                    PostMessage, % OldbotSettings.settingsJsonObj.input.pressEscDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x010001,, % "ahk_id " clientWindowID
                    PostMessage, 0x101, %vk%, 1,, % "ahk_id " clientWindowID
                case false:
                    SendMessage, % OldbotSettings.settingsJsonObj.input.pressEscDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x010001,, % "ahk_id " clientWindowID
                    SendMessageKeyUp(vk, clientWindowID)
            }
        case "Backspace":
            vk := 0x08
            SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x0E0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "ScrollLock":
            vk := 0x91
            SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x0460001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Capslock":
            vk := 0x14
            SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x03A0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Space":
            vk := 0x20
            SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x0390001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Del", case "Delete":
            vk := 0x2E
            SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x01530001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Tab":
            vk := 0x09
            SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x0F0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Home":
            vk := 0x24
            SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x01470001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "End":
            vk := 0x23
            SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x014F0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Insert":
            vk := 0x2D
            SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x01520001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "PgUp", case "PageUp":
            vk := 0x21
            SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x01490001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "PgDn", case "PgDown", case "PageDown":
            vk := 0x22
            SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x01510001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)

            /**
            symbols
            */
        case "+":
            ; numpad +
            vk := 0xBB
            SendMessage, 0x100, %vk%, 0x04E0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case ",":
            vk := 0xBC
            SendMessage, 0x100, %vk%, 0x0330001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "-":
            vk := 0xBD
            SendMessage, 0x100, %vk%, 0x0C0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case ".":
            vk := 0xBE
            SendMessage, 0x100, %vk%, 0x0340001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "/":
            vk := 0xBF
            SendMessage, 0x100, %vk%, 0x0730001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "\":
            vk := 0xDC
            SendMessage, 0x100, %vk%, 0x0560001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "~":
            vk := 0xC0
            SendMessage, 0x100, %vk%, 0x0280001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)

            /**
            Numpad keys
            */
        case "Numpad0", case "Num0":
            vk := 0x60
            SendMessage, 0x100, %vk%, 0x0520001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Numpad1", case "Num1":
            vk := 0x61
            SendMessage, 0x100, %vk%, 0x04F0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Numpad2", case "Num2":
            vk := 0x62
            SendMessage, 0x100, %vk%, 0x0500001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Numpad3", case "Num3":
            vk := 0x63
            SendMessage, 0x100, %vk%, 0x0510001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Numpad4", case "Num4":
            vk := 0x64
            SendMessage, 0x100, %vk%, 0x04B0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Numpad5", case "Num5":
            vk := 0x65
            SendMessage, 0x100, %vk%, 0x04C0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Numpad6", case "Num6":
            vk := 0x66
            SendMessage, 0x100, %vk%, 0x04D0001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Numpad7", case "Num7":
            vk := 0x67
            SendMessage, 0x100, %vk%, 0x0470001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Numpad8", case "Num8":
            vk := 0x68
            SendMessage, 0x100, %vk%, 0x0480001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        case "Numpad9", case "Num9":
            vk := 0x69
            SendMessage, 0x100, %vk%, 0x0490001,, % "ahk_id " clientWindowID
            SendMessageKeyUp(vk, clientWindowID)
        default:
            If (RegExMatch(Key,"(F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|Enter|Esc|Space|Del|Tab|Home|End|Insert|PgUp|PgDown|Up|Down|Left|Right|Num |Numpad)"))
                ControlSend,, {%key%}, % "ahk_id " clientWindowID
            else {
                ; ControlSend,, %key%, % "ahk_id " clientWindowID
                write(key, clientWindowID)
            }
    }
}

; ######################## MOUSE ########################

MouseMove(posX, posY, debug := false, waitModifierKeys := true)
{
    if (debug) {
        Gui, Carregando:Destroy
        WinActivate()
        mousemove, WindowX + posX, WindowY + posY
        Msgbox, debug posX = %posX%, posY= %posY%
    }

    if (backgroundMouseInput = false) {
        if (waitModifierKeys) {
            KeyWait, Control, T5
            KeyWait, Shift, T5
            KeyWait, Alt, T5
        }

        WinGetPos, WindowX, WindowY, WindowWidth, WindowHeight, % "ahk_id " paramClientID(clientWindowID)
        MouseMove, WindowX + posX, WindowY + posY
        return
    }

    ControlFromPoint(posX, posY, cX, cY, clientWindowID)

    /**
    Tibia 11/12 Ots
    */
    /**
    0x02000001 is the for the "wMouseMsg" param of WM_SETCURSOR receive "WM_MOUSEMOVE" as value
    */
    try SendMessage, 0x020 , %TibiaClientID% , 0x02000001, , % "ahk_id " paramClientID(clientWindowID) ;SETCURSOR SEND
    catch {
    }
    try PostMessage, 0x200 , 0x0001, cX&0xFFFF | cY<<16, , % "ahk_id " paramClientID(clientWindowID) ;MOUSEMOVE POST
    catch {
    }
}

MouseDrag(X1, Y1, X2, Y2, clientWindowID := "", debug := false, waitModifierKeys := true)
{

    if (debug) {
        mousemove, WindowX + X1, WindowY + Y1
        Msgbox, X1 = %X1%, Y1= %Y1%
        mousemove, WindowX + X2, WindowY + Y2
        Msgbox, X2 = %X2%, Y2= %Y2%

    }
    if (backgroundMouseInput = false) {
        if (waitModifierKeys) {
            KeyWait, Control, T5
            KeyWait, Shift, T5
            KeyWait, Alt, T5
        }

        WinActivate()

        WinGetPos, WindowX, WindowY, WindowWidth, WindowHeight, % "ahk_id " paramClientID(clientWindowID)
        MouseClickDrag, Left, WindowX + X1, WindowY + Y1, WindowX + X2, WindowY + Y2
        return
    }

    if (OldBotSettings.settingsJsonObj.input.mouseDragDefaultMethod = false)
        return drag(x1, y1, x2, y2, clientWindowID)

    ControlFromPoint(X1, Y1, cX, cY, clientWindowID)
    ClickButtonDown("Left", cX, cY, clientWindowID)
    /**
    needed to work with client focused(taleon)
    */
    ; if (isTibia13())
    ; PostMessage, 0x02A3, 0, 0,, % "ahk_id " paramClientID(clientWindowID) ; WM_MOUSELEAVE

    ControlFromPoint(X2, Y2, cX, cY, clientWindowID)
    /**
    0x02000001 is the for the "wMouseMsg" param of WM_SETCURSOR receive "WM_MOUSEMOVE" as value
    */
    PostMessage, 0x200, 0x0001, cX&0xFFFF | cY<<16, , % "ahk_id " paramClientID(clientWindowID) ;MOUSEMOVE

    ; SendMessage, 0x020 , %TibiaClientID% , 0x02040001, , % "ahk_id " paramClientID(clientWindowID)   ;SETCURSOR SEND

    PostMessage, 0x202, 0, cX&0xFFFF | cY<<16,, % "ahk_id " paramClientID(clientWindowID) ; WM_LBUTTONUP
}

drag(x1, y1, x2, y2, clientWindowID := "", waitModifierKeys := true)
{
    WinGetTitle, TibiaClientTitle, % "ahk_id " paramClientID(clientWindowID)

    ; Random, random_pos_x, -1, 1
    ; Random, random_pos_y, -1, 1

    ControlFromPoint(x1, y1, cX1, cY1, clientWindowID)
    ControlFromPoint(x2, y2, cX2, cY2, clientWindowID)
    Bot_protection := 0

    KeyWait, LButton
    KeyWait, RButton

    SleepR(5, 10)
    if (Bot_protection = 1)
        DllCall("Data\Files\Others\mousehook64.dll\dragDrop", "AStr", TibiaClientTitle, "INT", false, "INT", cX1, "INT", cY1, "INT", cX2, "INT", cY2)
    else
        DllCall("Data\Files\Others\mousehook64.dll\dragDrop", "AStr", TibiaClientTitle, "INT", true, "INT", cX1, "INT", cY1, "INT", cX2, "INT", cY2)
    SleepR(5, 10)
    return
}

/*
MOUSEMOVE message without lParam of mouse (0x0001 or 0x0002)
*/
MouseMovePostMessageClick(cX, cY, clientWindowID := "") {
    PostMessage, 0x200 , 0x00000000, cX&0xFFFF | cY<<16, , % "ahk_id " paramClientID(clientWindowID) ;MOUSEMOVE POST
    return
}

rightClick(posX, posY, clientWindowID := "") {
    clientWindowID := paramClientID(clientWindowID)
    WinGetTitle, TibiaClientTitle, % "ahk_id " clientWindowID
    ControlFromPoint(posX, posY, cX, cY, clientWindowID)

    KeyWait, LButton
    KeyWait, RButton
    DllCall("Data\Files\Others\mousehook64.dll\RightClick", "AStr", TibiaClientTitle, "INT", cX, "INT", cY)
    return
}

leftClick(posX, posY, clientWindowID := "") {
    clientWindowID := paramClientID(clientWindowID)
    WinGetTitle, TibiaClientTitle, % "ahk_id " clientWindowID

    ControlFromPoint(posX, posY, cX, cY, clientWindowID)

    KeyWait, LButton
    KeyWait, RButton
    ; BlockInput, on ;Hotkey, RButton, do_nothing, On
    DllCall("Data\Files\Others\mousehook64.dll\LeftClick", "AStr", TibiaClientTitle, "INT", cX, "INT", cY)
    ; SleepR(15, 30)
    ; BlockInput, Off
    return
}

Click(params, clientWindowID := "")
{
    /**
    optional/default params
    */
    params.debug := params.debug = "" ? false : params.debug
        , params.waitModifierKeys := params.waitModifierKeys = "" ? true : params.waitModifierKeys
        , params.menuClickDefaultMethod := params.menuClickDefaultMethod = "" ? true : params.menuClickDefaultMethod

    if (params.waitModifierKeys = true) {
        KeyWait, Control, T5
        KeyWait, Shift, T5
        KeyWait, Alt, T5
    }

    if (params.debug) {
        WinActivate()
        MouseMove, WindowX + params.posX, WindowY + params.posY
        Msgbox, % "debug posX = " params.posX ", posY = " params.posY "`nWindowX = " WindowX ", WindowY = " WindowY "`n button = " params.button
    }


    if (backgroundMouseInput = false) {
        WinActivate()
        WinGetPos, WindowX, WindowY, WindowWidth, WindowHeight, % "ahk_id " paramClientID(clientWindowID)
        if (OldbotSettings.settingsJsonObj.input.mouseClickDelay > 1) {
            MouseMove, WindowX + params.posX, WindowY + params.posY
            Click, % "Down " params.button
            Sleep, % OldbotSettings.settingsJsonObj.input.mouseClickDelay
            Click, % "Up " params.button
            return
        }

        MouseClick, % params.button, WindowX + params.posX, WindowY + params.posY
        return
    }

    ; ControlClick, % "X" params.posY " Y"  params.posY,  % "ahk_id " TibiaClientID,, % params.button, 1, % "Pos"
    ; ControlClick, % "x" params.posX " y"  params.posY,  % "ahk_id " TibiaClientID
    ; error := ErrorLevel
    ; return


    if (params.menuClickDefaultMethod = false) OR (OldBotSettings.settingsJsonObj.input.mouseClickDefaultMethod = false) {
        ; MouseMove, WindowX + params.posX, WindowY + params.posY
        ; Msgbox, % "aaaaaa posX = " params.posX ", posY = " params.posY ", button = " params.button
        if (params.button = "Right")
            return rightClick(params.posX, params.posY, clientWindowID)
        if (params.button = "Left")
            return leftClick(params.posX, params.posY, clientWindowID)
    }

    /**
    se não usar o controlfrompoint, está clicando mais pra baixo da coordenada
    como se não estivesse considerando o titulo da janela ou algo do tipo
    */

    ControlFromPoint(params.posX, params.posY, cX, cY, clientWindowID)

    ; msgbox, % posX "`n" cX "`n" posY "`n" cY

    ClickButtonDown(params.button, cX, cY, clientWindowID, params.debug)

    /**
    added to work in PXG
    */
    MouseMovePostMessageClick(cX, cY, clientWindowID := "")
    ; PostMessage, 0x200 , 0x00000000, cX&0xFFFF | cY<<16, , % "ahk_id " paramClientID(clientWindowID)   ;MOUSEMOVE POST

    SendMessage, 0x084 , 0x00000000, cX&0xFFFF | cY<<16, , % "ahk_id " paramClientID(clientWindowID) ;NCHITTEST SEND
    SendMessage, 0x020 , % paramClientID(clientWindowID), % params.button = "Left" ? 0x02020001 : 0x02050001, , % "ahk_id " paramClientID(clientWindowID) ;SETCURSOR SEND
    PostMessage, % params.button = "Left" ? 0x202 : 0x205, 0, cX&0xFFFF | cY<<16,, % "ahk_id " paramClientID(clientWindowID) ; WM_LBUTTONUP

    return
}

MouseClick(button, posX, posY, debug := false, clientWindowID := "", waitModifierKeys := true) {
    /**
    changed on 02/07/22 to be able to send clicks with "mouseClickDefaultMethod" option
    for medivia
    */
    ; msgbox, % button
    Click({"button": button, "posX": posX, "posY": posY, "waitModifierKeys": waitModifierKeys, "debug": debug}, clientWindowID)
}

ClickButtonDown(button, cX, cY, clientWindowID := "", debug := false) {
    /**
    correct order to send these messages in Tibia 11/12
    */
    ; SendMessage, % WM_NCACTIVATE := 0x0086, 0, , , % "ahk_id " paramClientID(clientWindowID)   ;NCHITTEST SEND

    if (debug) {
        m(button, cX, cY, paramClientID(clientWindowID))
    }

    MouseMovePostMessageClick(cX, cY, clientWindowID := "")

    SendMessage, 0x084 , 0x00000000, cX&0xFFFF | cY<<16, , % "ahk_id " paramClientID(clientWindowID) ;NCHITTEST SEND

    SendMessage, 0x020 , % paramClientID(clientWindowID) , % (button = "Left") ? 0x02010001 : 0x02040001, , % "ahk_id " paramClientID(clientWindowID) ;SETCURSOR SEND

    /**
    necessary to work on PXG but breaks tibia 11 client
    */
    if (OldBotSettings.settingsJsonObj.configFile = "settings_pokexgames.json") OR (OldBotSettings.settingsJsonObj.configFile = "settings_medivia.json") {
        MouseMovePostMessageClick(cX, cY, clientWindowID)
    }
    /**
    added to work in PXG
    */
    PostMessage 0x07, , , , % "ahk_id " paramClientID(clientWindowID) ; WM_SETFOCUS (https://autohotkey.com/board/topic/64721-howto-send-keys-to-background-window-lotro/)

    /**
    0x0001/0x0002 param is for the message WM_LBUTTONDOWN param "fwKeys" receive the value "MK_LBUTTON"/"MK_RBUTTON"
    */
    PostMessage, % (button = "Left") ? 0x201 : 0x204, % (button = "Left") ? 0x0001 : 0x0002, cX&0xFFFF | cY<<16,, % "ahk_id " paramClientID(clientWindowID) ; WM_LBUTTONDOWN
    return
}

ClickButtonUp(button, posX, posY, clientWindowID := "") {
    ControlFromPoint(posX, posY, cX, cY, clientWindowID)
    PostMessage, % button = "Left" ? 0x202 : 0x205, 0, cX&0xFFFF | cY<<16,, % "ahk_id " paramClientID(clientWindowID) ; WM_LBUTTONUP
    return
}


ClickShift(params, clientWindowID := "")
{
    /**
    optional/default params
    */
    params.debug := params.debug = "" ? false : params.debug

    if (backgroundMouseInput = false) {
        WinGetPos, WindowX, WindowY, WindowWidth, WindowHeight, % "ahk_id " paramClientID(clientWindowID)
        if (OldbotSettings.settingsJsonObj.input.mouseClickDelay > 1) {
            MouseMove, WindowX + params.posX, WindowY + params.posY
            Click, % "Down " params.button
            Sleep, % OldbotSettings.settingsJsonObj.input.mouseClickDelay
            Click, % "Up " params.button
            return
        }

        MouseClick, % params.button, WindowX + params.posX, WindowY + params.posY
        return
    }

    /**
    se não usar o controlfrompoint, está clicando mais pra baixo da coordenada
    como se não estivesse considerando o titulo da janela ou algo do tipo
    */
    ControlFromPoint(params.posX, params.posY, cX, cY, clientWindowID)
    ; msgbox, % posX "`n" cX "`n" posY "`n" cY

    ClickButtonDownShift(params.button, params.posX, params.posY, clientWindowID, params.debug)
    ClickButtonUpShift(params.button, params.posX, params.posY, clientWindowID)
}

ClickButtonDownShift(button, posX, posY, clientWindowID := "", debug := false) {
    /**
    correct order to send these messages in Tibia 11/12
    */
    ; SendMessage, % WM_NCACTIVATE := 0x0086, 0, , , % "ahk_id " paramClientID(clientWindowID)   ;NCHITTEST SEND
    ControlFromPoint(posX, posY, cX, cY, clientWindowID)

    if (debug) {
        m(button, cX, cY, paramClientID(clientWindowID))
    }

    MouseMovePostMessageClick(cX, cY, clientWindowID := "")
    Sleep, 10

    x := GetRelativeCoordX(posX)
    y := GetRelativeCoordY(posY)

    SendMessage, 0x084 , 0x00000000, x&0xFFFF | y<<16, , % "ahk_id " paramClientID(clientWindowID) ;NCHITTEST SEND

    SendMessage, 0x020 , %TibiaClientID%, 0x02040001, , % "ahk_id " paramClientID(clientWindowID) ;SETCURSOR SEND


    ; 0x02000001 is the for the "wMouseMsg" param of WM_SETCURSOR receive "WM_MOUSEMOVE" as value

    /**
    necessary to work on PXG but breaks tibia 11 client
    */
    if (OldBotSettings.settingsJsonObj.configFile = "settings_pokexgames.json") OR (OldBotSettings.settingsJsonObj.configFile = "settings_medivia.json") {
        ; MouseMovePostMessageClick(cX, cY, clientWindowID)
    }
    Send, {Shift down}
    ; Sleep, 10
    ; PostMessage,0x100, 0x10, 0x02A0001,, % "ahk_id " paramClientID(clientWindowID) ;WM_KEYDOWN := 0x100
    ; PostMessage,0x100, 0x10, 0x402A0001,, % "ahk_id " paramClientID(clientWindowID) ;WM_KEYDOWN := 0x100
    ; PostMessage,0x100, 0x10, 0x402A0001,, % "ahk_id " paramClientID(clientWindowID) ;WM_KEYDOWN := 0x100
    Sleep, 10

    /**
    0x0001/0x0002 param is for the message WM_LBUTTONDOWN param "fwKeys" receive the value "MK_LBUTTON"/"MK_RBUTTON"
    */
    PostMessage, % (button = "Left" ? 0x201 : 0x204), % (button = "Left" ? 0x0001 : 0x4 | 0x0002)  , cX&0xFFFF | cY<<16,, % "ahk_id " paramClientID(clientWindowID) ; WM_LBUTTONDOWN
    return
}

ClickButtonUpShift(button, posX, posY, clientWindowID := "") {
    ControlFromPoint(posX, posY, cX, cY, clientWindowID)
    PostMessage, % (button = "Left" ? 0x202 : 0x205), 0x4, cX&0xFFFF | cY<<16,, % "ahk_id " paramClientID(clientWindowID) ; WM_LBUTTONUP
    Sleep, 10
    Send, {Shift Up}
    return
}

GetRelativeCoordY(Y) {
    return abs(WindowY - Y)
}

GetRelativeCoordX(X) {
    return abs(WindowX - X)
}

; Retrieves the control at the specified point.
; X         [in]    X-coordinate relative to the top-left of the window.
; Y         [in]    Y-coordinate relative to the top-left of the window.
; WinTitle  [in]    Title of the window whose controls will be searched.
; WinText   [in]
; cX        [out]   X-coordinate relative to the top-left of the control.
; cY        [out]   Y-coordinate relative to the top-left of the control.
; ExcludeTitle [in]
; ExcludeText  [in]
; return Value:     The hwnd of the control if found, otherwise the hwnd of the window.
ControlFromPoint(X, Y, ByRef cX="", ByRef cY="", clientWindowID := "") {
    static EnumChildFindPointProc=0
    if !EnumChildFindPointProc
        EnumChildFindPointProc := RegisterCallback("EnumChildFindPoint","Fast")

    /**
    if clientWindowID is not a hex number, it can crash autohotkey
    */
    if (clientWindowID != "") && (!InStr(clientWindowID, "0x"))
        clientWindowID := ""

    target_window := (clientWindowID = "" OR clientWindowID = 0) ? TibiaClientID : clientWindowID
    ; msgbox, % target_window " / " clientWindowID " / " TibiaClientID
    if (target_window = "" OR target_window = 0) {
        throw Exception(A_ScriptName "." A_ThisFunc "`nEmpty Tibia client ID.")
        ; if !(target_window := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText))
        return false
    }

    VarSetCapacity(rect, 16)
    DllCall("GetWindowRect","uint",target_window,"uint",&rect)
    VarSetCapacity(pah, 36, 0)
    NumPut(X + NumGet(rect,0,"int"), pah,0,"int")
    NumPut(Y + NumGet(rect,4,"int"), pah,4,"int")
    DllCall("EnumChildWindows","uint",target_window,"uint",EnumChildFindPointProc,"uint",&pah)
    control_window := NumGet(pah,24) ? NumGet(pah,24) : target_window
    try DllCall("ScreenToClient","uint",control_window,"uint",&pah)
    catch e {
        Msgbox, 16,% A_ThisFunc, % e.Message "`n" e.What
        return 0
    }
    cX:=NumGet(pah,0,"int"), cY:=NumGet(pah,4,"int")
    ; msgbox, % X "`n" cX "`n" Y "`n" cY
    return control_window
}

; EnumChildFindPoint(hwnd, lParam) {
;     MsgBox, Found child window: %hwnd%, lparam %lParam%
;     return True
; }

;---------------------------------------------------------------------------
SendMouse_LeftClick() { ; send fast left mouse clicks
    DllCall("mouse_event", "UInt", 0x02) ; left button down
    DllCall("mouse_event", "UInt", 0x04) ; left button up
}

SendMouse_RightClick() { ; send fast right mouse clicks
    DllCall("mouse_event", "UInt", 0x08) ; right button down
    DllCall("mouse_event", "UInt", 0x10) ; right button up
}

SendMouse_MiddleClick() { ; send fast middle mouse clicks
    DllCall("mouse_event", "UInt", 0x20) ; middle button down
    DllCall("mouse_event", "UInt", 0x40) ; middle button up
}

SendMouse_RelativeMove(x, y) { ; send fast relative mouse moves
    DllCall("mouse_event", "UInt", 0x01, "UInt", x, "UInt", y) ; move
}

SendMouse_AbsoluteMove(x, y) { ; send fast absolute mouse moves
    ; Absolute coords go from 0..65535 so we have to change to pixel coords
    ;-----------------------------------------------------------------------
    static SysX, SysY
    If (SysX = "")
        SysX := 65535//A_ScreenWidth, SysY := 65535//A_ScreenHeight
    DllCall("mouse_event", "UInt", 0x8001, "UInt", x*SysX, "UInt", y*SysY)
}

SendMouse_Wheel(w) { ; send mouse wheel movement, pos=forwards neg=backwards
    ;---------------------------------------------------------------------------
    DllCall("mouse_event", "UInt", 0x800, "UInt", 0, "UInt", 0, "UInt", w)
}

; ######################## KEYBOARD + MOUSE ########################

MouseClickModifier(modifierKey, LeftOrRight, x, y, debug := false, clientWindowID := "") {
    if (backgroundKeyboardInput = false) && (OldbotSettings.settingsJsonObj.input.physicalPressModifierKeys = false)
        OldbotSettings.settingsJsonObj.input.physicalPressModifierKeys := true

    PressModifierKey(modifierKey, Key, clientWindowID)
    /**
    Needed sleep after pressing with modifier key
    Without the sleep Ctrl+K for example is failing sometimes in TIbia 11/12+
    */
    Sleep, 25

    MouseClick(LeftOrRight, x, y, debug, clientWindowID, waitModifierKeys := false)
    /**
    Needed sleep after pressing with modifier key
    */
    Sleep, 50

    ReleaseModifierKey(modifierKey, clientWindowID)
    return
}

/**
* right click to show the "Use" option menu
* @param int x
* @param int y
* @param ?bool debug
* @return void
*/
rightClickUse(x, y, debug := false)
{
    static classicControlDisabled
    if (classicControlDisabled == "") {
        classicControlDisabled := new _ClientInputIniSettings().get("classicControlDisabled")
    }

    MouseMove(x, y)
    if (classicControlDisabled) {
        MouseClick("Right", x, y, debug)
    } else {
        MouseClickModifier("Ctrl", "Right", x, y, debug)
    }
}

/*
hold Ctrl to trigger the "Use" action if classic control is disabled
*/
rightClickUseClassicControl(x, y, debug := false, clientWindowID := "") {
    static classicControlDisabled
    if (classicControlDisabled == "") {
        classicControlDisabled := new _ClientInputIniSettings().get("classicControlDisabled")
    }

    if (classicControlDisabled) {
        MouseClickModifier("Ctrl", "Right", x, y, debug, clientWindowID)
        return
    }

    MouseClick("Right", x, y, debug, clientWindowID)
}

rightClickUseWithoutPressingCtrl(x, y) {
    static classicControlDisabled
    if (classicControlDisabled == "") {
        classicControlDisabled := new _ClientInputIniSettings().get("classicControlDisabled")
    }

    /**
    if classic control is disabled, use the Open menu to open it
    otherwise just right click on it
    */
    if (classicControlDisabled) {
        return rightClickOnUse(x, y)
    }

    MouseClick("Right", x, y)
}

/**
* @param int x
* @param int y
* @param ?bool debug
* @return bool
*/
rightClickOnUse(x, y, debug := false) {
    static searchCache
    if (!searchCache) {
        searchCache := new _UseMenuSearch()
    }

    rightClickUse(x, y, debug)
    Sleep, 50

    Loop, 3 {
        _search := searchCache
            .setArea(new _WindowArea())
            .search()
            .click("Left",,, debug)

        if (_search.found()) {
            break
        }

        Sleep, 50
    }

    return _search.found()
}
