Class _ScriptRestriction {


    createRestrictionGUI() {
        global 

        local w_gui, w

        w_gui := 300

        scriptOwner := this.getScriptOwner()
        scriptUser := this.getScriptUser()


        Gui, manageScriptRestrictionGUI:Destroy
        Gui, manageScriptRestrictionGUI:-MinimizeBox
        Gui, manageScriptRestrictionGUI:Add, Text, x10 y+5, % "Script Owner:"
        Gui, manageScriptRestrictionGUI:Add, Edit, x80 yp-2 w200 h18 ReadOnly -VScroll -HScroll, % (scriptOwner = "") ? "None" : scriptOwner
        Gui, manageScriptRestrictionGUI:Add, Text, x10 y+7, % "Script User:"
        Gui, manageScriptRestrictionGUI:Add, Edit, x80 yp-2 w200 h18 ReadOnly -VScroll -HScroll, % (scriptUser = "") ? "None" : scriptUser



        Gui, manageScriptRestrictionGUI:Add, Text, x10 y+15, % txt("Restringir script ao Usuário:", "Rescrict script to User:")
        Gui, manageScriptRestrictionGUI:Add, Edit, x10 y+3 w200 h18 vscriptUserEmail, % scriptUserEmail
        w := w_gui - 20

        Disabled1 := (scriptUser != "") ? "Disabled" : ""
        Disabled2 := (scriptOwner != "" && this.isScriptOwner() = false) ? "Disabled" : ""

        Gui, manageScriptRestrictionGUI:Add, Button, x10 y+5 g_restrictScript %Disabled1% %Disabled2%, % txt("Restringir script", "Restrict script")

        ; Gui, manageScriptRestrictionGUI:Add, Button, x+5 yp+0 %Disabled2%, % LANGUAGE = "PT-BR" ? "Remover restrição do script" : "Remove script restriction"

        Gui, manageScriptRestrictionGUI:Font, cGray
        if (LANGUAGE = "PT-BR") {
            Gui, manageScriptRestrictionGUI:Add, Text, x10 y+15 w%w% Left, % ""
                . "Preencha o email do outro usuário que terá acesso ao script.."
                . " Somente o usuário com esse email terá permissão para carregar e usar o script."
                . "`n"
                . "`n"
                . " Scripts restritos sâo encriptados, e muitas coisas não podem ser vistas ou editadas pelo usuário, somente pelo Owner, como waypoints(Action Scripts)"

        } else {
            Gui, manageScriptRestrictionGUI:Add, Text, x10 y+15 w%w% Left, % ""
                . "Fill the email of the other user that will have access to the script."
                . " Only the user with this e-mail will be allowed to load and use the script."
                . "`n"
                . "`n"
                . "Restricted scripts are encrypted, and many things can't be seen or edited by the user, only by the Owner, such as waypoints(Action Scripts)."
                . "`n"
        }

        Gui, manageScriptRestrictionGUI:Font, norm
        Gui, manageScriptRestrictionGUI:Font, 

        Gui, manageScriptRestrictionGUI:Show, w%w_gui%, % "Restrict script - " currentScript
    }

    restrictScript() {
        Gui, manageScriptRestrictionGUI:Default
        GuiControlGet, scriptUserEmail

        scriptUserEmail := StrReplace(scriptUserEmail, " ", "")

        if (scriptUserEmail = "")
            throw Exception("Fill the e-mail of the user to restrict to.")

        if (StrLen(scriptUserEmail) < 7)
            throw Exception("Invalid user e-mail, too short: " scriptUserEmail)

        if (!RegExMatch(scriptUserEmail,"(@|.)"))
            throw Exception("Invalid user e-mail: " scriptUserEmail)

        if (nnnnnn = 1)
            loginEmail := ""

        if (loginEmail = "")
            throw Exception("Your e-mail login is empty.")

        try CavebotScript.isEncryptedScript(currentScript)
        catch e {
            throw e
        }

        if (CavebotScript.isEncrypted = true)
            throw Exception("Current script is already encrypted, only the uncrypted(original) script can be restricted.")


        scriptNewName := currentScript "_" scriptUserEmail
        scriptNewName := StrReplace(scriptNewName, ".", "_")
        newScriptFile := scriptNewName ".json"
        Msgbox, 68,, % "A new encrypted script .json file will be created with ""_" scriptUserEmail """ in the end of its name:`n`n""" newScriptFile """`n`nContinue?"
        IfMsgBox, No
            return

        scriptFile.scriptOwnerEmail := loginEmail
        scriptFile.scriptUserEmail := scriptUserEmail
        scriptFileObj.scriptOwnerEmail := loginEmail
        scriptFileObj.scriptUserEmail := scriptUserEmail

        try CavebotScript.encryptScript(scriptFile.JSON(true), "Cavebot\" newScriptFile)
        catch e {
            Msgbox, 48, % A_ThisFunc, e.Message "`n" e.What
            return
        } finally {
            /**
            delete the info from the original uncrypted script
            */        
            scriptFile.Delete("scriptOwnerEmail")
            scriptFile.Delete("scriptUserEmail")
            scriptFileObj.Delete("scriptOwnerEmail")
            scriptFileObj.Delete("scriptUserEmail")
        }

        try TrayTipMessage("Script restriction", "Successfully restricted.")
        catch {
        }    
        ; Msgbox, 64,, % "Success."

    }

    setScriptOwner(email := "") {
        if (email = "")
            throw Exception("Empty owner email.")

        scriptFileObj.scriptOwnerEmail := email
        CavebotScript.saveSettings(A_ThisFunc)
    }

    setScriptUser(email := "") {
        if (email = "")
            throw Exception("Empty user email.")
        scriptFileObj.scriptUserEmail := email
        CavebotScript.saveSettings(A_ThisFunc)
    }

    getScriptOwner(scriptName := "") {
        if (scriptName = "")
            scriptName := currentScript

        if (scriptName = currentScript)
            return scriptFileObj.scriptOwnerEmail

        scriptJson := CavebotScript.loadScriptJSON(scriptName)
        if (CavebotScript.isEncrypted = false)
            scriptJsonObj := scriptJson.Object()

        return scriptJsonObj.scriptOwnerEmail
    }

    getScriptUser(scriptName := "") {
        if (scriptName = "")
            scriptName := currentScript

        if (scriptName = currentScript)
            return scriptFileObj.scriptUserEmail


        scriptJson := CavebotScript.loadScriptJSON(scriptName)
        if (CavebotScript.isEncrypted = false)
            scriptJsonObj := scriptJson.Object()

        return scriptJsonObj.scriptUserEmail
    }

    isScriptUser() {

        if (!scriptFileObj.scriptUserEmail)
            return true

        if (nnnnnn = 1)
            loginEmail := ""

        if (loginEmail = this.getScriptUser())
            return true
        return false
    }

    isScriptOwner() {

        if (!scriptFileObj.scriptOwnerEmail)
            return true

        if (nnnnnn = 1)
            loginEmail := ""


        if (loginEmail = this.getScriptOwner())
            return true
        return false
    }

    checkScriptRestriction(showMsgBox := true) {
        if (nnnnnn = 1)
            return
        if (currentScriptRestricted = true) && (this.isScriptOwner() = false) {
            if (showMsgBox = true) {
                Msgbox, 48,,% txt("O Script é restrito, somente o proprietário pode ver e editar isto.", "Script is restricted, only the owner can see and edit this."), 8
            }
            throw Exception("")
        }
    }

    checkAllowedToUse(showMessage := true) {

        ; msgbox, %  currentScriptRestricted " / " this.isScriptOwner() " / " this.isScriptUser() "`n" loginEmail
        ; if (currentScriptRestricted = true) && (this.isScriptOwner() = false) && (this.isScriptUser() = false) {
        if (currentScriptRestricted = true) && (this.isScriptOwner() = false) && (this.isScriptUser() = false) {
            if (LANGUAGE = "PT-BR")
                message := "O script é restrito e você não possui permissão para usá-lo.`nContate o proprietário do script:`n- Proprietário: " this.getScriptOwner() "`n- User permitido: " this.getScriptUser()
            else 
                message := "Script is restricted and you are not allowed to use it.`nContact the script owner:`n- Owner: " this.getScriptOwner() "`n- User allowed: " this.getScriptUser()
            if (showMessage = true) {
                Gui, Carregando:Destroy
                Msgbox, 48,,% message, 20
            }
            throw Exception(message)
        }

    }



}