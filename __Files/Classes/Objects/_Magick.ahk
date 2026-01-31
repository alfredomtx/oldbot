
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Config\_Folders.ahk

Class _Magick extends _BaseClass
{
    static ENABLED := false
    static EXE_PATH := _Folders.BIN "\magick.exe"
    static GAMMA := "1.5"

    static OUTPUT_PATH := A_Temp "\OldBot\magick_output.png"
    static INPUT_PATH := A_Temp "\OldBot\magick_input.png"

    __New(image)
    {
        _Validation.instanceOf("image", _BitmapImage)

        this.image := image
        this.ran := false
        this.elapsed := ""

        this.draw := ""
    }

    run()
    {
        t := new _Timer()
        if (!this.ENABLED) {
            this.ran := true
            this.image.save(this.OUTPUT_PATH)

            return this
        }

        try {
            _Validation.fileExists("EXE_PATH", _Magick.EXE_PATH)

            deleteFileIfExists(this.OUTPUT_PATH)

            this.image.save(this.INPUT_PATH)


            cmd := _Str.quoted(this.EXE_PATH) " " _Str.quoted(this.INPUT_PATH) " -gamma " this.GAMMA

            if (this.draw) {
                cmd .= " " this.draw
            }

            cmd .= " " _Str.quoted(this.OUTPUT_PATH)


            RunWait, %cmd%,, Hide

            this.ran := true
        } finally {
            deleteFileIfExists(this.INPUT_PATH)
        }

        this.elapsed := t.elapsed()

        return this

        ; t.elapsed(msgbox := true)
    }

    setDraw(x, y, w, h, color := "pink")
    {
        this.draw := "-fill " color " -draw " _Str.quoted("rectangle " x "," y " " w "," h)

        return this
    }

    getOutputBitmap()
    {
        if (!this.ran) {
            throw Exception("run() must be called before getOutputBitmap().")
        }

        return new _BitmapImage(this.OUTPUT_PATH)
    }

}