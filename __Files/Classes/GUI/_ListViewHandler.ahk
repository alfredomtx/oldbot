
Class _ListViewHandler  {



    getSelectedItemOnLV(LV, column := 2, defaultGUI := "CavebotGUI", returnRow := false) {
        this.setDefault(LV, defaultGUI)
        selectedRow := LV_GetNext()
        if (returnRow = true)
            return selectedRow
        LV_GetText(selectedItem, selectedRow, column)
        return selectedItem
    }

    getCheckedRow(LV, column := 2, defaultGUI := "CavebotGUI", returnRow := false) {
        this.setDefault(LV, defaultGUI)
        selectedRow := LV_GetNext(0, "C")
        if (returnRow)
            return selectedRow
        LV_GetText(selectedItem, selectedRow, column)
        return selectedItem
    }

    getSelectedRowsNumbersLV(LV, column := 1, defaultGUI := "CavebotGUI") {
        this.setDefault(LV, defaultGUI)
        selectedItems := {}
        RowNumber = 0 ; This causes the first loop iteration to start the search at the top of the list.
        Loop {
            RowNumber := LV_GetNext(RowNumber) ; Resume the search at the row after that found by the previous iteration.
            if not RowNumber ; The above returned zero, so there are no more selected rows.
                break
            selectedItems[A_Index] := RowNumber
        }
        if (selectedItems.Count() < 1)
            Throw Exception("Select at least one item in the list.")
        return selectedItems

    }

    getSelectedRowsLV(LV, column := 2, defaultGUI := "CavebotGUI", checked := false) {
        try Gui, %defaultGUI%:Default
        catch {
        }
        try Gui, ListView, %LV%
        catch {
        }
        rowsSelected := 0
        selectedItems := {}
        RowNumber = 0 ; This causes the first loop iteration to start the search at the top of the list.
        Loop {
            RowNumber := LV_GetNext(RowNumber, (checked = true ? "C" : "")) ; Resume the search at the row after that found by the previous iteration.
            if not RowNumber ; The above returned zero, so there are no more selected rows.
                break
            LV_GetText(selectedItem, RowNumber, column)
            selectedItems[RowNumber] := selectedItem
            rowsSelected++
        }
        if (selectedItems.Count() < 1)
            Throw Exception("Select at least one item in the list.")
        return selectedItems
    }

    findRowByContent(string, column, LV, defaultGUI := "CavebotGUI") {
        this.setDefault(LV, defaultGUI)
        Loop, % LV_GetCount() {
            Gui, ListView, %LV%
            LV_GetText(rowContent, A_Index, column)
            if (rowContent = string)
                return A_Index
        }

    }

    setDefault(LV, defaultGUI := "CavebotGUI") {
        Gui, %defaultGUI%:Default

        try {
            Gui, ListView, %LV%
        } catch {
        }
    }

    loadingLV(LV, defaultGUI := "CavebotGUI") {
        try Gui, %defaultGUI%:Default
        catch {
        }

        /*
        if the listview does not exist, it fails to set the default listview to the new one and will delete the contents
        of the current default listview.
        */
        ; value := ""
        ; try GuiControlGet, value, Visible, % LV
        ; catch {
        ; }
        ; if (!value) {
        ;     return
        ;     throw Exception("LV is probably not visible: " LV)
        ; }

        Gui, ListView, % LV
        if (A_DefaultListView != LV) {
            throw Exception("Default listview was not set: " LV)
        }

        try {
            LV_Delete()
        } catch {
        }
    }

    setColumnInteger(Column, LV, defaultGUI := "CavebotGUI") {
        this.setDefault(LV, defaultGUI)
        LV_ModifyCol(Column, "Integer")
        LV_ModifyCol(Column, "Center")
    }

    selectRow(LV, Row, defaultGUI := "CavebotGUI") {
        this.setDefault(LV, defaultGUI)
        LV_Modify(Row, "Vis")
        LV_Modify(Row, "Focus Select")
    }


    checkRow(LV, Row, defaultGUI := "CavebotGUI", focus := true) {
        this.setDefault(LV, defaultGUI)
        LV_Modify(Row, "+Check")
        if (focus = false)
            return
        LV_Modify(Row, "Vis")
        LV_Modify(Row, "Focus Select")
    }

    uncheckRow(LV, Row, defaultGUI := "CavebotGUI") {
        this.setDefault(LV, defaultGUI)
        ; LV_Modify(Row, "Vis")
        LV_Modify(Row, "-Focus -Select")
        LV_Modify(Row, "-Check")
    }


}