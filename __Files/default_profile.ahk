global DefaultProfile
; StringTrimRight, DIR, A_WorkingDir, 13
IniRead, DefaultProfile, oldbot_profile.ini, profile, DefaultProfile, settings.ini
IfNotInString, DefaultProfile, settings.ini
{
    FoundPos := InStr(DefaultProfile, "\settings")
    StringReplace, DefaultProfile_SemIni, DefaultProfile, .ini,, All
    ; msgbox, %FoundPos%
    StringTrimLeft, DefaultProfile, DefaultProfile, FoundPos + 9
    StringTrimLeft, DefaultProfile_SemIni, DefaultProfile_SemIni, FoundPos + 9
    DefaultProfile = settings_%DefaultProfile%

} else {
    DefaultProfile = settings.ini
    DefaultProfile_SemIni = default
}
