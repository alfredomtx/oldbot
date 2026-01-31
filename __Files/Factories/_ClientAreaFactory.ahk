#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

/**
* @factory - new instance returns an instance of another class
*/
class _ClientAreaFactory extends _BaseClass
{
    /**
    * @return _AbstractClientArea
    * @throws
    */
    __New(areaName)
    {
        if (!areaName) {
            return new _WindowArea()
        }

        areas := this.getAreas()
        if (!areas[areaName]) {
            areaName := this.resolveAreaThatStartsWith(areaName)
        }

        if (!areas[areaName]) {
            throw Exception("Invalid client area name: " areaName)
        }

        class := areas[areaName]

        return new %class%()
    }

    /**
    * @param string areaName
    * @return ?string
    */
    resolveAreaThatStartsWith(areaName)
    {
        for name, _ in this.getAreas() {
            if (_Str.startsWith(name, areaName)) {
                return name
            }
        }
    }

    /**
    * @return array<string, string>
    */
    getAreas()
    {
        static areas
        if (areas) {
            return areas
        }

        areas := {}
        areas[_ActionBarArea.NAME] := _ActionBarArea.__Class
        areas[_ChatArea.NAME] := _ChatArea.__Class
        areas[_ChatButtonArea.NAME] := _ChatButtonArea.__Class
        areas[_CooldownBarArea.NAME] := _CooldownBarArea.__Class
        areas[_GameWindowArea.NAME] := _GameWindowArea.__Class
        ; areas[_FirstCustomArea.NAME] := _FirstCustomArea.__Class
        areas[_MinimapArea.NAME] := _MinimapArea.__Class
        areas[_PrivateMessageArea.NAME] := _PrivateMessageArea.__Class
        ; areas[_SecondCustomArea.NAME] := _SecondCustomArea.__Class
        areas[_SideBarsArea.NAME] := _SideBarsArea.__Class
        areas[_SideBarLeftArea.NAME] := _SideBarLeftArea.__Class
        areas[_SideBarRightArea.NAME] := _SideBarRightArea.__Class
        areas[_StatusBarArea.NAME] := _StatusBarArea.__Class
        ; areas[_ThirdCustomArea.NAME] := _ThirdCustomArea.__Class
        areas[_WindowArea.NAME] := _WindowArea.__Class

        /*
        Battle list
        */
        areas[_BattleListArea.NAME] := _BattleListArea.__Class
        areas[_BattleListPixelArea.NAME] := _BattleListPixelArea.__Class
        areas[_PlayersBattleListArea.NAME] := _PlayersBattleListArea.__Class
        areas[_SioBattleListArea.NAME] := _SioBattleListArea.__Class

        /*
        Equipment
        */
        areas[_EquipmentArea.NAME] := _EquipmentArea.__Class
        areas[_ArmorArea.NAME] := _ArmorArea.__Class
        areas[_AmuletArea.NAME] := _AmuletArea.__Class
        areas[_BootsArea.NAME] := _BootsArea.__Class
        areas[_HelmetArea.NAME] := _HelmetArea.__Class
        areas[_LeftHandArea.NAME] := _LeftHandArea.__Class
        areas[_LegsArea.NAME] := _LegsArea.__Class
        areas[_RightHandArea.NAME] := _RightHandArea.__Class
        areas[_RingArea.NAME] := _RingArea.__Class
        areas[_ShieldArea.NAME] := _ShieldArea.__Class
        areas[_TorchArea.NAME] := _TorchArea.__Class


        /*
        Market
        */
        for _, class in this.getMarketAreas() {
            areas[class.NAME] := class.__Class
        }

        return areas
    }

    /**
    * @return array<string, bool>
    */
    getDisplayAreas()
    {
        static displayAreas
        if (displayAreas) {
            return displayAreas
        }

        hiddenAreas := {}
        hiddenAreas[_BattleListPixelArea.NAME] := true
        hiddenAreas[_ChatButtonArea.NAME] := true
        hiddenAreas[_PrivateMessageArea.NAME] := true

        for _, class in this.getMarketAreas() {
            hiddenAreas[class.NAME] := true
        }

        displayAreas := this.getAreas().Clone()

        for area, _ in hiddenAreas {
            displayAreas.Delete(area)
        }

        return displayAreas
    }

    /**
    * @param string selected
    * @return string
    */
    getDropdown(selected := "windowArea")
    {
        static dropdownOptions
        if (dropdownOptions) {
            return dropdownOptions
        }

        dropdownOptions := ""
        for name, _ in this.getDisplayAreas() {
            dropdownOptions .= name "|" (name = selected ? "|" : "")
        }

        return dropdownOptions
    }

    /**
    * @return string
    */
    getString()
    {
        static stringOptions
        if (stringOptions) {
            return stringOptions
        }

        stringOptions := this.getDropdown("")
        stringOptions := StrReplace(stringOptions, "|", " | ")
        return stringOptions
    }

    /**
    * @return array<Class>
    */
    getMarketAreas()
    {
        static marketAreas
        if (marketAreas) {
            return marketAreas
        }

        marketAreas := {}
        marketAreas.Push(_BalanceArea)
        marketAreas.Push(_CreateOfferSelectedAmountArea)
        marketAreas.Push(_FirstMarketItemArea)
        marketAreas.Push(_ItemsListArea)
        marketAreas.Push(_MarketWindowArea)
        marketAreas.Push(_PiecePriceArea)
        marketAreas.Push(_SelectedMarketItemArea)


        marketAreas.Push(_SellAmountArea)
        marketAreas.Push(_SellEndsAtArea)
        marketAreas.Push(_SellNameArea)
        marketAreas.Push(_SellOffersArea)
        marketAreas.Push(_SellPriceArea)
        marketAreas.Push(_SellSelectedAmountArea)
        marketAreas.Push(_SellTotalPriceArea)
        marketAreas.Push(_MyOffersCancelSellButtonArea)
        marketAreas.Push(_MyOffersSellItemNameArea)

        marketAreas.Push(_BuyAmountArea)
        marketAreas.Push(_BuyEndsAtArea)
        marketAreas.Push(_BuyNameArea)
        marketAreas.Push(_BuyOffersArea)
        marketAreas.Push(_BuyPriceArea)
        marketAreas.Push(_BuySelectedAmountArea)
        marketAreas.Push(_BuyTotalPriceArea)
        marketAreas.Push(_MyOffersCancelBuyButtonArea)
        marketAreas.Push(_MyOffersBuyItemNameArea)

        return marketAreas
    }
}