
class _FullLight extends _BaseClass
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New()
    {
        ; guardAgainstAbstractInstantiation(this)
    }

    /**
    * @return ?string
    */
    getCurrentLightValue()
    {
        if (instanceOf(_MemoryAddress, MemoryManager.LightPointerOffset)) {
            currentLight := MemoryManager.LightPointerOffset.read()
            return currentLight
        }

        if (IsObject(MemoryManager.LightPointerOffsets)) {
            currentLight := MemoryManager.readMemoryNew({"info": "FullLight"}, {1: MemoryManager.LightPointerOffsets.value})
            return currentLight
        }

        currentLight :=  MemoryManager.readMemoryNew({"info": "FullLight"}, {1: MemoryManager.LightPointerOffset})
        return currentLight
    }


    writeMemory(value)
    {
        if (instanceOf(_MemoryAddress, MemoryManager.LightPointerOffset)) {
            currentLight := MemoryManager.LightPointerOffset.write(value)
            return currentLight
        }

        if (IsObject(MemoryManager.LightPointerOffsets)) {
            if (debug) {
                msgbox,% "MemoryManager.LightPointerOffsets.sqms = " MemoryManager.LightPointerOffsets.sqms
                msgbox,%  MemoryManager.LightPointerValues.sqms " / " MemoryManager.LightPointerValues.value
            }
            MemoryManager.writeMemoryNew(MemoryManager.LightPointerValues.value, {}, {1: MemoryManager.LightPointerOffsets.value})
            MemoryManager.writeMemoryNew(MemoryManager.LightPointerValues.sqms, {}, {1: MemoryManager.LightPointerOffsets.sqms})
        } else {
            MemoryManager.writeMemoryNew(value, {}, {1: MemoryManager.LightPointerOffset})
        }
    }

    readMemory()
    {

    }
}