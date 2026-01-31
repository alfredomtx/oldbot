
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ImageSearch\_AbstractBase64Image.ahk

class _CreatureImage extends _AbstractBase64Image
{
	static CACHE := {}

	__Call(method, args*) {
		methodParams(this[method], method, args)
	}

	__Init() {
		_Validation.isObject("targetingObj.targetList", targetingObj.targetList)
	}

	__New(name) {
		if (_CreatureImage.CACHE[name]) {
			return _CreatureImage.CACHE[name]
		}

		_Validation.hasKey("targetingObj.targetList", targetingObj.targetList, name)
		_Validation.empty("targetingObj.targetList[name].image", targetingObj.targetList[name].image)

		if (empty(targetingObj.targetList[name].image)) {
			throw Exception(txt("A criatura """ name """ não possui imagem.", "Creature """ name """ has no image."))
		}

		base.__New(name, targetingObj.targetList[name].image, this)

		_CreatureImage.CACHE[this.getName()] := this
	}

	/**
	* @abstract
	* @return void
	*/
	disposeImageFromCache() {
		_CreatureImage.CACHE.Delete(this.getName())
	}
}