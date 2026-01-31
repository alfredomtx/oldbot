#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_MarketAction.ahk

class _RecognizeOfferOwnership extends _MarketAction
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(offer, scannedOffer)
    {
        base.__New(offer)

        _Validation.instanceOf("scannedOffer", scannedOffer, _ScannedOffer) 
        this.scannedOffer := scannedOffer
    }

    /**
    * @return bool
    * @throws
    */
    run()
    {
        this.log(txt("Checando se a primeira oferta é sua.", "Checking if the first offer is yours."))
        result := this.execute()

        this.log(result ? txt("A primeira oferta é sua, nenhuma oferta a ser coberta.", "The first offer is yours, no offer to be covered.") : txt("A primeira oferta não é sua.", "The first offer is not yours."))

        return result
    }

    execute()
    {
        type := this.offer.type
        if (!this.offer.hasLastCreated()) {
            this.log(txt("Nenhuma oferta de " _Str.quoted(type) " criada anteriormente.", "No " _Str.quoted(type) " offer created previously."))

            return false
        }

        if (this.offer.settings("createAnonymousOffers")) {
            player := this.scannedOffer.getPlayerName()

            if (player != "anonymous") {
                this.log(txt("Player da oferta(" player ") é diferente de ""anonymous"".", "Offer player(" player ") is different from ""anonymous""."))

                return false
            }
        }

        endsAt := this.scannedOffer.getEndsAt()
        createdEndsAt := this.offer.getLastCreatedEndsAt()
        if (endsAt != createdEndsAt) {
            this.log(txt("""Ends at"" da oferta(" endsAt ") é diferente do criado anteriormente(" createdEndsAt ").", "Offer ""Ends at""(" endsAt ") is different from the created previously(" createdEndsAt ")."))

            return false
        }

        price := this.scannedOffer.getPrice()
        createdPrice := this.offer.getLastCreatedPrice()
        if (price != createdPrice) {
            this.log(txt("Preço da oferta(" price ") é diferente do preço criado anteriormente(" createdPrice ").", "Offer price(" price ") is different from the price created previously(" createdPrice ")."))

            return false
        }

        return true
    }
}