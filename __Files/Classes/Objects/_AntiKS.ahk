
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

Class _AntiKS extends _BaseClass
{
    static STATE_ENABLED := "Enabled"
    static STATE_DISABLED := "Disabled"
    static STATE_PLAYER_ON_SCREEN := "Player on screen"

    static IMAGES_FOLDER := _Folders.IMAGES_TARGETING "\anti_ks"

    static DEBUG_ON_FOUND := 0

    static ALL_STATES := [_AntiKS.STATE_DISABLED, _AntiKS.STATE_ENABLED, _AntiKS.STATE_PLAYER_ON_SCREEN]

    run()
    {
        Gui, TargetAim:Destroy
        t1 := new _Timer()
        gammaImage := this.gammaImage()
        area := this.getArea()

        notFound := true
        this.x := "", this.y := ""
        loop, % this.IMAGES_FOLDER "\*.png" {
            _search := this.imageSearch(A_LoopFileName)
                .setScreenBitmap(gammaImage.getOutputBitmap())
                .setDebug(GetKeyState("Ctrl") && GetKeyState("Alt"))
                .search()

            if (_search.found()) {
                if (this.DEBUG_ON_FOUND) {
                    _search.debug()
                        .setScreenBitmap(gammaImage.getOutputBitmap())
                        .search()
                }

                this.x := _search.getX()
                this.y := _search.getY()
                ; this.x := _search.getX() + area.getX1()
                ; this.y := _search.getY() + area.getY1()
                ; this.x := _search.getX() + area.getX1()
                ; this.y := _search.getY() + area.getY1()
                _TargetingSystem.targetAimGui(this.x, this.y, 12, 16, A_LoopFileName)
                notFound := false

                break
            }
        }

        ; Gui, TargetAim:Destroy
        ; tooltip, % t1.elapsed()

        return notFound
    }

    states()
    {
        static states
        if (states) {
            return states
        }
        if (isMiracle74()) {
            return states := _Arr.remove(this.ALL_STATES, "Player on screen")
        }

        return states := this.ALL_STATES
    }

    attack()
    {
        if (!this.shouldRun()) {
            return false
        }

        if (!this.x || !this.y) {
            return false
        }

        Gui, TargetAim:Destroy

        coords := this.adjustCoordinates(false)
        ; coords.debug()

        ; TargetingSystem.afterAttackCreatureByClick(ignoreFirstSleep := true)

        this.attackAndSleep(coords)
        if (new _IsAttacking().notFound()) {
            coords := this.adjustCoordinates(true)
            ; coords.debug()
            this.attackAndSleep(coords)
            if (new _IsAttacking().notFound()) {
                throw Exception("Could not attack the creature", "FailedToAttackException")
            }
        }


        return true
    }

    attackAndSleep(coords)
    {
        MouseClick("Right", coords.x, coords.y, debug := false)
        if (delay := jsonConfig("targeting", "options", "delayAfterAttackClick")) {
            Sleep, % delay
        }
    }

    adjustCoordinates(flag := false)
    {
        mod += SQM_SIZE_HALF / 2

        x := this.x
        y := this.y
        if (this.x < CHAR_POS_X) {
            x := flag ? x + mod : x - mod
        }
        if (this.x > CHAR_POS_X) {
            x := flag ? x - mod : x + mod
        }
        if (this.y < CHAR_POS_Y) {
            y := flag ? y - mod : y + mod
        }
        if (this.y > CHAR_POS_Y) {
            y := flag ? y + mod : y - mod
        }

        return new _Coordinate(x, y)
    }

    imageSearch(file)
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _ImageSearch()
                .setFolder(this.IMAGES_FOLDER)
                .setVariation(new _TargetingSettings().get("antiKsVariation"))
                .setArea(this.getArea())
                .setTransColor(ImagesConfig.pinkColorTrans)
        }


        return searchCache.setFile(file)
    }

    gammaImage()
    {
        image := _BitmapEngine.getClientBitmap(this.getArea().getCoordinates())

        return new _Magick(image)
        ; .draw()
            .run()
    }

    getArea()
    {
        static area
        return area ? area : area := new _AroundCharacterArea()
    }

    shouldRun()
    {
        static value
        return value ? value : new _TargetingSettings().get("antiKs") = "Enabled" && isMiracle74()
    }

}