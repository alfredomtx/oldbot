

class _ClickOnChatButton extends _AbstractAction
{
    /**
    * @param string type - "on" or "off"
    * @param _ClickParams params
    * @return _ImageSearch
    */
    __New(type, params) {
        try {
            this.validations(type, params)

            _search := type = "on" ? new _SearchChatOnButton() : new _SearchChatOffButton()

            _search.setClickOffsetX(params.offsetX)
                .setClickOffsetY(params.offsetY)
                .click(params.button)

            MouseMove(CHAR_POS_X, CHAR_POS_Y)

            return _search
        } catch e {
            this.handleException(e, this)
            throw e
        }
    }

    /**
    * @abstract
    * @throws
    */
    validations(type, params) {
        _Validation.isOneOf("type", type, "on", "off")
        _Validation.instanceOf("params", params, _ClickParams)
    }

}