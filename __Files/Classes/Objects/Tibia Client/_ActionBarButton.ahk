

/**
* @property number
* @propety button
* @property string value
* @property string hotkey
* @property string extra
*/
class _ActionBarButton extends _BaseClass
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(number, button, value, hotkey, extra := "")
    {
        this.number := number
        this.button := button
        this.value := value
        this.hotkey := hotkey
        this.extra := extra
    }

}