#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\_Market\Actions\_Loggable.ahk

class _CheckboxCheck extends _Loggable
{
    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    __New(checkedImage, uncheckedImage)
    {
        this._loopSearch := true
        this.checkedImage := checkedImage
        this.uncheckedImage := uncheckedImage
    }

    loopSearch(value := true) 
    {
        this._loopSearch := value
        return this
    }

    run()
    {
        array := _A.split(this.uncheckedImage, ".")
        imageName := array[array.Count() - 1]

        this.log(txt("Selecionando o checkbox " _Str.quoted(imageName) ".", "Selecting the " _Str.quoted(imageName) " checkbox."))
        checked := ims(this.checkedImage)

        this._loopSearch ? checked.loopSearch() : checked.search()
        if (checked.found()) {
            return
        }

        unchecked := ims(this.uncheckedImage)
        this._loopSearch ? unchecked.loopSearch() : unchecked.search()
        if (unchecked.notFound()) {
            throw Exception(this.uncheckedImage " not found.")
        }

        unchecked.setClickOffsets(4)
            .click()

        sleep(100, 200)

        this._loopSearch ? checked.loopSearch() : checked.search()
        if (checked.notFound()) {
            throw Exception("Falha ao selecionar o checkbox " _Str.quoted(imageName) ".", "Failed to select the " _Str.quoted(imageName) " checkbox.")
        }
    }



}