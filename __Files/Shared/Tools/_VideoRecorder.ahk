dependencies := {}
dependencies.Push("_Validation")
dependencies.Push("_GUI")
dependencies.Push("_AbstractControl")
dependencies.Push("_Button")
dependencies.Push("_Text")

for _, class in dependencies
{
    if (!%class%) {
        msgbox, 16, % "_VideoRecorder.ahk",  % "Missing include class """ class """"
        ExitApp
    }
}

Class _VideoRecorder extends _GUI
{
    static INSTANCE

    __Call(method, args*) {
        methodParams(this[method], method, args)
    }

    /**
    * @param ?string title
    */
    __New()
    {
        if (_VideoRecorder.INSTANCE) {
            return _VideoRecorder.INSTANCE
        }

        base.__New("recorder", "Recorder")

        this.onCreate(this.create.bind(this))
            .withoutMinimizeButton()
            .alwaysOnTop()

        _VideoRecorder.INSTANCE := this
    }

    /**
    * @abstract
    * @return void
    */
    create()
    {
        _AbstractControl.SET_DEFAULT_GUI(this)

        this.createControls()

        _AbstractControl.RESET_DEFAULT_GUI()
    }

    /**
    * @return void
    */
    createControls()
    {
        this.startButton := new _Button().title("Start")
            .xs().y(5).w(100)
            .event(this.start.bind(this))
            .keepDisabled()
            .add()

        this.stopButton := new _Button().title("Stop")
            .xs().yadd(5).w(100)
            .event(this.stop.bind(this))
            .add()
    }

    start()
    {
        try {
            this.setSystemCursor("IDC_WAIT")
            this.stopButton.disable()
            this.record()
        } catch e {
            this.restoreCursor()
            this.startButton.enable()
            this.stopButton.enable()
            Msgbox, 48,, % e.Message
        }
    }

    record()
    {

        _Validation.clientOpened()


        ffmpegDir := A_WorkingDir "\Data\Files\Third Part Programs\ffmpeg"
        ffmpegDir := _Folders.THIRD_PARTY_PROGRAMS "\ffmpeg"
        _Validation.fileExists("ffmpegDir", ffmpegDir ".exe")


        width := WindowWidth + 1000
        height := WindowHeight

        recordX := WindowX + 10
        recordY := WindowY + 10
        width -= 10
        height -= 20

        x := width + recordX
        if (x > A_ScreenWidth) {
            width := abs(recordX - A_ScreenWidth) - 10
        }

        y := height + recordY
        if (y > A_ScreenHeight) {
            height := abs(recordY - A_ScreenHeight) - 10
        }

        videoFileName := StrReplace(TibiaClientTitle, "*", "") "_" A_Now
        videoFileName := StrReplace(videoFileName, " ", "_")
        this.fileName := videoFileName ".mp4"

        try {
            Run, %ffmpegDir% -y -f gdigrab -framerate 30 -video_size %width%x%height% -offset_x %recordX% -offset_y %recordY% -show_region 1 -draw_mouse 1 -i desktop -c:v libx264 -r 30 -preset ultrafast -tune zerolatency -crf 25 -pix_fmt yuv420p %videoFileName%.mp4
            Sleep, 1000
        } catch e {
            throw Exception("Failed to run recorder.`n`n" e.Message "`n" e.What)
        }

        if (!this.winExist()) {
            throw Exception(txt("Falha ao iniciar o gravador, a janela do ""ffmpeg"" não foi encontrada.`n`nConfirme se o ""ffmpeg"" foi baixado no seu PC, abra-o no menu superior ""Arquivo"" -> ""Abrir programas"" -> ""Abrir ShareX(gravar tela)"" e tente novamente.", "Failed to start the recorder, the ""ffmpeg"" window was not found.`n`nConfirm that ""ffmpeg"" was downloaded in your PC, open it in the top menu ""File"" -> ""Open programs"" -> ""Open ShareX(record screen)"" and try again."))
        }

        this.restoreCursor()
        this.startButton.disable()
        this.stopButton.enable()
    }

    stop()
    {
        this.setSystemCursor("IDC_WAIT")
        window := "ffmpeg.exe"
        if (!this.winExist()) {
            this.stopButton.enable()
            this.restoreCursor()
            return
        }

        WinActivate, % window
        Sleep, 100
        Send, {q}
        Sleep, 250

        this.restoreCursor()
        if (this.winExist()) {
            this.stopButton.enable()
            msgbox, 48,, % txt("Falha ao parar o gravador, a janela do ffmpeg ainda está aberta.`nTente novamente ou pare manualmente a gravação ativando a janela do ffmpeg e pressionando ""q"".", "Failed to stop the recorder, the ffmpeg window is still open.`nTry again or stop the recording manually by activating the ffmpeg window and pressing ""q"".")
            return
        }

        this.startButton.enable()
        this.traytip("Video file:", this.fileName, 4)
    }

    winExist()
    {
        window := "ffmpeg.exe"

        return WinExist(window)
    }

    traytip(title, message, timeout := 4, warningIcon := false)
    {
        Menu Tray, Icon

        iconType := warningIcon = true ? 2 : 1
        TrayTip, % title, % message, % timeout, % iconType

        fn := this.hideTraytip.bind(this)
        SetTimer, % fn, Delete
        SetTimer, % fn, % "-" timeout * 1000
    }

    hideTraytip()
    {
        TrayTip ; Attempt to hide it the normal way.
        if SubStr(A_OSVersion,1,3) = "10." {
            Menu Tray, NoIcon
            Sleep 200 ; It may be necessary to adjust this sleep.
            Menu Tray, Icon
        }
    }

    /**
    * @return void
    */
    restoreCursor()
    {
        SPI_SETCURSORS := 0x57
        DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
    }

    /**
    * @param ?string Cursor
    * @param int cx
    * @param int cy
    * @return void
    */
    setSystemCursor( Cursor = "", cx = 0, cy = 0 )
    {
        /**
        IDC_ARROW := 32512
        IDC_IBEAM := 32513
        IDC_WAIT := 32514
        IDC_CROSS := 32515
        IDC_UPARROW := 32516
        IDC_SIZE := 32640
        IDC_ICON := 32641
        IDC_SIZENWSE := 32642
        IDC_SIZENESW := 32643
        IDC_SIZEWE := 32644
        IDC_SIZENS := 32645
        IDC_SIZEALL := 32646
        IDC_NO := 32648
        IDC_HAND := 32649
        IDC_APPSTARTING := 32650
        IDC_HELP := 32651
        */
        BlankCursor := 0, SystemCursor := 0, FileCursor := 0 ; init

        SystemCursors = 32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS
            ,32516IDC_UPARROW,32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE
            ,32643IDC_SIZENESW,32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL
            ,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP

        If Cursor = ; empty, so create blank cursor
        {
            VarSetCapacity( AndMask, 32*4, 0xFF ), VarSetCapacity( XorMask, 32*4, 0 )
            BlankCursor = 1 ; flag for later
        }
        Else If SubStr( Cursor,1,4 ) = "IDC_" ; load system cursor
        {
            Loop, Parse, SystemCursors, `,
            {
                CursorName := SubStr( A_Loopfield, 6, 15 ) ; get the cursor name, no trailing space with substr
                CursorID := SubStr( A_Loopfield, 1, 5 ) ; get the cursor id
                SystemCursor = 1
                If ( CursorName = Cursor )
                {
                    CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )
                    Break
                }
            }
            If CursorHandle = ; invalid cursor name given
            {
                Msgbox,, SetCursor, Error: Invalid cursor name
                CursorHandle = Error
            }
        }
        Else If FileExist( Cursor )
        {
            SplitPath, Cursor,,, Ext ; auto-detect type
            If Ext = ico
                uType := 0x1
            Else If Ext in cur,ani
                uType := 0x2
            Else ; invalid file ext
            {
                Msgbox,, SetCursor, Error: Invalid file type
                CursorHandle = Error
            }
            FileCursor = 1
        }
        Else
        {
            Msgbox,, SetCursor, Error: Invalid file path or cursor name
            CursorHandle = Error ; raise for later
        }
        If CursorHandle != Error
        {
            Loop, Parse, SystemCursors, `,
            {
                If BlankCursor = 1
                {
                    Type = BlankCursor
                    %Type%%A_Index% := DllCall( "CreateCursor"
                        , Uint,0, Int,0, Int,0, Int,32, Int,32, Uint,&AndMask, Uint,&XorMask )
                    CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
                    DllCall( "setSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
                }
                Else If SystemCursor = 1
                {
                    Type = SystemCursor
                    CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )
                    %Type%%A_Index% := DllCall( "CopyImage"
                        , Uint,CursorHandle, Uint,0x2, Int,cx, Int,cy, Uint,0 )
                    CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
                    DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
                }
                Else If FileCursor = 1
                {
                    Type = FileCursor
                    %Type%%A_Index% := DllCall( "LoadImageA"
                        , UInt,0, Str,Cursor, UInt,uType, Int,cx, Int,cy, UInt,0x10 )
                    DllCall( "SetSystemCursor", Uint,%Type%%A_Index%, Int,SubStr( A_Loopfield, 1, 5 ) )
                }
            }
        }
    }
}
