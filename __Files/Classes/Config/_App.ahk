
class _App extends _App.Getters
{
    static IDENTIFIER := "OldBot PRO"
    static GUI_CLASS := "Chrome_WidgetWin_1"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        guardAgainstInstantiation(this)
    }

    class Getters extends _App.Setters
    {
    }

    class Setters extends _App.Predicates
    {
    }

    class Predicates extends _App.Factory
    {
    }

    class Factory extends _App.Base
    {
    }

    class Base extends _BaseClass
    {
    }
}