
class _GuiMenu extends _BaseClass
{
    __New(name := "")
    {
        this.name := name ? name : _Str.random(16)
    }

    add(item)
    {
        _Validation.instanceOf("item", item, _GuiMenuItem)

        try {
            fn := item.getCallback()
            Menu, % this.name, Add, % item.getTitle(), % fn
        } catch e {
            throw Exception("Failed to add item to menu.`n- menu: " this.name "`n- item: " item.getTitle(), e)
        }

        this.setIcon(item)

        return this
    }

    setIcon(item)
    {
        if (!item.getIcon()) {
            return
        }

        icon := item.getIcon()
        try { 
            if (instanceOf(icon, _BitmapIcon)) {
                Menu, % this.name, Icon, % item.getTitle(), % "HBITMAP:" icon.getBitmap().getHBitmap(),, 32
            } else {
                Menu, % this.name, Icon, % item.getTitle(), % icon.dllName, % icon.number,16
            }
        } catch e {
            throw Exception("Failed to set icon to menu item.`n- menu: " this.name "`n- item: " item.getTitle() "`n- icon: " serialize(icon), e)
        }
    }

    show()
    {
        Menu, % this.name, Show

        return this
    }
}