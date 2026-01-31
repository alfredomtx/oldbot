
class _MarketItemCollection extends _BaseClass
{
    static CACHE

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(items := "", cached := true)
    {
        if (!items && cached) {
            if (_MarketItemCollection.CACHE) {
                return _MarketItemCollection.CACHE
            }

            return this.refresh()
        }

        this.setItems(items ? items : Array())
        this.identifier := ""
    }

    empty()
    {
        return new this("", false)
    }

    add(item) 
    {
        this._items.Push(item)

        return this
    }

    load()
    {
        this.refresh()

        return this.setItems(_MarketItemCollection.CACHE.items())
    }

    refresh()
    {
        _MarketItemCollection.CACHE := ""
        _MarketItemCollection.CACHE := new this(new _MarketItemSettings().getKeys())
        _MarketItemCollection.CACHE.identifier := "cache"

        return _MarketItemCollection.CACHE
    }

    setting(item, key)
    {
        return new _MarketItemSettings().get(key, item)
    }

    ;#region Getters
    items()
    {
        return this._items
    }
    ;#endregion

    ;#region Setters
    setItems(items)
    {
        this._items := items

        return this
    }
    ;#endregion

    ;#region Attributes
    count()
    {
        return this.items().Count()
    }
    ;#endregion

    ;#endregion
    isEmpty()
    {
        return this.count() == 0
    }
    ;#endregion

    ;#region States
    enabled()
    {
        instance := this.empty()
        for, _, item in this.items() {
            if (!this.setting(item, "enabled")) {
                continue
            }

            instance.add(item)
        }

        return instance
    }
    ;#endregion

    ;#region Factory
    ;#endregion
}