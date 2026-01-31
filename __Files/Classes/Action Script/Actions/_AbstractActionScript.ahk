#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

classLoaded("_Logger", _Logger)

/**
* @property array<mixed> params
* @property array<mixed> values
* @property BoundFunc validation
*/
class _AbstractActionScript extends _ActionScript
{
    __New()
    {
        this.params := {}
        this.values := {}
    }

    /**
    * @return mixed
    */
    run()
    {
        _Logger.SET_CALLBACK(this.logger.bind(this))
        this.setValidation(this.validate.bind(this))

        try {
            if (this.isIncompatible()) {
                throw Exception(txt("Action """ this.IDENTIFIER """ não é compatível com o cliente atual.", "Action """ this.IDENTIFIER """ is not compatible with the current client."), "UncompatibleAction")
            }

            this.params := this.checkParamsVariables(this.values)
            this.identifyParams()
            this.runValidation()

            return this.runAction()
        } catch e {
            this.handleException(e, this)
            throw e
        }
    }

    /**
    * @return void
    */
    identifyParams()
    {
    }

    /**
    * @return void
    * @throws
    */
    validate()
    {
    }

    /**
    * @abstract
    * @return mixed
    * @throws
    */
    runAction()
    {
        abstractMethod()
    }

    /**
    * @param Exception e
    * @param object class
    */
    handleException(e, class)
    {
        _Logger.exception(e, class.__Class)
    }

    /**
    * @throws
    */
    runValidation()
    {
        if (!this._validation) {
            return
        }

        _Validation.function("this._validation", this._validation)

        fn := this._validation
        %fn%()
    }

    ;#Region Setters
    /**
    * @param array<mixed> values
    * @return this
    */
    setValues(values)
    {
        this.values := values
        return this
    }

    /**
    * @param BoundFunc callback
    * @return this
    */
    setValidation(callback)
    {
        this._validation := callback
        return this
    }
    ;#Endregion

    ;#Region Logging
    logger(identifier, msg)
    {
        writeCavebotLog(identifier, msg)
    }

    /**
    * @param string message
    * @param ?string origin
    * @return void
    */
    info(message, origin := "")
    {
        _Logger.log("Action", message, this.IDENTIFIER, origin ? origin : this.__Class)
    }

    /**
    * @param string message
    * @param ?string origin
    * @return void
    */
    error(message, origin := "")
    {
        _Logger.error(message, this.IDENTIFIER, origin ? origin : this.__Class)
    }
    ;#Endregion

    /**
    * @param string message
    * @param ?string origin
    * @return void
    */
    warning(message, origin := "")
    {
        _Logger.warning(message, this.IDENTIFIER, origin ? origin : this.__Class)
    }

    ;#Region Predicates
    /**
    * @abtract
    * @return bool
    */
    isIncompatible()
    {
        return false
    }
    ;#Endregion
}