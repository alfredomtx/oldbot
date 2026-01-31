GuiEscape(GuiHwnd)
{
    instance := _GUI.INSTANCES[GuiHwnd]
    if (instance._preventEscape) {
        return
    }

    GuiClose(GuiHwnd)
}
