#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Executables\_AbstractExe.ahk

class _OldBotExe extends _AbstractExe
{
    static NAME := "OldBot PRO"
    static TEMP_FOLDER := ""

    /**
    * @return bool
    */
    usesRandomName()
    {
        return true
    }

    /**
    * @return string
    */
    getPath()
    {
        return this.getName()
    }

    /**
    * @return string
    */
    getCurrentPath()
    {
        return this.getCurrentName()
    }

    /**
    * @return string
    */
    getRandomExePath(name)
    {
        return name
    }

    /**
    * @return void
    */
    processExistOpen()
    {
        try {
            if (!FileExist(this.getCurrentPath())) {
                throw Exception("File not found: " this.getCurrentPath())
            }
            Run, % this.getCurrentPath()
        } catch e {
            throw e
        }
    }
}