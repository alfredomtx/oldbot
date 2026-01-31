#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\Settings\JSON\_AbstractJsonSettings.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

class _MarketSettings extends _AbstractJsonSettings
{
    static INSTANCE
    static IDENTIFIER := "market"

    static DEFAULT_PROFILE := "default"

    static PROFILE_PATH := _Folders.MARKET_ROOT "\profiles"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        if (_MarketSettings.INSTANCE) {
            return _MarketSettings.INSTANCE
        }

        base.__New()

        if (!FileExist(this.PROFILE_PATH)) {
            FileCreateDir, % this.PROFILE_PATH
        }

        _MarketSettings.INSTANCE := this
    }

    ensureFileExist()
    {
        if (!FileExist(this.profilePath())) {
            FileAppend, % "", % this.profilePath()
        }
    }

    profiles(cached := true)
    {
        static profiles
        if (profiles && cached) {
            return profiles
        }

        this.ensureFileExist()

        dir := this.PROFILE_PATH
        profiles := {}
        Loop, % dir "\*.ini"
        {
            profiles[StrReplace(A_LoopFileName, ".ini", "")] := true
        }

        return profiles
    }

    /**
    * @return string
    */
    profilePath()
    {
        return this.PROFILE_PATH . "\" . this.profile() . ".ini"
    }

    /**
    * @return string
    */
    profile()
    {
        profile := this.get("profile")
        if (empty(profile)) {
            this.set("profile", this.DEFAULT_PROFILE)

            return this.DEFAULT_PROFILE
        }

        return profile


        file := this.PROFILE_PATH . "\" . profile . ".ini"

        if (!FileExist(file)) {
            return this.DEFAULT_PROFILE
        }

        return this.get("profile")
    }

    /**
    * @return string
    */
    getIdentifier()
    {
        return _MarketSettings.IDENTIFIER
    }

    /**
    * @return void
    */
    setAttributes()
    {
        this.attributes := {}

        this.attributes[this.ENABLED_KEY] := new _DefaultBoolean(false, _Market.IDENTIFIER)
        this.attributes["profile"] := new _DefaultString(this.DEFAULT_PROFILE)
    }
}