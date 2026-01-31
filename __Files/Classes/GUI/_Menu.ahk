
Class _Menu
{
    static ICON_YOUTUBE := "Data\Files\Images\GUI\Icons\third_part\youtube.ico"


    __New()
    {
        this.tutorialMenuJsonDir := OldBotSettings.JsonFolder "\Menu\tutorials.json"
        this.youtubeIcon := "Data\Files\Images\GUI\Icons\third_part\youtube.ico"

        this.menus := {}
    }


    createAllMenus() {

    }

    loadTutorialMenuFromJSON() {
        file := this.tutorialMenuJsonDir
        if (!FileExist(file)) {
            Msgbox, 16, % A_ThisFunc, % "Missing file: """ A_WorkingDir "\" file """.", 10
            return
        }
        try {
            tutorialMenuJsonJson := new JSONFile(file)
        } catch e {
            Msgbox, 16, % A_ThisFunc, % "Failed to load life.json file:`n" e.Message "`n" e.What, 10
            return
        }
        this.tutorialMenuObj := tutorialMenuJsonJson.Object()
        ; msgbox, % serialize(this.tutorialMenuObj)

    }

    createTutorialMenuFromJSON() {
        global

        this.mainMenuName := "Tutorials"

        this.menus[this.mainMenuName] := {}

        Menu, Sub_VideoTutoriais, Add, % txt("Canal no YouTube", "YouTube Channel"), AbrirYoutube
        this.setIcon("Sub_VideoTutoriais", txt("Canal no YouTube", "YouTube Channel"), {"icon": "Data\Files\Images\GUI\Icons\third_part\youtube_main.ico", "size": 16})
        Menu, Sub_VideoTutoriais, Add

        this[this.mainMenuName "SubMenus"] := {}


        for parentMenu, items in this.tutorialMenuObj
        {
            menuName := this.mainMenuName "_" parentMenu

            this[this.mainMenuName "SubMenus"].Push(parentMenu)
            this.menus[this.mainMenuName][menuName] := {}
            ; msgbox, % serialize(this.menus[this.mainMenuName])
            ; msgbox, % menuName " = " serialize(items)

            for key, atributes in items
            {
                ; msgbox, % parentMenu "`n`n" key " = " serialize(atributes)
                this.menus[this.mainMenuName][menuName][atributes.text] := atributes.url
                ; msgbox, % this.menus[this.mainMenuName][parentMenu][atributes.text]
                this.createMenu(menuName, atributes.text, this.mainMenuName "MenuHandler", atributes, {"icon": this.youtubeIcon, "size": 16})

            }

            ; msgbox, % "aaa`n" serialize(this.menus[this.mainMenuName])

        }

        ; msgbox, % "this[" this.mainMenuName "SubMenus]`n" serialize(this[this.mainMenuName "SubMenus"])

        for key, parentMenu in this[this.mainMenuName "SubMenus"]
        {

            menuName := this.mainMenuName "_" parentMenu
            ; msgbox, % parentMenu "`n`n" ":" menuName
            try Menu, Sub_VideoTutoriais, Add, % parentMenu, % ":" menuName
            catch e {
                if (!A_IsCompiled)
                    throw e
            }
        }


        Menu, InfoMenu, Add, % "Videos", :Sub_VideoTutoriais
        try Menu, InfoMenu, Icon, % "Videos", Data\Files\Images\GUI\Icons\third_part\youtube.ico,0,16
        catch e {
            if (!A_IsCompiled)
                throw e
        }




    }

    createMenu(parentMenu, title, glabel, atributes := "", icon := "") {
        ; msgbox,, % A_ThisFunc, % "parentMenu = " parentMenu "`ntitle = " title "`natributes = " serialize(atributes) "`nicon = " serialize(icon)

        try Menu, %parentMenu%, Add, % title, % glabel
        catch e {
            if (!A_IsCompiled)
                Msgbox, 16, % A_ThisFunc, % "Error creating menu:`n- parentMenu: " parentMenu "`n- title: " title "`n- glabel: " glabel "`n`nError: " e.Message " | " e.What, 8
            return
        }

        if (icon.icon) {
            this.setIcon(parentMenu, title, icon)
        }

        if (atributes.enabled = false)
            this.disableMenu(parentMenu, title)
    }

    enableMenu() {
        try Menu, %parentMenu%, Enable, % title
        catch e {
            if (!A_IsCompiled)
                Msgbox, 16, % A_ThisFunc, % "Error:`n- parentMenu: " parentMenu "`n- title: " title "`n`nError: " e.Message " | " e.What, 8
            return
        }

    }

    disableMenu(parentMenu, title) {
        try Menu, %parentMenu%, Disable, % title
        catch e {
            if (!A_IsCompiled)
                Msgbox, 16, % A_ThisFunc, % "Error:`n- parentMenu: " parentMenu "`n- title: " title "`n`nError: " e.Message " | " e.What, 8
            return
        }

    }

    setIcon(parentMenu, title, icon)
    {
        if (instanceOf(icon.icon, _Icon)) {
            obj := icon.icon
            icon := {}
            icon.icon := obj.dllName
            icon.number := obj.number
        }

        try Menu, %parentMenu%, Icon, % title, % icon.icon, % (icon.number > 0 ? icon.number : 0), % icon.size
        catch e {
            if (!A_IsCompiled)
                Msgbox, 16, % A_ThisFunc, % "Error:`n- parentMenu: " parentMenu "`n- title: " title "`n- icon: " serialize(icon) "`n`nError: " e.Message " | " e.What, 8
            return
        }

    }

    subSaveMenuOptions() {

        this.createMenu("Sub_SaveMenu", LANGUAGE = "PT-BR" ? "Salvar script como..." : "Save script as...", "SaveScriptAsMenu", atributes, {})

        this.createMenu("Sub_SaveMenu", LANGUAGE = "PT-BR" ? "Salvar perfil como...`tCtrl+S" : "Save profile as...`tCtrl+S", "SalvarPerfil", atributes, {"icon": _Icon.get(_Icon.SETTINGS), "size": 16})

    }

    fileMenuCloseOptions() {
        this.createMenu("FileMenu", "Logout", "LogoutMenu", atributes := {}, {"icon": _Icon.get(_Icon.USER), "size": 16})
        this.createMenu("FileMenu", "Reload Bot`tAlt+R", "MenuHandler", atributes := {}, {"icon": _Icon.get(_Icon.RELOAD), "size": 16})
        this.createMenu("FileMenu", "E&xit", "CavebotGUIGuiClose", atributes := {}, {"icon": _Icon.get(_Icon.DELETE_ROUND), "size": 16})
    }


    createSubOpenFolderMenu() {

        this.createMenu("Sub_FoldersMenu", "Screenshots (bot)", "AbrirPastaScreenshots", atributes := {}, {})
        if (OldBotSettings.settingsJsonObj.configFile = "settings.json")
            this.createMenu("Sub_FoldersMenu", "Screenshots (Tibia)", "AbrirPastaScreenshotsTibia", atributes := {}, {})
        Menu, Sub_FoldersMenu, Add,

        this.createMenu("Sub_FoldersMenu", "OldBot", "AbrirPastaOldBot", atributes := {}, {})
        this.createMenu("Sub_FoldersMenu", "Cavebot", "AbrirPastaCavebot", atributes := {}, {})
        this.createMenu("Sub_FoldersMenu", "Executables", "OpenExecutablesFolder", atributes := {}, {})
        this.createMenu("Sub_FoldersMenu", "Images", "OpenFolderHandler", atributes := {}, {})

        this.createMenu("Sub_FoldersMenu", "JSON files", "OpenFolderHandler", atributes := {}, {})
        this.createMenu("Sub_FoldersMenu", "JSON (Memory)", "OpenFolderHandler", atributes := {}, {})

        Menu, Sub_FoldersMenu, Add,


        this.createMenu("Sub_FoldersMenu", "Alerts", "OpenFolderHandler", atributes := {}, {})
        this.createMenu("Sub_FoldersMenu", "Healing", "OpenFolderHandler", atributes := {}, {})
        this.createMenu("Sub_FoldersMenu", "Looting", "OpenFolderHandler", atributes := {}, {})
        this.createMenu("Sub_FoldersMenu", "Item Refill", "OpenFolderHandler", atributes := {}, {})

        this.createMenu("Sub_FoldersMenu", "NPCs", "OpenFolderHandler", atributes := {}, {})
        this.createMenu("Sub_FoldersMenu", "Reconnect", "OpenFolderHandler", atributes := {}, {})
        this.createMenu("Sub_FoldersMenu", "Sio", "OpenFolderHandler", atributes := {}, {})
        this.createMenu("Sub_FoldersMenu", "Support", "OpenFolderHandler", atributes := {}, {})
        this.createMenu("Sub_FoldersMenu", "Targeting", "OpenFolderHandler", atributes := {}, {})
    }
}
