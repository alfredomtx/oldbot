
class _AbstractGUI extends _BaseClass
{
    __New()
    {
        this._create()
    }

    /**
    * @return void
    */
    _beforeCreate()
    {
        this._destroy()
        this.beforeCreate()
    }

    /**
    * @abstract
    * @return void
    */
    beforeCreate()
    {
        abstractMethod()
    }

    /**
    * @return void
    */
    _create()
    {
        this._beforeCreate()
        this.create()
        this._show()
        this._afterCreate()
    }

    /**
    * @abstract
    * @return void
    */
    create()
    {
        abstractMethod()
    }

    /**
    * @return void
    */
    _afterCreate()
    {
        this.afterCreate()
    }

    /**
    * @abstract
    * @return void
    */
    afterCreate()
    {
        abstractMethod()
    }

    /**
    * @return void
    */
    _destroy()
    {
        this.destroy()
    }

    /**
    * @abstract
    * @return void
    */
    destroy()
    {
        abstractMethod()
    }

    /**
    * @return void
    */
    _show()
    {
        this.show()
    }

    /**
    * @abstract
    * @return void
    */
    show()
    {
        abstractMethod()
    }
}