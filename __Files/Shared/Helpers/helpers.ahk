
__CallCustom(this, method, args*)
{
    if (this[method]) {
        methodParams(this[method], method, args)
        return this[method].Call(this, args*)
    }

    base := ObjGetBase(this)
    class := iterateChildClasses(base, method)
    if (class) {
        return callClassMethod(this, class, method, args*)
    }

    class := iterateBaseClass(ObjGetBase(base), method)
    if (class) {
        return callClassMethod(this, class, method, args*)
    }

    if method not in Insert,Remove,MinIndex,MaxIndex,SetCapacity
            ,GetCapacity,GetAddress,_NewEnum,HasKey,Clone
        throw Exception("Non-existent method: " method ", args: " serialize(args))
}

callClassMethod(this, class, method, args*)
{
    methodParams(class[method], method, args)

    return class[method].Call(this, args*)
}

iterateBaseClass(class, method)
{
    childClassWithMethod := iterateChildClasses(class, method)
    if (childClassWithMethod) {
        return childClassWithMethod
    }

    base := ObjGetBase(class)
    if (base) {
        return iterateBaseClass(base, method)
    }
}

iterateChildClasses(class, method)
{
    for property, propertyClass in class {
        if (SubStr(property, 1, 1) != "_") {
            break
        }

        if (propertyClass[method]) {
            return propertyClass
        }
    }
}

/**
* @param FuncObj funcObj
* @param string method
* @param array args
* @return void
* @throws
*/
methodParams(funcObj, method, args)
{
    ; if method in Insert,Remove,MinIndex,MaxIndex,SetCapacity
    ;         ,GetCapacity,GetAddress,_NewEnum,HasKey,Clone
    ; {
    ;     count := Round(args.MaxIndex())
    ; } else {
    ;     count := Round(args.MaxIndex()) + 1 ; add one for hidden 'this'
    ; }
    if (!funcObj) {
        return
    }

    count := Round(args.MaxIndex()) + 1 ; add one for hidden 'this'

    try {
        if (count < funcObj.MinParams)
            throw Exception("`nToo few parameters passed to method.", -1, count)
        else if (count > funcObj.MaxParams) && !funcObj.IsVariadic
            throw Exception("`nToo many parameters passed to method.", -1, count)
    } catch e {
        e.Message .= "`n- Method: " method "`n- Function method name: " funcObj.name "`n- Expecting: " count - 1 "`n- Args: " args "`n- Serialized: " se(args)  "`n- FuncObj: " se(funcObj)

        _Logger.exception(e)
        throw e
    }
}

/**
* @param string className
* @param object classObject
* @return void
* @throws
*/
classLoaded(className, classObject)
{
    if (!classObject || !IsObject(classObject)) {
        throw Exception(className " not initialized.", -2)
    }
}

/**
* @return void
* @throws
*/
abstractMethod()
{
    throw Exception("Abstract method not implemented: " A_ThisFunc, -2)
}

/**
* @param object inheritorClass
* @param object abstractClass
* @return void
* @throws
*/
guardAgainstAbstractClassInstance(inheritorClass, abstractClass)
{
    if (inheritorClass.base.__Class != abstractClass.__Class) {
        if (inheritorClass = "") {
            throw Exception("Instantiating abstract class without inheritor: " abstractClass.__Class, -1)
        }

        throw Exception("Instantiating abstract class: " abstractClass.__Class, -1)
    }
}

/**
* @param object class
* @return void
* @throws
*/
guardAgainstInstantiation(class)
{
    throw Exception("Instantiating static class: " class.__Class, -1)
}

/**
* @param array<mixed> values
* @return bool
*/
isAllEmpty(values*)
{
    values := (values.MaxIndex() == 1) ? values.1 : values

    for _, value in values {
        if (value) {
            return false
        }
    }

    return true
}

/**
* @param array<mixed> values
* @return bool
*/
isAnyEmpty(values*)
{
    values := (values.MaxIndex() == 1) ? values.1 : values

    for _, value in values {
        if (!value) {
            return true
        }
    }

    return false
}

/**
* @param mixed value
* @return bool
*/
empty(value := "")
{
    return (value = "" || value = A_Space) && value != 0
}

/**
* @param object obj
* @return string
*/
serialize(obj)
{
    if !IsObject(obj)
        return ""
    str := "{"
    for k,v in obj
    {
        if IsObject(v)
        {
            if IsFunc(v.name)
                v := "Function"
            else
                v := serialize(v)
        }
        str .= k ":" v ", "
    }
    if IsObject(obj.base)
        str .= "base:" serialize(obj.base) ", "
    return RegexReplace(str, ", $", "") "}"
}

/**
* @param object obj
* @return string
*/
se(obj)
{
    return serialize(obj)
}

/**
* @param array<mixed> msg
* @return void
* @msgbox
*/
m(msg*)
{
    if (A_IsCompiled) {
        return
    }

    Gui, Carregando:Destroy
    Gui, CarregandoGUI:Destroy

    stringM := ""
    for _, value in msg {
        if (A_index > 1) {
            stringM .= "`n`n"
        }

        if (IsObject(value)) {
            stringM .= serialize(value)
        } else {
            stringM .= value
        }
    }

    msgbox, % stringM
}

/**
* @param mixed object
* @param object expectedClass
* @return true
*/
instanceOf(object, expectedClass)
{
    if (!IsObject(object)) {
        return false
    }

    if (object.__Class = expectedClass.__Class) {
        return true
    }

    baseClass := object.base
        , baseClassName := StrReplace(baseClass.__Class, ".Base", "")

    Loop, {
        if (baseClassName = expectedClass.__Class) {
            return true
        }

        if (IsObject(baseClass.base)) {
            baseClass := baseClass.base
                , baseClassName := baseClass.__Class
        } else {
            break
        }
    }

    return false
}

/**
* @param array haystack
* @param string needle
* @return int
*/
InArray(haystack, needle)
{
    if !(IsObject(haystack)) || (haystack.Length() = 0) {
        return 0
    }

    for index, value in haystack
        if (value = needle)
            return index
    return 0
}

/**
* @param string pt
* @param string en
* @param ?string prepend
* @return string
*/
txt(pt, en, prepend := "")
{
    global LANGUAGE
    return (LANGUAGE = "PT-BR" ? pt : en) prepend
}

/**
* @param string pt
* @param string en
* @param ?string prepend
* @return string
*/
__(pt, en, prepend := "")
{
    global LANGUAGE
    return (LANGUAGE = "PT-BR" ? pt : en) prepend
}

/**
* @param bool value
* @return string
*/
boolToString(value)
{
    return value = true ? "true" : "false"
}

/**
* @param string value
* @return bool
*/
stringToBool(value)
{
    return value = "true" || value = "1" ? true : false
}

/**
* @param mixed value
* @return bool
*/
bool(value)
{
    return value ? true : false
}

/**
* @param int z
* @return string
*/
floorString(z)
{
    return StrLen(z) = 1 ? "0" z : z
}

/**
* @param string string
* @return string
*/
lcfirst(string)
{
    firstLetter := strtolower(SubStr(string,1, 1))
    return firstLetter "" SubStr(string, 2, StrLen(string))
}

/**
* @param string string
* @return string
*/
ucfirst(string)
{
    firstLetter := strtoupper(SubStr(string,1, 1))
    return firstLetter "" SubStr(string, 2, StrLen(string))
}

/**
* @param string string
* @return string
*/
strtoupper(string)
{
    return Format("{:U}", string)
}

/**
* @param string string
* @return string
*/
strtolower(string)
{
    return Format("{:L}", string)
}

/**
* @param int min
* @param int max
* @return int
*/
random(min, max)
{
    Random, R, min, max
    return R
}

/**
* @return bool
*/
isCavebotExecutable()
{
    return InStr(A_ScriptName, "Cavebot")
}

/**
* @return bool
*/
isFunction(value)
{
    funcRefrence := numGet(&(_ := Func("inStr").bind()), "ptr")
    return isFunc(value) || (isObject(value) && (numGet(&value, "ptr") = funcRefrence))
}

/**
* @param string string
* @return ?string
*/
lang(string, capitalized := true)
{
    switch string {
        case "cancel": string := txt("cancelar", "cancel")
        case "close": string := txt("fechar", "close")
        case "conditions": string := txt("condições", "conditions")
        case "delete": string := txt("deletar", "delete")
        case "enabled": string := txt("ativado", "enabled")
        case "edit": string := txt("editar", "edit")
        case "elapsed": string := txt("duração", "elapsed")
        case "left click": string := txt("clique esquerdo", "left click")
        case "ms": string := txt("milisegundos", "miliseconds")
        case "name": string := txt("nome", "name")
        case "open": string := txt("abrir", "open")
        case "options": string := txt("opções", "options")
        case "remove": string := txt("remover", "remove")
        case "right click": string := txt("clique direito", "right click")
        case "save": string := txt("salvar", "save")
        case "settings": string := txt("configurações", "settings")
        case "space": string := txt("espaço", "space")
        case "toggle": string := txt("alternar", "toggle")
    }

    if (capitalized) {
        return ucfirst(string)
    }

    return string
}

/**
* @param string name
* @return bool
* @throws
*/
clientHasFeature(name)
{
    ; if (!OldBotSettings.settingsJsonObj.clientFeatures.HasKey(name)) {
    _Validation.hasKey("OldBotSettings.settingsJsonObj.clientFeatures." name, OldBotSettings.settingsJsonObj.clientFeatures, name)
    ; }

    return OldBotSettings.settingsJsonObj.clientFeatures[name] ? true : false
}

/**
* @return string
*/
clientIdentifier(memoryIdentifier := true)
{
    static value
    if (value) {
        return value
    }

    settings := new _SettingsJson()
    classLoaded("_SettingsJson", _SettingsJson)

    m := settings.get("tibiaClient.memoryIdentifier")
    if (memoryIdentifier = true) && (settings.get("tibiaClient.memoryIdentifier")) {
        return value := settings.get("tibiaClient.memoryIdentifier")
    }
    if (settings.get("tibiaClient.clientImagesCategoryIdentifier") = "") {
        return value := StrReplace(StrReplace(settings.get("configFile"), "settings_"), ".json", "")
    } else {
        return value := settings.get("tibiaClient.clientImagesCategoryIdentifier")
    }
}

/**
* @param string identifier
* @param ?string text
* @return void
*/
OutputDebug(identifier, text := "")
{
    OutputDebug, % "OldBot | " identifier " | " text "`n"
}

/**
* @param string identifier
* @param ?string text
* @return void
*/
out(identifier, text := "")
{
    OutputDebug(identifier, text)
}

/**
* @param string string
* @return bool
*/
containsSpecialCharacter(string)
{
    Loop, % StrLen(string) {
        stringmid,passchar,string,%A_Index%,1
        if (inStr("±!@#$%^&*()+=-;,.<>/?/:""'|\[]{}`´~",passchar)) {
            return true
        }
    }

    return false
}

/**
* @param int num
* @param int total
* @throws
*/
percentage(num, total)
{
    _Validation.number("num", num)
    _Validation.number("total", total)

    if (total = 0) {
        throw Exception("Total is zero")
    }

    percentage := (num / total) * 100
    return round(percentage)
}

/**
* @return bool
*/
isDisconnected()
{
    return TibiaClient.isDisconnected()
}

/**
* @return bool
*/
isConnected()
{
    return !isDisconnected()
}

/**
* @param string path
* @return bool
*/
isFolder(path)
{
    return InStr(FileExist(path), "D") ? true : false
}

/**
* @return bool
*/
isWin11()
{
    return StrReplace(A_OSVersion, ".", "") >= 10022000
}

/**
* @param mixed value
*/
string(value)
{
    return "" value ""
}

/**
* @param BoundFunc callback
* @param int retries
* @param int delay
* @param ?string identifier
* @return mixed
* @throws
*/
retry(callback, retries, delay, identifier := "")
{
    Loop, % retries {
        if (A_Index > 1) {
            _Logger.log("Retrying " A_Index "/" retries ", error: " e.Message, identifier)
            Sleep, % delay
        }

        try {
            return %callback%()
        } catch e {
            if (A_Index == retries) {
                throw e
            }
        }
    }
}

/**
* @param BoundFunc callback
* @return mixed
*/
tryCatch(callback, logException := false)
{
    try {
        return %callback%()
        ; return callback.Call()
    } catch e {
        if (logException) {
            _Logger.exception(e, A_ThisFunc)
        }

        return
    }
}

/**
* @param BoundFunc callback
* @param ?bool condition
* @return void
*/
callables(callables, condition := "")
{
    for _, callable in callables {
        result := callable.Call()
        if (condition == true && result) {
            return true
        }

        if (condition == false && !result) {
            return true
        }
    }

    return false
}

/**
* @param BoundFunc callback
* @param ?string identifier
* @return bool
*/
callablesTrue(callables)
{
    for _, callable in callables {
        if (callable.Call()) {
            return true
        }
    }

    return false
}

/**
* @param BoundFunc callback
* @param ?string identifier
* @return bool
*/
callablesFalse(callables)
{
    for _, callable in callables {
        if (!callable.Call()) {
            return true
        }
    }

    return false
}

/**
* @param int processId
* @return bool
*/
isProcessElevated(processId)
{
    if !(hProcess := DllCall("OpenProcess", "uint", 0x0400, "int", 0, "uint", processId, "ptr"))
        throw Exception("OpenProcess failed", -1)
    if !(DllCall("advapi32\OpenProcessToken", "ptr", hProcess, "uint", 0x0008, "ptr*", hToken))
        throw Exception("OpenProcessToken failed", -1), DllCall("CloseHandle", "ptr", hProcess)
    if !(DllCall("advapi32\GetTokenInformation", "ptr", hToken, "int", 20, "uint*", IsElevated, "uint", 4, "uint*", size))
        throw Exception("GetTokenInformation failed", -f1), DllCall("CloseHandle", "ptr", hToken) && DllCall("CloseHandle", "ptr", hProcess)

    return IsElevated, DllCall("CloseHandle", "ptr", hToken) && DllCall("CloseHandle", "ptr", hProcess)
}

/**
* ATTENTION: May cause memory leak when called multiple times
*
* @param ?string Cursor
* @param int cx
* @param int cy
* @return void
*/
setSystemCursor( Cursor = "", cx = 0, cy = 0 )
{
    /**
    IDC_ARROW := 32512
    IDC_IBEAM := 32513
    IDC_WAIT := 32514
    IDC_CROSS := 32515
    IDC_UPARROW := 32516
    IDC_SIZE := 32640
    IDC_ICON := 32641
    IDC_SIZENWSE := 32642
    IDC_SIZENESW := 32643
    IDC_SIZEWE := 32644
    IDC_SIZENS := 32645
    IDC_SIZEALL := 32646
    IDC_NO := 32648
    IDC_HAND := 32649
    IDC_APPSTARTING := 32650
    IDC_HELP := 32651
    */
    BlankCursor := 0, SystemCursor := 0, FileCursor := 0 ; init

    SystemCursors = 32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS
        ,32516IDC_UPARROW,32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE
        ,32643IDC_SIZENESW,32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL
        ,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP

    If Cursor = ; empty, so create blank cursor
    {
        VarSetCapacity( AndMask, 32*4, 0xFF ), VarSetCapacity( XorMask, 32*4, 0 )
        BlankCursor = 1 ; flag for later
    }
    Else If SubStr( Cursor,1,4 ) = "IDC_" ; load system cursor
    {
        Loop, Parse, SystemCursors, `,
        {
            CursorName := SubStr( A_Loopfield, 6, 15 ) ; get the cursor name, no trailing space with substr
            CursorID := SubStr( A_Loopfield, 1, 5 ) ; get the cursor id
            SystemCursor = 1
            If ( CursorName = Cursor )
            {
                CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )
                Break
            }
        }
        If CursorHandle = ; invalid cursor name given
        {
            Msgbox,, SetCursor, Error: Invalid cursor name
            CursorHandle = Error
        }
    }
    Else If FileExist( Cursor )
    {
        SplitPath, Cursor,,, Ext ; auto-detect type
        If Ext = ico
            uType := 0x1
        Else If Ext in cur,ani
            uType := 0x2
        Else ; invalid file ext
        {
            Msgbox,, SetCursor, Error: Invalid file type
            CursorHandle = Error
        }
        FileCursor = 1
    }
    Else
    {
        Msgbox,, SetCursor, Error: Invalid file path or cursor name
        CursorHandle = Error ; raise for later
    }
    If CursorHandle != Error
    {
        Loop, Parse, SystemCursors, `,
        {
            If BlankCursor = 1
            {
                Type = BlankCursor
                %Type%%A_Index% := DllCall( "CreateCursor"
                    , Uint,0, Int,0, Int,0, Int,32, Int,32, Uint,&AndMask, Uint,&XorMask )
                CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
                DllCall( "setSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
            }
            Else If SystemCursor = 1
            {
                Type = SystemCursor
                CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )
                %Type%%A_Index% := DllCall( "CopyImage"
                    , Uint,CursorHandle, Uint,0x2, Int,cx, Int,cy, Uint,0 )
                CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
                DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
            }
            Else If FileCursor = 1
            {
                Type = FileCursor
                %Type%%A_Index% := DllCall( "LoadImageA"
                    , UInt,0, Str,Cursor, UInt,uType, Int,cx, Int,cy, UInt,0x10 )
                DllCall( "SetSystemCursor", Uint,%Type%%A_Index%, Int,SubStr( A_Loopfield, 1, 5 ) )
            }
        }
    }

    SetTimer, restoreCursor, Delete
    SetTimer, restoreCursor, -5000
}

/**
* @return void
*/
restoreCursor()
{
    DllCall("SystemParametersInfo", "uint", SPI_SETCURSORS := 0x57, "uint", 0, "ptr", 0, "uint", 0)
}

/**
* @param string text
* @return bool
*/
isUpperCase(text)
{
    return text == strtoupper(text) ? true : false
}

/**
* @param string setting
* @param array<string> key
* @return mixed
*/
jsonConfig(setting, key*)
{
    local system, obj, arr

    if (InStr(setting, ".") && !key.MaxIndex()) {
        arr := StrSplit(setting, ".")
        setting := _Arr.first(arr)
        key := _Arr.values(_Arr.shift(arr))
    }

    switch (setting) {
        default:
            system := %setting%System
            obj := setting "JsonObj"
    }

    switch (key.MaxIndex()) {
        case 1:
            return system[obj][key.1]
        case 2:
            return system[obj][key.1][key.2]
        case 3:
            return system[obj][key.1][key.2][key.3]
        default:
            throw Exception("Invalid key " serialize(key) " for setting " setting)
    }
}

/**
* @param string path
* @param ?mixed default
* @param ?string folder
* @return mixed
*/
jconfig(dotPath, default := "", folder := "")
{
    static cache := {}

    if (cache[dotPath]) {
        return cache[dotPath]
    }

    arr := StrSplit(dotPath, ".")
    file := _Arr.first(arr)
    ; _Validation.empty("file", file)
    keys := _Arr.values(_Arr.shift(arr))

    filePath := (folder ? folder : _Folders.JSON) "\" file ".json"
    if (!cache[filePath]) {
        cache[filePath] := _Json.load(filePath)
    }

    value := GetNestedKey(cache[filePath], keys)
    if (value = "") {
        value := default
    }

    if (!cache[dotPath]) {
        cache[dotPath] := value
    }

    return value
}

ims(dotPath, params := "")
{
    static cache := {}
    local search, config, defaultConfig, image, key

    if (cache[dotPath]) {
        return cache[dotPath]
    }

    config := jconfig(dotPath)

    key := _Arr.last(StrSplit(dotPath, "."))

    defaultKey := StrReplace(dotPath, "." key, ".default")
    defaultConfig := jconfig(defaultKey)
    if (!config.image) {
        image := config
        config := {}
        config.image := image
    }

    ; TODO: merge params with config
    if (params.area) {
        config.area := params.area
    }

    config := _Arr.merge(defaultConfig, config)

    search := new _ImageSearch()
        .setFolder(config.folder)
        .setVariation(config.variation)
        .setFile(config.image)
        .setArea(config.area ? new _ClientAreaFactory(config.area) : new _WindowArea())
        .setTransColor(config.transColor)
        .setDebug(config.debug)
        .setDebugResult(config.debugResult)

    if (config.cache == false || params.cache == false) {
        return search
    }

    return cache[dotPath] := search
}

GetNestedKey(obj, keys) {
    ; keys := StrSplit(key, ".")  ; Split the key string by dots
    result := obj
    for _, subkey in keys {
        if !IsObject(result) || !result.HasKey(subkey)
            return ""
        result := result[subkey]
    }
    return result
}

/**
* @param int n
* @return bool
*/
isEven(n)
{
    return mod(n, 2) = 0
}

/**
* @param int n
* @return bool
*/
isOdd(n)
{
    return n&1
}

/**
* @param mixed value
* @return bool
*/
isNumber(value)
{
    if value is number
    {
        return true
    }

    return false
}

/**
* @param mixed value
* @return bool
*/
int(value)
{
    return Format("{:0.0f}", value)
}

Hash(Options, ByRef Var, nBytes:="")
{ ;                                 Hash() v0.37 by SKAN on D444/D445 @ tiny.cc/hashit
    Local
    HA := {"ALG":"SHA256","BAS":0, "UPP":1, "ENC":"UTF-8"}
    Loop, Parse, % Format("{:U}", Options), %A_Space%, +
        A := StrSplit(A_LoopField, ":", "+"), HA[ SubStr(A[1], 1, 3) ] := A[2]

    HA.X := ( HA.ENC="UTF-16" ? 2 : 1)
    OK1  := { "SHA1":1, "SHA256":1, "SHA384":1, "SHA512":1, "MD2":1, "MD4":1, "MD5":1 }[ HA.ALG ]
    OK2  := { "CP0":1, "UTF-8":1, "UTF-16":1}[ HA.ENC ]
    NaN  := ( StrLen(nBytes) And (nBytes != Round(nBytes)) ),                    lVar := StrLen(Var)
    pNum := ( lVar And [var].GetCapacity(1)="" And (Var = Abs(Round(Var))) ),    nVar := VarSetCapacity(Var)

    If ( OK1="" Or OK2="" Or NaN=1 Or lVar<1 Or (pNum=1 And nBytes<1) Or (pNum=0 And nVar<nBytes))
        Return ( 0, ErrorLevel := OK1="" ? "Algorithm not known.`n=> MD2 MD4 MD5 SHA1 SHA256 SHA384 SHA512`nDefault: SHA256"
        :  OK2="" ? "Codepage incorrect.`n=> CP0 UTF-16 UTF-8`nDefault: UTF-8"
        :  NaN=1  ? "nBytes in incorrect format"
        :  lVar<1 ? "Var is empty. Nothing to hash."
        : (pNum=1 And nBytes<1) ? "Pointer requires nBytes greater than 0."
        : (pNum=0 And nVar<nBytes) ? "Var's capacity is lesser than nBytes." : "" )

    hBcrypt := DllCall("Kernel32.dll\LoadLibrary", "Str","Bcrypt.dll", "Ptr")
    DllCall("Bcrypt.dll\BCryptOpenAlgorithmProvider", "PtrP",hAlg:=0, "WStr",HA.ALG, "Ptr",0, "Int",0, "UInt")
    DllCall("Bcrypt.dll\BCryptCreateHash", "Ptr",hAlg, "PtrP",hHash:=0, "Ptr", 0, "Int", 0, "Ptr",0, "Int",0, "Int", 0)

    nLen := 0, FileLen := File := rBytes := sStr := nErr := ""
    If ( nBytes!="" And (pBuf:=pNum ? Var+0 : &Var) )
    {
        If ( nBytes<=0  )
            nBytes := StrPut(Var, HA.ENC)
            , VarSetCapacity(sStr, nBytes * HA.X)
            , nBytes := ( StrPut(Var, pBuf := &sStr, nBytes, HA.ENC) - 1 ) * HA.X
        nErr := DllCall("Bcrypt.dll\BCryptHashData", "Ptr",hHash, "Ptr",pBuf, "Int",nBytes, "Int", 0, "UInt")
    } Else {
        File := FileOpen(Var, "r -rwd")
        try {
            If  ( (FileLen := File.Length) And VarSetCapacity(Bin, 65536) )
                Loop
                    If ( rBytes := File.RawRead(&Bin, 65536) )
                        nErr   := DllCall("Bcrypt.dll\BCryptHashData", "Ptr",hHash, "Ptr",&Bin, "Int",rBytes, "Int", 0, "Uint")
                    Until ( nErr Or File.AtEOF Or !rBytes )
            File := ( FileLen="" ? 0 : File.Close() )
        } finally {
            File.Close()
        }
    }

    DllCall("Bcrypt.dll\BCryptGetProperty", "Ptr",hAlg, "WStr", "HashDigestLength", "UIntP",nLen, "Int",4, "PtrP",0, "Int",0)
    VarSetCapacity(Hash, nLen)
    DllCall("Bcrypt.dll\BCryptFinishHash", "Ptr",hHash, "Ptr",&Hash, "Int",nLen, "Int", 0)
    DllCall("Bcrypt.dll\BCryptDestroyHash", "Ptr",hHash)
    DllCall("Bcrypt.dll\BCryptCloseAlgorithmProvider", "Ptr",hAlg, "Int",0)
    DllCall("Kernel32.dll\FreeLibrary", "Ptr",hBCrypt)

    If ( nErr=0 )
        VarSetCapacity(sStr, 260, 0),  nFlags := HA.BAS ? 0x40000001 : 0x4000000C
        , DllCall("Crypt32\CryptBinaryToString", "Ptr",&Hash, "Int",nLen, "Int",nFlags, "Str",sStr, "UIntP",130)
        , sStr := ( nFlags=0x4000000C And HA.UPP ? Format("{:U}", sStr) : sStr )

    Return ( sStr, ErrorLevel := File=0    ? ( FileExist(Var) ? "Open file error. File in use." : "File does not exist." )
        : FileLen=0 ? "Zero byte file. Nothing to hash."
        : (FileLen & rBytes=0) ? "Read file error."
        : nErr ? Format("Bcrypt error. 0x{:08X}", nErr)
        : nErr="" ? "Unknown error." : "" )
}


inStrAll(haystack, needle)
{
    occurrences := []
    startIndex := 1

    ; Loop until no more occurrences are found
    while (startIndex := InStr(haystack, needle, false, startIndex + StrLen(needle))) {
        occurrences.Push(startIndex)
    }

    return occurrences
}

/**
* @param int min
* @param ?int max
* @return void
*/
sleep(min, max := "")
{
    if (!max)  {
        Sleep, % min
        return
    }

    Random, delay, %min%, %max%
    sleep, %delay%
}

/**
* @param Object object
* @param int x
* @param int y
* @param int z
* @return void
*/
deleteCoordinate(ByRef object, x, y, z)
{
    object[z][x].Delete(y)
    if (!object[z][x].Count()) {
        object[z].Delete(x)
    }

    if (!object[z].Count()) {
        object.Delete(z)
    }
}

/**
* @param string className
* @param mixed class
* @return mixed
* @throws
*/
validateClass(className, class, expectedClass)
{
    classLoaded(className, class)
    _Validation.instanceOf(className, class, expectedClass)

    return class
}

/**
* @param string filePath
* @return int
*/
deleteFileIfExists(filePath)
{
    if (FileExist(filePath)) {
        FileDelete, % filePath

        return ErrorLevel
    }

    return false
}
