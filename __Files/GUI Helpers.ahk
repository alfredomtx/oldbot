/**
* @param string ErrLevel
* @return bool
*/
isCheckedLV(ErrLevel) {
    return InStr(ErrLevel, _Listview.ERRORLEVEL_CHECKED, true)
}