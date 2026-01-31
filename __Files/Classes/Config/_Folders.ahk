
class _Folders extends _BaseClass
{
    static CAVEBOT := "Cavebot"
    static DATA := "Data"
    static MARKET_ROOT := "Market"

    static EXECUTABLES := _Folders.DATA "\Executables"
    static EXECUTABLES_TEMP := _Folders.EXECUTABLES "\temp"
    static FILES := _Folders.DATA "\Files"
    static MARKET := _Folders.DATA "\Market"
    static SCREENSHOTS := _Folders.DATA "\Screenshots"
    static SPECIAL_AREAS := _Folders.DATA "\Special Areas"

    static BIN := _Folders.FILES "\bin"
    static IMAGES := _Folders.FILES "\Images"
    static JSON := _Folders.FILES "\JSON"
    static OTHERS := _Folders.FILES "\Others"
    static SOUNDS := _Folders.FILES "\Sounds"
    static THIRD_PARTY_PROGRAMS := _Folders.FILES "\Third Part Programs"

    static IMAGES_ALERTS := _Folders.IMAGES "\Alerts"
    static IMAGES_CAVEBOT := _Folders.IMAGES "\Cavebot"
    static IMAGES_CAVEBOT_TRADE := _Folders.IMAGES_CAVEBOT "\Trade"
    static IMAGES_CLIENT := _Folders.IMAGES "\Client"
    static IMAGES_FISHING := _Folders.IMAGES "\Fishing"
    static IMAGES_LOOTING := _Folders.IMAGES "\Looting"
    static IMAGES_RECONNECT := _Folders.IMAGES "\Reconnect"
    static IMAGES_TARGETING := _Folders.IMAGES "\Targeting"

    static IMAGES_GUI := _Folders.IMAGES "\GUI"
    static IMAGES_GUI_RUNEMAKER := _Folders.IMAGES_GUI "\Runemaker"

    static JSON_CAVEBOT := _Folders.JSON "\cavebot"
    static JSON_CLIENT_AREAS := _Folders.JSON "\client_areas"
    static JSON_CLIENT_MENUS := _Folders.JSON "\client_menus"
    static JSON_CONTAINERS := _Folders.JSON "\containers"
    static JSON_HEALING := _Folders.JSON "\healing"
    static JSON_ITEM_REFILL := _Folders.JSON "\itemRefill"
    static JSON_LOOTING := _Folders.JSON "\looting"
    static JSON_MEMORY := _Folders.JSON "\memory"
    static JSON_MINIMAP := _Folders.JSON "\minimap"
    static JSON_SUPPORT := _Folders.JSON "\support"
    static JSON_TARGETING := _Folders.JSON "\targeting"

    static FONTS := _Folders.OTHERS "\fonts"

    ; __Get(attribute)
    ; {
    ;     if (!this[attribute]) {
    ;         throw Exception("Invalid folder: " attribute)
    ;     }

    ;     return _Images.FOLDER "\" _Images[attribute]
    ;     m(a)
    ; }

    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New()
    {
        guardAgainstInstantiation(this)
    }
}