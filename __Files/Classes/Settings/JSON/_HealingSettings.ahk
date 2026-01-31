#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\JSON\_AbstractJsonSettings.ahk

class _HealingSettings extends _AbstractJsonSettings
{
    static INSTANCE
    static IDENTIFIER := "healing"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }


    /**
    * @param string key
    * @param mixed value
    */
    set(key, value)
    {
        base.set(key, value)
    }

    __New()
    {
        if (_HealingSettings.INSTANCE) {
            return _HealingSettings.INSTANCE
        }

        base.__New()

        _HealingSettings.INSTANCE := this
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _HealingSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes["life.highestComment"] := new _DefaultString("").setSanitizer(this, "commentSanitizer")
        this.attributes["life.highComment"] := new _DefaultString("").setSanitizer(this, "commentSanitizer")
        this.attributes["life.midComment"] := new _DefaultString("").setSanitizer(this, "commentSanitizer")
        this.attributes["life.lowComment"] := new _DefaultString("").setSanitizer(this, "commentSanitizer")

        this.attributes["life.highestLife"] := this.getDefaultPercentageValue(95, "highestLife")
        this.attributes["life.highLife"] := this.getDefaultPercentageValue(75, "highLife")
        this.attributes["life.midLife"] := this.getDefaultPercentageValue(50, "midLife")
        this.attributes["life.lowLife"] := this.getDefaultPercentageValue(35, "lowLife")

        this.attributes["life.highestMana"] := this.getDefaultPercentageValue(15, "highestMana")
        this.attributes["life.highMana"] := this.getDefaultPercentageValue(15, "highMana")
        this.attributes["life.midMana"] := this.getDefaultPercentageValue(15, "midMana")
        this.attributes["life.lowMana"] := this.getDefaultPercentageValue(15, "lowMana")

        this.attributes["life.highestHotkey"] := new _DefaultString("")
        this.attributes["life.highHotkey"] := new _DefaultString("")
        this.attributes["life.midHotkey"] := new _DefaultString("")
        this.attributes["life.lowHotkey"] := new _DefaultString("")

        this.attributes["life.midPotionHotkey"] := new _DefaultString("")
        this.attributes["life.lowPotionHotkey"] := new _DefaultString("")

        this.attributes["life.midItemName"] := new _DefaultString("")
        this.attributes["life.lowItemName"] := new _DefaultString("")
        this.attributes["mana.manaItemName"] := new _DefaultString("mana potion")


        this.attributes[i := "mana.manaMin"] := this.getDefaultPercentageValue(40, i)
        this.attributes[i := "mana.manaMax"] := this.getDefaultPercentageValue(60, i)

        this.attributes["mana.manaHotkey"] := new _DefaultString("")
        this.attributes["mana.manaTrainHotkey"] := new _DefaultString("")
    }

    /**
    * @param ?string identifier
    * @return _DefaultValue
    */
    getDefaultPercentageValue(default := "", identifier := "")
    {
        return new _DefaultValue(default, 5, 99, identifier)
    }

    commentSanitizer(comment)
    {
        replaces := {}
        replaces.Push("+")
        replaces.Push("-")
        replaces.Push("/")
        replaces.Push("\")
        replaces.Push("*")
        replaces.Push("=")

        for key, value in replaces
            comment := StrReplace(comment, value, "&")

        return comment
    }
}