global telegramChatID


Class _Telegram {


    __Init(createWinHTTP := false) {


        IniRead, telegramChatID, %DefaultProfile%, telegram, telegramChatID, %A_Space%
        ; msgbox, % telegramChatID

        this.botToken := "" ; Add your Telegram bot token here

        this.sendFileThreadCounter := 0
        this.sendMessageThreadCounter := 0

        if (createWinHTTP = true)
            this.createHTTPObj()


        this.characterExceptions := {}
        this.characterExceptions.Push(".")
        this.characterExceptions.Push(":")
        this.characterExceptions.Push(",")
        this.characterExceptions.Push("_")
        this.characterExceptions.Push("-")
        this.characterExceptions.Push("|")
        this.characterExceptions.Push("#")
        this.characterExceptions.Push("@")
        this.characterExceptions.Push(")")
        this.characterExceptions.Push("(")


    }

    createHTTPObj() {
        try this.TWinHTTP := ComObjCreate("WinHTTP.WinHttpRequest.5.1")
        catch e {
            throw Exception(e.Message "`n" e.What)
        }

    }


    getSendFileThreadCounter() {
        if (this.sendFileThreadCounter > 9999)
            this.sendFileThreadCounter := 1
        return this.sendFileThreadCounter
    }

    getSendMessageThreadCounter() {
        if (this.sendMessageThreadCounter > 9999)
            this.sendMessageThreadCounter := 1
        return this.sendMessageThreadCounter
    }


    checkChatID() {
        if (telegramChatID = "")
            throw Exception("Chat ID not set.")
    }

    sendFileTelegram(caption, fileFullPath, photo := true, waitThreadFinish := true, logMethod := false) {
        global ; global because of the thread manager

        this.checkChatID()

        if (OldbotSettings.settingsJsonObj.telegram.sendPhotoAsDocument = true)
            photo := false


        if (!FileExist(fileFullPath))
            throw ExceptioN("File doesn't exist:`n" fileFullPath)


        curl := "C:\WINDOWS\SYSTEM32\curl.exe"
        if (!FileExist(curl))
            throw Exception("Curl exe doesn't exist at: " curl)


        if (!this.TWinHTTP)
            this.createHTTPObj()


        caption := removeSpecialCharacters(caption, this.characterExceptions)


        /**
        send picture and video
        */
        TelegramBotToken := this.botToken

        telegramChatID := telegramChatID
        ; msgbox, % telegramChatID

        tempFile := A_Temp "\OldBot\logs_telegram.txt"
        try FileDelete, %tempFile%
        catch {
        }
        Sleep, 25

        sendFileThreadCounter := this.getSendFileThreadCounter()

        threadName := "telegramSendFile"
        ThreadManager.createThread(threadName)

        %threadName%%sendFileThreadCounter%Obj := CriticalObject({"photo": photo, "caption": caption, "logMethod": logMethod, "tempFile": tempFile, "fileFullPath": fileFullPath, "telegramChatID": telegramChatID, "TelegramBotToken": TelegramBotToken})


        %threadName%%sendFileThreadCounter% := AhkThread("
        (

            ; ListVars
            #NoTrayIcon
            #Persistent
            MyObj := CriticalObject(A_Args[1])
            photo := MyObj.photo
            caption := MyObj.caption
            fileFullPath := MyObj.fileFullPath
            telegramChatID := MyObj.telegramChatID
            TelegramBotToken := MyObj.TelegramBotToken
            tempFile := MyObj.tempFile
            logMethod := MyObj.logMethod
            logMethod := logMethod = true ? logMethod : false


            method := photo = true ? ""sendPhoto"" : ""sendDocument""
            fileType := photo = true ? ""photo"" : ""document""
            url = https://api.telegram.org/bot%TelegramBotToken%/%method% -F chat_id=%telegramChatID% -F caption=""%caption%"" -F %fileType%=""@%fileFullPath%""

            command = curl.exe -s -X POST %url%
            ; clipboard := command

            if (logMethod = false) {
                try runwait, %command%, , Hide
                catch {
}
                Sleep, 50
                ExitApp
            }
            
            try OutputDebug, OldBot | sendFileTelegram | %url%
            catch {
}

            ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99
            try shell := ComObjCreate(""WScript.Shell"")
            catch {
}
            ; Execute a single command via cmd.exe
            try exec := shell.Exec(command)
            catch {
}
            Loop, 40 { ; 2 secs
                Sleep, 50
                if (WinExist(""ahk_exe curl.exe"")) {
                    WinHide, ahk_exe curl.exe
                    break
                }
            }
            ; Read and return the command's output
            try stdout := exec.StdOut.ReadAll()
            catch {
}
            FileAppend, % stdout, % tempFile

            try OutputDebug, OldBot | sendFileTelegram | %stdout%
            catch {
}
            Sleep, 50
            ExitApp

        )", &%threadName%%sendFileThreadCounter%Obj "")

        this.sendFileThreadCounter++

        ; msgbox, % "a = " %threadName%%sendFileThreadCounter%.ahkReady()
        if (waitThreadFinish = true) {
            While ThreadManager.checkThreadFinished(threadName "" sendFileThreadCounter, finishThread := false, debug := false) {
                ; ToolTip % "running thread.`n" threadName " = " serialize(%threadName%%sendFileThreadCounter%Obj)
                Sleep, 100
                ; Tooltip
            }
        }


        /**
        if (photo = true)
        runwait, curl.exe -s -X POST https://api.telegram.org/bot%TelegramBotToken%/sendPhoto -F chat_id=%telegramChatID% -F caption="%caption%" -F photo="@%fileFullPath%", , Hide
        else
        runwait, curl.exe -s -X POST https://api.telegram.org/bot%TelegramBotToken%/sendDocument -F chat_id=%telegramChatID% -F caption="%caption%" -F document="@%fileFullPath%", , Hide

        */
    }


    deleteMessage() {
        this.checkChatID()

        if (!this.TWinHTTP)
            this.createHTTPObj()


    }

    sendMessageTelegram(message, icon := "", waitThreadFinish := true) {

        this.checkChatID()

        curl := "C:\WINDOWS\SYSTEM32\curl.exe"
        if (!FileExist(curl))
            throw ExceptioN("Curl exe doesn't exist at: " curl)

        if (!this.TWinHTTP)
            this.createHTTPObj()

        ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=24919



        this.TelegramMsg(icon, 1, message, waitThreadFinish)                      ;icon before text
        ; msgbox, % A_TickCount - t1
        ; this.TelegramMsg(32,2,RandomVariable)                ;icon after text
        ; this.TelegramMsg("%F0%9F%8E%88",2,RandomVariable)    ;own icon
        ; this.TelegramMsg(0,a,"string with space")            ;no icon    




    }

    TelegramMsg(Option, EmojiPosition, Text, waitThreadFinish := true) {
        global 
        TelegramBotToken := this.botToken

        if telegramChatID =
            this.Telegram_FirstCFG()
        if telegramChatID =
            this.Telegram_FirstCFG()



        Text := removeSpecialCharacters(Text, this.characterExceptions)

        if Option=16
            TelegramIconString := "%E2%9D%8C"
        if Option=32
            TelegramIconString := "%E2%9D%94"
        if Option=48
            TelegramIconString := "%E2%9A%A0%EF%B8%8F"
        if Option=64
            TelegramIconString := "%E2%84%B9%EF%B8%8F"

        IfInString, Option, `%
            TelegramIconString := Option

        IfLessOrEqual, EmojiPosition, 1
            Text = %TelegramIconString% %Text%

        IfGreaterOrEqual, EmojiPosition, 2
            Text = %Text% %TelegramIconString%



        sendMessageThreadCounter := this.getSendFileThreadCounter()

        threadName := "telegramSendMessage"
        ThreadManager.createThread(threadName)

        %threadName%%sendMessageThreadCounter%Obj := CriticalObject({"Text": Text, "telegramChatID": telegramChatID, "TelegramBotToken": TelegramBotToken, "debug": A_IsCompiled ? false : true})

        %threadName%%sendMessageThreadCounter% := AhkThread("
        (
            #NoTrayIcon
            #Persistent
            MyObj := CriticalObject(A_Args[1])
            Text := MyObj.Text
            telegramChatID := MyObj.telegramChatID
            TelegramBotToken := MyObj.TelegramBotToken
            debug := MyObj.debug

            TWinHTTP := ComObjCreate(""WinHTTP.WinHttpRequest.5.1"")
            ; msgbox, 64,, a, 2

            TelegramURL = https://api.telegram.org/bot%TelegramBotToken%/sendmessage?chat_id=%telegramChatID%&text=%Text%
            ; msgbox, % TelegramURL
            TWinHTTP.SetTimeouts(0, 60000, 30000, 60000)
            TWinHTTP.Open(""GET"", TelegramURL, 0)
            try {
                TWinHTTP.Send()
            } catch e {
                error := A_Hour "":"" A_Min "":"" A_Sec "" | TelegramMsg: "" e.Message "" | "" e.What
                OutputDebug, % A_ThisFunc "": ""  error
            }
            try {
                Result := TWinHTTP.ResponseText
            } catch e {
                error := A_Hour "":"" A_Min "":"" A_Sec "" | TelegramMsg: "" e.Message "" | "" e.What
                OutputDebug, % A_ThisFunc "": ""  error
                ExitApp
            }
            ; if (debug) && (!InStr(Result, "":true""))
                ; Msgbox, 48,, % Result
            ; telegramJsonObj := Json.Load(Result)

            Sleep, 100
            ExitApp

        )", &%threadName%%sendMessageThreadCounter%Obj "")

        this.sendMessageThreadCounter++

        ; msgbox, % "a = " %threadName%%sendMessageThreadCounter%.ahkReady()
        if (waitThreadFinish = true) {
            While ThreadManager.checkThreadFinished(threadName "" sendMessageThreadCounter, finishThread := false, debug := false) {
                ; ToolTip % "running thread.`n" threadName " = " serialize(%threadName%%sendMessageThreadCounter%Obj)
                Sleep, 100
                ; Tooltip
            }
        }


        return

    }


    telegramConfigGUI() {
        Random, SecurityCode, 1000, 9999

        this.SecurityCode := SecurityCode

        Gui, TelegramConfig:Destroy
        Gui, TelegramConfig:+AlwaysOnTop -MinimizeBox
        Gui, TelegramConfig:Add, Text, x10 y+5 w200, % LANGUAGE = "PT-BR" ? "Passo 1) Crie seu próprio bot Telegram via @BotFather e adicione o token acima." : "Step 1) Create your own Telegram bot via @BotFather and add the token above."
        Gui, TelegramConfig:Add, Edit, x10 y+3 w200 ReadOnly, % "https://t.me/BotFather"

        Gui, TelegramConfig:Add, Text, x10 y+10 w200, % LANGUAGE = "PT-BR" ? "Passo 2) Envie a mensagem com esse código de segurança:" : "Step 2) Send a message with this Security Code:"
        Gui, TelegramConfig:Add, Edit, x10 y+3 ReadOnly, % SecurityCode

        Gui, TelegramConfig:Add, Text, x10 y+10 w200, % LANGUAGE = "PT-BR" ? "Passo 3) Você enviou a mensagem? Então clique aqui:" : "Step 3) Did you send the message? Then click here:"
        Gui, TelegramConfig:Add, Button, x10 y+5 w200 gsentTelegramCodeMessage, % LANGUAGE = "PT-BR" ? "Verificar Código de Segurança" : "Verify Security Code"


        Gui, TelegramConfig:Show,, % "Telegram OldBot"
    }

    Telegram_FirstCFG() {
        Gui, TelegramConfig:Destroy
        CarregandoGUI("Checking security code message...", text_width := 180, progress_width := 180, , , , , show_bar := false)
        ; msgbox open telegram and open a new Chat with @botfater`nif yout dont know how you do that, search in your default serach engine for "Telegram Botfather first bot"`n`nyou need to choose a unique name (you cant change it)
        ; loop
        ; {
        ;     InputBox, BotToken, enter the in telegram indicated bot token, 
        ;     MsgBox, 4, , Bot Token correct?:`n%BotToken%
        ;         IfMsgBox Yes
        ;             break
        ; }
        if (!this.TWinHTTP)
            this.createHTTPObj()

        TelegramBotToken := this.botToken

        ; msgbox now open a new chat with your new created bot (search for @*yourbotname* and start a new chat) and enter this number %SecurityCode% and send it via telegram`n press OK, when done.

        ; tempFileDir := A_Temp "\findChatID.json"
        ; FileDelete, % tempFileDir
        ; UrlDownloadToFile https://api.telegram.org/bot%TelegramBotToken%/getupdates , % tempFileDir
        ; sleep 2000

        TelegramURL = https://api.telegram.org/bot%TelegramBotToken%/getupdates
        this.TWinHTTP.Open("GET", TelegramURL, 0)
        try this.TWinHTTP.Send("")
        catch e
            throw e
        Result := this.TWinHTTP.ResponseText
        ; msgbox, % Result
        telegramJsonObj := Json.Load(Result)
        ; msgbox, % serialize(telegramJsonObj)


        messages := telegramJsonObj.result


        ; msgbox, % "messages count = " messages.Count()

        lastMessageChatID := ""

        index := 0
        ; loop, % messages.Count() 
        for key, value in messages
        {
            value := messages[messages.Count() - index]
            text := value.message.text
            ; msgbox, % index " = " index " | msg  = " text "`n`n" serialize(value)
            if (text = this.SecurityCode) {
                lastMessage := value
                lastMessageText := lastMessage.message.text
                lastMessageChatID := lastMessage.message.chat.id
                lastMessageID := lastMessage.message.message_id
            }
            index++

        }

        Gui, Carregando:Destroy
        ; msgbox,%  lastMessageText " / " lastMessageChatID " / " lastMessageID "`n`n" serialize(lastMessage)

        Gui, Carregando:Destroy
        if (lastMessageChatID = "") {
            ; file := FileOpen(A_Temp "\OldBot\message_resut" , "w")
            ; file.Write(Result)
            ; file.Close()
            throw Exception("Security Code message was not found in the chat, try again.")
        }


        telegramChatID := lastMessageChatID
        IniWrite, % telegramChatID, %DefaultProfile%, telegram, telegramChatID
        GuiControl, setupTelegramGUI:, telegramChatID, % telegramChatID
        GuiControl, setupTelegramGUI:Enable, telegramTestMessageButton
        GuiControl, setupTelegramGUI:Enable, telegramTestScreenshotButton
        Msgbox, 64,, % "Success.`n`nYou can send a test message check if it's working."


        ; msgbox now search for the number %SecurityCode% and on the same line there should be something like: "chat":{"id":782163891`n`nfound it? press ok

        ; InputBox ChatID, enter the number after "chat":{"id": here:
        ; FileAppend, Telegram Bot Token = %TelegramBotToken%`n, %A_ScriptDir%\TokenAndID.txt
        ; FileAppend, Telegram Chat ID = %ChatID%, %A_ScriptDir%\TokenAndID.txt
        ; run %A_ScriptDir%\TokenAndID.txt

        ; msgbox here you go. copy and past the values to the variables TelegramBotToken & TelegramChatID in the sourcecode.`n`n(you can delte all the .txt files)

    }


    clearChat(chatIdSearch := "") {
        if (chatIdSearch = "") {
            this.checkChatID()      
            chatIdSearch := telegramChatID
        }

        CarregandoGUI("Loading...", text_width := 120, progress_width := 120, , , , , show_bar := false)

        if (!this.TWinHTTP)
            this.createHTTPObj()

        TelegramBotToken := this.botToken

        ; last := 513746092 + 1
        ; TelegramURL = https://api.telegram.org/bot%TelegramBotToken%/getupdates?offset=%last%
        TelegramURL = https://api.telegram.org/bot%TelegramBotToken%/getupdates
        this.TWinHTTP.Open("GET", TelegramURL, 0)
        try this.TWinHTTP.Send("")
        catch e
            throw e
        Result := this.TWinHTTP.ResponseText
        ; msgbox, % Result
        telegramJsonObj := Json.Load(Result)

        messages := telegramJsonObj.result

        firstUpdate := messages[1]
        firstUpdateID := messages[1].update_id
        lastUpdate := messages[messages.Count()]
        lastUpdateID := messages[messages.Count()].update_id



        CarregandoGUI("Deleting messages 0/" messages.Count() "...", text_width := 200, progress_width := 200, , , , , show_bar := false)


        ; 513746092
        ; 513746121
        ; clipboard := firstUpdateID

        ; msgbox, % firstUpdateID "/" serialize(firstUpdate) "`n`n" lastUpdateID "/" serialize(lastUpdate)

        ; msgbox, % "messages to delete = " 


        chats := {}
        for key, value in messages
        {
            InfoCarregando("Deleting messages " A_Index "/" messages.Count() "...")
            ; msgbox, % serialize(value)
            chatID := value.message.chat.id

            if (chatID != chatIdSearch)
                continue
            if (!chats[chatID])
                chats[chatID] := {}
            text := value.message.text
            messageID := value.message.message_id

            msgbox, %  chatID " / " messageID " / " text "`n`n" serialize(value.message)
            ; msgbox, % serialize(value.message)

            TelegramURL = https://api.telegram.org/bot%TelegramBotToken%/deleteMessage?chat_id=%telegramChatID%&message_id=%messageID%
            this.TWinHTTP.Open("GET", TelegramURL, 0)
            try this.TWinHTTP.Send("")
            catch e
                throw e
            Result := this.TWinHTTP.ResponseText
            msgbox, % Result

            ; msgbox, % key " = " username " | msg  = " text "`n`n" serialize(value)
        }

        Gui, Carregando:Destroy


    }




}

