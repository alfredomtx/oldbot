
#Include C:\Users\Alfredo\Documents\GitHub\OldBot-Pro\__Files\Shared\OldBot\ImageSearch\_AbstractImageSearch.ahk

class _ImageSearch extends _AbstractImageSearch
{
	; __Call(method, args*) {
	; 	methodParams(this[method], method, args)
	; }

	__New()
	{
		base.__New(this)
	}

	loopSearch()
	{
		originalFile := this.file
		SplitPath, % this.file, , , , fileName

		try {
			Loop, % this.folder "/" fileName "*.png" {
				this.setFile(A_LoopFileName)

				this.search()

				if (this.found()) {
					break
				}
			}
		} finally {
			this.file := originalFile
		}

		return this
	}
}