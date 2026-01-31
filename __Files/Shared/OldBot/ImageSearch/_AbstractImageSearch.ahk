
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ImageSearch\_AbstractBitmapSearch.ahk

/**
* @property _BitmapImage bitmap
* @property string file
* @property string folder
*/
class _AbstractImageSearch extends _AbstractBitmapSearch
{
	static CACHE := {}

	__New(inheritorClass := "")
	{
		guardAgainstAbstractClassInstance(inheritorClass, this)

		base.__New(this)
	}

	/**
	* @abstract
	* @return _BitmapImage
	*/
	getImageBitmap()
	{
		if (this.bitmap) {
			return this.bitmap
		}

		this.setBitmapImage(this.getBitmapFromFile())

		return this.bitmap
	}

	/**
	* @abstract
	* @return this
	*/
	disposeImageBitmap()
	{
		this.getImageBitmap().dispose()
		this.disposeBitmapFromCache()
		this.bitmap := ""

		return this
	}

	/**
	* @abstract
	* @return void
	* @throws
	*/
	validations()
	{
		_Validation.empty("file", this.getFile())
			, _Validation.empty("folder", this.getFolder())
			, _Validation.fileExists("this.getFilePath()", this.getFilePath())

		this.validateCoordinates()
	}

	/**
	* @return void
	*/
	disposeBitmapFromCache()
	{
		filePath := this.getFilePath()
			, _AbstractImageSearch.CACHE[filePath] := ""
			, _AbstractImageSearch.CACHE.Delete(filePath)
	}

	/**
	* @return _BitmapImage
	*/
	getBitmapFromFile()
	{
		filePath := this.getFilePath()

		if (_AbstractImageSearch.CACHE[filePath]) {
			return _AbstractImageSearch.CACHE[filePath]
		}

		return _AbstractImageSearch.CACHE[filePath] := new _BitmapImage(filePath)
			.setIdentifier(filePath)
	}

	/**
	* @return string
	*/
	getFile()
	{
		return this.file
	}

	/**
	* @return string
	*/
	getFolder()
	{
		return this.folder
	}

	/**
	* @return ?string
	*/
	getFilePath()
	{
		folder := this.getFolder(), file := this.getFile()
		if (isAnyEmpty(folder, file)) {
			return
		}

		return folder "\" file
	}

	/**
	* @param string file
	* @return this
	*/
	setFile(file)
	{
		_Validation.empty("file", file)
		this.file := this.enforcePng(file)

		if (!this.getFilePath()) {
			return this
		}

		this.setBitmapImage(this.getBitmapFromFile())

		return this
	}

	setBitmapImage(image)
	{
		_Validation.instanceOf("image", image, _BitmapImage)

		this.bitmap := image

		return this
	}

	/**
	* @param string folder
	* @return this
	*/
	setFolder(folder)
	{
		this.folder := folder

		if (!this.getFilePath()) {
			return this
		}

		this.setBitmapImage(this.getBitmapFromFile())

		return this
	}

	/**
	* @param string path
	* @return this
	*/
	setPath(path)
	{
		SplitPath, % path, fileName, fileDir

		; unsetting in case it was set before
		this.folder := ""
		this.file := ""

		this.setFile(fileName)
		this.setFolder(fileDir)

		return this
	}

	/**
	* @param string file
	* @return string
	*/
	enforcePng(file)
	{
		if (!InStr(file, ".png")) {
			file .= ".png"
		}

		return file
	}

}