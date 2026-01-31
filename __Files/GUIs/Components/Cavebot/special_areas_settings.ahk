_AbstractStatefulControl.SET_DEFAULT_STATE(_CavebotIniSettings)

    new _Groupbox().title("Special Areas")
    .xs().yadd(20).w(this.guiW - 20).r(5)
    .section()
    .add()

    new _Checkbox().title("Usar Special Areas para caminhar", "Use Special Areas to walk")
    .name("useSpecialAreasToWalk")
    .xs(10).ys(+20)
    .add()

    new _Checkbox().title("Mostrar rota gerada para caminhar", "Show generated path to walk")
    .name("showPath")
    .xs(10).yadd(10)
    .add()


    new _Button().title("Set Special Areas")
    .xs(10).yadd(15).w(120).h(33)
    .event(_SpecialAreasHUD.selectSqms.bind(_SpecialAreasHUD))
    .icon(_Icon.get(_Icon.SQUARES), "a0 l3 s18 b0")
    .add()

    new _ControlFactory(_ControlFactory.SETTINGS_BUTTON)
    .yp().w(26).h(33)
    .event(new _SpecialAreasSettingsGUI().open.bind(new _SpecialAreasSettingsGUI()))
    .icon(_Icon.get(_Icon.SETTINGS), "a0 l1 b0 t1 s18")
    .disabled()
    .add()

