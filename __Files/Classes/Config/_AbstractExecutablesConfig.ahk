#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_AbstractConfigClass.ahk

class _AbstractExecutablesConfig extends _AbstractConfigClass
{
    stopAllExceptOldBot()
    {
        skip := {}
        skip[_OldBotExe.NAME] := true

        this.stopAll(skip)
    }

    stopAll(skip := "")
    {
        for _, exe in this.getList() {
            if (skip[exe.NAME]) {
                continue
            }

            exe.stop()
        }
    }
}
