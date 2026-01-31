
Class _ItemRefillGUI  {
    __New()
    {
        this.strings := {}
        this.strings.Push("ring")
        this.strings.Push("amulet")
        this.strings.Push("boots")
        this.strings.Push("quiver")
        this.strings.Push("distanceWeapon")

    }

    PostCreate_RefillGUI() {
    }


    submitItemRefillControl(control, value, funcOrigin := "") {
        item := this.itemString(control)

        ; msgbox, % control ", " value  ", " item

        control := StrReplace(control, "Refill", "")

        if (control != "quiver")
            control := StrReplace(control, item, "")

        /**
        first letter to lowercase
        */
        firstLetter := SubStr(control, 1, 1)
        StringTrimLeft, control, control, 1
        StringLower, firstLetter, firstLetter
        control := firstLetter "" control


        _GuiHandler.submitSetting("itemRefill", (item = "") ? control : item "/" control, value)
    }


    itemString(control) {
        item := ""

        for key, string in this.strings
        {
            if (InStr(control, string)) {
                item := string
                break
            }
        }

        return item
    }


    createRefillGUI()
    {
        global

        main_tab := "ItemRefill"
        child_tabs_%main_tab% := "Settings"

        Gui, CavebotGUI:Add, Tab2, x6 vTab_%main_tab% y%y_tab% w%tabsWidth% h%tabsHeight% hWndhTab_%main_tab% %TabStyle% +Theme, % child_tabs_%main_tab%
        if (load_order[1] != main_tab)
            GuiControl, Hide, Tab_%main_tab% ; esconder a tab antes de adicionar os elementos a ela

        if (OldbotSettings.uncompatibleModule("itemRefill") = true) {
            _GuiHandler.uncompatibleModuleWarning()
            return
        }

        Loop, parse, child_tabs_%main_tab%, |
        {
            current_child_tab := A_LoopField
            ; msgbox, % child_tabs_%main_tab%
            Gui, CavebotGUI:Tab, %current_child_tab%
            switch current_child_tab
            {
                case "Settings":
                    this.ChildTab_ItemRefill()
            }
        }

        return
    }

    ChildTab_ItemRefill() {
        global

        w := tabsWidth - 20



        this.itemsSection()

        quiverGroupboxWidth := 230

        this.quiverControls(w_text)



        y := this.itemsGroupbox.height + 62
        w_text := 60

        w_group1 := 230
        w_dropdown := w_group1 - w_text - 30

        x := quiverGroupboxWidth + 30

        Gui CavebotGUI:Add, GroupBox, x%x% y%y% w%w_group1% h132 Section,

        Disabled := uncompatibleFunction("itemRefill", "distanceWeaponRefill") = true ? "Disabled" : ""
        item := "distanceWeapon"
        distanceWeaponRefillEnabled := itemRefillObj.distanceWeaponRefillEnabled
        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+0 vdistanceWeaponRefillEnabled gdistanceWeaponRefillEnabled hwndhdistanceWeaponRefillEnabled Checked%distanceWeaponRefillEnabled% %Disabled%, Distance Weapon Refill
        TT.Add(hdistanceWeaponRefillEnabled, (LANGUAGE = "PT-BR" ? "Refillar o slot de arrow/hand com uma distance weapon" : "Refill the hand/arrow slot with a distance weapon"))


        Gui, CavebotGUI:Add, Text, xs+10 yp+25 w%w_text% Right, Slot:
        Gui, CavebotGUI:Add, Listbox, x+8 yp-3 r2 w%w_dropdown% vdistanceWeaponSlot gsubmitItemRefillOptionHandler hwndhdistanceWeaponSlot, % "hand|arrow"

        GuiControl, CavebotGUI:ChooseString, distanceWeaponSlot, % itemRefillObj[item].slot
        TT.Add(hdistanceWeaponSlot, (LANGUAGE = "PT-BR" ? "Selecione qual o slot será usado para checar se está vazio." : "Select which slot will be used to check if it's empty."))


        switch ItemRefillSystem.itemRefillJsonObj.options.equipItemMode {
            case "mouse":

                Gui, CavebotGUI:Add, Text, xs+10 y+15 w%w_text% Right, Ammunition:
                Gui, CavebotGUI:Add, DDL, x+8 yp-3 w%w_dropdown% vdistanceWeaponItemToEquip gsubmitItemRefillOptionHandler hwndhdistanceWeaponAmmunition, % this.getAmmoList()
                GuiControl, CavebotGUI:ChooseString, distanceWeaponItemToEquip, % itemRefillObj.distanceWeapon.itemToEquip

            default:
                Gui, CavebotGUI:Add, Text, xs+10 y+10 w%w_text% Right, Weapon Hotkey:
                Gui, CavebotGUI:Add, Hotkey, x+8 yp+4 w%w_dropdown% vdistanceWeaponHotkey hwndhdistanceWeaponHotkey gsubmitItemRefillOptionHandler, % itemRefillObj[item].hotkey
                TT.Add(hdistanceWeaponHotkey, (LANGUAGE = "PT-BR" ? "Hotkey configurada para equipar a distance weapon" : "Hotkey set to equip the distance weapon"))
        }
        /**
        Gui, CavebotGUI:Add, Text, xs+10 yp+25 w%w_text% Right, Weapon:
        Gui, CavebotGUI:Add, DDL, x+8 yp-3 w%w_dropdown% vdistanceWeapon gsubmitItemRefillOptionHandler hwndhdistanceWeapon, % ItemsHandler.getItemList("star|stone|spear|knife", {1: "Distance Weapons"})
        GuiControl, CavebotGUI:ChooseString, distanceWeapon, % distanceWeapon
        TT.Add(hdistanceWeapon, "Weapon to refill the hand slot with")
        */


        _GuiHandler.tutorialButtonModule("ItemRefill")
    }

    getAmmoList()
    {
        static list
        if (list) {
            return list
        }
        list := ItemsHandler.getItemList("", {1: "Ammunition", 2: "Distance Weapons"}, "bow|crossbow|arbalest|soul|chain bolter|the |_")
        list .= "|torch|rope"

        return list
    }

    itemsSection() {
        global

        this.itemsGroupbox := {}
        this.itemsGroupbox.subGroupbox := {}

        this.itemsGroupbox.width := w - 0
        this.itemsGroupbox.height := 360
        ; this.itemsGroupbox.height := 315
        this.itemsGroupbox.x := 15

        subgroupCount := 3

        lifeConditionText := (LANGUAGE = "PT-BR" ? "Se marcado, irá checar sua life antes de equipar o item.`nDeixe desmarcado se você não precisa dessa condição, pois usará menos CPU se desmarcado" : "If checked, it will check your life before equipping the item.`nLeave it unchecked if you don't need this life condition, since it will use less CPU if unchecked")
        manaConditionText := (LANGUAGE = "PT-BR" ? "Se marcado, irá checar sua mana antes de equipar o item.`nDeixe desmarcado se você não precisa dessa condição, pois usará menos CPU se desmarcado" : "If checked, it will check your mana before equipping the item`nLeave it unchecked if you don't need this mana condition, since it will use less CPU if unchecked")
        lifePercentText := (LANGUAGE = "PT-BR" ? "Porcentagem de life para começar a equipar o item, não irá equipar se a sua life estiver acima" : "Percent of life to start equipping the item, it won't equip if your life is above this")
        manaPercentText := (LANGUAGE = "PT-BR" ? "Porcentagem de mana para começar a equipar o item, não irá equipar se a sua mana estiver acima" : "Percent of mana to start equipping the item, it won't equip if your mana is above this")

        lifeConditionUnequipText := "If checked, it will check your life before unequipping the item.`nLeave it unchecked if you don't need this life condition, since it will use less CPU if unchecked"
        manaConditionUnequipText := "If checked, it will check your mana before unequipping the item`nLeave it unchecked if you don't need this mana condition, since it will use less CPU if unchecked"
        lifePercentUnequipText := (LANGUAGE = "PT-BR" ? "Se marcado, irá checar sua life antes de desequipar o item.`nDeixe desmarcado se você não precisa dessa condição, pois usará menos CPU se desmarcado" : "Percent of life to start unequipping the item, it won't unequip the item if your life is below this")
        manaPercentUnequipText := (LANGUAGE = "PT-BR" ? "Se marcado, irá checar sua life antes de desequipar o item.`nDeixe desmarcado se você não precisa dessa condição, pois usará menos CPU se desmarcado" : "Percent of mana to start unequipping the item, it won't unequip the item if your mana is below this")

        Gui CavebotGUI:Add, GroupBox, % "x" this.itemsGroupbox.x " y+6 w" this.itemsGroupbox.width " h" this.itemsGroupbox.height " Section", Items


        this.itemsGroupbox.subGroupbox.width := (this.itemsGroupbox.width / subgroupCount) - 14
        this.itemsGroupbox.subGroupbox.height := this.itemsGroupbox.height - 33
        this.itemsGroupbox.subGroupbox.x := this.itemsGroupbox.x + 10

        w_text := 81

        widthControls := this.itemsGroupbox.subGroupbox.width - w_text - 28

        widthDropdown := this.itemsGroupbox.subGroupbox.width - w_text - 30

        Gui, CavebotGUI:Add, Groupbox, % "x" this.itemsGroupbox.subGroupbox.x " ys+20 w" this.itemsGroupbox.subGroupbox.width " h" this.itemsGroupbox.subGroupbox.height " Section",

        this.itemsControls("ring", w_text, widthControls)

        this.itemsGroupbox.subGroupbox.x := this.itemsGroupbox.subGroupbox.x + this.itemsGroupbox.subGroupbox.width + 10
        Gui, CavebotGUI:Add, Groupbox, % "x" this.itemsGroupbox.subGroupbox.x " ys+0 w" this.itemsGroupbox.subGroupbox.width " h" this.itemsGroupbox.subGroupbox.height " Section",
        this.itemsControls("amulet", w_text, widthControls)

        this.itemsGroupbox.subGroupbox.x := this.itemsGroupbox.subGroupbox.x + this.itemsGroupbox.subGroupbox.width + 10
        Gui, CavebotGUI:Add, Groupbox, % "x" this.itemsGroupbox.subGroupbox.x " ys+0 w" this.itemsGroupbox.subGroupbox.width " h" this.itemsGroupbox.subGroupbox.height " Section",
        this.itemsControls("boots", w_text, widthControls)
    }

    quiverControls(w_text) {
        global

        y := this.itemsGroupbox.height + 62
        w_text := 60

        w_dropdown := quiverGroupboxWidth - w_text - 30

        Gui CavebotGUI:Add, GroupBox, x15 y%y% w%quiverGroupboxWidth% h132 Section,

        item := "quiver"

        Disabled := uncompatibleFunction("itemRefill", "quiverRefill") = true ? "Disabled" : ""
        quiverRefillEnabled := itemRefillObj.quiverRefillEnabled
        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+0 vquiverRefillEnabled gquiverRefillEnabled hwndhquiverRefillEnabled Checked%quiverRefillEnabled% %Disabled%, Quiver Refill
        TT.Add(hquiverRefillEnabled, (LANGUAGE = "PT-BR" ? "Refillar o Quiver com munição quando estiver vazio(com zero de munição)" : "Refill the Quiver with the ammunition when it is empty(containig zero ammo)"))

        Gui, CavebotGUI:Add, Text, xs+10 yp+25 w%w_text% Right, Quiver:

        /**
        need to get the image of the other quivers on windows client
        */
        quiverList := ItemsHandler.getItemList("quiver", {1: "Quivers"})
        Gui, CavebotGUI:Add, DDL, x+8 yp-3 w%w_dropdown% vquiver hwndhquiver gsubmitItemRefillOptionHandler, % quiverList
        GuiControl, CavebotGUI:ChooseString, quiver, % itemRefillObj[item].quiver
        TT.Add(hquiver, (LANGUAGE = "PT-BR" ? "Quiver equipado no seu set" : "Quiver equipped in your set"))

        Gui, CavebotGUI:Add, Text, xs+10 y+14 w%w_text% Right, Equip mode:
        Gui, CavebotGUI:Add, Listbox, x+8 yp-3 r2 w%w_dropdown% vquiverEquipMode gquiverEquipMode hwndhquiverEquipMode, % "hotkey|mouse"
        GuiControl, CavebotGUI:ChooseString, quiverEquipMode, % itemRefillObj[item].equipMode
        TT.Add(hquiverEquipMode, (LANGUAGE = "PT-BR" ? "Se selecionado ""hotkey"", irá pressionar o Ammunition Hotkey e a munição deve ser equipada diretamente no quiver.`nPorém, em alguns OT servers isso não acontece, nesse caso deve usar o modo de ""mouse"", onde irá arrastar a munição para o quiver" : "If selected ""hotkey"", it will press the Ammunition Hotkey and the ammo is supposed to be equipped directly into the quiver.`nHowever, in some OT servers this doesn't happen, in this case need to use the ""mouse"" mode, where it will drag the Ammunition to the quiver"))


        Hidden1 := itemRefillObj[item].equipMode = "Hotkey" ? "" : "Hidden"
        Hidden2 := itemRefillObj[item].equipMode = "Hotkey" ? "Hidden" : ""

        ys1 := 89
        ys2 := ys1 - 3

        ammoList := ItemsHandler.getItemList("", {1: "Ammunition"})
        Gui, CavebotGUI:Add, Text, xs+10 ys+%ys1% w%w_text% vquiverAmmoText Right %Hidden2%, Ammunition:

            new _Dropdown().name("quiverAmmunition")
            .x("+8").y("p-3").w(w_dropdown)
            .hidden(itemRefillObj[item].equipMode = "Hotkey")
            .event("submitItemRefillOptionHandler")
            .add()
            .list(this.getQuiverAmmoList())

        ; Gui, CavebotGUI:Add, DDL, x+8 yp-3 w%w_dropdown% vquiverAmmunition gsubmitItemRefillOptionHandler hwndhquiverAmmunition %Hidden2%, % ammoList
        ; GuiControl, CavebotGUI:ChooseString, quiverAmmunition, % itemRefillObj[item].ammunition
        ; TT.Add(hquiverAmmunition, "")

        Gui, CavebotGUI:Add, Text, xs+10 ys+%ys2% w%w_text% vquiverAmmoHotkeyText Right %Hidden1%, Ammunition Hotkey:
        Gui, CavebotGUI:Add, Hotkey, x+8 yp+4 w%w_dropdown% vquiverAmmoHotkey hwndhquiverAmmoHotkey gsubmitItemRefillOptionHandler %Hidden1%, % itemRefillObj[item].ammoHotkey
        TT.Add(hquiverAmmoHotkey, (LANGUAGE = "PT-BR" ? "Hotkey configuarda para equipar a munição no quiver" : "Hotkey set for the ammunition to equip(put) in the quiver"))
    }

    /**
    * @return array<_ListOption>
    */
    getQuiverAmmoList()
    {
        list := {}
        for key, item in ItemsHandler.getItemListArray("", {1: "Ammunition"}) {
            list.Push(new _ListOption(item, item = itemRefillObj.quiver.ammunition))
        }

        return list
    }

    itemsControls(item, w_text, widthControls) {
        global

        this.itemsGroupbox.subGroupbox.child := {}
        this.itemsGroupbox.subGroupbox.child.width := this.itemsGroupbox.subGroupbox.width - 20
        this.itemsGroupbox.subGroupbox.child.x := this.itemsGroupbox.subGroupbox.x + 10
        this.itemsGroupbox.subGroupbox.child.controlsX := this.itemsGroupbox.subGroupbox.child.x + 10
        this.itemsGroupbox.subGroupbox.child.widthControls := this.itemsGroupbox.subGroupbox.child.width - 22
        this.itemsGroupbox.subGroupbox.child.widthText := 92
        this.itemsGroupbox.subGroupbox.child.widthControlsText := this.itemsGroupbox.subGroupbox.child.width - this.itemsGroupbox.subGroupbox.child.widthText - 28


        w_text := 81

        Disabled := uncompatibleFunction("itemRefill", item "Refill") = true ? "Disabled" : ""

        %item%RefillEnabled := itemRefillObj[item "RefillEnabled"]
        StringUpper, itemText, item, T
        checked := %item%RefillEnabled
        Gui, CavebotGUI:Add, Checkbox, xs+10 yp+0 v%item%RefillEnabled g%item%RefillEnabled hwndh%item%RefillEnabled Checked%checked% %Disabled%, %  itemText " Refill"
        TT.Add(h%item%RefillEnabled, (LANGUAGE = "PT-BR" ? "Equipar o " item " quando o " item " slot estiver vazio" : "Equip the " item " when the " item " slot is empty"))

        switch item {
            case "ring":
                if (ItemRefillSystem.itemRefillJsonObj.options.equipItemMode = "hotkey") {
                    itemList := ItemsHandler.getItemList("", {1: "Rings"}
                        , "")
                } else {
                    itemList := ItemsHandler.getItemList("", {1: "Rings"}, "")
                }

            case "amulet":
                itemList := ItemsHandler.getItemList("", {1: "Amulets and Necklaces"}, "")
            case "boots":
                itemList := ItemsHandler.getItemList("", {1: "Boots"}, "firewalker|soft boots")
                itemList .= "|worn firewalker boots"
                itemList .= "|worn soft boots"
        }

        Gui CavebotGUI:Add, GroupBox, % "x" this.itemsGroupbox.subGroupbox.child.x " y+6 w" this.itemsGroupbox.subGroupbox.child.width " h" 123 "", % LANGUAGE = "PT-BR" ? "Opções" : "Options"

        switch ItemRefillSystem.itemRefillJsonObj.options.equipItemMode {
            case "mouse":
                tooltipText := item " to equip"
                Gui, CavebotGUI:Add, Text, % "x" this.itemsGroupbox.subGroupbox.child.controlsX " yp+20 w" this.itemsGroupbox.subGroupbox.child.widthText - 35 " hwndh" item "RefillItemToEquipText Right", Item:
                TT.Add(h%item%RefillItemToEquipText, tooltipText)

                Gui, CavebotGUI:Add, DDL, % "x+5"  " yp-3 w" this.itemsGroupbox.subGroupbox.child.widthControlsText + 35 " v" item "RefillItemToEquip gsubmitItemRefillOptionHandler hwndh" item "RefillItemToEquip", % itemList
                GuiControl, CavebotGUI:ChooseString, %item%RefillItemToEquip, % itemRefillObj[item].itemToEquip
                TT.Add(h%item%RefillItemToEquip, tooltipText)

            default:
                tooltipText := txt("Hotkey do " item " para equipar", "Hotkey of the " item " to equip")
                Gui, CavebotGUI:Add, Text, % "x" this.itemsGroupbox.subGroupbox.child.controlsX " yp+20 w" this.itemsGroupbox.subGroupbox.child.widthText " hwndh" item "RefillHotkeyText Right", Hotkey:
                TT.Add(h%item%RefillHotkeyText, tooltipText)

                Gui, CavebotGUI:Add, Hotkey, % "x+5 yp-2 w" this.itemsGroupbox.subGroupbox.child.widthControlsText " h18 v" item "RefillHotkey gsubmitItemRefillOptionHandler hwndh" item "RefillHotkey", % itemRefillObj[item].hotkey
                TT.Add(h%item%RefillHotkey, tooltipText)
        }

        %item%IgnoreInPZ := itemRefillObj[item].ignoreInPZ
        checked := %item%IgnoreInPZ
        Gui, CavebotGUI:Add, Checkbox, % "x" this.itemsGroupbox.subGroupbox.child.controlsX " y+8 v" item "IgnoreInPZ hwndh" item "IgnoreInPZ gsubmitItemRefillOptionHandler Checked" checked " " , % LANGUAGE = "PT-BR" ? "Ignorar em Protection Zone" : "Ignore in Protection Zone"
        TT.Add(h%item%IgnoreInPZ, (LANGUAGE = "PT-BR" ? "Ignorar o " item " refill quando estiver dentro de uma Protection Zone" : "Ignore the " item " refill when inside a Protection Zone"))


        this.lifeManaControls(item, "life", false, LANGUAGE = "PT-BR" ? "Vida abaixo %:" : "Life below %:", "+10")
        this.lifeManaControls(item, "mana", false, LANGUAGE = "PT-BR" ? "Mana abaixo %:" : "Mana below %:", "+7")

        Gui CavebotGUI:Add, GroupBox, % "x" this.itemsGroupbox.subGroupbox.child.x " y+20 w" this.itemsGroupbox.subGroupbox.child.width " h" 168 "",

        %item%Unequip := itemRefillObj[item].unequip
        checked := %item%Unequip
        Disabled := ItemRefillSystem.itemRefillJsonObj.options.disableUnequipItem = true ? "Hidden" : ""
        Gui, CavebotGUI:Add, Checkbox, % "x" this.itemsGroupbox.subGroupbox.child.controlsX " yp+0 v" item "Unequip hwndh" item "Unequip gunequipItemCheckbox Checked" checked " " Disabled, % (LANGUAGE = "PT-BR" ? "Desequipar " : "Unequip " ) item
        TT.Add(h%item%Unequip, (LANGUAGE = "PT-BR" ? "Desequipar o " item " se as condições de Life/Mana abaixo forem verdadeiras" : "Unequip the " item " if Life/Mana conditions below are true"))

        this.lifeManaControls(item, "life", true, LANGUAGE = "PT-BR" ? "Vida acima %:" :  "Life above %:", "p+20")
        this.lifeManaControls(item, "mana", true, LANGUAGE = "PT-BR" ? "Mana acima %:" : "Mana above %:", "+10")


        Gui, CavebotGUI:Add, Groupbox, % "x" this.itemsGroupbox.subGroupbox.child.controlsX + 10 " y+7 w" this.itemsGroupbox.subGroupbox.child.width - 40 " h8 cBlack"


        %item%UnequipEquipOther := itemRefillObj[item].unequipEquipOther
        checked := %item%UnequipEquipOther
        DisabledUnequipItem := itemRefillObj[item].unequip = true ? "" : "Hidden"
        Gui, CavebotGUI:Add, Checkbox, % "x" this.itemsGroupbox.subGroupbox.child.controlsX " y+10 v" item "UnequipEquipOther hwndh" item "UnequipEquipOther gunequipEquipItemCheckbox Checked" checked " " DisabledUnequipItem " ", % (LANGUAGE = "PT-BR" ? "Equipar outro " : "Equip other ") item


        checked := %item%UnequipEquipOther
        Disabled := "Hidden"
        if (%item%Unequip = 1 && %item%UnequipEquipOther = 1)
            Disabled := ""

        StringUpper, itemWord, item, T
        switch item {
            case "boots":
                extendedText := (LANGUAGE = "PT-BR" ? "`n`nExemplo: pressionar a hotkey para equipar uma nova ""soft boots"" quando o item equipado for uma ""worn soft boots""." : "`n`nExample: press the hotkey to equip a new ""soft boots"" when the equipped item is the ""worn soft boots"".")
            case "amulet":
                extendedText := (LANGUAGE = "PT-BR" ? "`n`nExemplo: pressionar a hotkey para equipar o ""enchanted sleep shawl"" quando o item equipador for o ""sleep shawl""." : "`n`nExample: press the hotkey to equip a ""enchanted sleep shawl"" when the equipped item is the ""sleep shawl"".")
        }

        TT.Add(h%item%RefillItem, (LANGUAGE = "PT-BR" ? "Se marcado e o " item " selecionado está equipado, irá pressionar a hotkey para equipar(desequipando esse " item " equipado)." : "If checked and the selected " item " is equipped, it'll press the hotkey to equip(unequipping this selected " item " equipped).") extendedText)

        switch item {
            case "ring":
                extendedText := (LANGUAGE = "PT-BR" ? "`n`nExemplo de cenário: equipar um ""prismatic ring"" se a condição ""Life above %"" for verdadeira, a hotkey principal do ring refill é para o ""might ring"", equipado quando a condição ""Life below %"" era verdadeira." : "`n`nExample scenario: equip a ""prismatic ring"" if ""Life above %"" condition is true, the main hotkey of ring refill is for the ""might ring"", equipped when ""Life below %"" condition was true.")
        }

        TT.Add(h%item%UnequipEquipOther, (LANGUAGE = "PT-BR" ? "Se marcado, irá equipar outro " item " após desequipar o atual." : "If checked, it will equip another " item " after unequipping the current one.") extendedText)

        Disabled := itemRefillObj[item].unequipEquipOther = true ? "" : "Hidden"
        tooltipText := txt("Hotkey do " item " para equipar após ter desequipado o anterior", "Hotkey of the " item " to equip after unequip the previous one")

        Gui, CavebotGUI:Add, Text, % "x" this.itemsGroupbox.subGroupbox.child.controlsX " y+10 w" this.itemsGroupbox.subGroupbox.child.widthText " v" item "UnequipEquipOtherHotkeyText hwndh" item "UnequipEquipOtherHotkeyText " Disabled " " DisabledUnequipItem " Right", Hotkey:
        TT.Add(h%item%UnequipEquipOtherHotkeyText, tooltipText)

        Gui, CavebotGUI:Add, Hotkey, % "x+5 yp-2 w" this.itemsGroupbox.subGroupbox.child.widthControlsText " h18 v" item "UnequipEquipOtherHotkey gsubmitItemRefillOptionHandler hwndh" item "UnequipEquipOtherHotkey " Disabled " " DisabledUnequipItem, % itemRefillObj[item].unequipEquipOtherHotkey
        TT.Add(h%item%UnequipEquipOtherHotkey, tooltipText)
    }


    lifeManaControls(item, type, unequipCondition, checkboxText, y := "+10") {
        global

        if type not in life,mana
            throw Exception("Wrong type for item refill condition: " type)

        %item%Refill%type%Condition := itemRefillObj[item][type "Condition"]

        DisabledUnequip := unequipCondition = false ? "" : (itemRefillObj[item].unequip = true ? "" : "Hidden")

        switch unequipCondition {
            case true:
                checked := itemRefillObj[item][type "ConditionUnequip"]
                var := item "Refill" type "ConditionUnequip"
                ; msgbox, % var "`n" checked "`n"  item "`n"  type
            case false:
                checked := itemRefillObj[item][type "Condition"]
                var := item "Refill" type "Condition"
                checked := %item%Refill%type%Condition
        }

        controlHwnd := "h" var
        Gui, CavebotGUI:Add, Checkbox, % "x" this.itemsGroupbox.subGroupbox.child.controlsX " y" y " w" this.itemsGroupbox.subGroupbox.child.widthText " h19 v" var " gitemRefillLifeCheckbox hwndh" var " " DisabledUnequip " Checked" checked "", % checkboxText
        TT.Add(h%var%, unequipCondition = false ? %type%ConditionText : %type%ConditionUnequipText)

        Disabled := %item%Refill%type%ConditionUnequip = true ? "" : "Disabled"

        switch unequipCondition {
            case true:
                var := item "Refill" type "Unequip"
            case false:
                var := item "Refill" type
        }
        Disabled := checked = true ? "" : "Disabled"

        Gui, CavebotGUI:Add, Edit, % "x+5 yp-0 h18 v" var " gsubmitItemRefillOptionHandler hwndh" var " w" this.itemsGroupbox.subGroupbox.child.widthControlsText " 0x2000 Limit2 Center " Disabled " " DisabledUnequip " ", % unequipCondition = false ? itemRefillObj[item][type] : itemRefillObj[item][type "Unequip"]
        TT.Add(h%var%, unequipCondition = false ? %type%PercentText : %type%PercentUnequipText)
    }
}
