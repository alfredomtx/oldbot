
Class _TargetingSettingsGUI extends _GUI
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?string title
    */
    __New()
    {
        base.__New("Targeting", "Targeting - " lang("settings"))

        this.guiW := 350
        this.textW := 150
        this.editW := 125

        this.onCreate(this.create.bind(this))
            .y(100).w(this.guiW)
            .withoutMinimizeButton()
        ; .alwaysOnTop()
        ; .withoutWindowButtons()
    }

    /**
    * @abstract
    * @return void
    */
    create()
    {
        _AbstractControl.SET_DEFAULT_GUI(this)
        _AbstractStatefulControl.SET_DEFAULT_STATE(_TargetingSettings)

        this.createControls()

        _AbstractControl.RESET_DEFAULT_GUI()
        _AbstractStatefulControl.RESET_DEFAULT_STATE()
    }

    /**
    * @return void
    */
    createControls()
    {
        this.settings()
        this.iniSettings()
    }

    /**
    * @return void
    */
    settings()
    {
        global


        attackAllMode := targetingObj.settings.attackAllMode
        Disabled := (TargetingSystem.targetingJsonObj.options.disableAttackAllMode = true) ? "Disabled" : ""
        Gui Add, Checkbox, x10 y+10 vattackAllMode gattackAllMode hwndhattackAllMode Checked%attackAllMode% %Disabled%, % txt("Modo de ataque All(todos)", "Attack All mode")
        TT.Add(hattackAllMode, txt("Com esse modo ativo, quando nenhuma criatura adicionada na lista no Targeting for encontrada, o Targeting irá tentar atacar a primeira criatura no Battle List, ao invés de ignorar com a mensagem no log de ""NoCreatureFound"".`n`nAs configurações para essas criaturas são feitas na primeira criatura na lista do Targeting, com o nome de ""all"".`n`nModo em fase de BETA testes, pode haver problemas e melhorias a serem realizadas.",  "With this mode enabled, when no creature added on the list in the Targeting is found, the Targeting will try to attack the first creature on the Battle List, instead of ignoring it with the log message ""NoCreatureFound"".`n`nThe configurations for these creatures are done in the first creature in the Targeting list, with the name ""all"".`n`nMode in BETA test phase, there could be issues and improvements to be made."))

            new _Checkbox().title("Modo de hunt assist", "Hunt assist mode")
            .name("huntAssistMode")
            .xs().yadd(10)
            .tt("Se marcado, o Targeting não irá clicar para atacar as criaturas, irá rodar somente quando você atacar uma criatura manualmente.`nÉ útil para usar como um assistênte de hunt pra você, para usar magias de ataque automaticamente e lootear.", "If checked, the Targeting won't click to attack the creatures, it will run only when you attack a creature manually.`nIt's useful to use as an assist for you when hunting, to cast the attack spells automatically and loot.")
            .add()

        if (LANGUAGE = "PT-BR") {
            antisKsTooltip := ""
                . "Com o Anti-KS ativo, irá procurar por creaturas para atacar somente quando detectado que o seu char está sendo atacado."
                . "`n`nPontos negativos do AntiKS são: menor exp/h já que não irá atacar criaturas imediatamente, lurar mais criaturas enquanto anda pela cave e não recebendo ataques."
        } else {
            antisKsTooltip := ""
                . "With Anti-KS enabled, it will start searching for creatures to attack only if detected that your character is being attacked."
            ; . "`nRecommended to enable whenever possible, since it makes your char looks less like a bot and therefore receive less reports."
                . "`n`nDownsides of the AntiKS are: probably exp/h since it won't attack creatures instantly, lure more creatures while walking through the cave and not receiving attacks."
        }

        options :=_Arr.concat(new _TargetingSettings().getAttribute("antiKs").getValues(), "|")
        if (_Arr.search(options, _AntiKS.STATE_PLAYER_ON_SCREEN)) {
            if (LANGUAGE = "PT-BR") {
                antisKsTooltip .= "`n`nNo modo ""Player on screen"", é ativado o AntiKS somente quando o Battle list de ""Players"" não está vazio(é mais eficiente)."
                    . "`nPara usar o modo ""Player on screen"", é necessário ter um battle list adicional com o nome ""Players"", configurado para mostrar somente players."
            } else {
                antisKsTooltip .= "`n`nOn ""Player on screen"" mode, it enables the anti-KS only when the ""Players"" Battle List is not empty(it's more efficient)."
                    . "`nTo use ""Player on screen"" mode, must have a battle list named ""Players"", configured to show only players."

            }
        }

        Gui Add, Text, % "x10 y+15 w" this.textW " Right Section", Anti-KS:
        this.antiKs := new _Listbox().title(options)
            .name("antiKs")
            .xadd(3).yp(-4).w(this.editW).r(options.Count())
            .afterSubmit(this.afterSubmitAntiKs.bind(this))
            .tt(antisKsTooltip)
            .disabled(disabled := !isTibia13Or14())
            .add()

        if (disabled) {
                new _Text().title("Compatível somente com Tibia 13/14+.", "Only compatible with Tibia 13/14+.")
                .xp(-25).yadd(5)
                .color("Red")
                .option("Right")
                .tt("O Anti-KS é compatível somente com clientes Tibia 13/14+", "The Anti-KS is only compatible with Tibia 13/14+ clients")
                .add()
        }


        ; Gui Add, DDL, % "x+3 yp-4 w" this.editW " vantiKS gantiKS hwndhantiKS Choose" antiKS " AltSubmit", % options
        ; Gui CavebotGUI:Add, Checkbox, x+45 yp+0 , Anti-KS
        ; Gui CavebotGUI:Add, Checkbox, x+5 yp+0 hwndhantiKS Checked%antiKS%, Only with Player
    }

    iniSettings()
    {
        _AbstractStatefulControl.SET_DEFAULT_STATE(_TargetingIniSettings)

        pt := 20

            new _ControlFactory(_ControlFactory.LINE)
            .w(this.guiW - 20)
            .add()

            new _ControlFactory(_ControlFactory.PROFILE_SETTINGS_EDIT)
            .w(this.guiW - 20)
            .add()


            new _Checkbox().title("Randomizar ataque na mesma criatura", "Randomize same creature attack")
            .name("randomizeSameCreatureAttack")
            .xs().yadd(15)
            .tt("Por padrão quando a mesma criatura é encontrado mais de uma vez no Battle List, o Targeting irá atacar a  primeira encontrada, ao marcar essa opção, irá escolher randomicamente qual delas atacar.`nÉ útil para treinar com a mesma criatura quando para de atacar por vida baixa.`n`nOBS: essa opção não tem efeito com o ""Modo de ataque all"" ativo.", "By default when the same creature is found more than once in the Battle List, the Targeting will attack the first one found, by checking this option, it will randomly choose which one to attack`nIt is useful for traning with the same creature when stop attacking by low life.`n`nPS: this option has no effect with ""Attack all mode"" active.")
            .add()

            new _Text().title("Intervalo do Targeting", "Targeting Interval", ":")
            .xs().yadd(15).w(this.textW)
            .option("Right")
            .tt("Intervalo em que o Targeting roda e procura periodicamente por criaturas na tela(battle list limpo), quando encontrado, o Targeting roda e o Cavebot fica pausado.", "Interval in which the Targeting runs and periodically search for creatures on the screen(clear battle list), when found, the Targeting runs and the Cavebot is paused")
            .add()

            new _Edit().name("targetingIntervalTime")
            .x().yp(-2).w(this.editW)
            .rule(new _ControlRule().default(new _TargetingIniSettings().getAttribute("targetingIntervalTime")))
            .numeric()
            .center()
            .parent()
            .add()


            new _Text().title("Anti-KS: " txt("Ataques antes de liberar", "Attacks before releasing") ":")
            .xs().yadd(pt).w(this.textW)
            .option("Right")
            .tt("Quantidade de ataques detectados necessários das criaturas antes de liberar o Targeting e começar a atacar`n`nIsso ajuda a fazer com que o Anti-KS seja mais eficiente para não atacar criaturas de outros, principalmente em criatudas que atacam com magias em área e hitam o seu char quando você está passando por perto delas", "Amount of attacks needed to be detected from the creatures before releasing the Targeting and start attacking`n`nThis helps making the Anti-KS more effective to not attack creatures from others, mainly with creatures that attack with area spells and hits your char when you are crossing near them")
            .disabled(!isTibia13Or14())
            .add()

            new _Dropdown().title(_Arr.concat(new _TargetingIniSettings().getAttribute("antiKsAttacksRelease").getValues(), "|"))
            .name("antiKsAttacksRelease")
            .x().yp(3).w(this.editW)
            .disabled(!isTibia13Or14())
            .parent()
            .add()

            new _Text().title("Método de Ataque", "Attack Method", ":")
            .xs().yadd(pt).w(this.textW)
            .option("Right")
            .tt("Click on Battle é o método padrão de ataque, irá atacar clicando na criatura no Battle List.`nCom o método press key, irá pressionar a tecla definida abaixo, o que é mais rápido", "Click on Battle is the default attack method, it will attack clicking on the creature in the Battle List.`nWith press key method, it will press the hotkey defined below instead, which is faster")
            .tt("")
            .tt("Cuidado! " "Com o método " _Str.quoted(_TargetingIniSettings.ATTACK_METHOD_HOTKEY) " selecionado, a prioridade de criatura por Danger não será considerado, irá sempre atacar a primeira criatura no Battle List. ", "Careful! With " _Str.quoted(_TargetingIniSettings.ATTACK_METHOD_HOTKEY) " method selected, the creature's Danger priority won't be considered, it will always attack the first creature in the Battle List.")
            .add()

            new _Listbox() .title(_Arr.concat(new _TargetingIniSettings().getAttribute("attackMethod").getValues(), "|"))
            .name("attackMethod")
            .x().w(this.editW).r(2)
            .parent()
            .add()


            new _Text().title("Attack hotkey:")
            .xs().yadd(15).w(this.textW)
            .option("Right")
            .tt("Tecla de ataque para o método de ataque " _Str.quoted(_TargetingIniSettings.ATTACK_METHOD_HOTKEY), "Attack hotkey for the " _Str.quoted(_TargetingIniSettings.ATTACK_METHOD_HOTKEY) " attack method")
            .add()

        this.attackHotkey := new _Hotkey().name("attackHotkey")
            .x().yp(-2).h(18).w(this.editW)
            .rule(new _ControlRule().rule(_ControlRule.NOT_EMPTY))
            .parent()
            .add()

            new _Button().title("Space")
            .x().yp().w(50).h(19)
            .event(this.attackHotkey.set.bind(this.attackHotkey, "Space"))
            .tt("Setar a tecla de ataque para ""Espaço""", "Set the attack key to ""Space""")
            .add()
    }

    afterSubmitAntiKs()
    {
        if (!isMiracle74()) {
            return
        }

        if (this.antiKs.get() == _AntiKS.STATE_ENABLED) {
            msgbox, 64, % "Anti-KS", % txt("ATENÇÃO: para o Anti-KS funcionar no Miracle, é necessário sempre ter uma fonte de luz no personagem(tocha, utevo lux, etc).`nCaso contrário, o bot não conseguira identificar os monstros que estão atacando em volta do char e nenhum monstro será atacado.`n`nVocê pode usar ""Distance Weapon Refill"" na aba ""Refill"" para refillar o slot arrow com tocha.", "ATTENTION: for the Anti-KS to work on Miracle, it is necessary to always have a light source on the character(torch, utevo lux, etc).`nOtherwise, the bot will not be able to identify the monsters that are attacking around the char and no monster will be attacked.`n`nYou can use ""Distance Weapon Refill"" in the ""Refill"" tab to refill the arrow slot with torch.")
        }
    }
}
