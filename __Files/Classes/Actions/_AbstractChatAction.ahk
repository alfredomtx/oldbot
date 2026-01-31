

#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Actions\_AbstractAction.ahk

class _AbstractChatAction extends _AbstractAction
{
    /**
    * @abstract
    * @return bool
    */
    isIncompatible() {
        return !OldBotSettings.settingsJsonObj.clientFeatures.chatOnOff
    }
}