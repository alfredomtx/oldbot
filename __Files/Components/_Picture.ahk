class _Picture extends _AbstractControl
{
    static CONTROL := "Picture"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        base.__New(_Picture.CONTROL)
    }

    image(image)
    {
        _Validation.fileExists("image", image)

        this.title(image)

        return this
    }

    bitmap(bitmap)
    {
        _Validation.instanceOf("bitmap", bitmap, _BitmapImage)

        this.set("HBITMAP:*" bitmap.getHBitmap())

        GuiControl, % this.guiPrefix() "MoveDraw", % this.getControlID(), % "w" bitmap.getW() " h" bitmap.getH()

        bitmap.dispose()
    }

    onEvent()
    {
    }
}
