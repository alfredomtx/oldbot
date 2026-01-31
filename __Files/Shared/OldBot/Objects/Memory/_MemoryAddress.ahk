
/**
* @property hex address
* @property array<hex> offsets
*/
class _MemoryAddress extends _BaseClass
{
    ; __Call(method, args*) {
    ;     methodParams(this[method], method, args)
    ; }

    __New(address)
    {
        _Validation.empty("address", address)

        this.offsets := {}
        this.debug := false
        this.bytes := 0
        this.type := "UInt"

        this.address := address
    }

    /**
    * @param array data
    * @return self
    */
    FROM_ARRAY(data)
    {
        _Validation.empty("data.a", data.a)
        _Validation.empty("data.o", data.o)

        instance := new this(data.a)

        for _, offset in data.o {
            instance.addOffset(offset)
        }

        for option, value in data.options {
            func := instance["set" option].bind(instance, value)
            result := %func%()

            if (!result) {
                throw Exception("Invalid option: " option)
            }
        }

        return instance
    }

    /**
    * @param hex value
    * @return this
    */
    setBytes(value)
    {
        _Validation.number(A_ThisFunc ".value", value)
        this.bytes := value

        return this
    }

    /**
    * @param string type
    * @return this
    */
    setType(value)
    {
        _Validation.string(A_ThisFunc ".value", value)
        this.type := value

        return this
    }

    /**
    * @param hex value
    * @return this
    */
    setOffset(value)
    {
        _Validation.empty(A_ThisFunc ".value", value)
        this.offsets := {}
        this.offsets.Push(value)

        return this
    }


    /**
    * @param hex value
    * @return this
    */
    addOffset(value)
    {
        _Validation.empty(A_ThisFunc ".value", value)
        this.offsets.Push(value)

        return this
    }

    /**
    * @param array<hex> value
    * @return this
    */
    setOffsets(offsets)
    {
        _Validation.empty(A_ThisFunc ".offsets", offsets)
        for key, value in offsets {
            this.addOffset(value)
        }

        return this
    }

    /**
    * @return this
    */
    setDebug()
    {
        this.debug := true
        return this
    }

    /**
    * @return ?string
    * @throws
    */
    read()
    {
        return MemoryManager.readMemoryNew({"address": this.address, "debug": this.debug, "bytesReadRaw": this.bytes, "type": this.type}, this.offsets)
    }

    /**
    * @return ?int
    * @throws
    */
    write(value)
    {
        _Validation.empty(value)

        return MemoryManager.writeMemoryNew(value, {"address": this.address, "debug": this.debug, "bytesReadRaw": this.bytes, "type": this.type}, this.offsets)
    }
}