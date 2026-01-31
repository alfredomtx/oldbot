
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\libraries\JSONFile.ahk

class _Json extends _BaseClass
{
    load(filePath := "")
    {
        local obj, data, files
        obj := this.loadObject(filePath)

        classLoaded("_A", _A)

        if (extends := obj.__extends) {
            files := _Arr.wrap(extends)

            for _, file in files {
                SplitPath, filePath,, outDir
                data := this.load(outDir "\" file)
                obj := _A.merge(data, obj)
                data := ""
            }
        }

        return obj
    }

    loadObject(filePath)
    {
        local json

        if (!IsObject(JSONFile)) {
            throw Exception("JSONFile not loaded.")
        }

        if (!filePath) {
            throw Exception("Empty file path.")
        }

        if (!FileExist(filePath)) {
            throw Exception("File does not exist: " filePath)
        }

        try {
            json := new JSONFile(filePath)
        } catch e {
            throw Exception("Failed to load JSON file """ filePath """" , e.Message "`n" e.What)
        }

        obj := json.Object()
        json := ""

        return obj
    }

    error(e, timeout := "")
    {
        OutputDebug("Load JSON File", e.Message " | " e.What)
        msgbox, 16, % "Load JSON File", % e.Message "`n`n" e.what, % timeout ? timeout : ""
    }
}