global creaturesFile
global creaturesObj

global creaturesImageFile
global creaturesImageObj

global customCreaturesImageFile
global customCreaturesImageObj




/*
Class that handles creatures.json(creatureObj) and creatures_image.json (creaturesImageObj)
*/

Class _CreaturesHandler
{
    __New(loadJson := false)
    {
        this.creaturesJsonFolder := OldbotSettings.JsonFolder "\Creatures"

        if (loadJson = true) {

            if (!FileExist(this.creaturesJsonFolder "\creatures.json"))
                throw Exception("JSON file doesn't exist: " this.creaturesJsonFolder "\creatures.json")

            if (!FileExist(this.creaturesJsonFolder "\creatures_image.json"))
                throw Exception("JSON file doesn't exist: " this.creaturesJsonFolder "\creatures_image.json")

            creaturesFile := new JSONFile(this.creaturesJsonFolder "\creatures.json")
            creaturesObj := creaturesFile.Object()

            creaturesImageFile := new JSONFile(this.creaturesJsonFolder "\creatures_image.json")
            creaturesImageObj := creaturesImageFile.Object()
            this.loadOtherCreaturesJsons()

        }

    }

    loadOtherCreaturesJsons() {

        fileName := StrReplace(OldbotSettings.settingsJsonObj.configFile, "settings_", "")
        fileLoad := this.creaturesJsonFolder "\creatures_image_" fileName

        if (!FileExist(fileLoad)) {
            if (OldbotSettings.settingsJsonObj.configFile != "settings.json")
                FileAppend, % "", % fileLoad
            return
        }


        customCreaturesImageFile := new JSONFile(fileLoad)
        customCreaturesImageObj := customCreaturesImageFile.Object()

        for itemName, atributes in customCreaturesImageObj
        {

            if (creaturesImageObj.hasKey(itemName))
                creaturesImageObj[itemName] := {}
            creaturesImageObj[itemName] := atributes
            ; msgbox, % itemName "`n" serialize(atributes)
        }

    }

    addCreatureImage(creatureName, image) {
        ; if is compiled and if the creature image already exists, don't override
        if (A_IsCompiled) {
            if (creaturesImageObj[creatureName])
                return
        }
        if (!creaturesImageObj[creatureName])
            creaturesImageObj[creatureName] := {}

        if (customCreaturesImageFile) && (customCreaturesImageObj[creatureName] = "")
            customCreaturesImageObj[creatureName] := {}


        this.setCreatureAtribute(creatureName, "image", image)
        this.setCreatureAtribute(creatureName, "timestamp", A_Now)
        ; msgbox, % creatureName "`n" serialize(customCreaturesImageObj[creatureName])

        this.saveCreatures()
    }

    /**
    * @return void
    * @throws
    */
    validateName(name)
    {
        if (name = "")
            throw Exception("Write a name for the new creature.")

        if (StrLen(name) < 3)
            throw Exception("Name is too short, less than 3 characters.")
    }

    /**
    * @return void
    * @throws
    */
    validateCreatureAddTargetList(name)
    {
        this.validateName(name)

        if (creaturesObj.hasKey(name))
            throw Exception( """" name """ is already in the creatures list.")
    }

    /**
    * @return string
    * @throws
    */
    addCreatureInputBox()
    {
        InputBox, name, % txt("Adicionar nova criatura na lista", "Add new creature to the list"), % txt("Nome da criatura", "Creature name:"),,350,105
        if (ErrorLevel = 1) {
            throw Exception(ErrorLevel)
        }

        return name
    }

    /**
    * @return void
    */
    addCreatureToCreaturesList()
    {
        try {
            NewCreatureName := this.addCreatureInputBox()
            this.validateCreatureAddTargetList(NewCreatureName)
        } catch e {
            if (e.Message == 1) {
                return
            }

            throw e
        }


        Gui, AddCreatureGUI:Hide

        stringlower, NewCreatureName, NewCreatureName

        creaturesImageObj[NewCreatureName] := {}
        creaturesObj[NewCreatureName] := {}

        creaturesFile.Fill(creaturesObj)
        creaturesFile.Save(true)

        Gui, AddCreatureGUI:Show
        GuiControl, AddCreatureGUI:, searchFilterCreatureName, % NewCreatureName

        ; TargetingGUI.LoadCreatureListLV(NewCreatureName, searchFilterExactCreatureName, searchFilterHaveImage)
    }

    setCreatureAtribute(creatureName, atribute, value := "") {
        if (customCreaturesImageFile) && (customCreaturesImageObj[creatureName] != "")
            customCreaturesImageObj[creatureName][atribute] := value
        else
            creaturesImageObj[creatureName][atribute] := value
    }


    saveCreatures() {
        ; msgbox, % A_ThisFunc
        Gui, CarregandoCavebot:Destroy
        Gui, CarregandoCavebot:-Caption +Border +Toolwindow +AlwaysOnTop
        Gui, CarregandoCavebot:Add, Progress, y+8 HwndpHwnd1 +0x8 w120
        Gui, CarregandoCavebot:Show, NoActivate,
        PostMessage,0x40a,1,38,, ahk_id %pHwnd1%

        if (customCreaturesImageFile) {
            customCreaturesImageFile.Fill(customCreaturesImageObj)
            customCreaturesImageFile.Save(true)
            Gui, CarregandoCavebot:Destroy
            return
        }

        creaturesImageFile.Fill(creaturesImageObj)
        creaturesImageFile.Save(true)
        Gui, CarregandoCavebot:Destroy
    }

} 