
Class _ClientFinderMenu
{
    handle(menu)
    {
        setSystemCursor("IDC_WAIT")

        fn := this[menu].bind(this)

        try {
            fn.Call()
        } catch e {
            MsgBox, 16, Error, % e.Message
        }

        restoreCursor()
    }

    minimapCenter()
    {
            new _ClientFinder().findMinimapCenter()
    }

    zoomMinus()
    {
            new _ClientFinder().findMinimapZoomMinus()
    }

    backpack()
    {
            new _ClientFinder().findBackpack()
    }

    statusBar()
    {
            new _ClientFinder().findStatusBar()
    }

    battleList()
    {
            new _ClientFinder().findBattleListTitle()
            new _ClientFinder().findBattleListEmpty()
    }

    lifeBar()
    {
            new _ClientFinder().findLifeBar()
    }

    menuOpen()
    {
            new _ClientFinder().findOpen()
    }

    battleListButtons()
    {
            new _ClientFinder().findBattleListButton()
    }

    list()
    {
        static list
        if (list) {
            return list
        }

        list := []

        list.Push("backpack")
        list.Push("battleList")
        list.Push("battleListButtons")
        list.Push("lifeBar")
        list.Push("menuOpen")
        list.Push("minimapCenter")
        list.Push("statusBar")
        list.Push("zoomMinus")

        return list
    }

    createMenu()
    {
        if (A_IsCompiled) {
            return
        }

        fn := this.testAll.bind(this)
        Menu, ClientFinderMenu, Add, % "Test All", % fn

        fn := this.handle.bind(this)
        for _, item in this.list() {
            Menu, ClientFinderMenu, Add, % item, % fn
        }

        Menu, MyMenuBar, Add, % "&Z", :ClientFinderMenu
    }

    testAll()
    {
        for _, item in this.list() {
            this.handle(item)
        }
    }
}
