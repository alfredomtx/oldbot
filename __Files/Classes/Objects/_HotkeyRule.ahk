#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Objects\_ControlRule.ahk

class _HotkeyRule extends _ControlRule
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    evaluate(value)
    {
        _Validation.hotkey(value)
    }
}