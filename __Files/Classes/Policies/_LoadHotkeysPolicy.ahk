

class _LoadHotkeysPolicy extends _BaseClass
{
    /**
    * @return bool
    */
    run()
    {
        return !isTibia13() || isRubinot()
    }
}