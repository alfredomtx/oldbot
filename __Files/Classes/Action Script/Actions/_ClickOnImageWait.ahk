
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Action Script\Actions\_AbstractActionScript.ahk

class _ClickOnImageWait extends _AbstractActionScript
{
    static IDENTIFIER := "clickonimagewait"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return bool
    */
    runAction()
    {
        functionValues := this.values
        this.info(ActionScript.string_log)

        params := {}
            , params.imageName := functionValues.1
            , params.click := functionValues.2
            , params.timeout := this.getNumberParam(functionValues.3)
            , params.repeat := this.getNumberParam(functionValues.4)
            , params.delay := this.getNumberParam(functionValues.5)
            , params.variation := this.getNumberParam(functionValues.6)
            , params.holdCtrl := functionValues.7
            , params.holdShift := functionValues.8
            , params.offsetX := this.getNumberParam(functionValues.9)
            , params.offsetY := this.getNumberParam(functionValues.10)

            , params := this.checkParamsVariables(params)

            , params.timeout := (params.timeout < 1) ? 1 : params.timeout
            , params.delay := (params.delay < 1) ? 500 : params.delay
            , params.repeat := (params.repeat < 1) ? 1 : params.repeat
            , params.variation := (params.variation < 0) ? _ScriptImages.DEFAULT_VARIATION : params.variation
            , params.offsetX := _ActionScriptValidation.isNumber(params.offsetX)
            , params.offsetY := _ActionScriptValidation.isNumber(params.offsetY)


        this.info(params.imageName " | click: " params.click ", timeout: " params.timeout ", repeat: " params.repeat ", delay: " params.delay ", variation: " params.variation " | offsetX: " params.offsetX ", offsetY: " params.offsetY)

        Loop, % params.repeat {
            try {
                _search := this.search(params)
            } catch e {
                if (e.What = "Timeout") {
                    this.info(e.Message)
                    return false
                }

                _Logger.exception(e, A_ThisFunc, params.imageName)
                return -1
            }

            if (_search.notFound()) {
                this.info("Image """ params.imageName """ not found on screen")
                return false
            }

            if (stringToBool(params.holdCtrl)) {
                MouseClickModifier("Ctrl", params.click, _search.getX() + params.offsetX, _search.getY() + params.offsetY)
            } else if (stringToBool(params.holdShift)) {
                MouseClickModifier("Shift", params.click, _search.getX() + params.offsetX, _search.getY() + params.offsetY)
            } else {
                MouseClick(params.click, _search.getX() + params.offsetX, _search.getY() + params.offsetY, debug := false)
            }

            Sleep, 100
            if (A_Index > 0) {
                delay := params.delay - 100
                Sleep, % (delay > 1) ? delay : 0
            }
        }
    }


    /**
    * @param object params
    * @return _Base64ImageSearch
    */
    search(params)
    {
        static searchCache

        if (!searchCache) {
            searchCache := new _Base64ImageSearch()
                .setImage(new _ScriptImage(params.imageName))
                .setVariation(params.variation)
                .setTransColor("0")
        }

        _search := searchCache

        if (_ActionScriptValidation.validateUserDefinedSearchArea(this.IDENTIFIER, params)) {
            _search.setCoordinates(_Coordinates.FROM_ARRAY(params))
            this.info("image: " params.imageName " | variation: " params.variation " | x1: " params.x1 ", y1: " params.y1 ", x2: " params.x2 ", y2: " params.y2)
        } else {
            this.info("image: " params.imageName " | search area: " params.searchArea " | variation: " params.variation)
            _search.setArea(new _ClientAreaFactory(params.searchArea))
        }

        return _search.searchWithTimeout(params.timeout * 1000, 100, this.loggerCallback.bind(this))
    }

    /**
    * @param string message
    * @return void
    */
    loggerCallback(message)
    {
        this.info(message)
    }
}