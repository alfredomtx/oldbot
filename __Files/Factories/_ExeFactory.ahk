#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

class _ExeFactory extends _BaseClass
{
    /**
    * @return _AbstractExe
    * @throws
    */
    __New(name)
    {
        _Validation.empty("name", name)

        exes := this.getExes()
        if (!exes[name]) {
            throw Exception("Invalid exe name: " name)
        }

        return exes[name]
    }

    /**
    * @return array<string, _AbstractExe>
    */
    getExes()
    {
        static exes
        if (exes) {
            return exes
        }

        exes := {}
        for _, exe in _Executables.getList() {
            exes[exe.NAME] := exe
        }

        return exes
    }
}