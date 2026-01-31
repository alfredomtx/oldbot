attackAllMode:
    GuiControlGet, attackAllMode
    if (attackAllMode = 1)
        msgbox, 64,, % txt("ATENÇÃO: Os botões do Battle List de configurações de ocultar/exibir monstros, npcs, players e etc devem estar OCULTOS para usar esse modo de ataque all.", "ATTENTION: The Battle List buttons of settings for show/hide monsters, npcs, players and etc must be HIDDEN to use this attack all mode."), 20
submitTargetingSettingOption:
    Gui, CavebotGUI:Default
    Gui, CavebotGUI:Submit, NoHide

    TargetingHandler.submitTargetingSetting(A_GuiControl, %A_GuiControl%)
return

_submitCheckboxTargeting:
    Gui, CavebotGUI:Default
    Gui, CavebotGUI:Submit, NoHide
    TargetingHandler.submitCheckboxTargeting(A_GuiControl, %A_GuiControl%)
return

spellCreatureCountMethod:
    Gui, AdvancedSpellGUI:Submit, NoHide
    if (spellCreatureCountMethod = "Battle list") {
        GuiControl, AdvancedSpellGUI:Enable, spellCreatureCountPolicy
        GuiControl, AdvancedSpellGUI:Disable, spellMode
        GuiControl, AdvancedSpellGUI:Choose, spellMode, 1
    } else if (isTibia13()) {
        GuiControl, AdvancedSpellGUI:Enable, spellMode
        GuiControl, AdvancedSpellGUI:Disable, spellCreatureCountPolicy
        GuiControl, AdvancedSpellGUI:ChooseString, spellCreatureCountPolicy, % "All creatures"
    }
    if (creatureNameSpell = TargetingSystem.defaultCreature)
        GuiControl, AdvancedSpellGUI:Disable, spellCreatureCountPolicy

return

submitTargetOptionHandler:
    try
        TargetingHandler.submitTargetOption()
    catch e
        Msgbox, 48,, % e.Message
return



DeleteAttackSpell:
    AttackSpell.deleteSpell()
    TargetingGUI.checkSpellIconLV()
return

LV_Creatures:
    switch, A_GuiEvent {
        case "Normal", case "RightClick":
            TargetingGUI.LV_Creatures()
    }
return

LV_CreatureList:
    switch, A_GuiEvent {
        case "DoubleClick":
            TargetingGUI.LV_CreatureList()
    }
return

LV_CreaturesSpells:
    switch, A_GuiEvent {
        case "Normal", case "RightClick":
            TargetingGUI.LV_CreaturesSpells()
    }
return

EditAttackSpell:
    ; try
    AttackSpell.editAttackSpell()
    ; catch e {
    ; if (A_IsCompiled)
    ; Msgbox, 48,, % e.Message "`n" e.What
    ; else
    ; Msgbox, 48,, % e.Message "`n" e.What "`n" e.File "`n" e.Line
    ; }


    Gosub, spellMode

return

LV_Spells:
    selectedSpell := 0
    if (A_GuiEvent = "DoubleClick") {
        goto, EditAttackSpell
    }
    If (A_GuiEvent = "RightClick") {
        _AttackSpell.toggleSpell()
    }
return


spellCreatureCount:
    Gui, AdvancedSpellGUI:Submit, NoHide
    if (spellCreatureCount = "Any") {
        GuiControl, AdvancedSpellGUI:Disable, spellCreatureCountMethod
        GuiControl, AdvancedSpellGUI:Disable, spellCreatureCountPolicy
    } else {
        GuiControl, AdvancedSpellGUI:Enable, spellCreatureCountMethod
        GuiControl, AdvancedSpellGUI:Enable, spellCreatureCountPolicy
    }
    if (creatureNameSpell = TargetingSystem.defaultCreature)
        GuiControl, AdvancedSpellGUI:Disable, spellCreatureCountPolicy
return

spellType:
    Gui, AdvancedSpellGUI:Submit, NoHide
    if (spellType = "Attack") {
        GuiControl, AdvancedSpellGUI:Hide, supportSpellText
        GuiControl, AdvancedSpellGUI:Hide, spellSupportSpell
        GuiControl, AdvancedSpellGUI:Show, cooldownSpellText
        GuiControl, AdvancedSpellGUI:Show, spellCooldownSpell
    } else {
        GuiControl, AdvancedSpellGUI:Show, supportSpellText
        GuiControl, AdvancedSpellGUI:Show, spellSupportSpell
        GuiControl, AdvancedSpellGUI:Hide, cooldownSpellText
        GuiControl, AdvancedSpellGUI:Hide, spellCooldownSpell
    }
return


spellFilter:
    AttackSpell.updateSpellListByFilter()
return

; not used
spellCooldownSpell:
    GuiControlGet, spellCooldownSpell
    GuiControl, AdvancedSpellGUI:, spellCooldownSpell, % "|"

    ; msgbox, % spellCooldownSpell
    if (spellCooldownSpell = "") {
        GuiControl, AdvancedSpellGUI:, spellCooldownSpell, % AttackSpell.cooldownAllSpellsDropdown
        ; GuiControl, AdvancedSpellGUI:ChooseString, spellCooldownSpell, % "Default"
        return
    }

    dropdownOptions := ""
    for key, value in AttackSpell.cooldownAllSpells
    {
        if (spellCooldownSpell = value) {
            GuiControl, AdvancedSpellGUI:, spellCooldownSpell, % AttackSpell.cooldownAllSpellsDropdown
            GuiControl, AdvancedSpellGUI:ChooseString, spellCooldownSpell, % value
            return
        }
        if (InStr(spellCooldownSpell, value))
            dropdownOptions .= value "|"

    }
    if (dropdownOptions = "") {
        GuiControl, AdvancedSpellGUI:, spellCooldownSpell, % AttackSpell.cooldownAllSpellsDropdown
        return
    }

    GuiControl, AdvancedSpellGUI:, spellCooldownSpell, % dropdownOptions


return

spellMode:
    Gui, AdvancedSpellGUI:Submit, NoHide
    switch spellMode {
        case 1:
            Loop 9 {
                if (A_Index = 5)
                    continue
                GuiControl, AdvancedSpellGUI:, SQMMagiaMonstro_%A_Index%, 0
                GuiControl, AdvancedSpellGUI:Disable, SQMMagiaMonstro_%A_Index%
            }
            ; case 2:
            ;     Loop 9 {
            ;         if (A_Index = 5)
            ;             continue
            ;         GuiControl, AdvancedSpellGUI:, SQMMagiaMonstro_%A_Index%, 1
            ;         GuiControl, AdvancedSpellGUI:Enable, SQMMagiaMonstro_%A_Index%
            ;     }
        case 2:
            GuiControl, AdvancedSpellGUI:, SQMMagiaMonstro_1, 0
            GuiControl, AdvancedSpellGUI:Disable, SQMMagiaMonstro_1
            GuiControl, AdvancedSpellGUI:, SQMMagiaMonstro_2, 1
            GuiControl, AdvancedSpellGUI:Enable, SQMMagiaMonstro_2
            GuiControl, AdvancedSpellGUI:, SQMMagiaMonstro_3, 0
            GuiControl, AdvancedSpellGUI:Disable, SQMMagiaMonstro_3
            GuiControl, AdvancedSpellGUI:, SQMMagiaMonstro_4, 1
            GuiControl, AdvancedSpellGUI:Enable, SQMMagiaMonstro_4
            GuiControl, AdvancedSpellGUI:, SQMMagiaMonstro_6, 1
            GuiControl, AdvancedSpellGUI:Enable, SQMMagiaMonstro_6
            GuiControl, AdvancedSpellGUI:, SQMMagiaMonstro_7, 0
            GuiControl, AdvancedSpellGUI:Disable, SQMMagiaMonstro_7
            GuiControl, AdvancedSpellGUI:, SQMMagiaMonstro_8, 1
            GuiControl, AdvancedSpellGUI:Enable, SQMMagiaMonstro_8
            GuiControl, AdvancedSpellGUI:, SQMMagiaMonstro_9, 0
            GuiControl, AdvancedSpellGUI:Disable, SQMMagiaMonstro_9
    }

return



addCreatureToTargetList:
    try
        TargetingHandler.addToTargetList()
    catch e {
        ; Msgbox, 48, % A_ThisLabel, % e.Message "`n"
        if (A_IsCompiled)
            Msgbox, 48, % A_ThisLabel, % e.Message, 2
        else
            Msgbox, 48, % A_ThisLabel, % e.Message "`n" e.What "`n" e.File "`n" e.Line
        return
    }
return

AddNewCreatureToList:
    try CreaturesHandler.addCreatureToCreaturesList()
    catch e {
        Msgbox, 48,, % e.Message, 4
        Goto, AddNewCreatureToList
    }
return



SearchCreatureList:
    SetTimer, SearchCreatureListTimer, Delete
    SetTimer, SearchCreatureListTimer, -300
return

SearchCreatureListTimer:
    TargetingGUI.filterCreatureList()
return

showAllCreaturesList:
    GuiControlGet, showAllCreaturesList
    SetTimer, SearchCreatureListTimer, Delete
    SetTimer, SearchCreatureListTimer, -100
return

;getCreatureImage:
getCreatureImage:
    try {
        switch TargetingSystem.targetingJsonObj.options.getCreatureImageManually {
            case true:
                TargetingHandler.getCreatureImage()
            default:
                TargetingHandler.getCreatureImageAttacking()
        }
    } catch e {
        OldBotSettings.enableGuisLoading()
        Msgbox, 48,, % e.Message, 10
    }
return

testCreature:
    try {
        TargetingHandler.testCreatureImage()
    } catch e {
        msgbox, 48,, % e.Message, 10
    }
return


spellCooldown:
    GuiControlGet, spellCooldown
    check_control := Func("CheckEditValue").bind("spellCooldown", 100, 999999, "AdvancedSpellGUI")
    SetTimer, % check_control, Delete
    SetTimer, % check_control, -700
return

spellMana:
    GuiControlGet, spellMana
    check_control := Func("CheckEditValue").bind("spellMana", 0, 99, "AdvancedSpellGUI")
    SetTimer, % check_control, Delete
    SetTimer, % check_control, -700
return

spellTargetLife:
    GuiControlGet, spellTargetLife
    check_control := Func("CheckEditValue").bind("spellTargetLife", 0, 100, "AdvancedSpellGUI")
    SetTimer, % check_control, Delete
    SetTimer, % check_control, -700
return

spellRune:
    SetTimer, deleteSpellHotkey, Delete
    SetTimer, deleteSpellHotkey, -300
return

deleteSpellHotkey:
    GuiControlEdit("AdvancedSpellGUI", "spellHotkey", "")
return

deleteSpellRune:
    GuiControl, AdvancedSpellGUI:ChooseString, spellRune, % A_Space
return

SaveAttackSpell:
    ; selectedSpell :=  _ListviewHandler.getSelectedItemOnLV("LV_Spells", 1)
    try
        AttackSpell.saveSpell(selectedSpell)
    catch e {
        Gui, AdvancedSpellGUI:Default
        gui, hide
        Msgbox, 48,, % e.Message
        gui, Show
    }
    TargetingGUI.checkSpellIconLV()
return

moveAttackSpell:
    changeButton("CavebotGUI", A_GuiControl, action := "Disable")
    direction := StrReplace(A_GuiControl, "moveSpell", "")
    AttackSpell.moveSpell(direction)
    changeButton("CavebotGUI", A_GuiControl, action := "Enable")
return

addNewMonsterGUI:
    TargetingGUI.addNewMonsterGUI()
return

addNewMonsterGUIGUIGuiEscape:
addNewMonsterGUIGUIGuiClose:
    Gui, addNewMonsterGUIGUI:Destroy
return

AddCreatureGUI:
    TargetingGUI.createAddCreatureGUI()
return
AddCreatureGUIGuiEscape:
AddCreatureGUIGuiClose:
    Gui, AddCreatureGUI:Destroy
return


TargetingTab:
return

TargetingGUIGuiClose:
    Gui, CavebotGUI:Destroy
    Gui, advancedConfigTargeting:Destroy
    Gui, WhatIsEmptyBattleWindowPicture:Destroy
    Gui, WhatIsLootingType:Destroy
    Gui, WhatIsAttackMode:Destroy
    Gui, WhatIsCombatMode:Destroy
    Gui, WhatIsIgnorarTargetApos:Destroy
    Gui, WhatIsspellOneMonster:Destroy
    Gui, AdvancedSpellGUI:Destroy
    Gui, WhatIsPressionarHotkeyTargetNaoListado:Destroy
    Gui, WhatIsEquiparRing:Destroy
    Gui, WhatIsPararAtaqueVida:Destroy
    Gui, WhatIsExetaResLowLife:Destroy
    Gui, WhatIsManterDistanciaVida:Destroy
    Gui, WhatIsEquiparAmulet:Destroy
    Gui, WhatIsFecharTextBoxes:Destroy
    Gui, WhatIsIgnoreUnreachableTarget:Destroy
    Gui, MonstroImagemGUI:Destroy
    Gui, InformacoesMonstrosGeralGUI:Destroy
    Gui, InfoAntiKS:Destroy

return


TargetingGUI:
    gosub, CarregandoCavebotGUI
    selected_GUI := "Targeting"
    Goto, MainGUI
return



WhatIsAttackAllMonstersMode:
    Gui, WhatIsAttackAllMonstersMode:Destroy
    Gui, WhatIsAttackAllMonstersMode:+AlwaysOnTop +Owner -MinimizeBox
    Gui, WhatIsAttackAllMonstersMode:Add, Text, x10 y5 w350 -VScroll -HScroll ReadOnly, % LANGUAGE = "PT-BR" ? ""
        . "Modo em fase BETA.`n`n"
        . "Nesse modo, o ataque individual por cada monstro é ignorado, e o bot irá clicar na primeira posição do Battle List, para atacar o que aparecer no Battle List quando não for encontrado vazio."
        . "`n`nDessa forma, é possível atacar monstros/targets que não estão cadastrados no Targeting, porém trazendo mais limitações de configurações, todas a configurações de ataque são feitas no montro " """default""" "  no Targeting."
        . "`n`nATENÇÃO: O Battle List deve estar configurado para mostrar SOMENTE os monstros, caso contrário o bot irá tentar atacar Players e NPCs se aparecerem na primeira posição do Battle List."
        . "" : ""
        . "Mode in BETA phase.`n`n"
        . "In this mode, the individual attack by monster is ignored, and the bot will click on the first position of the Battle List, to attack whatever appears in the Battle List when it is not found empty."
        . "`n`nIn this way, it is possible to attack monsters/targets that are not registered in the Targeting, however bringing more limitations of settings, all the attack settings are done in the " """default""" " on Targeting."
        . "`n`nATTENTION: The Battle List must be configured to show ONLY monsters, otherwise the bot will try to attack Players and NPCs if they appear in the first position of the Battle List."
    ; Gui, WhatIsAttackAllMonstersMode:Add, Picture, x10 y+5, Data\Files\Images\GUI\Targeting e Looter\Tutorial_LootValiosoPicture.png
    Gui, WhatIsAttackAllMonstersMode:Show,,% LANGUAGE = "PT-BR" ? "Modo de ataque qualquer monstro" : "Attack mode any monster"
return
WhatIsAttackAllMonstersModeGuiEscape:
WhatIsAttackAllMonstersModeGuiClose:
    Gui, WhatIsAttackAllMonstersMode:Destroy
return


AdvancedSpellGUI:
    _AttackSpellsGUI.createAdvancedSpellGUI()
return
AdvancedSpellGUIGuiEscape:
AdvancedSpellGUIGuiClose:
    Gui, AdvancedSpellGUI:Destroy
return


CopyAttackSpellGUI:
    Gui, CopySpellGUI:Destroy
    Gui, CopySpellGUI:-MinimizeBox +AlwaysOnTop

    Path = Cavebot\%currentScript%\Monstros\*.png

    monsterList := ""
    monstersArray := {}

    reached_limit := false

    Spell := new _AttackSpell()
    Loop, %Path% {
        StringReplace, Monstro, A_LoopFileName, .png,, All
        StringReplace, Monstro, Monstro, %A_Space%,_, All
        ; if (Monstro = selectedMonster)
        ; continue
        Spell.readSpell(Monstro, 1)
        if (%Monstro%_hotkeymagia1 = "")
            continue
        monstersArray.Push(Monstro)
        if (A_Index > 20) {
            reached_limit := true
            break
        }
    }
    if (monstersArray.MaxIndex() < 1) {
        Msgbox, 64,, % LANGUAGE = "PT-BR" ? "Não há outros monstros com magias para copiar." : "There are no other monsters with spells to copy the spells."
        return
    }

    Gui, AdvancedSpellGUI:Destroy

    for key, value in monstersArray
        monsterList .= value "|"
    Gui, CopySpellGUI:Add, Text, x10 y+5, % LANGUAGE = "PT-BR" ? "Copiar magias de outro monstro:" : "Copy spells from another monster:"
    Gui, CopySpellGUI:Add, Listbox, x10 y+5 w190 vMonsterCopySpells, %monsterList%

    if (reached_limit = true) {
        Gui, CopySpellGUI:Font, cGray
        Gui, CopySpellGUI:Add, Text, x10 y+5, % LANGUAGE = "PT-BR" ? "Limite de 20 monstros na lista." : "Limit of 20 monsters in the list."
        Gui, CopySpellGUI:Font, norm
        Gui, CopySpellGUI:Font,
    }
    Gui, CopySpellGUI:Add, Button, xp+0 y+7 w120 h25 gCopyAttackSpell hwndAdicionarMagia_Button 0x1, % LANGUAGE = "PT-BR" ? "Copiar magias" : "Copy spells"
    GuiButtonIcon(AdicionarMagia_Button, "shell32.dll", 297, "a0 l5 s20 b2")

    Gui, CopySpellGUI:Show,,% LANGUAGE = "PT-BR" ? "Copiar magias de ataque" : "Copy attack spells"
    if (MonsterCopySpells = "")
        MonsterCopySpells := monstersArray[1]
    GuiControl, CopySpellGUI:ChooseString, MonsterCopySpells, % MonsterCopySpells
return


AddAttackSpell:
    selectedSpell := 0
    goto, AdvancedSpellGUI


spellHotkey:
    GuiControlGet, spellHotkey
    vars := ValidateHotkey("AdvancedSpellGUI", "spellHotkey", spellHotkey)
    if (vars["erro"] > 0) {
        spellHotkey := A_Space
        msgbox, 64,, % vars["msg"]
        return
    }

    SetTimer, deletespellRune, Delete
    SetTimer, deletespellRune, -200
return



CloneAttackSpells:
    Gui, CavebotGUI:Default
    Gui, CavebotGUI:Submit, NoHide
    try GuiControlGet, creatureNameSpell
    catch {
    }
    ; if (targetingObj.targetList[creatureNameSpell].attackSpells.count() < 1) {
    ;     Msgbox, 64,, % "This creature has no attack spells."
    ;     return
    ; }

    Gui, CopySpellGUI:Destroy
    Gui, CopySpellGUI:-MinimizeBox +AlwaysOnTop

    Gui, CopySpellGUI:Add, Text, x10 y+5, % "Select the creatures to copy to:"
    Gui, CopySpellGUI:Add, Checkbox, x10 y+5 vselectAllCreatures gselectAllCreatures, % "Select all"
    index := 0
    for creatureName, atributes in targetingObj.targetList
    {
        if (creatureName = creatureNameSpell)
            continue
        if (index > 24)
            break
        varName := StrReplace(creatureName, " ", "_")
        try Gui, CopySpellGUI:Add, Checkbox, x10 y+5 vchecked_%varName%, % creatureName
        catch e {
            if (!A_IsCompiled)
                Msgbox, % e.Message "`n" e.What "`n" e.File "`n" e.Line
        }
        index++
    }


    Gui, CopySpellGUI:Add, Button, xp+0 y+7 w120 h25 gCopySpells 0x1, % "Clone spells"
    Gui, CopySpellGUI:Show,,% "Clone attack spells"
return

CopySpellGUIGuiEscape:
CopySpellGUIGuiClose:
    Gui, CopySpellGUI:Destroy
return


selectAllCreatures:
    Gui, CopySpellGUI:Submit, NoHide
    for creatureName, atributes in targetingObj.targetList
    {
        varName := StrReplace(creatureName, " ", "_")
        GuiControl, CopySpellGUI:, checked_%varName%, % selectAllCreatures
    }
return

CopySpells:
    Gui, CopySpellGUI:Submit, NoHide
    Gui, CopySpellGUI:Destroy



    if (creatureNameSpell = "") {
        Msgbox, 64,, % "Select a creature to clone the spells from."
        return
    }

    selectedCreatures := {}
    for creatureName, atributes in targetingObj.targetList
    {
        varName := StrReplace(creatureName, " ", "_")
        if (checked_%varName% = 1)
            selectedCreatures.Push(creatureName)
        checked_%varName% := 0
    }

    if (selectedCreatures.Count() < 1)
        return


    for key, creatureName in selectedCreatures
    {
        /**
        CAN't do targetingObj.targetList[creatureName].attackSpells := targetingObj.targetList[creatureNameSpell].attackSpells
        because for some reason every change made on spells of the original creature are
        being changed in the other creatures also
        */
        targetingObj.targetList[creatureName].attackSpells := {}
        for key2, spell in targetingObj.targetList[creatureNameSpell].attackSpells
            targetingObj.targetList[creatureName].attackSpells.Push(spell)
    }
    ; msgbox, % "@@@@ " serialize(targetingObj.targetList[creatureName].attackSpells)
    TargetingHandler.saveTargetList(A_ThisFunc)

    TargetingGUI.loadTargetListLV(true)
return

creatureImageWidth:
    GuiControlGet, creatureImageWidth
    IniWrite, %creatureImageWidth%, %DefaultProfile%, targeting, creatureImageWidth
return

tutorialButtonTargeting:
    openURL(LinksHandler.Targeting.tutorial)
return