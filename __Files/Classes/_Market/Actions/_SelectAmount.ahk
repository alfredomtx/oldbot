#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_Loggable.ahk

class _SelectAmount extends _Loggable
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(amount, decreasePosition, increasePosition, offerAmount := "")
    {
        _Validation.instanceOf("increasePosition", increasePosition, _Coordinate)
        _Validation.instanceOf("decreasePosition", decreasePosition, _Coordinate)

        this.amount := amount
        this.offerAmount := offerAmount
        this.increasePosition := increasePosition
        this.decreasePosition := decreasePosition
        this._unitAmount := 1
    }

    run()
    {
        this.selectAmount()
        sleep(100)
    }

    selectAmount()
    {
        t1 := new _Timer()
        if (this.amount == 0) {
            this.log(txt("Setando quantidade para o máximo possivel", "Setting amount to maximum possible."))

            this.selectMaximum()
            return
        } else {
            this.log(txt("Setando quantidade para ", "Setting amount to ") this.amount ".") 
        }

        if (this.amount > 10000) {
            this.amount := 10000
            this.log(txt("Limitando quantidade máxima para ", "Limiting maximum amount to ") this.amount ".") 
        }

        if (this._unitAmount > 1) {
            this.handleMultipleUnitAmount()
        } else {
            this.handleSingleUnitAmount()
        }

        this.log(lang("elapsed") ": " t1.seconds() " seconds.")
    }

    handleSingleUnitAmount()
    {
        clicks := this.amount - 1

        this.handleClicks(clicks)
    }

    handleMultipleUnitAmount()
    {
        clicks := Floor(this.amount / this._unitAmount) - 1
        this.handleClicks(clicks)
    }

    handleClicks(clicks)
    {
        if (this.amount > 200) {
            this.selectUsingModifiers(clicks)
        } else {
            this.selectUsingClicks(clicks)
        }
    }

    selectMaximum()
    {
        c1 := _Coordinate.FROM(this.decreasePosition)
            .addX(12)

        c2 := _Coordinate.FROM(this.increasePosition)
            .addX(12)

        c1.drag(c2, debug := false)
    }

    selectUsingClicks(clicks)
    {
        Loop, % clicks {
            this.increasePosition.click()
            sleep(40, 75)
        }
    }

    selectUsingModifiers(clicks)
    {
        ctrlClicks := Floor(clicks / 100)
        shiftClicks := Floor(clicks / 10)

        this.log(txt("Clicando com Ctrl: ", "Clicking with Ctrl: ") ctrlClicks " x.")

        Loop, % ctrlClicks {
            this.increasePosition.clickWithModifier("Ctrl")
            sleep(40, 75)
            clicks -= 100
            shiftClicks -= 10
        }

        ; Loop, % shiftClicks {
        ;     this.increasePosition.clickWithModifier("Shift")
        ;     sleep(40, 75)
        ;     clicks -= 10
        ; }
        this.selectUsingClicks(clicks)
    }

    setUnitAmount(value)
    {
        this._unitAmount := value

        return this
    }
}