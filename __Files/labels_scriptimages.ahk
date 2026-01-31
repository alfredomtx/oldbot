
addScriptImageFromClipboard:
    try {
        _ScriptImages.addImageFromClipboard()
    } catch e {
        Msgbox, 48,, % e.Message, 2
    }
return

addScriptImage:
    FileSelectFile, image, 3,, Select a ".png" picture file(32 x 32px max size), (*.png)
    if (image = "") {
        return
    }

    if (!InStr(image, ".png")) {
        Msgbox, 48,, % "Select a .png file.", 2
    return
}


string := InStr(image, "\", 0, -1)
newImage := SubStr(image, string - StrLen(image) + 1) 
imageName := StrReplace(newImage, ".png", "")

try
    _ScriptImages.addImageFromPath(image, imageName)
catch e {
    Msgbox, 48,, % e.Message, 2
    goto, addScriptImage
}
goto, ScriptImagesGUI
return

ScriptImagesGUI:
    ScriptImagesGUI.createScriptImagesGUI()
return

ScriptImagesGUIGuiEscape:
ScriptImagesGUIGuiClose:
    Gui, ScriptImagesGUI:Destroy
return


LV_ScriptImages:
    if (A_GuiEvent != "Normal")
        return
    ScriptImagesGUI.LV_ScriptImages()
return

editScriptImageCategory:
    selectedImage :=  _ListviewHandler.getSelectedItemOnLV("LV_ScriptImages", 2, "ScriptImagesGUI")
    if (selectedImage = "" OR selectedImage = "Name")
        return
    GuiControlGet, scriptImageCategory
    _ScriptImages.editImageCategory(selectedImage, scriptImageCategory)
    ; ScriptImagesGUI.LoadScriptImagesLV()
return

saveScriptImage:
    selectedImage :=  _ListviewHandler.getSelectedItemOnLV("LV_ScriptImages", 2, "ScriptImagesGUI")
    if (selectedImage = "" OR selectedImage = "Name") {
        Msgbox, 64,, % "Select an image in the list.", 1
    return
}
GuiControlGet, scriptImageName
if (scriptImageName = "")
    return
if (selectedImage = scriptImageName)
    return
_ScriptImages.editImageName(selectedImage, scriptImageName)
return

deleteScriptImageItem:
    selectedImage :=  _ListviewHandler.getSelectedItemOnLV("LV_ScriptImages", 2, "ScriptImagesGUI")
    if (selectedImage = "" OR selectedImage = "Name") {
        Msgbox, 64,, % "Select an image in the list.", 1
    return
}
GetKeyState, CtrlPressed, Ctrl, D
if (CtrlPressed != "D") {
    Msgbox, 52,, "%selectedImage%" image will be deleted.`n`nAre you sure?
    IfMsgBox, No
        return
}
_ScriptImages.deleteImage(selectedImage)
try {
    GuiControl, ScriptImagesGUI:, scriptImagePicture, % ""
    GuiControl, ScriptImagesGUI:, scriptImageName, % ""
    GuiControl, ScriptImagesGUI:Disable, scriptImageName
} catch {
}
ScriptImagesGUI.LoadScriptImagesLV()
return

clipboardScriptImage:
    selectedImage :=  _ListviewHandler.getSelectedItemOnLV("LV_ScriptImages", 2, "ScriptImagesGUI")
    if (selectedImage = "" OR selectedImage = "Name") {
        Msgbox, 64,, % "Select an image in the list.", 1
    return
}

try {
    image := new _ScriptImage(selectedImage).toClipboard()
} catch e {
    Msgbox, 48, % selectedImage, % e.Message, 10
}

return



changeScriptImageFromClipboard:
    try
        _ScriptImages.changeImageFromClipboard()
    catch e {
        Msgbox, 48,, % e.Message, 2
    }
return

changeScriptImageItem:
    selectedImage :=  _ListviewHandler.getSelectedItemOnLV("LV_ScriptImages", 2, "ScriptImagesGUI")
    if (selectedImage = "" OR selectedImage = "Name") {
        Msgbox, 64,, % "Select an image in the list.", 1
    return
}

FileSelectFile, image, 3,, Select a ".png" picture file(32 x 32px max size), (*.png)
if (image = "") {
    return
}
if (!InStr(image, ".png")) {
    Msgbox, 48,, % "Select a .png file."
    return
}

try {
    _ScriptImages.addImageFromPath(image, selectedImage)
} catch e {
    Msgbox, 48,, % e.Message
    goto, changeScriptImageItem
}
pBitmap := GdipCreateFromBase64(scriptImagesObj[selectedImage].image)
    , hBitmap:=Gdip_CreateHBITMAPFromBitmap(pBitmap)

GuiControl, ScriptImagesGUI:, scriptImagePicture, % ""
GuiControl, ScriptImagesGUI:, scriptImagePicture, HBITMAP:%hBitmap% *w0 *h0
Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
ScriptImagesGUI.LoadScriptImagesLV()
return

testScriptImage:
    try
        _ScriptImages.testScriptImage()
    catch e {
        Msgbox, 48,, % e.Message, 10
    } 
return


scriptImageSearchArea:
return