
/**
* @property array<string> headers
* @property _RowFilter filter
* @property array<_Row> rows
*/
class _Listview extends _AbstractListableControl
{
    static CONTROL := "Listview"
    static DEBOUNCE_INTERVAL := 50

    static ERRORLEVEL_CHECKED := "C"
    static ERRORLEVEL_UNCHECKED := "c"

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    /**
    * @param array<string> headers
    * @return this
    */
    __New()
    {
        base.__New(_Listview.CONTROL)

        this.filter := new _RowFilter("")

        base.title("|")
        this.ignoredEvents := {}
        this.ignoredEvents["F"] := true ; focus
        this.ignoredEvents["S"] := true ; scroll
        ; this.ignoredEvents["I"] := true
        this.ignoredEvents["C"] := true
        this.ignoredEvents["K"] := true

        this.selectedRow := ""

        this.option("-Hdr")
    }

    /**
    * @abstract
    * @param int CtrlHwnd
    * @param string GuiEvent
    * @param int EventInfo
    * @param ?int ErrLevel
    * @return this
    */
    onEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "")
    {
        ; _Logger.log(A_ThisFunc, GuiEvent " | " EventInfo " | " ErrLevel)
        for event, value in this.ignoredEvents {
            if (InStr(GuiEvent, event) && value) {
                return
            }
        }

        switch (GuiEvent) {
            case "I": 
                if (this.isChecked && InStr(ErrLevel, "S")) {
                    return
                }

                /*
                focusing a row without checking the checkbox
                */
                if (this.isChecked && InStr(ErrLevel, "f")) {
                    return
                }
        }

        this.runOnEvent(CtrlHwnd, GuiEvent, EventInfo, ErrLevel)
    }

    /**
    * @param array<string> headers
    * @return this
    */
    title(headers)
    {
        _Validation.isObject("headers", headers)

        title := _Arr.concat(headers, "|")

        this.option("+Hdr")
        base.title(title)

        this.headers := headers

        return this
    }

    /**
    * @abstract
    * @param array<_Row> rows
    * @return this
    */
    list(rows)
    {
        this.rows := rows

        if (this.hasRows()) {
            _Validation.instanceOf("rows", _Arr.first(rows), _Row)
        }

        this.loadRows()

        return this
    }

    /**
    * @return array<_Row> rows
    */
    getRows()
    {
        return this.rows
    }

    /**
    * @return void
    */
    loadRows()
    {
        this.deleteRows()

        if (!this.hasRows()) {
            return
        }

        this.removeCallback()
        try {
            this.disable()

            for _, row in this.rows {
                this.addRow(row, A_Index)
            }

            this.resize()

            this.enable()
        } catch e {
            _Logger.exception(e, A_ThisFunc, this.getControlID())
        } finally {
            this.addCallback()
        }
    }

    /**
    * @return bool
    */
    hasRows()
    {
        return (this.rows.MaxIndex() > 0)
    }

    /**
    * @abstract
    * @return string
    */
    defaultOptions()
    {
        return "Grid AltSubmit"
    }

    /**
    * @param _Row row
    * @param int index
    * @return this
    */
    addRow(row, index)
    {
        if (!this.filter.evaluate(row)) {
            return
        }

        this.setDefaultListview()

        columns := row.get()

        options := ""
        if (row.isSelected()) {
            options := "Focus Select Check Vis"

            this.selectedRow := row.setText(columns[1])
                .setNumber(index)
        }

        if (row.isChecked()) {
            options .= " Check "
        }

        this.removeCallback()

        try {
            LV_Add(row.getOptions() " " options, columns*)

            if (row.isSelected()) {
                this.modifyRow(index, "Vis")
            }
        } finally {
            this.addCallback()
        }

        return this
    }

    /**
    * @return this
    */
    deleteRows()
    {
        this.setDefaultListview()

        this.selectedRow := {}

        try {
            LV_Delete()
        } catch {
        }

        return this
    }

    /**
    * @return void
    */
    setDefaultListview()
    {
        this.setDefaultGui()

        Gui, ListView, % this.getControlID()
        if (A_DefaultListView != this.getControlID()) {
            throw Exception("Default listview was not set: " this.getControlID())
        }
    }

    /**
    * @return this
    */
    resize()
    {
        this.setDefaultListview()
        Loop, % this.headers.Count() {
            LV_ModifyCol(A_Index, "autohdr")
        }

        return this
    }

    /**
    * @return int
    */
    getSelectedRow()
    {
        this.setDefaultListview()
        return LV_GetNext(, "F")
    }

    /**
    * @return int
    */
    getCheckedRow(row := "")
    {
        this.setDefaultListview()
        return LV_GetNext(row, "C")
    }

    /**
    * @param int row
    * @param int column
    * @return string
    */
    getText(row, column := 1)
    {
        this.setDefaultListview()
        LV_GetText(text, row, column)

        return text
    }

    /**
    * @param int column
    * @return string
    */
    getSelectedText(column := 1)
    {
        return this.getText(this.getSelectedRow(), column)
    }

    /**
    * @param int column
    * @return string
    */
    getCheckedText(column := 1)
    {
        return this.getText(this.getCheckedRow(), column)
    }

    /**
    * @param string value
    * @return this
    */
    search(value, column := 1)
    {
        this.filter := new _RowFilter(value, column)
        if (this.fn) {
            fn := this.fn
            SetTimer, % fn, Delete
        }

        this.fn := this.loadRows.bind(this)

        fn := this.fn
        interval := this.DEBOUNCE_INTERVAL
        SetTimer, % fn, -%interval%
        return this
    }

    /**
    * @param int rowNumber
    * @param ?bool removeCallback
    * @param int rowNumber
    */
    selectRow(rowNumber, removeCallback := true)
    {
        this.modifyRow(rowNumber, "+Select", removeCallback)
        return this
    }

    /**
    * @param int rowNumber
    * @param ?bool removeCallback
    * @param int rowNumber
    */
    unselectRow(rowNumber, removeCallback := true)
    {
        this.modifyRow(rowNumber, "-Select", removeCallback)
        return this
    }

    /**
    * @param int rowNumber 
    * @param ?bool removeCallback
    * @param int rowNumber
    */
    checkRow(rowNumber, removeCallback := true)
    {
        this.modifyRow(rowNumber, "+Check", removeCallback)
        return this
    }

    /**
    * @param int rowNumber
    * @param ?bool removeCallback
    * @param int rowNumber
    */
    uncheckRow(rowNumber, removeCallback := true)
    {
        this.modifyRow(rowNumber, "-Check", removeCallback)
        return this
    }

    /**
    * @param int rowNumber
    * @param string options
    * @param ?bool removeCallback
    * @return this
    */
    modifyRow(rowNumber, options, removeCallback := true)
    {
        _Validation.number("rowNumber", rowNumber)

        this.setDefaultListview()

        if (removeCallback) {
            this.removeCallback()
        }

        try {
            LV_Modify(rowNumber, options)
        } catch e {
            _Logger.exception(e, A_ThisFunc, this.getControlID())
        } finally {
            if (removeCallback) {
                this.addCallback()
            }
        }

        return this
    }

    /**
    * @return this
    */
    checked()
    {
        this.isChecked := true
        this.option("Checked")

        ; this.ignoredEvents["Normal"] := true
        this.ignoredEvents["S"] := true


        return this
    }

    /**
    * @param ?int column
    * @return array<int, text>
    */
    getSelectedRows(column := 1)
    {
        this.setDefaultListview()

        selected := {}
        RowNumber := 0 ; This causes the first loop iteration to start the search at the top of the list.
        Loop {
            RowNumber := LV_GetNext(RowNumber, (this.isChecked ? "C" : "")) ; Resume the search at the row after that found by the previous iteration.
            if not RowNumber ; The above returned zero, so there are no more selected rows.
                break
            LV_GetText(text, RowNumber, column)

            selected[RowNumber] := text
        }

        return selected
    }
}
