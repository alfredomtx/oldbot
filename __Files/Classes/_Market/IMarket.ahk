#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_OCR.ahk


#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\_MarketModule.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\_MarketExe.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Settings\_MarketSettings.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Settings\_MarketItemSettings.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Settings\_MarketIniSettings.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\API\Requests\_MarketbotRequest.ahk

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\_Market.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\GUI\_MarketbotHUD.ahk

;#region Actions
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_CancelOffer.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_CheckboxCheck.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_CreateOffer.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_RecognizeOfferOwnership.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_SelectAmount.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_ScanOffer.ahk

; read
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\Read\_ReadAmount.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\Read\_ReadBalance.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\Read\_ReadInteger.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\Read\_ReadText.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\Read\_ReadSelectedAmount.ahk
;#Endregion


;#region Objects
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\_Csv.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\_OfferLog.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\_MarketbotLicense.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\_MarketItemCollection.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\_MarketCooldown.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\_ScannedOffer.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\_UserOffer.ahk
;#Endregion

;#region Objects - Offer Handler
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Offer Handler\_AcceptOfferHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Offer Handler\_BuyOfferHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Offer Handler\_CreateOfferHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Offer Handler\_CreateBuyOfferHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Offer Handler\_CreateSellOfferHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Offer Handler\_OfferHandler.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Offer Handler\_SellOfferHandler.ahk
;#Endregion


;#region Objects - Item Offer
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Item Offer\_ItemOffer.ahk
; Buy
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Item Offer\_BuyItemOffer.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Item Offer\_CreateBuyItemOffer.ahk
; Sell
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Item Offer\_CreateSellItemOffer.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Objects\Item Offer\_SellItemOffer.ahk
;#Endregion


;#region Client Areas
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\_ItemsListArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\_FirstMarketItemArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\_MarketPositions.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\_MarketWindowArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\_SelectedMarketItemArea.ahk

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\Buy\_BuyOffersArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\Sell\_SellOffersArea.ahk

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\Buy\_MyOffersCancelBuyButtonArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\Sell\_MyOffersCancelSellButtonArea.ahk

;#region Client Areas - OCR
; Buy
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\_BalanceArea.ahk

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Buy\_BuySelectedAmountArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Buy\_MyOffersBuyItemNameArea.ahk
; Sell
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Sell\_SellSelectedAmountArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Sell\_MyOffersSellItemNameArea.ahk
; Offer
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\_CreateOfferSelectedAmountArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\_PiecePriceArea.ahk
;#Endregion

;#region Client Areas OCR - Row
; Buy
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Buy\Row\_BuyAmountArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Buy\Row\_BuyEndsAtArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Buy\Row\_BuyNameArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Buy\Row\_BuyPriceArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Buy\Row\_BuyTotalPriceArea.ahk
; Sell
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Sell\Row\_SellAmountArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Sell\Row\_SellEndsAtArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Sell\Row\_SellNameArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Sell\Row\_SellPriceArea.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Client Areas\OCR\Sell\Row\_SellTotalPriceArea.ahk
;#Endregion

