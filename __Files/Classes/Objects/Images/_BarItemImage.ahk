
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Objects\Images\_AbstractItemImage.ahk

class _BarItemImage extends _AbstractItemImage
{
	static CACHE := {}
	static CROP_UP := 9

	__Call(method, args*) {
		methodParams(this[method], method, args)
	}

	__New(name) {
		if (_BarItemImage.CACHE[name]) {
			return _BarItemImage.CACHE[name]
		}

		base.__New(name, itemsImageObj[name].image, this)

		cropped := new _BitmapImage(this.getBitmap().crop(0, 0, _BarItemImage.CROP_UP, 0))

		this.setBitmap(cropped)
		this.paintBackgroundPink()

		_BarItemImage.CACHE[this.getName()] := this
	}

	/**
	* @abstract
	* @return void
	*/
	disposeImageFromCache() {
		_BarItemImage.CACHE.Delete(this.getName())
	}
}