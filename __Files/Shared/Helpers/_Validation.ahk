#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

class _Validation extends _BaseClass
{
    static ERROR_LEVEL := -2

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param string varName
    * @param mixed value
    * @return void
    * @throws
    */
    true(varName, value)
    {
        if (value != true) {
            this._exception("""" varName """ is not true.")
        }
    }

    /**
    * @param string varName
    * @param mixed value
    * @return void
    * @throws
    */
    false(varName, value)
    {
        if (value != false) {
            this._exception("""" varName """ is not false.")
        }
    }

    /**
    * @param string varName
    * @param mixed value
    * @return void
    * @throws
    */
    empty(varName, value)
    {
        if (empty(value)) {
            this._exception("""" varName """ is empty.")
        }
    }

    /**
    * @param string varName
    * @param mixed value
    * @return void
    * @throws
    */
    number(varName, value)
    {
        if (empty(value)) {
            this._exception("""" varName """ is empty.")
        }

        if value is not number
        {
            this._exception("""" varName """ is not a number: " value)
        }
    }

    /**
    * @param string varName
    * @param mixed value
    * @return void
    * @throws
    */
    bool(varName, value)
    {
        if (empty(value)) {
            this._exception("""" varName """ is empty.")
        }

        if (!_A.isBoolean(value)) {
            this._exception("""" varName """ is boolean: " value)
        }
    }

    /**
    * @param string varName
    * @param mixed value
    * @return void
    * @throws
    */
    numberOrEmpty(varName, value)
    {
        if (empty(value)) {
            return
        }

        if value is not number
        {
            this._exception("""" varName """ is not a number: " value)
        }
    }

    /**
    * @param string varName
    * @param mixed value
    * @return void
    * @throws
    */
    string(varName, value)
    {
        if (empty(value)) {
            this._exception("""" varName """ is empty.")
        }

        if value is number
        {
            this._exception("""" varName """ is a number: " value)
        }

        this.object(varName, value)
    }

    /**
    * @param string varName
    * @param mixed value
    * @return void
    * @throws
    */
    stringOrNumber(varName, value)
    {
        if (empty(value)) {
            this._exception("""" varName """ is empty.")
        }

        this.object(varName, value)
    }

    /**
    * @param array<mixed> values
    * @return void
    * @throws
    */
    anyEmpty(values*)
    {
        if (isAnyEmpty(values)) {
            this._exception("A value is empty: " serialize(values))
        }
    }

    /**
    * @param string varName
    * @param string filePath
    * @return void
    * @throws
    */
    fileExists(varName, filePath)
    {
        this.empty("filePath", filePath)

        if (!InStr(FileExist(filePath), "A")) {
            this._exception("File does not exist: " filePath "`nWorkingDir:`n" A_WorkingDir "`n`n" FileExist(filePath))
        }
    }

    /**
    * @param string varName
    * @param string path
    * @return void
    * @throws
    */
    folderExists(varName, path)
    {
        this.empty(varName, path)

        if (!isFolder(path)) {
            this._exception("Folder does not exist: " path "`n`n" FileExist(path))
        }
    }

    /**
    * @param string varName
    * @param mixed value
    * @return void
    * @throws
    */
    isObject(varName, value)
    {
        if (!IsObject(value)) {
            this._exception("""" varName """ is not an object: " value)
        }
    }

    /**
    * @param string varName
    * @param mixed value
    * @return void
    * @throws
    */
    object(varName, value)
    {
        if (IsObject(value)) {
            this._exception("""" varName """ is an object.")
        }
    }

    /**
    * @param string varName
    * @param mixed value
    * @return void
    * @throws
    */
    function(varName, value)
    {
        if (!isFunction(value)) {
            this._exception("""" varName """ is not a function: " value)
        }
    }

    /**
    * @param string varName
    * @param mixed value
    * @param object expectedClass
    * @return void
    * @throws
    */
    instanceOf(varName, value, expectedClass)
    {
        this.empty(varName, value)

        if (empty(expectedClass)) {
            this._exception("Expected class is empty.")
        }

        if (!IsObject(expectedClass)) {
            this._exception("Expected class """ expectedClass """ is not an object.")
        }

        if (!instanceOf(value, expectedClass)) {
            this._exception("""" varName """ is not an instance of """ expectedClass.__Class """, base class: """ className """" )
        }
    }

    /**
    * @param string varName
    * @param mixed value
    * @return void
    * @throws
    */
    isCoordinate(varName, value)
    {
        return this.instanceOf(varName, value, _Coordinate)
    }

    /**
    * @param string varName
    * @param mixed value
    * @return void
    * @throws
    */
    isCoordinates(varName, value)
    {
        return this.instanceOf(varName, value, _Coordinates)
    }

    /**
    * @param string varName
    * @param string value
    * @param array<mixed> possibleValues
    * @return void
    * @throws
    */
    isOneOf(varName, value, possibleValues*)
    {
        for _, v in possibleValues {
            if (value = v) {
                return
            }
        }

        this._exception("""" varName """(""" value """) is not one of the expected values: " se(possibleValues) )
    }

    /**
    * @param string varName
    * @param string value
    * @param array<mixed> possibleValues
    * @return void
    * @throws
    */
    isNotOneOf(varName, value, possibleValues*)
    {
        for _, v in possibleValues {
            if (value = v) {
                this._exception("""" varName """(""" value """) cannot be one of the values: " se(possibleValues) )
            }
        }
    }

    /**
    * @param string varName
    * @param object object
    * @param string key
    * @return void
    * @throws
    */
    hasKey(varName, object, key, level := "")
    {
        try {
            throw Exception("""object"" is not an object, called for variable """ varName """.")
        } catch {
            this.isObject(varName, object)
        }

        if (!object.HasKey(key)) {
            ; this._exception("""" varName """ does not have key: " value "`n" (object.Count() > 500 ? "Too big to serialize" : se(object)), level)
            this._exception("""" varName """ does not have key: " key, level)
        }
    }

    /**
    * @param string idenifier
    * @param int bitmap
    * @throws
    */
    bitmap(identifier, bitmap)
    {
        this.empty(identifier, bitmap)

        try {
            _BitmapEngine.isValidBitmap(bitmap)
        } catch {
            this._exception("Bitmap """ identifier """ is invalid: " bitmap)
        }
    }

    /**
    * @param mixed left
    * @param mixed right
    * @throws
    */
    equals(left, right)
    {
        if (left != right) {
            this._exception("""" left """ is not equal to """ right """")
        }
    }

    /**
    * @param int left
    * @param int expected
    * @throws
    */
    higher(value, expected)
    {
        if (value <= expected) {
            this._exception("""" value """ is not higher than """ expected """")
        }
    }

    /**
    * @param string identifier
    * @param int y
    * @param int z
    * @return void
    * @throws
    */
    mapCoordinates(identifier, x, y, z)
    {
        this.mapCoordinateX(identifier ".x", x)
        this.mapCoordinateY(identifier ".y", y)
        this.mapCoordinateZ(identifier ".z", z)
    }

    /**
    * @param string varName
    * @param int x
    * @return void
    * @throws
    */
    mapCoordinateX(varName, x)
    {
        this.empty(varName, x)
        ; if (x <= tibiaMapX1 OR x >= tibiaMapX2) {
        ;     throw Exception("Invalid """ varName """ coordinate: " x ", outside of Real Tibia map range: " tibiaMapX1 " to " tibiaMapX2)
        ; }
    }

    /**
    * @param string varName
    * @param int y
    * @return void
    * @throws
    */
    mapCoordinateY(varName, y)
    {
        this.empty(varName, y)
        ; if (y <= tibiaMapY1 OR y >= tibiaMapY2) {
        ;     throw Exception("Invalid """ varName """ coordinate: " y ", outside of Real Tibia map range: " tibiaMapY1 " to " tibiaMapY2)
        ; }
    }

    /**
    * @param string varName
    * @param int z
    * @return void
    * @throws
    */
    mapCoordinateZ(varName, z)
    {
        this.empty(varName, z)
        if (z < 0 OR z > 15) {
            throw Exception("Invalid """ varName """ coordinate: " z ", outside of valid range: " 0 " to " 15)
        }
    }

    /**
    * @return void
    * @throws
    */
    connected()
    {
        if (isDisconnected()) {
            this._exception("Character is disconnected.")
        }
    }

    /**
    * @return void
    * @throws
    */
    clientOpened()
    {
        try {
            TibiaClient.checkClientSelected()
        } catch e {
            this._exception(txt("O cliente do Tibia não está aberto.", "Tibia client is not opened."))
        }
    }

    /**
    * @return void
    * @throws
    */
    clientClosed()
    {
        try {
            this.clientOpened()
        } catch {
            return
        }

        this._exception(txt("O cliente do Tibia não está fechado.", "Tibia client is not closed."))
    }

    /**
    * @param string htk
    * @return void
    * @throws
    */
    hotkey(htk)
    {
        static modifiers := ["^", "!", "+", "#"]
        msg := txt("Hotkeys com Ctrl, Shift ou Alt não são permitidas.",  "Hotkeys with Ctrl, Shift or Alt are not allowed.")

        for _, modifier in modifiers {
            if InStr(htk, modifier) {
                throw Exception(msg)
            }
        }

        if (RegExMatch(htk,"(Caps|Tab|Back|Space)")) {
            throw Exception(txt("Hotkey inválida, use outra hotkey.",  "Invalid hotkey, use another hotkey."))
        }

        if (containsSpecialCharacter(htk)) {
            throw Exception(txt("Caractéres especiais não são permitidos como hotkey.",  "Special characters are not allowed as hotkey."))
        }
    }

    /**
    * @param string msg
    * @return void
    * @throws
    */
    _exception(msg := "", level := "")
    {
        throw Exception("Message: " msg, _Validation.ERROR_LEVEL)
        ; throw Exception("Message: " msg, _Validation.ERROR_LEVEL)
        if (!A_IsCompiled) {
            lines := this.ScriptInfo("ListLines")

            clipboard := lines

            charactersToShow := 1500
            listLinesSeparator := "----"

            pos := InStr(lines, "ScriptInfo(")
            StringTrimRight, a, lines, % StrLen(lines) - pos - (StrLen("ScriptInfo(""ListLines"")"))

            lines := SubStr(a, -charactersToShow)
            exceptionFuncCallLine := InStr(lines, listLinesSeparator, 0, -1)

            linesWithoutCurrentExceptionFunc := SubStr(lines, 1, exceptionFuncCallLine - 1)

            linesWithoutFirstFuction := SubStr(linesWithoutCurrentExceptionFunc, InStr(linesWithoutCurrentExceptionFunc, listLinesSeparator) + StrLen(listLinesSeparator))

            sanitized := StrReplace(linesWithoutFirstFuction, A_ScriptDir "\", "`nFILE: ")

            throw Exception("MESSAGE: " msg "`n`nCALLSTACK:`n" sanitized, level ? level : _Validation.ERROR_LEVEL)
        }

    }

    ScriptInfo(Command)
    {
        static hEdit := 0, pfn, bkp
        if !hEdit {
            hEdit := DllCall("GetWindow", "ptr", A_ScriptHwnd, "uint", 5, "ptr")
            user32 := DllCall("GetModuleHandle", "str", "user32.dll", "ptr")
            pfn := [], bkp := []
            for i, fn in ["SetForegroundWindow", "ShowWindow"] {
                pfn[i] := DllCall("GetProcAddress", "ptr", user32, "astr", fn, "ptr")
                DllCall("VirtualProtect", "ptr", pfn[i], "ptr", 8, "uint", 0x40, "uint*", 0)
                bkp[i] := NumGet(pfn[i], 0, "int64")
            }
        }

        if (A_PtrSize=8) {  ; Disable SetForegroundWindow and ShowWindow.
            NumPut(0x0000C300000001B8, pfn[1], 0, "int64")  ; return TRUE
            NumPut(0x0000C300000001B8, pfn[2], 0, "int64")  ; return TRUE
        } else {
            NumPut(0x0004C200000001B8, pfn[1], 0, "int64")  ; return TRUE
            NumPut(0x0008C200000001B8, pfn[2], 0, "int64")  ; return TRUE
        }

        static cmds := {ListLines:65406, ListVars:65407, ListHotkeys:65408, KeyHistory:65409}
        cmds[Command] ? DllCall("SendMessage", "ptr", A_ScriptHwnd, "uint", 0x111, "ptr", cmds[Command], "ptr", 0) : 0

        NumPut(bkp[1], pfn[1], 0, "int64")  ; Enable SetForegroundWindow.
        NumPut(bkp[2], pfn[2], 0, "int64")  ; Enable ShowWindow.

        ControlGetText, text,, ahk_id %hEdit%
        return text
    }
}