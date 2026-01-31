

checkLifeManaAndTrain:
    Gui, CavebotGUI:Submit, NoHide
    ; msgbox, % lifeHealingEnabled " / " manaHealingEnabled " / " manaTrainEnabled
    if (lifeHealingEnabled = true && manaHealingEnabled = true && manaTrainEnabled = true)
        LifeManaTrain := 1
    else
        LifeManaTrain := 0

    checkbox_setvalue("LifeManaTrain", LifeManaTrain)

    if (lifeHealingEnabled = false && manaHealingEnabled = false && manaTrainEnabled = false)
        HealingHandler.stopAllHealing()
return

LifeManaTrain:
    ; GuiControlGet, LifeManaTrain
    switch LifeManaTrain {
        case true:
            HealingHandler.startAllHealing()
        case false:
            HealingHandler.stopAllHealing()
    }
    restoreCursor()
return

lifeHealingEnabled:
    Gui, CavebotGUI:Submit, NoHide
    lifeHealingEnabled := lifeHealingEnabled
    if (lifeHealingEnabled = 1) {
        try HealingHandler.validateHealingRules()
        catch e {
            HealingHandler.setLifeHealingEnabled(false)
            Msgbox, 48,, % e.Message, 4
            return
        }
        if (HealingHandler.checkLifeHotkeys(startingBot) = false) {
            HealingHandler.setLifeHealingEnabled(false)
            return
        }

    }
    HealingHandler.setLifeHealingEnabled(lifeHealingEnabled)
    gosub, checkLifeManaAndTrain
return

manaHealingEnabled:
    Gui, CavebotGUI:Submit, NoHide
    if (manaHealingEnabled = 1) && (HealingHandler.checkManaHotkey(startingBot) = false) {
        HealingHandler.setManaHealingEnabled(false)
        gosub, checkLifeManaAndTrain
        return
    }
    HealingHandler.setManaHealingEnabled(manaHealingEnabled)
    gosub, checkLifeManaAndTrain

return

manaTrainEnabled:
    Gui, CavebotGUI:Submit, NoHide
    if (manaTrainEnabled = 1) && (HealingHandler.checkManaTrainHotkey(startingBot) = false) {
        HealingHandler.setManaTrainEnabled(false)
        gosub, checkLifeManaAndTrain
        return
    }
    HealingHandler.setManaTrainEnabled(manaTrainEnabled)
    gosub, checkLifeManaAndTrain
return


saveHealingTimer:
    HealingHandler.saveHealing()
return

submitHealingOptionHandler:
    try
        HealingHandler.submitHealingOption()
    catch e {
        Msgbox, 48,, % e.Message, 10
    }
return

tutorialButtonHealing:
    openURL(LinksHandler.Healing.tutorial)
return