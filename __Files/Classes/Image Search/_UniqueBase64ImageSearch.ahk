
/**
* @property _BitmapImage uniqueScreenBitmap
*/
class _UniqueBase64ImageSearch extends _Base64ImageSearch
{
	__New() {
		base.__New(this)
	}

	/**
	* @param bool withNewScreenBitmap
	* @return this
	*/
	search(withNewScreenBitmap := false) {
		if (withNewScreenBitmap) {
			this.disposeScreenBitmap()
		}

		base.search()
		return this
	}

	/**
	* @return _BitmapImage
	*/
	getScreenBitmap() {
		if (this.uniqueScreenBitmap) {
			return this.uniqueScreenBitmap
		}

		return this.uniqueScreenBitmap := _BitmapEngine.getBitmap(this.getCoordinates(), this.__Class)
	}

	/**
	* @return void
	*/
	disposeScreenBitmap() {
		this.uniqueScreenBitmap.dispose(), this.uniqueScreenBitmap := ""
	}
}