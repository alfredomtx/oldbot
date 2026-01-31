

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\_AbstractAction.ahk

class _ToggleChat extends _AbstractChatAction
{
    /**
    * @param string state - "on" or "off"
    * @return void
    * @throws
    */
    __New(state)
    {
        if (this.isIncompatible()) {
            return
        }

        this.validations(state)
        _search := state = "on" ? new _SearchChatOnButton() : new _SearchChatOffButton()
        if (_search.found()) {
            return
        }

        Loop, 3 {
            _ := new _ClickOnChatButton(state = "on" ? "off" : "on", new _ClickParams("Left", 6))

            Sleep, 100

            _search := state = "on" ? new _SearchChatOnButton() : new _SearchChatOffButton()
            if (_search.found()) {
                return
            }
        }

        if (_search.notFound()) {
            throw Exception("Failed to toggle chat """ state """.")
        }
    }

    /**
    * @abstract
    * @throws
    */
    validations(state)
    {
        _Validation.isOneOf("state", state, "on", "off")
    }
}