


InformacoesActionScriptGUI:
    try, 
        Run, https://github.com/alfredomtx/OldBot-Docs/blob/master/Action`%20Scripts.md
    catch {
        Msgbox, 16,, Não foi possível abrir o link:`nhttps://github.com/alfredomtx/OldBot-Docs/blob/master/Action`%20Scripts.md
        return
    }
return

ReverterActionScript:
    if (ActionScriptTab = "")
        ActionScriptTab := tab

    Gosub, UpdateActionScriptForm
return 

UpdateActionScriptForm:
    ActionScriptCode := WaypointHandler.getAtribute("action", selectedWaypointEdit, ActionScriptTab)
    ActionScriptCode := StrReplace(ActionScriptCode, "<br>", "`n")
    GuiControl, ActionScriptGUI:, ActionScriptCode, % ActionScriptCode
return

ActionScriptGUI:
        new _ActionScriptGUI().open()
return

ActionScriptGUIGuiClose:
    Gui, ActionScriptGUI:Destroy
    actionScriptWaypoint := ""
    actionScriptTab := ""
return
InformacoesActionScriptGUIGuiEscape:
InformacoesActionScriptGUIGuiClose:
    Gui, InformacoesActionScriptGUI:Destroy
return

searchActionScript:
    Gui, ActionScriptGUI:Submit, NoHide
    ActionScriptGUI.loadActionScriptsListbox(searchActionScript)
return

DeleteLastLineActionScript:
    Gui, ActionScriptGUI:Submit, NoHide
    ActionScriptNew := actionScriptCode
    RemoveLastLine(ActionScriptNew)
    GuiControl, ActionScriptGUI:, actionScriptCode, % ActionScriptNew
    GuiControl, ActionScriptGUI:focus, actionScriptCode
    SendMessage, 0x0115, 7, 0,, ahk_id %hactionScriptCode% ;WM_VSCROLL    
    Send, ^{End}
return

RemoveLastLine(ByRef Var, EOL := "") {
    If (EOL = "")
        EOL := InStr(Var, "`r`n") ? "`r`n" : InStr(Var, "`n") ? "`n" : InStr(Var, "`r") ? "`r" : ""
    If (EOL) && (P := InStr(Var, EOL, 0, 0))
        Var := SubStr(Var, 1, P - 1)
    Else
        Var := ""
}

UseActionScript:
    Gui, ActionScriptGUI:Submit, NoHide
UseActionScriptNew:
    StringReplace, ActionScriptList, ActionScriptList, (),, All

    if (InStr(ActionScriptList, ActionScript.uncompatibleString)) {
        Msgbox, 64,, % "Action is uncompatible with the current client, it may not work.", 2
        ActionScriptList := StrReplace(ActionScriptList, ActionScript.uncompatibleString, "")
    }


    relativePositionString := txt("a posição é relativa a janela(window) do Tibia", "the position is relative to the Tibia window")
    returnSuccessString := txt("Retorna 1(verdadeiro) em caso de sucesso ou 0(falso).", "Returns 1(true) in case of success or 0(zero).")

    directionString := ""

    description := "", param1 := "", param2 := "", param3 := "", param4 := "", param5 := "", param6 := "", param7 := "", param8 := "", param9 := "", param10 := ""
    examples := {}
    switch ActionScriptList {

        case "alarmplay":
            description := txt("Iniciar um som de alarme, o alarme só é parado ao executar a action alarmstop() ou ao fechar o Cavebot/bot.", "Start a alarm sound, the alarm is only stopped by running the alarmstop() action or closing the Cavebot/bot.")

        case "alarmstop":
            description := txt("Parar o alarme disparado pela action alarmplay().", "Stop the alarm triggered by the alarmplay() action.")

        case "battlelistchangeorder":
            description := txt("Alterar a ordenação do Battle List, sendo o número 1 a opção ""Sort Ascending by Display Time"", 2 ""Sort Descending by Display Time"", 3 ""Sort Ascending by Distance""...", "Change the order of the Battle List, where the number 1 is the option ""Sort Ascending by Display Time"", 2 ""Sort Descending by Display Time"", 3 ""Sort Ascending by Distance""...")
            examples.1 := "battlelistchangeorder(3)"
                . txt("`n# -- alterar a ordenação do Battlsre List para ", "`n# -- change the Battle List order to ") """Sort Ascending by Distance""."
            param1 := "number"

        case "aaaa":
            description := txt("", "")

        case "aaaa":
            description := txt("", "")

        case "buyitemnpc":
            description := txt("Compra itens no NPC.", "Buy item on NPC.")
            examples.1 := "buyitemnpc(strong mana potion, 100)"
                . txt("`n# -- compra", "`n# -- buy") "100 strong mana potion."
            examples.2 := "$amountManaPotion = itemcount(mana potion)"
                . "`n# -- count how many potions you have before buying more."
                . "`n# buyitemnpc(mana potion, 100, $amountManaPotion)"
                . "`n# -- buy 100 mana potions, decreasing how many you already have."
                . "`n"
            examples.2 := "$amountDiamondArrow = itemcount(diamond arrow)"
                . "`n# -- count how many potions you have before buying more."
                . "`n# buyitemnpc(diamond arrow, 1000, $amountDiamondArrow, distance)"
                . "`n# -- say ""distance"" to NPC to filter trade list and buy 1000 diamond arrows, decreasing how many you already have."
                . "`n"
            examples.5 := "buyitemnpc(mana potion, 100, 0, , first menu)" 
                . "`n# -- buy 100 mana potion, but instead of saying ""trade"", it will say ""first menu"". Note that the param number 4(trade filter) is empty in this case to keep the default behaviour for the param."
                . "`n"
            param1 := "item name"
                , param2 := "amount to buy"
                , param3 := "amount to decrease<optional>"
                , param4 := "trade filter<optional>"
                , param5 := "trade message<optional>"

        case "capacity":
            description := txt("Retorna a quantidade de capacity(cap) do char, ou -1 em caso de falha. OBS: O capacity deve estar visivel na janela de Skills", "return the character's capacity(cap) amount, or -1 in case of failure.PS: the capacity must be visible on the Skills window.")
            examples.1 := "if (capacity() < 50) then gotolabel(LeaveHunt)" 
                . "`n# -- if capacity is lower than 50, go to the waypoint with label named ""LeaveHunt""." 

        case "chatcontains":
            examples.1 := "chatcontains(hi)"
                . "`n# -- return true if the word ""hi"" is found in the current chat."
            examples.2 := "chatcontains(hi | hello | oi)"
                . "`n# -- return true if the words ""hi"", ""hello"" or ""oi"" is found in the current chat."
                . "`n"
            examples.3 := "$chatContains = chatcontains(hi | hello | oi)"
                . "`n# if ($chatContains = true) then gotolabel(PlayerTalking)"
                . "`n# -- go to label named ""PlayerTalking"" if the words ""hi"", ""hello"" or ""oi"" is found in the current chat."
                . "`n"
            param1 := "string"

        case "closecavebot":
            description := txt("Fechar o executável do Cavebot(Cavebot.exe).", "Close the Cavebot executable(Cavebot.exe).")

        case "creaturesbattlelist":
            description := txt("Contar quantas criaturas da lista do Targeting estão visíveis no Battle List. Retorna a quantidade de criaturas encontradas ou 0(zero).", "Count how many creatures of the Targeting list are visible in the Battle List. Returns the amount of creatures found or 0(zero).")
            examples.1 := "$creatureCount = creaturesbattlelist()" 
                . "`n# -- returns the count of how many creatures are on the Battle List." 

        case "capacity":
            description := txt("Retorna a quantidade atual de cap do char, o capacity deve estar visivel na Skill Window(janela de skills)", "Returns the character's current amount of cap, the capacity must be visible in the Skill Window.")
            examples.1 := "if (capacity() < 50) then gotolabel(leaveHunt)" 
                . "`n# -- if cap is lower than 50, go to the waypoint with label named ""leavehunt""." 

        case "clickonsqm":
            description := txt("Clicar em um SQM em volta do char.", "Click on a SQM around the character.")
            examples.1 := "clickonsqm(right, N, 3, 1000)" 
                . "`n# -- Right click on North SQM 3 times, wait 1000ms after each click."
            param1 := "click"
                , param2 := "direction"
                , param3 := "repeat<optional>"
                , param4 := "delay<optional>"
                , param5 := "holdCtrl<optional>"
                , param6 := "holdShift<optional>"

        case "clickonitem":
            description := txt("Clicar em um item visível na tela.", "Click on an item visible in the screen.")
            examples.1 := "clickonitem(brown mushroom, right, 3, 1000)" 
                . "`n# -- Right click on brown mushroom 3 times, wait 1000ms after each click."
            param1 := "item name"
                , param2 := "click"
                , param3 := "repeat<optional>"
                , param4 := "delay<optional>"

        case "clickonimage":
            description := txt("Clicar em uma imagem na tela, a imagem é configurada em Script Images.", "Click on an image in the screen, the image is configured in Script Images.")
            ; examples.1 := "clickonitem(brown mushroom, right, 3, 1000)" 
            ; . "`n# -- Right click on brown mushroom 3 times, wait 1000ms after each click"
            param1 := "script image name"
                , param2 := "click"
                , param3 := "repeat<optional>"
                , param4 := "delay<optional>"
                , param5 := "tolerancy<optional>"
                , param6 := "holdCtrl<optional>"
                , param7 := "holdShift<optional>"
                , param8 := "offsetX<optional>"
                , param9 := "offsetY<optional>"

        case "clickonimagewait":
            description := txt("Clicar em uma imagem na tela e repete a busca pela quantidade em segundos definida no parametro ""timeout"" enquanto a imagem não for encontrada, a imagem é configurada em Script Images.", "Click on an image in the screen and repeat the search for the amount in seconds set in the ""timeout"" parameter while the image is not found, the image is configured in Script Images.")
            param1 := "script image name"
                , param2 := "click"
                , param3 := "timeout<optional>"
                , param4 := "repeat<optional>"
                , param5 := "delay<optional>"
                , param6 := "tolerancy<optional>"
                , param7 := "holdCtrl<optional>"
                , param8 := "holdShift<optional>"
                , param9 := "offsetX<optional>"
                , param10 := "offsetY<optional>"

        case "clickonposition":
            description := txt("Clicar em uma posição da tela, " , "Click on a position of the screen, ") relativePositionString "."
            examples.1 := "clickonposition(Left, 600, 550)" 
                . "`n# Left click on position x:600, y:550, this position is relative to the Tibia Client window(not absolute position of the screen)."
            param1 := "click"
                , param2 := "x"
                , param3 := "y"
                , param4 := "repeat<optional>"
                , param5 := "delay<optional>"
                , param6 := "holdCtrl<optional>"
                , param7 := "holdShift<optional>"

        case "closebackpack":
            description := txt("Fecha a backpack se estiver aberta. Somente as Main Backpacks listadas na aba Looting -> DepositList podem ser usadas nessa action.", "Close the backpack if it is opened. Only the Main Backpacks listed on Looting -> DepositList tab can be used in this action.")
            examples.1 := "closebackpack(orange backpack)" 
                . "`n# -- close the ""orange backpack"". ATTENTION: Only the Main Backpacks shown in Looting -> DepositList can be used in this action!"
            param1 := "backpack"

        case "convertgold":
            description := txt("Converter gold ou platinum coins visíveis na tela.", "Convert gold or platinum coins visible on the screen.")
            param1 := "converter hotkey<optional>"

        case "deposititems":
            description := txt("Procurar por um SQM do depot(laranja) vazio e depositar os itens configurados na aba Looting -> DepositList", "Search for an empty depot SQM(orange) and deposit the items configured on Looting -> DepositList tab.")
            examples.1 := "deposititems(golden backpack)" 
                . "`n# deposit items and also deposit the golden backpack in the Stash(premium account only)."
            examples.2 := "$depositStashBP = getuseroption(depositStashBackpack)" 
                . "`n# -- get the user option value with name ""depositStashBackpack""."
                . "`n# deposititems($depositStashBP)"
                . "`n# if ""$depositStashBP"" variable is a backpack, it will deposit the entire backpack in the Stash. You can use ""takeitemfromstash()"" function to take items(such as potions)."
                . "`n"

        case "depositmoney":
            description := txt("Falar para o NPC hi->deposit all->yes", "Say to the NPC hi->deposit all->yes")

        case "deposittostash":
            description := txt("Abrir o depot e arrastar a Backpack definida para o Stash.", "Open the depot and drag the Backpack set to the Stash.")
            param1 := "Stash Backpack"

        case "droptrash":
            description := txt("Jogar todos os lixos do Looting -> TrashList no SQM do char.", "Drop all the items of the Looting -> TrashList in the character's SQM")

            param1 := "delay<optional>"

        case "droplootonground":
            description := txt("Jogar todos os items do Looting -> LootList no SQM do char.", "Drop all the items of the Looting -> LootList in the character's SQM")

        case "exitgame":
            description := txt("Fechar o jogo(exitar).", "Exit the game.")

        case "forcewalkarrow":
            description := txt("Alterar o funcionamento do Cavebot para que ande somente usando as setas ao invés de clicar no minimapa. Andar pelas setas é possível somente no " TibiaClient.Tibia13Identifier " e em áreas que forem dentro das coordenadas do Tibia Global, ou seja, em áreas custom que não são visíveis no Map Viewer não será possivel andar pelas setas.", "Change the functioning of the Cavebot so it walks only using the arrows instead of clicking on the map. Walk by arrows is possible only on " TibiaClient.Tibia13Identifier " and in areas that are in same coordinates of Real Tibia, that means, in custom areas that are not visible in the Map Viewer it won't be possible to walk with arrows.")

        case "forcewalkarrowstop":
            description := txt("Voltar o Cavebot ao seu funcionamento normal, revertendo a action forcewalkarrow().", "Turn the Cavebot back to its normal functioning, reverting the forcewalkarrow() action.")

        case "follow":
            description := txt("Dar follow em um NPC ou Player, geralmente usando a imagem do nome no Battle List.", "Do a follow in a NPC or Player, usually using the image of the name on the Battle List.")
            examples.1 := "follow(Eremo)" 
                . "`n# -- search for the NPC Eremo and follow him."
            examples.2 := "follow(Captain)" 
                . "`n# -- search for the first name ""Captain"", useful for following the ship NPCs."
                . "`n"
            examples.3 := "follow(MyScriptImageOfNpc, true)" 
                . "`n# -- search for the Script Image named ""MyScriptImageOfNpc"" and click on it holding ""Ctrl"", this will make sure the menu is shown in case the click is not in the battle list(is for example in the NPC icon on screen."
                . "`n"
            param1 := "Script Image name"
                , param2 := "hold ctrl<optional>"

        case "getbalance":
            description := txt("Retorna a quantidade de gps no ""balance"" ao conversar com o NPC do banco, em caso falha retorna -1.", "Returns the amount of gps in the ""balance"" when talking to the bank NPC, in case of fail returns -1.")
            examples.1 := "if (getbalance() > 100000) then gotolabel(transferGold)" 
                . "`n# -- if balance is higher than 100k, go to the waypoint with label named ""transferGold""." 
            examples.2 := "$balance = getbalance()" 
                . "`nif ($balance > 0) then transfergold(player name)"
                . "`n"

        case "getuseroption":
            description := txt("Obter o valor de uma configuração do Script Setup (User Options).", "Get the value of a setting from the Script Setup (User Options).")
            examples.1 := "$huntCave1 = getuseroption(checkboxHuntOnCave1)" 
                . "`n# -- get the selected user option value with name ""checkboxHuntOnCave1""."
                . "`n# if ($huntCave1 = true) then gotolabel(StartHuntCave1)"
                . "`n# -- go to the waypoint with label named  ""StartHuntCave1"" if the user checked the checkbox option."
            examples.2 := "see itemcount() example for another getuseroption() example."
                . "`n"
            param1 := "userOptionName"

        case "getsetting":
            description := txt("Obter o valor de uma configuração do Script (do arquivo JSON).", "Get the value of a setting from the Script Setup (of the JSON file).")
            examples.1 := "$lootingEnabled = getsetting(looting/settings/lootingEnabled)" 
                . "`n# -- get looting enabled setting, which is 0 if disabled(false) or 1 if enabled(true)."
                . "`n# if ($lootingEnabled = 0) then setsetting(looting/settings/lootingEnabled, 1)"
                . "`n# -- enable looting if disabled."
            examples.2 := "$mainbp = getsetting(looting/depositSettings/backpackSettings/mainBackpack)"
                . "`n# -- get the main backpack chosen deposit settings."
                . "`n# mousedragitem(great mana potion, $mainbp, 10)"
                . "`n# -- try to move great mana potion 10 times to the main backpack."
                . "`n"
            param1 := "settingPath"

        case "gotolabel":
            description := txt("Fazer o Cavebot ir para um Waypoint específico, usando como parâmetro o Label, nome da aba ou número de um waypoint.", "Make the Cavebot go to a specific Waypoint, using as parameter the Label, tab name or number of a waypoint.")
            examples.1 := "gotolabel(leavehunt)" 
                . "`n# -- go to the waypoint with label named ""leavehunt""."
            examples.2 := "gotolabel(1)"
                . "`n# -- go to waypoint number 1."
                . "`n"
            examples.3 := "gotolabel(Waypoints)"
                . "`n# -- go to the first waypoint of the tab named ""Waypoints""."
                . "`n"
            param1 := "label"

            description := txt("Retorna 1(verdadeiro) se a magia ou o grupo da magia está com cooldown, ou 0(falso) do contrário.", "Returns 1(true) if the spell or the spell group is with cooldown, or 0(false) otherwise.")

        case "isattacking":
            description := txt("Retorna 0(falso) se não estiver atacando nenhuma criatura no Battle List, 1(verdadeiro) se estiver.", "Returns 0(false) it is not attacking any creature on the Battle List, 1(true) if it is.")
            examples.1 := "if (isattacking() = false) then gotolabel(xxx)" 

        case "isbattlelistempty":
            description := txt("Retorna 0(falso) se a imagem do Battle List vazia não for encontrada, 1(verdadeiro) se encontrada.", "Returns 0(false) if the image of the empty Battle List is not found, 1(true) if found.")
            examples.1 := "if (isbattlelistempty() = false) then gotolabel(xxx)" 

        case "isdisconnected":
            description := txt("Retorna 0(falso) se o char está conectado ou 1(verdadeiro) se desconectado.", "Returns 0(false) if the char is connected or 1(true) if disconnected.")

        case "islocation":
            description := txt("Checar se o char está nas coordenadas definidas nos parametros OU nas coordenadas do Waypoint atual.", "Check if the character is at the coordinates set in the params OR in the coordinates of the current Waypoint.") " " returnSuccessString
            examples.1 := "if (islocation() = false) then gotolabel(xxx)" 
                . "`n# -- if the char is not at the waypoint coordinate(inside the Range area), go to a label named ""xxx""."
            examples.2 := "if (islocation(32345,32223,7) = false) then gotolabel(xxx)" 
                . "`n# -- if the char is not at the example coordinates 32345,32223,7, go to a label named ""xxx""."
                . "`n"

        case "imagesearch":
            searchAreasString := _ClientAreaFactory.getString()
            description := txt("Procurar uma imagem na tela. Retorna a quantidade de vezes que a imagem foi encontrada na tela, 0(zero) se nenhuma for encontrada, ou -1 em caso de erro.`n# O parâmetro ""searchArea"" pode ser uma dessas opções: " searchAreasString ". O padrão é ""window"".`n# Os parâmetros ""x1, y1, x2, y2"" são usados para delimitar a área de busca na tela, que por padrão é na janela inteira do cliente.`n# OBS: pixels pretos são considerados transparente pelo bot ao realizar a busca da imagem.", "Search for an image on the screen. Returns how many times the images was found on the screen, 0(zero) if none is found, or -1 in case of error.`n# The ""searchArea"" param can be one of these options: " searchAreasString ". The default is ""window"".`n# The ""x1, y1, x2, y2"" are used to limit the search area on screen, that by default is the entire window of the client.`n# PS: black pixels are considered transparent by the bot when performing the search.")
            examples.1 := "if (imagesearch(image test) < 1) then gotolabel(imageNotFound)" 
                . "`n# -- searches for the script image named ""image test"", if found less than 1(none) go to label named ""imageNotFound""."
            param1 := "script image name"
            param2 := "search area<optional>"
            param3 := "variation<optional>"
            param4 := "x1<optional>"
            param5 := "y1<optional>"
            param6 := "x2<optional>"
            param7 := "y2<optional>"

        case "imagesearchwait":
            searchAreasString := _ClientAreaFactory.getString()
            description := txt("Procurar uma imagem na tela e repete a busca pela quantidade em segundos definida no parametro ""timeout"" enquanto a imagem não for encontrada. Retorna a quantidade de vezes que a imagem foi encontrada na tela, 0(zero) se nenhuma for encontrada, ou -1 em caso de erro.`n# O parâmetro ""searchArea"" pode ser uma dessas opções: " searchAreasString ". O padrão é ""window"".`n# Os parâmetros ""x1, y1, x2, y2"" são usados para delimitar a área de busca na tela, que por padrão é na janela inteira do cliente.`n# OBS: pixels pretos são considerados transparente pelo bot ao realizar a busca da imagem.", "Search for an image on the screen and repeat the search for the amount in seconds set in the ""timeout"" parameter while the image is not found. Returns how many times the images was found on the screen, 0(zero) if none is found, or -1 in case of error.`n# The ""searchArea"" param can be one of these options: " searchAreasString ". The default is ""window"".`n# The ""x1, y1, x2, y2"" are used to limit the search area on screen, that by default is the entire window of the client.`n# PS: black pixels are considered transparent by the bot when performing the search.")
            examples.1 := "if (imagesearchwait(image test) < 1) then gotolabel(imageNotFound)" 
                . "`n# -- searches for the script image named ""image test"", if found less than 1(none) go to label named ""imageNotFound""."
            param1 := "script image name"
            param2 := "timeout"
            param3 := "variation<optional>"
            param4 := "search area<optional>"
            param5 := "x1<optional>"
            param6 := "y1<optional>"
            param7 := "x2<optional>"
            param8 := "y2<optional>"

        case "itemcount":
            description := txt("Retorna a contagem de um item na Action Bar(" TibiaClient.Tibia13Identifier ") ou de itens visíveis na tela(em versões antigas do Tibia).", "Returns the count of an item in the Action Bar(" TibiaClient.Tibia13Identifier ") or of the items visible on the screen(in older Tibia versions).")
            examples.1 := "if (itemcount(mana potion) < 20) then gotolabel(leavehunt)" 
                . "`n# -- count the amount of mana potions, if lower than 100 go to label ""leavehunt""."
            examples.2 := "$potionCheck = getuseroption(potionToUse)" 
                . "`n# -- get the selected user option value with name ""potionToUse""."
                . "`n# $potionsLeave = getuseroption(potionLeaveAmount)"
                . "`n# -- get the selected user option value with name ""potionLeaveAmount""."
                . "`n# if (itemcount($potionCheck) < $potionsLeave) then gotolabel(leavehunt)"
                . "`n# -- count the amount of $potionCheck, if lower than $potionsLeave go to label ""leavehunt""."
                . "`n"
            param1 := "item name"

        case "itemsearch":
            description := txt("Procurar um item na tela. Retorna a quantidade de vezes que o item foi encontrado na tela ou 0(zero) se nenhum for encontrada.", "Search for an item on the screen. Returns how many times the item was found on the screen or 0(zero) if none is found.")
            examples.1 := "$haveWornboots = itemsearch(worn soft boots)" 
                . "`n# if ($haveWornboots > 0) then gotolabel(RenewBoots)" 
                . "`n# -- If found more than zero ""worn soft boots"" on screen, go to the waypoint with label named ""RenewBoots"" to renew the soft boots."
            param1 := "item name"
            param2 := "search area<optional>"
            param3 := "x1<optional>"
            param4 := "y1<optional>"
            param5 := "x2<optional>"
            param6 := "y2<optional>"

        case "lifepercent":
            description := txt("Verificar se o personagem possui a quantidade de vida. Retorna 1(verdadeiro) ou 0(falso)", "Check if the character has the amount of life. Returns 1(true) or 0(false)")
            examples.1 := "if (lifepercent(30) = false) then presskey(F1)"
                . "`n# -- press the hotkey ""F1"" if does not have 30% of life."
            examples.2 := "$hasLife = lifepercent(30)"
                . "`nif ($hasLife = false) then presskey(F1)" 
                . "`n# -- press the hotkey ""F1"" if does not have 30% of life."
                . "`n"

        case "level":
            description := txt("Retorna o level atual do char, o level deve estar visivel na Skill Window(janela de skills)", "Returns the character's current level, the level must be visible in the Skill Window.")
            examples.1 := "if (level() >= 8) then gotolabel(leaveHunt)" 
                . "`n# -- if level is higher or equal than 8, go to the waypoint with label named ""leavehunt""." 

        case "distancelooting":
            description := txt("Realiza as ações de Distance Looting, da mesma forma que é realizado após o Targeting mata uma criatura por exemplo.", "Perform the Distance Looting actions, the same way it's performed Targeting kills a creature for example.")

        case "lootaround":
            description := txt("Realiza as ações de Looting, da mesma forma que é realizado após o Targeting mata uma criatura por exemplo.", "Perform the Looting actions, the same way it's performed Targeting kills a creature for example.")

        case "manapercent":
            description := txt("Verificar se o personagem possui a quantidade de mana. Retorna 1(verdadeiro) ou 0(falso)", "Check if the character has the amount of mana. Returns 1(true) or 0(false)")
            examples.1 := "$hasMana = manapercent(90)"
                . "`nif ($hasMana = true) then presskey(F1)" 
                . "`n# -- press the hotkey ""F1"" if has 90% or more of mana."
            examples.2 := "$hasMana = manapercent(30)"
                . "`nif ($hasMana = false) then presskey(F1)" 
                . "`n# -- press the hotkey ""F1"" if does not have 30% of mana."
                . "`n"
            param1 := "percentage"

        case "luremodestop":
            description := txt("Parar o lure mode iniciado pela action luremode().", "Stop the lure mode started by the luremode() action.")

        case "luremode":
            description := txt("Alterar o modo em que o Targeting e o Cavebot funcionam em conjunto, para que o Targeting comece a atacar somente com uma quantidade mínima de criaturas no Battle List.", "Change the way the Targeting and Cavebot function together, so the Targeting starts attacking only with a minimum amount of creatures in the Battle List.")
            examples.1 := "luremode(3)" 
                . "`n# -- set lure mode and only stop the Cavebot to attack with 3+ creatures on battle list."
            examples.2 := "luremode(6, 3)" 
                . "`n# -- set lure mode to stop the Cavebot to attack with 6+ creatures on battle list, and keep walking when there are 3 or less."
                . "`n"
            examples.3 := "$creaturesLure = getuseroption(amountCreaturesLure)" 
                . "`n# -- get the selected user option value with name ""amountCreaturesLure""."
                . "`n# luremode($creaturesLure)"
                . "`n# -- set lure mode and only stop the Cavebot to attack with the amount of creatures set on Script Settings by the user."
                . "`n"
            param1 := "creatures amount"
            param2 := "minimum amount<optional>"

        case "luremodewalkingattack":
            description := "[BETA] " txt("Ao executar essa action, uma nova ação será feita a cada 1 segundo enquanto o luremode estiver ativo e sem a quantidade necessária de monstros para atacar. O bot irá pressionar ""Espaço"" para atacar alguma criatura no Battle List caso não esteja atacando nenhuma. O parâmetro ""hotkey"" serve para usar uma runa ou magia de ataque enquanto estiver atacando. O parâmetro ""spell"" serve para checar o cooldown de acordo com o nome da magia(caso o cooldown da magia seja maior do que o padrão de 2 segundos )", "When running this action, a new action will be performed every 1 second while the luremode is enabled and without the necessary amount of creatures to attack. The bot will press ""Space"" to attack some creature on Battle List in case it is not attacking any. The parameter ""spell hotkey"" is to use a rune or attack spell while attacking. The parameter ""spell"" is to check the cooldown according to the spell name(in case the spell's cooldown is higher than the default 2 seconds).")
            param1 := "hotkey1<optional>"
            param2 := "spell1<optional>"
            param3 := "hotkey2<optional>"
            param4 := "spell2<optional>"
            param5 := "hotkey3<optional>"
            param6 := "spell3<optional>"

        case "luremodewalkingattackstop":
            description := txt("Desativa a ação criada pela action ""luremodewalkingattack"".", "Disabled the action created by the ""luremodewalkingattack"".")

        case "log":
            description := txt("Escrever algo no log.", "Write something in the log.")
            param1 := "message"

        case "math":
            examples.1 := "math(2, +, 2)" 
                . "`n# -- 2 plus 2, the result will be 4."
            examples.2 := "math(2, -, 1)" 
                . "`n# -- 2 minus 2, the result will be 1."
                . "`n"
            examples.3 := "math(2, *, 2)" 
                . "`n# -- 2 times 2, the result will be 4."
                . "`n"
            examples.4 := "math(4, /, 2)" 
                . "`n# -- 4 divided by 2, the result will be 2."
                . "`n"
            description := txt("Realizar uma operação matemática com 1 operador e 2 operandos(2 números). Retorna o resultado da operação.", "Do a mathematical operation with 1 operator and 2 operands(2 numbers). Returns the result of the operation")
            param1 := txt("operando 1", "operand 1")
            param2 := txt("operador", "operator")
            param3 := txt("operando 2", "operand 2")

        case "minimapheight":
            description := txt("Redimensionar o minimapa setando a altura definida.", "Resize the minimap setting the defined height.")
            param1 := "height"
            examples.1 := "minimapheight(250)" 
                . "`n# -- resize the minimap to 250 pixels of height."

        case "minimapzoom":
            description := txt("Alterar o zoom do mapa clicando no botão de zoom.", "Change the minimap zoom click on the zoom button.")
            param1 := "number"
            examples.1 := "minimapzoom(+1)" 
                . "`n# -- click on the minimap plus(+) button 1 time."
            examples.2 := "minimapzoom(-1)" 
                . "`n# -- click on the minimap minus(-) button 1 time."
                . "`n"
            examples.3 := "minimapzoom(+3)" 
                . "`n# -- click on the minimap plus(+) button 3 times."
                . "`n"

        case "messagebox":
            description := txt("Exibir uma janela com uma mensagem na tela. ATENÇÃO: O Cavebot não roda enquanto a janela com a mensagem não for fechada.", "Show a window with a message on the screen. ATTENTION: The Cavebot does not run until the message window is closed.")
            param1 := "message"

        case "mousemove":
            description := txt("Mover o mouse para uma posição na tela", "Move the mouse to a position on the screen")", "relativePositionString "."
            param1 := "x"
                , param2 := "y"

        case "mousedrag":
            description := txt("Arrastar o mouse de uma posição até a outra na tela", "Drag the mouse from a position to another on the screen") ", "relativePositionString "."
            param1 := "x1"
                , param2 := "y1"
                , param3 := "x2"
                , param4 := "y2"
                , param5 := "repeat<optional>"

        case "mousedragimage":
            description := txt("Arrastar o mouse da posição de uma imagem até a posição de outra imagem na tela.", "Drag the mouse from a position of an image to the position of an image on the screen.")
            param1 := "image move from"
                , param2 := "image move to"
                , param3 := "repeat<optional>"
                , param4 := "delay<optional>"
                , param5 := "hold shift<optional>"
                , param6 := "variation<optional>"

        case "mousedragimageitem":
            description := txt("Arrastar o mouse da posição de uma imagem até a posição de um item na tela.", "Drag the mouse from a position of an image to the position of an item on the screen.")
            param1 := "script image name"
                , param2 := "item move from"
                , param3 := "repeat<optional>"
                , param4 := "delay<optional>"
                , param5 := "hold shift<optional>"

        case "mousedragimageposition":
            examples.1 := "mousedragimageposition(test, 500, 500)" 
                . "`n# -- drag the mouse from the position of where the image named ""test"" is found, to the position x: 500 and y: 500 in Tibia client window."
            examples.1 := "mousedragimageposition(test, +50, +10)" 
                . "`n# -- drag the mouse from the position of where the image named ""test"" is found, to the position plus 50 pixels in the X axis and 10 pixels in Y axis(relative to where the image was found)."
                . "`n"

            description := txt("Arrastar o mouse da posição da imagem até a posição da tela", "Drag the mouse from the position of the image to the position of the screen") ", "relativePositionString "."
            param1 := "image move from"
                , param2 := "position x"
                , param3 := "position y"
                , param4 := "repeat<optional>"
                , param5 := "delay<optional>"
                , param6 := "hold shift<optional>"
                , param7 := "variation<optional>"

        case "mousedragitem":
            description := txt("Arrastar o mouse da posição de um item até a posição de outro item na tela.", "Drag the mouse from the position of an item to the position of another item on the scren.")
            examples.1 := "mousedragitem(diamond arrow, quiver, 8, 500)" 
                . "`n# -- move diamond arrow to the quiver 8 times, wait 500ms after each item move."
            examples.2 := "see getsetting() example for another mousedragitem() example"
                . "`n"
            param1 := "item move from"
                , param2 := "item move to"
                , param3 := "repeat<optional>"
                , param4 := "delay<optional>"
                , param5 := "hold shift<optional>"

        case "mousedragitemimage":
            description := txt("Arrastar o mouse da posição de um item até a posição de uma imagem na tela.", "Drag the mouse from a position of an item to the position of an image on the screen.")
            param1 := "item move from"
                , param2 := "script image name"
                , param3 := "repeat<optional>"
                , param4 := "delay<optional>"
                , param5 := "hold shift<optional>"

        case "mousedragitemposition":
            description := txt("Arrastar o mouse da posição de um item até a posição da tela", "Drag the mouse from a position of an item to the position of the screen") ", "relativePositionString "."
            examples.1 := "mousedragitemposition(mana potion, 450, 560)" 
                . "`n# -- move mana potion once to the position x: 450, y:560 on the screen(position relative to Tibia's window)."
            examples.2 := "mousedragitemposition(scarab coin, SQMNX, SQMNY, 1, 1)" 
                . "`n# -- move once 1 scarab coin(pressing shift) to the position of SQM N (North)."
                . "`n"
            examples.3 := "mousedragitemposition(empty potion flask, SQMCX, SQMCY, 10, 500, 1)" 
                . "`n# -- move 10 times the empty potion flasks to the character position - SQM C (Center), wait 500ms after each item move."
                . "`n"
            examples.4 := "mousedragitemposition(red quiver, shieldX, shieldY)" 
                . "`n# mousedragitemposition(falcon bow, handX, handY)"
                . "`n# -- move the red quiver to the shield slot position and the falcon bow to the hand position, equipping both."
                . "`n"
            param1 := "item move from"
                , param2 := "position x"
                , param3 := "position y"
                , param4 := "repeat<optional>"
                , param5 := "delay<optional>"
                , param6 := "hold shift<optional>"

        case "notification":
            description := txt("Exibir uma notificação não intrusiva na tela(traytip).", "Show a non intrusive notification on screen(traytip).")
            param1 := "message"

        case "npchi":
            description := txt("Iniciar uma conversa com o NPC e verificar se o chat foi aberto.", "Start a conversation with the NPC and check if the chat has been opened.") " " returnSuccessString

        case "npctrade":
            description := txt("Iniciar uma conversa com o NPC e verificar se a Janela de Trade foi aberta. Retorna 1(verdadeiro) em caso de sucesso ou 0(falso).", "Start a conversation with the NPC and check if the Trade Window has been opened. Returns 1(true) in case of success or 0(zero).")

        case "openbackpack":
            description := txt("Abrir uma backpack em uma nova janela.", "Open a backpack in a new window.")
            examples.1 := "openbackpack(orange backpack)" 
                . "`n# -- open the ""orange backpack"" in a new window."
            param1 := "backpack"

        case "opendepot":
            description := txt("Procurar por um SQM do depot(laranja) vazio e abrir o depot.", "Search for an empty depot SQM(orange) and open the depot.") " " returnSuccessString
            description := txt("Abrir uma backpack em uma nova janela.", "Open a backpack in a new window.")

        case "removemonsterfromlist":
            description := txt("Remover uma criatura da lista de criatures do Targeting.", "Remove a creature from the creatures list of the Targeting.")
            param1 := "monster creature name"

        case "pausemodule":
            description := txt("Pausar um módulo do bot.", "Pause a module of the bot.")
            examples.1 := "pausemodule(support)" 
                . "`n-- pause the entire ""Support"" module. To unpause, use unpausemodule()."
            examples.2 := "pausemodule(fishing)" 
                . "`n# -- pause the ""Fishing"" module."
                . "`n"
            param1 := "module name"

        case "presskey":
            description := txt("Pressionar uma tecla.", "Press a hotkey.")
            examples.1 := "presskey(F12, 3, 1000)" 
                . "`n# -- press ""F12"" key 3 times, wait 1000ms after each press."
            examples.2 := "presskey(Down)" 
                . "`n# -- press the arrow key ""Down""."
                . "`n"
            examples.3 := "presskey(+F1)" 
                . "`n# -- press ""F1"" key holding Shift."
                . "`n"
            examples.4 := "presskey(^F1)" 
                . "`n# -- press ""F1"" key holding Ctrl."
                . "`n"
            param1 := "key"
                , param2 := "repeat<optional>"
                , param3 := "delay<optional>"

        case "randomnumber":
            description := txt("Retorna um número randomicamente entre o intervalo de números definido.", "Returns a number randomly between the number range of set.")
            examples.1 := "$randomNumber = randomnumber(1, 10)" 
                . "`n# returns a random number between 1 and 10 and stores in the $randomNumber variable."
            param1 := "min"
                , param2 := "max"

        case "reloadcavebot":
            description := txt("Reabrir o executável do Cavebot(Cavebot.exe).", "Reopen the Cavebot executable(Cavebot.exe).")

        case "resetsession":
            description := txt("Resetar a sessão do Cavebot e as suas variaveis de hora, minuto e segundos.", "Reset the Cavebot session and its variables of hour, minute and seconds.")

        case "runcommand":
            param1 := "command"

        case "runactionwaypoint":
            description := txt("Executar um waypoint de Action específico do Cavebot, sem precisar usar a action gotolabel() nesse waypoint.", "Run a specific Action Waypoint of the Cavebot, without the need of using a gotolabel() action on this waypoint.")
            examples.1 := "runactionwaypoint(2, Waypoints)" 
                . "`n# -- run the waypoint 2 of the TAB named ""Waypoints"""
            examples.2 := "runactionwaypoint(1)" 
                . "`n# -- run the waypoint 1 of current the TAB"
                . "`n"
            examples.3 := "runactionwaypoint(1, CheckSupply)" 
                . "`n# -- run the waypoint 1 of the TAB named ""CheckSupply"""
                . "`n"
            examples.4 := "runactionwaypoint(buyHealthPotion)" 
                . "`n# -- run the waypoint with LABEL named ""buyHealthPotion"""
                . "`n"
            param1 := "label"
            param2 := "tab<optional>"

        case "screenshot":
            description := txt("Tirar uma foto da tela e salvar na pasta de screenshots(menu Arquivo -> Abrir pastas -> Screenshots).", "Take a picture of the screen and save in the screenshots folder(menu File -> Open folders -> Screenshots).")

        case "soulpoints":
            description := txt("Retorna o soul points atual do char, o soul points deve estar visivel na Skill Window(janela de skills)", "Returns the character's current soul points, the soul points must be visible in the Skill Window.")
            examples.1 := "if (soulpoints() < 10) then gotolabel(LowSoul)" 
                . "`n# -- if soulpoints is higher or equal than 10, go to the waypoint with label named ""lowSoul""." 

        case "reachlocation":
            description := txt("Caminha até uma coordenada, igual um waypoint de ""Walk"".", "Walk to a coordinate, the same as a ""Walk"" waypoint.")
            examples.1 := "reachlocation(32935, 32075, 7, 1, 1)" 
                . "`n# -- Walk to the coordinates of Venore Depot right stairs, with the range of 1x1 (like a Stand)."
                . "`n# -- TibiaMaps link: https://tibiamaps.io/map#32935,32075,7:2"
            param1 := "x"
            param2 := "y"
            param3 := "z"
            param4 := "rangeX"
            param5 := "rangeY"

        case "say":
            description := txt("Escrever e enviar uma mensagem no chat.", "Write and send a message in the chat.")
            examples.1 := "say(oldbot rocks)" 
                . "`n# -- say message ""oldbot rocks"" on the current chat."
            param1 := "message"

        case "sellallitemsnpc":
            description := txt("Vende todos os itens que estiverem disponíveis para venda no Trade List, é muito mais rápido do que a venda de itens usando a action ""sellitemnpc"".", "Sell all the items available to sell on the Trade List, it's much faster than the selling of items using the ""sellitemnpc"" action.")

            param1 := "trade message<optional>"

        case "sellitemnpc":
            description := txt("Vender itens no NPC.", "Sell items in the NPC.")
            examples.1 := "sellitemnpc(empty potion flask)" 
                . "`n# -- sell all empty potion flasks on NPC."
            examples.2 := "sellitemnpc(SellList)" 
                . "`n# -- sell all items of the LootList"
                . "`n"
            examples.3 := "sellitemnpc(LootList)" 
                . "`n# -- sell all items of the DepositList"
                . "`n"
            examples.4 := "sellitemnpc(DepositList)" 
                . "`n# -- sell all items of the DepositList"
                . "`n"
            examples.5 := "sellitemnpc(SellList, first menu)" 
                . "`n# -- sell all items of the SellList, but instead of saying ""trade"", will say ""first menu""."
                . "`n"
            param1 := "item name"
                , param2 := "trade message<optional>"

        case "setlocation":
            description := txt("Setar as variáveis internas do Cavebot para as coordenadas definidas.", "Set the internal Cavebot variables to the defined coordinates.")
            param1 := "x"
            param2 := "y"
            param3 := "z"

        case "setsetting":
            description := txt("Definir o valor de uma configuração global do bot, essa action pode ser usada para alterar configurações do Script(arquivo JSON) e também para alterar configurações internas como, por exemplo, do Cavebot(cavebotSystem).", "Set the value of a global setting of the bot, this action can be used to change Script settings(JSON file) as well as to change internal settings like, for example, of the Cavebot(cavebotSystem).")
            examples.1 := "setsetting(looting/settings/lootingEnabled, 0)" 
                . "`n# -- disable looting."
            examples.2 := "setsetting(targeting/targetList/Dragon/onlyIfTrapped, 1)"
                . "`n# -- change the ""Dragon"" creature setting to attack only if trapped."
                . "`n"
            examples.3 := "setsetting(reconnect/autoReconnect, 1)"
                . "`n# -- enable the Auto Reconnect."
                . "`n"
            examples.4 := "setsetting(cavebotSystem/checkDisconnected, 0)"
                . "`n# -- disable the internal disconnected check of the Cavebot System, this allows the waypoints to run even if the character is disconnected(to interact with the client for example)."
            examples.5 := "setsetting(alerts/Image is found 1/enabled, 1)"
                . "`n# -- enable the alert ""Image is found 1""."
                . "`n"
            param1 := "settingPath", param2 := "value"

        case "stamina":
            description := txt("Retorna a quantidade atual de horas da stamina do char, a stamina deve estar visivel na Skill Window(janela de skills)", "Returns the character's current hours of stamina, the stamina must be visible in the Skill Window.")
            examples.1 := "if (stamina() < 40) then gotolabel(leaveHunt)" 
                . "`n# -- if the stamina is lower than 40 hours, go to the waypoint with label named ""leavehunt""."

        case "targetingdisable":
            description := txt("Desabilitar o Targeting. OBS: Caso o Cavebot detecte que o char está trapado, o Targeting é ativado automaticamente para atacar as criaturas e depois desativado novamente.", "Disable the Targeting. PS: In case the Cavebot detects that the character is trapped, the Targeting is enabled automatically to attack the creatures and then it's disabled again.")

        case "targetingenable":
            description := txt("Habilitar o Targeting após ser desabilitado pela action targetingdisable()", "Enable the Targeting after it has been disabled by the targetingenable() action.")

        case "takeitemfromstash":
            description := txt("Abrir a Stash e retirar a quantidade definida do item.", "Open the Stash and take the amount set of the item.")
            examples.1 := "takeitemfromstash(mana potion, 100)"
                . "`n# -- take 100 mana potion from the Supply Stash."
            examples.2 := "$amountAssassinStar = itemcount(assassin star)"
                . "`n# -- count how assassin stars you have."
                . "`n# takeitemfromstash(assassin star, 500, $amountAssassinStar)"
                . "`n# -- take 500 assassin stars from the Stash, decreasing how many you already have."
                . "`n"
            param1 := "item name"
                , param2 := "amount to take"
                , param3 := "amount to decrease<optional>"

        case "telegrammessage":
            description := txt("Enviar uma mensagem no Telegram, o telegram é configurado na aba Alerts.", "Send a message on Telegram, the telergam is configured in the Alerts tab.")
            param1 := "message"

        case "telegramscreenshot":
            description := txt("Enviar uma screenshot no Telegram, o telegram é configurado na aba Alerts.", "Send a screenshot on Telegram, the telergam is configured in the Alerts tab.")
            param1 := "caption"

        case "transfergold":
            description := txt("Conversar com o NPC do banco para transferir uma quantidade de gold coins para outro jogador.", "Talk to the bank NPC to transfer an amount of gold coins to another player.")
            examples.1 := "transfergold(Arieswar)" 
                . "`n# -- Talk to NPC to get the current balance and transfer all of it to the player named ""Arieswar""."
            examples.2 := "transfergold(Arieswar, 5000)" 
                . "`n# -- Talk to NPC to get the current balance and transfer all of subtracting 5k (example: if balance is 20k, it will transfer 15k)"
                . "`n"
            examples.3 := "$keepGoldBalance = 5000" 
                . "`n# transfergold(Arieswar, $keepGoldBalance)"
                . "`n"
            param1 := "player name"
                , param2 := "subtract amount<optional>"

        case "travel":
            description := txt("Conversar com o NPC para viajar para outra cidade ou local, essa action verifica se a posição do personagem no mapa mudou para tentar novamente em caso de falha.", "Talk to the NPC to travel to another city or place, this action checks if the character position on the mao changed to try again in case of failure.") " " returnSuccessString
            examples.1 := "travel(Venore, Captain)" 
                . "`n# -- try to follow any NPC whose first name is ""Captain"" and then travel to Venore."
            examples.2 := "travel(Edron, Captain Bluebear)" 
                . "`n# -- try to follow the NPC ""Captain Bluebear"" and then travel to Edron."
                . "`n"
            param1 := "location"
                , param2 := "npc to follow<optional>"

        case "turn":
            description := txt("Girar o personagem para uma direção.", "Rotate(turn) the personagem to a direction.")
            examples.1 := "turn(N)" 
                . "`n# -- turn character towards North."
            param1 := "direction"

        case "useitem":
            description := txt("Usar um item visível na tela.", "Use a item visible on the screen.")
            examples.1 := "useitem(fish, 3, 1000)" 
                . "`n# -- Click on the fish and then in ""use"" option 3 times, wait 1000ms after each use."
            param1 := "item name"
                , param2 := "repeat<optional>"
                , param3 := "delay<optional>"

        case "useitemoncorpses":
            description := txt("Usar o item configurado na hotkey nos corpos localizados na tela. A imagem dos corpos são configuradas em Script Images, são imagens com a categoria ""Corpse"".", "Use the item set in the hotkey in the corpses found on screen. The image of the corpses are configured in Script Images, they are images with the ""Corpse"" category.")
            param1 := "hotkey or item name(old tibia)"

        case "usesqm":
            description := txt("Realizar a ação de ""Use"" em um SQM em volta do char.", "Do the ""Use"" action in a SQM around the character.")
            examples.1 := "usesqm(S)" 
                . "`n# -- do the ""Use"" action on the South SQM."

        case "unpausemodule":
            description := txt("Despausar um módulo do bot.", "Unpause a module of the bot.")
            examples.1 := "unpausemodule(support)" 
                . "`n-- pause the entire ""Support"" module. To pause, use pausemodule()."
            examples.2 := "unpausemodule(fishing)" 
                . "`n# -- pause the ""Fishing"" module."
                . "`n"
            param1 := "module name"

        case "variable":
            description := txt("Definir um valor ou criar uma variável do Script, essa variável só existe enquanto o Cavebot está rodando.", "Set the value or create a Script variable, this variable only exists while the Cavebot is running.")
            examples.1 := "variable(myVariableName, 1)" 
                . "`n# -- create a script variable named ""myVariableName"" and set it's value to 1."
            examples.2 := "variable(myTextVariable, this is a text value for the variable)" 
                . "`n# -- create a script variable named ""myTextVariable"" and set it's value."
                . "`n"
                . "`n# $textVar = getsetting(scriptVariables/myTextVariable)"
                . "`n# -- get the variable value using getsetting() and store in the $textVar."
                . "`n"
                . "`n# messagebox($textVar)"
                . "`n# -- show the variable value using a messagebox()."
                . "`n"
            examples.3 := "variable(triesDeposit, ++)" 
                . "`n# -- create a script variable named ""triesDeposit"" and increments its value, to decrement set value as ""--""."
                . "`n"
            param1 := "variable name"
            param2 := "value"
            param3 := "type<optional>"

        case "variableshowall":
            description := txt("Mostrar no log todas as variáveis do Script criadas com a action variable() e os seus valores.", "Show in the log all the Script variables created with the variable() action and their values.")
            examples.1 := "variableshowall()"
                . "`n# -- show in the log all the script variables and their values."

        case "waypointdistance":
            description := txt("Calcular a distância do char até o waypoint definido. Retorna a distância em SQMs, ou -1 em caso de erro", "Calculate the character distance until the defined waypoint. Returns the distance in SQMs, or -1 in case of error.")

            examples.1 := "$distance = waypointdistance(NextWaypoint)" 
                . "`n# -- returns the distance from the next waypoint(if exists) and stores in the $distance variable. ""NextWaypoint"" is a special parameter in this case, which will get the next waypoint."
            examples.2 := "$distance = waypointdistance(BuySupply)" 
                . "`n# -- returns the distance from the waypoint with label name ""BuySupply""."
                . "`n"
            examples.3 := "$distance = waypointdistance(3, Depositer)" 
                . "`n# -- returns the distance from the waypoint number 3 of the tab named ""Depositer""."
                . "`n"
            param1 := "label"
        case "wait":
            description := txt("Esperar a quantidade de milisegundos, o Cavebot não fará nada enquanto espera.", "Wait the amount of miliseconds, the Cavebot will do nothing while it waits.")

            examples.1 := "wait(1000)" 
                . "`n# -- wait 1000 miliseconds(1 second)."
            examples.2 := "wait(30, second)" 
                . "`n# -- wait 30 seconds"
                . "`n"
            examples.3 := "wait(5, minute)" 
                . "`n# -- wait 5 minutes"
                . "`n"
            examples.4 := "wait(3, hour)" 
                . "`n# -- wait 3 hours"
                . "`n"
            param1 := "ms"
            param2 := "measure<optional>"

        case "write":
            description := txt("Escrever(digitar) um texto.", "Write(type) a text.")
            examples.1 := "write(oldbot rocks)" 
                . "`n# -- write the text ""oldbot rocks""."
            param1 := "message"
    }


    params := ""
    loop, 10 {
        if (param%A_Index% != "") {
            params .= param%A_Index%
            nextIndex := A_Index + 1
            if (param%nextIndex% != "")
                params .= ", "
        }
    }

    SelectedAction := ActionScriptList "(" params ")"

    SelectedAction .= "`n"

    switch (new _CavebotIniSettings().get("addActionWithExamples")) {
        case true:
            if (examples[1]) {
                SelectedAction := "# ___________________________________________________`n" SelectedAction

                if (description != "") {
                    SelectedAction := "`n" "# ________________ " txt("Descrição da Action", "Action Description") " __________________`n"    "# " description "`n" SelectedAction
                }

                for key, example in examples
                    SelectedAction := "# @ " txt("exemplo", "example") " " A_Index ":`n# " example "`n" SelectedAction

                SelectedAction := "# ______________ " txt("Exemplos de", "Examples of")  " """ ActionScriptList """ ________________`n" SelectedAction "`n"
            } else {
                if (description != "") {
                    SelectedAction := "# ___________________________________________________`n" SelectedAction
                    SelectedAction := "`n" "# ________________ " txt("Descrição da Action", "Action Description") " __________________`n"    "# " description "`n" SelectedAction
                }
            }
    }





    if (actionScriptCode = "")
        ActionScriptNew := SelectedAction
    else
        ActionScriptNew := actionScriptCode "`n" SelectedAction

    try {
        GuiControl, ActionScriptGUI:, actionScriptCode, % ActionScriptNew
        SendMessage, 0x0115, 7, 0,, ahk_id %hactionScriptCode% ;WM_VSCROLL    
    } catch {
    }
return


getScreenCoordsActionScript:
    if (ActionScriptGUI.getMouseCoordinatesAction() = false) {
        Gui, ActionScriptGUI:Show
        Sleep, 50
        GuiControl, ActionScriptGUI:focus, actionScriptCode
    }
    ActionScriptGUI.abordGetMouseCoordsAction()

return




