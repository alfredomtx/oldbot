
Class _TestGameAreasMenu
{
    __New()
    {
    }

    handle(area)
    {
        try {
            instance := new %area%()
            instance.test()
        } catch e {
            MsgBox, 16, Error, % e.Message
        }
    }

    classes()
    {
        static classes
        if (classes) {
            return classes
        }

        group := {}
        group[_StatusBarArea.__Class] := []
        group[_StatusBarArea.__Class].Push(_TorchArea.__Class)
        group[_StatusBarArea.__Class].Push(_LeftHandArea.__Class)
        group[_StatusBarArea.__Class].Push(_AmuletArea.__Class)
        group[_StatusBarArea.__Class].Push(_RingArea.__Class)
        group[_StatusBarArea.__Class].Push(_BootsArea.__Class)

        group[_BattleListArea.__Class] := []
        group[_BattleListArea.__Class].Push(_BattleListPixelArea.__Class)

        group[_LifeBarArea.__Class] := []
        group[_LifeBarArea.__Class].Push(_ManaBarArea.__Class)


        group[_MainBackpackArea.__Class] := []
        group[_MainBackpackArea.__Class].Push(_FirstSlotArea.__Class)

        group[_MinimapArea.__Class] := []

        classes := group

        return classes
    }

    createMenu()
    {
        if (A_IsCompiled) {
            return
        }

        fn := this.testAll.bind(this)
        Menu, TestMenu, Add, % "Test All", % fn

        fn := this.handle.bind(this)

        for mainClass, classes in this.classes() {
            Menu, TestMenu, Add
            Menu, TestMenu, Add, % mainClass, % fn

            for _, class in classes {
                Menu, TestMenu, Add, % class, % fn
            }
        }

        Menu, MyMenuBar, Add, % "&T", :TestMenu
    }

    testAll()
    {
        for mainClass, classes in this.classes() {
            this.handle(mainClass)

            for _, class in classes {
                this.handle(class)
            }
        }
    }
}
