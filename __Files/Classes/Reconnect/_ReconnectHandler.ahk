
global accountEmail1
global accountEmail2
global accountEmail3
global characterListPosition1
global characterListPosition2
global characterListPosition3
global loginTwoFactor
global autoReconnectAccount

global accountPassword1
global accountPassword2
global accountPassword3

Class _ReconnectHandler
{
    __New()
    {
        global

        IniRead, autoReconnect, %DefaultProfile%, settings, autoReconnect, 0
        reconnectObj.autoReconnect := autoReconnect
        IniRead, LoginHotkey1, %DefaultProfile%, settings, LoginHotkey1, 0
        IniRead, LoginHotkey2, %DefaultProfile%, settings, LoginHotkey2, 0

        IniRead, autoReconnectAccount, %DefaultProfile%, accountsettings, autoReconnectAccount, 1
        IniRead, accountEmail1, %DefaultProfile%, accountsettings, accountEmail1, %A_Space%
        IniRead, accountPassword1, %DefaultProfile%, accountsettings, accountPassword1, %A_Space%
        IniRead, characterListPosition1, %DefaultProfile%, accountsettings, characterListPosition1, 1
        IniRead, loginTwoFactor, %DefaultProfile%, accountsettings, loginTwoFactor, 0

        IniRead, accountEmail2, %DefaultProfile%, accountsettings, accountEmail2, %A_Space%
        IniRead, accountPassword2, %DefaultProfile%, accountsettings, accountPassword2, %A_Space%
        IniRead, characterListPosition2, %DefaultProfile%, accountsettings, characterListPosition2, 1

        IniRead, accountEmail3, %DefaultProfile%, accountsettings, accountEmail3, %A_Space%
        IniRead, accountPassword3, %DefaultProfile%, accountsettings, accountPassword3, %A_Space%
        IniRead, characterListPosition3, %DefaultProfile%, accountsettings, characterListPosition3, 1


    }


    setAutoReconnect(value) {
        reconnectObj.autoReconnect := value += 0
        this.saveReconnect()

    }


    saveAccountInfo(accountNumber, email := "", password := "") {
        if (email = "")
            IniWrite, % "", %DefaultProfile%, accountsettings, accountEmail%accountNumber%
        if (password = "")
            IniWrite, % "", %DefaultProfile%, accountsettings, accountPassword%accountNumber%

        if (email = "" OR password = "") {
            try TrayTipMessage("Account " accountNumber " info", "Successfully saved.")
            catch {
            }
            return
        }

        if (StrLen(email) < 4)
            throw Exception("E-mail is too short, less than 4 characters.")

        if (StrLen(password) < 4)
            throw Exception("Password is too short, less than 4 characters.")

        ; if (!RegExMatch(email,"(@|.)"))
        ; throw Exception("Invalid e-mail.")

        emailEncrypted := Encryptor.encrypt(email)

        try passwordEncrypted := Encryptor.encryptPassword(email, password)
        catch e 
            throw e

        ; msgbox, % accountNumber "`n" email " / " password "`n`n" emailEncrypted " / " passwordEncrypted

        IniWrite, % emailEncrypted, %DefaultProfile%, accountsettings, accountEmail%accountNumber%
        IniWrite, % passwordEncrypted, %DefaultProfile%, accountsettings, accountPassword%accountNumber%

        try TrayTipMessage("Account " accountNumber " info", "Successfully saved.")
        catch {
        }

    }


    saveReconnect(saveCavebotScript := true) {
        scriptFile.reconnect := reconnectObj
        if (saveCavebotScript = true)
            CavebotScript.saveSettings(A_ThisFunc)
    }




}