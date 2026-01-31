global pBitmapClientScreen
global pBitmapClientScreen

Class _ImagesConfig
{

    __New()
    {

        if (!IsObject(TibiaClient))
            throw Exception("TibiaClient class not included")


        this.rightClickMenusVAR := 50

        this.pixelColors()

        this.foldersSetup()

        this.cavebotImages()
        this.clientImages()
        this.healingImages()
        this.reconnectImages()
        ; this.sioImages()
        this.targetingImages()

    }

    pixelColors() {
        this.pinkColor := "0xFFFF00FF"
        this.pinkColorTrans := "0xFF00FF"

        this.battleListLifeBar := {}
        this.battleListLifeBar.Push("0x00C000") ; greenFull
        this.battleListLifeBar.Push("0x60C060") ; green
        this.battleListLifeBar.Push("0xC0C000") ; yellow
        this.battleListLifeBar.Push("0xC03030") ; red
    }

    foldersSetup() {
        this.npcsFolder := "Data\NPCs"

        this.folder := "Data\Files\Images"


        this.GUIfolder := this.folder "\GUI"
        this.alertsFolder := this.folder "\Alerts"
        this.cavebotFolder := this.folder "\Cavebot"
        this.clientFolder := this.folder "\Client"
        this.clientNumbersFolder := this.clientFolder "\numbers"
        this.clientChatFolder := this.clientFolder "\chat"
        this.clientButtonsFolder := this.clientFolder "\buttons"
        this.clientMenusFolder := this.clientFolder "\menus"
        this.clientNumbersFolder := this.clientFolder "\numbers"
        this.clientChatFolder := this.clientFolder "\chat"
        this.clientButtonsFolder := this.clientFolder "\buttons"
        this.clientOpenMenuFolder := this.clientMenusFolder "\open"

        this.corpsesFolder := this.folder "\Corpses"
        this.cooldownBarFolder := this.folder "\Cooldown Bar"
        this.healingFolder := this.folder "\Healing"
        this.healingLifeFolder := this.healingFolder "\life"
        this.healingLifeBarFolder := this.healingLifeFolder "\bar"
        this.healingLifePixelFolder := this.healingLifeFolder "\pixel"
        this.healingManaFolder := this.healingFolder "\mana"
        this.healingManaBarFolder := this.healingManaFolder "\bar"
        this.healingManaPixelFolder := this.healingManaFolder "\pixel"
        this.healingLifeFolder := this.healingFolder "\life"
        this.healingLifeBarFolder := this.healingLifeFolder "\bar"
        this.healingLifePixelFolder := this.healingLifeFolder "\pixel"
        this.healingManaFolder := this.healingFolder "\mana"
        this.healingManaBarFolder := this.healingManaFolder "\bar"
        this.healingManaPixelFolder := this.healingManaFolder "\pixel"

        this.fishingFolder := this.folder "\Fishing"
        this.itemRefillFolder := this.folder "\Item Refill"
        this.lootingFolder := this.folder "\Looting"
        this.supportFolder := this.folder "\Support"
        this.mainBackpacksFolder := this.folder "\Main Backpacks"
        this.reconnectFolder := this.folder "\Reconnect"
        this.sioFolder := this.folder "\Sio"
        this.statusBarFolder := this.folder "\Status Bar"
        this.targetingFolder := this.folder "\Targeting"
        this.lifeBarsFolder := this.targetingFolder "\Life Bars"
        this.othersFolder := this.folder "\Others"

        this.actionBarFolder := this.cavebotFolder "\Action Bar"
        this.battleListFolder := this.targetingFolder "\Battle List"
        this.battleListTitleFolder := this.battleListFolder "\title"
        this.battleListEmptyFolder := this.battleListFolder "\empty"
        this.battleListLifeBarsFolder := this.battleListFolder "\life_bars"
        this.battleListButtonsFolder := this.targetingFolder "\Battle List\buttons"
        this.cavebotNumbersFolder := this.cavebotFolder "\Numbers"
        this.cavebotNumbersSkillWindowFolder := this.cavebotFolder "\Numbers"
        this.charAreaFolder := this.cavebotFolder "\Char Area"
        this.depositerFolder := this.cavebotFolder "\Depositer"
        this.stashFolder := this.cavebotFolder "\Stash"
        this.minimapFolder := this.cavebotFolder "\Minimap"
        this.minimapMarkersFolder := this.minimapFolder "\Markers"
        this.minimapCenterFolder := this.minimapFolder "\center"
        this.minimapZoomPlusFolder := this.minimapFolder "\plus"
        this.minimapZoomMinusFolder := this.minimapFolder "\minus"
        this.npcTradeFolder := this.cavebotFolder "\NPC Trade"
        this.npcItemsFolder := this.npcTradeFolder "\Items"
    }

    clientImages() {
        this.chatButtons := "chat_buttons.png"
    }


    cavebotImages() {

        this.purse := "purse.png"

        this.chatDisabled := "chat_disabled.png"
        this.chatOpened := "chat_opened.png"

        this.minimap := {}

        this.charArea := {}
        this.charArea.charArea1VAR := 55
        this.charArea.charArea1_1 := this.cooldownBarFolder "\" "attack.png"
        this.charArea.charArea1_2 := this.cooldownBarFolder "\" "support.png"

        this.charArea.charArea2_1 := this.charAreaFolder "\" "CharArea2_1.png"
        this.charArea.charArea2_1VAR := 30
        this.charArea.charArea2_2 := this.charAreaFolder "\" "CharArea2_2.png"
        this.charArea.charArea2_2VAR := 30
        this.charArea.charArea2_3 := this.charAreaFolder "\" "CharArea2_3.png"
        this.charArea.charArea2_3VAR := 30
        this.charArea.charArea2_4 := this.charAreaFolder "\" "CharArea2_4.png"
        this.charArea.charArea2_4VAR := 30


        this.depositer := {}
        this.depositer.locker := "locker_opened.png"
        this.depositer.depotWindow := "depot_window.png"

        this.skillWindow := {}
        this.skillWindow.capacity := this.cavebotNumbersFolder "\capacity.png"
        this.skillWindow.level := this.cavebotNumbersFolder "\level.png"
        this.skillWindow.stamina := this.cavebotNumbersFolder "\stamina.png"
        this.skillWindow.soulpoints := this.cavebotNumbersFolder "\soulpoints.png"

        this.tradeWindow := {}

        this.stash := {}
        this.stash.stashWindow := "stash_window.png"
        this.stash.stashBox := "stash_box.png"
        this.stash.retrieveItemWindow := "retrieve_items_window.png"
    }

    healingImages() {
    }

    lootingImages() {

    }

    targetingImages() {
        this.following := this.targetingFolder "\" "following.png"
        this.followingVAR := 30
        this.attackingCreature := this.targetingFolder "\" "attacking_creature.png"
        this.redPixel := this.targetingFolder "\" "red_pixel.png"
    }

    reconnectImages() {
        this.reconnect := {}
        this.reconnect.cancelButton := this.reconnectFolder "\" "cancel_button.png"
        this.reconnect.connecting := this.reconnectFolder "\" "connecting.png"
        this.reconnect.email := this.reconnectFolder "\" "email.png"
        this.reconnect.sorry := this.reconnectFolder "\" "sorry.png"
        this.reconnect.selectCharacter := this.reconnectFolder "\" "select_character.png"
    }

}