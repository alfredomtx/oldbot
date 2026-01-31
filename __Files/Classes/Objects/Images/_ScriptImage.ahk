
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ImageSearch\_AbstractBase64Image.ahk

class _ScriptImage extends _AbstractBase64Image
{
	static CACHE := {}

	__Call(method, args*) {
		methodParams(this[method], method, args)
	}

	__Init() {
		_Validation.isObject("scriptImagesObj", scriptImagesObj)
	}

	__New(name) {
		if (_ScriptImage.CACHE[name]) {
			return _ScriptImage.CACHE[name]
		}

		_Validation.hasKey("scriptImagesObj", scriptImagesObj, name)
		_Validation.empty("scriptImagesObj[name].image", scriptImagesObj[name].image)

		base.__New(name, scriptImagesObj[name].image, this)

		_ScriptImage.CACHE[this.getName()] := this
	}

	/**
	* @abstract
	* @return void
	*/
	disposeImageFromCache() {
		_ScriptImage.CACHE.Delete(this.getName())
	}
}