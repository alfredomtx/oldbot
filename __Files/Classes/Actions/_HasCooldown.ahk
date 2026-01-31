class _HasCooldown extends _AbstractAction
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return bool
    * @throws
    */
    __New(group, spell := "")
    {
        if (!clientHasFeature("cooldownBar")) {
            return false
        }

        this.group := group
        this.spell := spell

        try {
            this.validations()

            /**
            if is an attack spell with the default 2 secs cooldown(no individual higher cooldown)
            example: exori frigo, avalanche rune
            */
            if (this.spell = "Default" && this.group = "Attack") {
                _search := this.searchCooldownImage(this.group)

                return _search.notFound()
            }

            if (this.spell) {
                /**
                search for the spell icon first
                */
                _search := this.searchCooldownImage(spell)
                if (_search.found()) {
                    return true
                }
            }

            /**
            if didnt find the spell icon, search for the group cooldown
            */
            _search := this.searchCooldownImage(this.group)

            return _search.notFound()
        } catch e {
            this.handleException(e, this)
            throw e
        }
    }

    /**
    * @param string image
    * @return bool
    */
    searchCooldownImage(image) {
        static searchCache
        if (!searchCache) {
            searchCache := new _UniqueImageSearch()
                .setFolder(ImagesConfig.cooldownBarFolder)
                .setVariation(50)
                .setArea(new _CooldownBarArea())
        }

        try {
            _search := searchCache
                .setFile(image)
                .search()
        } catch e {
            writeCavebotLog("ERROR", (functionName ": ") e.Message " | " e.What)
        }

        return _search
    }

    /**
    * @abstract
    * @throws
    */
    validations()
    {
        static validated

        _Validation.empty("this.group", this.group)

        if (validated) {
            return
        }

        validated := true
    }
}