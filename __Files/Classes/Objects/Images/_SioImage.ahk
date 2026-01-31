
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ImageSearch\_AbstractBase64Image.ahk

class _SioImage extends _AbstractBase64Image
{
	static CACHE := {}

	__Call(method, args*) {
		methodParams(this[method], method, args)
	}

	__Init() {
		_Validation.isObject("sioFriendObj", sioFriendObj)
	}

	__New(name)
	{
		if (_SioImage.CACHE[name]) {
			return _SioImage.CACHE[name]
		}

		_Validation.hasKey("sioFriendObj", sioFriendObj, name)

		base.__New(name, sioFriendObj[name].image, this)

		_SioImage.CACHE[this.getName()] := this
	}

	/**
	* @abstract
	* @return void
	*/
	disposeImageFromCache()
	{
		_SioImage.CACHE.Delete(this.getName())
	}
}