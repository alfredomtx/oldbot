
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Objects\Images\_AbstractItemImage.ahk

class _ItemImage extends _AbstractItemImage
{
	static CACHE := {}

	__Call(method, args*) {
		methodParams(this[method], method, args)
	}

	__New(name, paintBorder := true)
	{
		if (_ItemImage.CACHE[name]) {
			return _ItemImage.CACHE[name]
		}

		base.__New(name, itemsImageObj[name].image_full, this, paintBorder)

		_ItemImage.CACHE[this.getName()] := this
	}

	/**
	* @abstract
	* @return void
	*/
	disposeImageFromCache()
	{
		_ItemImage.CACHE.Delete(this.getName())
	}
}