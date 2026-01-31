#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Objects\_DefaultValue.ahk

class _DefaultString extends _DefaultValue
{
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @param mixed default
    * @param ?string identifier
    */
    __New(default, identifier := "")
    {
        base.__New(default, "", "", identifier)
    }
}