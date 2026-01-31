class _AttackSpellsGUI extends _BaseClass
{
    static INSTANCE


    __New()
    {
        if (_AttackSpellsGUI.INSTANCE) {
            return _AttackSpellsGUI.INSTANCE
        }

        _AttackSpellsGUI.INSTANCE := this
    }

    createAdvancedSpellGUI()
    {
        global

        _AbstractControl.SET_DEFAULT_GUI_NAME("AdvancedSpellGUI")

        this.createControls()

        w := w_groupbox + 30
        h := 500
        Gui, AdvancedSpellGUI:Show, w%w% h%h%,% (selectedSpell = 0 ? "Add attack spell" : "Edit attack spell [" selectedSpell "]") " - " creatureNameSpell

        _AbstractControl.RESET_DEFAULT_GUI()

        Gosub, spellMode
        Gosub, spellFilter

        this.spellHotkeyText(spellAreaRune)
    }

    createControls()
    {
        global

        Gui, CavebotGUI:Default
        GuiControlGet, creatureNameSpell

        Gui, CopySpellGUI:Destroy
        Gui, AdvancedSpellGUI:Destroy
        Gui, AdvancedSpellGUI:-MinimizeBox +AlwaysOnTop +0x200000
        Gui, AdvancedSpellGUI:Default


            new _Button().title(selectedSpell = 0 ? txt("Adicionar magia", "Add spell") : txt("Salvar magia", "Save spell"))
            .x(10).y(5).w(150).h(25)
            .focused()
            .event("SaveAttackSpell")
            .icon(_Icon.get(_Icon.CHECK), "a0 l5 b0 s15")
            .add()

        w_groupbox := 350
        h_groupbox := !clientHasFeature("cooldownBar") ? 140 : 168
        h_groupbox += 50


        w_text := 120
        x_controls := w_text + 30
        w_controls := w_groupbox - w_text - 35

        if (TargetingSystem.targetingJsonObj.attackSpells.useScriptImageForRunes = true)
            h_groupbox += 30

        Gui, AdvancedSpellGUI:Add, Groupbox, x10 y+10 w%w_groupbox% h%h_groupbox% Section, % LANGUAGE = "PT-BR" ? "Configurações de Spell/Runa" : "Spell/Rune settings"
            new _Checkbox().title("Habilitar magia", "Enable spell")
            .xs(10).yp(25).w(w_text)
            .name("spellEnabled")
            .value(spellEnabled = "" ? 1 : spellEnabled)
            .add()

            new _Text().title("Hotkey:")
            .name("spellHotkeyText")
            .xs(10).yadd(10).w(w_text)
            .option("Right")
            .add()

        Gui, AdvancedSpellGUI:Add, Hotkey, x%x_controls% w%w_controls% yp-3  h21 gspellHotkey vspellHotkey hwndhspellHotkey, % spellHotkey
        TT.Add(hspellHotkey, (LANGUAGE = "PT-BR" ? "Hotkey da magia ou runa para usar." : "Hotkey of the spell or rune to cast."))


        if (TargetingSystem.targetingJsonObj.attackSpells.useScriptImageForRunes = true) {
            runesList := A_Space "|"
            switch TibiaClient.getClientIdentifier() {
                case "medivia":
                    runesList .= ItemsHandler.getItemList("", {1: "Attack Runes", 2: "Wands", 3: "Rods"}, "valuable|eldritch|plain|ornate", "")
                    Gui, AdvancedSpellGUI:Add, Text, xs+10 y+10 w%w_text% Right, Rune/wand:
                default:
                    Gui, AdvancedSpellGUI:Add, Text, xs+10 y+10 w%w_text% Right, % txt("Runa", "Rune", ":")
                    runesList .= ItemsHandler.getItemList("", {1: "Attack Runes"}, "", "")
            }
            ; runesList .= "Rope"

            ; Gui, AdvancedSpellGUI:Add, Edit, x%x_controls% w%w_controls% yp-3 h21 gspellRune vspellRune hwndhspellRune, % spellRune
            Gui, AdvancedSpellGUI:Add, DDL, x%x_controls% w%w_controls% yp-3 gspellRune vspellRune hwndhspellRune, % runesList
            GuiControl, AdvancedSpellGUI:ChooseString, spellRune, % spellRune
            TT.Add(hspellRune, txt("Nome da runa para clicar(use) e depois clicar(atirar) no Targeting atual no Battle List(atirar runa sem hotkey).", "Name of the rune to click(use) on and then click(shoot) on the current Targeting in the Battle List(shoot rune without hotkey)."))
            ; SetEditCueBanner(hspellRune, "Script image name...")

        }


        switch (clientHasFeature("cooldownBar")) {
            case false:
                    new _Text().title("Cooldown (miliseconds):")
                    .xs(10).yadd(10).w(w_text)
                    .option("Right")
                    .add()
                ; Gui, AdvancedSpellGUI:Add, Text, xs+10 y+10 w%w_text% Right, Cooldown:
                Gui, AdvancedSpellGUI:Add, Edit, x%x_controls% w%w_controls% yp-3 vspellCooldown gspellCooldown hwndhspellCooldown h21 0x2000, % spellCooldown = "" ? "2000" : spellCooldown
                TT.Add(hspellCooldown, (LANGUAGE = "PT-BR" ? "Cooldown para esperar antes de usar a próxima magia" : "Cooldown to wait before casting next spell"))
            default:

                Gui, AdvancedSpellGUI:Add, Text, xs+10 y+10 w%w_text% Right, % LANGUAGE = "PT-BR" ? "Tipo:" : "Type:"
                    new _Listbox().name("spellType")
                    .x(x_controls).yp("-3").w(w_controls).r(2)
                    .title("Attack||Support")
                    .disabled(jsonConfig("targeting", "options", "disableCreaturePositionCheck"))
                    .tt("Magias de diferentes tipos tem cooldown diferentes.`n`nMagias de ataque não esperam pelo cooldown de magias de Suporte, e vice versa.", "Different types of spell have different cooldowns`n`nAttack spells don't wait for the cooldown of Support spells, and vice versa.")
                    .event("spellType")
                    .add()

                y := (TargetingSystem.targetingJsonObj.attackSpells.useScriptImageForRunes = true) ? h_groupbox : h_groupbox - 51
                w_spells := w_controls / 2 + 15

                w_filter := abs(w_controls - w_spells) - 3

                yLast := _AbstractControl.getLastAdded().getGuiY()

                    new _Text().title("Cooldown da magia:", "Cooldown of the spell:")
                    .name("cooldownSpellText")
                    .xs(10).y(yLast + 10).w(w_text)
                    .option("Right")
                    .add()
                ; Gui, AdvancedSpellGUI:Add, Text, xs+10 y%y% w%w_text% vcooldownSpellText hwndhcooldownSpellText Right, Cooldown Spell:

                vocationFilter := StrReplace(spellFilter, "Filter: ", "")
                if (vocationFilter = "" OR vocationFilter = "none")
                    vocationFilter := "all"

                Gui, AdvancedSpellGUI:Add, DDL, x%x_controls% w%w_spells% yp-3 vspellCooldownSpell hwndhspellCooldownSpell, % AttackSpell.spellsDropdown[vocationFilter].attack
                TT.Add(hspellCooldownSpell, (LANGUAGE = "PT-BR" ? "Magias de ataque com cooldown acima do padrão de 2 segundos`nAo selecionar a magia, irá respeitar o cooldown da magia"  : "Attack spells with cooldown higher than the Default 2 seconds`nBy selecting the spell, it will respect the cooldown of the spell"))

                Gui, AdvancedSpellGUI:Add, Combobox, x+3 w%w_filter% yp+0 vspellFilter gspellFilter hwndhspellFilter, % "Filter: none||Filter: knight|Filter: paladin|Filter: druid|Filter: sorcerer|"
                GuiControl, AdvancedSpellGUI:ChooseString, spellFilter, % spellFilter
                TT.Add(hspellFilter, txt("Mostrar magias filtradas por vocação", "Show spells filtered by vocation"))

                    new _Text().title("Magia de Suporte", "Support Spell", ":")
                    .name("supportSpellText")
                    .xs(10).y(yLast + 10).w(w_text)
                    .option("Right")
                    .hidden()
                    .add()

                Gui, AdvancedSpellGUI:Add, DDL, x%x_controls% w%w_spells% yp-3 vspellSupportSpell hwndhspellSupportSpell Hidden, % AttackSpell.spellsDropdown[vocationFilter].support
                TT.Add(hspellSupportSpell, txt("Selecione qual magia de Suporte você está usando`nO sistema do Targeting irá respeitar o cooldown da magia especifica", "Select which Support spell you are using`nThe Targeting system will respect the cooldown of this specific spell"))

        }

        Hidden := (uncompatibleFunction("healing", "manaHealing")) ? "Hidden" : ""

        spellMana := spellMana < 0 ? 0 : spellMana
        Gui, AdvancedSpellGUI:Add, Text, xs+10 y+10 w%w_text% Right, % LANGUAGE = "PT-BR" ? "Mana acima %:" : "Mana above %:"
        Gui, AdvancedSpellGUI:Add, Edit, x%x_controls% yp-3 w%w_controls% h21 vspellMana gspellMana hwndhspellMana Limit2 0x2000 %Hidden%, % spellMana
        Gui, AdvancedSpellGUI:Add, Updown, Range0-99, % spellMana
        TT.Add(hspellMana, (LANGUAGE = "PT-BR" ? "Quantidade mínima de mana para usar, se a mana for menor do que o setado, irá pular para a próxima magia." : "Minimum amount of mana to cast, if mana is not lower than set, it will skip to next spell."))


        spellTargetLife := spellTargetLife < 0 ? 0 : spellTargetLife
        Hidden := jsonConfig("targeting", "options", "disableCreatureLifeCheck") ? "Hidden" : ""
        Gui, AdvancedSpellGUI:Add, Text, xs+10 y+10 w%w_text% Right, % LANGUAGE = "PT-BR" ? "Target Life abaixo %:" : "Target Life below %:"
        Gui, AdvancedSpellGUI:Add, Edit, x%x_controls% yp-3 w%w_controls% h21 vspellTargetLife gspellTargetLife hwndhspellTargetLife Limit3 0x2000 %Hidden%, % spellTargetLife
        Gui, AdvancedSpellGUI:Add, Updown, Range0-100, % spellTargetLife
        TT.Add(hspellTargetLife, (LANGUAGE = "PT-BR" ? "Quantidade máxima de vida que a criatura atual que está sendo atacado precisa ter para que a magia seja usada. Exemplo: se colocado 30, a magia será usada somente quando a criatura estiver com MENOS de 30% de vida." : "Maximum amount of life the current creature being attacked must have for the spell to be cast. Example: if put 30, the spell will be used only when the creature has LESS than 30% of life."))


            new _Checkbox().title("Runa em área(avalanche, gfb...)", "Area rune(avalanche, gfb...)")
            .name("spellAreaRune")
            .x("s+10").yadd(10)
            .tt("Com essa opção ativa, quando usando uma runa em área como Avalanche, ao invés de atirar na criatura que está sendo atacada, irá tentar atirar na área que hita a maior quantidade de monstros na tela.`n`nOBS: a hotkey precisa estar configurada como ""Use with crosshair"" no cliente do Tibia para usar essa opção.", "With this option enabled, when using an area rune such as Avalanche, instead of shooting in the creature being attacked, it will try to shoot it in the area that hits the most targets on screen.`n`nPS: the hotkey must be set as ""Use with crosshair"" in the Tibia client to use this option.")
            .value(spellAreaRune = "" ? 0 : spellAreaRune)
            .disabled(jsonConfig("targeting", "options", "disableCreaturePositionCheck"))
            .event(this.areaRuneControl.bind(this))
            .add()


        Gui, AdvancedSpellGUI:Add, Groupbox, x10 y+20 w%w_groupbox% h325 Section, % txt("Condições", "Conditions")


        this.tt := txt("Distância máxima que a criatura pode estar do personagem.`nExemplo: se selecionado 3, não ira usar a magia caso a criatura esteja a 4 ou mais SQMs de distância.", "Maximum distance where the creature can be from the character.`nExample: if selected 3, it won't use the spell in case the creature is at 4 our more SQMs of distance.")

            new _Text().title("Distância da criatura:", "Creature distance:")
            .x("s+10").y("p+25").w(w_text)
            .option("Right")
            .tt(this.tt)
            .add()

        this.sqmDistanceControl := new _Combobox().name("spellSqmDistance")
            .x(x_controls).y("p-3").w(w_controls)
            .disabled(jsonConfig("targeting", "options", "disableCreaturePositionCheck"))
            .tt(this.tt)
            .add()
        this.sqmDistanceControl.list(this.getSqmDistanceList())

        Disabled := ""

        Gui, AdvancedSpellGUI:Add, Text, xs+10 y+15 w%w_text% Right hwndhspellCreatureCountText, % LANGUAGE = "PT-BR" ? "Contagem de criaturas:" : "Creature count:"
        Gui, AdvancedSpellGUI:Add, Combobox, x%x_controls% w%w_controls% yp-3 vspellCreatureCount gspellCreatureCount hwndhspellCreatureCount %Disabled%, Any||Only 1|1+|2+|3+|4+|5+|6+|7+|8+
        TT.Add(hspellCreatureCount, (LANGUAGE = "PT-BR" ? "Quantidade de criaturas para usar a magia, se a quantidade for menor, irá pular para a próxima magia" : "Amount of creatures to cast the spell, if the amount is lower, it will skip to next spell"))

        Gui, AdvancedSpellGUI:Add, Text, xs+10 y+15 w%w_text% Right, % LANGUAGE = "PT-BR" ? "Método de contagem:" : "Count method:"
        Gui, AdvancedSpellGUI:Add, Listbox, x%x_controls% w%w_controls% yp-3 r2 vspellCreatureCountMethod gspellCreatureCountMethod hwndhspellCreatureCountMethod Disabled, Battle list||Around character
        TT.Add(hspellCreatureCountMethod, (LANGUAGE = "PT-BR" ? "Define se irá contar as criaturas no Battle List ou em volta do char." : "Defines if it will count creatures on Battle List or around the char."))


        Gui, AdvancedSpellGUI:Add, Text, xs+10 y+15 w%w_text% Right, % LANGUAGE = "PT-BR" ? "Política de contagem:" : "Count policy:"
        Gui, AdvancedSpellGUI:Add, Listbox, x%x_controls% w%w_controls% yp-3 r2 vspellCreatureCountPolicy hwndhspellCreatureCountPolicy Disabled, All creatures||This creature
        TT.Add(hspellCreatureCountPolicy, (LANGUAGE = "PT-BR" ? "Define se irá considerar todas as criaturas para contar ou somente essa criatura.`n`nExemplo: se há 2 Rotworms e 1 Skeleton, se selecionado ""All creatures"", irá contar 3 criaturas ao invés de 1(supondo que você está adicionado a magia para o Skeleton)" : "Defines if it will consider all creatures in the count or consider only this creature.`n`nExample: if there are 2 Rotworms and 1 Skeleton, if selected ""All creatures"", it will count 3 creatures instead of 1(pretending you are adding a spell for the Skeleton)"))


        Gui, AdvancedSpellGUI:Add, Text, xs+10 y+15 w%w_text% Right, % LANGUAGE = "PT-BR" ? "Criatura em volta:" : "Creature around:"
        Gui, AdvancedSpellGUI:Add, Listbox, x%x_controls% w%w_controls% yp-3 r2 vspellMode gspellMode hwndhspellMode AltSubmit Disabled, [1] Any||[2] Sqms straight to the char
        TT.Add(hspellMode, (LANGUAGE = "PT-BR" ? "Se selecionada a opção 2, irá usar a magina somente se houver pelo menos uma criatura nos sqms em volta do char mostrados" : "If selected option 2, it will cast spell only if there is at least one creature in the sqms shown around the char"))
        ; Gui, AdvancedSpellGUI:Add, Listbox, vspellMode gspellMode AltSubmit xs+10 y+3 r3 w230 Choose%spellMode%, [1] Any||[2] Any sqm around the char|[3] Only at char's straight sqms
        ; press hotkey before clicking add this
        Gui, AdvancedSpellGUI:Add, Radio, vSQMMagiaMonstro_7 +Group x%x_controls% y+4 h35 w40 Disabled, % "NW"
        Gui, AdvancedSpellGUI:Add, Radio, vSQMMagiaMonstro_8 +Group x+3 yp+0 h35 w40 Disabled, % "N"
        Gui, AdvancedSpellGUI:Add, Radio, vSQMMagiaMonstro_9 +Group x+3 yp+0 h35 w40 Disabled, % "NE"
        Gui, AdvancedSpellGUI:Add, Radio, vSQMMagiaMonstro_4 +Group x%x_controls% y+3 h35 w40 Disabled, % "W"
        Gui, AdvancedSpellGUI:Add, Radio, vSQMMagiaMonstro_5 +Group x+3 yp+0 h35 w40 Disabled, C
        Gui, AdvancedSpellGUI:Add, Radio, vSQMMagiaMonstro_6 +Group x+3 yp+0 h35 w40 Disabled, % "E"
        Gui, AdvancedSpellGUI:Add, Radio, vSQMMagiaMonstro_1 +Group x%x_controls% y+3 h35 w40 Disabled, % "SW"
        Gui, AdvancedSpellGUI:Add, Radio, vSQMMagiaMonstro_2 +Group x+3 yp+0 h35 w40 Disabled, % "S"
        Gui, AdvancedSpellGUI:Add, Radio, vSQMMagiaMonstro_3 +Group x+3 yp+0 h35 w40 Disabled, % "SE"

        Gui, AdvancedSpellGUI:Add, Groupbox, x10 y+15 w%w_groupbox% h100 Section, % LANGUAGE = "PT-BR" ? "Opções" : "Options"

        spellturnToDirection := (spellturnToDirection = "") ? 0 : spellturnToDirection
        Disabled := ""
        Gui, AdvancedSpellGUI:Add, Checkbox, xs+10 yp+25 vspellturnToDirection hwndhspellturnToDirection Checked%spellturnToDirection% %Disabled%, % txt("Girar em direção as criaturas", "Turn toward creatures")
        TT.Add(hspellturnToDirection, txt("Gira na direção onde há mais criaturas em volta do char.`nExemplo: se há 1 criatura em baixo e 3 criaturas em cima, irá girar para cima, útil para ""exori min"".", "Turn towards the direction where there are more creatures around the char.`nExample: if there is 1 creature Down and 3 creatures Up, it will turn the char Up, useful for ""exori min"""))


        Disabled := isTibia13() ? "" : "Disabled"

        spellPlayerSafe := (spellPlayerSafe = "") ? 0 : spellPlayerSafe
        Gui, AdvancedSpellGUI:Add, Checkbox, xs+10 y+10 vspellPlayerSafe hwndhspellPlayerSafe Checked%spellPlayerSafe% %Disabled%, % txt("Não usar com player na tela(player safe)", "Don't cast with player on screen(player safe)")
        TT.Add(hspellPlayerSafe, txt("Pular a magia se o Battle List de ""Players"" não estiver vazio.`n`nOBS: Você deve setar o Battle List adicional de ""Players"" para usar essa opção." , "Only use the spell if the ""Players"" Battle List it not empty.`n`nPS: You must set up the additional ""Players"" Battle list to use it"))

        spellOnlyWithPlayer := (spellOnlyWithPlayer = "") ? 0 : spellOnlyWithPlayer
        Gui, AdvancedSpellGUI:Add, Checkbox, xs+10 y+10 vspellOnlyWithPlayer hwndhspellOnlyWithPlayer Checked%spellOnlyWithPlayer% %Disabled%, % txt("Usar somente com player na tela", "Cast only with player on screen")
        TT.Add(hspellOnlyWithPlayer, txt("Usar a magia somente se o Battle List de ""Players"" não estiver vazio. Exemplo de uso: caçando na Avalanche porém com player na tela usar somente Exori Frigo.`n`nOBS: Você deve setar o Battle List adicional de ""Players"" para usar essa opção.", "Use the spell only if the ""Players"" Battle List it not empty. Usage example: hunting with Avalanche but with player on screen use only Exori Frigo.`n`nPS: You must set up the additional ""Players"" Battle list to use it"))
    }

    areaRuneControl(control, value)
    {
        this.spellHotkeyText(value)
    }

    /**
    * @return array<_ListOption>
    */
    getSqmDistanceList()
    {
        list := {}
        list.Push(new _ListOption("Any", true))
        Loop, 7 {
            list.Push(new _ListOption(A_Index))
        }

        return list
    }

    spellHotkeyText(spellAreaRune)
    {
        GuiControl, AdvancedSpellGUI:, spellHotkeyText, % spellAreaRune ? """With Crosshair"" hotkey:" : "Hotkey:"
    }
}