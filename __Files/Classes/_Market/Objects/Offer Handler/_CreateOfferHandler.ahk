
class _CreateOfferHandler extends _OfferHandler
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(offer, type)
    {
        base.__New(offer, type)

        pt := "data,item,quantidade,preço,preço total,expiração,taxa do market,gasto em taxas total,balance"
        en := "date,item,amount,price,total price,ends at,market fee,fee expenses,balance"

        this.csv := new _Csv(_Csv.PATH(this.CSV_FILE), txt(pt, en))
    }

    /**
    * @return bool
    */
    run()
    {
        try {
            this.shouldIgnoreOffer()
        } catch e {
            return this.handleIgnoreOfferException(e)
        }

        return this.continueRun()
    }

    /**
    * @return bool
    */
    handleIgnoreOfferException(e)
    {
        switch (e.What) {
            case "NoOffersException":
                return this.noOffersAvailableFlow()
            case "DisabledException":
                return false
            default: 
                return this.ignoreException(e)
        }
    }

    /**
    * @return bool
    */
    continueRun()
    {
        this.scanOffer()

        try {
            return this.runActionsOrIgnore()
        } catch e {
            if (e.What == "MultipleOffersException") {
                throw e 
            }

            this.ignoreLog(e.Message)

            return false
        }
    }

    /**
    * @return bool
    */
    runActionsOrIgnore()
    {
        try {
            this.offer.rejectOffer(this.scannedOffer.getPrice())
        } catch e {
            switch (e.What) {
                    /**
                    * Cancel any existing offers if the current price is rejected to be covered
                    */
                case "OfferPriceException":
                    this.cancelOfferIfHasLastCreated()
            }

            throw e
        }

        return this.actOnOffer()
    }

    /**
    * @return bool
    * @throws
    */
    actOnOffer()
    {
        if (this.recognizeOfferOwnership()) {
            return true
        }

        this.cancelOffer()

        return this.createOffer()
    }

    recognizeOfferOwnership()
    {
        action := new _RecognizeOfferOwnership(this.offer, this.scannedOffer)
            .setLogger(this.info.bind(this))
        if (action.run()) {
            return true
        }

        this.doesNotOwnOffer()

        return false
    }

    /**
    * @return void
    * @throws
    */
    doesNotOwnOffer()
    {
    }

    cancelOfferIfHasLastCreated()
    {
        value := new _MarketItemSettings().read("last" this.offer.getType() "Offer", this.offer.getItem())
        if (value != "" && !this.offer.hasLastCreated()) {
            this.info(txt("Nenhuma oferta criada anteriormente para ser cancelada.", "No offer created previously to be cancelled."))
        } else {
            this.cancelOffer()
            this.offer.unsetLastCreated()
        }
    }

    cancelOffer()
    {
        try {
                new _CancelOffer(this.offer)
                .setLogger(this.info.bind(this))
                .run()
        } catch e {
            ; continue the offer creation when the offer is not found
            if (e.What == "OfferNotFoundException") {
                this.info(e.Message)
            } else {
                throw e 
            }
        }
    }

    /**
    * @return bool
    */
    createOffer()
    {
        this.offer.balanceCondition(this.balance)

        return this.initializeCreateOffer()
            .setPrice(this.offer.getOfferCreationPrice(this.scannedOffer.getPrice()))
            .run()
    }

    initializeCreateOffer()
    {
        return new _CreateOffer(this.offer)
            .setLogger(this.info.bind(this))
            .setExceptionLogger(this.getExceptionLogger())
            .setCsv(this.csv)
    }

    /**
    * if there is no offer available, just create a new one with the minimum amount
    * @return bool
    */
    noOffersAvailableFlow()
    {
        try {
            this.cancelOfferIfHasLastCreated()

            return this.initializeCreateOffer()
                .setPrice(this.offer.getOfferCreationPrice(0))
                .run()
        } catch e {
            this.ignoreLog(e.Message)

            return false
        }
    }

    ignoreException(e)
    {
        this.ignoreLog(e.Message)

        return false
    }
}