
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

class _Str extends _BaseClass
{
    /**
    * @param string haystack
    * @param string needle
    * @return bool
    */
    contains(haystack, needle)
    {
        if (IsObject(needle)) {
            for _, value in needle {
                if (InStr(haystack, value)) {
                    return true
                }
            }
            return false
        }

        return InStr(haystack, needle)
    }

    /**
    * @param string haystack
    * @param string needle
    * @return string
    */
    startsWith(haystack, needle)
    {
        needleLength := StrLen(needle)
        if (StrLen(haystack) < needleLength) {
            return false
        }

        return SubStr(haystack, 1, needleLength) = needle
    }

    /**
    * @param ?int length
    * @return string
    */
    random(length := "")
    {
        Random, R, 6, 16

        str := ""
        Loop, % length ? length : R {
            Random, randomNumber, 65, 90  ; Generate a random number between ASCII values for uppercase letters (A-Z)
            Random, r, 0, 1

            letter := Chr(randomNumber)
            if (r) {
                letter := this.toLower(letter)
            }

            str .= letter
        }

        return str
    }

    /**
    * @param string string
    * @return string
    */
    toUpper(string)
    {
        return Format("{:U}", string)
    }

    /**
    * @param string string
    * @return string
    */
    toLower(string)
    {
        return Format("{:L}", string)
    }

    /**
    * @param string string
    * @return string
    */
    quoted(string)
    {
        return """" string """"
    }

    /**
    * @param string string
    * @return string
    */
    first(string)
    {
        return SubStr(string, 1, 1)
    }

    /**
    * @param string string
    * @return string
    */
    withoutSpaces(string)
    {
        return StrReplace(string, " ", "_")
    }

    /**
    * @param string string
    * @return string
    */
    withSpaces(string)
    {
        return StrReplace(string, "_", " ")
    }
}