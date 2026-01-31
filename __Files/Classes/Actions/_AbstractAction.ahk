#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

class _AbstractAction extends _BaseClass
{
    __Init() {
        classLoaded("_Logger", _Logger)
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
    * @abstract
    * @throws
    */
    validations()
    {
    }

    /**
    * @abstract
    * @return bool
    */
    isIncompatible()
    {
    }
}