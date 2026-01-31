
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ImageSearch\_AbstractImageSearch.ahk

/**
* @property _BitmapImage bitmap
*/
class _BitmapImageSearch extends _AbstractBitmapSearch
{
	; __Call(method, args*) {
	; 	methodParams(this[method], method, args)
	; }

	__New() {
		base.__New(this)
	}

	/**
	* @abstract
	* @return _BitmapImage
	*/
	getImageBitmap() {
		return this.getBitmap()
	}

	/**
	* @abstract
	* @return this
	*/
	disposeImageBitmap() {
		this.getBitmap().dispose()
		return this
	}

	/**
	* @abstract
	* @return void
	* @throws
	*/
	validations() {
		_Validation.instanceOf("this.getBitmap()", this.getBitmap(), _BitmapImage)
	}

	/**
	* @return _BitmapImage
	*/
	getBitmap() {
		return this.bitmap
	}

	/**
	* @param _BitmapImage bitmap
	* @return this
	*/
	setBitmap(bitmap) {
		this.bitmap := bitmap
		return this
	}
}