

class _GuiMenuItem extends _BaseClass
{
    __New(menu)
    {
        _Validation.instanceOf("menu", menu, _GuiMenu)

        this.menu := menu
    }

    getTitle()
    {
        return this.title
    }

    getCallback()
    {
        return this.callback
    }

    getIcon()
    {
        return this.icon
    }

    setCallback(callback)
    {
        _Validation.function("callback", callback)
        this.callback := callback

        return this
    }

    setTitle(title)
    {
        this.title := title

        return this
    }

    setIcon(icon)
    {
        _Validation.instanceOf("icon", icon, _Icon)
        this.icon := icon

        return this
    }
}