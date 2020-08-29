#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <fun>
#include <nvault>
#include <dhudmessage>

#define PLUGIN "Zombie Awaken"
#define VERSION "1.1"
#define AUTHOR "DefinitelyNotJah"

#define fm_set_weapon_ammo(%1,%2) set_pdata_int(%1, OFFSET_CLIPAMMO, %2, EXTRAOFFSET_WEAPONS)
#define OFFSET_CLIPAMMO	51
#define EXTRAOFFSET_WEAPONS 4

new const sound_armorhit[] = "player/bhit_helmet-1.wav"

/*================
======REGISTERS===
================*/

new g_iMaxClients, g_MsgTeamInfo, g_msgDeathMsg, g_msgScreenShake, g_msgScreenFade, gmsgWeaponList, g_msgScoreInfo,
g_msgScoreAttrib, g_msgAmmoPickup, g_save, g_save2, g_save3, g_save4, g_save5, g_roundstart, g_freeround, count_new, g_endround,
Float:g_flLastNvgToggle[33], bool:g_bNvgOn[33], g_szLightStyle[2], 
g_pCvarNVisionDensity,g_pCvarZombieNVisionColors[3], g_pCvarLightingStyle, g_fwRoundStart, g_fwDummyResult,
g_damagedealt[33], g_msgBarTime, g_MsgMoney, g_msgMoneyBlink

new bool:g_buffed[33], bool:g_randomclass[33]

new in_burn[33], skin[33], g_isconnected[33], g_attack_type[33]
const USE_USING = 2

native cs_set_player_model(id, const model[])

enum
{
	Red = 0,
	Green,
	Blue
}
enum
{
	ATTACK_SLASH = 1,
	ATTACK_STAB
}
enum
{
	MAX_CLIP = 0,
	MAX_AMMO
}
			
new const g_weapon_ammo[][] =
{
	{ -1, -1 },
	{ 13, 200 },
	{ -1, -1 },
	{ 10, 200 },
	{ -1, -1 },
	{ 7, 200 },
	{ -1, -1 },
	{ 30, 200 },
	{ 30, 200 },
	{ -1, -1 },
	{ 30, 200 },
	{ 20, 200 },
	{ 25, 000 },
	{ 30, 200 },
	{ 35, 200 },
	{ 25, 200 },
	{ 12, 200 },
	{ 20, 200 },
	{ 10, 200 },
	{ 30, 200 },
	{ 100, 200 },
	{ 8, 200 },
	{ 30, 200 },
	{ 30, 200 },
	{ 20, 200 },
	{ -1, -1 },
	{ 7, 200 },
	{ 30, 200 },
	{ 30, 200 },
	{ -1, -1 },
	{ 50, 200 }
}

new mdl_light, mdl_psy, mdl_china, mdl_shaman, mdl_deimos, mdl_males, mdl_females, mdl_yaksha

#define MAX_CLIENTS 32
#define PLAYER_LINUX_XTRA_OFF 5
#define is_user_valid_connected(%1) (1 <= %1 <= g_iMaxClients && g_isconnected[%1])

native give_weapon_svdex(id)
native give_weapon_dualkriss(id)
native cso_open_buy_menu(id)
new g_levelprowess[33], g_levelprotection[33],
g_levelswiftness[33], g_levelmarksmanship[33],
g_levelhealth[33], g_levelpoints[33]
new g_lsave1, g_lsave2, g_lsave3, g_lsave4, g_lsave5, g_lsave6

new const MAX_LEVELS[101] = 
{
    10,			//1
	20,			//2
	30,			//3
	40,			//4
	50,		//5
	60,		//6
	70,		//7
	80,		//8
	90,		//9
	100,		//10
	110,		//11
	120,		//12
	130,		//13
	140,		//14
	150,		//15
	160,
	170,
	180,
	190,
	200,
	210,
	220,
	230,
	240,
	250,
	260,
	270,
	280,
	290,
	300,
	310,
	320,
	330,
	340,
	350,
	360,
	370,
	380,
	390,
	400,
	410,
	420,
	430,
	440,
	450,
	460,
	470,
	480,
	490,
	500,
	510,
	520,
	530,
	540,
	550,
	560,
	570,
	580,
	590,
	600,
	610,
	620,
	630,
	640,
	650,
	660,
	670,
	680,
	690,
	700,
	710,
	720,
	730,
	740,
	750,
	760,
	770,
	780,
	790,
	800,
	810,
	820,
	830,
	840,
	850,
	860,
	870,
	880,
	890,
	900,
	910,
	920,
	930,
	940,
	950,
	960,
	970,
	980,
	990,
	1000,
	1000
}

new g_iLevel[ MAX_CLIENTS + 1 ], g_iExp[ MAX_CLIENTS + 1 ], g_CSOMoney[ MAX_CLIENTS + 1 ]

	
new const g_objective_ents[][] = 
{
	"func_bomb_target", 
	"info_bomb_target", 
	"info_vip_start", 
	"func_vip_safetyzone",
	"func_escapezone", 
	"hostage_entity",
	"monster_scientist", 
	"func_hostage_rescue", 
	"info_hostage_rescue", 
	"env_fog", 
	"env_rain", 
	"env_snow", 
	"item_longjump", 
	"func_vehicle" 
}
		
#define fm_create_entity(%1) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))
#define fm_remove_entity(%1) engfunc(EngFunc_RemoveEntity, %1)
#define fm_entity_set_model(%1,%2) engfunc(EngFunc_SetModel, %1, %2)

new g_playerclass[33] // Player's Zombie Class
new g_playersex[33] // Player's SEX
new g_nextclass[33] // Player's Next Zombie Class
new g_nodamage[33] // No Damage User
new g_zombie[33] // Had Zombie
new g_knife[33] // Player's knife type
new g_modname[32] // for formatting the mod name
new g_using_ab[33] // Using the Ability
new g_sprintzm[33] // is China ZM Using his ability
new g_type[33] // Player or Hero or Herine
new g_fwSpawn // spawn forward handle
new g_buyzone_ent // custom buyzone entity
new g_knife_key[33] // Used for Autosave!
new g_switchingteam // flag for whenever a player's team change emessage is sent
new g_startround

#define ID_SHOWHUD (taskid - TASK_SHOWHUD)
#define ID_TEAM (taskid - TASK_TEAM)
#define TASKID_BURN 3462
#define TASK_SPAWN 35674
#define TASKID_REMOVE_BURN 3463
#define TASK_RESTORE_MONEY 98210
#define TASK_BLOOD 151303

// Hammer
#define ANIM_IDLESLASH			0
#define ANIM_SLASH 				1
#define ANIM_SLASHE 				2
#define ANIM_DRAW 				3
#define ANIM_IDLESTAB 			4
#define ANIM_STAB 				5
#define ANIM_DRAWSTAB			6
#define ANIM_MOVESTAB 			7
#define ANIM_MOVESLASH 			8
new g_mode[33] , g_primaryattack[33]
// ============

#define OFFSET_MODELINDEX 491

// Edit these :pp 
#define MAX_MONEY_VIP 150000
#define MAX_MONEY 100000

new Float:g_teams_targettime // for adding delays between Team Change messages

new const CS_TEAM_NAMES[][] = { "UNASSIGNED", "TERRORIST", "CT", "SPECTATOR" }

const PDATA_SAFE = 2
const OFFSET_PAINSHOCK = 108 // ConnorMcLeod
const OFFSET_CSTEAMS = 114
const OFFSET_CSDEATHS = 444;
const OFFSET_MONEY = 115

const PEV_SPEC_TARGET = pev_iuser2

new pcvar_radius, pcvar_damage, g_pCvarAdminContact
new pcvar_burn_damage, pcvar_burn_period, pcvar_burn_delay, cvar_multiratio

enum
{
	FM_CS_TEAM_UNASSIGNED = 0,
	FM_CS_TEAM_T,
	FM_CS_TEAM_CT,
	FM_CS_TEAM_SPECTATOR
}
enum (+= 100)
{
	TASK_SHOWHUD,
	TASK_TEAM
}

const PEV_ADDITIONAL_AMMO = pev_iuser1

const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0;

const OFFSET_CSMENUCODE = 205
const OFFSET_LINUX = 5;
const OFFSET_LINUX_WEAPONS = 4;

const OFFSET_WEAPONOWNER = 41;
const OFFSET_ACTIVE_ITEM = 373;

const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE|(1<<CSW_HEGRENADE))
const ZOMBIE_ALLOWED_WEAPONS_BITSUM = (1<<CSW_KNIFE)|(1<<CSW_HEGRENADE)

const m_flNextAttack = 83

//native give_weapon_infi(id)
native give_weapon_ddeagle(id)

const UNIT_SECOND = (1<<12)

new countdown_timer

new g_fire_exp, g_exploSpr, g_trailSpr, g_fire_dm, g_smk_exp, g_FrogEXP

new round_count

enum
{
	light = 0,
	normal,
	china,
	voodoo,
	deimos,
	yaksha
}
enum
{
	strong = 0,
	axe,
	katana,
	combat,
	hammer
}
enum
{
	player = 0,
	hero,
	heroine
}
enum
{
	male = 0,
	female
}
new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_ak47", "weapon_knife", "weapon_p90" }
// Cvars
new cvar_delay, cvar_fire_radius, cvar_fire_dmg,
cvar_light_speed, cvar_pyscho_speed, cvar_china_force_speed, cvar_china_speed, cvar_voodoo_speed,
cvar_deimos_speed, cvar_reload_psy, cvar_reload_china, cvar_reload_voodoo,
cvar_strong_dmg, cvar_axe_dmg, cvar_combat_dmg, cvar_katana_dmg, cvar_spawndelay,
cvar_knockbackdist, cvar_zmknockback, cvar_jump_radius, cvar_jump_knock, cvar_reload_deimos, cvar_heal_radius,
cvar_hammer_dmg , cvar_hammer_dmg2 ,cvar_hammer_speed , cvar_hammer_speed2, cvar_human_speed, cvar_hammer_radius,
cvar_hammer_radius2, cvar_zombie_distance, cvar_nata_distance, cvar_strong_stab, cvar_fire_knock,
g_ZBScore, g_HMScore, cvar_yaskha_speed

const PEV_NADE_TYPE = pev_flTimeStepSound;
const NADE_TYPE_FIRE = 1111;
const NADE_TYPE_JUMP = 55556;

new const NADE_TYPE_HOLYBOMB = 1865;

const FFADE_IN = 0x0000

new const light_classname[] = "nst_deimos_skill"

new const ViewModelHoly[]="models/zm_cso/v_holybomb.mdl"
new const PlayerModelHoly[]="models/zm_cso/p_holybomb.mdl"
new const ViewModelFire[]="models/zm_cso/v_fire_grenade.mdl"
new const PlayerModelFire[]="models/zm_cso/p_fire_grenade.mdl"
new const WorldModelGrenades[]="models/zm_cso/w_ger_nades.mdl"

new const explode_spriteHoly[]="sprites/csozm/holybomb_exp.spr"
new const burn_spriteHoly[]="sprites/csozm/holybomb_burn.spr"

new const sound_skill_start[] = "zm_cso/deimos_skill_start.wav"
new const sound_skill_hit[] = "zm_cso/deimos_skill_hit.wav"

new const light_idle[] = "zm_cso/light_idle.wav"
new const normal_idle[] = "zm_cso/normal_idle.wav"

new const sound_buyammo[] = "items/9mmclip1.wav"

new sprites_exp_index, sprites_trail_index

new const frogbomb_sound[][] = 
{
	"zm_cso/all/zombi_bomb_pull_1.wav", 
	"zm_cso/all/zombi_bomb_deploy.wav",
	"zm_cso/all/zombi_bomb_throw.wav"
}

new const frogbomb_sound_idle[][] = 
{ 
	"zm_cso/all/zombi_bomb_idle_1.wav"
}

new g_exploSprHoly

new const ExplodeSounds[][]=
{
	"zm_cso/holywater_explosion.wav"
}
new const InfectSounds[][]=
{
	"zm_cso/light/infect.wav",
	"zm_cso/psy/infect.wav",
	"zm_cso/inf.wav",
	"zm_cso/light/infect2.wav",
	"zm_cso/psy/infect2.wav"
}
/* Plugins & Precache & etc */
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack");
	RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
	RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
	RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade");
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1);
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fw_primarynnKnifeAttack", 1)
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fw_SecondaryKnifeAttack", 1)
	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_knife", "fw_HammerKnifeIdle")
	RegisterHam(Ham_TakeDamage,"player","CPlayer__TakeDamage_Post",1)
	RegisterHam(Ham_Use, "func_tank", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary")
	RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary")
	RegisterHam(Ham_Touch, "grenade", "fw_TouchGrenade", 1)
	RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary")
	
	register_forward(FM_EmitSound, "fw_EmitSoundHuman")
	register_forward(FM_EmitSound, "fw_EmitSoundZombies")
	register_forward(FM_TraceHull, "fw_TraceHull")	
	register_forward(FM_TraceLine, "fw_traceline")
	register_forward(FM_AddToFullPack, "fw_PlayerAddToFullPack", 1 );
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect");
	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1);
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_GetGameDescription, "fw_GetGameDescription")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward(FM_Touch, "fw_Touch")
	register_forward(FM_CmdStart, "fw_cmdstart")
	register_forward(FM_CmdStart, "fw_CmdKnife")
	register_forward(FM_UpdateClientData, "fw_updateclientdata_post", 1)

	unregister_forward(FM_Spawn, g_fwSpawn)
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
	register_logevent("logevent_round_end", 2, "1=Round_End")
	
	register_menu("Game Menu", KEYSMENU, "menu_game");
	register_menu("Enhance Menu", KEYSMENU, "enhance_game");
	register_menu("Upgrade Menu", KEYSMENU, "upgrade_game");
	register_menu("Class Menu", KEYSMENU, "menu_class");
	register_menu("Knife Menu", KEYSMENU, "menu_knife");
	register_menu("Shop Menu", KEYSMENU, "menu_shop");

	register_clcmd("chooseteam", "clcmd_changeteam")
	register_clcmd("jointeam", "clcmd_changeteam")
	register_clcmd("drop", "clcmd_drop")
	register_clcmd("say /vips", "CmdVIP")
	register_clcmd("say_team /vips", "CmdVIP")
	//register_clcmd("say /shop", "show_shop_menu")
	register_clcmd("say /enhance", "show_enhance_menu")
	//register_clcmd("say /store", "show_shop_menu")
	register_clcmd("say /menu", "show_game_menu")
	register_clcmd("nightvision", "Cmd_NvgToggle")
	register_clcmd("infect", "cmd_infect")
	
	g_iMaxClients = get_maxplayers();
	
	g_MsgTeamInfo = get_user_msgid("TeamInfo")
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgDeathMsg = get_user_msgid("DeathMsg");
	g_msgBarTime = get_user_msgid("BarTime");
	g_msgScreenFade = get_user_msgid("ScreenFade");
	g_msgScoreAttrib = get_user_msgid("ScoreAttrib");
	g_msgScreenShake = get_user_msgid("ScreenShake");
	gmsgWeaponList = get_user_msgid("WeaponList");
	g_msgAmmoPickup = get_user_msgid("AmmoPickup");
	g_MsgMoney = get_user_msgid("Money")
	g_msgMoneyBlink = get_user_msgid("BlinkAcct")
	
	// block some Functions
	register_message(get_user_msgid("WeapPickup"), "message_weappickup")
	register_message(g_msgAmmoPickup, "message_ammopickup")
	register_message(get_user_msgid("Scenario"), "message_scenario")
	register_message(get_user_msgid("HostagePos"), "message_hostagepos")
	register_message(get_user_msgid("TextMsg"), "message_textmsg")
	register_message(get_user_msgid("SendAudio"), "message_sendaudio")
	register_message(g_MsgTeamInfo, "message_teaminfo")

	// Block normal CS Buy Menu
	register_menucmd(register_menuid("#Buy", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyPistol", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyShotgun", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuySub", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyRifle", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyMachine", 1), 511, "menu_cs_buy")
	register_menucmd(register_menuid("BuyItem", 1), 511, "menu_cs_buy")
	register_menucmd(-28, 511, "menu_cs_buy")
	register_menucmd(-29, 511, "menu_cs_buy")
	register_menucmd(-30, 511, "menu_cs_buy")
	register_menucmd(-32, 511, "menu_cs_buy")
	register_menucmd(-31, 511, "menu_cs_buy")
	register_menucmd(-33, 511, "menu_cs_buy")
	register_menucmd(-34, 511, "menu_cs_buy")
	
	register_event("CurWeapon","ev_curweapon","be","1=1") 
	register_event("TeamInfo", "event_TeamInfo", "a", "2=TERRORIST", "2=CT")
	
	// Weapon Hooks
	RegisterHam(Ham_Item_AddToPlayer, "weapon_flashbang", "fw_Hook_FlashBang")
	RegisterHam(Ham_Item_AddToPlayer, "weapon_hegrenade", "fw_Hook_HeGrenade")
	
	for (new i = 1; i < sizeof WEAPONENTNAMES; i++)
		if (WEAPONENTNAMES[i][0]) RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "fw_Item_Deploy_Post", 1);
		
	register_message(get_user_msgid("Health"), "message_health");
	
	g_save = nvault_open("EXP_SAVE")
	g_save2 = nvault_open("KNIFE_SAVE")
	g_save3 = nvault_open("LEVEL_SAVE")
	g_save4 = nvault_open("SKIN_SAVE")
	g_save5 = nvault_open("MONEY_SAVE")
	g_lsave1 = nvault_open("PROWESS_SAVE")
	g_lsave2 = nvault_open("PROC_SAVE")
	g_lsave3 = nvault_open("SWIFT_SAVE")
	g_lsave4 = nvault_open("MARK_SAVE")
	g_lsave5 = nvault_open("HP_SAVE")
	g_lsave6 = nvault_open("PTS_SAVE")
	
	// Registering Cvars
	cvar_delay = register_cvar("cso_delay", "20")
	cvar_fire_radius = register_cvar("cso_fire_radius", "150")
	cvar_fire_dmg = register_cvar("cso_fire_dmg", "500")
	cvar_knockbackdist = register_cvar("cso_knock_distance", "500")
	cvar_zmknockback = register_cvar("cso_victim_knockback", "200.0")
	cvar_spawndelay = register_cvar("cso_spawn_delay", "5")
	g_pCvarAdminContact = register_cvar("ze_admin_contact", "Forum: GamerClub.net")
	
	// Zombies Cvars
	cvar_light_speed = register_cvar("cso_light_speed", "250")
	cvar_pyscho_speed = register_cvar("cso_pyscho_speed", "275")
	cvar_china_force_speed = register_cvar("cso_china_force_speed", "500.0")
	cvar_china_speed = register_cvar("cso_china_speed", "240")
	cvar_voodoo_speed = register_cvar("cso_voodoo_speed", "255")
	cvar_heal_radius = register_cvar("cso_voodoo_heal_radius", "200")
	cvar_deimos_speed = register_cvar("cso_deimos_speed", "260")
	cvar_yaskha_speed = register_cvar("cso_yaksha_speed", "275")
	
	cvar_reload_psy = register_cvar("cso_pyscho_bar_t", "20")
	cvar_reload_china = register_cvar("cso_china_bar_t", "20")
	cvar_reload_voodoo = register_cvar("cso_voodoo_bar_t", "15")
	cvar_reload_deimos = register_cvar("cso_deimos_bar_t", "10")
	
	// Holy Bomb
	pcvar_radius = register_cvar("cso_holy_radius", "170")
	pcvar_damage = register_cvar("cso_holy_damage", "100")
	pcvar_burn_damage = register_cvar("cso_holy_burn_damage","30")
	pcvar_burn_period = register_cvar("cso_holy_burns_period", "9")
	pcvar_burn_delay = register_cvar("cso_holy_burn_second", "0.3")
	
	// Jump Greande
	cvar_jump_radius = register_cvar("cso_frog_grenade_radius", "350")
	cvar_jump_knock = register_cvar("cso_frog_grenade_knockback", "450")
	
	//Fire Nades
	cvar_fire_knock = register_cvar("cso_fire_grenade_knockback", "200")
	
	// Knifes
	cvar_strong_dmg = register_cvar("cso_a_knife_strong_damage","8")
	cvar_strong_stab = register_cvar("cso_a_knife_strong_stab", "1000")
	cvar_axe_dmg = register_cvar("cso_a_knife_axe_damage", "6.75")
	cvar_combat_dmg = register_cvar("cso_a_knife_combat_damage", "6.90")
	cvar_katana_dmg = register_cvar("cso_a_knife_katana_damage", "7.25")
	
	cvar_hammer_dmg = register_cvar("cso_a_knife_hammer_dmg", "7.55")
	cvar_hammer_dmg2 = register_cvar("cso_a_knife_hammer_dmg2", "6.75")
	cvar_hammer_speed = register_cvar("cso_knife_hammer_speed", "220.0")
	cvar_hammer_speed2 = register_cvar("cso_knife_hammer_speed2", "170.0")
	cvar_hammer_radius = register_cvar("cso_knife_hammer_distance", "100.0")
	cvar_hammer_radius2 = register_cvar("cso_knife_hammer_distance2", "125.0")
	cvar_nata_distance = register_cvar("cso_knife_strong_distance", "55.0")

	cvar_zombie_distance = register_cvar("cso_w_zombie_distance", "20.0")
	
	cvar_human_speed = register_cvar("cso_human_speed", "230")
	cvar_multiratio = register_cvar("cso_multi_ratio", "0.15")
	
	//Night Vision
	g_pCvarNVisionDensity = register_cvar("cso_zombie_nightvision_density", "0.0010")
	g_pCvarZombieNVisionColors[Red] = register_cvar("cso_zombie_nvision_red", "255")
	g_pCvarZombieNVisionColors[Green] = register_cvar("cso_zombie_nvision_green", "0")
	g_pCvarZombieNVisionColors[Blue] = register_cvar("cso_zombie_nvision_blue", "0")
	g_pCvarLightingStyle = register_cvar("cso_lighting_style", "d")
	
	register_clcmd("cso_give_level", "clcmd_add_user_level", ADMIN_RCON, "<name> <amount>")
	register_clcmd("cso_give_money", "clcmd_add_user_money", ADMIN_RCON, "<name> <amount>")
	register_concmd("cso_get_stats", "clcmd_get_user_stats")
	register_clcmd("cso_set_skin", "clcmd_set_user_skin", ADMIN_RCON, "<2-8 girls / 9-10 boys>")
	register_clcmd("say /vip", "clcmd_vip_motd")
	register_clcmd("say /help", "clcmd_help_motd")
	formatex(g_modname, charsmax(g_modname), "GAMERCLUB.NET")
	
	set_task(1.0, "Lighting_Style", _, _, _, "b")

	g_fwRoundStart = CreateMultiForward("cso_round_started", ET_IGNORE, FP_CELL)
	
}
public clcmd_vip_motd(id)
{
	show_motd(id, "vip.txt")
}
public clcmd_help_motd(id)
{
	show_motd(id, "help.txt")
}
public clcmd_get_user_stats(id)
{
	static s_Name[32], Iterator;
	
	for (Iterator = 1; Iterator <= get_maxplayers(); Iterator++)
	{
		if (is_user_connected(Iterator))
		{
			get_user_name(Iterator, s_Name, 31);

			if(get_user_flags(id) & ADMIN_KICK)
			{
				client_print ( id, print_console, "[ADMIN-CSO] Player %s / Level %d / EXP %d / Money %d / P-D-S-M-H %d-%d-%d-%d-%d", s_Name, g_iLevel[Iterator], g_iExp[Iterator], g_CSOMoney[Iterator], g_levelprowess[Iterator], g_levelprotection[Iterator], g_levelswiftness[Iterator], g_levelmarksmanship[Iterator], g_levelhealth[Iterator]);
			}
		}
	}

	return PLUGIN_HANDLED;
}
public Lighting_Style()
{
	get_pcvar_string(g_pCvarLightingStyle, g_szLightStyle, charsmax(g_szLightStyle))
	
	for (new id = 1; id <= g_iMaxClients; id++)
	{
		// Not Set For Un-Connected or Zombies
		if (!is_user_connected(id) || g_zombie[id])
			continue
		
		Set_MapLightStyle(id, g_szLightStyle)
	}
}
public plugin_cfg()
{
	server_cmd("mp_timelimit 0")
	g_ZBScore = 0
	g_HMScore = 0
	round_count = 0

	g_buyzone_ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_buyzone"))
	if (pev_valid(g_buyzone_ent))
	{
		dllfunc(DLLFunc_Spawn, g_buyzone_ent)
		set_pev(g_buyzone_ent, pev_solid, SOLID_NOT)
	}
}
public clcmd_add_user_level(id, level, cid)
{
	if ( !cmd_access ( id, level, cid, 3 ) )
		return PLUGIN_HANDLED;
		
	new s_Name[ 32 ], s_Amount[ 4 ], s_Admin[ 32 ]
	read_argv ( 1, s_Name, charsmax ( s_Name ) );
	get_user_name(id, s_Admin, 31);
	read_argv ( 2, s_Amount, charsmax ( s_Amount ) );
	
	new i_Target = cmd_target ( id, s_Name, 2 );
		
	if ( !i_Target )
	{
		client_print ( id, print_console, "[ADMIN-CSO] Player is not found")
		return PLUGIN_HANDLED;
	}
	
	if(str_to_num(s_Amount) + g_iLevel[i_Target] < 100)
	{
		g_levelpoints[i_Target] = str_to_num(s_Amount) + g_levelpoints[i_Target]
		g_iLevel[i_Target] = str_to_num(s_Amount) + g_iLevel[i_Target]
		g_iExp[i_Target] = 0
		client_print ( id, print_console, "[ADMIN-CSO] You gave %s %s level(s) and points", s_Name, s_Amount)
		client_printc(i_Target, "!g[CSO]!n ADMIN %s gave you %s Level(s).", s_Admin, s_Amount)
		Save_Data(i_Target)
	}
	else
	{
		client_print ( id, print_console, "[ADMIN-CSO] Amount is too big")
	}
	return PLUGIN_HANDLED;
}
public clcmd_add_user_money(id, level, cid)
{
	if ( !cmd_access ( id, level, cid, 3 ) )
		return PLUGIN_HANDLED;
		
	new s_Name[ 32 ], s_Amount[ 32 ], s_Admin[ 32 ]
	read_argv ( 1, s_Name, charsmax ( s_Name ) );
	get_user_name(id, s_Admin, charsmax( s_Admin ));
	read_argv ( 2, s_Amount, charsmax ( s_Amount ) );
	
	new i_Target = cmd_target ( id, s_Name, 2 );
		
	if ( !i_Target )
	{
		client_print ( id, print_console, "[ADMIN-CSO] Player is not found")
		return PLUGIN_HANDLED;
	}
	
	g_CSOMoney[i_Target] = str_to_num(s_Amount) + g_CSOMoney[i_Target]
	client_print ( id, print_console, "[ADMIN-CSO] You gave %s %s money.", s_Name, s_Amount)
	client_printc(i_Target, "!g[CSO]!n ADMIN %s gave you %s money.", s_Admin, s_Amount)
	if (!task_exists(i_Target+TASK_RESTORE_MONEY))
		set_task(0.5,"restore_player_money",i_Target+TASK_RESTORE_MONEY)
	Save_Data(i_Target)

	return PLUGIN_HANDLED;
}
public clcmd_set_user_skin(id, level, cid)
{
	if ( !cmd_access ( id, level, cid, 3 ) )
		return PLUGIN_HANDLED;
		
	new s_Name[ 32 ], s_Amount[ 4 ];
	read_argv ( 1, s_Name, charsmax ( s_Name ) );
	read_argv ( 2, s_Amount, charsmax ( s_Amount ) );
	
	new i_Target = cmd_target ( id, s_Name, 2 );
		
	if ( !i_Target )
	{
		client_print ( id, print_console, "[ADMIN-CSO] Player is not found")
		return PLUGIN_HANDLED;
	}
	
	skin[i_Target] = str_to_num(s_Amount)
	Save_Data(i_Target)
	client_print ( id, print_console, "[ADMIN-CSO] %s now have skin number %s", s_Name, s_Amount)
	return PLUGIN_HANDLED;
}
public plugin_precache()
{
	// Model Precache
	precache_model("models/zm_cso/v_infection.mdl")
	precache_model("models/zm_cso/v_zm_light.mdl")
	precache_model("models/zm_cso/v_zm_china.mdl")
	precache_model("models/zm_cso/v_zm_voodoo.mdl")
	precache_model("models/zm_cso/v_deimos.mdl")
	precache_model("models/zm_cso/v_zm_pyscho.mdl")
	precache_model("models/player/legendofwarior_humans/legendofwarior_humans.mdl")
	mdl_males = precache_model("models/player/legendofwarior_humans/legendofwarior_humans.mdl")
	precache_model("models/zm_cso/v_katana.mdl")
	precache_model("models/zm_cso/p_katana.mdl")
	precache_model("models/zm_cso/v_combat.mdl")
	precache_model("models/zm_cso/p_combat.mdl")
	precache_model("models/zm_cso/v_strong.mdl")
	precache_model("models/zm_cso/p_strong.mdl")
	precache_model("models/zm_cso/v_hammer_csozm.mdl")
	precache_model("models/zm_cso/p_hammer.mdl")
	precache_model("models/zm_cso/v_axe.mdl")
	precache_model("models/zm_cso/p_axe.mdl")
	precache_sound("csoleg_pickup.wav")
	precache_model("models/player/csozm_ligh/csozm_ligh.mdl")
	mdl_light = precache_model("models/player/csozm_ligh/csozm_ligh.mdl")
	precache_model("models/player/csozm_psycho/csozm_psycho.mdl")
	mdl_psy = precache_model("models/player/csozm_psycho/csozm_psycho.mdl")
	precache_model("models/player/csozm_china/csozm_china.mdl")
	mdl_china = precache_model("models/player/csozm_china/csozm_china.mdl")
	precache_model("models/player/csozm_shaman/csozm_shaman.mdl")
	mdl_shaman = precache_model("models/player/csozm_shaman/csozm_shaman.mdl")
	precache_model("models/player/legendofwarior_females/legendofwarior_females.mdl")
	mdl_females = precache_model("models/player/legendofwarior_females/legendofwarior_females.mdl")
	precache_model("models/player/csozm_deimos/csozm_deimos.mdl")
	mdl_deimos = precache_model("models/player/csozm_deimos/csozm_deimos.mdl")
	precache_model("models/player/akshazombi_origin/akshazombi_origin.mdl")
	mdl_yaksha = precache_model("models/player/akshazombi_origin/akshazombi_origin.mdl")
	precache_model(ViewModelFire)
	precache_model(PlayerModelFire)
	precache_model(WorldModelGrenades)
	precache_model("models/zm_cso/v_fast_bomb.mdl")
	precache_model("models/zm_cso/v_psycho_jump_f.mdl")
	precache_model("models/zm_cso/v_china_bomb.mdl")
	precache_model("models/zm_cso/v_voodoo_bomb.mdl")
	precache_model("models/zm_cso/p_zombiebomb.mdl")
	precache_model("models/zm_cso/v_deimos_jump_f.mdl")

	precache_model("models/v_knife_zombiaksha.mdl")
	precache_model("models/zm_cso/v_yaksha_jump_f.mdl")
	
	for(new i; i<=charsmax(InfectSounds); i++)
		precache_sound(InfectSounds[i])
	
	// Sprite Precache
	g_fire_exp = precache_model("sprites/csozm_fire_exp.spr")
	g_exploSpr = precache_model("sprites/shockwave.spr")
	g_trailSpr = precache_model("sprites/csozm_trail.spr")
	g_fire_dm = precache_model("sprites/csozm_fire.spr")
	g_smk_exp = precache_model("sprites/csozm_smoke.spr")
	g_exploSprHoly = precache_model(explode_spriteHoly)
	g_FrogEXP = precache_model("sprites/csozm/zombiebomb.spr")
	
	// Sound Precache
	precache_sound("zm_cso/20sec.wav")
	precache_sound("zm_cso/roundstart.wav")
	precache_sound("zm_cso/roundstart2.wav")
	precache_sound("zm_cso/roundstart3.wav")
	precache_generic("sound/zm_cso/ambience.mp3")
	precache_sound("zm_cso/countdown.wav")
	precache_sound("zm_cso/fire_exp.wav")
	precache_sound("zm_cso/ability_reset.wav")
	precache_sound("zm_cso/pyscho_smoke.wav")
	precache_sound("zm_cso/china_stop.wav")
	precache_sound("zm_cso/china_run.wav")
	precache_sound("zm_cso/knifes/strong_draw.wav")
	precache_sound("zm_cso/knifes/axe_draw.wav")
	precache_sound("zm_cso/knifes/combat_draw.wav")
	precache_sound("zm_cso/knifes/katana_draw.wav")
	precache_sound("zm_cso/knifes/hammer_draw.wav")
	precache_sound("zm_cso/knifes/strong_slash.wav")
	precache_sound("zm_cso/knifes/axe_slash.wav")
	precache_sound("zm_cso/knifes/combat_slash.wav")
	precache_sound("zm_cso/knifes/katana_slash.wav")
	precache_sound("zm_cso/knifes/hammer_slash.wav")
	precache_sound("zm_cso/knifes/strong_hitwall.wav")
	precache_sound("zm_cso/knifes/axe_hitwall.wav")
	precache_sound("zm_cso/knifes/combat_hitwall.wav")
	precache_sound("zm_cso/knifes/katana_hitwall.wav")
	precache_sound("zm_cso/knifes/hammer_hitwall.wav")
	precache_sound("zm_cso/knifes/strong_hit.wav")
	precache_sound("zm_cso/knifes/axe_hit.wav")
	precache_sound("zm_cso/knifes/combat_hit.wav")
	precache_sound("zm_cso/knifes/katana_hit.wav")
	precache_sound("zm_cso/knifes/hammer_hit.wav")
	precache_sound("zm_cso/knifes/strong_stab.wav")
	precache_sound("zm_cso/knifes/axe_stab.wav")
	precache_sound("zm_cso/knifes/combat_stab.wav")
	precache_sound("zm_cso/knifes/katana_stab.wav")
	precache_sound("zm_cso/knifes/hammer_stab.wav")
	precache_sound("zm_cso/all/hit_01.wav")
	precache_sound("zm_cso/all/slash_01.wav")
	precache_sound("zm_cso/all/wall_01.wav")
	precache_sound("zm_cso/light/pain.wav")
	precache_sound("zm_cso/psy/pain.wav")
	precache_sound("zm_cso/china/pain.wav")
	precache_sound("zm_cso/voodoo/pain.wav")
	precache_sound("zm_cso/all/win_human.wav")
	precache_sound("zm_cso/all/win_zombie.wav")
	precache_sound("zm_cso/all/no_one.wav")
	precache_sound("zm_cso/voodoo_heal.wav")
	precache_sound("zm_cso/head_explode.wav")
	precache_sound("vox/one.wav")
	precache_sound("vox/two.wav")
	precache_sound("vox/three.wav")
	precache_sound("vox/four.wav")
	precache_sound("vox/five.wav")
	precache_sound("vox/six.wav")
	precache_sound("vox/seven.wav")
	precache_sound("vox/eight.wav")
	precache_sound("vox/nine.wav")
	precache_sound("vox/ten.wav")
	precache_sound("zm_cso/excellent.wav")
	precache_sound("zm_cso/female-hit.wav")
	precache_sound("zm_cso/female-die.wav")

	// Holy Bomb
	precache_model(burn_spriteHoly)
	precache_model(ViewModelHoly)
	precache_model(PlayerModelHoly)
	
	for(new i; i<=charsmax(ExplodeSounds); i++)
		precache_sound(ExplodeSounds[i])
	
	static a
	for(a = 0; a < sizeof frogbomb_sound; a++)
		precache_sound(frogbomb_sound[a])

	for(a = 0; a < sizeof frogbomb_sound_idle; a++)
		precache_sound(frogbomb_sound_idle[a])
		
	precache_generic("sprites/weapon_holybomb_csozm.txt")
	precache_generic("sprites/csozm/640hud61.spr")
	precache_generic("sprites/csozm/640hud7.spr")
	precache_generic("sprites/claw_light_csozm.txt")
	precache_generic("sprites/csozm/Claws.spr")
	precache_generic("sprites/csozm/Claws1.spr")
	precache_generic("sprites/csozm/Claws2.spr")
	precache_generic("sprites/claw_psy_csozm.txt")
	precache_generic("sprites/claw_china_csozm.txt")
	precache_generic("sprites/claw_voodoo_csozm.txt")
	precache_generic("sprites/claw_deimos_csozm.txt")
	precache_generic("sprites/csozm/640hud25.spr")
	precache_generic("sprites/knife_strong_csozm.txt")
	precache_generic("sprites/knife_axe_csozm.txt")
	precache_generic("sprites/csozm/640hud47.spr")
	precache_generic("sprites/csozm/640hud39.spr")
	precache_generic("sprites/knife_combat_csozm.txt")
	precache_generic("sprites/csozm/640hud53.spr")
	precache_generic("sprites/knife_katana_csozm.txt")
	precache_generic("sprites/csozm/640hud21.spr")
	precache_generic("sprites/knife_hammer_csozm.txt")
	precache_generic("sprites/csozm/640hud7a.spr")
	precache_generic("sprites/csozm/640hud30.spr")
	precache_generic("sprites/csozm/640hud31.spr")
	precache_generic("sprites/csozm/640hud36.spr")
	precache_generic("sprites/weapon_jump_csozm.txt")
	precache_generic("sprites/weapon_he_csozm.txt")
	
	// Weapon Keys
	register_clcmd("weapon_holybomb_csozm", "HookFlashBang")
	register_clcmd("claw_light_csozm", "HookKnife")
	register_clcmd("claw_psy_csozm", "HookKnife")
	register_clcmd("claw_china_csozm", "HookKnife")
	register_clcmd("claw_voodoo_csozm", "HookKnife")
	register_clcmd("claw_deimos_csozm", "HookKnife")
	register_clcmd("knife_strong_csozm", "HookKnife")
	register_clcmd("knife_axe_csozm", "HookKnife")
	register_clcmd("knife_combat_csozm", "HookKnife")
	register_clcmd("knife_katana_csozm", "HookKnife")
	register_clcmd("knife_hammer_csozm", "HookKnife")
	
	register_clcmd("weapon_jump_csozm", "HookHeGrenade")
	register_clcmd("weapon_he_csozm", "HookHeGrenade")
	
	sprites_exp_index = precache_model("sprites/csozm/zombiebomb.spr")
	sprites_trail_index = precache_model("sprites/laserbeam.spr")
	precache_sound(sound_skill_start)
	precache_sound(sound_skill_hit)
	precache_sound(light_idle)
	precache_sound(normal_idle)
	
	g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")
	register_forward(FM_PrecacheSound, "fw_PrecacheSound")
	
	new ent
	
	// Fake Hostage (to force round ending)
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "hostage_entity"))
	if (pev_valid(ent))
	{
		engfunc(EngFunc_SetOrigin, ent, Float:{8192.0,8192.0,8192.0})
		dllfunc(DLLFunc_Spawn, ent)
	}
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"))	
	if (pev_valid(ent))
	{
		Set_KeyValue(ent, "density", "0.0018", "env_fog")
		Set_KeyValue(ent, "rendercolor", "0 0 0", "env_fog")
	}

	engfunc(EngFunc_PrecacheSound, sound_armorhit)
}

stock Set_KeyValue(entity, const key[], const value[], const classname[])
{
	set_kvd(0, KV_ClassName, classname)
	set_kvd(0, KV_KeyName, key)
	set_kvd(0, KV_Value, value)
	set_kvd(0, KV_fHandled, 0)

	dllfunc(DLLFunc_KeyValue, entity, 0)
}

public fw_PrecacheSound(const Sound[])
{
	if(containi(Sound, "/hostage/") != -1)
		return FMRES_SUPERCEDE
		
	return FMRES_IGNORED
}
public plugin_natives()
{
	register_native("cso_get_user_levels", "native_get_user_levels", 1)
	register_native("zp_get_user_zombie", "native_get_zombie", 1)
	register_native("cso_get_user_zombie", "native_get_zombie", 1)
	register_native("cso_open_knife_menu", "native_open_knife", 1)
	register_native("cso_get_user_type_hero", "native_get_type", 1)
	register_native("cso_get_user_type_heroine", "native_get_type_heroine", 1)
	register_native("cso_is_round_started", "native_get_round_started", 1)
	register_native("cso_set_user_money", "cso_set_user_money", 1)
	register_native("cso_get_user_money", "cso_get_user_money", 1)
	register_native("cso_blink_money", "cso_blink_money", 1)
	register_native("cso_is_yaksha", "native_cso_is_yaksha", 1)

}
public native_cso_is_yaksha(id)
{
	return (g_playerclass[id] == yaksha && g_zombie[id]);
}
public native_get_round_started()
{
	return g_roundstart;
}
public native_get_user_levels(id)
{
	return g_iLevel[id];
}
public native_get_zombie(id)
{
	return g_zombie[id];
}
public native_open_knife(id)
{
	show_knife_menu(id);
}
public native_get_type(id)
{
	return g_type[id] == hero;
}
public native_get_type_heroine(id)
{
	return g_type[id] == heroine;
}
public HookFlashBang(id)
{
	engclient_cmd(id, "weapon_flashbang")
	return PLUGIN_HANDLED;
}
public HookHeGrenade(id)
{
	engclient_cmd(id, "weapon_hegrenade")
	return PLUGIN_HANDLED;
}
public HookKnife(id)
{
	engclient_cmd(id, "weapon_knife")
	return PLUGIN_HANDLED;
}
public fw_Hook_FlashBang(iEnt, id)
{
	if(pev_valid(iEnt))
	{
		message_begin(MSG_ONE, get_user_msgid("WeaponList"), .player=id)
		write_string("weapon_holybomb_csozm") 
		write_byte(11)
		write_byte(2)
		write_byte(-1)
		write_byte(-1)
		write_byte(3)
		write_byte(2)
		write_byte(25)
		write_byte(24)
		message_end()
	}
}
public fw_Hook_HeGrenade(iEnt, id)
{
	if(pev_valid(iEnt))
	{
		message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
		if (g_zombie[id])	
			write_string("weapon_jump_csozm")
		else
			write_string("weapon_he_csozm")
		write_byte(12)
		write_byte(1)
		write_byte(-1)
		write_byte(-1)
		write_byte(3)
		write_byte(1)
		write_byte(4)
		write_byte(24)
		message_end()
	}
}
public fw_GetGameDescription()
{
	// Return the mod name so it can be easily identified
	forward_return(FMV_STRING, g_modname)
	
	return FMRES_SUPERCEDE;
}
/* Customized Nades */
public fw_SetModel(entity, const model[])
{
	// We don't care
	if (strlen(model) < 8)
		return HAM_IGNORED;

	// Get damage time of grenade
	static Float:dmgtime
	pev(entity, pev_dmgtime, dmgtime)
	
	// Grenade not yet thrown
	if (dmgtime == 0.0)
		return HAM_IGNORED;
	
	if(!g_zombie[pev(entity, pev_owner)])
	{
		if (model[9] == 'h' && model[10] == 'e')
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_BEAMFOLLOW) // TE id
			write_short(entity) // entity
			write_short(g_trailSpr) // sprite
			write_byte(10) // life
			write_byte(10) // width
			write_byte(235) // r
			write_byte(50) // g
			write_byte(0) // b
			write_byte(200) // brightness
			message_end()
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_FIRE)
			engfunc(EngFunc_SetModel, entity, WorldModelGrenades)
			set_pev(entity, pev_body, 0)
			return FMRES_SUPERCEDE
		}
		else if (model[9] == 'f' && model[10] == 'l')
		{
			fm_set_rendering(entity, kRenderFxGlowShell, 90, 155, 255, kRenderNormal, 3)
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_HOLYBOMB)
			set_pev(entity, pev_dmgtime, get_gametime()+9999999.0)
			set_pev(entity, pev_nextthink, get_gametime()+9999999.0)
			engfunc(EngFunc_SetModel, entity, WorldModelGrenades)
			set_pev(entity, pev_body, 2)
			return FMRES_SUPERCEDE
		}
	}
	else
	{
		if (model[9] == 'h' && model[10] == 'e')
		{
			set_pev(entity, PEV_NADE_TYPE, NADE_TYPE_JUMP)
			engfunc(EngFunc_SetModel, entity, WorldModelGrenades)
			set_pev(entity, pev_body, 1)
			set_pev(entity, pev_sequence, 3)
			set_pev(entity, pev_animtime, get_gametime()/2)
			set_pev(entity, pev_framerate, 10.0)
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}
public fw_TouchGrenade(ent)
{
	if(pev(ent, PEV_NADE_TYPE) == NADE_TYPE_HOLYBOMB)
	{
		holy_explode(ent)
		return HAM_SUPERCEDE;
	}
	return HAM_IGNORED
}
public fw_ThinkGrenade(entity) {
	if (!pev_valid(entity)) 
	         return HAM_IGNORED;
		 
         // Get damage time of grenade
	static Float:dmgtime, Float:current_time
	pev(entity, pev_dmgtime, dmgtime)
	current_time = get_gametime()
	
	// Check if it's time to go off
	if (dmgtime > current_time)
		return HAM_IGNORED;
	
	switch (pev(entity, PEV_NADE_TYPE))
	{
		case NADE_TYPE_FIRE:
		{
			fire_explode(entity)
		}
		case NADE_TYPE_JUMP:
		{
			head_explode(entity)
		}
		default: return HAM_IGNORED
	}
	return HAM_SUPERCEDE;
}
public head_explode(ent)
{
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, originF[0])
	engfunc(EngFunc_WriteCoord, originF[1])
	engfunc(EngFunc_WriteCoord, originF[2] + 45.0)
	write_short(g_FrogEXP)
	write_byte(20)
	write_byte(186)
	message_end()
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_SPARKS) 
	engfunc(EngFunc_WriteCoord, originF[0])
	engfunc(EngFunc_WriteCoord, originF[1])
	engfunc(EngFunc_WriteCoord, originF[2] + 45.0) 
	message_end()

	emit_sound(ent, CHAN_WEAPON, "zm_cso/head_explode.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	static victim
	victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, get_pcvar_float(cvar_jump_radius))) != 0)
	{
		if (!is_user_alive(victim))
			continue;
		
		new Float:VictimOrigin[3]
		pev(victim, pev_origin, VictimOrigin)
		
		static Float:Velocity[3]
		get_speed_vector(originF, VictimOrigin, get_pcvar_float(cvar_jump_knock), Velocity)
			               
		set_pev(victim, pev_velocity, Velocity)
		if(!g_zombie[victim])
		{
			message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, victim)
			write_short(UNIT_SECOND*13) // amplitude
			write_short(UNIT_SECOND*3) // duration
			write_short(UNIT_SECOND*30) // frequency
			message_end()
			if(get_user_health(victim) > 29)
				fm_set_user_health(victim, get_user_health(victim) - random_num(10, 20))
		}
	}
	engfunc(EngFunc_RemoveEntity, ent)
}
public holy_explode(ent)
{
	// Get origin
	static Float:originF[3], iOrigin[3]
	pev(ent, pev_origin, originF)
	FVecIVec(originF, iOrigin)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, {0, 0, 0}, 0)
	write_byte(TE_EXPLOSION)
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2]+30)
	write_short(g_exploSprHoly)
	write_byte(10)
	write_byte(28)
	write_byte(TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NOPARTICLES)
	message_end()
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_DLIGHT) 
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2])
	write_byte(10) 
	write_byte(30)
	write_byte(100)
	write_byte(255)
	write_byte(5) 
	write_byte(0) 
	message_end()
	 
	emit_sound(ent, CHAN_WEAPON, ExplodeSounds[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	static victim, attacker
	victim = -1
	attacker = pev( ent, pev_owner )
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, get_pcvar_float(pcvar_radius))) != 0)
	{
		if (!is_user_alive(victim))
			continue;
			
		if(g_zombie[victim])
		{
			ExecuteHam(Ham_TakeDamage, victim, "grenade", attacker, get_pcvar_float(pcvar_damage), DMG_BULLET)
			CreateBurnEntity(victim, attacker)
			client_print(attacker, print_center, "Health : %d", get_user_health(victim))
		}
		else
		{
			holy_buff(victim)
		}
	}
	engfunc(EngFunc_RemoveEntity, ent)
}
public holy_buff(id)
{
	g_buffed[id] = true
	client_printc(id, "!g[CSO]!n You have received the holy buff for 3 seconds.")
	set_task(3.0, "end_buff", id)
}
public end_buff(id)
{
	client_printc(id, "!g[CSO]!n Your holy buff has worn out.")
	g_buffed[id] = false
}
// Holy Bomb
public CreateBurnEntity(victim, attacker)
{
	if(!is_user_alive(victim)||!is_user_alive(attacker))
		return
	if(in_burn[victim]>0)
		return
		
	new ent = fm_create_entity("cycler_sprite")
	
	set_pev(ent, pev_owner, attacker)
	
	set_pev(ent, pev_model, burn_spriteHoly)
	dllfunc(DLLFunc_Spawn, ent)
	
	set_pev(ent, pev_classname, "HolyBombFire")
	
	fm_entity_set_model(ent, burn_spriteHoly)
	
	fm_set_rendering(ent, kRenderFxNoDissipation, 255, 255, 255, kRenderGlow, 255)
	
	set_pev(ent, pev_framerate, 10.0)
	
	set_pev(ent, pev_solid, SOLID_NOT)
	set_pev(ent, pev_movetype, MOVETYPE_FOLLOW)
	set_pev(ent, pev_aiment, victim)
	
	in_burn[victim]=ent
	
	static params[1]
	params[0] = attacker
	
	
	set_task(get_pcvar_float(pcvar_burn_period), "TaskRemoveBurnEntity", victim+TASKID_REMOVE_BURN)
	
	set_task(get_pcvar_float(pcvar_burn_delay), "Burn", victim+TASKID_BURN, params, sizeof params, "b")
	
}

public Burn(args[1] ,taskid)
{
	new id = taskid-TASKID_BURN
	
	if(!is_user_alive(id))
		return
		
	if(!pev_valid(in_burn[id]))
		return
	
	if(get_user_health(id) <= get_pcvar_num(pcvar_burn_damage))
	{
		set_task(1.0, "TaskRemoveBurnEntity", id+TASKID_REMOVE_BURN)
	}
	
	ExecuteHam(Ham_TakeDamage, id, "Holy Bomb", args[0], get_pcvar_float(pcvar_burn_damage), DMG_BURN)
}

public TaskRemoveBurnEntity(taskid)
{
	new id = taskid-TASKID_REMOVE_BURN	
	
	RemoveBurnEntity(id)
}

public RemoveBurnEntity(id)
{
	if(!pev_valid(in_burn[id]))
		return
	
	fm_remove_entity(in_burn[id])
	in_burn[id]=-1
}

// End
public fire_explode(ent)
{
	// Get origin
	static Float:originF[3]
	pev(ent, pev_origin, originF)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte (TE_SPRITE) // TE ID
	engfunc(EngFunc_WriteCoord, originF[0]) // Position X
	engfunc(EngFunc_WriteCoord, originF[1]) // Y
	engfunc(EngFunc_WriteCoord, originF[2] + 50.0) // Z
	write_short(g_fire_exp) // Sprite index
	write_byte(25) // Size of sprite
	write_byte(255) // Framerate
	message_end()
	 
	emit_sound(ent, CHAN_WEAPON, "zm_cso/fire_exp.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte (TE_SPRITE) // TE ID
	engfunc(EngFunc_WriteCoord, originF[0]) // Position X
	engfunc(EngFunc_WriteCoord, originF[1]) // Y
	engfunc(EngFunc_WriteCoord, originF[2] + 50.0) // Z
	write_short(g_fire_dm) // Sprite index
	write_byte(25) // Size of sprite
	write_byte(255) // Framerate
	message_end()
	
	static victim, attacker
	victim = -1
	attacker = pev( ent, pev_owner )
	
	make_beam(originF, 200, 100, 0)
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, get_pcvar_float(cvar_fire_radius))) != 0)
	{
		if (!is_user_alive(victim))
			continue;
			
		if(g_zombie[victim])
		{
			ExecuteHam(Ham_TakeDamage, victim, "grenade", attacker, get_pcvar_float(cvar_fire_dmg), DMG_BLAST)
			client_print(attacker, print_center, "Health : %d", get_user_health(victim))
		}
		
		new Float:VictimOrigin[3]
		pev(victim, pev_origin, VictimOrigin)
		
		static Float:Velocity[3]
		get_speed_vector(originF, VictimOrigin, get_pcvar_float(cvar_fire_knock), Velocity)
			               
		set_pev(victim, pev_velocity, Velocity)
		
		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenShake, _, victim)
		write_short(UNIT_SECOND*20) // amplitude
		write_short(UNIT_SECOND*3) // duration
		write_short(UNIT_SECOND*30) // frequency
		message_end()
	}
	engfunc(EngFunc_RemoveEntity, ent)
}
public make_beam(const Float:originF[3], red, green, blue)
{
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+385.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(red) // red
	write_byte(green) // green
	write_byte(blue) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+470.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(red) // red
	write_byte(green) // green
	write_byte(blue) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	engfunc(EngFunc_WriteCoord, originF[2]+555.0) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(red) // red
	write_byte(green) // green
	write_byte(blue) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
}
public ev_curweapon(id)
{
	if(!is_user_alive(id) || g_zombie[id])
		return PLUGIN_CONTINUE

	if(read_data(2) != CSW_KNIFE)
	{
		g_primaryattack[id] = 0
		if(g_mode[id] == 3) g_mode[id] = 1
		if(g_mode[id] == 4) g_mode[id] = 1
		if(g_mode[id] == 2) g_mode[id] = 0
		
		return PLUGIN_CONTINUE
	}

	return PLUGIN_CONTINUE	
}
public fw_CmdKnife(id, uc_handle, seed)
{
	if (!is_user_alive(id)) 
		return

	static ent
	ent = find_ent_by_owner(-1, "weapon_knife", id)
	
	if(!pev_valid(ent))
		return
	if(get_pdata_float(ent, 46, 4) > 0.0 || get_pdata_float(ent, 47, 4) > 0.0) 
		return
	
	static CurButton
	CurButton = get_uc(uc_handle, UC_Buttons)
	
	if(CurButton & IN_ATTACK)
	{
		g_attack_type[id] = ATTACK_SLASH
	} else {
		g_attack_type[id] = ATTACK_STAB
	}
}

public fw_cmdstart(id, uc_handle, seed)
{
	if(!is_user_alive(id) || g_zombie[id] || g_knife[id] != hammer || get_user_weapon(id) != CSW_KNIFE)
			return FMRES_IGNORED;

	new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)

	if(g_primaryattack[id] && !g_mode[id])
	{
		if(flNextAttack > 0.1)
			return FMRES_IGNORED;

		set_player_nextattack(id, 0.1)

		return FMRES_SUPERCEDE;
	}

	if((get_uc(uc_handle, UC_Buttons) & IN_ATTACK) && !g_mode[id])
	{
		if(flNextAttack > 0.1)
			return FMRES_IGNORED;

		g_primaryattack[id] = 1
		util_playweaponanimation(id, ANIM_SLASH)
		set_task(1.0,"knife_attack",id)

		set_player_nextattack(id, 0.1)
		return FMRES_IGNORED;
	}

	if(g_primaryattack[id]) 
		return FMRES_IGNORED;

	if(get_uc(uc_handle, UC_Buttons) & IN_ATTACK)
	{
		if(g_mode[id] == 2 || g_mode[id] == 3 || g_mode[id] == 4)
		{
			if(flNextAttack > 0.1)
				return FMRES_IGNORED;

			set_player_nextattack(id, 0.1)
		}

		return FMRES_IGNORED;
	}

	if(flNextAttack > 0.1)
		return FMRES_IGNORED;

	if((get_uc(uc_handle, UC_Buttons) & IN_ATTACK2))
	{
		if(g_mode[id] == 0)
		{
			g_mode[id] = 2
			util_playweaponanimation(id, ANIM_MOVESTAB) 
			set_task(1.4,"change_stab",id)
			set_player_nextattack(id, 1.5)
		}else if(g_mode[id] == 1){
			g_mode[id] = 3
			util_playweaponanimation(id, ANIM_MOVESLASH) 
			set_task(0.4,"change_slash1",id)
			set_player_nextattack(id, 1.5)
		}

		set_pev(id, pev_button , pev(id,pev_button) & ~IN_ATTACK2)
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}
public message_teaminfo(msg_id, msg_dest)
{
	// Only hook global messages
	if (msg_dest != MSG_ALL && msg_dest != MSG_BROADCAST) return;
	
	// Don't pick up our own TeamInfo messages for this player (bugfix)
	if (g_switchingteam) return;
	
	// Get player's id
	static id
	id = get_msg_arg_int(1)
	
	// Invalid player id? (bugfix)
	if (!(1 <= id <= g_iMaxClients)) return;
	
	// Round didn't start yet, nothing to worry about
	if (!g_roundstart) 
		return;
	
	// Get his new team
	static team[2]
	get_msg_arg_string(2, team, charsmax(team))
	
	// Perform some checks to see if they should join a different team instead
	switch (team[0])
	{
		case 'C': // CT
		{
			if (!fnGetZombies()) // no zombies alive --> switch to T and spawn as zombie
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_T)
				set_msg_arg_string(2, "TERRORIST")
			}
		}
		case 'T': // Terrorist
		{
			if (fnGetZombies()) // zombies alive --> switch to CT
			{
				remove_task(id+TASK_TEAM)
				fm_cs_set_user_team(id, FM_CS_TEAM_CT)
				set_msg_arg_string(2, "CT")
			}
		}
	}
}

public change_stab(id)
{
	if(!is_user_alive(id) || g_zombie[id] || g_knife[id] != hammer || get_user_weapon(id) != CSW_KNIFE)
		return PLUGIN_CONTINUE;

	g_mode[id] = 1

	return PLUGIN_CONTINUE;	
}

public change_slash1(id)
{
	if(!is_user_alive(id) || g_zombie[id] || g_knife[id] != hammer || get_user_weapon(id) != CSW_KNIFE)
		return PLUGIN_CONTINUE;

	g_mode[id] = 4
	set_task(1.0,"change_slash2",id)

	return PLUGIN_CONTINUE;
}

public change_slash2(id)
{
	if(!is_user_alive(id) || g_zombie[id] || g_knife[id] != hammer || get_user_weapon(id) != CSW_KNIFE)
		return PLUGIN_CONTINUE;

	g_mode[id] = 0

	return PLUGIN_CONTINUE;	
}
public knife_attack(id)
{
	if(!is_user_alive(id) || g_zombie[id] || g_knife[id] != hammer || get_user_weapon(id) != CSW_KNIFE)
		return;

	new knife = find_ent_by_owner ( -1, "weapon_knife", id )
	
	ExecuteHam(Ham_Weapon_PrimaryAttack, knife)

	g_primaryattack[id] = 2
	set_task(1.0,"knife_clear",id)
	set_player_nextattack(id, 1.0)
	util_playweaponanimation(id, ANIM_SLASHE)
}

public knife_clear(id)
{
	if(!is_user_alive(id) || g_zombie[id] || g_knife[id] != hammer || get_user_weapon(id) != CSW_KNIFE)
		return;

	g_primaryattack[id] = 0
}
public fw_updateclientdata_post(Player, SendWeapons, CD_Handle)
{
	if(!is_user_alive(Player) || g_zombie[Player] || g_knife[Player] != hammer || get_user_weapon(Player) != CSW_KNIFE)
		return FMRES_IGNORED
	
	set_cd(CD_Handle, CD_flNextAttack, halflife_time() + 0.001 )

	if(get_cd(CD_Handle, CD_WeaponAnim) != ANIM_MOVESTAB && g_mode[Player] == 2) 
	{
		set_cd(CD_Handle, CD_WeaponAnim, ANIM_MOVESTAB); 
		return FMRES_SUPERCEDE; 
	}

	if(get_cd(CD_Handle, CD_WeaponAnim) != ANIM_MOVESLASH && g_mode[Player] == 3) 
	{
		set_cd(CD_Handle, CD_WeaponAnim, ANIM_MOVESLASH); 
		return FMRES_SUPERCEDE; 
	}

	return FMRES_HANDLED
}
/* Knife Knockbacks */
public CPlayer__TakeDamage_Post(victim, inflictor, attacker, Float:damage)
{
	
	if (!is_user_connected(attacker)) 
		return
	
	if (!is_user_valid_connected(victim) || !is_user_valid_connected(attacker))
		return
		
	if(is_user_valid_connected(inflictor) && get_user_weapon(inflictor) == CSW_KNIFE && !g_zombie[attacker] && g_zombie[victim])
	{
		new Float:velocity[3], Float:newvelocity[3]
		entity_get_vector(victim, EV_VEC_velocity, velocity)
	
		new Float:victim_origin[3], Float:attacker_origin[3]
		entity_get_vector(victim, EV_VEC_origin, victim_origin)
		entity_get_vector(attacker, EV_VEC_origin, attacker_origin)
	
		newvelocity[0] = victim_origin[0] - attacker_origin[0]
		newvelocity[1] = victim_origin[1] - attacker_origin[1]
	
		new Float:largestnum = 0.0
	
		if (0 <= floatcmp(floatabs(newvelocity[0]), floatabs(newvelocity[1])) <= 1)
		{
			if (floatabs(newvelocity[0]) > 0) largestnum = floatabs(newvelocity[0])
		}
		else
		{
			if (floatabs(newvelocity[1]) > 0) largestnum = floatabs(newvelocity[1])
		}
	
		newvelocity[0] /= largestnum
		newvelocity[1] /= largestnum
		
		new Float:knockbackprowess, Float:holy_buff_knockback
		switch(g_levelprowess[attacker])
		{
			case 1 : knockbackprowess = 0.0
			case 2 : knockbackprowess = 1.0
			case 3 : knockbackprowess = 1.5
			case 4 : knockbackprowess = 2.0
			case 5 : knockbackprowess = 2.5
			case 6 : knockbackprowess = 3.0
			case 7 : knockbackprowess = 3.5
			case 8 : knockbackprowess = 4.0
			case 9 : knockbackprowess = 4.5
			case 10 : knockbackprowess = 5.0
		}
		if(g_buffed[attacker])
			holy_buff_knockback = 10.0
		else
			holy_buff_knockback = 0.0
		if(g_knife[attacker] == strong)
		{
			velocity[0] = newvelocity[0] * (1.1 + knockbackprowess + holy_buff_knockback) * 3000 / get_distance_f(victim_origin, attacker_origin)
			velocity[1] = newvelocity[1] * (1.1 + knockbackprowess + holy_buff_knockback) * 3000 / get_distance_f(victim_origin, attacker_origin)
		}
		else if(g_knife[attacker] == axe)
		{
			velocity[0] = newvelocity[0] * (0.7 + knockbackprowess + holy_buff_knockback) * 3000 / get_distance_f(victim_origin, attacker_origin)
			velocity[1] = newvelocity[1] * (0.7 + knockbackprowess + holy_buff_knockback) * 3000 / get_distance_f(victim_origin, attacker_origin)
		}
		else if(g_knife[attacker] == combat)
		{
			velocity[0] = newvelocity[0] * (0.4 + knockbackprowess + holy_buff_knockback)  * 3000 / get_distance_f(victim_origin, attacker_origin)
			velocity[1] = newvelocity[1] * (0.4 + knockbackprowess + holy_buff_knockback) * 3000 / get_distance_f(victim_origin, attacker_origin)
		}
		else if(g_knife[attacker] == katana)
		{
			velocity[0] = newvelocity[0] * (1.3 + knockbackprowess + holy_buff_knockback)  * 3000 / get_distance_f(victim_origin, attacker_origin)
			velocity[1] = newvelocity[1] * (1.3 + knockbackprowess + holy_buff_knockback) * 3000 / get_distance_f(victim_origin, attacker_origin)
		}
		else if(g_knife[attacker] == hammer)
		{
			if(!g_mode[attacker])
			{
				velocity[0] = newvelocity[0] * (12.3 + knockbackprowess + holy_buff_knockback)  * 3000 / get_distance_f(victim_origin, attacker_origin)
				velocity[1] = newvelocity[1] * (12.3 + knockbackprowess + holy_buff_knockback) * 3000 / get_distance_f(victim_origin, attacker_origin)
			}
			else
			{
				velocity[0] = newvelocity[0] * (25.0 + knockbackprowess + holy_buff_knockback )  * 3000 / get_distance_f(victim_origin, attacker_origin)
				velocity[1] = newvelocity[1] * (25.0 + knockbackprowess + holy_buff_knockback) * 3000 / get_distance_f(victim_origin, attacker_origin)
			}
		}
		newvelocity[2] = random_float(175.0 , 250.0)
			
		newvelocity[0] += velocity[0]
		newvelocity[1] += velocity[1]
		entity_set_vector(victim, EV_VEC_velocity, newvelocity)
	
		set_pdata_float(victim, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX, 5)
	}
}
/* Humans and Zombies Sounds */
public fw_EmitSoundHuman(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	// Block all those unneeeded hostage sounds
	if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
		return FMRES_SUPERCEDE;
	
	if (!is_user_valid_connected(id) || g_zombie[id])
		return FMRES_IGNORED;
	
	if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
	{
		if (sample[14] == 'd' && sample[15] == 'e' && sample[16] == 'p') // Draw
		{
			if(g_knife[id] == strong)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/strong_draw.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			else if(g_knife[id] == axe)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/axe_draw.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			else if(g_knife[id] == combat)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/combat_draw.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			else if(g_knife[id] == katana)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/katana_draw.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			else if(g_knife[id] == hammer)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/hammer_draw.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			return FMRES_SUPERCEDE;
		}
		if (sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') // slash
		{
			if(g_knife[id] == strong)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/strong_slash.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			else if(g_knife[id] == axe)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/axe_slash.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			else if(g_knife[id] == combat)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/combat_slash.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			else if(g_knife[id] == katana)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/katana_slash.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			else if(g_knife[id] == hammer)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/hammer_slash.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			return FMRES_SUPERCEDE;
		}
		if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') // hit
		{
			if (sample[17] == 'w') // wall
			{
				if(g_knife[id] == strong)
					emit_sound(id, CHAN_AUTO, "zm_cso/knifes/strong_hitwall.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				else if(g_knife[id] == axe)
					emit_sound(id, CHAN_AUTO, "zm_cso/knifes/axe_hitwall.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				else if(g_knife[id] == combat)
					emit_sound(id, CHAN_AUTO, "zm_cso/knifes/combat_hitwall.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				else if(g_knife[id] == katana)
					emit_sound(id, CHAN_AUTO, "zm_cso/knifes/katana_hitwall.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				else if(g_knife[id] == hammer)
					emit_sound(id, CHAN_AUTO, "zm_cso/knifes/hammer_hitwall.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				return FMRES_SUPERCEDE;
			}
			else
			{
				if(g_knife[id] == strong)
					emit_sound(id, CHAN_AUTO, "zm_cso/knifes/strong_hit.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				else if(g_knife[id] == axe)
					emit_sound(id, CHAN_AUTO, "zm_cso/knifes/axe_hit.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				else if(g_knife[id] == combat)
					emit_sound(id, CHAN_AUTO, "zm_cso/knifes/combat_hit.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				else if(g_knife[id] == katana)
					emit_sound(id, CHAN_AUTO, "zm_cso/knifes/katana_hit.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				else if(g_knife[id] == hammer)
					emit_sound(id, CHAN_AUTO, "zm_cso/knifes/hammer_hit.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					
				return FMRES_SUPERCEDE;
			}
		}
		if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') // stab
		{
			if(g_knife[id] == strong)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/strong_stab.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			else if(g_knife[id] == axe)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/axe_stab.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			else if(g_knife[id] == combat)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/combat_stab.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			else if(g_knife[id] == katana)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/katana_stab.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			else if(g_knife[id] == hammer)
				emit_sound(id, CHAN_AUTO, "zm_cso/knifes/hammer_stab.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				
			return FMRES_SUPERCEDE;
		}
	}
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't')
	{
		if(g_playersex[id] == female)
		{
			emit_sound(id, CHAN_AUTO, "zm_cso/female-hit.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			return FMRES_SUPERCEDE;
		}
	}
	if (sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a')))
	{
		if(g_playersex[id] == female)
		{
			emit_sound(id, CHAN_AUTO, "zm_cso/female-die.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}
public fw_EmitSoundZombies(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	// Block all those unneeeded hostage sounds
	if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e')
		return FMRES_SUPERCEDE;
	
	if (!is_user_valid_connected(id) || !g_zombie[id])
		return FMRES_IGNORED;
	
	if (sample[8] == 'k' && sample[9] == 'n' && sample[10] == 'i')
	{
		if (sample[14] == 's' && sample[15] == 'l' && sample[16] == 'a') // slash
		{
			emit_sound(id, CHAN_AUTO, "zm_cso/all/slash_01.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			return FMRES_SUPERCEDE;
		}
		if (sample[14] == 'h' && sample[15] == 'i' && sample[16] == 't') // hit
		{
			if (sample[17] == 'w') // wall
			{
				emit_sound(id, CHAN_AUTO, "zm_cso/all/wall_01.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				
				return FMRES_SUPERCEDE;
			}
			else
			{
				emit_sound(id, CHAN_AUTO, "zm_cso/all/hit_01.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					
				return FMRES_SUPERCEDE;
			}
		}
		if (sample[14] == 's' && sample[15] == 't' && sample[16] == 'a') // stab
		{
			emit_sound(id, CHAN_AUTO, "zm_cso/all/hit_01.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
				
			return FMRES_SUPERCEDE;
		}
	}
	if (sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't')
	{
		if(g_playerclass[id] == light)
			emit_sound(id, CHAN_AUTO, "zm_cso/light/pain.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		else if(g_playerclass[id] == normal)
			emit_sound(id, CHAN_AUTO, "zm_cso/psy/pain.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		else if(g_playerclass[id] == china)
			emit_sound(id, CHAN_AUTO, "zm_cso/china/pain.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		else if(g_playerclass[id] == voodoo)
			emit_sound(id, CHAN_AUTO, "zm_cso/voodoo/pain.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		else if(g_playerclass[id] == deimos)
			emit_sound(id, CHAN_AUTO, "zm_cso/psy/pain.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		else if(g_playerclass[id] == yaksha)
		{
			emit_sound(id, CHAN_AUTO, "zm_cso/psy/pain.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}
/* Some Functions */
// Prevent zombies from seeing any weapon pickup icon
public message_weappickup(msg_id, msg_dest, msg_entity)
{
	if (g_zombie[msg_entity])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Prevent zombies from seeing any ammo pickup icon
public message_ammopickup(msg_id, msg_dest, msg_entity)
{
	if (g_zombie[msg_entity])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Block hostage HUD display
public message_scenario()
{
	if (get_msg_args() > 1)
	{
		static sprite[8]
		get_msg_arg_string(2, sprite, charsmax(sprite))
		
		if (equal(sprite, "hostage"))
			return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// Block hostages from appearing on radar
public message_hostagepos()
{
	return PLUGIN_HANDLED;
}

// Block some text messages
public message_textmsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	
	// Game restarting, reset scores and call round end to balance the teams
	if (equal(textmsg, "#Game_will_restart_in"))
	{
		g_ZBScore = 0
		g_HMScore = 0
		logevent_round_end()
	}
	// Block round end related messages
	else if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win"))
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// Block CS round win audio messages, since we're playing our own instead
public message_sendaudio()
{
	static audio[17]
	get_msg_arg_string(2, audio, charsmax(audio))
	
	if(equal(audio[7], "terwin") || equal(audio[7], "ctwin") || equal(audio[7], "rounddraw"))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}
/* Round end */
public logevent_round_end()
{
	// Prevent this from getting called twice when restarting (bugfix)
	static Float:lastendtime, Float:current_time
	current_time = get_gametime()
	if (current_time - lastendtime < 0.5)
		return;
	lastendtime = current_time
	
	g_endround = true
	
	remove_task(1603)
	remove_task(1604)

	// Show HUD notice, play win sound, update team scores...
	if (!fnGetZombies())
	{
		play_sound("zm_cso/all/win_human.wav")
		client_printc(0, "!g[CSO]!n The Human race has successfuly stopped the invasion!")
		g_HMScore++
		for(new i = 0; i < g_iMaxClients; i++)
		{
			if(!is_user_valid_connected(i) || g_zombie[i])
				continue

			g_CSOMoney[i] += 3000
			client_printc(i, "!g[CSO]!n You received +3000$ cash for winning the game.")
		}
	}
	else if (!fnGetHumans())
	{
		play_sound("zm_cso/all/win_zombie.wav")
		client_printc(0, "!g[CSO]!n The Deadly Virus has spread and can not be stopped!")
		g_ZBScore++
		for(new i = 0; i < g_iMaxClients; i++)
		{
			if(!is_user_valid_connected(i) || !g_zombie[i])
				continue

			g_CSOMoney[i] += 3000
			client_printc(i, "!g[CSO]!n You received +3000$ cash for winning the game.")
		}
	}
	else
	{
		play_sound("zm_cso/all/no_one.wav")
		client_printc(0, "!g[CSO]!n A stalemate! No one has won!")
		for(new i = 0; i < g_iMaxClients; i++)
		{
			if(!is_user_valid_connected(i))
				continue

			g_CSOMoney[i] += 1000
			client_printc(i, "!g[CSO]!n You received +1000$.")
		}
	}
	balance_teams()
}
public play_sound(const sound[])
{
	client_cmd(0, "spk ^"%s^"", sound)
}
/* Knifes Sprites and Claws! */
public check_weapons_list(id)
{
	if(g_zombie[id])
	{
		if(g_playerclass[id] == light)
		{
			message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
			write_string("claw_light_csozm")
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(2)
			write_byte(1)
			write_byte(29)
			write_byte(0)
			message_end()
		}
		else if(g_playerclass[id] == normal)
		{
			message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
			write_string("claw_psy_csozm")
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(2)
			write_byte(1)
			write_byte(29)
			write_byte(0)
			message_end()
		}
		else if(g_playerclass[id] == china)
		{
			message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
			write_string("claw_china_csozm")
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(2)
			write_byte(1)
			write_byte(29)
			write_byte(0)
			message_end()
		}
		else if(g_playerclass[id] == voodoo)
		{
			message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
			write_string("claw_voodoo_csozm")
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(2)
			write_byte(1)
			write_byte(29)
			write_byte(0)
			message_end()
		}
		else if(g_playerclass[id] == deimos || g_playerclass[id] == yaksha)
		{
			message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
			write_string("claw_deimos_csozm")
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(2)
			write_byte(1)
			write_byte(29)
			write_byte(0)
			message_end()
		}
	}
	else
	{
		if(g_knife[id] == strong)
		{
			message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
			write_string("knife_strong_csozm")
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(2)
			write_byte(1)
			write_byte(29)
			write_byte(0)
			message_end()
		}
		else if(g_knife[id] == axe)
		{
			message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
			write_string("knife_axe_csozm")
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(2)
			write_byte(1)
			write_byte(29)
			write_byte(0)
			message_end()
		}
		else if(g_knife[id] == combat)
		{
			message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
			write_string("knife_combat_csozm")
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(2)
			write_byte(1)
			write_byte(29)
			write_byte(0)
			message_end()
		}
		else if(g_knife[id] == katana)
		{
			message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
			write_string("knife_katana_csozm")
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(2)
			write_byte(1)
			write_byte(29)
			write_byte(0)
			message_end()
		}
		else if(g_knife[id] == hammer)
		{
			message_begin(MSG_ONE, gmsgWeaponList, {0,0,0}, id)
			write_string("knife_hammer_csozm")
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(-1)
			write_byte(2)
			write_byte(1)
			write_byte(29)
			write_byte(0)
			message_end()
		}
	}
}
/* Abilitys Ends */
public china_reset(id)
{
	if(g_zombie[id]){
		fm_set_rendering(id)
		g_sprintzm[id] = false
		emit_sound(id, CHAN_AUTO, "zm_cso/china_stop.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		client_cmd(id,"cl_forwardspeed 400")
		client_cmd(id,"cl_backspeed 400")
	}
}
public reset_ability(id)
{
	if(g_zombie[id]){
		emit_sound(id, CHAN_AUTO, "zm_cso/ability_reset.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		client_printc(id, "!g[CSO]!n Your ability is ready for use!")
		g_using_ab[id] = false
	}
}
/* Public Functions */
public fw_TraceHull(Float:vector_start[3], Float:vector_end[3], ignored_monster, hull, id, handle)
{
	if (!is_user_alive(id) || !is_user_valid_connected(id))
		return FMRES_IGNORED;
	
	if (get_user_weapon(id) != CSW_KNIFE)
		return FMRES_IGNORED
		
	if(!g_zombie[id]){
		if(g_knife[id] == strong)
		{
			static Float:vecStart[3], Float:vecEnd[3], Float:v_angle[3], Float:v_forward[3], Float:view_ofs[3], Float:fOrigin[3]
			
			pev(id, pev_origin, fOrigin)
			pev(id, pev_view_ofs, view_ofs)
			xs_vec_add(fOrigin, view_ofs, vecStart)
			pev(id, pev_v_angle, v_angle)
			
			engfunc(EngFunc_MakeVectors, v_angle)
			get_global_vector(GL_v_forward, v_forward)
			
			static Float:scalar
			
			if(g_attack_type[id] == ATTACK_SLASH) scalar = get_pcvar_float(cvar_nata_distance)
			else if(g_attack_type[id] == ATTACK_STAB) scalar = get_pcvar_float(cvar_nata_distance)
			
			xs_vec_mul_scalar(v_forward, scalar, v_forward)
			xs_vec_add(vecStart, v_forward, vecEnd)
			
			engfunc(EngFunc_TraceHull, vecStart, vecEnd, ignored_monster, hull, id, handle)
			
			return FMRES_SUPERCEDE
		}
	}
	else if(g_zombie[id])
	{
		static Float:vecStart[3], Float:vecEnd[3], Float:v_angle[3], Float:v_forward[3], Float:view_ofs[3], Float:fOrigin[3]
			
		pev(id, pev_origin, fOrigin)
		pev(id, pev_view_ofs, view_ofs)
		xs_vec_add(fOrigin, view_ofs, vecStart)
		pev(id, pev_v_angle, v_angle)
		
		engfunc(EngFunc_MakeVectors, v_angle)
		get_global_vector(GL_v_forward, v_forward)
		
		xs_vec_mul_scalar(v_forward, get_pcvar_float(cvar_zombie_distance), v_forward)
		xs_vec_add(vecStart, v_forward, vecEnd)			
		engfunc(EngFunc_TraceHull, vecStart, vecEnd, ignored_monster, hull, id, handle)
			
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED;
}

public fw_traceline(Float:vector_start[3], Float:vector_end[3], ignored_monster, id, handle)
{
	if (!is_user_alive(id) || !is_user_valid_connected(id))
		return FMRES_IGNORED;
	
	new Float:distanceprowess, Float:distancebuff
	switch(g_levelprowess[id])
	{
		case 1 : distanceprowess = 0.0
		case 2 : distanceprowess = 1.0
		case 3 : distanceprowess = 1.5
		case 4 : distanceprowess = 2.0
		case 5 : distanceprowess = 2.5
		case 6 : distanceprowess = 3.0
		case 7 : distanceprowess = 3.5
		case 8 : distanceprowess = 4.0
		case 9 : distanceprowess = 4.5
		case 10 : distanceprowess = 5.0
	}
	if(g_buffed[id])
		distancebuff = 50.0
	else
		distancebuff = 0.0
	if (get_user_weapon(id) == CSW_KNIFE)
	{
		if(!g_zombie[id]){
			if(g_knife[id] == strong)
			{
				pev(id, pev_v_angle, vector_end)
				angle_vector(vector_end, ANGLEVECTOR_FORWARD, vector_end)
				
				if(g_attack_type[id] == ATTACK_SLASH)
					xs_vec_mul_scalar(vector_end, get_pcvar_float(cvar_nata_distance) + distanceprowess + distancebuff, vector_end)
				else if(g_attack_type[id] == ATTACK_STAB)
					xs_vec_mul_scalar(vector_end, get_pcvar_float(cvar_nata_distance) + distanceprowess + distancebuff, vector_end)
				
				xs_vec_add(vector_start, vector_end, vector_end)
				engfunc(EngFunc_TraceLine, vector_start, vector_end, ignored_monster, id, handle)
				return FMRES_SUPERCEDE;
			}
			else if(g_knife[id] == hammer)
			{
				pev(id, pev_v_angle, vector_end)
				angle_vector(vector_end, ANGLEVECTOR_FORWARD, vector_end)
				
				if(!g_mode[id]) 
					xs_vec_mul_scalar(vector_end, get_pcvar_float(cvar_hammer_radius) + distanceprowess + distancebuff, vector_end)
				else
					xs_vec_mul_scalar(vector_end, get_pcvar_float(cvar_hammer_radius2) + distanceprowess + distancebuff, vector_end)
				
				xs_vec_add(vector_start, vector_end, vector_end)
				engfunc(EngFunc_TraceLine, vector_start, vector_end, ignored_monster, id, handle)
				return FMRES_SUPERCEDE;
			}
		}
		else
		{
			pev(id, pev_v_angle, vector_end)
			angle_vector(vector_end, ANGLEVECTOR_FORWARD, vector_end)
				
			xs_vec_mul_scalar(vector_end, get_pcvar_float(cvar_zombie_distance) + distanceprowess, vector_end)
				
			xs_vec_add(vector_start, vector_end, vector_end)
			engfunc(EngFunc_TraceLine, vector_start, vector_end, ignored_monster, id, handle)
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED
}
public check_level(id)
{
	while( g_iExp[ id ] >= MAX_LEVELS[ g_iLevel[ id ] ] ) 
	{
		g_iLevel[ id ] += 1;
		g_iExp[id] = 0;
		g_levelpoints[id]++
		client_printc(id, "!g[CSO]!n You have leveled up!")
		client_printc(id, "!g[CSO]!n Say /enhance and spend your points!")
		g_CSOMoney[id] += 1000
		client_printc(id, "!g[CSO]!n You received +1000$ cash for leveling up!")
		if (!task_exists(id+TASK_RESTORE_MONEY))
			set_task(0.5,"restore_player_money",id+TASK_RESTORE_MONEY)
	}
	Save_Data(id)
}
public client_death(killer,victim,weapon,hitplace,TK)
{
	if(killer == victim)
		return PLUGIN_HANDLED;

	if(!g_zombie[killer] && g_zombie[victim])
	{
		if(weapon == CSW_KNIFE)
		{
			if(get_user_flags(killer) & ADMIN_LEVEL_H)
			{
				g_iExp[killer] += 10
				g_CSOMoney[killer] += 2000
			}
			else
			{
				g_iExp[killer] += 5
				g_CSOMoney[killer] += 1000
			}			
			client_printc(killer, "!g[CSO]!n You got bonus EXP for finishing off a zombie with a knife.")
			client_printc(killer, "!g[CSO]!n You got bonus CASH for finishing off a zombie with a knife.")
			client_cmd(killer, "spk zm_cso/excellent.wav")
		}
		else
		{
			if(get_user_flags(killer) & ADMIN_LEVEL_H)
			{
				g_iExp[killer] += 6
				g_CSOMoney[killer] += 1500
			}
			else
			{
				g_iExp[killer] += 3
				g_CSOMoney[killer] += 750
			}	
		}
		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, killer)
		write_short(UNIT_SECOND) // duration
		write_short(0) // hold time
		write_short(FFADE_IN) // fade type
		write_byte(0) // r
		write_byte(10) // g
		write_byte(200) // b
		write_byte(150) // alpha
		message_end()
		check_level(killer)
	}
	else
	{
		if(get_user_flags(killer) & ADMIN_LEVEL_H)
		{
			g_iExp[killer] += 20
			g_CSOMoney[killer] += 4000
		}
		else
		{
			g_iExp[killer] += 10		
			g_CSOMoney[killer] += 2000
		}	
		client_printc(killer, "!g[CSO]!n You got bonus EXP for finishing off the last human.")
		client_printc(killer, "!g[CSO]!n You got bonus CASH for finishing off the last human.")
		check_level(killer)
	}
	if (!task_exists(killer+TASK_RESTORE_MONEY)) 
		set_task(0.5,"restore_player_money",killer+TASK_RESTORE_MONEY)
	return PLUGIN_CONTINUE;
}
public fw_UseStationary(entity, caller, activator, use_type)
{
	// Prevent zombies from using stationary guns
	if (use_type == USE_USING && is_user_valid_connected(caller) && g_zombie[caller])
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

public fw_PlayerPreThink(id)
{
	if(g_roundstart)
	{
		message_begin(MSG_ONE, get_user_msgid("StatusIcon"), {0,0,0}, id);
		write_byte(1);
		write_string("dmg_bio");
		write_byte(255);
		write_byte(0);
		write_byte(0);
		message_end();
	}

	dllfunc(DLLFunc_Touch, g_buyzone_ent, id)
		
	new temp[2], weapon = get_user_weapon(id, temp[0], temp[1])
	if(is_user_alive(id) || !g_zombie[id])
	{
		if ( weapon == CSW_KNIFE )
		{
			if ((get_user_button(id) & IN_JUMP) && !(get_user_oldbutton(id) & IN_JUMP))
			{
				new flags = entity_get_int(id, EV_INT_flags)
				new waterlvl = entity_get_int(id, EV_INT_waterlevel)
			
				if (!(flags & FL_ONGROUND))
					return PLUGIN_CONTINUE
				if (flags & FL_WATERJUMP)
					return PLUGIN_CONTINUE
				if (waterlvl > 1)
					return PLUGIN_CONTINUE

				new Float:fVelocity[3]
				entity_get_vector(id, EV_VEC_velocity, fVelocity)
				if(g_knife[id] == strong)
					fVelocity[2] += 330
				else if(g_knife[id] == axe)
					fVelocity[2] += 345
				else if(g_knife[id] == combat)
					fVelocity[2] += 332
				else if(g_knife[id] == katana)
					fVelocity[2] += 330
				else if(g_knife[id] == hammer)
					fVelocity[2] += 328
				entity_set_vector(id, EV_VEC_velocity, fVelocity)
				entity_set_int(id, EV_INT_gaitsequence, 6)
			}
		}
	}
	return PLUGIN_CONTINUE;
}
public message_health(msg_id, msg_dest, msg_entity) {
	// Get player's health
	static health
	health = get_msg_arg_int(1)
	
	// Don't bother
	if (health < 256) return;
	
	// Check if we need to fix it
	if (health % 256 == 0)
		fm_set_user_health(msg_entity, pev(msg_entity, pev_health) + 1)
	
	// HUD can only show as much as 255 hp
	set_msg_arg_int(1, get_msg_argtype(1), 255)
}
public fw_Spawn(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return FMRES_IGNORED;
	
	// Get classname
	new classname[32]
	pev(entity, pev_classname, classname, sizeof classname - 1)
	
	// Check whether it needs to be removed
	for (new i = 0; i < sizeof g_objective_ents; i++)
	{
		if (equal(classname, g_objective_ents[i]))
		{
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}
public fw_Item_Deploy_Post(weapon_ent) {
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	static weaponid
	weaponid = cs_get_weapon_id(weapon_ent)

	// Valid owner?
	if (!pev_valid(owner))
		return;
	
	replace_weapon_models(owner, weaponid)
	
	if (g_zombie[owner] && !((1<<weaponid) & ZOMBIE_ALLOWED_WEAPONS_BITSUM))
	{
		engclient_cmd(owner, "weapon_knife")
	}
}
public set_default_models(id)
{
	cs_set_player_model(id, "legendofwarior_humans")
	if(get_user_flags(id) & ADMIN_LEVEL_H)
		set_pev(id, pev_body, 8)
	else
		set_pev(id, pev_body, random_num(0, 7))
	fm_set_user_model_index(id, mdl_males)
}
public check_models(id)
{
	if(is_user_alive(id))
	{
		if(is_user_valid_connected(id))
		{
			new skinny = skin[id]
			switch(skinny)
			{
				case 0 :
				{
					set_default_models(id)
					g_playersex[id] = male
				}
				case 1 :
				{
					set_default_models(id)
					skin[id] = 0
					g_playersex[id] = male
				}
				case 2 :
				{
					cs_set_player_model(id, "legendofwarior_females")
					fm_set_user_model_index(id, mdl_females)
					set_pev(id, pev_body, 0)
					g_playersex[id] = female
				}
				case 3 :
				{
					cs_set_player_model(id, "legendofwarior_females")
					fm_set_user_model_index(id, mdl_females)
					set_pev(id, pev_body, 1)
					g_playersex[id] = female
				}
				case 4 :
				{
					cs_set_player_model(id, "legendofwarior_females")
					fm_set_user_model_index(id, mdl_females)
					set_pev(id, pev_body, 2)
					g_playersex[id] = female
				}
				case 5 :
				{
					cs_set_player_model(id, "legendofwarior_females")
					fm_set_user_model_index(id, mdl_females)
					set_pev(id, pev_body, 3)
					g_playersex[id] = female
				}
				case 6 :
				{
					cs_set_player_model(id, "legendofwarior_females")
					fm_set_user_model_index(id, mdl_females)
					set_pev(id, pev_body, 4)
					g_playersex[id] = female
				}
				case 7 :
				{
					cs_set_player_model(id, "legendofwarior_females")
					fm_set_user_model_index(id, mdl_females)
					set_pev(id, pev_body, 5)
					g_playersex[id] = female
				}
				case 8 :
				{
					cs_set_player_model(id, "legendofwarior_females")
					fm_set_user_model_index(id, mdl_females)
					set_pev(id, pev_body, 6)
					g_playersex[id] = female
				}
				case 9 :
				{
					cs_set_player_model(id, "legendofwarior_humans")
					fm_set_user_model_index(id, mdl_males)
					set_pev(id, pev_body, 9)
					g_playersex[id] = male
				}
				case 10 :
				{
					cs_set_player_model(id, "legendofwarior_humans")
					fm_set_user_model_index(id, mdl_males)
					set_pev(id, pev_body, 10)
					g_playersex[id] = male
				}
			}
		}
	}
}
public set_user_human(id)
{
	g_buffed[id] = false
	Update_Attribute(id)
	g_zombie[id] = false
	remove_task(id+TASKID_REMOVE_BURN)
	RemoveBurnEntity(id)	
	client_cmd(id,"cl_forwardspeed 400")
	client_cmd(id,"cl_backspeed 400")
	g_sprintzm[id] = false
	set_user_rendering(id)
	g_using_ab[id] = false
	new bonushealth
	switch(g_levelhealth[id])
	{
		case 1 : bonushealth = 0
		case 2 : bonushealth = 25			
		case 3 : bonushealth = 50		
		case 4 : bonushealth = 75
		case 5 : bonushealth = 100
		case 6 : bonushealth = 125
		case 7 : bonushealth = 150
		case 8 : bonushealth = 175
		case 9 : bonushealth = 200
		case 10 : bonushealth = 300
	}
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		fm_set_user_health(id, 200 + bonushealth)
	}
	else
	{
		fm_set_user_health(id, 100 + bonushealth)
	}
	if(g_freeround)
		set_pev(id, pev_gravity, 0.15)
	else
		set_pev(id, pev_gravity, 1.0)
			
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
			
	check_models(id)
		
	static weapon_ent
	weapon_ent = fm_cs_get_current_weapon_ent(id)
	if (pev_valid(weapon_ent)) replace_weapon_models(id, cs_get_weapon_id(weapon_ent))
	check_weapons_list(id)
	engclient_cmd(id, "weapon_knife")
	
	Set_NightVision(id, 0, 0, 0x0000, 0, 0, 0, 0)
}
public fw_PlayerSpawn_Post(id) 
{
	if (!is_user_alive(id) || !fm_cs_get_user_team(id) || !is_user_valid_connected(id))
		return
		
	client_crsis(id, 1)
	Update_Attribute(id)

	if(g_randomclass[id])
	{
		if(get_user_flags(id) & ADMIN_LEVEL_H)
			g_nextclass[id] = deimos
		else
			g_nextclass[id] = random_num(light, voodoo)
		g_randomclass[id] = false
	}
	
	client_printc(id, "!g[CSO]!n A friendly reminder, press !t[M] !nor type !t/menu !nto open Game Menu.")
	
	if(!g_roundstart)
	{
		set_task(2.0, "bruh_buy", id)
		set_user_human(id)
	}
	else
	{
		if(g_freeround)
			set_user_human(id)
		else
			infect_user(id)
	}
	g_type[id] = player
	check_level(id)
	
	if (!task_exists(id+TASK_RESTORE_MONEY)) 
		set_task(0.5,"restore_player_money",id+TASK_RESTORE_MONEY)
}
public bruh_buy(id)
{
	cso_open_buy_menu(id)
}
public Update_Attribute(id)
{
    if (get_user_flags(id) & ADMIN_LEVEL_H)
    {
        message_begin(MSG_ALL, get_user_msgid("ScoreAttrib"), {0, 0, 0}, id)
        write_byte(id)
        write_byte(4)
        message_end()
    }
}
public CmdVIP(id)
{
    set_task(0.1, "Print_List")
}
public Print_List()
{
	Print_VIP_List()
}
public Print_VIP_List()
{
    new szVIPName[33][32], szMessage[700], szContact[256]

    new iPlayer, i, iVIPCount = 0, iLen = 0;

    for (iPlayer = 1; iPlayer <= g_iMaxClients; iPlayer++)
    {
        if (!is_user_connected(iPlayer) || !(get_user_flags(iPlayer) & ADMIN_LEVEL_H))
            continue

        get_user_name(iPlayer, szVIPName[iVIPCount++], charsmax(szVIPName))
    }

    iLen = formatex(szMessage, charsmax(szMessage), "!nVIPs ONLINE: ")

    if (iVIPCount)
    {
        for (i = 0; i <= iVIPCount; i++)
            iLen += formatex(szMessage[iLen], charsmax(szMessage) - iLen, "!t%s!n%s!t", szVIPName[i], (i < (iVIPCount - 1)) ? ", " : "")
    }
    else
    {
        szMessage = "!nNo VIPs online."
    }

    client_printc(0, "!g[CSO]!n %s", szMessage)
    get_pcvar_string(g_pCvarAdminContact, szContact, charsmax(szContact))

    if (szContact[0])
    {
        client_printc(0, "!g[CSO]!n Contact server administrator : !t%s", szContact)
    }
}
public fw_PlayerAddToFullPack( ES_Handle, E, pEnt, pHost, bsHostFlags, pPlayer, pSet )
{       
	if( pPlayer && get_user_weapon(pEnt) == CSW_KNIFE && !g_zombie[pEnt] )
	{
		static iAnim;

		iAnim = get_es( ES_Handle, ES_Sequence );

		if(g_knife[pEnt] == katana)
		{
			switch( iAnim )
			{
				case 73:
				{
					set_es( ES_Handle, ES_Sequence, iAnim -= 4 );
				}
				case 74:
				{
					set_es( ES_Handle, ES_Sequence, iAnim -= 4 );
				}
				case 75:
				{
					set_es( ES_Handle, ES_Sequence, iAnim -= 4 );
				}
				case 76:
				{
					set_es( ES_Handle, ES_Sequence, iAnim -= 4 );
				}
			}
		}
		else if(g_knife[pEnt] == hammer)
		{
			switch( iAnim )
			{
				case 73, 74, 75, 76:
				{
					set_es( ES_Handle, ES_Sequence, iAnim += 10 );
				}
			}
		}
	}
	return FMRES_IGNORED;
}
// Ability Deimos 
public launch_light(id)
{
	if (!is_user_alive(id)) return;
	
	new Float:vecAngle[3],Float:vecOrigin[3],Float:vecVelocity[3],Float:vecForward[3]
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	fm_get_user_startpos(id,5.0,2.0,-1.0,vecOrigin)
	pev(id,pev_angles,vecAngle)
	engfunc(EngFunc_MakeVectors,vecAngle)
	global_get(glb_v_forward,vecForward)
	velocity_by_aim(id,2000,vecVelocity)
	set_pev(ent,pev_origin,vecOrigin)
	set_pev(ent,pev_angles,vecAngle)
	set_pev(ent,pev_classname,light_classname)
	set_pev(ent,pev_movetype,MOVETYPE_FLY)
	set_pev(ent,pev_solid,SOLID_BBOX)
	engfunc(EngFunc_SetSize,ent,{-1.0,-1.0,-1.0},{1.0,1.0,1.0})
	engfunc(EngFunc_SetModel,ent,"models/w_hegrenade.mdl")
	set_pev(ent,pev_owner,id)
	set_pev(ent,pev_velocity,vecVelocity)
	
	set_rendering(ent, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte(TE_BEAMFOLLOW)
	write_short(ent)
	write_short(sprites_trail_index)
	write_byte(5)
	write_byte(3)
	write_byte(209)
	write_byte(120)
	write_byte(9)
	write_byte(200)
	message_end()
	
	return;
}
public fw_Touch(ent, victim)
{
	if (!pev_valid(ent)) return FMRES_IGNORED
	
	new EntClassName[32]
	entity_get_string(ent, EV_SZ_classname, EntClassName, charsmax(EntClassName))
	
	if (equal(EntClassName, light_classname)) 
	{
		light_exp(ent, victim)
		
		return FMRES_IGNORED
	}
	
	return FMRES_IGNORED
}
light_exp(ent, victim)
{
	if (!pev_valid(ent)) return;
	
	if (is_user_alive(victim) && !g_zombie[victim])
	{
		set_player_nextattack(victim, 10.0)

		message_begin(MSG_ONE, g_msgScreenFade, _, victim)
		write_short(UNIT_SECOND)
		write_short(0)
		write_short(FFADE_IN)
		write_byte(209)
		write_byte(120)
		write_byte(9)
		write_byte (255)
		message_end()
	
		message_begin(MSG_ONE, g_msgScreenShake, _, victim)
		write_short(UNIT_SECOND*4)
		write_short(UNIT_SECOND*2)
		write_short(UNIT_SECOND*10)
		message_end()

		client_printc(victim, "!g[CSO]!n You have been attacked, you can't shoot your weapons for 10s.")
	}
	
	PlayEmitSound(ent, sound_skill_hit)
	
	static Float:origin[3]
	pev(ent, pev_origin, origin)
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2]))
	write_short(sprites_exp_index)
	write_byte(40)
	write_byte(30)
	write_byte(14)
	message_end()
	
	remove_entity(ent)
}
// Done :D
public clcmd_drop(id)
{
	if(g_zombie[id] && is_user_valid_connected(id))
	{
		if(is_user_alive(id))
		{
			if(!g_using_ab[id])
			{
				if(g_playerclass[id] == normal)
				{
					g_using_ab[id] = true
					
					emit_sound(id, CHAN_AUTO, "zm_cso/pyscho_smoke.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					
					static Float:originF[3]
					pev(id, pev_origin, originF)
					
					engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
					write_byte(TE_BEAMCYLINDER) // TE id
					engfunc(EngFunc_WriteCoord, originF[0]) // x
					engfunc(EngFunc_WriteCoord, originF[1]) // y
					engfunc(EngFunc_WriteCoord, originF[2]) // z
					engfunc(EngFunc_WriteCoord, originF[0]) // x axis
					engfunc(EngFunc_WriteCoord, originF[1]) // y axis
					engfunc(EngFunc_WriteCoord, originF[2]+200.0) // z axis
					write_short(g_exploSpr) // sprite
					write_byte(0) // startframe
					write_byte(0) // framerate
					write_byte(4) // life
					write_byte(60) // width
					write_byte(0) // noise
					write_byte(230) // red
					write_byte(240) // green
					write_byte(220) // blue
					write_byte(255) // brightness
					write_byte(0) // speed
					message_end()

					message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
					write_byte (TE_SPRITE) // TE ID
					engfunc(EngFunc_WriteCoord, originF[0]) // Position X
					engfunc(EngFunc_WriteCoord, originF[1]) // Y
					engfunc(EngFunc_WriteCoord, originF[2]) // Z
					write_short(g_smk_exp) // Sprite index
					write_byte(35) // Size of sprite
					write_byte(255) // Framerate
					message_end()
					
					message_begin(MSG_ONE, g_msgBarTime, _, id)
					write_byte(get_pcvar_num(cvar_reload_psy)) // time
					write_byte(0) // unknown
					message_end()
					
					set_task(20.0, "reset_ability", id)
					
				}
				else if(g_playerclass[id] == china)
				{
					fm_set_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 25)
					g_using_ab[id] = true
					g_sprintzm[id] = true
					emit_sound(id, CHAN_AUTO, "zm_cso/china_run.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					client_cmd(id,"cl_forwardspeed 1600")
					client_cmd(id,"cl_backspeed 1600")
					set_task(10.0, "china_reset", id)
					
					message_begin(MSG_ONE, g_msgBarTime, _, id)
					write_byte(get_pcvar_num(cvar_reload_china)) // time
					write_byte(0) // unknown
					message_end()
				
					set_task(20.0, "reset_ability", id)
				}
				else if(g_playerclass[id] == voodoo)
				{
					
					static Float:originF[3]
					pev(id, pev_origin, originF)
	
					message_begin(MSG_ONE, g_msgBarTime, _, id)
					write_byte(get_pcvar_num(cvar_reload_voodoo)) // time
					write_byte(0) // unknown
					message_end()
					
					emit_sound(id, CHAN_AUTO, "zm_cso/voodoo_heal.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
					
					g_using_ab[id] = true
					
					make_beam(originF, 245, 5, 13)
					
					static victim 
					victim = -1
	
					while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, originF, get_pcvar_float(cvar_heal_radius))) != 0)
					{
						if (!is_user_alive(victim) || !g_zombie[victim])
							continue;
							
						fm_set_user_health(victim, get_user_health(victim) + 500)
						message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, victim)
						write_short(UNIT_SECOND) // duration
						write_short(0) // hold time
						write_short(FFADE_IN) // fade type
						write_byte(200) // r
						write_byte(0) // g
						write_byte(0) // b
						write_byte(200) // alpha
						message_end()
					}
					
					
					set_task(15.0, "reset_ability", id)
				}
				else if(g_playerclass[id] == deimos && get_user_weapon(id) == CSW_KNIFE)
				{
					
					message_begin(MSG_ONE, g_msgBarTime, _, id)
					write_byte(get_pcvar_num(cvar_reload_deimos)) // time
					write_byte(0) // unknown
					message_end()
					
					PlayEmitSound(id, sound_skill_start)
					util_playweaponanimation(id, 8)
					set_pev(id, pev_sequence, 10)
					set_player_nextattack(id, 1.3)
					
					g_using_ab[id] = true
					
					set_task(0.5, "launch_light", id)
					
					set_task(10.0, "reset_ability", id)
				}
			}
			else
			{
				client_printc(id, "!g[CSO]!n You can not use your ability yet.")
			}
		}
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
public client_PreThink(id)
{
	new speedswiftness, holy_buff_speed
	if(g_buffed[id])
		holy_buff_speed = 150
	else
		holy_buff_speed = 1
	switch(g_levelswiftness[id])
	{
		case 1 : speedswiftness = 5
		case 2 : speedswiftness = 10
		case 3 : speedswiftness = 15
		case 4 : speedswiftness = 20
		case 5 : speedswiftness = 25
		case 6 : speedswiftness = 30
		case 7 : speedswiftness = 35
		case 8 : speedswiftness = 40
		case 9 : speedswiftness = 45
		case 10 : speedswiftness = 50
	}
	if(g_zombie[id])
	{
		if(g_playerclass[id] == light)
			set_user_maxspeed(id, get_pcvar_float(cvar_light_speed) + speedswiftness)
		else if(g_playerclass[id] == normal)
			set_user_maxspeed(id, get_pcvar_float(cvar_pyscho_speed) + speedswiftness)
		else if(g_playerclass[id] == china)
		{
			if(g_sprintzm[id])
				set_user_maxspeed(id, get_pcvar_float(cvar_china_force_speed) + speedswiftness)
			else
				set_user_maxspeed(id, get_pcvar_float(cvar_china_speed) + speedswiftness)
		}
		else if(g_playerclass[id] == voodoo)
			set_user_maxspeed(id, get_pcvar_float(cvar_voodoo_speed) + speedswiftness)
		else if(g_playerclass[id] == deimos)
			set_user_maxspeed(id, get_pcvar_float(cvar_deimos_speed) + speedswiftness)
		else if(g_playerclass[id] == yaksha)
			set_user_maxspeed(id, get_pcvar_float(cvar_yaskha_speed) + speedswiftness)
	}
	else
	{
		if(g_knife[id] == hammer && get_user_weapon(id) == CSW_KNIFE)
		{
			if(g_mode[id] == 0) set_user_maxspeed(id, get_pcvar_float(cvar_hammer_speed) + speedswiftness + holy_buff_speed)
			if(g_mode[id] == 1) set_user_maxspeed(id, get_pcvar_float(cvar_hammer_speed2) + speedswiftness + holy_buff_speed)
			if(g_mode[id] == 2) set_user_maxspeed(id, get_pcvar_float(cvar_hammer_speed2) + speedswiftness + holy_buff_speed)
			if(g_mode[id] == 3) set_user_maxspeed(id, get_pcvar_float(cvar_hammer_speed2) + speedswiftness + holy_buff_speed)
			if(g_mode[id] == 4) set_user_maxspeed(id, get_pcvar_float(cvar_hammer_speed) + speedswiftness + holy_buff_speed)
		}
		else
		{
			set_user_maxspeed(id, get_pcvar_float(cvar_human_speed) + speedswiftness + holy_buff_speed)
		}
	}
	if(g_iLevel[ id ] >= 100)
	{
		g_iLevel[ id ] = 100
	}
	if(g_iExp[ id ] >= 1000)
	{
		g_iExp[ id ] = 0
	}
}
// CS Buy Menus
public menu_cs_buy(id, key)
{
	if (g_zombie[id])
		return PLUGIN_HANDLED;

	cso_open_buy_menu(id)
	return PLUGIN_CONTINUE;
}
public client_connect(id)
{
	g_CSOMoney[ id ] = 0
	g_iExp[ id ] = 0
	g_iLevel [ id ] = 0
	Load_Data(id)
	g_randomclass[id] = true
	g_zombie[id] = false
}
public client_putinserver(id)
{
	if(g_knife_key[id] == 0)
		g_knife[id] = strong 
	else if(g_knife_key[id] == 1)
		g_knife[id] = axe
	else if(g_knife_key[id] == 2)
		g_knife[id] = combat
	else if(g_knife_key[id] == 3)
		g_knife[id] = katana
	else if(g_knife_key[id] == 4)
		g_knife[id] = hammer
		
	set_user_info(id, "_vgui_menus", "0") 

	g_isconnected[id] = true
	set_task(1.0, "ShowHUD", id+TASK_SHOWHUD, _, _, "b")
		
}
public event_TeamInfo()
{
	static id, iPlayersnum
	id = read_data(1)
	iPlayersnum = fnGetAlive()

	if(id == 0 || is_user_alive(id) || !is_user_valid_connected(id))	
		return
	
	if(fnGetHumans() > 1)
	{
		if(!task_exists(id+TASK_SPAWN))
		{
			set_task(get_pcvar_float(cvar_spawndelay), "respawn_player_task", id+TASK_SPAWN)
			client_printc(id, "!g[CSO]!n You will respawn within' couple seconds...")
		}
	}
	if(!fnGetZombies() && iPlayersnum >= 2 && g_roundstart && !g_endround && !g_freeround)
	{
		if(!task_exists(4998456))
			set_task(1.0, "restart_server", 4998456)
	}
}
public restart_server(taskid)
{
	remove_task(taskid)
	logevent_round_end()
}
public fw_ClientDisconnect(id)
{
	g_isconnected[id] = false
	Save_Data(id)
	client_crsis(id, 0)
	if(task_exists(id+TASK_SHOWHUD))
		remove_task(id+TASK_SHOWHUD)
}
public fw_ClientDisconnect_Post(id)
{
	static iPlayersnum
	iPlayersnum = fnGetAlive()
	
	if(g_zombie[id])
	{
		if(!fnGetZombies() && iPlayersnum > 2)
		{
			new newid, szName[ 32 ], szNewName[ 32 ]
			static iPlayersNum
			iPlayersNum = gAlive()
	 	
			newid = gRandomAlive(random_num(1, iPlayersNum))
			  
			get_user_name( id, szName, 31 )
			get_user_name( newid, szNewName, 31 )
	
			infect_user(newid)
			client_printc(0, "!g[CSO]!n Player %s has left, %s is the new zombie!", szName, szNewName)
		}
	}
	else
	{
		if(!fnGetHumans() && iPlayersnum >= 2 && g_roundstart)
		{
			client_printc(0, "!g[CSO]!n Last human has disconnected. Restarting Round..")
			set_task(1.0, "logevent_round_end")
		}
	}
}
public client_crsis(id, is_spawning)
{
	RemoveBurnEntity(id)
	if(task_exists(id+TASKID_REMOVE_BURN))
		remove_task(id+TASKID_REMOVE_BURN)
	if(task_exists(id+TASK_SPAWN))
		remove_task(id+TASK_SPAWN)
	if(task_exists(id+TASK_BLOOD))
		remove_task(id+TASK_BLOOD)
	set_user_rendering(id)
	if(g_sprintzm[id])
		g_sprintzm[id] = false
	if(g_using_ab[id])
		g_using_ab[id] = false
	if(g_mode[id] != 0)
		g_mode[id] = 0
	if(g_primaryattack[id] != 0)
		g_primaryattack[id] = 0
	if(g_buffed[id])
		g_buffed[id] = false
	if(!is_spawning)
	{
		if(task_exists(id+TASK_RESTORE_MONEY))
			remove_task(id+TASK_RESTORE_MONEY)
		if(task_exists(id+TASK_TEAM))
			remove_task(id+TASK_TEAM)	
	}
}
public fw_PlayerKilled(id, attacker, shouldgib)
{
	if(fnGetHumans() > 1 && is_user_valid_connected(id))
	{
		if(!task_exists(id+TASK_SPAWN))
		{
			set_task(get_pcvar_float(cvar_spawndelay), "respawn_player_task", id+TASK_SPAWN)
			client_printc(id, "!g[CSO]!n You will respawn within' couple seconds...")
		}
	}
	else
	{
		client_printc(id, "!g[CSO]!n Due to some reasons, you are unable to respawn.")
	}
	if (g_bNvgOn[id])
	{
		g_bNvgOn[id] = false
		Set_MapLightStyle(id, g_szLightStyle)
		Set_NightVision(id, 0, 0, 0x0000, 0, 0, 0, 0)
	}

	remove_task(id+TASKID_REMOVE_BURN)
	RemoveBurnEntity(id)	
}
public respawn_player_task(taskid)
{
	static id
	id = taskid-TASK_SPAWN

	ExecuteHamB(Ham_CS_RoundRespawn, id)
	remove_task(taskid)
}
public event_round_start()
{
	client_cmd(0, "stopsound")
	g_endround = false
	g_startround = true
	g_roundstart = false
	
	client_printc(0, "!g[CSO]!n This game mode has been created by %s", AUTHOR)
	client_printc(0, "!g[CSO]!n Press !t[B] !nor type !t/buy !nto open the buy menu before the round starts.")
	/*
	if(round_count >= 1)
	{*/
		if(task_exists(1603))
			remove_task(1603)
		if(task_exists(1604))
			remove_task(1604)
		if(task_exists(1501))
			remove_task(1501)
		set_task(2.0, "round_song")
		set_task(2.0 + get_pcvar_float(cvar_delay), "gaming_game", 1604)
		// countdown
		countdown_timer = 21-1
		set_task(2.0, "make_countdown", 1603); 
		g_freeround = false
	}/*
	else
	{
		client_printc(0, "!g[CSO]!n The game will start after 30 seconds.")
		g_freeround = true
		count_new = 31-1
		set_task(2.0, "new_round_count", 1501)
	}*/
	round_count++
}
public play_countdown(id)
{
	if(!is_user_valid_connected(id))
		return

	client_cmd(id, "spk zm_cso/countdown.wav")
}
public gaming_game()
{
	set_task(2.0, "bruh_forward", 987256)

	start_game(0)
	remove_task(1604)
}
public bruh_forward()
{
	for (new id = 1; id <= g_iMaxClients; id++)
	{
		static forward_id
		forward_id = id

		ExecuteForward(g_fwRoundStart, g_fwDummyResult, forward_id);
	}
	remove_task(987256)
}
public new_round_count()
{
	new speak[10][] = 
	{
		"vox/one.wav",
		"vox/two.wav",
		"vox/three.wav",
		"vox/four.wav",
		"vox/five.wav",
		"vox/six.wav",
		"vox/seven.wav",
		"vox/eight.wav",
		"vox/nine.wav",
		"vox/ten.wav"
	}
	if(count_new <= 10)
		client_cmd(0, "spk %s", speak[count_new-1])
	set_hudmessage(213, 85, 0, -1.0, -1.0, 0, 6.0, 1.0)
	show_hudmessage(0, "Round Restart in [%d]", count_new)
	count_new--
	if(count_new != 0)
		set_task(1.0, "new_round_count", 1501)
	else
	{
		remove_task(1501)
		logevent_round_end()
		for (new id = 1; id <= g_iMaxClients; id++)
		{
				set_pev(id, pev_gravity, 1.0)
				client_print(id, print_center, "Time to start the game")
				client_printc(id, "!g[CSO]!n Game is starting, get ready.")
		}
	}
}
public make_countdown() {

	--countdown_timer

	for(new i = 0; i < g_iMaxClients; i++)
	{
		if(!is_user_valid_connected(i))
			continue

		if(countdown_timer <= 10)
		{
			if(countdown_timer == 10)
				play_countdown(i)

			message_begin(MSG_ONE, g_msgScreenShake, _, i)
			write_short(UNIT_SECOND*4)		
			write_short(UNIT_SECOND*2)
			write_short(UNIT_SECOND*10)
			message_end()

			client_print(i, print_center, "Zombies Appear in %d seconds", countdown_timer)
		}
	}
	if(countdown_timer != 0)
	{
		set_task(1.0, "make_countdown", 1603);
	}
	else
	{
		remove_task(1603)
	}
}
public start_game(player_id)
{
	static iPlayersNum, iZombies, iMaxZombies, iPlayersnum, id

	iPlayersNum = gAlive()
	iPlayersnum = fnGetAlive()
	id = gRandomAlive(random_num(1, iPlayersNum))
	
	if(iPlayersnum >= 7)
	{	
		// iMaxZombies is rounded up, in case there aren't enough players
		iMaxZombies = floatround(iPlayersnum * get_pcvar_float(cvar_multiratio), floatround_ceil)
		iZombies = 0
		
		// Randomly turn iMaxZombies players into zombies
		while (iZombies < iMaxZombies)
		{
			// Keep looping through all players
			if (++player_id > g_iMaxClients) 
				player_id = 1
			
			// Dead or already a zombie
			if (!is_user_alive(player_id) || g_zombie[player_id])
				continue;
			
			// Random chance
			if (random_num(0, 1))
			{
				// Turn into a zombie
				infect_user(player_id)
				iZombies++
				fm_set_user_health(player_id, 10000)
			}
		}
		check_teams()
		client_print(0, print_center, "Zombies Appear!")
		g_startround = false
	}
	else if(iPlayersnum >= 2){
		infect_user(id)
		fm_set_user_health(id, 15000)
		check_teams()
		client_print(0, print_center, "Zombies Appear!")
		g_startround = false
	}
	else
	{
		client_print(0, print_center, "No Enough Players to Start The Game")
	}
	if(iPlayersnum >= 5)
	{
		new idZ
		static iPlayersNumZ
		iPlayersNumZ = gAliveZ()
		
		idZ = gRandomAliveZ(random_num(1, iPlayersNumZ))
		make_user_hero(idZ)
	}
	else
	{
		client_printc(0, "!g[CSO]!n A hero or heroine will be picked if there is 10 players.")
	}
	g_roundstart = true
	client_cmd(0,"mp3 play sound/zm_cso/ambience.mp3")
}
public make_user_hero(id)
{
	fm_set_user_health(id, 1000)
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	fm_give_item(id, "weapon_hegrenade")
	set_user_armor(id, 300)	
	//give_weapon_infi(id)
	give_weapon_ddeagle(id)
	new Random = random(2)
	new name[32]
	get_user_name(id, name, 31)
	switch(Random)
	{
		case 0 :
		{
			cs_set_player_model(id, "legendofwarior_humans")
			set_pev(id, pev_body, 11)
			give_weapon_svdex(id)
			g_type[id] = hero
			g_playersex[id] = male
			client_printc(0, "!g[CSO]!n !t%s !nhas been chosen as a !tHero!n!", name)
		}
		case 1 :
		{
			cs_set_player_model(id, "legendofwarior_females")
			set_pev(id, pev_body, 6)
			g_type[id] = heroine
			g_playersex[id] = female
			give_weapon_dualkriss(id)
			client_printc(0, "!g[CSO]!n !t%s !nhas been chosen as a !tHero!n!", name)
		}
	}
}
public round_song()
{
	client_cmd(0, "spk zm_cso/20sec.wav")
	set_task(2.0, "play_song")
}
public play_song()
{
	new Random = random(3)
	switch(Random)
	{
		case 0 : client_cmd(0, "spk zm_cso/roundstart.wav")
		case 1 : client_cmd(0, "spk zm_cso/roundstart2.wav")
		case 2 : client_cmd(0, "spk zm_cso/roundstart3.wav")
	}
}
/* External Functions */
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type) 
{
	if(g_startround)
		return HAM_SUPERCEDE;
		
	if (victim == attacker)
		return HAM_IGNORED;
		
	if (g_endround)
		return HAM_SUPERCEDE;
		
	if (g_nodamage[victim])
	         return HAM_SUPERCEDE;
		
	if (!is_user_valid_connected(victim) || !is_user_valid_connected(attacker))
		return HAM_IGNORED;
		 
	if(damage_type & DMG_FALL)
	{
		if(get_user_flags(victim) & ADMIN_LEVEL_H && !g_zombie[victim])
			return HAM_SUPERCEDE;
		else
			return HAM_IGNORED
	}
	switch(g_levelprotection[victim])
	{
		case 1 : damage *= 1.0
		case 2 : damage *= 0.95
		case 3 : damage *= 0.90
		case 4 : damage *= 0.85
		case 5 : damage *= 0.80
		case 6 : damage *= 0.75
		case 7 : damage *= 0.70
		case 8 : damage *= 0.65
		case 9 : damage *= 0.60
		case 10 : damage *= 0.50
		default : damage *= 1.0
	}
	new Float:damageprowess
	switch(g_levelprowess[attacker])
	{
		case 1 : damageprowess = 1.0
		case 2 : damageprowess = 1.25
		case 3 : damageprowess = 1.5
		case 4 : damageprowess = 2.0
		case 5 : damageprowess = 2.5
		case 6 : damageprowess = 3.0
		case 7 : damageprowess = 3.5
		case 8 : damageprowess = 4.0
		case 9 : damageprowess = 4.5
		case 10 : damageprowess = 5.0
		default : damageprowess = 1.0
	}
	new Float:damagemarks
	switch(g_levelmarksmanship[attacker])
	{
		case 1 : damagemarks = 1.0
		case 2 : damagemarks = 1.05
		case 3 : damagemarks = 1.10
		case 4 : damagemarks = 1.15
		case 5 : damagemarks = 1.20
		case 6 : damagemarks = 1.25
		case 7 : damagemarks = 1.30
		case 8 : damagemarks = 1.35
		case 9 : damagemarks = 1.40
		case 10 : damagemarks = 1.50
		default : damagemarks = 1.0
	}
	if(!g_zombie[attacker])
	{
		g_damagedealt[attacker] += floatround(damage)
		while (g_damagedealt[attacker] > 300)
		{
			if(get_user_flags(attacker) & ADMIN_LEVEL_H)
			{
				g_iExp[attacker] += 2
				g_CSOMoney[attacker] += 200
			}
			else
			{
				g_iExp[attacker] += 1
				g_CSOMoney[attacker] += 100
			}
			check_level(attacker)
			g_damagedealt[attacker] -= 300
		}
	}
	if(g_zombie[attacker] && !g_zombie[victim])
	{
		if(fnGetHumans() != 1)
		{
			static Float:armor
			pev(victim, pev_armorvalue, armor)

			if (armor > 0.0)
			{
				emit_sound(victim, CHAN_BODY, sound_armorhit, 1.0, ATTN_NORM, 0, PITCH_NORM)
				set_pev(victim, pev_armorvalue, floatmax(0.0, armor - damage))
				return HAM_SUPERCEDE;
			}

			infect_user(victim)
			fm_give_item(attacker, "weapon_hegrenade")
			fm_set_user_health(attacker, get_user_health(attacker) + 500)
			message_begin(MSG_BROADCAST, g_msgDeathMsg)
			write_byte(attacker) // killer
			write_byte(victim) // victim
			write_byte(random_num(0,1)) // headshot flag
			write_string("knife") // killer's weapon
			message_end()
			
			message_begin(MSG_BROADCAST, g_msgScoreAttrib)
			write_byte(victim) // id
			write_byte(0) // attrib
			message_end()
			
			UpdateFrags(attacker, victim, 1, 1, 1)
			
			if(get_user_flags(attacker) & ADMIN_LEVEL_H)
			{
				g_iExp[attacker] += 6
				g_CSOMoney[attacker] += 1000
			}
			else
			{
				g_iExp[attacker] += 3
				g_CSOMoney[attacker] += 500
			}
			check_level(attacker)
		
			return HAM_SUPERCEDE;
		}
		else
		{
			client_print(attacker, print_center, "Health : %d", get_user_health(victim) - floatround(damage))
			SetHamParamFloat(4, damage * damageprowess);
		}
	}
	else if(!g_zombie[attacker] && g_zombie[victim])
	{
		if (is_user_valid_connected(inflictor) && get_user_weapon(inflictor) == CSW_KNIFE)
		{
			if(g_knife[attacker] == strong)
			{
				if(g_attack_type[attacker] == ATTACK_SLASH)
					SetHamParamFloat(4, damage * get_pcvar_float(cvar_strong_dmg) * damageprowess);
				else if(g_attack_type[attacker] == ATTACK_STAB)
					SetHamParamFloat(4, get_pcvar_float(cvar_strong_stab) * damageprowess);
			}
			else if(g_knife[attacker] == katana)
				SetHamParamFloat(4, damage * get_pcvar_float(cvar_katana_dmg) * damageprowess);
			else if(g_knife[attacker] == axe)
				SetHamParamFloat(4, damage * get_pcvar_float(cvar_axe_dmg) * damageprowess);
			else if(g_knife[attacker] == combat)
				SetHamParamFloat(4, damage * get_pcvar_float(cvar_combat_dmg) * damageprowess);
			else if(g_knife[attacker] == hammer)
			{
				if(g_mode[attacker])
					SetHamParamFloat(4, damage * get_pcvar_float(cvar_hammer_dmg2) * 2 * damageprowess)
				else
					SetHamParamFloat(4, damage * get_pcvar_float(cvar_hammer_dmg) * 4 * damageprowess)
			}

		}
		else if(is_user_valid_connected(inflictor))
			SetHamParamFloat(4, damage * damagemarks)
		client_print(attacker, print_center, "Health : %d", get_user_health(victim) - floatround(damage))
	}
	if(!task_exists(attacker+TASK_RESTORE_MONEY))  
		set_task(0.1,"restore_player_money",attacker+TASK_RESTORE_MONEY)
	return HAM_IGNORED
}
// Ham Take Damage Post Forward
public fw_TakeDamage_Post(victim)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(victim) != PDATA_SAFE)
		return;
}
public fw_TraceAttack(victim, attacker, Float:damage, Float:direction[3], tracehandle, damage_type) {
	if(g_startround)
		return HAM_SUPERCEDE;
		
	if (victim == attacker)
		return HAM_IGNORED;
		
	if (g_endround)
		return HAM_SUPERCEDE;
		
	if (g_nodamage[victim])
	         return HAM_SUPERCEDE;
		 
	if (!is_user_valid_connected(victim) || !is_user_valid_connected(attacker))
		return HAM_IGNORED;
		 
	static origin1[3], origin2[3]
	get_user_origin(victim, origin1)
	get_user_origin(attacker, origin2)
	
	// Get victim's velocity
	static Float:velocity[3]
	pev(victim, pev_velocity, velocity)
	
	// Max distance exceeded
	if (get_distance(origin1, origin2) > get_pcvar_num(cvar_knockbackdist))
		return HAM_IGNORED;
		
	if (g_zombie[victim])
	{
		if(g_playerclass[victim] == deimos || g_playerclass[victim] == yaksha)
			xs_vec_mul_scalar(direction, get_pcvar_float(cvar_zmknockback) / 3, direction)
		else
			xs_vec_mul_scalar(direction, get_pcvar_float(cvar_zmknockback), direction)
	}
	xs_vec_add(velocity, direction, direction)
	set_pev(victim, pev_velocity, direction)
	return HAM_IGNORED
}
public fw_TouchWeapon(weapon, id)
{
	// Not a player
	if (!is_user_valid_connected(id))
		return HAM_IGNORED;
		
	if(g_zombie[id])
		return HAM_SUPERCEDE;
		
	return HAM_IGNORED;
}
/* Knives Time */
public fw_HammerKnifeIdle(Weapon)
{
	new id = get_pdata_cbase(Weapon, 41, 4)
	
	if(!is_user_alive(id) || g_zombie[id] || g_knife[id] != hammer)
		return HAM_IGNORED;

	if(g_mode[id] == 2 || g_mode[id] == 3 || g_mode[id] == 4 || g_primaryattack[id]) 
		return HAM_SUPERCEDE;

	if(g_mode[id] == 1) 
	{
		util_playweaponanimation(id, ANIM_IDLESTAB)
		return HAM_SUPERCEDE;
	}

	return HAM_IGNORED;
}
public fw_primarynnKnifeAttack(Weapon)
{
	new id = get_pdata_cbase(Weapon, 41, 4)
	
	if(!is_user_alive(id) || g_zombie[id])
		return HAM_IGNORED;
	
	if(g_knife[id] == strong)
		set_player_nextattack(id, 1.20)
	else if(g_knife[id] == axe)
		set_player_nextattack(id, 0.85)
	else if(g_knife[id] == combat)
		set_player_nextattack(id, 0.87)
	else if(g_knife[id] == katana)
		set_player_nextattack(id, 1.15)
	else if(g_knife[id] == hammer)
	{
		set_player_nextattack(id, 1.25)
		if(g_mode[id])
		{
			util_playweaponanimation(id, ANIM_STAB)
			set_pdata_float(id, m_flNextAttack, 2.0, PLAYER_LINUX_XTRA_OFF, 5)
		}

	}
	return HAM_IGNORED;
}
public fw_SecondaryKnifeAttack(Weapon)
{
	new id = get_pdata_cbase(Weapon, 41, 4)
	
	if(!is_user_alive(id) || g_zombie[id])
		return HAM_IGNORED;
		
	if(g_knife[id] == strong)
		set_player_nextattack(id, 1.65)
	else if(g_knife[id] == axe)
		set_player_nextattack(id, 0.25)
	else if(g_knife[id] == combat)
		set_player_nextattack(id, 0.28)
	else if(g_knife[id] == katana)
		set_player_nextattack(id, 1.55)
	return HAM_IGNORED;
}
public check_teams()
{
	static team[33], id
	// Turn the remaining players into humans
	for (id = 1; id <= g_iMaxClients; id++)
	{
		team[id] = fm_cs_get_user_team(id)
		
		// Skip if not playing
		if (team[id] == FM_CS_TEAM_SPECTATOR || team[id] == FM_CS_TEAM_UNASSIGNED)
			continue;
			
		// Only those of them who aren't zombies
		if (!is_user_alive(id) || g_zombie[id])
			continue;

		// Switch to CT
		if (fm_cs_get_user_team(id) != FM_CS_TEAM_CT) // need to change team?
		{
			remove_task(id+TASK_TEAM)
			fm_cs_set_user_team(id, FM_CS_TEAM_CT)
			fm_user_team_update(id)
		}
	}

}
/* ShowHUD */
public ShowHUD(taskid)
{
	static id
	id = ID_SHOWHUD;

	if(!is_user_valid_connected(id))
		return;
	
	// Player died?
	if (!is_user_alive(id))
	{
		// Get spectating target
		id = pev(id, PEV_SPEC_TARGET)
		
		// Target not alive
		if (!is_user_alive(id)) return;
	}

	new szClass[60]
	if (g_zombie[id])
	{
		switch(g_playerclass[id])
		{
			case light: szClass = "Light"
			case normal: szClass = "Psycho"
			case china: szClass = "Chinese"
			case voodoo: szClass = "Voodoo"
			case deimos: szClass = "Deimos"
			case yaksha: szClass = "YAKSHA"
		}
	}
	else
	{
		if (g_type[id] == hero)
			szClass = "Hero"
		else if (g_type[id] == heroine)
			szClass = "Heroine"
		else
			szClass = "Human"
	}

	set_dhudmessage(random(255), random(255), random(255), -1.0, 0.0, 0, 6.0, 1.1, 0.0, 0.0);
	show_dhudmessage(id, "[%s%d] ZB ( %i ) HM [%s%d]^nROUND", g_ZBScore >= 10 ? "" : "0", g_ZBScore, round_count, g_HMScore >= 10 ? "" : "0", g_HMScore);	

	set_dhudmessage(255, 0, 0, 0.02, 0.9, 0, 6.0, 1.0)
	show_dhudmessage(id, "Health: %d || Levels: %d/100 || XP: %d/%d || Class : %s", get_user_health(id), g_iLevel[id], g_iExp[id], MAX_LEVELS[g_iLevel[ id ]], szClass)
}
/* Menu */
public clcmd_changeteam(id)
{
	static team
	team = fm_cs_get_user_team(id)
	
	// Unless it's a spectator joining the game
	if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
		return PLUGIN_CONTINUE;
	
	// Pressing 'M' (chooseteam) ingame should show the main menu instead
	show_game_menu(id)
	return PLUGIN_HANDLED;
}
public show_shop_menu(id) {
	
	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\yMysterious Store^n^n")
	// Items
	if(g_CSOMoney[ id ] >= 100)
		len += formatex(menu[len], charsmax(menu) - len, "\r1.\w Ammunition \y[100$]^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r1.\d Ammunition \y[100$]^n")
	if(g_CSOMoney[ id ] >= 800)
		len += formatex(menu[len], charsmax(menu) - len, "\r2.\w M67 Grenade \y[800$]^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r2.\d M67 Grenade \y[800$]^n")
	if(g_CSOMoney[ id ] >= 1200)
		len += formatex(menu[len], charsmax(menu) - len, "\r3.\w Holy Water Bottle \y[1200$]^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r3.\d Holy Water Bottle \y[1200$]^n")
	if(g_CSOMoney[ id ] >= 3000)
		len += formatex(menu[len], charsmax(menu) - len, "\r4.\w +10 EXP \y[3000$]^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r4.\d +10 EXP \y[3000$]^n")
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		if(g_CSOMoney[ id ] >= 20000)
			len += formatex(menu[len], charsmax(menu) - len, "\r5.\w Hero Pack \y[20000$] \rVIP Only^n")
		else
			len += formatex(menu[len], charsmax(menu) - len, "\r5.\d Hero Pack \y[20000$] \rVIP Only^n")
	}
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r5.\d Hero Pack \y[20000$] \rVIP Only^n")
		
	if(g_CSOMoney[ id ] >= 25000)
		len += formatex(menu[len], charsmax(menu) - len, "\r6.\w +100 EXP \y[25000$]")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r6.\d +100 EXP \y[25000$]")
	
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\r0.\y Exit")
	 
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	show_menu(id, KEYSMENU, menu, -1, "Shop Menu")
}
public menu_shop(id, key) {
	if(g_zombie[id])
		return PLUGIN_HANDLED
		
	static weapon, maxclip, ent, weaponname[32]
		
	switch (key)
	{
	    case 0:
		{
			if(g_CSOMoney[ id ] >= 100)
			{
				weapon = get_user_weapon(id)
				maxclip = g_weapon_ammo[weapon][MAX_CLIP]
				if(maxclip)
				{
					get_weaponname(weapon, weaponname, 31)
					ent = fm_find_ent_by_owner(-1, weaponname, id)
						
					fm_set_weapon_ammo(ent, maxclip)
					
					emit_sound(id, CHAN_ITEM, sound_buyammo, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}
				g_CSOMoney[ id ] -= 100
				cso_update_user_money(id)
			}
			else
				cso_blink_money(id)
		}
	    case 1:
		{
			if(g_CSOMoney[ id ] >= 800)
			{
				fm_give_item(id, "weapon_hegrenade")
				g_CSOMoney[ id ] -= 800
				cso_update_user_money(id)
			}
			else
				cso_blink_money(id)
		}
		case 2:
		{
			if(g_CSOMoney[ id ] >= 1200)
			{
				fm_give_item(id, "weapon_flashbang")
				g_CSOMoney[ id ] -= 1200
				cso_update_user_money(id)
			}
			else
				cso_blink_money(id)
		}
		case 3:
		{
			if(g_CSOMoney[ id ] >= 3000)
			{
				g_iExp[id] += 10
				g_CSOMoney[ id ] -= 3000
				check_level(id)
				cso_update_user_money(id)
			}
			else
				cso_blink_money(id)
		}
		case 4:
		{
			if(get_user_flags(id) & ADMIN_LEVEL_H)
			{
				if(g_CSOMoney[ id ] >= 20000)
				{
					make_user_hero(id)
					g_CSOMoney[ id ] -= 20000
					cso_update_user_money(id)
				}
				else
					cso_blink_money(id)
			}
		}
		case 5:
		{
			if(g_CSOMoney[ id ] >= 25000)
			{
				g_iExp[id] += 100
				g_CSOMoney[ id ] -= 25000
				check_level(id)
				cso_update_user_money(id)
			}
			else
				cso_blink_money(id)
		}
	}
	return PLUGIN_HANDLED;
}
public show_upgrade_menu(id) 
{
	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\yUpgrade your Stats \r|| \wLevels \r: \y%d\r/\y100 \r- \y%d\r/\y%d \wXP^n", g_iLevel[id], g_iExp[id], MAX_LEVELS[g_iLevel[ id ]])
	len += formatex(menu[len], charsmax(menu) - len, "\yYou have \r%d points \yto spend!^n^n", g_levelpoints[id])
	// Items
	if(g_levelpoints[id] >= 2 && g_levelprowess[id] < 10)
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r1\y]. [HB/ZB]\w Physical Prowess\y++^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r1\y]. [HB/ZB]\d Physical Prowess^n")
	if(g_levelpoints[id] >= 2 && g_levelprotection[id] < 10)
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r2\y]. [HB/ZB]\w Physical Protection\y++^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r2\y]. [HB/ZB]\d Physical Protection^n")
	if(g_levelpoints[id] >= 2 && g_levelswiftness[id] < 10)
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r3\y]. [HB/ZB]\w Physical Swiftness\y++^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r3\y]. [HB/ZB]\d Physical Swiftness^n")
	if(g_levelpoints[id] >= 2 && g_levelmarksmanship[id] < 10)
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r4\y]. [HB/ZB]\w Marksmanship\y++^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r4\y]. [HB/ZB]\d Marksmanship^n")
	if(g_levelpoints[id] >= 2 && g_levelhealth[id] < 10)
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r5\y]. [HB/ZB]\w Bonus Health\y++^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r5\y]. [HB/ZB]\d Bonus Health^n")
	len += formatex(menu[len], charsmax(menu) - len, "^n^n^n\y[\r9\y]. \wGo Back^n")
	len += formatex(menu[len], charsmax(menu) - len, "\y[\r0\y].\y Exit")
	 
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	show_menu(id, KEYSMENU, menu, -1, "Upgrade Menu")
}
public upgrade_game(id, key) {
	switch (key)
	{
		case 0:
		{
			if(g_levelpoints[id] >= 2 && g_levelprowess[id] < 10) {
				g_levelprowess[id]++
				g_levelpoints[id] -= 2
				client_printc(id, "!g[CSO]!n Your !tPhysical Prowess!n has been increased!")
			}
			else
				client_printc(id, "!g[CSO]!n Insufficient level points.")
			show_upgrade_menu(id) 
		}
		case 1:
		{
			if(g_levelpoints[id] >= 2 && g_levelprotection[id] < 10) {
				g_levelprotection[id]++
				g_levelpoints[id] -= 2
				client_printc(id, "!g[CSO]!n Your !tPhysical Protection!n has been increased!")
			}
			else
				client_printc(id, "!g[CSO]!n Insufficient level points.")
			show_upgrade_menu(id) 
		}
		case 2:
		{
			if(g_levelpoints[id] >= 2 && g_levelswiftness[id] < 10) {
				g_levelswiftness[id]++
				g_levelpoints[id] -= 2
				client_printc(id, "!g[CSO]!n Your !tPhysical Swiftness!n has been increased!")
			}
			else
				client_printc(id, "!g[CSO]!n Insufficient level points.")
			show_upgrade_menu(id) 
		}
		case 3:
		{
			if(g_levelpoints[id] >= 2 && g_levelmarksmanship[id] < 10) {
				g_levelmarksmanship[id]++
				g_levelpoints[id] -= 2
				client_printc(id, "!g[CSO]!n Your !tMarksmanship!n has been increased!")
			}	
			else
				client_printc(id, "!g[CSO]!n Insufficient level points.")
			show_upgrade_menu(id) 
		}
		case 4:
		{
			if(g_levelpoints[id] >= 2 && g_levelhealth[id] < 10) {
				g_levelhealth[id]++
				g_levelpoints[id] -= 2
				client_printc(id, "!g[CSO]!n Your !tHealth!n has been increased!")
			}
			else
				client_printc(id, "!g[CSO]!n Insufficient level points.")
			show_upgrade_menu(id) 
		}
	    case 8:
		{
			show_enhance_menu(id) 
		}
	}
	return PLUGIN_HANDLED;
}
public show_enhance_menu(id) 
{
	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\yPlayer Enhancement \r|| \wLevels \r: \y%d\r/\y100 \r- \y%d\r/\y%d \wXP^n", g_iLevel[id], g_iExp[id], MAX_LEVELS[g_iLevel[ id ]])
	len += formatex(menu[len], charsmax(menu) - len, "\yYou have \r%d points^n^n", g_levelpoints[id])
	// Items
	len += formatex(menu[len], charsmax(menu) - len, "\r[HB/ZB]\w Physical Prowess : \r%d/10^n", g_levelprowess[id])
	len += formatex(menu[len], charsmax(menu) - len, "\r[HB/ZB]\w Physical Protection : \r%d/10^n", g_levelprotection[id])
	len += formatex(menu[len], charsmax(menu) - len, "\r[HB/ZB]\w Physical Swiftness : \r%d/10^n", g_levelswiftness[id])
	len += formatex(menu[len], charsmax(menu) - len, "\r[HB/ZB]\w Marksmanship : \r%d/10^n", g_levelmarksmanship[id])
	len += formatex(menu[len], charsmax(menu) - len, "\r[HB/ZB]\w Bonus Health : \r%d/10^n", g_levelhealth[id])
	len += formatex(menu[len], charsmax(menu) - len, "^n^n^n\y[\r9\y]. \y[\w---INCREASE STATS---\y]^n")
	len += formatex(menu[len], charsmax(menu) - len, "\y[\r0\y].\y Exit")
	 
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	show_menu(id, KEYSMENU, menu, -1, "Enhance Menu")
}
public enhance_game(id, key) {
	switch (key)
	{
		case 0..7:
		{
			show_enhance_menu(id) 
		}
	    case 8:
		{
			show_upgrade_menu(id)
		}
	}
	return PLUGIN_HANDLED;
}
public show_game_menu(id) 
{
	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\rCSO.\yGAMERCLUB\r.net^n")
	len += formatex(menu[len], charsmax(menu) - len, "\wGame Menu^n^n")
	// Items
	len += formatex(menu[len], charsmax(menu) - len, "\y[\r1\y].\w Choose Zombie Class^n")

	len += formatex(menu[len], charsmax(menu) - len, "\y[\r2\y].\d Quest Menu \r(soon)^n")

	len += formatex(menu[len], charsmax(menu) - len, "\y[\r3\y].\w Player Enhancement^n")
	if(get_user_flags(id) & ADMIN_KICK)
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r4\y].\w Join Spectator \y[\rHELPER\y]^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r4\y].\d Join Spectator \y[\rHELPER\y]^n")
	len += formatex(menu[len], charsmax(menu) - len, "^n^n^n\y[\r0\y].\y Exit")
	 
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	show_menu(id, KEYSMENU, menu, -1, "Game Menu")
}
public menu_game(id, key) {
	switch (key)
	{
	    case 0:
		{
			show_class_menu(id)
		}
		case 1:
		{
			show_game_menu(id)
		}
		case 2:
		{
			show_enhance_menu(id) 
		}
		case 3:
		{
			if(get_user_flags(id) & ADMIN_KICK)
			{
				dllfunc(DLLFunc_ClientKill, id)
				fm_cs_set_user_team(id, FM_CS_TEAM_SPECTATOR)
				fm_user_team_update(id)
			}
			else
				show_game_menu(id)
		}
	}
	return PLUGIN_HANDLED;
}
public show_class_menu(id) {
	
	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\rCSO.\yGAMERCLUB\r.net^n")
	len += formatex(menu[len], charsmax(menu) - len, "\wPick a Class^n^n")
	// Items
	len += formatex(menu[len], charsmax(menu) - len, "\y[\r1\y].\w Light \d: \rInvisibility \r(soon)^n")
	len += formatex(menu[len], charsmax(menu) - len, "\y[\r2\y].\w Pyscho \d: \rSmoke^n")
	len += formatex(menu[len], charsmax(menu) - len, "\y[\r3\y].\w China \d: \rSpeed^n")
	len += formatex(menu[len], charsmax(menu) - len, "\y[\r4\y].\w Voodoo \d: \rHealing^n")
	if(get_user_flags(id) & ADMIN_LEVEL_H)
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r5\y].\w Deimos \d: \rTail\y [\rVIP\y]")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r5\y].\d Deimos \d: \rTail\y [\rVIP\y]")
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\y[\r0\y].\y Exit")
	 
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	show_menu(id, KEYSMENU, menu, -1, "Class Menu")
}
public menu_class(id, key) {
	switch (key)
	{
	    case 0:
		{
			g_nextclass[id] = light
			client_printc(id, "!g[CSO]!n Your next class will be : !tLight Zombie!n!")
		}
	         case 1:
		{
			g_nextclass[id] = normal
			client_printc(id, "!g[CSO]!n Your next class will be : !tPyscho Zombie!n!")
		}
		case 2:
		{
			g_nextclass[id] = china
			client_printc(id, "!g[CSO]!n Your next class will be : !tChina Zombie!n!")
		}
		case 3:
		{
			g_nextclass[id] = voodoo
			client_printc(id, "!g[CSO]!n Your next class will be : !tVoodoo Zombie!n!")
		}
		case 4:
		{
			if(get_user_flags(id) & ADMIN_LEVEL_H)
			{
				g_nextclass[id] = deimos
				client_printc(id, "!g[CSO]!n Your next class will be : !tDeimos Zombie!n!")
			}
		}
	}
	return PLUGIN_HANDLED;
}
public show_knife_menu(id) {
	
	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\yChoose Your Melee^n^n")
	// Items
	len += formatex(menu[len], charsmax(menu) - len, "\r1.\w Nata^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r2.\w Axe^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r3.\w Combat^n")
	if(get_user_flags(id) & ADMIN_LEVEL_H)
		len += formatex(menu[len], charsmax(menu) - len, "\r4.\w Katana \rVIP^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r4.\d Katana \rVIP^n")
	if(get_user_flags(id) & ADMIN_KICK || get_user_flags(id) & ADMIN_LEVEL_H)
		len += formatex(menu[len], charsmax(menu) - len, "\r5.\w Hammer \rHELPER|VIP^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r5.\d Hammer \rHELPER|VIP^n")
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\r0.\w Exit")
	 
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	show_menu(id, KEYSMENU, menu, -1, "Knife Menu")
}
public menu_knife(id, key) {
	if(g_zombie[id])
		return PLUGIN_HANDLED;
		
	switch (key)
	{
		case 0:
		{
			if(get_user_weapon(id) == CSW_KNIFE){
				set_pev(id, pev_viewmodel2, "models/zm_cso/v_strong.mdl")
				set_pev(id, pev_weaponmodel2, "models/zm_cso/p_strong.mdl")
				set_player_nextattack(id, 1.20)
			}
			g_knife[id] = strong
			g_knife_key[id] = 0
			check_weapons_list(id)
			Save_Data(id)
		}
		case 1:
		{
			if(get_user_weapon(id) == CSW_KNIFE){
				set_pev(id, pev_viewmodel2, "models/zm_cso/v_axe.mdl")
				set_pev(id, pev_weaponmodel2, "models/zm_cso/p_axe.mdl")
			}
			g_knife[id] = axe
			g_knife_key[id] = 1
			check_weapons_list(id)
			Save_Data(id)
		}
		case 2:
		{
			if(get_user_weapon(id) == CSW_KNIFE){
				set_pev(id, pev_viewmodel2, "models/zm_cso/v_combat.mdl")
				set_pev(id, pev_weaponmodel2, "models/zm_cso/p_combat.mdl")
			}
			g_knife[id] = combat
			g_knife_key[id] = 2
			check_weapons_list(id)
			Save_Data(id)
		}
		case 3:
		{
			if(get_user_flags(id) & ADMIN_LEVEL_H)
			{
				if(get_user_weapon(id) == CSW_KNIFE){
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_katana.mdl")
					set_pev(id, pev_weaponmodel2, "models/zm_cso/p_katana.mdl")
				}
				g_knife[id] = katana
				g_knife_key[id] = 3
				check_weapons_list(id)
				Save_Data(id)
			}
		}
		case 4:
		{
			if(get_user_flags(id) & ADMIN_KICK || get_user_flags(id) & ADMIN_LEVEL_H)
			{
				if(get_user_weapon(id) == CSW_KNIFE){
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_hammer_csozm.mdl")
					set_pev(id, pev_weaponmodel2, "models/zm_cso/p_hammer.mdl")
				}
				g_knife[id] = hammer
				g_knife_key[id] = 4
				g_mode[id] = 0
				g_primaryattack[id] = 0
				check_weapons_list(id)
				Save_Data(id)
			}
		}
	}
	return PLUGIN_HANDLED;
}
/* Infection Functions */
public infect_user(id)
{
	g_buffed[id] = false
	g_mode[id] = 0
	g_primaryattack[id] = 0
	g_zombie[id] = true
	g_using_ab[id] = true
	set_pev(id, pev_armorvalue, 0.0)
	g_type[id] = player
	drop_weapons(id, 1)
	drop_weapons(id, 2)
	fm_strip_user_weapons(id)
	fm_give_item(id, "weapon_knife")
	set_player_nextattack(id, 2.0)
	set_pev(id, pev_viewmodel2, "models/zm_cso/v_infection.mdl")
	set_pev(id, pev_weaponmodel2, "")
	util_playweaponanimation(id, 0)
	new bonushealth
	switch(g_levelhealth[id])
	{
		case 1 : bonushealth = 0
		case 2 : bonushealth = 250			
		case 3 : bonushealth = 500		
		case 4 : bonushealth = 750
		case 5 : bonushealth = 1000
		case 6 : bonushealth = 1250
		case 7 : bonushealth = 1500
		case 8 : bonushealth = 1750
		case 9 : bonushealth = 2000
		case 10 : bonushealth = 3000
	}
	if(g_nextclass[id] == light)
	{
		new Random = random(2)
		switch(Random)
		{
			case 0 : 
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			case 1 :
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		cs_set_player_model(id, "csozm_ligh")
		fm_set_user_model_index(id, mdl_light)
		g_playerclass[id] = light
		fm_set_user_health(id, 1500 + bonushealth)
		set_pev(id, pev_gravity, 0.575)
		set_pev(id, pev_body, random_num(0, 1))
	}
	else if(g_nextclass[id] == normal)
	{
		new Random = random(3)
		switch(Random)
		{
			case 0 : 
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			case 1 :
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[4], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			case 2 :
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		cs_set_player_model(id, "csozm_psycho")
		fm_set_user_model_index(id, mdl_psy)
		g_playerclass[id] = normal
		fm_set_user_health(id, 1750 + bonushealth)
		set_pev(id, pev_gravity, 0.700)
		set_pev(id, pev_body, random_num(0, 1))
	}
	else if(g_nextclass[id] == china)
	{
		new Random = random(3)
		switch(Random)
		{
			case 0 : 
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			case 1 :
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[4], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			case 2 :
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		cs_set_player_model(id, "csozm_china")
		fm_set_user_model_index(id, mdl_china)
		g_playerclass[id] = china
		fm_set_user_health(id, 2000 + bonushealth)
		set_pev(id, pev_gravity, 0.795)
		set_pev(id, pev_body, 0)
	}
	else if(g_nextclass[id] == voodoo)
	{
		new Random = random(3)
		switch(Random)
		{
			case 0 : 
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			case 1 :
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[4], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			case 2 :
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		cs_set_player_model(id, "csozm_shaman")
		fm_set_user_model_index(id, mdl_shaman)
		g_playerclass[id] = voodoo
		fm_set_user_health(id, 1800 + bonushealth)
		set_pev(id, pev_gravity, 0.750)
		set_pev(id, pev_body, random_num(0, 1))
	}
	else if(g_nextclass[id] == deimos)
	{
		new Random = random(3)
		switch(Random)
		{
			case 0 : 
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			case 1 :
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[4], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			case 2 :
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		cs_set_player_model(id, "csozm_deimos")
		fm_set_user_model_index(id, mdl_deimos)
		g_playerclass[id] = deimos
		fm_set_user_health(id, 2550 + bonushealth)
		set_pev(id, pev_gravity, 0.680)
		set_pev(id, pev_body, 0)
	}
	else if(g_nextclass[id] == yaksha)
	{
		new Random = random(3)
		switch(Random)
		{
			case 0 : 
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			case 1 :
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[4], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
			case 2 :
			{
				emit_sound(id, CHAN_AUTO, InfectSounds[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
			}
		}
		cs_set_player_model(id, "akshazombi_origin")
		fm_set_user_model_index(id, mdl_yaksha)
		g_playerclass[id] = yaksha
		fm_set_user_health(id, 5000 + bonushealth)
		set_pev(id, pev_gravity, 0.720)
		set_pev(id, pev_body, 0)
	}
	set_task(1.5, "check_claws", id)
	
	check_weapons_list(id)
	
	remove_task(id+TASK_TEAM)
	fm_cs_set_user_team(id, FM_CS_TEAM_T)
	fm_user_team_update(id)
	
	 // Get his origin coords
	static iOrigin[3]
	get_user_origin(id, iOrigin)
	
	message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, id)
	write_short(UNIT_SECOND) // duration
	write_short(0) // hold time
	write_short(FFADE_IN) // fade type
	write_byte(230) // r
	write_byte(0) // g
	write_byte(0) // b
	write_byte(200) // alpha
	message_end()
	
	Set_NightVision(id, 0, 0, 0x0004, get_pcvar_num(g_pCvarZombieNVisionColors[Red]), get_pcvar_num(g_pCvarZombieNVisionColors[Green]), get_pcvar_num(g_pCvarZombieNVisionColors[Blue]), get_pcvar_num(g_pCvarNVisionDensity))
	Set_MapLightStyle(id, "z")
	g_bNvgOn[id] = true
	
	client_printc(0, "!g[CSO]!n You are a !tZombie!n, Your objective is kill/infect all remaining humans.")
	Update_Attribute(id)
	if(!task_exists(id+TASK_BLOOD))
		set_task(random_float(60.0, 80.0), "zombie_play_idle", id+TASK_BLOOD, _, _, "b")
}
public check_claws(id)
{
	fm_give_item(id, "weapon_hegrenade")
	engclient_cmd(id, "weapon_knife")
	if(g_playerclass[id] == light)
	{
		set_pev(id, pev_viewmodel2, "models/zm_cso/v_zm_light.mdl")
	}
	else if(g_playerclass[id] == normal)
	{
		set_pev(id, pev_viewmodel2, "models/zm_cso/v_zm_pyscho.mdl")
	}
	else if(g_playerclass[id] == china)
	{
		set_pev(id, pev_viewmodel2, "models/zm_cso/v_zm_china.mdl")
	}
	else if(g_playerclass[id] == voodoo)
	{
		set_pev(id, pev_viewmodel2, "models/zm_cso/v_zm_voodoo.mdl")
	}
	else if(g_playerclass[id] == deimos)
	{
		set_pev(id, pev_viewmodel2, "models/zm_cso/v_deimos.mdl")
	}
	else if(g_playerclass[id] == yaksha)
	{
		set_pev(id, pev_viewmodel2, "models/v_knife_zombiaksha.mdl")
	}
	util_playweaponanimation(id, 3)
	g_using_ab[id] = false
}
// Weapons
replace_weapon_models(id, weaponid) {
	switch (weaponid)
	{
		case CSW_KNIFE:
		{
			if(g_zombie[id])
			{
				if(g_playerclass[id] == light)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_zm_light.mdl")
					set_pev(id, pev_weaponmodel2, "")
				}
				else if(g_playerclass[id] == normal)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_zm_pyscho.mdl")
					set_pev(id, pev_weaponmodel2, "")
				}
				else if(g_playerclass[id] == china)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_zm_china.mdl")
					set_pev(id, pev_weaponmodel2, "")
				}
				else if(g_playerclass[id] == voodoo)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_zm_voodoo.mdl")
					set_pev(id, pev_weaponmodel2, "")
				}
				else if(g_playerclass[id] == deimos)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_deimos.mdl")
					set_pev(id, pev_weaponmodel2, "")
				}
				else if(g_playerclass[id] == yaksha)
				{
					set_pev(id, pev_viewmodel2, "models/v_knife_zombiaksha.mdl")
					set_pev(id, pev_weaponmodel2, "")
				}
			}
			else
			{
				if(g_knife[id] == strong)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_strong.mdl")
					set_pev(id, pev_weaponmodel2, "models/zm_cso/p_strong.mdl")
					set_player_nextattack(id, 1.20)
				}
				else if(g_knife[id] == katana)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_katana.mdl")
					set_pev(id, pev_weaponmodel2, "models/zm_cso/p_katana.mdl")
				}
				else if(g_knife[id] == combat)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_combat.mdl")
					set_pev(id, pev_weaponmodel2, "models/zm_cso/p_combat.mdl")
				}
				else if(g_knife[id] == axe)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_axe.mdl")
					set_pev(id, pev_weaponmodel2, "models/zm_cso/p_axe.mdl")
				}
				else if(g_knife[id] == hammer)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_hammer_csozm.mdl")
					set_pev(id, pev_weaponmodel2, "models/zm_cso/p_hammer.mdl")
					if(!g_mode[id]) 
					{
						util_playweaponanimation(id, ANIM_DRAW) 
						set_player_nextattack(id, 1.5)
					}
					else
					{
						util_playweaponanimation(id, ANIM_DRAWSTAB) 
						set_player_nextattack(id, 1.5)
					}
				}
			}
		}
		case CSW_FLASHBANG:
		{
			if(!g_zombie[id])
			{
				set_pev(id, pev_viewmodel2, ViewModelHoly)
				set_pev(id, pev_weaponmodel2, PlayerModelHoly)
			}
		}
		case CSW_HEGRENADE:
		{
			if(!g_zombie[id])
			{
				set_pev(id, pev_viewmodel2, ViewModelFire)
				set_pev(id, pev_weaponmodel2, PlayerModelFire)
			}
			else
			{

				if(g_playerclass[id] == light)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_fast_bomb.mdl")
				}
				else if(g_playerclass[id] == normal)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_psycho_jump_f.mdl")
				}
				else if(g_playerclass[id] == china)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_china_bomb.mdl")
				}
				else if(g_playerclass[id] == voodoo)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_voodoo_bomb.mdl")
				}
				else if(g_playerclass[id] == deimos)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_deimos_jump_f.mdl")
				}
				else if(g_playerclass[id] == yaksha)
				{
					set_pev(id, pev_viewmodel2, "models/zm_cso/v_yaksha_jump_f.mdl")
				}
				set_pev(id, pev_weaponmodel2, "models/zm_cso/p_zombiebomb.mdl")
			}
		}
	}
}
/* Stocks */
stock set_player_nextattack(id, Float:nexttime)
{
	if(!is_user_valid_connected(id))
		return;
		
	set_pdata_float(id, m_flNextAttack, nexttime, PLAYER_LINUX_XTRA_OFF, 5)
}
stock util_playweaponanimation(const Player, const Sequence)
{
	if(!is_user_valid_connected(Player))
		return;
		
	set_pev(Player, pev_weaponanim, Sequence)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
	write_byte(Sequence)
	write_byte(pev(Player, pev_body))
	message_end()
}
gRandomAlive(n)
{
	static Alive, id
	Alive = 0

	for (id = 1; id <= g_iMaxClients; id++)
	{
		if (is_user_alive(id))
			Alive++
		
		if (Alive == n)
			return id;
	}
	return -1;
}
gAlive()
{
	static Alive, id
	Alive = 0
	for (id = 1; id <= g_iMaxClients; id++)
	{
		if (is_user_alive(id))
		{
			Alive++
		}
	}
	return Alive;
}
gRandomAliveZ(n)
{
	static Alive, id
	Alive = 0

	for (id = 1; id <= g_iMaxClients; id++)
	{
		if (is_user_alive(id) && !g_zombie[id])
			Alive++
		
		if (Alive == n)
			return id;
	}
	return -1;
}
gAliveZ()
{
	static Alive, id
	Alive = 0
	for (id = 1; id <= g_iMaxClients; id++)
	{
		if (is_user_alive(id) && !g_zombie[id])
		{
			Alive++
		}
	}
	return Alive;
}
stock fm_cs_get_user_team(id)
{	
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return FM_CS_TEAM_UNASSIGNED;
		
	return get_pdata_int(id, OFFSET_CSTEAMS, OFFSET_LINUX);
}

stock fm_cs_set_user_team(id, team)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
		
	set_pdata_int(id, OFFSET_CSTEAMS, team, OFFSET_LINUX)
}
stock fm_user_team_update(id)
{
	static Float:current_time
	current_time = get_gametime()
	
	if (current_time - g_teams_targettime >= 0.1)
	{
		set_task(0.1, "fm_cs_set_user_team_msg", id+TASK_TEAM)
		g_teams_targettime = current_time + 0.1
	}
	else
	{
		set_task((g_teams_targettime + 0.1) - current_time, "fm_cs_set_user_team_msg", id+TASK_TEAM)
		g_teams_targettime = g_teams_targettime + 0.1
	}
}
// Send User Team Message
public fm_cs_set_user_team_msg(taskid)
{
	// Note to self: this next message can now be received by other plugins
	
	// Set the switching team flag
	g_switchingteam = true
	
	// Tell everyone my new team
	emessage_begin(MSG_ALL, g_MsgTeamInfo)
	ewrite_byte(ID_TEAM) // player
	ewrite_string(CS_TEAM_NAMES[fm_cs_get_user_team(ID_TEAM)]) // team
	emessage_end()
	
	// Done switching team
	g_switchingteam = false
}
stock fm_cs_set_user_deaths(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_CSDEATHS, value, OFFSET_LINUX)
}
fnGetHumans() {
	static iHumans, id
	iHumans = 0
	
	for (id = 1; id <= g_iMaxClients; id++)
	{
		if (is_user_alive(id) && !g_zombie[id])
			iHumans++
	}
	
	return iHumans;
}
stock fm_set_user_health(id, health) {
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)
	
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
}

stock fm_cs_get_weapon_ent_owner(ent)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(ent) != PDATA_SAFE)
		return -1;
	
	return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}
stock fm_cs_get_current_weapon_ent(id)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return -1;
	
	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}
fnGetZombies()
{
	static iZombies, id
	iZombies = 0
	
	for (id = 1; id <= g_iMaxClients; id++)
	{
		if (is_user_alive(id) && g_zombie[id])
			iZombies++
	}
	
	return iZombies;
}
UpdateFrags(attacker, victim, frags, deaths, scoreboard)
{
	// Set attacker frags
	set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) + frags))
	
	// Set victim deaths
	fm_cs_set_user_deaths(victim, cs_get_user_deaths(victim) + deaths)
	
	// Update scoreboard with attacker and victim info
	if (scoreboard)
	{
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(attacker) // id
		write_short(pev(attacker, pev_frags)) // frags
		write_short(cs_get_user_deaths(attacker)) // deaths
		write_short(0) // class?
		write_short(fm_cs_get_user_team(attacker)) // team
		message_end()
		
		message_begin(MSG_BROADCAST, g_msgScoreInfo)
		write_byte(victim) // id
		write_short(pev(victim, pev_frags)) // frags
		write_short(cs_get_user_deaths(victim)) // deaths
		write_short(0) // class?
		write_short(fm_cs_get_user_team(victim)) // team
		message_end()
	}
}
public Save_Data(id)
{
	new vaultkey[64], vaultdata[256], vaultdata2[256], vaultdata3[256], vaultdata4[256], vaultdata5[256],
	lvaultdata1[256], lvaultdata2[256], lvaultdata3[256], lvaultdata4[256], lvaultdata5[256], lvaultdata6[256]

	new AuthID[33];
	get_user_authid(id, AuthID, 32);
			
	formatex(vaultkey, 64, "%s-/", AuthID)

	format(vaultdata, 255, "%i#", g_iExp[id])
	
	format(vaultdata2, 255, "%i#", g_iLevel[id])
	
	format(vaultdata3, 255, "%i#", g_knife_key[id])
	
	format(vaultdata4, 255, "%i#", skin[id])
	
	format(vaultdata5, 255, "%i#", g_CSOMoney[id])
	
	format(lvaultdata1, 255, "%i#", g_levelprowess[id])
	
	format(lvaultdata2, 255, "%i#", g_levelprotection[id])
	
	format(lvaultdata3, 255, "%i#", g_levelswiftness[id])
	
	format(lvaultdata4, 255, "%i#", g_levelmarksmanship[id])
	
	format(lvaultdata5, 255, "%i#", g_levelhealth[id])
	
	format(lvaultdata6, 255, "%i#", g_levelpoints[id])
	
	nvault_set(g_save, vaultkey, vaultdata)
	nvault_set(g_save3, vaultkey, vaultdata2)
	nvault_set(g_save2, vaultkey, vaultdata3)
	nvault_set(g_save4, vaultkey, vaultdata4)
	nvault_set(g_save5, vaultkey, vaultdata5)
	nvault_set(g_lsave1, vaultkey, lvaultdata1)
	nvault_set(g_lsave2, vaultkey, lvaultdata2)
	nvault_set(g_lsave3, vaultkey, lvaultdata3)
	nvault_set(g_lsave4, vaultkey, lvaultdata4)
	nvault_set(g_lsave5, vaultkey, lvaultdata5)
	nvault_set(g_lsave6, vaultkey, lvaultdata6)
	return PLUGIN_CONTINUE;
}
public Load_Data(id)
{
	new vaultkey[64], vaultdata[256], vaultdata2[256], vaultdata3[256], vaultdata4[256], vaultdata5[256],
	lvaultdata1[256], lvaultdata2[256], lvaultdata3[256], lvaultdata4[256], lvaultdata5[256], lvaultdata6[256]
	
	new AuthID[33];
	get_user_authid(id, AuthID, 32);
			
	formatex(vaultkey, 64, "%s-/", AuthID)
	
	format(vaultdata, 255, "%i#", g_iExp[id])
	
	format(vaultdata2, 255, "%i#", g_iLevel[id])
	
	format(vaultdata3, 255, "%i#", g_knife_key[id])
	
	format(vaultdata4, 255, "%i#", skin[id])
	
	format(vaultdata5, 255, "%i#", g_CSOMoney[id])
	
	format(lvaultdata1, 255, "%i#", g_levelprowess[id])
	
	format(lvaultdata2, 255, "%i#", g_levelprotection[id])
	
	format(lvaultdata3, 255, "%i#", g_levelswiftness[id])
	
	format(lvaultdata4, 255, "%i#", g_levelmarksmanship[id])
	
	format(lvaultdata5, 255, "%i#", g_levelhealth[id])
	
	format(lvaultdata6, 255, "%i#", g_levelpoints[id])
	
	nvault_get(g_save, vaultkey, vaultdata, 255)
	nvault_get(g_save3, vaultkey, vaultdata2, 255)
	nvault_get(g_save2, vaultkey, vaultdata3, 255)
	nvault_get(g_save4, vaultkey, vaultdata4, 255)
	nvault_get(g_save5, vaultkey, vaultdata5, 255)
	nvault_get(g_lsave1, vaultkey, lvaultdata1, 255)
	nvault_get(g_lsave2, vaultkey, lvaultdata2, 255)
	nvault_get(g_lsave3, vaultkey, lvaultdata3, 255)
	nvault_get(g_lsave4, vaultkey, lvaultdata4, 255)
	nvault_get(g_lsave5, vaultkey, lvaultdata5, 255)
	nvault_get(g_lsave6, vaultkey, lvaultdata6, 255)
	replace_all(vaultdata, 255, "#", " ")
	replace_all(vaultdata2, 255, "#", " ")
	replace_all(vaultdata3, 255, "#", " ")
	replace_all(vaultdata4, 255, "#", " ")
	replace_all(vaultdata5, 255, "#", " ")
	replace_all(lvaultdata1, 255, "#", " ")
	replace_all(lvaultdata2, 255, "#", " ")
	replace_all(lvaultdata3, 255, "#", " ")
	replace_all(lvaultdata4, 255, "#", " ")
	replace_all(lvaultdata5, 255, "#", " ")
	replace_all(lvaultdata6, 255, "#", " ")
	
	new XP[32], Level[32], Knifas[32], a[32], MoneyL[32],
	L_Prowess[32], L_Protection[32], L_Swiftness[32], L_Marksmanship[32],
	L_Health[32], L_Points[32]
	parse(vaultdata, XP, 31)
	parse(vaultdata2, Level, 31)
	parse(vaultdata3, Knifas, 31)
	parse(vaultdata4, a, 31)
	parse(vaultdata5, MoneyL, 31)
	parse(lvaultdata1, L_Prowess, 31)
	parse(lvaultdata2, L_Protection, 31)
	parse(lvaultdata3, L_Swiftness, 31)
	parse(lvaultdata4, L_Marksmanship, 31)
	parse(lvaultdata5, L_Health, 31)
	parse(lvaultdata6, L_Points, 31)
	g_iExp[id] = str_to_num(XP)
	g_iLevel[id] = str_to_num(Level)
	g_knife_key[id] = str_to_num(Knifas)
	g_CSOMoney[id] = str_to_num(MoneyL)
	g_levelprowess[id] = str_to_num(L_Prowess)
	g_levelprotection[id] = str_to_num(L_Protection)
	g_levelswiftness[id] = str_to_num(L_Swiftness)
	g_levelmarksmanship[id] = str_to_num(L_Marksmanship)
	g_levelhealth[id] = str_to_num(L_Health)
	g_levelpoints[id] = str_to_num(L_Points)
	skin[id] = str_to_num(a)
	
	return PLUGIN_CONTINUE;
}
public Cmd_NvgToggle(id)
{
	if (is_user_alive(id))
	{
		if(g_zombie[id])
		{
			new Float:fReffrenceTime = get_gametime()
			
			if(g_flLastNvgToggle[id] > fReffrenceTime)
				return
			
			// Just Add Delay like in default one in CS and to allow sound complete
			g_flLastNvgToggle[id] = fReffrenceTime + 1.5
			
			if(!g_bNvgOn[id])
			{
				g_bNvgOn[id] = true
				Set_NightVision(id, 0, 0, 0x0004, get_pcvar_num(g_pCvarZombieNVisionColors[Red]), get_pcvar_num(g_pCvarZombieNVisionColors[Green]), get_pcvar_num(g_pCvarZombieNVisionColors[Blue]), get_pcvar_num(g_pCvarNVisionDensity))
				Set_MapLightStyle(id, "z")
			}
			else
			{
				g_bNvgOn[id] = false
				Set_MapLightStyle(id, g_szLightStyle)
				Set_NightVision(id, 0, 0, 0x0000, 0, 0, 0, 0)
			}
		}
	}
}
public zombie_play_idle(taskid)
{
	if (g_endround)
		return;

	static id 
	id = taskid-TASK_BLOOD

	if(g_zombie[id])
	{
		if(g_playerclass[id] == light)
		{
			PlayEmitSound(id, light_idle)
		}
		else
		{
			PlayEmitSound(id, normal_idle)
		}
	}
}
fnGetAlive()
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= g_iMaxClients; id++)
	{
		if (is_user_alive(id))
			iAlive++
	}
	
	return iAlive;
}
stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	new Float:num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num

	return 1
}
PlayEmitSound(id, const sound[])
{
	if(!is_user_valid_connected(id) || !is_user_alive(id))
		return
	emit_sound(id, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}
fm_get_user_startpos(id,Float:forw,Float:right,Float:up,Float:vStart[])
{
	new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_v_angle, vAngle)
	
	engfunc(EngFunc_MakeVectors, vAngle)
	
	global_get(glb_v_forward, vForward)
	global_get(glb_v_right, vRight)
	global_get(glb_v_up, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}
stock fm_set_user_model_index(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_MODELINDEX, value, OFFSET_LINUX)
}  
stock fm_find_ent_by_owner(index, const classname[], owner) 
{
	static ent
	ent = index
	
	while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", classname)) && pev(ent, pev_owner) != owner) {}
	
	return ent
}
stock client_printc(index, const text[], any:...)
{
	if(!is_user_valid_connected(index))
		return;

	new szMsg[128];
	vformat(szMsg, sizeof(szMsg) - 1, text, 3);

	replace_all(szMsg, sizeof(szMsg) - 1, "!g", "^x04");
	replace_all(szMsg, sizeof(szMsg) - 1, "!n", "^x01");
	replace_all(szMsg, sizeof(szMsg) - 1, "!t", "^x03");

	if(index == 0)
	{
		for(new i = 0; i < g_iMaxClients; i++)
		{
			if(!is_user_connected(i))
				continue
			
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, i)
			write_byte(i)
			write_string(szMsg)
			message_end()
		}		
	} else {
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, index);
		write_byte(index);
		write_string(szMsg);
		message_end();
	}
} 
stock Set_MapLightStyle(iIndex, const szMapLightStyle[])
{
	message_begin(MSG_ONE, SVC_LIGHTSTYLE, {0, 0, 0}, iIndex)
	write_byte(0)
	write_string(szMapLightStyle)
	message_end()
}

// Set Player Nightvision
stock Set_NightVision(iIndex, iDuration, iHoldTime, iFlags, iRed, iGreen, iBlue, iAlpha)
{
	message_begin(MSG_ONE, g_msgScreenFade, {0, 0, 0}, iIndex)
	write_short(iDuration)
	write_short(iHoldTime)
	write_short(iFlags)
	write_byte(iRed)
	write_byte(iGreen)
	write_byte(iBlue)
	write_byte(iAlpha)
	message_end()
}
fnGetPlaying()
{
	static iPlaying, id, team
	iPlaying = 0
	
	for (id = 1; id <= g_iMaxClients; id++)
	{
		if (g_isconnected[id])
		{
			team = fm_cs_get_user_team(id)
			
			if (team != FM_CS_TEAM_SPECTATOR && team != FM_CS_TEAM_UNASSIGNED)
				iPlaying++
		}
	}
	
	return iPlaying;
}
balance_teams()
{
	// Get amount of users playing
	static iPlayersnum
	iPlayersnum = fnGetPlaying()
	
	// No players, don't bother
	if (iPlayersnum < 1) return;
	
	// Split players evenly
	static iTerrors, iMaxTerrors, id, team[33]
	iMaxTerrors = iPlayersnum/2
	iTerrors = 0
	
	// First, set everyone to CT
	for (id = 1; id <= g_iMaxClients; id++)
	{
		// Skip if not connected
		if (!g_isconnected[id])
			continue;
		
		team[id] = fm_cs_get_user_team(id)
		
		// Skip if not playing
		if (team[id] == FM_CS_TEAM_SPECTATOR || team[id] == FM_CS_TEAM_UNASSIGNED)
			continue;
		
		// Set team
		remove_task(id+TASK_TEAM)
		fm_cs_set_user_team(id, FM_CS_TEAM_CT)
		team[id] = FM_CS_TEAM_CT
	}
	
	// Then randomly set half of the players to Terrorists
	while (iTerrors < iMaxTerrors)
	{
		// Keep looping through all players
		if (++id > g_iMaxClients) id = 1
		
		// Skip if not connected
		if (!g_isconnected[id])
			continue;
		
		// Skip if not playing or already a Terrorist
		if (team[id] != FM_CS_TEAM_CT)
			continue;
		
		// Random chance
		if (random_num(0, 1))
		{
			fm_cs_set_user_team(id, FM_CS_TEAM_T)
			team[id] = FM_CS_TEAM_T
			iTerrors++
		}
	}
}
stock drop_weapons(id, dropwhat)
{
	// Get user weapons
	static weapons[32], num, i, weaponid
	num = 0 // reset passed weapons count (bugfix)
	get_user_weapons(id, weapons, num)
	
	// Loop through them and drop primaries or secondaries
	for (i = 0; i < num; i++)
	{
		// Prevent re-indexing the array
		weaponid = weapons[i]
		
		if ((dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)) || (dropwhat == 2 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)))
		{
			// Get weapon entity
			static wname[32], weapon_ent
			get_weaponname(weaponid, wname, charsmax(wname))
			weapon_ent = fm_find_ent_by_owner(-1, wname, id)
			
			// Hack: store weapon bpammo on PEV_ADDITIONAL_AMMO
			set_pev(weapon_ent, PEV_ADDITIONAL_AMMO, cs_get_user_bpammo(id, weaponid))
			
			// Player drops the weapon and looses his bpammo
			engclient_cmd(id, "drop", wname)
			cs_set_user_bpammo(id, weaponid, 0)
		}
	}
}
stock fm_strip_user_weapons(id)
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "player_weaponstrip"))
	if (!pev_valid(ent)) return;
	
	dllfunc(DLLFunc_Spawn, ent)
	dllfunc(DLLFunc_Use, ent, id)
	engfunc(EngFunc_RemoveEntity, ent)
}
stock fm_give_item(id, const item[])
{
	static ent
	ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, item))
	if (!pev_valid(ent)) return;
	
	static Float:originF[3]
	pev(id, pev_origin, originF)
	set_pev(ent, pev_origin, originF)
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, ent)
	
	static save
	save = pev(ent, pev_solid)
	dllfunc(DLLFunc_Touch, ent, id)
	if (pev(ent, pev_solid) != save)
		return;
	
	engfunc(EngFunc_RemoveEntity, ent)
}
public cso_get_user_money(id)
{
	return g_CSOMoney[id]
}
public cso_set_user_money(id, value)
{
	g_CSOMoney[id] = value

	message_begin(MSG_ONE_UNRELIABLE, g_MsgMoney, _, id)
	write_long(g_CSOMoney[id])
	write_byte(1)
	message_end()
}
public cso_update_user_money(id)
{
	message_begin(MSG_ONE_UNRELIABLE, g_MsgMoney, _, id)
	write_long(g_CSOMoney[id])
	write_byte(1)
	message_end()
}
public cso_blink_money(id)
{
	message_begin(MSG_ONE_UNRELIABLE, g_msgMoneyBlink, _, id) //HUD
	write_byte(5);
	message_end();
}
public restore_player_money(id)
{
	id-=TASK_RESTORE_MONEY
	
	if(is_user_bot(id))
		set_pdata_int(id,OFFSET_MONEY,16000,OFFSET_LINUX)
	else 
		set_pdata_int(id,OFFSET_MONEY,0,OFFSET_LINUX)
		
	message_begin(MSG_ONE_UNRELIABLE, g_MsgMoney, _, id)
	write_long(g_CSOMoney[id])
	write_byte(1)
	message_end()
		
	if (g_CSOMoney[id] > MAX_MONEY) 
	{
		if(!(get_user_flags(id) & ADMIN_LEVEL_H))
		    {
				g_CSOMoney[id] = MAX_MONEY
		    }
		else
		    if (g_CSOMoney[id] > MAX_MONEY_VIP) 
		    {
				g_CSOMoney[id] = MAX_MONEY_VIP;
		    }
	}
	if (g_CSOMoney[id] < 0) 
		g_CSOMoney[id]=0; 
	message_begin(MSG_ONE_UNRELIABLE, g_MsgMoney, _, id);
	write_long(g_CSOMoney[id]);
	write_byte(1);
	message_end();
}
public cmd_infect(id)
{
	g_nextclass[id] = yaksha
	infect_user(id)
}