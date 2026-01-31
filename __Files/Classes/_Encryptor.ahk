
Class _Encryptor
{
	/**
	use the first 5 characters of the email as a "salt" for encrypting the password
	*/
	encryptPassword(email, password) {

		if (StrLen(email) < 4)
			throw Exception("E-mail is too short, less than 4 characters.")

		salt := SubStr(email, 1, 5)
		encryptedPass := this.encrypt(salt "" password)

		return encryptedPass
	}

	/**
	decrypt the base64 string and remove the first 5 characters of the string (the salt)
	*/
	decryptPassword(encryptedPass) {

		decrypted := this.decrypt(encryptedPass)
		StringTrimLeft, decrypted, decrypted, 5
		return decrypted
	}

	randomString1() {
		return "AAYqsWA"
	}

	randomString2() {
		return "xqyMawz"
	}

	writeFile(byRef content) {
		fileBase64Dir := A_Temp "/temp_oldbot_cr.txt"
		file := ""
		try file := FileOpen(fileBase64Dir, "w")
		catch e {
			throw Exception("Failed to open file: " fileBase64Dir)
		}

		file.Write(content)
		file.Close()
		file := ""
	}

	readFile() {
		FileRead, fileContent, % A_Temp "/temp_oldbot_cr.txt"
		try FileDelete, % A_Temp "/temp_oldbot_cr.txt"
		catch {
		}
		return fileContent
	}

	replace(newString) {
		return newBase64String
	}

	/**
	encrypt a string to base64 and also replace some strings to not be a pure base64

	problems: 
	*/
	encrypt(string) {
		; msgbox, % string
		try this.textToBase64(string, base64String)
		catch e {
			throw Exception("Failed to encrypt string: " string)
		}


		try this.writeFile(base64String)
		catch e {
			throw e
		}

		encryptedString := this.readFile()
		if (encryptedString = "")
			throw Exception("Failed to read encrypted string from file.")
		; msgbox, % encryptedString

		encryptedString := StrReplace(encryptedString, "`n", "") ; remove line break
		encryptedString := StrReplace(encryptedString, "`r", "") ; remove line break
		; encryptedString := StrReplace(encryptedString, "8", "00000") ; replace the number 8 for 5 zeros, for some reason the number 8 is bugging the encryption/decryption
		encryptedString := StrReplace(encryptedString, "=", this.randomString1()) ; replace "=" for this random string

		/**
		for some reason, 8 is buggin when decrypting if i use this "o" replacement
		*/
		; encryptedString := StrReplace(encryptedString, "o", this.randomString2(), "", 1) ; replace letter "o" for this random string
		return encryptedString

	}

	decrypt(base64String) {
		; base64String := StrReplace(base64String, "00000", "8")
		base64String := StrReplace(base64String, this.randomString1(), "=")
		; base64String := StrReplace(base64String, this.randomString2(), "o")

		this.Base64Dec( base64String, decryptedString)
		if (decryptedString = "") {
			; Msgbox, 48,, % "Fail to decrypt string:`n`n" base64String
		}

		return decryptedString
	}

	/** Function: Base64_Encode
	*     Encode data to Base64
	* Syntax:
	*     bytes := Base64_Encode( ByRef data, len, ByRef out [ , mode := "A" ] )
	* Parameter(s):
	*     bytes      [retval] - on success, the number of bytes copied to 'out'.
	*     data    [in, ByRef] - data to encode
	*     len            [in] - size in bytes of 'data'. Specify '-1' to automtically
	*                           calculate the size.
	*     out    [out, ByRef] - out variable containing the Base64 encoded data
	*     mode      [in, opt] - Specify 'A'(default) to use the ANSI version of
	*                           'CryptBinaryToString'. Otherwise, 'W' for UNICODE.
	*/
	textToBase64(ByRef data, ByRef out:="",len:=-1, mode:="W") {
		if !InStr("AW", mode := Format("{:U}", mode), true)
			mode := "A"
		BytesPerChar := mode=="W" ? 2 : 1
		if (Round(len) <= 0)
			len := StrLen(data) * (A_IsUnicode ? 2 : 1)

		; CRYPT_STRING_BASE64 := 0x00000001
		if DllCall("Crypt32\CryptBinaryToString" . mode, "Ptr", &data, "UInt", len
			, "UInt", 0x00000001, "Ptr", 0, "UIntP", size)
		{
			VarSetCapacity(out, size *= BytesPerChar, 0)
			if DllCall("Crypt32\CryptBinaryToString" . mode, "Ptr", &data, "UInt", len
				, "UInt", 0x00000001, "Ptr", &out, "UIntP", size)
			return size * BytesPerChar
		}
	}


	Base64Dec( ByRef B64, ByRef Bin ) {  ; By SKAN / 18-Aug-2017
		Local Rqd := 0, BLen := StrLen(B64)                 ; CRYPT_STRING_BASE64 := 0x1
		DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
			, "UInt",0, "UIntP",Rqd, "Int",0, "Int",0 )
		VarSetCapacity( Bin, 128 ), VarSetCapacity( Bin, 0 ),  VarSetCapacity( Bin, Rqd, 0 )
		DllCall( "Crypt32.dll\CryptStringToBinary", "Str",B64, "UInt",BLen, "UInt",0x1
			, "Ptr",&Bin, "UIntP",Rqd, "Int",0, "Int",0 )
		return Rqd
	}



}