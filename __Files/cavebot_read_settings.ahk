
IniRead, CavebotLogsMinimized, %DefaultProfile%, cavebot_settings, CavebotLogsMinimized, 0
IniRead, CavebotLogs_lines, %DefaultProfile%, cavebot_settings, CavebotLogs_lines, 3
IniRead, CavebotLogsWidth, %DefaultProfile%, cavebot_settings, CavebotLogsWidth, 500
If (CavebotLogs_lines < 3)
    CavebotLogs_lines := 3
CavebotLogs_lines_old := CavebotLogs_lines
CavebotLogsWidth_old := CavebotLogsWidth

IniRead, TransparentCavebotLogs, %DefaultProfile%, cavebot_settings, TransparentCavebotLogs, 0
global TransparentCavebotLogs

IniRead, CavebotLogsWindowX, %DefaultProfile%, cavebot_settings, CavebotLogsWindowX, %A_Space%
IniRead, CavebotLogsWindowY, %DefaultProfile%, cavebot_settings, CavebotLogsWindowY, %A_Space%
global CavebotLogsWindowX, CavebotLogsWindowY, PainelCavebotHWND


