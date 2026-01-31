/**
* @property int x
* @property int y
* @property int z
* @property int w
* @property int h
* @property ?int createdAt
* @property ?int updatedAt
* 
* @property bool walkable
* 
* @property string type
* @property ?string status
* @property ?string identifier
* @attribute ?string image
* 
* @property ?array payload
*/
class _SpecialArea extends _BaseClass
{
    static TYPE_BLOCKED := "Blocked"
    static TYPE_BLOCKED_AUTO_DETECTED := "BlockedAutoDetected"
    static TYPE_BLOCKED_MAP_COLOR := "BlockedMapColor"
    static TYPE_BLOCKED_BY_CREATURE := "BlockedByCreature"
    static TYPE_BLOCKED_FISHING := "BlockedFishing"
    static TYPE_CHANGE_FLOOR := "ChangeFloor"
    static TYPE_CHANGE_FLOOR_MAP_COLOR := "ChangeFloorMapColor"
    static TYPE_NONE := "None"

    static STATUS_DELETED := "deleted"

    static COLOR_NONE := "black"

    static WALKABLE_TYPES := [_SpecialArea.TYPE_NONE, _SpecialArea.TYPE_CHANGE_FLOOR, _SpecialArea.TYPE_CHANGE_FLOOR_MAP_COLOR]

    static NON_WALKABLE_TYPES := [_SpecialArea.TYPE_BLOCKED
        , _SpecialArea.TYPE_BLOCKED_MAP_COLOR
        , _SpecialArea.TYPE_BLOCKED_AUTO_DETECTED
        , _SpecialArea.TYPE_BLOCKED_BY_CREATURE
        , _SpecialArea.TYPE_BLOCKED_FISHING]

    ;#Region Meta
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __Set(property)
    {
        switch (property) {
            case "updatedAt": ;
            default: 
                this.updatedAt := A_NowUTC
        }
    }

    __New()
    {
        this.w := 1
        this.h := 1

        this.walkable := true
        this.type := this.TYPE_NONE

        this.setCreatedAt(A_NowUTC)
    }
    ;#Endregion

    /**
    * @return this
    */
    deleteImage()
    {
        this.delete("image")

        return this
    }

    /**
    * @return this
    */
    toggleType()
    {
        type := this.getType()
        switch (type) {
            case this.TYPE_BLOCKED:
                this.setType(this.TYPE_CHANGE_FLOOR)
                this.setWalkable(true)
            default:
                this.setType(this.TYPE_BLOCKED)
                this.setWalkable(false)
        }

        this.delete("status")

        return this
    }

    /**
    * @return this
    */
    softDelete()
    {
        ; this.setType(this.TYPE_NONE)
        ; this.setWalkable(true)
        this.setStatus(this.STATUS_DELETED)

        return this
    }

    /**
    * @return string
    */
    resolveColor()
    {
        if (this.isDeleted()) {
            return "black"
        }

        switch (this.getType()) {
            case this.TYPE_BLOCKED:
                return "red"
            case this.TYPE_BLOCKED_MAP_COLOR:
                return "0x801717"
            case this.TYPE_BLOCKED_AUTO_DETECTED:
                return "purple"
            case this.TYPE_CHANGE_FLOOR:
                return "green"
            case this.TYPE_CHANGE_FLOOR_MAP_COLOR:
                return "165716"
            case this.TYPE_BLOCKED_FISHING:
                return "0x2babab"
            default: 
                return this.COLOR_NONE
        }
    }

    /**
    * @param ?string text
    * @return string
    */
    resolveHudText(text := "")
    {
        return (this.isDeleted() ? "DELETED`n" : "") "x: " this.x "`ny: " this.y "`nz: " this.z (text ? "`n" text : "") 
    }

    ;#Region Getters
    /**
    * @return int
    */
    getX()
    {
        return this.x
    }

    /**
    * @return int
    */
    getY()
    {
        return this.y
    }

    /**
    * @return int
    */
    getZ()
    {
        return this.z
    }

    /**
    * @return int
    */
    getW()
    {
        return this.w
    }

    /**
    * @return int
    */
    getH()
    {
        return this.h
    }

    /**
    * @return ?string
    */
    getCreatedAt()
    {
        return this.createdAt
    }

    /**
    * @return ?string
    */
    getUpdatedAt()
    {
        return this.updatedAt
    }

    /**
    * @return string
    */
    getType()
    {
        return this.type
    }

    /**
    * @return ?string
    */
    getIdentifier()
    {
        return this.identifier
    }

    /**
    * @return ?string
    */
    getStatus()
    {
        return this.status
    }

    /**
    * @return array
    */
    getPayload()
    {
        return this.payload
    }

    /**
    * @return array
    */
    getImage()
    {
        return _SpecialAreas.getAreaImage(this.x, this.y, this.z)
    }
    ;#Endregion

    ;#Region Setters
    /**
    * @param int value
    * @return this
    */
    setX(value)
    {
        this.x := value
        return this   
    }

    /**
    * @param int value
    * @return this
    */
    setY(value)
    {
        this.y := value
        return this   
    }

    /**
    * @param int value
    * @return this
    */
    setZ(value)
    {
        this.z := value
        return this   
    }

    /**
    * @param int value
    * @return this
    */
    setW(value)
    {
        this.w := value
        return this   
    }

    /**
    * @param int value
    * @return this
    */
    setH(value)
    {
        this.h := value
        return this   
    }

    /**
    * @param string value
    * @return this
    */
    setCreatedAt(value)
    {
        this.createdAt := value
        return this   
    }

    /**
    * @param string value
    * @return this
    */
    setUpdatedAt(value)
    {
        this.updatedAt := value
        return this   
    }

    /**
    * @param bool value
    * @return this
    */
    setWalkable(value)
    {
        this.walkable := bool(value)
        return this   
    }

    /**
    * @param string value
    * @return this
    */
    setType(value)
    {
        this.type := value
        if (this.type != this.TYPE_NONE && this.isDeleted()) {
            this.delete("status")
        }

        this.setWalkable(_Arr.search(_SpecialArea.WALKABLE_TYPES, this.type) ? true : false)

        return this   
    }

    /**
    * @param string value
    * @return this
    */
    setIdentifier(value)
    {
        this.identifier := value
        return this   
    }

    /**
    * @param string value
    * @return this
    */
    setStatus(value)
    {
        this.status := value
        return this   
    }

    /**
    * @param ? value
    * @return this
    */
    setPayload(value)
    {
        this.payload := value
        return this   
    }

    /**
    * @param ? value
    * @return this
    */
    setImage(value)
    {
        _SpecialAreas.setAreaImage(this, value)

        return this
    }
    ;#Endregion

    ;#Region Predicates
    /**
    * @return bool
    */
    isWalkable()
    {
        return this.isDeleted() ? true : this.walkable
    }
    /**
    * @return bool
    */
    isBlocked()
    {
        if (this.isDeleted()) {
            return false
        }

        return _Arr.search(_SpecialArea.NON_WALKABLE_TYPES, this.type) ? true : false
    }

    /**
    * @return bool
    */
    isChangeFloor()
    {
        return this.isDeleted() ? false : this.type = this.TYPE_CHANGE_FLOOR
    }

    /**
    * @return bool
    */
    isBlockedFishing()
    {
        return this.isDeleted() ? false : this.type = this.TYPE_BLOCKED_FISHING
    }

    /**
    * @return bool
    */
    isDeleted()
    {
        return this.status = this.STATUS_DELETED
    }
    ;#Endregion

    ;#Region Factory
    fromMapCoordinate(mapCoordinate)
    {
        instance := new this()
        instance.setX(mapCoordinate.getX())
        instance.setY(mapCoordinate.getY())
        instance.setZ(mapCoordinate.getZ())
        instance.setW(mapCoordinate.getW())
        instance.setH(mapCoordinate.getH())
        instance.setImage(mapCoordinate.getBase64Image())

        return instance
    }

    /**
    * @param array<string, mixed> data
    * @return _SpecialArea
    */
    fromArray(data)
    {
        instance := new this()

        instance.setW(data.w)
        instance.setH(data.h)
        instance.setX(data.x)
        instance.setY(data.y)
        instance.setZ(data.z)
        instance.setWalkable(data.walkable)
        instance.setType(data.type)
        instance.setIdentifier(data.identifier)
        instance.setStatus(data.status)
        instance.setPayload(data.payload)

        if (data.createdAt) {
            instance.setCreatedAt(data.createdAt)
        }

        instance.setUpdatedAt(data.updatedAt) ; last

        return instance
    }
    ;#Endregion

    ;#Region Mutators
    /**
    * @return _MapCoordinate
    */
    toMapCoordinate()
    {
        if (this.mapCoordinate) {
            return this.mapCoordinate
        }

        return this.mapCoordinate := new _MapCoordinate(this.x, this.y, this.z, this.w, this.h)
            .setIdentifier(this.type ":" this.identifier)
    }

    /**
    * @return array<string, mixed>
    */
    toArray()
    {
        array := {"walkable": this.walkable, "x": this.x, "y": this.y, "z": this.z, "w": this.w, "h": this.h, "type": this.type, "identifier": this.identifier, "status": this.status, "payload": this.payload, "image": this.getImage(), "createdAt": this.createdAt, "updatedAt": this.updatedAt}

        return _Arr.filter(array)
    }
    ;#Endregion
}
