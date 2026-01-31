
/**
* @property string type
* @property string item
* @property string playerName
* @property string endsAt
* @property int amount
* @property int price
* @property int totalPrice
*/
class _ScannedOffer extends _BaseClass
{
    static CSV_FILE := "scanned_offers.csv"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(item)
    {
        this.item := item
        this.type := ""

        this.playerName := ""
        this.amount := ""
        this.price := ""
        this.totalPrice := ""
        this.endsAt := ""

        header := "date,offer_type,player_name,item,amount,price,total_price,ends_at"

        this.csv := new _Csv(_Csv.PATH(this.CSV_FILE), header)
    }

    toCsv()
    {
        return now() "," this.type "," _Str.quoted(this.item) "," _Str.quoted(this.playerName) "," this.amount "," this.price "," this.totalPrice "," _Str.quoted(this.endsAt)
    }

    log()
    {
        this.csv.log(this.toCsv())
    }

    ;#region Getters
    getType()
    {
        return this.type
    }

    getItem()
    {
        return this.item
    }

    getPlayerName()
    {
        return this.playerName
    }

    getAmount()
    {
        return this.amount
    }

    getPrice()
    {
        return this.price
    }

    getTotalPrice()
    {
        return this.totalPrice
    }

    getEndsAt()
    {
        return this.endsAt
    }

    ;#endregion

    ;#region Setters
    setType(type)
    {
        this.type := type
        return this
    }

    setItem(item)
    {
        this.item := item
        return this
    }

    setPlayerName(playerName)
    {
        this.playerName := playerName
        return this
    }

    setAmount(amount)
    {
        _Validation.number("amount", amount)
        this.amount := amount
        return this
    }

    setPrice(price)
    {
        _Validation.number("price", price)
        this.price := price
        return this
    }

    setTotalPrice(totalPrice)
    {
        _Validation.number("totalPrice", totalPrice)
        this.totalPrice := totalPrice
        return this
    }

    setEndsAt(endsAt)
    {
        this.endsAt := StrReplace(endsAt, ",", "")
        return this
    }
    ;#endregion
}