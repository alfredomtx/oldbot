class _Key extends _BaseClass
{
    static MODIFIER_CTRL := "ctrl"
    static MODIFIER_SHIFT := "shift"

    static USE_CONTROL_SEND := true
    static DEFAULT_METHOD := true

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @param string key
    */
    __New(key)
    {
        this.key := key
        this.useControlSend := this.USE_CONTROL_SEND
        this.defaultMethod := this.DEFAULT_METHOD
        this.waitModifierKeys := true
    }

    setDefaultMethod(value)
    {
        this.defaultMethod := value
        return this
    }

    setUseControlSend(value)
    {
        this.useControlSend := value
        return this
    }

    press()
    {
        this.send(this.key)

        this.sleep()

        return this
    }

    /**
    * @throws
    */
    hold()
    {
        key := this.key
        try {
            ControlSend,, {%key% down}, % "ahk_id " TibiaClientID
            if (ErrorLevel) {
                throw Exception("Error sending key down : " key  ", ErrorLevel: " ErrorLevel ", id: " TibiaClientID)
            }
        }

        Sleep, 25

        return this
    }

    /**
    * @throws
    */
    release(sleep := true)
    {
        key := this.key
        try {
            ControlSend,, {%key% up}, % "ahk_id " TibiaClientID
            if (ErrorLevel) {
                throw Exception("Error sending key up: " key  ", ErrorLevel: " ErrorLevel ", id: " TibiaClientID)
            }
        }

        if (sleep) {
            Sleep, 25
        }

        return this
    }

    /**
    * @return this
    */
    ctrl()
    {
        this.modifier := this.MODIFIER_CTRL
        return this
    }

    /**
    * @return void
    */
    sleep()
    {
        static delay, randomDelay, min, max
        if (!delay) {
            delay := new _OldBotIniSettings().get("keyPressDelay")
            randomDelay := new _OldBotIniSettings().get("keyPressRandomDelay")

            min := delay - (randomDelay / 2)
            if (min < 0) {
                min := 0
            }

            max := delay + (randomDelay / 2)
        }

        Random, R, min, max
        this.realDelay := delay + R

        Sleep, % this.realDelay
    }

    send(Key, modifierKeyHold := false)
    {
        if (empty(Key)) {
            return
        }

        if (this.waitModifierKeys) {
            KeyWait, Control, T5
            KeyWait, Shift, T5
            KeyWait, Alt, T5
        }

        firstChar := SubStr(Key, 1, 1)
        if (firstChar = "^")
            return SendModifier("Ctrl", SubStr(Key, 2, StrLen(Key) - 1), TibiaClientID)
        if (firstChar = "+")
            return SendModifier("Shift", SubStr(Key, 2, StrLen(Key) - 1), TibiaClientID)
        if (firstChar = "!")
            return SendModifier("Alt", SubStr(Key, 2, StrLen(Key) - 1), TibiaClientID)

        if (!backgroundKeyboardInput) {
            If (StrLen(Key) = 1 OR RegExMatch(Key, this.keysRegex())) {
                WinActivate() ; FIXME: might need to be removed
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

        PostMessage 0x07, , , , % "ahk_id " TibiaClientID ; WM_SETFOCUS (https://autohotkey.com/board/topic/64721-howto-send-keys-to-background-window-lotro/)

        /**
        For medivia only ControlSend is working, SendMessage is spamming like the key is not being released
        */
        if (OldBotSettings.settingsJsonObj.input.useCSend) {
            If (RegExMatch(Key,"(F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|Enter|Esc|Space|Del|Tab|Home|End|Insert|PgUp|PgDown|Up|Down|Left|Right|Num |Numpad)"))
                ControlSend,, {%key%}, % "ahk_id " TibiaClientID
            else
                write(key, TibiaClientID)
            return
        }

        switch key {
                /**
                F1 - F12
                */
            case "F1":
                vk := 0x70
                SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x03B0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "F2":
                vk := 0x71
                SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x03C0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "F3":
                vk := 0x72
                SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x03D0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "F4":
                vk := 0x73
                SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x03E0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "F5":
                vk := 0x74
                SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x03F0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "F6":
                vk := 0x75
                SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x0400001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "F7":
                vk := 0x76
                SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x0410001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "F8":
                vk := 0x77
                SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x0420001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "F9":
                vk := 0x78
                SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x0430001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "F10":
                vk := 0x79
                SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x0440001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "F11":
                vk := 0x7A
                SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x0570001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "F12":
                vk := 0x7B
                SendMessage, % (OldbotSettings.settingsJsonObj.input.pressF1toF12KeysDefaultMethod = true) ? 0x100 : 0x102, %vk%, 0x0580001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)

                /**
                numbers
                1 on KEYDOWN param because if sent the 0xC$keycode was sending multiple times in tibia
                */
            case "0":
                vk := 0x30
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0B0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "1":
                vk := 0x31
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x020001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "2":
                vk := 0x32
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x030001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "3":
                vk := 0x33
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x040001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "4":
                vk := 0x34
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x050001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "5":
                vk := 0x35
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x060001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "6":
                vk := 0x36
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x070001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "7":
                vk := 0x37
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x080001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "8":
                vk := 0x38
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x090001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "9":
                vk := 0x39
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0A0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)

                /**
                letters
                */
            case "a":
                vk := 0x41
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x01E0001,, % "ahk_id " TibiaClientID
                ; SendMessage, 0x101, %vk%, 0x01E0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "b":
                vk := 0x42
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0300001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "c":
                vk := 0x43
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x02E0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "d":
                vk := 0x44
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0200001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "e":
                vk := 0x45
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0120001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "f":
                vk := 0x46
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0210001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "g":
                vk := 0x47
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0220001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "h":
                vk := 0x48
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0230001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "i":
                vk := 0x49
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0170001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "j":
                vk := 0x4A
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0240001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "k":
                vk := 0x4B
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0250001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "l":
                vk := 0x4C
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0260001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "m":
                vk := 0x4D
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0320001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "n":
                vk := 0x4E
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0310001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "o":
                vk := 0x4F
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0180001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "p":
                vk := 0x50
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0190001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "q":
                vk := 0x51
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0100001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "r":
                vk := 0x52
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0130001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "s":
                vk := 0x53
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x01F0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "t":
                vk := 0x54
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0140001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "u":
                vk := 0x55
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0160001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "v":
                vk := 0x56
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x02F0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "w":
                vk := 0x57
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0110001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "x":
                vk := 0x58
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x02D0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "y":
                vk := 0x59
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x0150001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "z":
                vk := 0x5A
                msgParam := (this.defaultMethod OR modifierKeyHold = true) ? 0x100 : 0x102
                SendMessage, % msgParam, %vk%, 0x02C0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)

                /**
                arrows
                */
            case "Up":
                vk := 0x26
                switch OldbotSettings.settingsJsonObj.input.postMsgArrowKeys {
                    case true:
                        ; PostMessage, % OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x01480001,, % "ahk_id " TibiaClientID
                        PostMessage, 0x100, %vk%, 0x01480001,, % "ahk_id " TibiaClientID
                        PostMessage, 0x101, %vk%, 0x01480001,, % "ahk_id " TibiaClientID
                    case false:
                        SendMessage, 0x100, %vk%, 0x01480001,, % "ahk_id " TibiaClientID
                        SendMessage, 0x101, %vk%, 0x01480001,, % "ahk_id " TibiaClientID
                }
            case "Down":
                vk := 0x28
                switch OldbotSettings.settingsJsonObj.input.postMsgArrowKeys {
                    case true:
                        PostMessage, 0x100, %vk% , 0x01500001,, % "ahk_id " TibiaClientID
                        PostMessage, 0x101, %vk% , 0x01500001,, % "ahk_id " TibiaClientID
                    case false:
                        SendMessage, 0x100, %vk%, 0x01500001,, % "ahk_id " TibiaClientID
                        SendMessage, 0x101, %vk%, 0x01500001,, % "ahk_id " TibiaClientID
                }
            case "Left":
                vk := 0x25
                switch OldbotSettings.settingsJsonObj.input.postMsgArrowKeys {
                    case true:
                        PostMessage, 0x100, %vk%, 0x014B0001,, % "ahk_id " TibiaClientID
                        PostMessage, 0x101, %vk%, 0x014B0001,, % "ahk_id " TibiaClientID
                    case false:
                        SendMessage, 0x100, %vk%, 0x014B0001,, % "ahk_id " TibiaClientID
                        SendMessage, 0x101, %vk%, 0x014B0001,, % "ahk_id " TibiaClientID
                }
            case "Right":
                vk := 0x27
                switch OldbotSettings.settingsJsonObj.input.postMsgArrowKeys {
                    case true:
                        PostMessage, 0x100, %vk%, 0x014D0001,, % "ahk_id " TibiaClientID
                        PostMessage, 0x101, %vk%, 0x014D0001,, % "ahk_id " TibiaClientID
                    case false:
                        SendMessage, 0x100, %vk%, 0x014D0001,, % "ahk_id " TibiaClientID
                        SendMessage, 0x101, %vk%, 0x014D0001,, % "ahk_id " TibiaClientID
                }

                /**
                other keys
                */
            case "Enter":
                vk := 0x0D
                SendMessage, % OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x01C0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Esc":
                vk := 0x1B
                switch OldbotSettings.settingsJsonObj.input.postMsgEscKey {
                    case true:
                        PostMessage, % OldbotSettings.settingsJsonObj.input.pressEscDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x010001,, % "ahk_id " TibiaClientID
                        PostMessage, 0x101, %vk%, 1,, % "ahk_id " TibiaClientID
                    case false:
                        SendMessage, % OldbotSettings.settingsJsonObj.input.pressEscDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x010001,, % "ahk_id " TibiaClientID
                        SendMessageKeyUp(vk, TibiaClientID)
                }
            case "Backspace":
                vk := 0x08
                SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x0E0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "ScrollLock":
                vk := 0x91
                SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x0460001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Capslock":
                vk := 0x14
                SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x03A0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Space":
                vk := 0x20
                SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x0390001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Del", case "Delete":
                vk := 0x2E
                SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x01530001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Tab":
                vk := 0x09
                SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x0F0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Home":
                vk := 0x24
                SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x01470001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "End":
                vk := 0x23
                SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x014F0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Insert":
                vk := 0x2D
                SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x01520001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "PgUp", case "PageUp":
                vk := 0x21
                SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x01490001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "PgDn", case "PgDown", case "PageDown":
                vk := 0x22
                SendMessage, OldbotSettings.settingsJsonObj.input.pressKeyDefaultMethod = true ? 0x100 : 0x102, %vk%, 0x01510001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)

                /**
                symbols
                */
            case "+":
                ; numpad +
                vk := 0xBB
                SendMessage, 0x100, %vk%, 0x04E0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case ",":
                vk := 0xBC
                SendMessage, 0x100, %vk%, 0x0330001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "-":
                vk := 0xBD
                SendMessage, 0x100, %vk%, 0x0C0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case ".":
                vk := 0xBE
                SendMessage, 0x100, %vk%, 0x0340001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "/":
                vk := 0xBF
                SendMessage, 0x100, %vk%, 0x0730001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "\":
                vk := 0xDC
                SendMessage, 0x100, %vk%, 0x0560001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "~":
                vk := 0xC0
                SendMessage, 0x100, %vk%, 0x0280001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)

                /**
                Numpad keys
                */
            case "Numpad0", case "Num0":
                vk := 0x60
                SendMessage, 0x100, %vk%, 0x0520001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Numpad1", case "Num1":
                vk := 0x61
                SendMessage, 0x100, %vk%, 0x04F0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Numpad2", case "Num2":
                vk := 0x62
                SendMessage, 0x100, %vk%, 0x0500001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Numpad3", case "Num3":
                vk := 0x63
                SendMessage, 0x100, %vk%, 0x0510001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Numpad4", case "Num4":
                vk := 0x64
                SendMessage, 0x100, %vk%, 0x04B0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Numpad5", case "Num5":
                vk := 0x65
                SendMessage, 0x100, %vk%, 0x04C0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Numpad6", case "Num6":
                vk := 0x66
                SendMessage, 0x100, %vk%, 0x04D0001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Numpad7", case "Num7":
                vk := 0x67
                SendMessage, 0x100, %vk%, 0x0470001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Numpad8", case "Num8":
                vk := 0x68
                SendMessage, 0x100, %vk%, 0x0480001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            case "Numpad9", case "Num9":
                vk := 0x69
                SendMessage, 0x100, %vk%, 0x0490001,, % "ahk_id " TibiaClientID
                SendMessageKeyUp(vk, TibiaClientID)
            default:
                If (RegExMatch(Key, this.keysRegex()))
                    ControlSend,, {%key%}, % "ahk_id " TibiaClientID
                else {
                    ; ControlSend,, %key%, % "ahk_id " TibiaClientID
                    write(key, TibiaClientID)
                }
        }
    }

    keysRegex()
    {
        static regex := "(?i)(F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|Enter|Esc|Space|Del|Tab|Home|End|Insert|PgUp|PgDown|Up|Down|Left|Right|Num |Numpad)"

        return regex
    }
}