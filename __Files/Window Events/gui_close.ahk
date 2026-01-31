GuiClose(GuiHwnd)
{
    instance := _GUI.INSTANCES[GuiHwnd]
    if (instance) {
        for, _, timer in instance.timers
        {
            SetTimer, % timer, Off
            SetTimer, % timer, Delete
        }

        instance.close()
    }
}
