
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Action Script\Actions\_AbstractActionScript.ahk

class _WriteAction extends _AbstractActionScript
{
    static IDENTIFIER := "write"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @return bool
    */
    runAction()
    {
        functionValues := this.values
        this.info(ActionScript.string_log)

        params := {}
            , params.message := functionValues.1

            , params := this.checkParamsVariables(params)

        /*
        remove line breaks from message
        */
        params.message := StrReplace(params.message, "`n", " ")
            , params.message := StrReplace(params.message, "`r", " ")
        /*
        words with '
        such as Ab'dendriel
        */
        switch (new _ClientInputIniSettings().get("writeMessagesWithPasteAction")) {
            case true: sendWithClipboard := true
            case false: sendWithClipboard := containsSpecialCharacter(params.message)
        }

        if (sendWithClipboard = true) {
            clipboardOld := Clipboard
            copyToClipboard(params.message)
            SendModifier("Ctrl", "v")
            copyToClipboard(clipboardOld)
        } else {
            Send(params.message)
        }

        return true
    }
}