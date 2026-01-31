

/*
WindowsMenu 
*/
iconNumber := (isWin11() = true) ? 234 : 233
Menu, WindowsMenu, Add, % txt("Mostrar janela de &funções`tShift+F11", "Show &functions window`tShift+F11"), MenuHandler
try Menu, WindowsMenu, Icon, % txt("Mostrar janela de &funções`tShift+F11", "Show &functions window`tShift+F11"), imageres.dll, %iconNumber%,16
catch {
}

Menu, WindowsMenu, Add


iconNumber := (isWin11() = true) ? 235 : 234
Menu, WindowsMenu, Add, % LANGUAGE = "PT-BR" ? "&Ativar Always On Top`tShift+F9" : "&Activate Always On Top`tShift+F9", MenuHandler
try Menu, WindowsMenu, Icon, % LANGUAGE = "PT-BR" ? "&Ativar Always On Top`tShift+F9" : "&Activate Always On Top`tShift+F9", imageres.dll, %iconNumber%,16
catch {
}

iconNumber := (isWin11() = true) ? 227 : 226
Menu, WindowsMenu, Add, % LANGUAGE = "PT-BR" ? "Esconder interface`tShift+F10" : "Hide interface`tShift+F10", MenuHandler
try Menu, WindowsMenu, Icon, % LANGUAGE = "PT-BR" ? "Esconder interface`tShift+F10" : "Hide interface`tShift+F10", imageres.dll, %iconNumber%,16
catch {
}

iconNumber := (isWin11() = true) ? 334 : 333
Menu, WindowsMenu, Add, % "&" txt("Transparência`tShift+F12", "Transparency`tShift+F12"), MenuHandler
try Menu, WindowsMenu, Icon,  % "&" txt("Transparência`tShift+F12", "Transparency`tShift+F12"), imageres.dll, %iconNumber%,16
catch {
}
