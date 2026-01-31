
class _AbstractConfigClass extends _BaseClass
{
    __New()
    {
        guardAgainstInstantiation(this)
    }

    /**
    * @param string className
    * @param mixed class
    * @return mixed
    * @throws
    */
    validateClass(className, class, expectedClass)
    {
        validateClass(className, class, expectedClass)

        return class
    }


    getList()
    {
        abstractMethod()
    }

    /**
    * @param string key
    * @return null|mixed
    */
    get(key)
    {
        return this.getList()[key]
    }


    /**
    * @param string key
    * @return bool
    */
    exists(key)
    {
        return this.get(key) ? true : false
    }
}