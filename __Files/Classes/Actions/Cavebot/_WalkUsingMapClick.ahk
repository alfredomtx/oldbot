
class _WalkUsingMapClick extends _WalkToDirection
{
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * walk to a direction until stopped, arrived or need to change direction
    * @return bool
    */
    walk()
    {
        this.setLoopAndStopCallables()

        ; Loop, % this.maxTries {
            new _WaitDisconnected()

        ; _Logger.log(this.__Class, txt("Tentativas: ", "Tries: ") A_Index "/" this.maxTries)

        if (callables(this.stopCallables, true)) {
            return true
        }

        if (this.walkWithClick()) {
            return true
        }

        return false
        ; return this.walkOnceMoreIfTrapped()
    }

    /**
    * @return bool
    */
    walkOnceMoreIfTrapped()
    {
        /**
        * if is the first time that failed to walk by click and there are monsters around,
        * consider that the char is trapped, enable targeting and retry to walk by click one more time
        */
        _CavebotTrappedEvent.handle()

        if (this.failedToWalkByClickCount == 1) {
            _Logger.info(this.mode, txt("Tentando andar mais uma vez através de cliques no mapa após situação de trap.", "Trying to walk one more time by clicking on the map after a trap situation."))

            this.setFailedToWalkByClick(false)

            return this.walkWithClick()
        }

        return false
    }

    pausedByTargetingEvent()
    {
        ; reset current count of tries to walk by click, so it doesn't fallback to walk by arrow unecessarily
        this.setWalkWithClickTries(0)
    }
}