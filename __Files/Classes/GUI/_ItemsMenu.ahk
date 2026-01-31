
class _ItemsMenu extends _BaseClass
{
    __New(itemsList, callback, menuName)
    {
        this.list := {}

        this.itemsList := itemsList
        this.callback := callback

        this.menu := new _GuiMenu(menuName)
    }

    getFirst()
    {
        return _Arr.first(this.list)
    }

    addText(title)
    {
        this.addToList(this.text(title))

        return this
    }

    defaultNoneText()
    {
        return txt("Nenhum", "None")
    }

    default()
    {
        return this.addText(this.defaultNoneText())
    }

    addToList(item)
    {
        this.list.Push(item)

        return this
    }

    add(item)
    {
        _Validation.instanceOf("item", item, _GuiMenuItem)

        this.menu.add(item)

        return this
    }

    show()
    {
        this.menu.show()

        return this
    }   

    create()
    {
        for _, item in this.itemsList {
            this.item(item)
        }

        for _, menuItem in this.list {
            this.add(menuItem)
        }

        return this
    }

    text(title)
    {
        menu := new _GuiMenuItem()
            .setTitle(title)
            .setCallback(this.callback)

        this.addToList(menu)

        return this
    }

    item(itemName)
    {
        icon := _BitmapIcon.FROM_ITEM(itemName)
        menu := new _GuiMenuItem()
            .setTitle(itemName)
            .setCallback(this.callback)

        if (icon) {
            menu.setIcon(icon)
        }

        this.addToList(menu)

        return this
    }
}