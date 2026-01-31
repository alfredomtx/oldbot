
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ImageSearch\_Base64ImageSearch.ahk

/**
* @property string name
* @property string imageName
* @property string size
*/
class _ItemSearch extends _Base64ImageSearch
{
	static SIZE_HALF := "half"
	static SIZE_FULL := "full"
	static SIZE_BAR := "bar"

	static OFFSET_X := 12
	static OFFSET_Y := 12

	; __Call(method, args*) {
	; 	methodParams(this[method], method, args)
	; }

	__New()
	{
		base.__New(this)

		this.setArea(new _SideBarsArea())
		this.setVariation(OldBotSettings.settingsJsonObj.options.itemSearchVariation)
		this.setTransColor(ImagesConfig.pinkColorTrans)

		this.setResultOffsetX(this.OFFSET_X)
		this.setResultOffsetY(this.OFFSET_Y)

		this.invertOrder := false
		this.onlyOneSprite := false
		this.delayCountAnimation := 75
		this.loopCountAnimation := 20

		this.options := {}
	}

	setOption(key, value)
	{
		this.options[key] := value
		return this
	}

	/**
	* @abstract
	* @return void
	* @throws
	*/
	validations()
	{
		base.validation()
		_Validation.empty("this.name", this.name)
		_Validation.empty("itemsImageObj.name", itemsImageObj[this.name])
	}

	/**
	* @abstract
	* @return this
	* @throws
	*/
	search()
	{
		this.item := itemsImageObj[this.name]
		this.spritesCount := this.item.sprites
		this.initialVariation := this.getVariation()

		loop, % this.spritesCount {
			this.setInitialSpriteIndex(A_Index)

			this.resolveCurrentImageName()

			this.resolveVariation()

			try {
				this.searchImage()
			} catch e {
				this.disposeShrinkedImageRubinot()

				_Logger.exception(e, this.name)
				; throw e
				return this
			}

			if (this.onlyOneSprite) {
				break
			}

			if (this.found()) {
				break
			}

		}

		return this
	}

	disposeShrinkedImageRubinot()
	{
		if (!isRubinot()) {
			return
		}

		this.itemImage.dispose()
	}

	setInitialSpriteIndex(loopIndex)
	{
		if (loopIndex = 1) {
			this.spriteIndex := (this.invertOrder) ? this.spritesCount : loopIndex
			return
		}

		this.spriteIndex := (this.invertOrder) ? this.spritesCount - loopIndex : loopIndex
	}

	resolveVariation()
	{
		this.checkAmmunitionVariation()

		if (this.options["trade"] && isRubinot()) {
			this.setVariation(85)
		}
	}

	/**
	* if is arrow or bolt, when searching for the first sprite, use less variation so the image
	* is not found in a different place, example: diamond arrow first sprite, because it it's cropped
	*/
	checkAmmunitionVariation()
	{
		if (this.spritesCount <= 1) {
			return
		}

		if (!RegExMatch(this.name, "(arrow|bolt)")) {
			return
		}

		if (this.getArea().__Class != _ActionBarArea.__Class) {
			return
		}

		this.setVariation(this.spriteIndex = 1 ? 10 : this.initialVariation)
	}

	resolveCurrentImageName()
	{
		if (this.spriteIndex <= 1) {
			this.imageName := this.name
			return
		}

		this.imageName := this.name "_" this.spriteIndex
	}

	/**
	* @return void
	* @throws
	*/
	searchImage()
	{
		_Validation.empty("this.imageName", this.imageName)

		switch this.getSize() {
			case _ItemSearch.SIZE_BAR:
				this.itemImage := new _BarItemImage(this.imageName)

				if (isRubinot()) {
					this.itemImage.dispose()
					this.itemImage := new _BarItemImage(this.imageName)
					this.itemImage.getBitmap().cropSelf(0, 0, 2)
					; this.itemImage.toClipboard()
				}

				this.setImage(this.itemImage)

			case _ItemSearch.SIZE_FULL:
				this.itemImage := new _ItemImage(this.imageName)

				if (this.options["trade"] && isRubinot()) {
					this.itemImage.dispose()
					this.itemImage := new _ItemImage(this.imageName, false)
					this.itemImage.getBitmap().cropSelf(1, 1)
					this.itemImage.getBitmap().shrink()
					; this.itemImage.toClipboard()
				}

				this.setImage(this.itemImage)

			default:
				this.itemImage := new _HalfItemImage(this.imageName)
				this.setImage(this.itemImage)
		}

		Loop, % this.loopCountAnimation {
			base.search()

			if (this.found()) {
				break
			}

			if (!this.item.animated_sprite) {
				break
			}

			Sleep, % this.delayCountAnimation
		}

		this.disposeShrinkedImageRubinot()
	}

	/**
	* @param string name
	* @return this
	*/
	setName(name)
	{
		_Validation.empty(A_ThisFunc ".name", name)
		this.name := name
		return this
	}

	/**
	* @return string
	*/
	getName()
	{
		return this.name
	}

	/**
	* @param string name
	* @return this
	*/
	setSize(size)
	{
		this.size := size
		return this
	}

	/**
	* @return string
	*/
	getSize()
	{
		return this.size
	}

	/**
	* @return this
	*/
	setHalfImage()
	{
		this.size := _ItemSearch.SIZE_HALF
		return this
	}

	/**
	* @return this
	*/
	setFullImage()
	{
		this.size := _ItemSearch.SIZE_FULL
		return this
	}

	/**
	* @return this
	*/
	setOnlyOneSprite()
	{
		this.onlyOneSprite := true
		return this
	}

	/**
	* @return this
	*/
	setInvertOrder()
	{
		this.invertOrder := true
		return this
	}

	/**
	* @param int value
	* @return this
	*/
	setLoopCountAnimation(value)
	{
		_Validation.number("value", value)
		this.loopCountAnimation := value
		return this
	}
}