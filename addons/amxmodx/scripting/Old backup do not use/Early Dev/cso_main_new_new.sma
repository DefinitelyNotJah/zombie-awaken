#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <fun>
#include <nvault>
#include <reapi>
#include <dhudmessage>

#define PLUGIN "Zombie Awaken"
#define VERSION "1.1"
#define AUTHOR "DefinitelyNotJah"

/*================
======REGISTERS===
================*/

new g_iMaxClients, g_MsgTeamInfo, g_msgDeathMsg, g_msgScreenShake, g_msgScreenFade, gmsgWeaponList, g_msgScoreInfo,
g_msgScoreAttrib, g_msgAmmoPickup, g_save, g_save2, g_save3, g_save4, g_save5, g_roundstart, g_freeround, count_new, g_endround

new in_burn[33], skin[33], g_isconnected[33], g_attack_type[33]
const USE_USING = 2

native cs_set_player_model(id, const model[])

enum
{
	ATTACK_SLASH = 1,
	ATTACK_STAB
}

new mdl_light, mdl_psy, mdl_china, mdl_shaman, mdl_deimos, mdl_males, mdl_females

#define MAX_CLIENTS 32
#define PLAYER_LINUX_XTRA_OFF 5
#define is_user_valid_connected(%1) (1 <= %1 <= g_iMaxClients && g_isconnected[%1])
#define W_Crystal "models/csoleg_crystal.mdl"
#define ClassCrystal "crystal_object"

native give_weapon_svdex(id)
native give_weapon_dualkriss(id)
native cso_open_buy_menu(id)

new const MAX_LEVELS[100] = 
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
	1000
}

new g_iLevel[ MAX_CLIENTS + 1 ], g_iExp[ MAX_CLIENTS + 1 ], g_iCrystal[ MAX_CLIENTS + 1 ]

	
new const g_objective_ents[][] = { "func_bomb_target", "info_bomb_target", "info_vip_start", "func_vip_safetyzone", "func_escapezone", "hostage_entity",
		"monster_scientist", "func_hostage_rescue", "info_hostage_rescue", "env_fog", "env_rain", "env_snow", "item_longjump", "func_vehicle" }
		
#define fm_create_entity(%1) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))
#define fm_remove_entity(%1) engfunc(EngFunc_RemoveEntity, %1)
#define fm_entity_set_model(%1,%2) engfunc(EngFunc_SetModel, %1, %2)

new g_playerclass[33] // Player's Zombie Class
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
new Float:g_buytime[33] // used to calculate custom buytime
new g_knife_key[33] // Used for Autosave!
new g_switchingteam // flag for whenever a player's team change emessage is sent
new g_startround

#define ID_SHOWHUD (taskid - TASK_SHOWHUD)
#define ID_TEAM (taskid - TASK_TEAM)
#define TASKID_BURN 3462
#define TASKID_REMOVE_BURN 3463

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

new Float:g_teams_targettime // for adding delays between Team Change messages

new const CS_TEAM_NAMES[][] = { "UNASSIGNED", "TERRORIST", "CT", "SPECTATOR" }

const PDATA_SAFE = 2
const OFFSET_PAINSHOCK = 108 // ConnorMcLeod
const OFFSET_CSTEAMS = 114
const OFFSET_CSDEATHS = 444;

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
	deimos
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
new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10",
			"weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550",
			"weapon_galil", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
			"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
			"weapon_ak47", "weapon_knife", "weapon_p90" }
// Cvars
new cvar_delay, cvar_fire_radius, cvar_fire_dmg,
cvar_light_speed, cvar_pyscho_speed, cvar_china_force_speed, cvar_china_speed, cvar_voodoo_speed,
cvar_deimos_speed, cvar_reload_psy, cvar_reload_china, cvar_reload_voodoo,
cvar_strong_dmg, cvar_axe_dmg, cvar_combat_dmg, cvar_katana_dmg,
cvar_knockbackdist, cvar_zmknockback, cvar_jump_radius, cvar_jump_knock, cvar_reload_deimos, cvar_heal_radius,
cvar_hammer_dmg , cvar_hammer_dmg2 ,cvar_hammer_speed , cvar_hammer_speed2, cvar_human_speed, cvar_hammer_radius,
cvar_hammer_radius2, cvar_zombie_distance, cvar_nata_distance, cvar_strong_stab

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
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fw_PrimaryKnifeAttack", 1)
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
	register_forward(FM_SetModel, "fw_SetModel")
	register_forward(FM_GetGameDescription, "fw_GetGameDescription")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward(FM_Touch, "fw_Touch")
	register_forward(FM_CmdStart, "fw_cmdstart")
	register_forward(FM_CmdStart, "fw_CmdKnife")
	register_forward(FM_UpdateClientData, "fw_updateclientdata_post", 1)
	
	register_touch(ClassCrystal, "player", "OnTouchCrystal")
	
	unregister_forward(FM_Spawn, g_fwSpawn)
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0");
	register_logevent("logevent_round_end", 2, "1=Round_End")
	
	register_menu("Game Menu", KEYSMENU, "menu_game");
	register_menu("Class Menu", KEYSMENU, "menu_class");
	register_menu("Knife Menu", KEYSMENU, "menu_knife");
	register_menu("Shop Menu", KEYSMENU, "menu_shop");
	
	g_buyzone_ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_buyzone"))
	if (pev_valid(g_buyzone_ent))
	{
		dllfunc(DLLFunc_Spawn, g_buyzone_ent)
		set_pev(g_buyzone_ent, pev_solid, SOLID_NOT)
	}
	
	register_clcmd("chooseteam", "clcmd_changeteam")
	register_clcmd("jointeam", "clcmd_changeteam")
	register_clcmd("drop", "clcmd_drop")
	register_clcmd("say /vips", "CmdVIP")
	register_clcmd("say_team /vips", "CmdVIP")
	register_clcmd("say /shop", "show_shop_menu")
	
	g_iMaxClients = get_member_game(m_nMaxPlayers);
	
	g_MsgTeamInfo = get_user_msgid("TeamInfo")
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgDeathMsg = get_user_msgid("DeathMsg");
	g_msgScreenFade = get_user_msgid("ScreenFade");
	g_msgScoreAttrib = get_user_msgid("ScoreAttrib");
	g_msgScreenShake = get_user_msgid("ScreenShake");
	gmsgWeaponList = get_user_msgid("WeaponList");
	g_msgAmmoPickup = get_user_msgid("AmmoPickup");
	
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
	
	// block normal CS BUY MENU
	register_message(get_user_msgid("StatusIcon"),	"msgStatusIcon");
	
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
	g_save5 = nvault_open("CRYSTAL_SAVE")
	
	// Registering Cvars
	cvar_delay = register_cvar("cso_delay", "20")
	cvar_fire_radius = register_cvar("cso_fire_radius", "150")
	cvar_fire_dmg = register_cvar("cso_fire_dmg", "500")
	cvar_knockbackdist = register_cvar("cso_knock_distance", "500")
	cvar_zmknockback = register_cvar("cso_victim_knockback", "200.0")
	g_pCvarAdminContact = register_cvar("ze_admin_contact", "Forum: GamerClub.net")
	
	// Zombies Cvars
	cvar_light_speed = register_cvar("cso_light_speed", "250")
	cvar_pyscho_speed = register_cvar("cso_pyscho_speed", "275")
	cvar_china_force_speed = register_cvar("cso_china_force_speed", "500.0")
	cvar_china_speed = register_cvar("cso_china_speed", "240")
	cvar_voodoo_speed = register_cvar("cso_voodoo_speed", "255")
	cvar_heal_radius = register_cvar("cso_voodoo_heal_radius", "200")
	cvar_deimos_speed = register_cvar("cso_deimos_speed", "260")
	
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
	
	
	//register_clcmd("admin_get_holybomb", "clcmd_holy")
	//register_clcmd("admin_get_hegrenade", "clcmd_he")
	register_clcmd("admin_set_user_level", "clcmd_set_user_level", ADMIN_RCON, "- admin_set_user_level <name> <amount>")
	register_clcmd("admin_set_user_crystal", "clcmd_set_user_crystal", ADMIN_RCON, "- admin_set_user_crystal <name> <amount>")
	register_clcmd("admin_set_user_skin", "clcmd_set_user_skin", ADMIN_RCON, "- admin_set_user_skin <name> <2-8 girls / 9-10 boys>")
	register_clcmd("say /vip", "clcmd_vip_motd")
	//register_clcmd("infect_me", "clcmd_infect_me")
	formatex(g_modname, charsmax(g_modname), "Zombie Awaken")
	
}
public plugin_cfg()
{
	set_task(0.1, "event_round_start")
	set_task(0.1, "logevent_round_end")
}
public clcmd_vip_motd(id)
{
	show_motd(id, "vip.txt")
}
public clcmd_infect_me(id)
{
	if(get_user_flags(id) & ADMIN_RCON)
		infect_user(id)
}
public clcmd_set_user_level(id, level, cid)
{
	if ( !cmd_access ( id, level, cid, 3 ) )
		return PLUGIN_HANDLED;
		
	new s_Name[ 32 ], s_Amount[ 4 ];
	read_argv ( 1, s_Name, charsmax ( s_Name ) );
	read_argv ( 2, s_Amount, charsmax ( s_Amount ) );
	
	new i_Target = cmd_target ( id, s_Name, 2 );
		
	if ( !i_Target )
	{
		client_print ( id, print_console, "(!) Player not found" );
		return PLUGIN_HANDLED;
	}
	
	g_iLevel[i_Target] = str_to_num(s_Amount)
	return PLUGIN_HANDLED;
}
public clcmd_set_user_crystal(id, level, cid)
{
	if ( !cmd_access ( id, level, cid, 3 ) )
		return PLUGIN_HANDLED;
		
	new s_Name[ 32 ], s_Amount[ 4 ];
	read_argv ( 1, s_Name, charsmax ( s_Name ) );
	read_argv ( 2, s_Amount, charsmax ( s_Amount ) );
	
	new i_Target = cmd_target ( id, s_Name, 2 );
		
	if ( !i_Target )
	{
		client_print ( id, print_console, "(!) Player not found" );
		return PLUGIN_HANDLED;
	}
	
	g_iCrystal[i_Target] = str_to_num(s_Amount)
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
		client_print ( id, print_console, "(!) Player not found" );
		return PLUGIN_HANDLED;
	}
	
	skin[i_Target] = str_to_num(s_Amount)
	Save_Data(i_Target)
	return PLUGIN_HANDLED;
}
public clcmd_holy(id)
{
	if(get_user_flags(id) & ADMIN_RCON)	
		give_item(id, "weapon_flashbang")
}
public clcmd_he(id)
{
	if(get_user_flags(id) & ADMIN_RCON)	
		give_item(id, "weapon_hegrenade")
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
	precache_model(W_Crystal)
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
	precache_model(ViewModelFire)
	precache_model(PlayerModelFire)
	precache_model(WorldModelGrenades)
	precache_model("models/zm_cso/v_fast_bomb.mdl")
	precache_model("models/zm_cso/v_psycho_jump_f.mdl")
	precache_model("models/zm_cso/v_china_bomb.mdl")
	precache_model("models/zm_cso/v_voodoo_bomb.mdl")
	precache_model("models/zm_cso/p_zombiebomb.mdl")
	precache_model("models/zm_cso/v_deimos_jump_f.mdl")
	
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
	precache_sound("zm_cso/10.wav")
	precache_sound("zm_cso/9.wav")
	precache_sound("zm_cso/8.wav")
	precache_sound("zm_cso/7.wav")
	precache_sound("zm_cso/6.wav")
	precache_sound("zm_cso/5.wav")
	precache_sound("zm_cso/4.wav")
	precache_sound("zm_cso/3.wav")
	precache_sound("zm_cso/2.wav")
	precache_sound("zm_cso/1.wav")
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
		// Set The fog
		Set_KeyValue(ent, "density", "0.0018", "env_fog")
		Set_KeyValue(ent, "rendercolor", "0 0 25", "env_fog")
	}
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
	register_native("cso_get_user_crystals", "native_get_user_crystals", 1)
	register_native("cso_add_user_crystals", "native_add_user_crystals", 1)
	register_native("cso_open_knife_menu", "native_open_knife", 1)
	register_native("cso_get_user_type_hero", "native_get_type", 1)
	register_native("cso_get_user_type_heroine", "native_get_type_heroine", 1)
	register_native("cso_is_round_started", "native_get_round_started", 1)
}
public native_get_round_started()
{
	return g_roundstart;
}
public native_get_user_levels(id)
{
	return g_iLevel[id];
}
public native_get_user_crystals(id)
{
	return g_iCrystal[id];
}
public native_get_zombie(id)
{
	return g_zombie[id];
}
public native_open_knife(id)
{
	show_knife_menu(id);
}
public native_add_user_crystals(id, amount)
{
	g_iCrystal[id] = g_iCrystal[id] + amount;
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
		if (!is_user_alive(victim) || !g_zombie[victim])
			continue;
			
		ExecuteHam(Ham_TakeDamage, victim, "grenade", attacker, get_pcvar_float(pcvar_damage), DMG_BULLET)
		CreateBurnEntity(victim, attacker)
		client_print(attacker, print_center, "Health : %d", get_user_health(victim))
	}
	engfunc(EngFunc_RemoveEntity, ent)
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
	
	set_task(get_pcvar_float(pcvar_burn_period), "TaskRemoveBurnEntity", victim+TASKID_REMOVE_BURN)
	
	set_task(get_pcvar_float(pcvar_burn_delay), "Burn", victim+TASKID_REMOVE_BURN, _, _, "b")
	
}

public Burn(taskid)
{
	new id = taskid-TASKID_REMOVE_BURN
	
	if(!is_user_alive(id))
		return
		
	if(!pev_valid(in_burn[id]))
		return
	
	if(get_user_health(id) <= get_pcvar_num(pcvar_burn_damage))
	{
		set_task(1.0, "TaskRemoveBurnEntity", id+TASKID_REMOVE_BURN)
	}
	
	ExecuteHam(Ham_TakeDamage, id, "Holy Bomb", "Holy Fire", get_pcvar_float(pcvar_burn_damage), DMG_BURN)
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
		if (!is_user_alive(victim) || !g_zombie[victim])
			continue;
			
		ExecuteHam(Ham_TakeDamage, victim, "grenade", attacker, get_pcvar_float(cvar_fire_dmg), DMG_BLAST)
		client_print(attacker, print_center, "Health : %d", get_user_health(victim))
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
	
		if(g_knife[attacker] == strong)
		{
			velocity[0] = newvelocity[0] * 1.1 * 3000 / get_distance_f(victim_origin, attacker_origin)
			velocity[1] = newvelocity[1] * 1.1 * 3000 / get_distance_f(victim_origin, attacker_origin)
		}
		else if(g_knife[attacker] == axe)
		{
			velocity[0] = newvelocity[0] * 0.7 * 3000 / get_distance_f(victim_origin, attacker_origin)
			velocity[1] = newvelocity[1] * 0.7 * 3000 / get_distance_f(victim_origin, attacker_origin)
		}
		else if(g_knife[attacker] == combat)
		{
			velocity[0] = newvelocity[0] * 0.4  * 3000 / get_distance_f(victim_origin, attacker_origin)
			velocity[1] = newvelocity[1] * 0.4 * 3000 / get_distance_f(victim_origin, attacker_origin)
		}
		else if(g_knife[attacker] == katana)
		{
			velocity[0] = newvelocity[0] * 1.3  * 3000 / get_distance_f(victim_origin, attacker_origin)
			velocity[1] = newvelocity[1] * 1.3 * 3000 / get_distance_f(victim_origin, attacker_origin)
		}
		else if(g_knife[attacker] == hammer)
		{
			if(!g_mode[attacker])
			{
				velocity[0] = newvelocity[0] * 12.3  * 3000 / get_distance_f(victim_origin, attacker_origin)
				velocity[1] = newvelocity[1] * 12.3 * 3000 / get_distance_f(victim_origin, attacker_origin)
			}
			else
			{
				velocity[0] = newvelocity[0] * 25.0  * 3000 / get_distance_f(victim_origin, attacker_origin)
				velocity[1] = newvelocity[1] * 25.0 * 3000 / get_distance_f(victim_origin, attacker_origin)
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
		logevent_round_end()
	}
	else if (equal(textmsg, "#Game_Commencing"))
	{
		g_roundstart = false
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
		client_print(0, print_center, "Humans Win!")
	}
	else if (!fnGetHumans())
	{
		play_sound("zm_cso/all/win_zombie.wav")
		client_print(0, print_center, "Zombies Win!")
	}
	else
	{
		play_sound("zm_cso/all/no_one.wav")
		client_print(0, print_center, "Humans Survive!")
	}
	rg_balance_teams()
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
		else if(g_playerclass[id] == deimos)
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
		client_print(id, print_chat, "You can use your ability Again")
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
	
	if (get_user_weapon(id) == CSW_KNIFE)
	{
		if(!g_zombie[id]){
			if(g_knife[id] == strong)
			{
				pev(id, pev_v_angle, vector_end)
				angle_vector(vector_end, ANGLEVECTOR_FORWARD, vector_end)
				
				if(g_attack_type[id] == ATTACK_SLASH)
					xs_vec_mul_scalar(vector_end, get_pcvar_float(cvar_nata_distance), vector_end)
				else if(g_attack_type[id] == ATTACK_STAB)
					xs_vec_mul_scalar(vector_end, get_pcvar_float(cvar_nata_distance), vector_end)
				
				xs_vec_add(vector_start, vector_end, vector_end)
				engfunc(EngFunc_TraceLine, vector_start, vector_end, ignored_monster, id, handle)
				return FMRES_SUPERCEDE;
			}
			else if(g_knife[id] == hammer)
			{
				pev(id, pev_v_angle, vector_end)
				angle_vector(vector_end, ANGLEVECTOR_FORWARD, vector_end)
				
				if(!g_mode[id]) 
					xs_vec_mul_scalar(vector_end, get_pcvar_float(cvar_hammer_radius), vector_end)
				else
					xs_vec_mul_scalar(vector_end, get_pcvar_float(cvar_hammer_radius2), vector_end)
				
				xs_vec_add(vector_start, vector_end, vector_end)
				engfunc(EngFunc_TraceLine, vector_start, vector_end, ignored_monster, id, handle)
				return FMRES_SUPERCEDE;
			}
		}
		else
		{
			pev(id, pev_v_angle, vector_end)
			angle_vector(vector_end, ANGLEVECTOR_FORWARD, vector_end)
				
			xs_vec_mul_scalar(vector_end, get_pcvar_float(cvar_zombie_distance), vector_end)
				
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
		client_print(id, print_center, "You Level UP!")
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
				g_iExp[killer] += 6
				g_iCrystal[killer] += 2
			}
			else
			{
				g_iExp[killer] += 3
				g_iCrystal[killer]++
			}			
			check_level(killer)
			client_cmd(killer, "spk zm_cso/excellent.wav")
		}
		else
		{
			if(get_user_flags(killer) & ADMIN_LEVEL_H)
			{
				g_iExp[killer] += 2
			}
			else
			{
				g_iExp[killer]++
			}	
			check_level(killer)
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
	}
	return PLUGIN_CONTINUE;
}
public fw_UseStationary(entity, caller, activator, use_type)
{
	// Prevent zombies from using stationary guns
	if (use_type == USE_USING && is_user_valid_connected(caller) && g_zombie[caller])
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

public fw_PlayerPreThink(id) {
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
	if (!g_zombie[id] && !g_roundstart)
	{
		//if (pev_valid(g_buyzone_ent))
		dllfunc(DLLFunc_Touch, g_buyzone_ent, id)
	}
	if ( !is_user_alive(id) || g_zombie[id] )
		return PLUGIN_CONTINUE
		
	new temp[2], weapon = get_user_weapon(id, temp[0], temp[1])
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
				fVelocity[2] += 332
			else if(g_knife[id] == combat)
				fVelocity[2] += 335
			else if(g_knife[id] == katana)
				fVelocity[2] += 330
			else if(g_knife[id] == hammer)
				fVelocity[2] += 328
			entity_set_vector(id, EV_VEC_velocity, fVelocity)
			entity_set_int(id, EV_INT_gaitsequence, 6)
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
				}
				case 1 :
				{
					set_default_models(id)
					skin[id] = 0
				}
				case 2 :
				{
					cs_set_player_model(id, "legendofwarior_females")
					fm_set_user_model_index(id, mdl_females)
					set_pev(id, pev_body, 0)
				}
				case 3 :
				{
					cs_set_player_model(id, "legendofwarior_females")
					fm_set_user_model_index(id, mdl_females)
					set_pev(id, pev_body, 1)
				}
				case 4 :
				{
					cs_set_player_model(id, "legendofwarior_females")
					fm_set_user_model_index(id, mdl_females)
					set_pev(id, pev_body, 2)
				}
				case 5 :
				{
					cs_set_player_model(id, "legendofwarior_females")
					fm_set_user_model_index(id, mdl_females)
					set_pev(id, pev_body, 3)
				}
				case 6 :
				{
					cs_set_player_model(id, "legendofwarior_females")
					fm_set_user_model_index(id, mdl_females)
					set_pev(id, pev_body, 4)
				}
				case 7 :
				{
					cs_set_player_model(id, "legendofwarior_females")
					fm_set_user_model_index(id, mdl_females)
					set_pev(id, pev_body, 5)
				}
				case 8 :
				{
					cs_set_player_model(id, "legendofwarior_females")
					fm_set_user_model_index(id, mdl_females)
					set_pev(id, pev_body, 6)
				}
				case 9 :
				{
					cs_set_player_model(id, "legendofwarior_humans")
					fm_set_user_model_index(id, mdl_males)
					set_pev(id, pev_body, 9)
				}
				case 10 :
				{
					cs_set_player_model(id, "legendofwarior_humans")
					fm_set_user_model_index(id, mdl_males)
					set_pev(id, pev_body, 10)
				}
			}
		}
	}
}
public set_user_human(id)
{
	Update_Attribute(id)
	g_zombie[id] = false
	remove_task(id+TASKID_REMOVE_BURN)
	RemoveBurnEntity(id)	
	client_cmd(id,"cl_forwardspeed 400")
	client_cmd(id,"cl_backspeed 400")
	client_cmd(id,"buy")
	g_sprintzm[id] = false
	set_user_rendering(id)
	g_using_ab[id] = false
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		fm_set_user_health(id, 200)
	}
	else
	{
		fm_set_user_health(id, 100)
	}
	if(g_freeround)
		set_pev(id, pev_gravity, 0.15)
	else
		set_pev(id, pev_gravity, 1.0)
			
	rg_remove_all_items(id)
	rg_give_item(id, "weapon_knife", GT_REPLACE)
			
	check_models(id)
		
	static weapon_ent
	weapon_ent = fm_cs_get_current_weapon_ent(id)
	if (pev_valid(weapon_ent)) replace_weapon_models(id, cs_get_weapon_id(weapon_ent))
	check_weapons_list(id)
	engclient_cmd(id, "weapon_knife")
}
public fw_PlayerSpawn_Post(id) 
{
	if (!is_user_alive(id) || !fm_cs_get_user_team(id) || !is_user_valid_connected(id))
		return
		
	Update_Attribute(id)
	
	if(!g_roundstart)
	{
		set_user_human(id)
	}
	else
	{
		if(g_freeround)
			set_user_human(id)
		else
			infect_user(id)
	}
	remove_task(id+TASKID_REMOVE_BURN)
	g_type[id] = player
	RemoveBurnEntity(id)	
	g_buytime[id] = get_gametime()
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

    iLen = formatex(szMessage, charsmax(szMessage), "^4VIPs ONLINE^1: ")

    if (iVIPCount)
    {
        for (i = 0; i <= iVIPCount; i++)
            iLen += formatex(szMessage[iLen], charsmax(szMessage) - iLen, "^3%s^1%s^3", szVIPName[i], (i < (iVIPCount - 1)) ? ", " : "")
    }
    else
    {
        szMessage = "^4No VIPs online^1."
    }

    client_print(0, print_chat, szMessage)
    get_pcvar_string(g_pCvarAdminContact, szContact, charsmax(szContact))

    if (szContact[0])
    {
        client_print(0, print_chat,"^4Contact Server Admin ^1-- ^3%s", szContact)
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
		rg_drop_items_by_slot(victim, PRIMARY_WEAPON_SLOT)
		rg_drop_items_by_slot(victim, PISTOL_SLOT)
		
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
					
					rg_send_bartime(id, get_pcvar_num(cvar_reload_psy), false)
					
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
					
					rg_send_bartime(id, get_pcvar_num(cvar_reload_china), false)
				
					set_task(20.0, "reset_ability", id)
				}
				else if(g_playerclass[id] == voodoo)
				{
					
					static Float:originF[3]
					pev(id, pev_origin, originF)
	
					rg_send_bartime(id, get_pcvar_num(cvar_reload_voodoo), false)
					
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
					
					rg_send_bartime(id, get_pcvar_num(cvar_reload_deimos), false)
					
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
				client_print(id, print_chat, "You can't use your ability for some reason.")
			}
		}
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
public client_PreThink(id)
{
	if(g_zombie[id])
	{
		if(g_playerclass[id] == light)
			set_user_maxspeed(id, get_pcvar_float(cvar_light_speed))
		else if(g_playerclass[id] == normal)
			set_user_maxspeed(id, get_pcvar_float(cvar_pyscho_speed))
		else if(g_playerclass[id] == china)
		{
			if(g_sprintzm[id])
				set_user_maxspeed(id, get_pcvar_float(cvar_china_force_speed))
			else
				set_user_maxspeed(id, get_pcvar_float(cvar_china_speed))
		}
		else if(g_playerclass[id] == voodoo)
			set_user_maxspeed(id, get_pcvar_float(cvar_voodoo_speed))
		else if(g_playerclass[id] == deimos)
			set_user_maxspeed(id, get_pcvar_float(cvar_deimos_speed))
	}
	else
	{
		if(g_knife[id] == hammer && get_user_weapon(id) == CSW_KNIFE)
		{
			if(g_mode[id] == 0) set_user_maxspeed(id, get_pcvar_float(cvar_hammer_speed))
			if(g_mode[id] == 1) set_user_maxspeed(id, get_pcvar_float(cvar_hammer_speed2))
			if(g_mode[id] == 2) set_user_maxspeed(id, get_pcvar_float(cvar_hammer_speed2))
			if(g_mode[id] == 3) set_user_maxspeed(id, get_pcvar_float(cvar_hammer_speed2))
			if(g_mode[id] == 4) set_user_maxspeed(id, get_pcvar_float(cvar_hammer_speed))
		}
		else
		{
			set_user_maxspeed(id, get_pcvar_float(cvar_human_speed))
		}
	}
	if(g_iLevel[ id ] >= 100)
	{
		g_iLevel[ id ] = 100
	}
	if(g_iCrystal[ id ] >= 200)
	{
		g_iCrystal[ id ] = 200
	}
	if(g_iExp[ id ] >= 1000)
	{
		g_iExp[ id ] = 0
	}
}
// CS Buy Menus
public menu_cs_buy(id, key)
{
	// Prevent buying if zombie/survivor (bugfix)
	if (g_zombie[id])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}
public msgStatusIcon(msgid, msgdest, id)
{
	static szIcon[8];
	get_msg_arg_string(2, szIcon, 7);

	if(g_roundstart)
	{
		if(equal(szIcon, "buyzone") && get_msg_arg_int(1))
		{
			set_pdata_int(id, 235, get_pdata_int(id, 235) & ~(1<<0));
			return PLUGIN_HANDLED;
		}
	}
 
	return PLUGIN_CONTINUE;
}
public client_connect(id)
{
	g_zombie[id] = false
	Load_Data(id)
}
public client_putinserver(id)
{
	set_task(1.0, "ShowHUD", id+TASK_SHOWHUD, _, _, "b")
	
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
		
}
public fw_ClientDisconnect(id)
{
	static iPlayersnum
	iPlayersnum = fnGetAlive()
	
	if(g_zombie[id])
	{
		if(!fnGetZombies() && iPlayersnum >= 2)
		{
			new newid, szName[ 32 ], szNewName[ 32 ]
			static iPlayersNum
			iPlayersNum = gAlive()
	 	
			newid = gRandomAlive(random_num(1, iPlayersNum))
			  
			get_user_name( id, szName, 31 )
			get_user_name( newid, szNewName, 31 )
	
			infect_user(newid)
			client_print(0, print_chat, "%s left, %s has became the new infected!", szName, szNewName)
		}
	}
	else
	{
		if(!fnGetHumans() && iPlayersnum >= 2)
		{
			set_task(1.0, "logevent_round_end")
		}
	}
	g_isconnected[id] = true	
	Save_Data(id)
}
public fw_PlayerKilled(id, attacker, shouldgib)
{
	if(g_zombie[id])
	{
		new Rand = random(100)
		switch(Rand)
		{
			case 50..100 : CreateCrystal(id)
		}
	}
	remove_task(id+TASKID_REMOVE_BURN)
	RemoveBurnEntity(id)		
}
public OnTouchCrystal(ent, id)
{
	if(is_valid_ent(ent) && is_user_alive(id))
	{
		remove_entity(ent)
		client_print(id, print_chat, "You pickup a Crystal!")
		g_iCrystal[id]++
		emit_sound(id, CHAN_WEAPON, "csoleg_pickup.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	return PLUGIN_CONTINUE
}

public event_round_start()
{
	client_cmd(0, "stopsound")
	remove_entity_name(ClassCrystal)
	round_count++
	g_endround = false
	g_startround = true
	
	client_print(0, print_chat, "[^4Zombie Awaken By %s]", AUTHOR)
	client_print(0, print_chat, "Press [B] or type /buy to open buy menu before round starts.")
	
	if(round_count > 1)
	{
		remove_task(1603)
		remove_task(1604)
		remove_task(1501)
		set_task(2.0, "round_song")
		set_task(2.0 + get_pcvar_float(cvar_delay), "gaming_game", 1604)
		// countdown
		countdown_timer = 21-1
		set_task(2.0, "make_countdown", 1603); 
		g_roundstart = false
		g_freeround = false
	}
	else
	{
		client_print(0, print_chat, "----------Round Restart after 30 seconds----------")
		g_roundstart = true
		g_freeround = true
		count_new = 31-1
		set_task(2.0, "new_round_count", 1501)
	}
}
public gaming_game()
{
	start_game(0)
	remove_task(1604)
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
		rg_round_end(1.0, WINSTATUS_TERRORISTS, ROUND_END_DRAW, "Time to start the game")
	}
}
public make_countdown() {
	new speak[10][] = 
	{
		"zm_cso/1.wav",
		"zm_cso/2.wav",
		"zm_cso/3.wav",
		"zm_cso/4.wav",
		"zm_cso/5.wav",
		"zm_cso/6.wav",
		"zm_cso/7.wav",
		"zm_cso/8.wav",
		"zm_cso/9.wav",
		"zm_cso/10.wav"
	}

	if(countdown_timer < 11)
		client_cmd(0, "spk %s", speak[countdown_timer-1]); 
		
	client_print(0, print_center, "Zombie Apocalypse will start in %d", countdown_timer)
	
	--countdown_timer
	if(countdown_timer != 0)
	{
		set_task(1.0, "make_countdown", 1603);
	}
	else
	{
		remove_task(1603)
	}
}
public start_game(player_id) {
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
				fm_set_user_health(player_id, 5000)
			}
		}
		check_teams()
		client_print(0, print_center, "Zombies Appear!")
		g_startround = false
	}
	else if(iPlayersnum >= 2){
		infect_user(id)
		fm_set_user_health(id, 8000)
		check_teams()
		client_print(0, print_center, "Zombies Appear!")
		g_startround = false
	}
	else
	{
		client_print(0, print_center, "No Enough Players to Start The Game")
	}
	if(iPlayersnum >= 10)
	{
		new idZ
		static iPlayersNumZ
		iPlayersNumZ = gAliveZ()
		
		idZ = gRandomAliveZ(random_num(1, iPlayersNumZ))
		make_user_hero(idZ)
	}
	else
	{
		client_print(0, print_chat, "INFO : Hero or Heroine appear when there are 10 players")
	}
	g_roundstart = true
}
public make_user_hero(id)
{
	fm_set_user_health(id, 300)
	rg_remove_all_items(id)
	rg_give_item(id, "weapon_knife", GT_REPLACE)
	rg_give_item(id, "weapon_hegrenade", GT_APPEND)
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
			set_dhudmessage(255, 0, 0, 0.0, -1.0, 0, 6.0, 5.0)
			show_dhudmessage(0, "***%s is Hero!***", name)
			client_print(0, print_chat, "%s has been choosen as a HERO!", name)
		}
		case 1 :
		{
			cs_set_player_model(id, "legendofwarior_females")
			set_pev(id, pev_body, 6)
			g_type[id] = heroine
			give_weapon_dualkriss(id)
			set_dhudmessage(255, 0, 0, 0.0, -1.0, 0, 6.0, 5.0)
			show_dhudmessage(0, "***%s is Heroine!***", name)
			client_print(0, print_chat, "%s has been choosen as HEROINE!", name)
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
	new Random = random(2)
	switch(Random)
	{
		case 0 : client_cmd(0, "spk zm_cso/roundstart.wav")
		case 1 : client_cmd(0, "spk zm_cso/roundstart2.wav")
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
		
	if(g_zombie[attacker] && !g_zombie[victim])
	{
		if(fnGetHumans() != 1)
		{
			infect_user(victim)
			rg_give_item(attacker, "weapon_hegrenade", GT_APPEND)
			fm_set_user_health(attacker, get_user_health(attacker) + 300)
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
				g_iExp[attacker] += 4
			else
				g_iExp[attacker] += 2
			check_level(attacker)
		
			return HAM_SUPERCEDE;
		}
		else
		{
			client_print(attacker, print_center, "Health : %d", get_user_health(victim) - floatround(damage))
		}
	}
	else if(!g_zombie[attacker] && g_zombie[victim])
	{
		if (is_user_valid_connected(inflictor) && get_user_weapon(inflictor) == CSW_KNIFE)
		{
			if(g_knife[attacker] == strong)
			{
				if(g_attack_type[attacker] == ATTACK_SLASH)
					SetHamParamFloat(4, damage * get_pcvar_float(cvar_strong_dmg));
				else if(g_attack_type[attacker] == ATTACK_STAB)
					SetHamParamFloat(4, get_pcvar_float(cvar_strong_stab));
			}
			else if(g_knife[attacker] == katana)
				SetHamParamFloat(4, damage * get_pcvar_float(cvar_katana_dmg));
			else if(g_knife[attacker] == axe)
				SetHamParamFloat(4, damage * get_pcvar_float(cvar_axe_dmg));
			else if(g_knife[attacker] == combat)
				SetHamParamFloat(4, damage * get_pcvar_float(cvar_combat_dmg));
			else if(g_knife[attacker] == hammer)
			{
				if(g_mode[attacker])
					SetHamParamFloat(4, damage * get_pcvar_float(cvar_hammer_dmg2) * 2)
				else
					SetHamParamFloat(4, damage * get_pcvar_float(cvar_hammer_dmg) * 4)
			}

		}
		client_print(attacker, print_center, "Health : %d", get_user_health(victim) - floatround(damage))
	}
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
		if(g_playerclass[victim] == deimos)
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
public fw_PrimaryKnifeAttack(Weapon)
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

	set_dhudmessage(255, 0, 0, 0.02, 0.9, 0, 6.0, 1.0)
	show_dhudmessage(id, "Health: %d || Levels: %d/100 || XP: %d/%d || Crystals : %d/200 || Class : %s", get_user_health(id), g_iLevel[id], g_iExp[id], MAX_LEVELS[g_iLevel[ id ]], g_iCrystal[id], szClass)
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
	len += formatex(menu[len], charsmax(menu) - len, "\yYou have %d/200 Crystals^n^n", g_iCrystal[ id ])
	// Items
	if(g_iCrystal[ id ] >= 1)
		len += formatex(menu[len], charsmax(menu) - len, "\r1.\w Ammo Refill \y[1 Crystal]^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r1.\d Ammo Refill \y[1 Crystal]^n")
	if(g_iCrystal[ id ] >= 5)
		len += formatex(menu[len], charsmax(menu) - len, "\r2.\w Fire Nade \y[5 Crystals]^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r2.\d Fire Nade \y[5 Crystals]^n")
	if(g_iCrystal[ id ] >= 7)
		len += formatex(menu[len], charsmax(menu) - len, "\r3.\w Holy Bottle \y[7 Crystals]^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r3.\d Holy Bottle \y[7 Crystals]^n")
	if(g_iCrystal[ id ] >= 15)
		len += formatex(menu[len], charsmax(menu) - len, "\r4.\w +10 EXP \y[15 Crystals]^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r4.\d +10 EXP \y[15 Crystals]^n")
	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		if(g_iCrystal[ id ] >= 50)
			len += formatex(menu[len], charsmax(menu) - len, "\r5.\w Hero Pack \y[50 Crystals] \rVIP Only^n")
		else
			len += formatex(menu[len], charsmax(menu) - len, "\r5.\d Hero Pack \y[50 Crystals] \rVIP Only^n")
	}
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r5.\d Hero Pack \y[50 Crystals] \rVIP Only^n")
		
	if(g_iCrystal[ id ] >= 100)
		len += formatex(menu[len], charsmax(menu) - len, "\r6.\w +100 EXP \y[100 Crystals]")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r6.\d +100 EXP \y[100 Crystals]")
	
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\r0.\y Exit")
	 
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	show_menu(id, KEYSMENU, menu, -1, "Shop Menu")
}
public menu_shop(id, key) {
	if(g_zombie[id])
		return PLUGIN_HANDLED
		
	switch (key)
	{
	    case 0:
		{
			if(g_iCrystal[ id ] >= 1)
			{
				refill_ammo(id)
				g_iCrystal[ id ] -= 1
			}
		}
	    case 1:
		{
			if(g_iCrystal[ id ] >= 5)
			{
				rg_give_item(id, "weapon_hegrenade", GT_APPEND)
				g_iCrystal[ id ] -= 5
			}
		}
		case 2:
		{
			if(g_iCrystal[ id ] >= 7)
			{
				rg_give_item(id, "weapon_flashbang", GT_APPEND)
				g_iCrystal[ id ] -= 7
			}
		}
		case 3:
		{
			if(g_iCrystal[ id ] >= 15)
			{
				g_iExp[id] += 10
				g_iCrystal[ id ] -= 15
			}
		}
		case 4:
		{
			if(get_user_flags(id) & ADMIN_LEVEL_H)
			{
				if(g_iCrystal[ id ] >= 50)
				{
					make_user_hero(id)
					g_iCrystal[ id ] -= 50
				}
			}
		}
		case 5:
		{
			if(g_iCrystal[ id ] >= 100)
			{
				g_iExp[id] += 100
				g_iCrystal[ id ] -= 100
			}
		}
	}
	return PLUGIN_HANDLED;
}
public refill_ammo(id)
{
	new weapon = get_user_weapon(id)
	cs_set_weapon_ammo(weapon, 200)
}
public show_game_menu(id) 
{
	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\yGame Menu \r|| \wLevels \r: \y%d\r/\y100 \r- \y%d\r/\y%d \wXP^n^n", g_iLevel[id], g_iExp[id], MAX_LEVELS[g_iLevel[ id ]])
	// Items
	len += formatex(menu[len], charsmax(menu) - len, "\r1.\w Choose Zombie Class^n")
	if(g_zombie[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r2.\d Crystal Shop^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r2.\w Crystal Shop^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r3.\w Check VIP Features^n")
	len += formatex(menu[len], charsmax(menu) - len, "^n^n^n\r0.\y Exit")
	 
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
			if(g_zombie[id])
				return PLUGIN_HANDLED
			else
				show_shop_menu(id)
		}
		case 2:
		{
			client_cmd(id, "say /vip")
		}
	}
	return PLUGIN_HANDLED;
}
public show_class_menu(id) {
	
	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\yChoose a Class^n^n")
	// Items
	len += formatex(menu[len], charsmax(menu) - len, "\r1.\w Light^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r2.\w Pyscho^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r3.\w China^n")
	len += formatex(menu[len], charsmax(menu) - len, "\r4.\w Voodoo^n")
	if(get_user_flags(id) & ADMIN_LEVEL_H)
		len += formatex(menu[len], charsmax(menu) - len, "\r5.\w Deimos \rVIP Only")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r5.\d Deimos \rVIP Only")
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\r0.\y Exit")
	 
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	show_menu(id, KEYSMENU, menu, -1, "Class Menu")
}
public menu_class(id, key) {
	switch (key)
	{
	         case 0:
		{
			g_nextclass[id] = light
			client_print(id, print_chat, "Next Infect, Your Class will be Light Zombie")
		}
	         case 1:
		{
			g_nextclass[id] = normal
			client_print(id, print_chat, "Next Infect, Your Class will be Pyscho Zombie")
		}
		case 2:
		{
			g_nextclass[id] = china
			client_print(id, print_chat, "Next Infect, Your Class will be China Zombie")
		}
		case 3:
		{
			g_nextclass[id] = voodoo
			client_print(id, print_chat, "Next Infect, Your Class will be Voodoo Zombie")
		}
		case 4:
		{
			if(get_user_flags(id) & ADMIN_LEVEL_H)
			{
				g_nextclass[id] = deimos
				client_print(id, print_chat, "Next Infect, Your Class will be Deimos Zombie")
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
	if(get_user_flags(id) & ADMIN_RESERVATION || get_user_flags(id) & ADMIN_LEVEL_H)
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
			if(get_user_flags(id) & ADMIN_RESERVATION)
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
	g_mode[id] = 0
	g_primaryattack[id] = 0
	g_zombie[id] = true
	g_using_ab[id] = true
	set_pev(id, pev_armorvalue, 0.0)
	g_type[id] = player
	rg_remove_all_items(id)
	rg_give_item(id, "weapon_knife", GT_REPLACE)
	set_player_nextattack(id, 2.0)
	set_pev(id, pev_viewmodel2, "models/zm_cso/v_infection.mdl")
	set_pev(id, pev_weaponmodel2, "")
	util_playweaponanimation(id, 0)
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
		fm_set_user_health(id, 1500)
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
		fm_set_user_health(id, 1750)
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
		fm_set_user_health(id, 2000)
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
		fm_set_user_health(id, 1800)
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
		fm_set_user_health(id, 2550)
		set_pev(id, pev_gravity, 0.680)
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
}
public check_claws(id)
{
	rg_give_item(id, "weapon_hegrenade", GT_APPEND)
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
	write_byte(0)
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
	new vaultkey[64], vaultdata[256], vaultdata2[256], vaultdata3[256], vaultdata4[256], vaultdata5[256]

	new name[33];
	get_user_name(id,name,32)
		
	format(vaultkey, 63, "%s-/", name)

	format(vaultdata, 255, "%i#", g_iExp[id])
	
	format(vaultdata2, 255, "%i#", g_iLevel[id])
	
	format(vaultdata3, 255, "%i#", g_knife_key[id])
	
	format(vaultdata4, 255, "%i#", skin[id])
	
	format(vaultdata5, 255, "%i#", g_iCrystal[id])
	
	nvault_set(g_save, vaultkey, vaultdata)
	nvault_set(g_save3, vaultkey, vaultdata2)
	nvault_set(g_save2, vaultkey, vaultdata3)
	nvault_set(g_save4, vaultkey, vaultdata4)
	nvault_set(g_save5, vaultkey, vaultdata5)
	return PLUGIN_CONTINUE;
}

public Load_Data(id)
{
	new vaultkey[64], vaultdata[256], vaultdata2[256], vaultdata3[256], vaultdata4[256], vaultdata5[256]
	
	new name[33];
	get_user_name(id,name,32)
			
	format(vaultkey, 63, "%s-/", name)
	
	format(vaultdata, 255, "%i#", g_iExp[id])
	
	format(vaultdata2, 255, "%i#", g_iLevel[id])
	
	format(vaultdata3, 255, "%i#", g_knife_key[id])
	
	format(vaultdata4, 255, "%i#", skin[id])
	
	format(vaultdata5, 255, "%i#", g_iCrystal[id])
	
	nvault_get(g_save, vaultkey, vaultdata, 255)
	nvault_get(g_save3, vaultkey, vaultdata2, 255)
	nvault_get(g_save2, vaultkey, vaultdata3, 255)
	nvault_get(g_save4, vaultkey, vaultdata4, 255)
	nvault_get(g_save5, vaultkey, vaultdata5, 255)
	replace_all(vaultdata, 255, "#", " ")
	replace_all(vaultdata2, 255, "#", " ")
	replace_all(vaultdata3, 255, "#", " ")
	replace_all(vaultdata4, 255, "#", " ")
	replace_all(vaultdata5, 255, "#", " ")
	
	new XP[32], Level[32], Knifas[32], a[32], Crystal[32]
	parse(vaultdata, XP, 31)
	parse(vaultdata2, Level, 31)
	parse(vaultdata3, Knifas, 31)
	parse(vaultdata4, a, 31)
	parse(vaultdata5, Crystal, 31)
	g_iExp[id] = str_to_num(XP)
	g_iLevel[id] = str_to_num(Level)
	g_knife_key[id] = str_to_num(Knifas)
	g_iCrystal[id] = str_to_num(Crystal)
	skin[id] = str_to_num(a)
	
	return PLUGIN_CONTINUE;
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
CreateCrystal(id)
{
	new ent = create_entity("info_target")
	if(!is_valid_ent(ent)) 
		return;
	
	new Float:Aim[3], Float:Origin[3]
	velocity_by_aim(id, 32, Aim)
	entity_get_vector(id, EV_VEC_origin, Origin)
	Origin[0] += 2*Aim[0]
	Origin[1] += 2*Aim[1]
	entity_set_string(ent, EV_SZ_classname, ClassCrystal)
	entity_set_model(ent, W_Crystal)
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS)
	entity_set_int(ent, EV_INT_solid, SOLID_TRIGGER)
	entity_set_size(ent, Float:{-8.0, -8.0, -8.0}, Float:{8.0, 8.0, 8.0})
	entity_set_float(ent, EV_FL_gravity, 1.25)
	entity_set_vector(ent, EV_VEC_origin, Origin)
	velocity_by_aim(id, 400, Aim)
	entity_set_vector(ent, EV_VEC_velocity, Aim)
	
}
stock fm_set_user_model_index(id, value)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(id) != PDATA_SAFE)
		return;
	
	set_pdata_int(id, OFFSET_MODELINDEX, value, OFFSET_LINUX)
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
