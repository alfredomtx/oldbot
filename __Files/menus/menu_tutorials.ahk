
Menu, Sub_Documentacoes, Add, OldBot Docs, OldBotDocsLink
try Menu, Sub_Documentacoes, Icon, OldBot Docs, imageres.dll,77,16
catch {
}

Menu, Sub_Documentacoes, Add, % "AutoHotkey Variables ", ListaVariaveisAutoHotkey
try Menu, Sub_Documentacoes, Icon, % "AutoHotkey Variables ", %A_AhkPath%,0,16
catch {
    try
        Run, Data\AutoHotkey_1.1.32.00_setup.exe
    catch {
        Gui, Carregando:Destroy
        Msgbox, 16,, Erro ao abrir o instalador do AutoHotkey em:`n%A_WorkingDir%\Data\AutoHotkey_1.1.32.00_setup.exe
    }
    Gui, Carregando:Destroy
    Msgbox, 48,, AutoHotkey não está instalado, prossiga com a instalação que foi aberta e clique em OK neste aviso para reabrir o bot.
    Goto, Reload
    return   
}

Menu, Sub_Documentacoes, Add

Menu, Sub_Documentacoes, Add, OldBot Requirements [PT-BR], LinkDocumentacaoRequisitos
try Menu, Sub_Documentacoes, Icon, OldBot Requirements [PT-BR], imageres.dll,100,16
catch {
}

/*
HelpMenu 
*/
Menu, HelpMenu, Add, % LANGUAGE = "PT-BR" ? "Recuperar senha" : "Recover password", AbrirPaginaLogin
Menu, HelpMenu, Add ; with no more options, this is a seperator
if (LANGUAGE = "PT-BR") {
    Menu, HelpMenu, Add, % LANGUAGE = "PT-BR" ? "Licença" : "License", MenuHandler
    Menu, HelpMenu, Add, % LANGUAGE = "PT-BR" ? "Sobre" : "About", MenuHandler
} else {
    Menu, HelpMenu, Add, % LANGUAGE = "PT-BR" ? "Sobre" : "About", MenuHandler
    Menu, HelpMenu, Add, % LANGUAGE = "PT-BR" ? "Licença" : "License", MenuHandler

}



/*
InfoMenu 
*/
Menu, InfoMenu, Add, % LANGUAGE = "PT-BR" ? "Documentações" : "Documentation", :Sub_Documentacoes
try Menu, InfoMenu, Icon, % LANGUAGE = "PT-BR" ? "Documentações" : "Documentation", imageres.dll,77,16
catch {
}

; Menu, InfoMenu, Add, % LANGUAGE = "PT-BR" ? "Ajuda" : "Help", :HelpMenu
;     try Menu, InfoMenu, Icon, % LANGUAGE = "PT-BR" ? "Ajuda" : "Help", shell32.dll,161,16

if (!A_IsCompiled) && (show_list_vars = true)
    Menu, InfoMenu, Add, ListVars, ListVarsLabel


