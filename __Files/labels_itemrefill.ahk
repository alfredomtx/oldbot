

submitItemRefillOptionHandler:
    Gui, CavebotGUI:Default
    Gui, CavebotGUI:Submit, NoHide

    if (InStr(A_GuiControl, "Hotkey")) {
        try _GuiHandler.validateHotkey(A_GuiControl, %A_GuiControl%)
        catch e {
            Msgbox, 48,, % e.Message
        return
    }
}


ItemRefillGUI.submitItemRefillControl(A_GuiControl, %A_GuiControl%, A_ThisLabel)
return

itemRefillLifeCheckbox:
    Gui, CavebotGUI:Default
    Gui, CavebotGUI:Submit, NoHide


    switch A_GuiControl {
        case "ringRefillLifeCondition":
            GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Enable" : "Disable"), ringRefillLife
            ; GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Show" : "Hide"), ringRefillLife
        case "ringRefillManaCondition":
            GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Enable" : "Disable"), ringRefillMana
            ; GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Show" : "Hide"), ringRefillMana
        case "amuletRefillLifeCondition":
            GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Enable" : "Disable"), amuletRefillLife
            ; GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Show" : "Hide"), amuletRefillLife
        case "amuletRefillManaCondition":
            GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Enable" : "Disable"), amuletRefillMana
            ; GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Show" : "Hide"), amuletRefillMana
        case "bootsRefillLifeCondition":
            GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Enable" : "Disable"), bootsRefillLife
            ; GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Show" : "Hide"), bootsRefillLife
        case "bootsRefillManaCondition":
            GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Enable" : "Disable"), bootsRefillMana
            ; GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Show" : "Hide"), bootsRefillMana

        case "ringRefillLifeConditionUnequip":
            GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Enable" : "Disable"), ringRefillLifeUnequip
        case "ringRefillManaConditionUnequip":
            GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Enable" : "Disable"), ringRefillManaUnequip
        case "amuletRefillLifeConditionUnequip":
            GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Enable" : "Disable"), amuletRefillLifeUnequip
        case "amuletRefillManaConditionUnequip":
            GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Enable" : "Disable"), amuletRefillManaUnequip
        case "bootsRefillLifeConditionUnequip":
            GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Enable" : "Disable"), bootsRefillLifeUnequip
        case "bootsRefillManaConditionUnequip":
            GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? " Enable" : "Disable"), bootsRefillManaUnequip
    }

    ItemRefillGUI.submitItemRefillControl(A_GuiControl, %A_GuiControl%, A_ThisLabel)

return




unequipEquipItemCheckbox:
    Gui, CavebotGUI:Default
    Gui, CavebotGUI:Submit, NoHide

    item := ItemRefillGUI.itemString(A_GuiControl)

    GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? "Enable" : "Disable"), %item%UnequipEquipOtherHotkey
    GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? "Enable" : "Disable"), %item%UnequipEquipOtherHotkeyText

    GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? "Show" : "Hide"), %item%UnequipEquipOtherHotkey
    GuiControl, % "CavebotGUI:" (%A_GuiControl% = 1 ? "Show" : "Hide"), %item%UnequipEquipOtherHotkeyText
    ItemRefillGUI.submitItemRefillControl(A_GuiControl, %A_GuiControl%, A_ThisLabel)
return

unequipItemCheckbox:
    Gui, CavebotGUI:Default
    Gui, CavebotGUI:Submit, NoHide



    item := ItemRefillGUI.itemString(A_GuiControl)


    controls := {}
    controls.Push()

    switch %A_GuiControl% {
        case 1:
            GuiControl, % "CavebotGUI:" "Enable", %item%RefillLifeConditionUnequip
            GuiControl, % "CavebotGUI:" "Enable", %item%RefillManaConditionUnequip
            GuiControl, % "CavebotGUI:" "Enable", %item%RefillLifeUnequip
            GuiControl, % "CavebotGUI:" "Enable", %item%RefillManaUnequip
            GuiControl, % "CavebotGUI:" "Enable", %item%UnequipEquipOther

            GuiControl, % "CavebotGUI:" "Show", %item%RefillLifeConditionUnequip
            GuiControl, % "CavebotGUI:" "Show", %item%RefillManaConditionUnequip
            GuiControl, % "CavebotGUI:" "Show", %item%RefillLifeUnequip
            GuiControl, % "CavebotGUI:" "Show", %item%RefillManaUnequip
            GuiControl, % "CavebotGUI:" "Show", %item%UnequipEquipOther

            GuiControlGet, %item%UnequipEquipOther
            if (%item%UnequipEquipOther = true) {
                GuiControl, % "CavebotGUI:" "Enable", %item%UnequipEquipOtherHotkey
                GuiControl, % "CavebotGUI:" "Enable", %item%UnequipEquipOtherHotkeyText

                GuiControl, % "CavebotGUI:" "Show", %item%UnequipEquipOtherHotkey
                GuiControl, % "CavebotGUI:" "Show", %item%UnequipEquipOtherHotkeyText
            }

        case 0:
            GuiControl, % "CavebotGUI:" "Disable", %item%RefillLifeConditionUnequip
            GuiControl, % "CavebotGUI:" "Disable", %item%RefillManaConditionUnequip
            GuiControl, % "CavebotGUI:" "Disable", %item%RefillLifeUnequip
            GuiControl, % "CavebotGUI:" "Disable", %item%RefillManaUnequip

            GuiControl, % "CavebotGUI:" "Disable", %item%UnequipEquipOther
            GuiControl, % "CavebotGUI:" "Disable", %item%UnequipEquipOtherHotkey
            GuiControl, % "CavebotGUI:" "Disable", %item%UnequipEquipOtherHotkeyText

            GuiControl, % "CavebotGUI:" "Disable", %item%RefillLifeConditionUnequip

            GuiControl, % "CavebotGUI:" "Hide", %item%RefillLifeConditionUnequip
            GuiControl, % "CavebotGUI:" "Hide", %item%RefillManaConditionUnequip
            GuiControl, % "CavebotGUI:" "Hide", %item%RefillLifeUnequip
            GuiControl, % "CavebotGUI:" "Hide", %item%RefillManaUnequip

            GuiControl, % "CavebotGUI:" "Hide", %item%UnequipEquipOther
            GuiControl, % "CavebotGUI:" "Hide", %item%UnequipEquipOtherHotkey
            GuiControl, % "CavebotGUI:" "Hide", %item%UnequipEquipOtherHotkeyText

            GuiControl, % "CavebotGUI:" "Hide", %item%RefillLifeConditionUnequip



    }

    ItemRefillGUI.submitItemRefillControl(A_GuiControl, %A_GuiControl%, A_ThisLabel)
return

quiverEquipMode:
    Gui, CavebotGUI:Default
    Gui, CavebotGUI:Submit, NoHide

    if (quiverEquipMode = "Hotkey") {
        GuiControl, CavebotGUI:Show, quiverAmmoHotkeyText
        GuiControl, CavebotGUI:Show, quiverAmmoHotkey
        GuiControl, CavebotGUI:Hide, quiverAmmoText
        GuiControl, CavebotGUI:Hide, quiverAmmunition
    } else {
        GuiControl, CavebotGUI:Hide, quiverAmmoHotkeyText
        GuiControl, CavebotGUI:Hide, quiverAmmoHotkey
        GuiControl, CavebotGUI:Show, quiverAmmoText
        GuiControl, CavebotGUI:Show, quiverAmmunition

    }
    ItemRefillGUI.submitItemRefillControl(A_GuiControl, %A_GuiControl%, A_ThisLabel)
return

quiverRefillEnabled:
    Gui, CavebotGUI:Submit, NoHide
    ItemRefillHandler.submitCheckboxItemRefill("quiverRefillEnabled", quiverRefillEnabled)
return

distanceWeaponRefillEnabled:
    Gui, CavebotGUI:Submit, NoHide

    ItemRefillHandler.submitCheckboxItemRefill("distanceWeaponRefillEnabled", distanceWeaponRefillEnabled)
return

ringRefillEnabled:
    Gui, CavebotGUI:Submit, NoHide
    ItemRefillHandler.submitCheckboxItemRefill("ringRefillEnabled", ringRefillEnabled)
return

amuletRefillEnabled:
    Gui, CavebotGUI:Submit, NoHide
    ItemRefillHandler.submitCheckboxItemRefill("amuletRefillEnabled", amuletRefillEnabled)
return

bootsRefillEnabled:
    Gui, CavebotGUI:Submit, NoHide
    ItemRefillHandler.submitCheckboxItemRefill("bootsRefillEnabled", bootsRefillEnabled)
return

tutorialButtonItemRefill:
    openURL(LinksHandler.ItemRefill.tutorial)
return

testMemoryRing:
    MemoryManager.testItemRefillRing()
return