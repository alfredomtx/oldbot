
#IfWinActive Action Script - 
^Esc::
+Esc::
    Gui, ActionScriptGUI:Default
    Gui, Destroy
return
^s:: _ActionScriptGUI.INSTANCE.saveActionScript()
^+s:: _ActionScriptGUI.INSTANCE.saveAndClose()
; ^z::
;     Gui, ActionScriptGUI:Default
;     Goto, ReverterActionScript
^d::
    Gui, ActionScriptGUI:Default
    Goto, DeleteLastLineActionScript


    #If
