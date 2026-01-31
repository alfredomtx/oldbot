

class _UseMenuSearch extends _ImageSearch
{
    __New()
    {
        base.__New(this)

        this.setFile(this.resolveImage())
            .setFolder(ImagesConfig.clientMenusFolder "\use")
            .setVariation(CavebotSystem.cavebotJsonObj.images.useVariation)
            .setClickOffsets(5)
    }

    resolveImage()
    {
        return _ClientMenusJson.exists() ? new _ClientMenusJson().get("use.image") : CavebotSystem.cavebotJsonObj.images.use
    }
}