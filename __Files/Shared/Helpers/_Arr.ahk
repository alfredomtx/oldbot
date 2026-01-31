#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

class _Arr extends _BaseClass
{
    /**
    * @param object object
    * @param string key
    * @return bool
    */
    exists(object, key)
    {
        return object.HasKey(key)
    }

    /**
    * @param object object
    * @param string value
    * @return ?string
    */
    search(object, value)
    {
        for key, v in object {
            if (v = value) {
                return key
            }
        }
    }

    /**
    * @param object object
    * @param string key
    * @return bool
    */
    notExists(object, key)
    {
        return !this.exists(object, key)
    }

    /**
    * @param object object
    * @return mixed
    */
    first(object)
    {
        if (!IsObject(object) && InStr(object, ".")) {
            object := StrSplit(object, ".")
        }

        for _, value in object {
            return value
        }
    }

    /**
    * @param object object
    * @return mixed
    */
    last(object)
    {
        if (!IsObject(object) && InStr(object, ".")) {
            object := StrSplit(object, ".")
        }

        if (!IsObject(object)) {
            return
        }

        temp := object.Clone()
        return temp.pop()
    }

    /**
    * @param object object
    * @return mixed
    */
    lastKey(object)
    {
        for key, _ in this.last(object) {
            return key
        }
    }

    /**
    * Wrap the value in an array in case it is not.
    * 
    * @param mixed value
    * @return array
    */
    wrap(value)
    {
        if (IsObject(value)) {
            return value
        }

        return Array(value)
    }

    /**
    * @param array object
    * @param string character
    * @return array
    */
    concat(object, character)
    {
        string := ""
        index := 1
        for _, value in object {
            if (index >= object.Count()) {
                string .= value
                break
            }

            string .= value "" character
            index++
        }

        return string
    }

    /**
    * @param array object
    * @param string needle
    * @return array
    */
    remove(object, needle)
    {
        if (_Arr._empty(needle)) {
            return object
        }

        if (!IsObject(object)) {
            return object
        }

        obj := {}
        for key, value in object {
            if (IsObject(needle)) {
                skip := false
                for _, needleValue in needle {
                    if (value = needleValue) {
                        skip := true
                        break
                    }
                }

                if (skip) {
                    continue
                }
            }

            if (value = needle) {
                continue
            }

            obj[key] := value
        }

        return obj
    }

    /**
    * @param array object
    * @param string needle
    * @return array
    */
    removeKey(object, needle)
    {
        if (_Arr._empty(needle)) {
            return object
        }

        if (!IsObject(object)) {
            return object
        }

        if (!object.HasKey(needle)) {
            return object
        }

        obj := object.Clone()
        obj.Delete(needle)

        return obj
    }

    /**
    * @param array object
    * @return ?array
    */
    keys(object)
    {
        if (!IsObject(object)) {
            return
        }

        obj := {}
        for key, value in object {
            obj.Push(key)
        }

        return obj
    }

    /**
    * @param array object
    * @return ?array
    */
    values(object)
    {
        if (!IsObject(object)) {
            return
        }

        obj := {}
        for key, value in object {
            obj.Push(value)
        }

        return obj
    }

    /**
    * @param array object
    * @return array
    */
    clone(object)
    {
        obj := {}
        for key, value in object {
            if (IsObject(value)) {
                obj[key] := value.Clone()
                continue
            }

            obj[key] := value
        }

        return obj
    }

    /**
    * @param array object
    * @param bool list
    * @return ?array
    */
    shift(object, list := false)
    {
        if (!IsObject(object)) {
            return object
        }

        if (object.Count() <= 1) {
            return
        }

        obj := {}
        index := 1
        for key, value in object {
            if (A_Index = 1) {
                continue
            }

            obj[list ? index : key] := value
            index++
        }

        return obj
    }

    /**
    * @param array array2
    * @return array
    */
    merge(array1, array2)
    {
        if (!IsObject(array1)) {
            return array2
        }

        obj := array1.Clone()
        for key, value in array2 {
            obj[key] := value
        }

        return obj
    }

    /**
    * @param object object
    * @param null|string|BoundFunc filter
    * @return mixed
    */
    filter(object, filter := "")
    {
        if (!IsObject(object)) {
            return
        }

        obj := {}
        if (_Arr._isFunction(filter)) {
            for key, value in object {
                result := filter.Call(key, value)
                if (result) {
                    obj[key] := value
                }
            }

            return obj
        }

        if (filter) {
            for key, value in object {
                if (_Arr._empty(value) || value = filter) {
                    continue
                }

                obj[key] := value
            }

            return obj
        }

        for key, value in object {
            if (!_Arr._empty(value)) {
                obj[key] := value
            }
        }

        return obj
    }

    /**
    * @param array object
    * @return array
    */
    invert(arr)
    {
        obj := []
        for index, value in arr
            obj.Insert(1, value)

        return obj
    }

    /**
    * @param mixed value
    * @return bool
    */
    _empty(value := "")
    {
        return (value = "" || value = A_Space) && value != 0
    }


    /**
    * @return bool
    */
    _isFunction(value)
    {
        funcRefrence := numGet(&(_ := Func("inStr").bind()), "ptr")
        return isFunc(value) || (isObject(value) && (numGet(&value, "ptr") = funcRefrence))
    }
}