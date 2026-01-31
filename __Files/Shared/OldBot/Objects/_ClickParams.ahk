

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

/**
* @property string button
* @property int offsetX
* @property int offsetY
*/
class _ClickParams extends _BaseClass
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(button, offsetX, offsetY := "") {
        _Validation.isOneOf("button", button, "Left", "Right")
        _Validation.number("offsetX", offsetX)

        if (offsetX && !offsetY) {
            offsetY := offsetX
        }

        _Validation.number("offsetY", offsetY)

        this.button := button
        this.offsetX := offsetX
        this.offsetY := offsetY
    }
}
