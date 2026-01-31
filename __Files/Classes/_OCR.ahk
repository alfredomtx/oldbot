
class _OCR
{
    static TEMP_IMAGE := A_Temp "\_ocr_temp.png"
    static TEMP_OUTPUT := A_Temp "\_ocr_output.txt"

    __New()
    {
        this.numbersOnly(false)
    }

    run(image, deleteImage := true)
    {
        if (instanceOf(image, _BitmapImage)) {
            if (this._increaseDpi) {
                image.increaseDpi(this._increaseDpi)
            }

            ; image.debug()

            image.save(this.TEMP_IMAGE)
            dir := this.TEMP_IMAGE
        } else {
            _Validation.fileExists("image", image)
            dir := image
        }

        try {
            text := this.runTesseract(dir)
            return text
        } finally {
            if (deleteImage) {
                try  {
                    FileDelete, % dir
                } catch {
                }
            }
        }

        return text
    }

    runTesseract(imagePath)
    {
        static q := Chr(0x22)
        static validated := false

        this.tesseract := A_WorkingDir "\Data\Files\bin\tesseract\tesseract.exe"
        this.tessdata := A_WorkingDir "\Data\Files\bin\tesseract\tessdata"

        if (!validated) {
            if !(FileExist(this.tesseract))
                throw Exception("Tesseract not found",, this.tesseract)

            if !(FileExist(this.tessdata))
                throw Exception("tessdata not found",, this.tessdata)

            validated := true
        }

        command := q this.tesseract q " --tessdata-dir " q  this.tessdata q " " q imagePath q " "  q SubStr(this.TEMP_OUTPUT, 1, -4) q " "
        /**
        0 = Orientation and script detection (OSD) only.
        1 = Automatic page segmentation with OSD.
        2 = Automatic page segmentation, but no OSD, or OCR. (not implemented)
        3 = Fully automatic page segmentation, but no OSD. (Default)
        4 = Assume a single column of text of variable sizes.
        5 = Assume a single uniform block of vertically aligned text.
        6 = Assume a single uniform block of text.
        7 = Treat the image as a single text line.
        8 = Treat the image as a single word.
        9 = Treat the image as a single word in a circle.
        10 = Treat the image as a single character.
        11 = Sparse text. Find as much text as possible in no particular order.
        12 = Sparse text with OSD.
        13 = Raw line. Treat the image as a single text line, bypassing hacks that are Tesseract-specific.
        */
        psm := this._psm ? this._psm : (this._numbersOnly ? 6 : 6)
        command .= "--oem 3 "
        command .= "--psm " psm " "
        if (this._numbersOnly) {
            command .= "-c tessedit_char_whitelist=0123456789 "
        }

        _cmd := ComSpec " /C " q command q
        RunWait % _cmd,, Hide

        if !(FileExist(this.TEMP_OUTPUT)) {
            throw Exception("Tesseract failed.",, _cmd)
        }

        try {
            FileRead, content, % this.TEMP_OUTPUT
            return content
        } finally {
            this.cleanup()
        }
    }

    cleanup()
    {
        try {
            FileDelete, % this.TEMP_OUTPUT
        } catch {
        }
    }

    psm(value)
    {
        this._psm := value

        return this
    }

    numbersOnly(value := true)
    {
        this._numbersOnly := value

        return this
    }

    increaseDpi(value := 300)
    {
        this._increaseDpi := value

        return this
    }
}