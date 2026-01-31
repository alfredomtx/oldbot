
class _OfferLog extends _OfferLog.Getters
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(offerExecution)
    {
        _Validation.instanceOf("offerExecution", offerExecution, _OfferExecution)

        this.offerExecution := offerExecution
    }

    class Getters extends _OfferLog.Setters
    {
    }

    class Setters extends _OfferLog.Predicates
    {
    }

    class Predicates extends _OfferLog.Factory
    {
    }

    class Factory extends _OfferLog.Base
    {
    }

    class Base extends _BaseClass
    {
    }
}