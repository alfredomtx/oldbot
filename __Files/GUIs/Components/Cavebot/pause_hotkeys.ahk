
    new _Groupbox().title("Hotkeys")
    .xs().yadd(20).w(this.guiW - 20).r(3)
    .section()
    .add()

pauseText := txt("Hotkey para ### o módulo do Cavebot(inclui também o Targeting e Looting).`nA hotkey é disparada somente se a janela do bot ou do Tibia estiver ativa.", "Hotkey to ### the Cavebot module(includes also Targeting and Looting).`nThe hotkey is triggered only if the bot or Tibia window is active.")

    new _Text().title("Hotkey Pausar Cavebot", "Cavebot Pause Hotkey", ":")
    .xs(10).ys(+20)
    .tt(StrReplace(pauseText, "###", txt("pausar", "pause")))
    .add()

    new _Hotkey().name("pauseHotkey")
    .x().w(this.editW)
    .parent()
    .rule(new _ControlRule().rule(_ControlRule.NOT_EMPTY))
    .add()

    new _Text().title("Hotkey Despausar Cavebot", "Cavebot Unpause Hotkey", ":")
    .xs(10).yadd(10)
    .tt(StrReplace(pauseText, "###", txt("despausar", "unpause")))
    .add()

    new _Hotkey().name("unpauseHotkey")
    .x().w(this.editW)
    .parent()
    .rule(new _ControlRule().rule(_ControlRule.NOT_EMPTY))
    .add()