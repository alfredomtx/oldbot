#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ClientAreas\_AbstractClientArea.ahk

class _OcrArea extends _AbstractClientArea
{
    /**
    * @param string image
    * @param _AbstractClientArea area
    * @return _ImageSearch
    * @throws
    */
    searchImage(image, area) 
    {
        search := ims(image, {"area": area.NAME, "cache": false}).search()
        if (search.notFound()) {
            throw Exception(_Str.quoted(image) " not found.")
        }

        return search
    }
}