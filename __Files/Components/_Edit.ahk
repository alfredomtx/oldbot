#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Components\_AbstractStatefulControl.ahk

class _Edit extends _AbstractStatefulControl
{
    static CONTROL := "Edit"
    static OPTION_NUMERIC := "0x2000"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        base.__New(_Edit.CONTROL)
    }

    /**
    * @abstract
    * @return void
    */
    onEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        this.debounceEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel)
    }

    /**
    * @return this
    */
    numeric()
    {
        this.option(this.OPTION_NUMERIC)
        return this
    }


    /**
    * @return this
    */
    readOnly()
    {
        this.option("ReadOnly")
        return this
    }

    /**
    * @return void
    */
    append(value, delimiter := "`n", scroll := true)
    {
        content := this.get()

        this.set(content "" delimiter "" value)

        if (scroll) {
            this.scroll()
        }
    }

    /**
    * @return void
    */
    scroll()
    {
        SendMessage, 0x0115, 7, 0,, % "ahk_id " this.getHwnd() ;WM_VSCROLL
    }

    tt(text, translation := "")
    {
        base.tt(text, translation)

        if (!this.has("parent")) {
            return this
        }

        rule := this.get("rule")
        if (rule) {
            tooltip := "`n- " txt("Padrão: ", "Default: ") rule.getDefault()
            tooltip .= "`n- Min: " rule.getMin()
            tooltip .= "`n- Max: " rule.getMax()
            if (rule.getType()) {
                tooltip .= "`n- " txt("Tipo: ", "Type: ") rule.getType()
            }

            base.tt(tooltip)
        }
    }

    isNumeric()
    {
        return this._options[this.OPTION_NUMERIC] ? true : false
    }
}
