class _BaseClass
{

    ; __Get(key) {
    ;     if (key = "base") {
    ;         return
    ;     }
    ; throw Exception("""" key """ class attribute does not exist.")
    ; }

    __Call(method:="") {
        ;if !(fn := Func("Obj" method)) || !fn.IsBuiltIn  ; Incorrect result for AddRef/Release/ect.
        if method not in Insert,Remove,Delete,MinIndex,MaxIndex,SetCapacity
                ,GetCapacity,GetAddress,_NewEnum,HasKey,Clone
            throw Exception("Non-existent method: """ method """", -2, method)
    }

    ; Must not define any other methods in this class or any super-class.
}