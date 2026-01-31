#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_Loggable.ahk

class _MarketAction extends _Loggable
{
    __New(offer)
    {
        _Validation.instanceOf("offer", offer, _ItemOffer)

        this.offer := offer
        this.simulation := new _MarketIniSettings().get("simulation")
    }

    settings(key, value := "")
    {
        if (value != "") {
            return new _MarketItemSettings().set(key, value, this.offer.item)
        }

        return new _MarketItemSettings().get(key, this.offer.item)
    }

    /**
    * @return mixed
    */
    run()
    {
        abstractMethod()
    }

    searchAndClickOkButton()
    {
        /**
        * Rubinot coins have a "processing request" window after creating the offer, so we need to click on the "OK" button to close it.
        */
        _search := new _SearchOkButton()
        if (_search.found()) {
            this.log(txt("Clicando no botão ""OK"" para fechar a janela de ""processing request"".", "Clicking on the ""OK"" button to close the ""processing request"" window."))
            _search.click()
            sleep(100, 200)
        }
    }
}