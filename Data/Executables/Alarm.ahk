#SingleInstance, Force
#NoTrayIcon
#NoEnv

Loop, {
	SoundPlay, Data\Files\Sounds\danger.wav, WAIT
	Sleep, 800
}
return

+!Esc::
Exitapp