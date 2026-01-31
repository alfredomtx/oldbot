
class _ScriptImagesGUI
{

    createScriptImagesGUI() {
        global
        _AbstractControl.SET_DEFAULT_GUI_NAME("ScriptImagesGUI")

        Gui, ScriptImagesGUI:Destroy
        Gui, ScriptImagesGUI:-MinimizeBox

        Gui, ScriptImagesGUI:Add, ListView, x7 y5 h492 w300 AltSubmit vLV_ScriptImages gLV_ScriptImages hwndhLV_ScriptImages LV0x1 LV0x10 -Multi, Image|Name|Category|Size


        w_group := 200
        w_controls := w_group - 20

            new _Button().title("Adicionar nova imagem", "Add new image")
            .xadd(8).y(5).w(w_group)
            .section()
            .tt("Adicionar uma imagem de um arquivo .png", "Add an image from a .png file")
            .event("addScriptImage")
            .icon(_Icon.get(_Icon.PLUS), "a0 l3 s16 b0")
            .add()

            new _Button().title("Adicionar do clipboard (Ctrl+V)", "Add from clipboard (Ctrl+V)")
            .xs().y().w(w_group)
            .tt("Adicionar uma imagem do clipboard", "Add an image from the clipboard", " (Ctrl+C)")
            .event("addScriptImageFromClipboard")
            .icon(_Icon.get(_Icon.PLUS), "a0 l3 s16 b0")
            .add()


        Gui, ScriptImagesGUI:Add, Groupbox, xs+0 y+7 w%w_group% h340 Section, % LANGUAGE = "PT-BR" ? "Editar imagem" : "Edit image"

            new _Button().title("Salvar nome", "Save name")
            .name("saveScriptImage")
            .xs(10).yp(20).w(w_controls)
            .event("saveScriptImage")
            .icon(_Icon.get(_Icon.CHECK), "a0 l3 s16 b0")
            .disabled()
            .add()

        Gui, ScriptImagesGUI:Add, Text, xs+10 y+5, % LANGUAGE = "PT-BR" ? "Nome da imagem:" : "Image name:"
        Gui, ScriptImagesGUI:Add, Edit, xs+10 y+3 vscriptImageName w%w_controls% h18 Disabled, 

        Gui, ScriptImagesGUI:Add, Text, xs+10 y+7, % LANGUAGE = "PT-BR" ? "Categoria:" : "Category:"
        Gui, ScriptImagesGUI:Add, DDL, xs+10 y+3 vscriptImageCategory geditScriptImageCategory hwndhscriptImageCategory w%w_controls% Disabled, % A_Space "|Corpse|Follow|Item on Trade"
        TT.Add(hscriptImageCategory, txt("- A categoria ""Corpse"" é usada para a função de ""Usar item no corpo"" do Targeting.`n- A categoria ""Follow"" é usada para a action follow().`n- A categoria ""Item on Trade"" é usada para a action buyitemnpc() e sellitemnpc(), para usar essa Script Image ao procurar pelo item no Trade.", "- The category ""Corpse"" is used for the ""Use item on corpse"" Targeting feature.`n- The category ""Follow"" is used for the follow() action.`n- The category ""Item on Trade"" is used for the buyitemnpc() and sellitemnpc() actions, to use this Script Image to search for the item on Trade.") )


        Gui, ScriptImagesGUI:Add, Text, xs+10 y+7, % LANGUAGE = "PT-BR" ? "Imagem:" : "Image:"
        Gui, ScriptImagesGUI:Add, Picture, xs+10 y+3 vscriptImagePicture,


            new _Button().title("Alterar imagem", "Change image")
            .name("changeScriptImageItem")
            .xs(10).y(275).w(w_controls)
            .tt("Alterar a imagem de um arquivo .png", "Change the image from a .png file")
            .event("changeScriptImageItem")
            .icon(_Icon.get(_Icon.IMAGE), "a0 l3 s16 b0")
            .disabled()
            .add()

            new _Button().title("Alterar do clipboard (Ctrl+V)", "Change from clipboard (Ctrl+V)")
            .name("changeScriptImageFromClipboard")
            .xs(10).y().w(w_controls)
            .tt("Segure ""Ctrl"" para pular o diálogo de confirmação", "Hold ""Ctrl"" to skip the confirmation dialog")
            .event("changeScriptImageFromClipboard")
            .icon(_Icon.get(_Icon.IMAGE), "a0 l3 s16 b0")
            .disabled()
            .add()

        ; Gui, ScriptImagesGUI:Add, Button, xs+10 y+5 w%w_controls% vchangeScriptImageFromClipboard gchangeScriptImageFromClipboard hwndhchangeScriptImageFromClipboard Disabled, % LANGUAGE = "PT-BR" ? 
        ; TT.Add(hchangeScriptImageFromClipboard, LANGUAGE = "PT-BR" ? 

        Gui, ScriptImagesGUI:Add, Groupbox, xp+0 y+2  w%w_controls% h8 cBlack

        Gui, ScriptImagesGUI:Add, Button, xs+10 y+6 w%w_controls% vclipboardScriptImage gclipboardScriptImage Disabled, % LANGUAGE = "PT-BR" ? "Copiar para o clipboard (Ctrl+C)" : "Copy to clipboard (Ctrl+C)"

            new _Button().title(lang("delete") "    ")
            .xs(10).y().w(w_controls)
            .tt("Segure ""Ctrl"" para pular o diálogo de confirmação", "Hold ""Ctrl"" to skip the confirmation dialog")
            .event("deleteScriptImageItem")
            .icon(_Icon.get(_Icon.DELETE), "a0 l3 s14 b0")
            .add()

        Gui, ScriptImagesGUI:Add, Groupbox, xs+0 y+15 w%w_group% h90 Section, % LANGUAGE = "PT-BR" ? "Testar imagem" : "Test image"

        w := (w_controls / 2) - 10
        Gui, ScriptImagesGUI:Add, Text, xs+10 yp+18, % LANGUAGE = "PT-BR" ? "Área de busca(search area):" : "Search area:"
        Gui, ScriptImagesGUI:Add, DDL, xs+10 y+3 vscriptImageSearchArea gscriptImageSearchArea hwndhscriptImageSearchArea w%w_controls%, % _ClientAreaFactory.getDropdown()


            new _Button().title("Testar imagem", "Test image")
            .name("testScriptImage")
            .xs(10).yadd(4).w(w_controls)
            .tt("Search for the image on the screen`n`nHold ""Ctrl"" to Left Click on the image.`nHold ""Shift"" to Right Click the image.")
            .event("testScriptImage")
            .icon(_Icon.get(_Icon.CAMERA), "a0 l3 s16 b0")
            .disabled()
            .add()

        Gui, ScriptImagesGUI:Show,, Script Images

        _AbstractControl.RESET_DEFAULT_GUI()

        this.LoadScriptImagesLV()
    }


    LV_ScriptImages() {
        classLoaded("ScriptImages", ScriptImages)

        Gui, ScriptImagesGUI:Default
        Gui, ListView, LV_ScriptImages

        selectedLine := LV_GetNext()
        LV_GetText(selectedItem,selectedLine,2)
        if (selectedItem = "" OR selectedItem = "Name")
            return
        try GuiControl, ScriptImagesGUI:, scriptImageName, % selectedItem
        catch {
        }
        try GuiControl, ScriptImagesGUI:Enable, scriptImageName
        catch {
        }
        try GuiControl, ScriptImagesGUI:Enable, scriptImageCategory
        catch {
        }
        try GuiControl, ScriptImagesGUI:Enable, scriptImageSearchArea
        catch {
        }
        try GuiControl, ScriptImagesGUI:Enable, saveScriptImage
        catch {
        }
        try GuiControl, ScriptImagesGUI:Enable, changeScriptImageItem
        catch {
        }
        try GuiControl, ScriptImagesGUI:Enable, changeScriptImageFromClipboard
        catch {
        }
        try GuiControl, ScriptImagesGUI:Enable, testScriptImage
        catch {
        }
        try GuiControl, ScriptImagesGUI:Enable, clipboardScriptImage
        catch {
        }
        try GuiControl, ScriptImagesGUI:Enable, deleteScriptImageItem
        catch {
        }
        try GuiControl, ScriptImagesGUI:ChooseString, scriptImageCategory, % A_Space
        catch {
        }
        try GuiControl, ScriptImagesGUI:ChooseString, scriptImageCategory, % scriptImagesObj[selectedItem].category
        catch {
        }

        if (empty(scriptImagesObj[selectedItem].image)) {
            return
        }

        pBitmap := GdipCreateFromBase64(scriptImagesObj[selectedItem].image)
            , hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
            , h := Gdip_GetImageHeight( pBitmap ) 
        ; , w := Gdip_GetImageWidth( pBitmap )


        try GuiControl, ScriptImagesGUI:, scriptImagePicture, % ""
        catch {
        }
        if (h <= 100) {
            try GuiControl, ScriptImagesGUI:, scriptImagePicture, HBITMAP:%hBitmap% *w0 *h0
            catch {
            }
        }
        Gdip_DisposeImage(pBitmap), pBitmap := "", DeleteObject(hBitmap), hBitmap := ""
    }


    LoadScriptImagesLV() {
        try {
            _ListviewHandler.loadingLV("LV_ScriptImages", "ScriptImagesGUI")
        } catch {
            return
        }

        Gui, ListView, LV_ScriptImages
        IL_Destroy(ImageListID_LV_ScriptImages)  ; Required for image lists used by tab_name controls.

        IconWidth    :=  32
            , IconHeight   := 32
            , IconBitDepth := 24 ;
            , InitialCount :=  1 ; The starting Number of Icons available in ImageList
            , GrowCount    :=  1

        Gui, ListView, LV_ScriptImages
        ImageListID_LV_ScriptImages  := DllCall( "ImageList_Create", Int,IconWidth,    Int,IconHeight
            , Int,IconBitDepth, Int,InitialCount
            , Int,GrowCount )
        Gui, ListView, LV_ScriptImages
        LV_SetImageList( ImageListID_LV_ScriptImages, 1 ) ; 0 for large icons, 1 for small icons
        ; LV_SetImageList( DllCall( "ImageList_Create", Int,2, Int,rh, Int,0x18, Int,1, Int,1 ), 1 )
        ; msgbox, % serialize(itemsImageObj)
        for imageName, atributes in scriptImagesObj
        {
            if (empty(atributes.image)) {
                continue
            }
            ; if (imageName = "WhereToStart")
            ; continue
            scriptImage := new _ScriptImage(imageName, atributes.image)

            IL_Add(ImageListID_LV_ScriptImages, "HBITMAP:" scriptImage.getBitmap().getHBitmap(), 0xFFFFFF, 1)  ; 0xFFFFFF to use with imanges insted of icons
            ; IL_Add(ImageListID_LV_ScriptImages, "Data\images\" imageName ".png", 0xFFFFFF, 1)  ; 0xFFFFFF to use with imanges insted of icons
            ; OutputDebug(scriptImage.getBitmap().getHBitmap() "`n")

            Gui, ListView, LV_ScriptImages
            LV_Add("Icon" A_Index,"", imageName, atributes.category, scriptImage.getBitmap().getW() " x " scriptImage.getBitmap().getH() "px")

            /*
            dispose to not cache images
            */
            scriptImage.dispose()
        }

        Gui, ListView, LV_ScriptImages
        Loop, 4
            LV_ModifyCol(A_Index, "autohdr")


    }

}