
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ImageSearch\_Base64ImageSearch.ahk

/**
* @property _BitmapImage targetingScreenBitmap
*/
class _TargetingBase64ImageSearch extends _Base64ImageSearch
{
	__New()
	{
		base.__New(this)
	}

	/**
	* @return _BitmapImage
	*/
	getScreenBitmap()
	{
		if (this.targetingScreenBitmap) {
			return this.targetingScreenBitmap
		}

		return this.targetingScreenBitmap := _BitmapEngine.getBitmap(this.getCoordinates(), this.__Class)
	}

	/**
	* @return void
	*/
	disposeScreenBitmap()
	{
		this.targetingScreenBitmap.dispose(), this.targetingScreenBitmap := ""
	}
}