
class _Loggable extends _BaseClass
{
    /**
    * @param BoundFunc logger
    */
    setLogger(logger)
    {
        _Validation.function("logger", logger)
        this.logger := logger

        return this
    }

    /**
    * @param string msg
    * @return void
    */
    log(msg)
    {
        this.logger.Call(msg)
    }

    /**
    * @param string msg
    * @param string identifier
    * @return void
    */
    logException(msg, identifier)
    {
        this.ExceptionLogger.Call(msg, identifier)
    }

    /**
    * @return ?BoundFunc
    */
    getLogger()
    {
        return this.logger
    }

    /**
    * @param BoundFunc logger
    */
    setExceptionLogger(logger)
    {
        _Validation.function("logger", logger)
        this.ExceptionLogger := logger

        return this
    }

    /**
    * @return ?BoundFunc
    */
    getExceptionLogger()
    {
        return this.ExceptionLogger
    }
}