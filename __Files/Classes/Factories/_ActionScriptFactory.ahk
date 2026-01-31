#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

class _ActionScriptFactory extends _BaseClass
{
    /**
    * @param string actionName
    * @return _AbstractActionScript
    * @throws
    */
    __New(actionName, functionValues := "")
    {
        class := _ActionScripts.get(actionName)
        if (!class) {
            throw Exception(txt("Action """ actionName """ não existe.", "Action """ actionName """ does not exist."))
        }

        return new class()
    }
}