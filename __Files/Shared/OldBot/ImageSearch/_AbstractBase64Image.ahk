
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

/**
* @property string name
* @property string base64
* @property string inheritorClassName
* @property _BitmapImage bitmap
*/
class _AbstractBase64Image extends _BaseClass
{
	__New(name := "", base64 := "", inheritorClass := "")
	{
		guardAgainstAbstractClassInstance(inheritorClass, this)
		this.inheritorClassName := inheritorClass.__Class

		_Validation.empty("name", name)
		_Validation.empty("base64", base64)

		this.setBase64(base64)
		this.setName(name)
	}

	/**
	* @abstract
	* @return void
	*/
	disposeImageFromCache()
	{
		abstractMethod()
	}

	/**
	* @return void
	*/
	dispose()
	{
		this.getBitmap().dispose(), this.bitmap := ""
			, this.disposeImageFromCache()
	}

	/**
	* @return _BitmapImage
	*/
	getBitmap()
	{
		if (this.bitmap) {
			return this.bitmap
		}

		this.bitmap := new _BitmapImage(this.getBase64())
			.setIdentifier(this.getName())

		return this.bitmap
	}

	/**
	* @param _BitmapImage bitmap
	* @return this
	*/
	setBitmap(bitmap)
	{
		_Validation.instanceOf("bitmap", bitmap, _BitmapImage)

		this.getBitmap().dispose()
		this.bitmap := bitmap

		return this
	}

	/**
	* @return _BitmapImage
	*/
	getHBitmap()
	{
		return this.getBitmap().getHBitmap()
	}

	/**
	* @return string
	*/
	getName()
	{
		return this.name
	}

	/**
	* @return string
	*/
	getBase64()
	{
		return this.base64
	}

	/**
	* @param string name
	* @return this
	*/
	setName(name)
	{
		this.name := name
		return this
	}

	/**
	* @param string base64
	* @return this
	*/
	setBase64(base64)
	{
		this.base64 := base64
		return this
	}

	/**
	* @return int
	* @throws
	*/
	getW()
	{
		return this.getBitmap().getW()
	}

	/**
	* @return int
	* @throws
	*/
	getH()
	{
		return this.getBitmap().getH()
	}

	/**
	* @param ?bool msgbox
	* @return void
	* @msgbox
	*/
	debug(msgbox := true)
	{
		this.getBitmap().debug(msgbox)
	}

	/**
	* @return void
	*/
	toClipboard()
	{
		this.getBitmap().toClipboard()
	}
}