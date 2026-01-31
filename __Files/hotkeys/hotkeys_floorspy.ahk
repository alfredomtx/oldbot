#If


#if (floorSpyEnabled = 0) && (OldBotSettings.uncompatibleModule("floorSpy") = false) && (WinActive("ahk_class AutoHotkeyGUI") OR WinActive("ahk_id " TibiaClientID))
^+MButton:: FloorSpy.enableFloorSpy()
^!MButton:: FloorSpy.enableFloorSpy()
^!Space:: FloorSpy.enableFloorSpy()
#if

#if (floorSpyEnabled = 1) && (OldBotSettings.uncompatibleModule("floorSpy") = false) && (WinActive("ahk_class AutoHotkeyGUI") OR WinActive("ahk_id " TibiaClientID))
^!Space:: FloorSpy.disableFloorSpy()

/*
Arrow keys
*/
^!Up:: FloorSpy.setSpyDirection("Up", true)
^!Down:: FloorSpy.setSpyDirection("Down", true)
^!Left:: FloorSpy.setSpyDirection("Left", true)
^!Right:: FloorSpy.setSpyDirection("Right", true)

/*
WASD
*/
^!w:: FloorSpy.setSpyDirection("Up", true)
^!s:: FloorSpy.setSpyDirection("Down", true)
^!a:: FloorSpy.setSpyDirection("Left", true)
^!d:: FloorSpy.setSpyDirection("Right", true)

/**
Numpad
*/
^!NumpadAdd:: FloorSpy.setSpyDirection("FloorUp", true)
^!NumpadSub:: FloorSpy.setSpyDirection("FloorDown", true)

^!Numpad8:: FloorSpy.setSpyDirection("Up", true)
^!Numpad2:: FloorSpy.setSpyDirection("Down", true)
^!Numpad4:: FloorSpy.setSpyDirection("Left", true)
^!Numpad6:: FloorSpy.setSpyDirection("Right", true)

/**
Mouse
*/
^!MButton:: FloorSpy.disableFloorSpy()
^+MButton:: FloorSpy.disableFloorSpy()

^!XButton1:: FloorSpy.setSpyDirection("FloorDown", true)
^!XButton2:: FloorSpy.setSpyDirection("FloorUp", true)

^+WheelUp:: FloorSpy.setSpyDirection("FloorDown", true)
^+WheelDown:: FloorSpy.setSpyDirection("FloorUp", true)

^!WheelUp:: FloorSpy.setSpyDirection("Up", true)
^!WheelDown:: FloorSpy.setSpyDirection("Down", true)
^!WheelLeft:: FloorSpy.setSpyDirection("Left", true)
^!WheelRight:: FloorSpy.setSpyDirection("Right", true)
#if
