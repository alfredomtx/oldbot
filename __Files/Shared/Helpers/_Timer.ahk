
/**
* @property int tickCount
*/
class _Timer
{
    __New(tickCount := "")
    {
        if (tickCount) {
            this.tickCount := tickCount
        } else {
            this.reset()
        }
    }

    /**
    * @return int
    * @msgbox
    */
    elapsed(msgbox := false)
    {
        elapsed := A_TickCount - this.tickCount
        if (msgbox) {
            msgbox, % "Elapsed: " elapsed
        }

        return elapsed
    }

    /**
    * @param string text
    * @return string
    */
    seconds(text := "")
    {
        return Format("{:0.2f}", this.elapsed() / 1000) "" text
    }

    /**
    * @param string text
    * @return string
    */
    minutes(text := "")
    {
        return Format("{:0.2f}", this.seconds() / 60) "" text
    }

    /**
    * @param string text
    * @return string
    */
    hours(text := "")
    {
        return Format("{:0.2f}", this.minutes() / 60) "" text
    }

    /**
    * @return void
    */
    reset()
    {
        this.tickCount := A_TickCount
    }

    log()
    {
        _Logger.log(A_ThisFunc, this.elapsed())
    }
}