saveSupportTimer:
    SupportHandler.saveSupport()
return

submitSupportOptionHandler:
    try
        SupportHandler.submitSupportOption()
    catch e
        Msgbox, 48,, % e.Message
return

exanaVitaEnabled:
    Gui, CavebotGUI:Submit, NoHide
    GuiControl, % "CavebotGUI:" (exanaVitaEnabled = 1 ? "Show" : "Hide"), exanaVitaLifeText 
    GuiControl, % "CavebotGUI:" (exanaVitaEnabled = 1 ? "Show" : "Hide"), exanaVitaLife 
    GuiControl, % "CavebotGUI:" (exanaVitaEnabled = 1 ? "Show" : "Hide"), exanaVitaHotkeyText 
    GuiControl, % "CavebotGUI:" (exanaVitaEnabled = 1 ? "Show" : "Hide"), exanaVitaHotkey 
    Goto, submitSupportOptionHandler

utamoVitaLife:
    Gui, CavebotGUI:Submit, NoHide
    ; if (utamoVitaLife > exanaVitaLife) {
    ;     GuiControl, CavebotGUI:, utamoVitaLife, % exanaVitaLife - 1
    ;     Msgbox, 48,, % LANGUAGE = "PT-BR" ? "A condição ""Vida abaixo""(" utamoVitaLife ") do Utamo Vita não pode ser MAIOR do que a ""Vida acima"" do Exana Vita." : "The condition ""Life below""(" utamoVitaLife ") of Utamo Vita cannot be HIGHER than the ""Life above"" of Exana Vita.", 10
    ;     return
    ; }
    Goto, submitSupportOptionHandler

exanaVitaLife:
    Gui, CavebotGUI:Submit, NoHide
    ; if (exanaVitaLife < utamoVitaLife) {
    ;     GuiControl, CavebotGUI:, exanaVitaLife, % utamoVitaLife + 1
    ;     Msgbox, 48,, % LANGUAGE = "PT-BR" ? "A condição ""Vida acima""(" exanaVitaLife ") do Exana Vita não pode ser MENOR do que a ""Vida abaixo"" do Utamo Vita." : "The condition ""Life above""(" exanaVitaLife ") of Exana Vita cannot be LOWER than the ""Life below"" of Utamo Vita.", 10
    ;     return
    ; }
    Goto, submitSupportOptionHandler

autoEatFood:
    Gui, CavebotGUI:Submit, NoHide
    if (autoEatFood = 1) && (SupportGUI.eatFoodHotkey.get()  = "") {
        _GuiHandler.toggleFunctionEnabledCheckbox("support", "autoEatFood", 0)
        Msgbox, 48,, % txt("Preencha a hotkey do Auto Eat Food.", "Fill the hotkey for Auto Eat Food."), 10
    return
}
SupportHandler.submitCheckboxSupport("autoEatFood", autoEatFood)
return

autoShoot:
    Gui, CavebotGUI:Submit, NoHide
    if (autoShoot && empty(autoShootHotkey)) {
        _GuiHandler.toggleFunctionEnabledCheckbox("support", "autoShoot", 0)
        Msgbox, 48,, % txt("Preencha a hotkey do Auto Shoot.", "Fill the hotkey for Auto Shoot."), 10
    return
}
SupportHandler.submitCheckboxSupport("autoShoot", autoShoot)
return

autoHaste:
    Gui, CavebotGUI:Submit, NoHide
    if (autoHaste = 1) && (hasteSpellHotkey = "") {
        _GuiHandler.toggleFunctionEnabledCheckbox("support", "autoHaste", 0)
        Msgbox, 48,, % txt("Preencha a hotkey do Auto Haste.", "Fill the hotkey for Auto Haste."), 10
    return
}
SupportHandler.submitCheckboxSupport("autoHaste", autoHaste)
return

autoUtamoVita:
    Gui, CavebotGUI:Submit, NoHide
    if (autoUtamoVita = 1) && (utamoVitaHotkey = "") {
        _GuiHandler.toggleFunctionEnabledCheckbox("support", "autoUtamoVita", 0)
        Msgbox, 48,, % txt("Preencha a hotkey do Auto Utamo Vita.", "Fill the hotkey for Auto Utamo Vita."), 10
    return
}
SupportHandler.submitCheckboxSupport("autoUtamoVita", autoUtamoVita)
return

autoBuffSpell:
    Gui, CavebotGUI:Submit, NoHide
    if (autoBuffSpell = 1) && (autoBuffSpellHotkey = "") {
        _GuiHandler.toggleFunctionEnabledCheckbox("support", "autoBuffSpell", 0)
        Msgbox, 48,, % txt("Preencha a hotkey do Auto Buff Spell.", "Fill the hotkey for Auto Buff Spell."), 10
    return
}
SupportHandler.submitCheckboxSupport("autoBuffSpell", autoBuffSpell)
return

cureParalyze:
    Gui, CavebotGUI:Submit, NoHide
    if (cureParalyze = 1) && (cureParalyzeHotkey = "") {
        _GuiHandler.toggleFunctionEnabledCheckbox("support", "cureParalyze", 0)
        Msgbox, 48,, % txt("Preencha a hotkey do Curar Paralyze.", "Fill the hotkey for Cure Paralyze."), 10
    return
}
SupportHandler.submitCheckboxSupport("cureParalyze", cureParalyze)
return

curePoison:
    Gui, CavebotGUI:Submit, NoHide
    if (curePoison = 1) && (curePoisonHotkey = "") {
        _GuiHandler.toggleFunctionEnabledCheckbox("support", "curePoison", 0)
        Msgbox, 48,, % txt("Preencha a hotkey do Curar Poison.", "Fill the hotkey for Cure Poison."), 10
    return
}
SupportHandler.submitCheckboxSupport("curePoison", curePoison)
return

cureFire:
    Gui, CavebotGUI:Submit, NoHide
    if (cureFire = 1) && (cureFireHotkey = "") {
        _GuiHandler.toggleFunctionEnabledCheckbox("support", "cureFire", 0)
        Msgbox, 48,, % txt("Preencha a hotkey do Curar Fire.", "Fill the hotkey for Cure Fire."), 10
    return
}
SupportHandler.submitCheckboxSupport("cureFire", cureFire)
return

cureCurse:
    Gui, CavebotGUI:Submit, NoHide
    if (cureCurse = 1) && (cureCurseHotkey = "") {
        _GuiHandler.toggleFunctionEnabledCheckbox("support", "cureCurse", 0)
        Msgbox, 48,, % txt("Preencha a hotkey do Curar Curse.", "Fill the hotkey for Cure Curse."), 10
    return
}
SupportHandler.submitCheckboxSupport("cureCurse", cureCurse)
return

supportControlsHidden:
    SupportGUI.toggleSupportControlsHidden()
return

fullLightEnabled:
    Gui, CavebotGUI:Submit, NoHide
    Gui, CavebotGUI:Default

    switch fullLightEnabled {
        case true:
            FullLightHandler.enableFullLight()
        case false:
            FullLightHandler.disableFullLight()
    }
return

submitFullLightOption:
    Gui, CavebotGUI:Submit, NoHide
    _GuiHandler.submitSetting("fullLight", A_GuiControl, %A_GuiControl%)
return


magnifierEnabled:
    _Magnifier.CHECKBOX.toggle()
return