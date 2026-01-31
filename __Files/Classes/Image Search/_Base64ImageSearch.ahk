
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ImageSearch\_AbstractImageSearch.ahk

/**
* @property _AbstractBase64Image image
*/
class _Base64ImageSearch extends _AbstractBitmapSearch
{
	; __Call(method, args*) {
	; 	methodParams(this[method], method, args)
	; }

	__New()
	{
		base.__New(this)
	}

	/**
	* @abstract
	* @return _BitmapImage
	*/
	getImageBitmap()
	{
		return this.getImage().getBitmap()
	}

	/**
	* @abstract
	* @return this
	*/
	disposeImageBitmap()
	{
		this.getImage().dispose()
		return this
	}

	/**
	* @abstract
	* @return void
	* @throws
	*/
	validations()
	{
		_Validation.instanceOf("this.getImage()", this.getImage(), _AbstractBase64Image)
	}

	/**
	* @return _AbstractBase64Image
	*/
	getImage()
	{
		return this.image
	}

	/**
	* @param _AbstractBase64Image image
	* @return this
	*/
	setImage(image)
	{
		this.image := image
		return this
	}
}