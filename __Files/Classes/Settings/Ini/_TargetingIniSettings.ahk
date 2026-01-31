#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\Ini\_AbstractIniSettings.ahk

identifier := _TargetingIniSettings.getIdentifier()
%identifier%Ini := {}

class _TargetingIniSettings extends _AbstractIniSettings
{
    static INSTANCE
    static IDENTIFIER := "targeting"

    static ATTACK_METHOD_CLICK := "Click on Battle List"
    static ATTACK_METHOD_HOTKEY := "Press hotkey"


    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        if (_TargetingIniSettings.INSTANCE) {
            return _TargetingIniSettings.INSTANCE
        }

        base.__New()

        _TargetingIniSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _TargetingIniSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes["attackMethod"] := new _DefaultEnum(this.ATTACK_METHOD_CLICK, [this.ATTACK_METHOD_CLICK, this.ATTACK_METHOD_HOTKEY])
            .setIdentifier("attackMethod")

        this.attributes["antiKsAttacksRelease"] := new _DefaultEnum("2 attacks(default)", ["1 attack(faster)", "2 attacks(default)", "3 attacks", "4 attacks", "5 attacks", "6 attacks"])
            .setIdentifier("antiKsAttacksRelease")
        this.attributes[v := "randomizeSameCreatureAttack"] := new _DefaultBoolean(false, v)
        this.attributes[v := "targetingIntervalTime"] := new _DefaultValue(500, 200, 2000, v).setType(lang("ms", false))
        this.attributes[v := "attackHotkey"] := new _DefaultString("Space", v)
    }
}