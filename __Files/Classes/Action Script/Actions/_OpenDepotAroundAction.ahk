
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Action Script\Actions\_AbstractDepositAction.ahk

class _OpenDepotAroundAction extends _AbstractDepositAction
{
    static IDENTIFIER := "opendepotaround"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    runAction()
    {
        static searchCache

        this.info(ActionScript.string_log)

        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFile(ImagesConfig.depositer.locker)
                .setFolder(ImagesConfig.depositerFolder)
                .setVariation(40)

                new _GameWindowArea()
        }


        ; writeCavebotLog("Action", LANGUAGE = "PT-BR" ? "Procurando pelo depot box limpo em volta" : "Searching for a clean depot box around")

        _search := searchCache.search()
        if (_search.found()) {
            return _search.getResult()
        } 

        ; if (clickAround = true) {
        sqms := {1: "N", 2: "S", 3: "W", 4: "E"}
        for key, sqm in sqms
        {
            x := SQM%sqm%X
            MouseClick("Right", SQM%sqm%X, SQM%sqm%Y, false)
            Sleep, 350
            Send("Esc")
            Sleep, 50
        }
        ; }

        Loop, 4 {
            _search := searchCache.search()
            if (_search.found()) {
                break
            } 

            Sleep, 250
        }

        Sleep, 100
        Send("Esc")
        Sleep, 100

        if (_search.found()) {
            return _search.getResult()
        } 

        return false
    }

}