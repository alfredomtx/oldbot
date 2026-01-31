
#Include, C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Cavebot\Walkable Conditions\_AbstractWalkableCondition.ahk

class _CoordinatePixelCondition extends _AbstractWalkableCondition
{
    static STAIR_PIXEL_COLOR := "0xFFFF00"

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    handle()
    {
        if (!isTibia13()) {
            return true
        }

        return this.isCoordPixelWalkable(bool(this.params.allowStair))
    }

    /**
    * @return bool
    */
    isCoordPixelWalkable(allowStair := false)
    {
        /*
        if is outside of map range(custom map), return true
        */
        if (this.x <= tibiaMapX1 OR this.x >= tibiaMapX2) || (this.y <= tibiaMapY1 OR this.y >= tibiaMapY2) {
            return true
        }

        pixColor := this.getCoordPixel()
        if (!allowStair && pixColor = this.STAIR_PIXEL_COLOR) {
            return false
        }

        if (this.getNonWalkablePixels().hasKey(pixColor)) {
            return false
        }

        if (OldBotSettings.settingsJsonObj.map.settings.pathFiles) {
            pixColor := this.getCoordCostPixel()
            if (pixColor = "0xFFFF00" OR pixColor = "0xFAFAFA") {
                return false
            }
        }

        return  true
    }

    isStair()
    {
        if (!isTibia13()) {
            return false
        }

        return this.getCoordPixel() = this.STAIR_PIXEL_COLOR
    }

    getNonWalkablePixels()
    {
        static list
        if (list) {
            return list
        }

        list := {}
        list["0x000000"] := true ; black
        list["0xFF3300"] := true ; red - wall
        list["0x3300CC"] := true ; blue - sea
        list["0x006600"] := true ; green - trees
        list["0x00FF00"] := true ; lime - swamps
        list["0x666666"] := true ; gray - rocks
        list["0x993300"] := true ; brown - cave
        list["0xFF6600"] := true ; orange - lava

        return list
    }

    getCoordPixel()
    {
        floorString := floorString(this.z)
            , pixColor := Gdip_GetPixel(pBitmapColoredFloor%floorString%, this.x - tibiaMapX1, this.y - tibiaMapY1, A_ThisFunc)
            , pix := ConvertARGB(pixColor)
        SetFormat, Integer, D

        return pix
    }

    getCoordCostPixel()
    {
        floorString := floorString(this.z)
            , pixColor := Gdip_GetPixel(pBitmapPathFloor%floorString%, this.x - tibiaMapX1, this.y - tibiaMapY1, A_ThisFunc)
            , pix := ConvertARGB(pixColor)
        SetFormat, Integer, D

        return pix
    }
}