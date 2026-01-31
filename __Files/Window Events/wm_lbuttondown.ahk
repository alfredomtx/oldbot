OnMessage(0x201, "WM_LBUTTONDOWN")

WM_LBUTTONDOWN()
{
    PostMessage, 0xA1, 2 ; 0xA1 = WM_NCLBUTTONDOWN
    if (!_GUI.INSTANCES.HasKey(A_Gui)) {
        return
    }

    instance := _GUI.INSTANCES[A_Gui]
    fn := instance.savePosition.bind(instance)
    SetTimer, % fn, Delete
    SetTimer, % fn, -200
    SetTimer, % fn, -500
    SetTimer, % fn, -1000
}
