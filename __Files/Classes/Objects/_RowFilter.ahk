
class _RowFilter extends _BaseClass
{
    /**
    * @param string value
    * @param int column
    */
    __New(value, column := 1, exactMatch := false) {
        this.value := value
        this.column := column
        this.exactMatch := exactMatch
    }

    /**
    * @param _Row row
    * @return bool
    */
    evaluate(row)
    {
        if (!this.value) {
            return true
        }

        columns := row.get()
        if (this.exactMatch && columns[this.column] != this.value) {
            return false
        }

        if (!this.exactMatch && !InStr(columns[this.column], this.value)) {
            return false
        }

        return true
    }
}