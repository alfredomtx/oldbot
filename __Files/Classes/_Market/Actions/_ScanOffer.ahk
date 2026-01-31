#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_MarketAction.ahk

class _ScanOffer extends _MarketAction
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return _ScannedOffer
    * @throws
    */
    run()
    {
        _Logger.log(A_ThisFunc)

        t := new _Timer()

        this.log(txt("Reconhecendo primeira oferta...", "Recognizing first offer..."))

        playerName := new _ReadText(this.class(_BuyNameArea, _SellNameArea)).run()
        amount := new _ReadAmount(this.class(_BuyAmountArea, _SellAmountArea)).run()
        price := new _ReadInteger(this.class(_BuyPriceArea, _SellPriceArea)).run()
        totalPrice := new _ReadInteger(this.class(_BuyTotalPriceArea, _SellTotalPriceArea)).run()
        endsAt := new _ReadText(this.class(_BuyEndsAtArea, _SellEndsAtArea)).run()

        scannedOffer := new _ScannedOffer(this.offer.getItem())
            .setType(this.offer.getType())
            .setPlayerName(playerName)
            .setAmount(amount)
            .setPrice(price)
            .setTotalPrice(totalPrice)
            .setEndsAt(endsAt)

        scannedOffer.log()

        price := txt("preço", "price") ": " scannedOffer.getPrice()
        totalPrice := txt("preço total", "total price") ": " scannedOffer.getTotalPrice()
        amount := txt("quantidade", " amount") ": " scannedOffer.getAmount()
        endsAt := txt("expiração", "ends at") ": " scannedOffer.getEndsAt()

        string := _A.join(Array(price, totalPrice,  amount, endsAt), ", ")

        this.log("Primeira oferta, name: " _Str.quoted(scannedOffer.getPlayerName()) ", " string " (" lang("elapsed", false) " " t.seconds() " sec).")

        this.offer.updateLastChecked()

        return scannedOffer
    }

    class(buy, sell)
    {
        return this.offer.getAreaIdentifier() == "buy" ? new buy() : new sell()
    }
}