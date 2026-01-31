
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Action Script\Actions\_AbstractActionScript.ahk

class _AbstractDepositAction extends _AbstractActionScript
{
    /**
    * @abtract
    * @return bool
    */
    isIncompatible()
    {
        return !isTibia13()
    }
}