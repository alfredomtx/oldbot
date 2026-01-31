

global debug_imagesearch
global pBitmapScreenImageSearchItem

/*
CAVEBOT-ONLY VARIABLES
*/
global selectedTabs
global selectedTabs := {}


; action_scripts.Push("zoom_minimapa")




/**
variaveis bloqueadas para não serem lidas
*/
global blacklist_variables_read := {}
blacklist_variables_read.Push("Password")
blacklist_variables_read.Push("AccountNameReconnect")
blacklist_variables_read.Push("AccountNameReconnect2")
blacklist_variables_read.Push("PasswordReconnect")
blacklist_variables_read.Push("PasswordReconnect2")
blacklist_variables_read.Push("PC_ID")
blacklist_variables_read.Push("PC_ID_USER")
blacklist_variables_read.Push("pc_id")
blacklist_variables_read.Push("pc_id_detected")

/**
variaveis bloqueadas para não serem usadas/criadas
*/
global blacklist_variables_use := {}
blacklist_variables_read.Push("supply")
blacklist_variables_read.Push("pot")
blacklist_variables_read.Push("potion")
blacklist_variables_read.Push("cap")
blacklist_variables_read.Push("Type")
blacklist_variables_read.Push("tries")
blacklist_variables_read.Push("number")
blacklist_variables_read.Push("condition")
blacklist_variables_read.Push("isnumber")
blacklist_variables_read.Push("ischeckbox")
blacklist_variables_read.Push("ishotkey")
blacklist_variables_read.Push("hotkey")
blacklist_variables_read.Push("string")
blacklist_variables_read.Push("index")


imbuementItemListDropdown := "bear paw|bloody pincers|brimstone fangs|brimstone shell|broken shamanic staff|brown mushroom|chicken feather|crawler head plating|cultish robe|cyclops toe|deepling warts|demonic skeletal hand|demon horn|draken sulphur|elven hoof|elven scouting glass|elvish talisman|fairy wings|fiery heart|flask of embalming fluid|frazzle skin|frosty heart|gloom wolf fur|goosebump leather|green dragon leather|green dragon scale|hellspawn tail|honeycomb|lions mane|marsh stalker feather|medicine pouch|metal spike|orc tooth|peackock feather fan|piece of dead brain|poisonous slime|polar bear paw|protective charm|quill|rope belt|rorc feather|sabretooth|scarab shell|slime heart|snake skin|some grimeleech wings|swampling wood|thick fur|vampire tooth|vexclaw talon|warmasters wristguards|war crystal|winter wolf fur|wyvern fang"
imbuementItemListDropdown := "----- Imbuement/addon items -----|" imbuementItemListDropdown


global potionListDropdown
global potionList
potionList := {}
potionList.Push("mana potion")
potionList.Push("strong mana potion")
potionList.Push("great mana potion")
potionList.Push("ultimate mana potion")
potionList.Push("small health potion")
potionList.Push("health potion")
potionList.Push("strong health potion")
potionList.Push("great health potion")
potionList.Push("ultimate health potion")
potionList.Push("supreme health potion")
potionList.Push("great spirit potion")
potionList.Push("ultimate spirit potion")
potionListDropdown := ""
for key, value in potionList
    potionListDropdown .= value (A_Index = potionList.MaxIndex() ? "" : "|") ; needed to not add | on the last item and it not be chosen on listview by default



supplyListDropdown = ----- Runes -----|avalanche rune|blank rune|destroy field rune|disintegrate rune|energy bomb rune|energy field rune|energy wall rune|explosion rune|fire bomb rune|fire wall rune|fireball rune|great fireball rune|heavy magic missile rune|holy missile rune|icicle rune|intense healing rune|magic wall rune|paralyze rune|poison bomb rune|poison field rune|poison wall rune|stalagmite rune|stone shower rune|sudden death rune|thunderstorm rune|ultimate healing rune|wild growth rune|----- Distance -----|assassin star|glooth spear|royal spear|royal star|small stone|spear|throwing star|----- Arrows -----|arrow|burst arrow|crystalline arrow|diamond arrow|earth arrow|envenomed arrow|flaming arrow|onyx arrow|poison arrow|shiver arrow|sniper arrow|tarsal arrow|----- Bolts -----|bolt|drill bolt|infernal bolt|piercing bolt|power bolt|prismatic bolt|spectral bolt|vortex bolt

global potionAndSupplyListdropdown
potionAndSupplyListdropdown = ----- Potions -----|%potionListDropdown%|----- Runes -----|avalanche rune|blank rune|destroy field rune|disintegrate rune|energy bomb rune|energy field rune|energy wall rune|explosion rune|fire bomb rune|fire wall rune|fireball rune|great fireball rune|heavy magic missile rune|holy missile rune|icicle rune|intense healing rune|magic wall rune|paralyze rune|poison bomb rune|poison field rune|poison wall rune|stalagmite rune|stone shower rune|sudden death rune|thunderstorm rune|ultimate healing rune|wild growth rune|----- Distance -----|assassin star|glooth spear|royal spear|royal star|small stone|spear|throwing star|----- Arrows -----|arrow|burst arrow|crystalline arrow|diamond arrow|earth arrow|envenomed arrow|flaming arrow|onyx arrow|poison arrow|shiver arrow|sniper arrow|tarsal arrow|----- Bolts -----|bolt|drill bolt|infernal bolt|piercing bolt|power bolt|prismatic bolt|spectral bolt|vortex bolt|%imbuementItemListDropdown%



global currentScript := "" 

global ScriptTabsList
ScriptTabsList := {}

global tab ; variável reservada - salva a tab atual que está selecionada no cavebot
global tab_prefix ; variável reservada - o prefixo da tab "Waypoints_"
tab := "Waypoints"
tab_prefix := "Waypoints_"




/*
OTHER VARIABLES
*/

global configs
configs := {}
configs.Push("antialiasingMode")
configs.Push("actionButtonShowAmount")
configs.Push("actionButtonShowHotkey")
configs.Push("actionButtonShowGraphicalCooldown")
configs.Push("actionButtonShowCooldownNumbers")
configs.Push("actionButtonAllowTooltip")
; configs.Push("cooldownBarEnabled")
configs.Push("consoleShowEventMessages")
configs.Push("consoleShowInfoMessages")
configs.Push("consoleShowTimestamps")
configs.Push("gameWindowScaleOnlyByEvenMultiples")
configs.Push("gameWindowShowLootMessages")
configs.Push("gameWindowShowOwnSpells")
configs.Push("gameWindowShowPotionMessages")
configs.Push("gameWindowShowHotkeyUsageMessages")
configs.Push("rendererIndex")
configs.Push("statusPanelEnabled")

for key, value in configs
{
    if (value = "")
        continue
    IniRead, %value%, %DefaultProfile%, client_settings, %value%, 1
    CriarVariavel(value, %value%)
}


global list := "rltibia"
global Year
global Month
global Day
global Hour
global Minute
global Second
global Ico
Ico :="Data\Files\Images\icon.ico"

ICON_DIR := "Data\Files\Images\GUI\Icons\"


FormatTime Year,, yyyy
FormatTime Month,, MM
FormatTime Day,, dd
; FormatTime Hour,, HH
; FormatTime Minute,, mm
; FormatTime Second,, ss
Hour := A_Hour
Minute := A_Min
Second := A_Sec
global now := Year "-" Month "-" Day " " Hour ":" Minute ":" Second


/**
Account/login related variables
*/
global EmailLogin
global Password
global user_email
global owner_email

