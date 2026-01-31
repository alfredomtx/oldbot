class _AbstractSioControl extends _BaseClass
{
    __Init() {
        classLoaded("_SioGUI", _SioGUI)
    }

    /**
    * @param string className
    * @return _AbstractStatefulControl
    */
    __New(className) {
        try {
            guiInstance := new _SioGUI()
            _Validation.function("guiInstance.getPlayerName", guiInstance.getPlayerName)

            instance := new %className%()

            _Validation.instanceOf(className ".instance", instance, _AbstractStatefulControl)
            _Validation.equals(className, instance.__Class)

            getPlayerNameFunction := guiInstance.getPlayerName.bind(guiInstance)

            instance.state(_SioSettings)
            instance.prefix("sio")
            instance.nested(getPlayerNameFunction)
            instance.afterSubmit(guiInstance.updateSioRow.bind(guiInstance, getPlayerNameFunction))

            instance.disabled(true)
        } catch e {
            _Logger.msgboxException(16, e, A_ThisFunc, className)
        }

        return instance
    }

    /**
    * @abstract
    * @return string
    */
    defaultOptions() {
    }
}
