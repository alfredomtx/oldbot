
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ImageSearch\_AbstractBase64Image.ahk

class _AbstractItemImage extends _AbstractBase64Image
{
	__Init() {
		_Validation.isObject("scriptImagesObj", scriptImagesObj)
	}

	__New(name, base64, inheritorClass := "", paintBorder := true)
	{
		guardAgainstAbstractClassInstance(inheritorClass, this)

		_Validation.hasKey("itemsImageObj", itemsImageObj, name)

		base.__New(name, base64, inheritorClass)

		if (paintBorder) {
			this.paintCornerPink()
		}
	}

	/**
	* @return void
	* @throws
	*/
	paintCornerPink()
	{
		static itemCornerPos
		if (!itemCornerPos) {
			itemCornerPos := {}
			Loop, 6
				itemCornerPos.Push(new _Coordinate(A_Index - 1, 0))
			Loop, 5
				itemCornerPos.Push(new _Coordinate(A_Index - 1, 1))
			Loop, 4
				itemCornerPos.Push(new _Coordinate(A_Index - 1, 2))
			Loop, 3
				itemCornerPos.Push(new _Coordinate(A_Index - 1, 3))
			Loop, 2
				itemCornerPos.Push(new _Coordinate(A_Index - 1, 4))
			Loop, 1
				itemCornerPos.Push(new _Coordinate(A_Index - 1, 5))
		}

		for _, coordinate in itemCornerPos {
			this.getBitmap().setPixel(coordinate, ImagesConfig.pinkColor)
		}
	}


	paintBackgroundPink()
	{
		static grayBackgroundPixels
		if (!grayBackgroundPixels) {
			grayBackgroundPixels := {}
			grayBackgroundPixels.Push("0x2C2C2C")
			grayBackgroundPixels.Push("0x222223")
			grayBackgroundPixels.Push("0x2C2D2D")
			grayBackgroundPixels.Push("0x282829")
			grayBackgroundPixels.Push("0x212222")
			grayBackgroundPixels.Push("0x292A29")
			grayBackgroundPixels.Push("0x252626")
			grayBackgroundPixels.Push("0x2D2E2E")
			grayBackgroundPixels.Push("0x202020")
			grayBackgroundPixels.Push("0x292A2A")
			grayBackgroundPixels.Push("0x242424")
			grayBackgroundPixels.Push("0x282827")
			grayBackgroundPixels.Push("0x262627")
			grayBackgroundPixels.Push("0x202021")
			grayBackgroundPixels.Push("0x313232")
			grayBackgroundPixels.Push("0x1C1D1D")
			grayBackgroundPixels.Push("0x1C1C1C")
			grayBackgroundPixels.Push("0x272828")
			grayBackgroundPixels.Push("0x2C2C2B")
			grayBackgroundPixels.Push("0x303031")
			grayBackgroundPixels.Push("0x232423")
			grayBackgroundPixels.Push("0x242526")
			grayBackgroundPixels.Push("0x1E1E1F")
			grayBackgroundPixels.Push("0x2B2C2B")
			grayBackgroundPixels.Push("0x2F3030")
			grayBackgroundPixels.Push("0x2D2E2D")
			grayBackgroundPixels.Push("0x343434")
			grayBackgroundPixels.Push("0x272827")
			grayBackgroundPixels.Push("0x232424")
			grayBackgroundPixels.Push("0x2E2F30")
			grayBackgroundPixels.Push("0x272827")
			grayBackgroundPixels.Push("0x282828")
			grayBackgroundPixels.Push("0x303030")
			grayBackgroundPixels.Push("0x181919")
			grayBackgroundPixels.Push("0x242425")
			grayBackgroundPixels.Push("0x29292A")
			grayBackgroundPixels.Push("0x323333")
			grayBackgroundPixels.Push("0x20201F")
			grayBackgroundPixels.Push("0x2A2A2B")
			grayBackgroundPixels.Push("0x1A1A1A")
			grayBackgroundPixels.Push("0x2E2E2F")
			grayBackgroundPixels.Push("0x1B1B1B")
			grayBackgroundPixels.Push("0x252625")
			grayBackgroundPixels.Push("0x2E2E2F")
			grayBackgroundPixels.Push("0x1F2020")
			grayBackgroundPixels.Push("0x2B2B2C")
			grayBackgroundPixels.Push("0x191A19")
			grayBackgroundPixels.Push("0x272728")
			grayBackgroundPixels.Push("0x2F302F")
			grayBackgroundPixels.Push("0x212122")
			grayBackgroundPixels.Push("0x30302F")
			grayBackgroundPixels.Push("0x202221")
			grayBackgroundPixels.Push("0x353635")
			grayBackgroundPixels.Push("0x1D1E1D")
			grayBackgroundPixels.Push("0x353636")
			grayBackgroundPixels.Push("0x2D2D2E")
			grayBackgroundPixels.Push("0x1B1C1C")
			grayBackgroundPixels.Push("0x1D1E1E")
			grayBackgroundPixels.Push("0x1D1D1E")
			grayBackgroundPixels.Push("0x363737")
			grayBackgroundPixels.Push("0x3A3A3A")
			grayBackgroundPixels.Push("0x383838")
		}

		Loop, % this.getBitmap().getH() {
			y := A_Index - 1

			Loop, % this.getBitmap().getW() {
				x := A_Index - 1
					, coord := new _Coordinate(x, y)
					, pixColor := this.getBitmap().getPixel(coord)

				paint := false
				for _, value in grayBackgroundPixels
				{
					if (pixColor = value) {
						paint := true
						break
					}
				}

				if (paint) {
					this.getBitmap().setPixel(coord, ImagesConfig.pinkColor)
				}
			}
		}
	}

}