
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Action Script\Actions\_AbstractActionScript.ahk

class _ImageSearchWait extends _AbstractActionScript
{
    static IDENTIFIER := "imagesearchwait"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return int
    */
    runAction()
    {
        functionValues := this.values
        this.info(ActionScript.string_log)

        params := {}
            , params.imageName := functionValues.1
            , params.timeout := this.getNumberParam(functionValues.2)
            , params.variation := this.getNumberParam(functionValues.3)t
            , params.searchArea := functionValues.4
            , params.x1 := this.getNumberParam(functionValues.5)
            , params.y1 := this.getNumberParam(functionValues.6)
            , params.x2 := this.getNumberParam(functionValues.7)
            , params.y2 := this.getNumberParam(functionValues.8)

            , params := this.checkParamsVariables(params)

            , params.variation := (params.variation < 1) ? _ScriptImages.DEFAULT_VARIATION : params.variation
            , params.timeout := (params.timeout < 1) ? 1 : params.timeout
            , params.searchArea := (params.searchArea = "") ? _WindowArea.NAME : params.searchArea

        timer := new _Timer()

        try {
            _search := this.search(params)
        } catch e {
            if (e.What = "Timeout") {
                this.info(e.Message)
                return _search.getResultsCount()
            }

            _Logger.exception(e, A_ThisFunc, params.imageName)
            return -1
        }

        global lastImageSearchX := _search.getResults()[1].getX()
        global lastImageSearchY := _search.getResults()[1].getY()

        return _search.getResultsCount()
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
                .setAllResults(true)
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