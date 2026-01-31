
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Classes\Objects\Images\_AbstractItemImage.ahk

class _HalfItemImage extends _AbstractItemImage
{
	static CACHE := {}

	__Call(method, args*) {
		methodParams(this[method], method, args)
	}

	__New(name)
	{
		if (_HalfItemImage.CACHE[name]) {
			return _HalfItemImage.CACHE[name]
		}

		base.__New(name, itemsImageObj[name].image, this)

		_HalfItemImage.CACHE[this.getName()] := this
	}

	/**
	* @abstract
	* @return void
	*/
	disposeImageFromCache()
	{
		_HalfItemImage.CACHE.Delete(this.getName())
	}
}