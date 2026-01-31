#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

class _NavigationActionFactory extends _BaseClass
{
    /**
    * @param string action
    * @param ?int number
    * @return _AbstractNavigationAction
    * @throws
    */
    __New(action, number := "")
    {
        classLoaded(action, %action%)

        switch (action) {
            case _NavigationAction.__Class:
                return new _NavigationAction(number)
        }

        return new %action%()
    }
}