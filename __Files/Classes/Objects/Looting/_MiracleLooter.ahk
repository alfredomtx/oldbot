
class _MiracleLooter extends _BaseClass
{
    static IMAGES_FOLDER := _Folders.IMAGES_LOOTING "\miracle\attr"

    __Init()
    {
        classLoaded("_Folders", _Folders)
    }

    run()
    {
        if (!isMiracle74()) {
            return
        }

        t := new _Timer()
        _Logger.info("Miracle Looting", txt("Procurando itens com atributo...", "Searching for items with attribute..."))
        _search := this.imageSearch(this.getImages())
            .search()

        if (!_search.getImageFound()) {
            ; m(t.elapsed(msgbox := false) " found: " _search.getImageFound().getFileName())
            _Logger.info("Miracle Looting", txt("Nenhum item encontrado.", "No item found.") " " t.elapsed() "ms")
            return false
        }

        coordinates := this.adjustItemPosition(_search)
        _Logger.info("Miracle Looting", txt("Item encontrado: ", "Item found: ") _search.getImageFound().getFileName() " " t.elapsed() "ms")
        ; coordinates.moveMouse(false)

        return coordinates
    }

    getImages()
    {
        static images
        if (images) {
            return images
        }

        images := {}

        Loop, Files, % this.IMAGES_FOLDER "\*.*", D
        {
            bottomTop := A_LoopFileFullPath
            Loop, Files, % bottomTop "\*.*", D
            {
                leftRight := A_LoopFileFullPath
                Loop, % leftRight "\*.png" {
                    images.Push(A_LoopFileFullPath)
                }
            }
        }

        return images
    }

    adjustItemPosition(search)
    {
        folder := search.getImageFound().getFileDir()

        x := 0
        y := 0
        if (InStr(folder, "left")) {
            x += _ItemSearch.OFFSET_X
        }
        if (InStr(folder, "right")) {
            x -= _ItemSearch.OFFSET_X
        }

        if (InStr(folder, "top")) {
            y += _ItemSearch.OFFSET_Y
        }
        if (InStr(folder, "bottom")) {
            y -= _ItemSearch.OFFSET_Y
        }

        return new _Coordinate(search.getResult().getX(), search.getResult().getY())
            .addX(x)
            .addY(y)
        ; .debug()
    }

    imageSearch(images)
    {
        static searchCache
        if (!searchCache) {
            searchCache := new _MultipleImageSearch(images)
                .setCoordinates(_Coordinates.FROM_ARRAY(ClientAreas.lootSearchArea))
                .setVariation(40)
                .setTransColor(ImagesConfig.pinkColorTrans)
        }

        return searchCache
    }
}