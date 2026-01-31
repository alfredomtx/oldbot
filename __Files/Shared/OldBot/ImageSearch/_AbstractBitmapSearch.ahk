#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\_BaseClass.ahk

/**
* @property _AbstractClientArea clientArea
* @property _Coordinates coordinates
* @property string gdipResult
*
* @property bool _debug
* @property bool _debugResult
* @property bool firstResult
* @property bool imageFound
* @property bool defaultClickMethod
* @property bool disposeScreenBitmapAfterSearch
*
* @property ?int resultOffsetX
* @property ?int resultOffsetY
* @property ?int clickOffsetX
* @property ?int clickOffsetY
*
* @property _Coordinate result
* @property array<_Coordinate> results
*
* @property _BitmapImage screenBitmap
*
* @property string transColor
* @property int variation
*/
class _AbstractBitmapSearch extends _BaseClass
{
	static DEFAULT_VARIATION := 60

	__Init()
	{
		classLoaded("_BitmapEngine", _BitmapEngine)
		classLoaded("_Coordinate", _Coordinate)
		classLoaded("_Coordinates", _Coordinates)
		_Validation.empty("pToken", pToken)
	}

	__New(inheritorClass := "")
	{
		guardAgainstAbstractClassInstance(inheritorClass, this)

		this.setDebug(false)
			, this.setDebugResult(false)
			, this.setAllResults(false)
			, this.setImageFound(false)
			, this.searchPerformed := false
			, this.defaultClickMethod := true
			, this.disposeScreenBitmapAfterSearch := true
	}

	/**
	* @abstract
	* @return _BitmapImage
	*/
	getImageBitmap()
	{
		abstractMethod()
	}

	/**
	* @abstract
	* @return this
	*/
	disposeImageBitmap()
	{
		abstractMethod()
	}

	/**
	* @abstract
	* @return void
	* @throws
	*/
	validations()
	{
		abstractMethod()
	}

	/**
	* @abstract
	* @return void
	* @msgbox
	*/
	debugBitmapsToClipboard()
	{
		if (this._debug && !this._debugResult) {
			Gui, Carregando:Destroy
			WinActivate()
			Gdip_SetBitmapToClipboard(this.getScreenBitmap().get())
			this.debugMsg("Clipboard:`nscreen`n" this.getScreenBitmap().getIdentifier())
			Gdip_SetBitmapToClipboard(this.getImageBitmap().get())
			this.debugMsg("Clipboard:`nimage`n" this.getImageBitmap().getIdentifier())
		}
	}

	/**
	* @return this
	* @throws
	*/
	searchWithTimeout(timeout := 1000, delay := 100, loggerCallback := "")
	{
		if (loggerCallback) {
			_Validation.function("loggerCallback", loggerCallback)
		}

		timer := new _Timer()

		Loop, {
			if (timer.elapsed() > timeout) {
				throw Exception(txt("Timeout de " timeout " ms excedido e nenhuma imagem foi encontrada", "Timeout of " timeout " ms exceeded and no image was found"), "Timeout")
			}

			searchTimer := new _Timer()
			this.search()

			if (loggerCallback) {
				if (!this.firstResult) {
					%loggerCallback%(this.getResultsCount() " """ this.getImageBitmap().getIdentifier() """ images found on screen, elapsed: " searchTimer.elapsed() "ms (" timer.elapsed() "/" timeout "ms)")
				}
			}

			if (this.found()) {
				if (this.firstResult) {
					%loggerCallback%(_Str.quoted(this.getImageBitmap().getIdentifier()) " found on screen " searchTimer.elapsed() "ms (" timer.elapsed() "/" timeout "ms)")
				}
				return this
			}

			if (this.firstResult) {
				%loggerCallback%(_Str.quoted(this.getImageBitmap().getIdentifier()) " not found on screen " searchTimer.elapsed() "ms (" timer.elapsed() "/" timeout "ms)")
			}

			Sleep, % delay
		}

		return this
	}

	/**
	* @return this
	* @throws
	*/
	search()
	{
		this.sideBarArea := false
		if (this.isSideBarsArea()) {
			this.originalArea := this.getArea()
			this.sideBarArea := true
			this.setArea(new _SideBarRightArea())
		}

		this.validations()
			, this.validateCoordinates()
			, this.validateSearchParameters()
			, this.validateBitmaps()

		this.resolveCoordinates()

		this.performImageSearch()

		if (this.notFound() && this.sideBarArea) {
			sideBarAreaLeftArea := new _SideBarLeftArea()
			if (sideBarAreaLeftArea.getWidth() < 20) {
				return this
			}

			this.setArea(sideBarAreaLeftArea)
			this.performImageSearch()

			if (this.notFound()) {
				this.setArea(this.originalArea)
				this.originalArea := ""
			}
		}

		return this
	}

	/**
	* @return void
	*/
	performImageSearch()
	{
		local gdipSearchResult

		this.debugBitmapsToClipboard()
		this.debugCoordinatePositions()

		this.resetResult(), this.gdipResult := "", gdipSearchResult := ""

		try {
			gdip_ImageSearch(this.getScreenBitmap().get()
				, this.getImageBitmap().get()
				, gdipSearchResult
				, this.x1
				, this.y1
				, this.x2
				, this.y2
				, this.getVariation()
				, this.getTranscolor()
				, 1
				, this.returnsFirstResult()
				, ",", ",", this.getImageBitmap().getIdentifier())
		} catch e {
			this.disposeImageBitmap()
			_Logger.exception(e, A_ThisFunc)
			throw e
		} finally {
			if (this.disposeScreenBitmapAfterSearch) {
				this.disposeScreenBitmap()
			}
		}

		this.gdipResult := gdipSearchResult, this.searchPerformed := true

		this.setResult()
		this.resolveFound()
	}

	/**
	* @return bool
	*/
	isSideBarsArea()
	{
		return (this.getArea().__Class == _SideBarsArea.__Class && !_SideBarsArea.DISABLED)
	}

	/**
	* @return _Coordinates
	*/
	getCoordinates()
	{
		return this.coordinates
	}

	/**
	* @param _Coordinates coordinates
	* @return this
	*/
	setCoordinates(coordinates)
	{
		_Validation.instanceOf("coordinates", coordinates, _Coordinates)
		_Validation.number("coordinates.getX1()", coordinates.getX1())s

		this.coordinates := coordinates

		/*
		unset client area (side bar area has a different flow)
		*/
		this.clientArea := ""

		return this
	}

	/**
	* @return _AbstractClientArea
	*/
	getArea()
	{
		return this.clientArea
	}

	/**
	* @param _AbstractClientArea clientArea
	* @return this
	*/
	setArea(clientArea)
	{
		_Validation.instanceOf("clientArea", clientArea, _AbstractClientArea)

		this.clientArea := clientArea
		this.coordinates := clientArea.getCoordinates()

		return this
	}

	setScreenBitmap(image)
	{
		_Validation.instanceOf("image", _BitmapImage)

		this.screenBitmap := image
		return this
	}

	/**
	* @return _BitmapImage
	*/
	getScreenBitmap()
	{
		if (this.screenBitmap) {
			return this.screenBitmap
		}

		return this.screenBitmap := _BitmapEngine.getClientBitmap(this.getCoordinates(), this.folder "\" this.file)
	}

	/**
	* @return void
	*/
	setResult()
	{
		if (this.returnsFirstResult()) {
			this.singleResultCoordinates()
		} else {
			this.multipleResultCoordinates()
		}

		this.validateResult()

		if (this.debugEither()) {
			this.debugImagePosition()
		}
	}

	/**
	* @return void
	*/
	resetResult()
	{
		this.setImageFound(false)
			, this.result := new _Coordinate()
			, this.results := ""
	}

	/**
	* @return void
	*/
	multipleResultCoordinates()
	{
		this.results := []
		results := StrSplit(this.gdipResult, ",")

		Loop, % results.Count() / 2 {
			this.results.Push(new _Coordinate(this.setResultX(results.1), this.setResultY(results.2)))
				, results.Remove(1)
				, results.Remove(1)
		}
	}

	/**
	* @return void
	*/
	singleResultCoordinates()
	{
		coords := StrSplit(this.gdipResult , ",")

		this.result
			.setX(this.setResultX(coords.1))
			.setY(this.setResultY(coords.2))
	}

	/**
	* @return void
	* @throws
	*/
	validateResult()
	{
		if (this.returnsFirstResult()) {
			if (this.result.getX() && empty(this.result.getY())) {
				this.exception("Only result y is empty, result: " this.gdipResult)
			}

			if (empty(this.result.getX()) && this.result.getY()) {
				this.exception("Only result x is empty, result: " this.gdipResult)
			}

			return
		}

		for key, coordinate in this.results {
			if (coordinate.getX() && empty(coordinate.getY())) {
				this.exception("[Result " key "] Only result y is empty, result: " this.gdipResult)
			}

			if (empty(coordinate.getX()) && coordinate.getY()) {
				this.exception("[Result " key "] Only result x is empty, result: " this.gdipResult)
			}
		}
	}

	/**
	* @return ?int
	*/
	setResultX(x)
	{
		return (empty(x) ? "" : this.getCoordinates().getX1() + x + this.getResultOffsetX())
	}

	/**
	* @return ?int
	*/
	setResultY(y)
	{
		return (empty(y) ? "" : this.getCoordinates().getY1() + y + this.getResultOffsetY())
	}

	/**
	* @return void
	* @throws
	*/
	resolveCoordinates()
	{
		local w, h

		try {
			Gdip_GetDimensions(this.getScreenBitmap().get(), w, h)
		} catch e {
			_Logger.exception(e, A_ThisFunc, "Gdip_GetDimensions(this.getScreenBitmap())")
			throw e
		}

		this.x1 := 0
			, this.y1 := 0
			, this.x2 := w
			, this.y2 := h
	}

	/**
	* @param bool value
	* @return this
	*/
	setAllResults(value)
	{
		this.firstResult := !value
		return this
	}

	/**
	* @return bool
	*/
	returnsFirstResult()
	{
		return this.firstResult
	}

	/**
	* @return int
	*/
	getVariation()
	{
		return (this.variation >= 0) ? this.variation : _AbstractBitmapSearch.DEFAULT_VARIATION
	}

	/**
	* @return this
	*/
	setVariation(variation)
	{
		this.variation := variation
		return this
	}

	/**
	* @return ?string
	*/
	getTransColor()
	{
		return this.transColor
	}

	/**
	* @param string transColor
	* @return this
	*/
	setTransColor(transColor := "0")
	{
		this.transColor := transColor
		return this
	}

	/**
	* @return void
	* @throws
	*/
	validateSearchParameters()
	{
		_Validation.number("this.getVariation()", this.getVariation())
	}

	/**
	* @return void
	*/
	disposeScreenBitmap()
	{
		this.screenBitmap.dispose(), this.screenBitmap := ""
	}

	/**
	* @return void
	*/
	validateBitmaps()
	{
		this.validateImageBitmap()
			, this.validateScreenBitmap()
	}

	/**
	* @return void
	* @throws
	*/
	validateImageBitmap()
	{
		if (this.getImageBitmap().isValid()) {
			return
		}

		if (!A_IsCompiled) {
			_Logger.error("Second time getting ImageBitmap, identiifer: " this.getImageBitmap().getIdentifier(), A_ThisFunc)
		}

		this.disposeImageBitmap()
		Sleep, 50

		if (this.getImageBitmap().isInvalid()) {
			this.exception("Invalid image bitmap, identifier: " this.getImageBitmap().getIdentifier() ", bitmap: " this.getImageBitmap())
		}
	}

	/**
	* @return void
	* @throws
	*/
	validateScreenBitmap()
	{
		if (this.getScreenBitmap().isValid()) {
			return
		}

		if (!A_IsCompiled) {
			_Logger.error("Second time getting ScreenBitmap", A_ThisFunc)
		}

		this.disposeScreenBitmap()
		Sleep, 50

		if (this.getScreenBitmap().isInvalid()) {
			this.exception("Invalid screen bitmap, bitmap: " this.getScreenBitmap())
		}
	}

	/**
	* @return _Coordinate
	*/
	getResult()
	{
		return this.result
	}

	/**
	* @return array<_Coordinate>
	*/
	getResults()
	{
		return this.results
	}

	/**
	* @return int
	*/
	getResultsCount()
	{
		return this.results.Count()
	}

	/**
	* @return ?int
	*/
	getX()
	{
		this.allResultsIncompatibleFunction(A_ThisFunc)

		return this.result.getX()
	}

	/**
	* @return ?int
	*/
	getY()
	{
		this.allResultsIncompatibleFunction(A_ThisFunc)

		return this.result.getY()
	}

	/**
	* @return ?int
	*/
	getAreaX()
	{
		this.allResultsIncompatibleFunction(A_ThisFunc)

		return this.result.x
	}

	/**
	* @return ?int
	*/
	getAreaY()
	{
		this.allResultsIncompatibleFunction(A_ThisFunc)

		return this.result.y
	}

	/**
	* @param ?string button
	* @param ?int repeat
	* @param ?int delay
	* @param ?bool debug
	* @return this
	*/
	click(button := "Left", repeat := 1, delay := "", debug := false)
	{
		this.allResultsIncompatibleFunction(A_ThisFunc)

		if (!this.resultHasCoords()) {
			if (!this.searchPerformed) {
				this.exception("Click before search performed")
			}

			return this
		}

		this.getResult()
			.setClickOffsetX(this.clickOffsetX)
			.setClickOffsetY(this.clickOffsetY)
			.setDefaultClickMethod(this.defaultClickMethod)
			.click(button, repeat, delay, this._debug ? this._debug : debug)

		return this
	}

	/**
	* @param ?bool value
	* @return this
	*/
	setDefaultClickMethod(value := false)
	{
		this.defaultClickMethod := value
		return this
	}

	/**
	* @param ?bool background
	* @param ?bool debug
	* @return this
	*/
	moveMouse(background := false, debug := false)
	{
		this.getResult()
			.setClickOffsetX(this.clickOffsetX)
			.setClickOffsetY(this.clickOffsetY)
			.moveMouse(background, debug)

		return this
	}

	/**
	* @param _Coordinate destination
	* @param ?bool debug
	* @return this
	*/
	drag(destination, debug := false)
	{
		this.getResult().drag(destination, debug)
		return this
	}

	/**
	* @return bool
	*/
	clickOnUse()
	{
		return this.getResult().clickOnUse()
	}

	/**
	* @return this
	*/
	useMenu()
	{
		this.getResult().useMenu()
		return this
	}

	/**
	* @return this
	*/
	use()
	{
		this.getResult().use()
		return this
	}

	/**
	* @return bool
	*/
	useWithoutCtrl()
	{
		return this.getResult().useWithoutCtrl()
	}

	/**
	* @return bool
	*/
	resultHasCoords()
	{
		if (this.returnsFirstResult()) {
			return !isAnyEmpty(this.result.getX(), this.result.getY())
		}

		if (this.getResultsCount() < 1) {
			return false
		}

		firstCoord := this.results[this.results.MinIndex()]

		return !isAnyEmpty(firstCoord.x, firstCoord.y)
	}

	/**
	* @return this
	*/
	getResultOffsetX()
	{
		return this.resultOffsetX ? this.resultOffsetX : 0
	}

	/**
	* @return this
	*/
	getResultOffsetY()
	{
		return this.resultOffsetY ? this.resultOffsetY : 0
	}

	/**
	* @param int offset
	* @return this
	*/
	setResultOffsets(offset){
		this.setResultOffsetX(offset)
		this.setResultOffsetY(offset)
		return this
	}
	/**
	* @param int offset
	* @return this
	*/
	setResultOffsetX(offset)
	{
		_Validation.number(offset)
		this.resultOffsetX := offset

		return this
	}

	/**
	* @param int offset
	* @return this
	*/
	setResultOffsetY(offset)
	{
		_Validation.number(offset)
		this.resultOffsetY := offset

		return this
	}

	/**
	* @param ?int offset
	* @return this
	*/
	setClickOffsetX(offset)
	{
		this.clickOffsetX := offset
		return this
	}

	/**
	* @param ?int offset
	* @return this
	*/
	setClickOffsetY(offset)
	{
		this.clickOffsetY := offset
		return this
	}

	/**
	* @param ?int offset
	* @return this
	*/
	setClickOffsets(offset)
	{
		this.setClickOffsetX(offset)
		this.setClickOffsetY(offset)
		return this
	}

	/**
	* @param string type
	* @param ?int offset
	* @return this
	*/
	setClickOffset(type, offset)
	{
		this.getResult().setClickOffset(type, offset)
		return this
	}

	/**
	* @param bool value
	* @return this
	*/
	setImageFound(value)
	{
		this.imageFound := (value) ? true : value
	}

	/**
	* @return bool
	*/
	found()
	{
		return this.imageFound
	}

	/**
	* @return bool
	*/
	notFound()
	{
		return !this.found()
	}

	/**
	* @return void
	*/
	resolveFound()
	{
		this.setImageFound(this.resultHasCoords())
	}

	/**
	* @param string msg
	* @return void
	* @msgbox
	*/
	debugMsg(msg)
	{
		Gui, Carregando:Destroy
		msgbox, , % this.base.__Class, % msg
	}

	/**
	* @return void
	* @msgbox
	*/
	debugCoordinatePositions()
	{
		return
		if (this._debug && !this._debugResult) {
			WinActivate()
			MouseMove, WindowX + this.getCoordinates().getX1(), WindowY + this.getCoordinates().getY1()
			this.debugMsg("x1 = " this.getCoordinates().getX1() ", y1 = " this.getCoordinates().getY1())
			MouseMove, WindowX + this.getCoordinates().getX2(), WindowY + this.getCoordinates().getY2()
			this.debugMsg("x2 = " this.getCoordinates().getX2() ", y2 = " this.getCoordinates().getY2() "`n`nw: " this.coordinates.getW() ", h:" this.coordinates.getH())
			this.debugMsg("Variation = " this.getVariation() "`n" "TransColor = " this.getTranscolor() "`n" "FirstResult = " this.returnsFirstResult())
		}
	}

	/**
	* @abstract
	* @return void
	* @msgbox
	*/
	debugImagePosition()
	{
		resultOffsetString := "`n`nResult offsets:`nx:" this.getResultOffsetX() ", y: " this.getResultOffsetY()
		gdipResultString := "`n`ngdip result: " this.gdipResult "`n`n" this.getImageBitmap().getIdentifier() "`n`nvariation: " this.variation
		gdipResultString .= "`ntranscolor: " this.getTransColor()

		if (this.returnsFirstResult()) {
			if (this.resultHasCoords()) {
				MouseMove(this.getX(), this.getY(), true, false)
			}
			this.debugMsg("Single result:" "`n`nx: " this.getX() ", y:" this.getY() "" resultOffsetString "" gdipResultString)
			return
		}

		for key, coordinate in this.getResults() {
			if (this.resultHasCoords()) {
				MouseMove(coordinate.getX(), coordinate.getY(), true, false)
			}
			this.debugMsg("Result number " key "/" this.getResultsCount() ":" "`n`nx: " coordinate.getX() ", y:" coordinate.getY() "" resultOffsetString "" gdipResultString)
		}
	}

	/**
	* @param bool value
	* @return this
	*/
	setDebug(value := true)
	{
		this._debug := value
		return this
	}

	/**
	* @return this
	*/
	debug()
	{
		this._debug := true
		return this
	}

	/**
	* @param bool value
	* @return this
	*/
	setDebugResult(value)
	{
		this._debugResult := value
		return this
	}

	/**
	* @return this
	*/
	debugResult()
	{
		this._debugResult := true
		return this
	}

	/**
	* @return bool
	*/
	debugEither()
	{
		return this._debug || this._debugResult
	}

	/**
	* @param string functionName
	* @throws
	*/
	allResultsIncompatibleFunction(functionName)
	{
		if (!this.returnsFirstResult()) {
			this.exception("called " functionName " when returns all results.", -4)
		}
	}

	/**
	* @return void
	*/
	guardAgainstInvalidCoordinates()
	{
		if (!this.getCoordinates()) {
			this.setCoordinates(new _WindowArea().getCoordinates())
		}

		if (this.getCoordinates().getX1() < 0) {
			this.getCoordinates().setX1(0)
		}

		if (this.getCoordinates().getY1() < 0) {
			this.getCoordinates().setY1(0)
		}

		if (this.getCoordinates().getX2() > WindowWidth) {
			this.getCoordinates().setX2(WindowWidth)
		}

		if (this.getCoordinates().getY2() > WindowHeight) {
			this.getCoordinates().setY2(WindowHeight)
		}
	}

	/**
	* @return void
	* @throws
	*/
	validateCoordinates()
	{
		this.guardAgainstInvalidCoordinates()

		_Validation.instanceOf("_Coordinates", this.coordinates, _Coordinates)

		if (this.getCoordinates().getX2() < this.getCoordinates().getX1()) {
			this.exception("X1 coordinate higher than X2: " this.getCoordinates().getX1() ", " this.getCoordinates().getX2())
		}

		if (this.getCoordinates().getY2() < this.getCoordinates().getY1()) {
			this.exception("Y1 coordinate higher than Y2: " this.getCoordinates().getY1() ", " this.getCoordinates().getY2())
		}
	}

	/**
	* @param string msg
	* @return void
	* @throws
	*/
	exception(msg, defaultErrorLevel := -2)
	{
		throw Exception(msg, defaultErrorLevel)
	}
}