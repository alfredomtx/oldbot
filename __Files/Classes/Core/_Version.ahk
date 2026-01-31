
class _Version extends _BaseClass
{
    static CURRENT := "18.9"
    static UPLOAD := "18.9"

    static BETA_ENABLED := 0
    static BETA := "18.9 BETA"


    static INI_SECTION := "version"
    static STABLE := "stable"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    getPreferred(ignoreCache := false)
    {
        return _Version.CURRENT

        preferredVersion := this.getPreferredVersion()
        availableVersions := this.getAvailableVersions(ignoreCache)
        stableVersion := this.getStableVersion(preferredVersion)

        if (new _OldBotIniSettings().get("receiveBetaVersions") && _Version.BETA_ENABLED) {
            return _Arr.last(availableVersions)
        } else {
            if (preferredVersion == _Version.STABLE) {
                return stableVersion
            }

            if (InStr(stableVersion, preferredVersion)) {
                return stableVersion
            }
        }

        ; if it is not a version in the expected format, set the stable version
        if (!RegExMatch(preferredVersion, "^\d+\.\d+$")) {
            _OldBotIniSettings.write("preferredVersion", stableVersion)

            return stableVersion
        }

        for _, version in availableVersions {
            if (version == preferredVersion) {
                return string(preferredVersion)
            }
        }

        throw Exception(txt("Versão preferida não existe: " preferredVersion "`nPor favor contate o suporte.", "Preferred version does not exist: " preferredVersion "`nPlease contact support.") this.getVersionInfo())
    }

    /**
    * @return string
    */
    getPreferredVersion()
    {
        preferredVersion := new _OldBotIniSettings().get("preferredVersion")
        if (InStr(preferredVersion, this.STABLE)) {
            preferredVersion := this.STABLE
        }

        if (empty(preferredVersion)) {
            preferredVersion := this.STABLE
            _OldBotIniSettings.write("preferredVersion", preferredVersion)
        }

        return string(preferredVersion)
    }

    /**
    * @param string preferredVersion
    * @param ?bool ignoreCache
    * @return ?string
    * @throws
    */
    getStableVersion(preferredVersion, ignoreCache := false)
    {
        static triedStableVersion := 0
        availableVersions := this.getAvailableVersions(ignoreCache)

        stableVersion := ""
        for _, availableVersion in availableVersions {
            if (string(preferredVersion) == string(availableVersion)) {
                return availableVersion
            }

            if (InStr(availableVersion, _Version.STABLE)) {
                stableVersion := availableVersion
            }
        }


        if (!stableVersion) {
            this.deleteCache()

            if (triedStableVersion == 0) {
                triedStableVersion++
                stableVersion := this.getStableVersion(preferredVersion, true)
            }

            if (!stableVersion) {
                throw Exception(txt("Falha ao definir versão estável, tente novamente e se o problema persistir por favor contate o suporte.", "Failed to set stable version, try again if the problem persists please contact support.") "`n" this.getVersionInfo())
            }
        }

        return string(stableVersion)
    }

    getVersionInfo()
    {
        return "`n`nVersion: " _Version.CURRENT "`nPreferred: " new _OldBotIniSettings().get("preferredVersion") "`nBETA: " (this.BETA_ENABLED ? this.BETA : "No")
    }

    /**
    * @return array<string>
    * @throws
    */
    getAvailableVersions(ignoreCache := false)
    {
        static versions
        local version
        if (!ignoreCache && versions) {
            return versions
        }

        if (!ignoreCache) {
            versions := this.getAvailableFromCache()
            if (versions) {
                return versions
            }
        }

        versions := new _GetAvailableVersionsRequest(new _OldBotIniSettings().get("receiveBetaVersions")).execute()

        _Logger.info("Versions", serialize(versions))

        _Validation.stringOrNumber("_Arr.first(versions)", _Arr.first(versions))

        filteredVersions := {}
        for _, version in versions {
            if (InStr(version, "stable")) {
                filteredVersions.Push(version)
                continue
            }

            ; Ravendawn bot versions
            if (version == "1.0" || version == "BETA") {
                continue
            }

            filteredVersions.Push(string(version))
        }

        versions := filteredVersions

        _OldBotIniSettings.write("lastUpdate", A_TickCount, this.INI_SECTION)
        _OldBotIniSettings.write("cache", _Arr.concat(versions, "|"), this.INI_SECTION)

        return versions
    }

    /**
    * @return ?array<string>
    */
    getAvailableFromCache()
    {
        lastListUpdate := _OldBotIniSettings.read("lastUpdate", this.INI_SECTION)
        cache := _OldBotIniSettings.read("cache", this.INI_SECTION)
        if (empty(cache)) {
            return
        }

        if (!empty(lastListUpdate)) {
            elapsedLastUpdate := (A_TickCount - lastListUpdate) / 1000
            minutes := elapsedLastUpdate / 60
            hours := minutes / 60
        }

        if (!empty(hours) && hours < 8) {
            availableVersions := _Arr.filter(StrSplit(cache, "|"))
            return availableVersions
        }
    }

    deleteCache()
    {
        _Ini.delete("cache", this.INI_SECTION)
    }

    getDisplayVersion()
    {
        version := this.BETA_ENABLED ? this.BETA : this.CURRENT
        return "v" version
    }
}