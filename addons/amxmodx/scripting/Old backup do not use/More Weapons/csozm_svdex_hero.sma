#include <amxmodx>
#include <engine>
#include <xs>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <cstrike>

native cso_get_user_zombie(id)

#define WEAPON_NUMBER 		4025

#define TIME_RELOAD		3.4
#define TIME_DRAW		1.1

#define ANIM_IDLE		0
#define ANIM_RELOAD		1
#define ANIM_DRAW		2
#define ANIM_SHOOT_1		3
#define ANIM_SHOOT_2		4
#define ANIM_CHANGE		5
#define ANIM_IDLE_EX		6
#define ANIM_SHOOT_EX_1		7
#define ANIM_SHOOT_EX_2		8
#define ANIM_CHANGE_EX		9

#define DAMAGE			2.50
#define DAMAGE_HERO		3.50
#define RECOIL			1.4
#define RECOIL_EX		0.0
#define RATE_OF_FIRE		92
#define CLIP			20
#define CLIP_EX			10
#define AMMO			180

#define EXPLODE_RADIUS		240.0
#define EXPLODE_DAMAGE		500.0

#define EXPLODE_SOUND		"weapons/svdex_explosion.wav"
#define SHOOT_SOUND		"weapons/svdex-1.wav"
#define SHOOT_EX_SOUND		"weapons/svdex-2.wav"
#define VIEW_MODEL		"models/xx/v_svdex.mdl"
#define PLAYER_MODEL		"models/xx/p_svdex.mdl"
#define WORLD_MODEL		"models/zm_cso/w_primaryn.mdl"
#define SPECIAL_MODEL		"models/xx/s_m79.mdl"

new g_itemid, g_has_svdex[33]

new g_primaryattack[33], g_clipammo[33], g_mode[33], g_change[33]

new g_orig_event_m249, g_m249_variables[10]

new g_index_smoke, g_index_shell

new g_index_explosion, g_index_trail, g_index_smoke_2, g_index_gibs

new g_clipammo_save[33], g_grenades[33], g_ammo_save[33]

enum ( <<=1 )
{
    v_angle = 1,
    punchangle
}

const WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_MP5NAVY)|(1<<CSW_UMP45)|(1<<CSW_G3SG1)|(1<<CSW_P90)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_AUG)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_M249)|(1<<CSW_SG552)|(1<<CSW_M249)|(1<<CSW_FAMAS)

public plugin_init()
{	
	register_plugin("[ZP] Extra Item: SVD EX", "1.0", "BlackCat")
	
	register_message(get_user_msgid("DeathMsg"), "message_deathmsg")
	register_message(get_user_msgid("WeapPickup"), "message_weappickup")
	
	register_message(get_user_msgid("CurWeapon"), "message_curweapon")
	register_message(get_user_msgid("AmmoX"), "message_ammox")
	
	register_forward(FM_SetModel, "fm_setmodel")
	register_forward(FM_UpdateClientData, "fm_updateclientdata_post", 1)
	register_forward(FM_PlaybackEvent, "fm_playbackevent")
	register_forward(FM_CmdStart, "fm_cmdstart") 
	
	register_touch("svdex_grenade", "*", "touch_svdex_grenade")
	
	RegisterHam(Ham_Item_AddToPlayer, "weapon_m249", "ham_item_addtoplayer")
	RegisterHam(Ham_Item_Deploy, "weapon_m249", "ham_item_deploy_post", 1)
	RegisterHam(Ham_Item_Holster, "weapon_m249", "ham_item_holster_post", 1)
	RegisterHam(Ham_Item_PreFrame, "weapon_m249", "ham_item_preframe")
	
	RegisterHam(Ham_Weapon_WeaponIdle, "weapon_m249", "ham_weapon_weaponidle")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m249", "ham_weapon_primaryattack")
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_m249", "ham_weapon_primaryattack_post", 1)
	RegisterHam(Ham_Weapon_Reload, "weapon_m249", "ham_weapon_reload")
	RegisterHam(Ham_Weapon_Reload, "weapon_m249", "ham_weapon_reload_post", 1)
	
	RegisterHam(Ham_TraceAttack, "player", "ham_traceattack")
	RegisterHam(Ham_TraceAttack, "player", "ham_traceattack_post", 1)	
	RegisterHam(Ham_TraceAttack, "worldspawn", "ham_traceattack_post", 1)
	RegisterHam(Ham_TraceAttack, "func_breakable", "ham_traceattack_post", 1)
	RegisterHam(Ham_TraceAttack, "func_wall", "ham_traceattack_post", 1)
	RegisterHam(Ham_TraceAttack, "func_door", "ham_traceattack_post", 1)
	RegisterHam(Ham_TraceAttack, "func_door_rotating", "ham_traceattack_post", 1)
	RegisterHam(Ham_TraceAttack, "func_plat", "ham_traceattack_post", 1)
	RegisterHam(Ham_TraceAttack, "func_rotating", "ham_traceattack_post", 1)
	
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1);
	
	RegisterHam(Ham_TakeDamage, "player", "ham_takedamage")
	RegisterHam(Ham_TakeDamage, "func_breakable", "ham_takedamage")
	
	RegisterHam(Ham_Spawn, "player", "ham_spawn_post", 1)
}

public plugin_precache()
{
	g_index_smoke = precache_model("sprites/effects/rainsplash.spr")
	g_index_shell = precache_model("models/rshell.mdl")
	
	precache_model(VIEW_MODEL)
	precache_model(PLAYER_MODEL)
	precache_model(WORLD_MODEL)
	precache_model(SPECIAL_MODEL)
	
	precache_sound(SHOOT_SOUND)	
	precache_sound(SHOOT_EX_SOUND)	
	
	precache_sound(EXPLODE_SOUND)	
	
	g_index_explosion = precache_model("sprites/csozm/m79_explosion.spr")
	
	g_index_trail = precache_model("sprites/zbeam2.spr")
	g_index_smoke = precache_model("sprites/effects/rainsplash.spr")
	g_index_smoke_2 = precache_model("sprites/black_smoke3.spr")
	g_index_gibs = precache_model("models/ceilinggibs.mdl")
		
	precache_sound("weapons/svdex_clipout.wav")
	precache_sound("weapons/svdex_clipin.wav")
	precache_sound("weapons/svdex_clipon.wav")
	precache_sound("weapons/svdex_draw.wav")
	precache_sound("weapons/svdex_foley1.wav")
	precache_sound("weapons/svdex_foley2.wav")
	precache_sound("weapons/svdex_foley3.wav")
		
	precache_generic("sprites/csozm/640hud7.spr")
	precache_generic("sprites/csozm/640hud36.spr")
	precache_generic("sprites/csozm/640hud41.spr")
	precache_generic("sprites/csozm/svdex_scope.spr")
	precache_generic("sprites/weapon_svdex_csozm.txt")
	precache_generic("sprites/weapon_svdex_2_csozm.txt") 
	register_clcmd("weapon_svdex_csozm", "clcmd_weapon_svdex")
	register_clcmd("weapon_svdex_2_csozm", "clcmd_weapon_svdex")
	
	register_message(78, "message_weaponlist")
	register_forward(FM_PrecacheEvent, "fm_precacheevent_post", 1)
}

public plugin_natives()
{
	register_native("give_weapon_svdex", "native_give_weapon", 1)
	register_native("has_weapon_svdex", "native_has_weapon", 1)
}

public client_connect(id) 
{
	g_has_svdex[id] = false
} 

public client_disconnect(id) 
{
	g_has_svdex[id] = false
}
public fw_PlayerSpawn_Post(id)
{
	g_has_svdex[id] = false
}
public ham_spawn_post(id) 
{
	if(!return_has_weapon(id, "weapon_m249")) 
		g_has_svdex[id] = false
}

public native_give_weapon(id) 
{
	give_svdex(id)
}

public native_has_weapon(id)
{
	return g_has_svdex[id]
}

public give_svdex(id)
{
	drop_weapons(id, 1)
	
	g_has_svdex[id] = true
	g_mode[id] = 0
	
	g_grenades[id] = CLIP_EX
	
	new weapon = give_item(id, "weapon_m249")

	if(weapon)
	{
		g_clipammo_save[id] = CLIP
		g_ammo_save[id] = AMMO
		
		cs_set_weapon_ammo(weapon, g_clipammo_save[id])
		cs_set_user_bpammo(id, CSW_M249, g_ammo_save[id])
	}
	
	ExecuteHamB(Ham_Item_Deploy, id)
}

public fm_precacheevent_post(type, const name[])
{
	if(equal("events/m249.sc", name))
	{
		g_orig_event_m249 = get_orig_retval()
		return FMRES_HANDLED	
	}
	return FMRES_IGNORED
}

public fm_setmodel(entity, model[])
{
	if(!is_valid_ent(entity))
		return FMRES_IGNORED

	static id, Ent
	
	id = entity_get_edict(entity, EV_ENT_owner)
	Ent = find_ent_by_owner(-1, "weapon_m249", entity)
		
	if(!equal(model, "models/w_m249.mdl") || !is_valid_ent(Ent) || !g_has_svdex[id])
		return FMRES_IGNORED

	entity_set_int(Ent, EV_INT_impulse, WEAPON_NUMBER)	
	entity_set_model(entity, WORLD_MODEL)
	set_pev(entity, pev_body, 14)
	
	g_has_svdex[id] = false
	
	g_mode[id] = false
	g_change[id] = false
	
	bartime(id, 0.0)
	remove_task(id)
	
	set_pdata_int(id, 51, g_clipammo_save[id], 4)
	g_ammo_save[id] = cs_get_user_bpammo(id, CSW_M249)
	
	return FMRES_SUPERCEDE
}

public fm_updateclientdata_post(id, SendWeapons, CD_Handle)
{
	if(!is_user_alive(id) || !is_user_connected(id) || get_user_weapon(id) != CSW_M249 || !g_has_svdex[id])
		return FMRES_IGNORED
	
	set_cd(CD_Handle, CD_flNextAttack, halflife_time() + 0.001)
		
	return FMRES_HANDLED
}

public fm_playbackevent(flags, id, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if (eventid != g_orig_event_m249 || !g_primaryattack[id] || !(1 <= id <= get_maxplayers()))
		return FMRES_IGNORED

	playback_event(flags | FEV_HOSTONLY, id, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
	
	return FMRES_SUPERCEDE
}

public fm_cmdstart(id, uc_handle, seed)
{
	if(!is_user_alive(id) || !is_user_connected(id) || get_user_weapon(id) != CSW_M249 || !g_has_svdex[id])
		return FMRES_IGNORED
		
	if(get_pdata_float(id, 83, 5) > 0.0) 
		return FMRES_IGNORED
	
	if((get_uc(uc_handle, UC_Buttons) & IN_ATTACK2) && !(pev(id, pev_oldbuttons) & IN_ATTACK2)) 
	{
		if(!g_mode[id])
		{
			g_change[id] = 1
			set_task(1.5, "set_mode", id)
			set_pdata_float(id, 83, 1.5, 5)
			
			play_weapon_animation(id, ANIM_CHANGE)
						
			bartime(id, 1.4)
			
			new weapon_entity = find_ent_by_owner (-1, "weapon_m249", id)
			new iClip = get_pdata_int(weapon_entity, 51, 4)
						
			g_clipammo_save[id] = iClip
			g_ammo_save[id] = cs_get_user_bpammo(id, CSW_M249)
		
		}
		else if(g_mode[id])
		{
			g_change[id] = 1
			set_task(1.5, "clear_mode", id)
			set_pdata_float(id, 83, 1.5, 5)
			
			play_weapon_animation(id, ANIM_CHANGE_EX)
						
			bartime(id, 1.4)
		}
	}
	return FMRES_IGNORED
}

public set_mode(id)
{
	if(!g_change[id] || !is_user_connected(id) || !is_user_alive(id)) 
		return
	
	g_mode[id] = 1
	g_change[id] = 0
	
	set_weaplist(id, "weapon_svdex_2_csozm")
	
	new weapon_entity = find_ent_by_owner (-1, "weapon_m249", id)
	
	set_pdata_int(weapon_entity, 51, g_grenades[id], 4)
	
	play_weapon_animation(id, ANIM_IDLE_EX)
	
	message_begin(MSG_ONE, get_user_msgid("HideWeapon"), {0,0,0}, id)
	{
		write_byte(1<<6)
	}
	message_end()
	
	message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, id)
	{
		write_byte(89)
	}
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("CurWeapon"), {0,0,0}, id)
	{
		write_byte(true)
		write_byte(g_m249_variables[8])
		write_byte(-1)
	}
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoX"), {0,0,0}, id)
	{
		write_byte(g_m249_variables[2])
		write_byte(g_grenades[id])
	}
	message_end()
}

public clear_mode(id)
{
	if(!g_change[id]) 
		return
			
	g_mode[id] = 0
	g_change[id] = 0
	
	set_weaplist(id, "weapon_svdex_csozm")
	
	new weapon_entity = find_ent_by_owner (-1, "weapon_m249", id)
	new iClip = get_pdata_int(weapon_entity, 51, 4)
	
	set_pdata_int(weapon_entity, 51, g_clipammo_save[id], 4)
	
	message_begin(MSG_ONE, get_user_msgid("HideWeapon"), {0,0,0}, id)
	{
		write_byte(1>>6)
	}
	message_end()
	
	message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, id)
	{
		write_byte(90)
	}
	message_end()
	
	message_begin(MSG_ONE, get_user_msgid("CurWeapon"), {0,0,0}, id)
	{
		write_byte(true)
		write_byte(g_m249_variables[8])
		write_byte(iClip)
	}
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoX"), {0,0,0}, id)
	{
		write_byte(g_m249_variables[2])
		write_byte(g_ammo_save[id])
	}
	message_end()
	
	play_weapon_animation(id, ANIM_IDLE)
}

public message_deathmsg(msg_id, msg_dest, id)
{
	static szTruncatedWeapon[33], attacker, victim
	attacker = get_msg_arg_int(1)
	victim = get_msg_arg_int(2)
	get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon))
	
	if(!is_user_connected(attacker) || attacker == victim || !equal(szTruncatedWeapon, "m249") || get_user_weapon(attacker) != CSW_M249 || !g_has_svdex[attacker])
		return PLUGIN_CONTINUE
	
	set_msg_arg_string(4, "svdex")
	
	return PLUGIN_CONTINUE
}

public message_weappickup(msg_id, msg_dest, id)
{
	if(!is_user_connected(id) || get_msg_arg_int(1) != CSW_M249 || !g_has_svdex[id])
		return PLUGIN_CONTINUE

	set_weaplist(id, "weapon_svdex_csozm")
	
	return PLUGIN_CONTINUE
}

public message_ammox(msg_id, msg_dest, id)
{
	if(!is_user_connected(id) || !g_has_svdex[id] || !g_mode[id] || get_user_weapon(id) != CSW_M249 || get_msg_arg_int(1) != g_m249_variables[2])
		return PLUGIN_CONTINUE

	set_msg_arg_int(1, ARG_BYTE, g_grenades[id])
	
	return PLUGIN_CONTINUE
}

public message_curweapon(msg_id, msg_dest, id)
{
	if(!is_user_connected(id) || get_msg_arg_int(2) != CSW_M249 || !g_has_svdex[id] || !g_mode[id])
		return PLUGIN_CONTINUE

	set_msg_arg_int(3, ARG_BYTE, -1)
	
	return PLUGIN_CONTINUE
}

public message_weaponlist(msg_id, msg_dest, id)
{
	if(get_msg_arg_int(8) != CSW_M249)
		return PLUGIN_CONTINUE;
	
	g_m249_variables[2] = get_msg_arg_int(2)
	g_m249_variables[3] = get_msg_arg_int(3)
	g_m249_variables[4] = get_msg_arg_int(4)
	g_m249_variables[5] = get_msg_arg_int(5)
	g_m249_variables[6] = get_msg_arg_int(6)
	g_m249_variables[7] = get_msg_arg_int(7)
	g_m249_variables[8] = get_msg_arg_int(8)
	g_m249_variables[9] = get_msg_arg_int(9)
	
	return PLUGIN_CONTINUE;
}

public set_weaplist(index, const string_msg[])
{
	message_begin(MSG_ONE, get_user_msgid("WeaponList"), {0,0,0}, index)
	{
		write_string(string_msg) 
		write_byte(g_m249_variables[2])
		write_byte(g_m249_variables[3])
		write_byte(g_m249_variables[4])
		write_byte(g_m249_variables[5])
		write_byte(g_m249_variables[6])
		write_byte(g_m249_variables[7])
		write_byte(g_m249_variables[8])
		write_byte(g_m249_variables[9])
	}
	message_end()
}

public clcmd_weapon_svdex(id)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE
	
	engclient_cmd(id, "weapon_m249")
	
	return PLUGIN_HANDLED
}

public ham_item_addtoplayer(entity, id)
{
	if(entity_get_int(entity, EV_INT_impulse) != WEAPON_NUMBER)
	{
		set_weaplist(id, "weapon_m249")
		return HAM_IGNORED
	}

	entity_set_int(entity, EV_INT_impulse, 0)
	
	g_has_svdex[id] = true
	
	return HAM_HANDLED
}

public ham_item_deploy_post(weapon_ent)
{
	static id; id = get_pdata_cbase(weapon_ent, 41, 4)
	
	if(!is_user_connected(id) || !g_has_svdex[id])
		return HAM_IGNORED
	
	set_pev(id, pev_viewmodel2, VIEW_MODEL)
	set_pev(id, pev_weaponmodel2, PLAYER_MODEL)
	
	play_weapon_animation(id, ANIM_DRAW)
	set_pdata_float(id, 83, TIME_DRAW, 5)
	
	g_primaryattack[id] = 0
	g_change[id] = 0
	
	g_mode[id] = 0
	
	set_pdata_int(weapon_ent, 51, g_clipammo_save[id], 4)
	
	bartime(id, 0.0)
	remove_task(id)
	
	message_begin(MSG_ONE, get_user_msgid("HideWeapon"), {0,0,0}, id)
	{
		write_byte(1>>6)
	}
	message_end()
	
	message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, id)
	{
		write_byte(90)
	}
	message_end()
	
	set_weaplist(id, "weapon_svdex_csozm")
	
	return HAM_IGNORED
}

public ham_item_holster_post(weapon_ent)
{
	static id; id = get_pdata_cbase(weapon_ent, 41, 4)
	
	if(!is_user_connected(id) || !g_has_svdex[id])
		return HAM_IGNORED
	
	g_ammo_save[id] = cs_get_user_bpammo(id, CSW_M249)
	
	g_primaryattack[id] = 0
	g_change[id] = 0
	
	g_mode[id] = 0
	
	bartime(id, 0.0)
	remove_task(id)
	
	message_begin(MSG_ONE, get_user_msgid("HideWeapon"), {0,0,0}, id)
	{
		write_byte(1>>6)
	}
	message_end()
	
	message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0,0,0}, id)
	{
		write_byte(90)
	}
	message_end()
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoX"), {0,0,0}, id)
	{
		write_byte(g_m249_variables[2])
		write_byte(g_ammo_save[id])
	}
	message_end()
	
	return HAM_IGNORED
}

public ham_item_preframe(weapon_entity) 
{
	new id; id = pev(weapon_entity, pev_owner)
	 
	if (!is_user_connected(id) || !g_has_svdex[id])
		return HAM_IGNORED
	
	new iBpAmmo = cs_get_user_bpammo(id, CSW_M249)
	new iClip = get_pdata_int(weapon_entity, 51, 4)
	new g_reload = get_pdata_int(weapon_entity, 54, 4) 

	if(g_reload && get_pdata_float(id, 83, 5) <= 0.0)
	{
		new j = min(CLIP - iClip, iBpAmmo)

		set_pdata_int(weapon_entity, 51, iClip + j, 4)
		cs_set_user_bpammo(id, CSW_M249, iBpAmmo - j)
		
		set_pdata_int(weapon_entity, 54, 0, 4)
		g_reload = 0
		
		g_clipammo_save[id] = (iClip + j)
	}
	
	return HAM_IGNORED
}

public ham_weapon_weaponidle(weapon_entity)
{
	new id = get_pdata_cbase(weapon_entity, 41, 4)
	
	if (!is_user_connected(id) || !g_has_svdex[id] || !g_mode[id])
		return HAM_IGNORED
	
	return HAM_SUPERCEDE
}

public ham_weapon_primaryattack(weapon_entity)
{
	new id = get_pdata_cbase(weapon_entity, 41, 4)
	
	if (!is_user_connected(id) || !g_has_svdex[id])
		return HAM_IGNORED
		
	if(pev(id, pev_oldbuttons) & IN_ATTACK2 || g_change[id])
		return HAM_SUPERCEDE
	
	g_primaryattack[id] = 1
	g_clipammo[id] = get_pdata_int(weapon_entity, 51, 4)

	return HAM_IGNORED
}

public ham_weapon_primaryattack_post(weapon_entity)
{
	new id = get_pdata_cbase(weapon_entity, 41, 4)
	
	if (!is_user_connected(id) || !g_has_svdex[id])
		return HAM_IGNORED
	
	if((get_pdata_int(weapon_entity, 51, 4) < g_clipammo[id]) && g_primaryattack[id])
	{
		g_clipammo[id] = get_pdata_int(weapon_entity, 51, 4)
		
		if(!g_mode[id]) g_clipammo_save[id] = get_pdata_int(weapon_entity, 51, 4)
		else g_grenades[id] = get_pdata_int(weapon_entity, 51, 4)
		
		g_primaryattack[id] = 0
		
		new Float:push[3], Float:cl_pushangle[33], g_duckle[33]
		
		if((pev(id, pev_flags) & (FL_DUCKING | FL_ONGROUND) == (FL_DUCKING | FL_ONGROUND)))
			g_duckle[id] = true
		else
			g_duckle[id] = false
		
		pev(id, pev_punchangle, push)
		xs_vec_sub(push,cl_pushangle[id],push)
		
		xs_vec_mul_scalar(push, (!g_mode[id] ? (!g_duckle[id] ? RECOIL : RECOIL * 0.5) : (!g_duckle[id] ? RECOIL_EX : RECOIL_EX * 0.5)), push)
		xs_vec_add(push,cl_pushangle[id],push)
		set_pev(id,pev_punchangle,push)
		
		emit_sound(id, CHAN_WEAPON, !g_mode[id] ? SHOOT_SOUND : SHOOT_EX_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM) 
		
		if(!g_mode[id]) EjectBrass(id, g_index_shell)
		
		play_weapon_animation(id, !g_mode[id] ? random_num(ANIM_SHOOT_1, ANIM_SHOOT_2) : g_grenades[id] ? ANIM_SHOOT_EX_1 : ANIM_SHOOT_EX_2)
		
		set_pdata_float(weapon_entity, 46, RATE_OF_FIRE / (!g_mode[id] ? 250.0 : (g_grenades[id] ? 35.0 : 500.0)), 4)
		
		if(g_mode[id]) 
		{
			weapon_primaryattack_two_post(id)
			
			message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("AmmoX"), {0,0,0}, id)
			{
				write_byte(g_m249_variables[2])
				write_byte(g_grenades[id])
			}
			message_end()
		}
	}
	return HAM_IGNORED
}

public weapon_primaryattack_two_post(id)
{
	new Float:fAngle[3], Float:fVelocity[3]
	pev(id, pev_v_angle, fAngle)
	
	new grenade = create_entity("info_target")
	
	if (!grenade) 
		return PLUGIN_HANDLED
	
	entity_set_string(grenade, EV_SZ_classname, "svdex_grenade")
	
	entity_set_model(grenade, SPECIAL_MODEL)
	
	new Float:vOrigin[3]
	pev(id, pev_origin, vOrigin)
	
	static Float:plrViewAngles[3], Float:VecEnd[3], Float:VecDir[3], Float:PlrOrigin[3]; 
   	pev(id, pev_v_angle, plrViewAngles); 

    	static Float:VecSrc[3], Float:VecDst[3]
	     
    	pev(id, pev_origin, PlrOrigin) 
    	pev(id, pev_view_ofs, VecSrc) 
    	xs_vec_add(VecSrc, PlrOrigin, VecSrc)  
		
    	angle_vector(plrViewAngles, ANGLEVECTOR_FORWARD, VecDir); 
    	xs_vec_mul_scalar(VecDir, 8192.0, VecDst); 
    	xs_vec_add(VecDst, VecSrc, VecDst); 
    		
    	new hTrace = create_tr2() 
    	engfunc(EngFunc_TraceLine, VecSrc, VecDst, 0, id, hTrace) 
    	get_tr2(hTrace, TR_vecEndPos, VecEnd);
    	
	static Float:origin[3], Float:angles[3], Float:v_forward[3], Float:v_right[3], Float:v_up[3], Float:gun_position[3], Float:player_origin[3], Float:player_view_offset[3]; 
	pev(id, pev_v_angle, angles); 
	engfunc(EngFunc_MakeVectors, angles); 
	global_get(glb_v_forward, v_forward); 
	global_get(glb_v_right, v_right); 
	global_get(glb_v_up, v_up); 

	pev(id, pev_origin, player_origin); 
	pev(id, pev_view_ofs, player_view_offset); 
	xs_vec_add(player_origin, player_view_offset, gun_position); 

	xs_vec_mul_scalar(v_forward, 18.0, v_forward);
	xs_vec_mul_scalar(v_up, -3.8, v_up);
	xs_vec_mul_scalar(v_right, 6.0, v_right);
    
	xs_vec_add(gun_position, v_forward, origin); 
	xs_vec_add(origin, v_right, origin); 
	xs_vec_add(origin, v_up, origin); 
	
	vOrigin[0] = origin[0]
	vOrigin[1] = origin[1]
	vOrigin[2] = origin[2]
	
	entity_set_origin(grenade, vOrigin)
	
	entity_set_vector(grenade, EV_VEC_angles, fAngle)
	
	new Float:MinBox[3] = {-1.0, -1.0, -1.0}
	new Float:MaxBox[3] = {1.0, 1.0, 1.0}
	entity_set_vector(grenade, EV_VEC_mins, MinBox)
	entity_set_vector(grenade, EV_VEC_maxs, MaxBox)
	
	entity_set_int(grenade, EV_INT_solid, SOLID_SLIDEBOX)
	
	entity_set_int(grenade, EV_INT_movetype, MOVETYPE_TOSS)
	
	entity_set_edict(grenade, EV_ENT_owner, id)
		
	VelocityByAim(id, random_num(1900, 2300), fVelocity)
	
	entity_set_vector(grenade, EV_VEC_velocity, fVelocity)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW)
	write_short(grenade)
	write_short(g_index_trail)
	write_byte(6)
	write_byte(3)
	write_byte(255)
	write_byte(255)
	write_byte(255)
	write_byte(random_num(75, 85))
	message_end()
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, vOrigin[0])
	engfunc(EngFunc_WriteCoord, vOrigin[1]) 
	engfunc(EngFunc_WriteCoord, vOrigin[2])
	write_short(g_index_smoke)
	write_byte(2)
	write_byte(random_num(100, 130))
	message_end()
	
	return PLUGIN_HANDLED
}

public touch_svdex_grenade(ent, touched) 
{
	if (!pev_valid(ent))
		return PLUGIN_HANDLED
		
	static Float:origin[3]
	pev(ent, pev_origin, origin)
	new owner = pev(ent, pev_owner)
	
	new victim = -1
	
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, EXPLODE_RADIUS)) != 0)
	{	
		new victim_origin[3], distance, distance_damage, floated_origin[3], distance_effects
		
		floated_origin[0] = floatround(origin[0])
		floated_origin[1] = floatround(origin[1])
		floated_origin[2] = floatround(origin[2])

		if(is_user_connected(victim) && is_user_alive(victim) && cso_get_user_zombie(victim))
		{
			get_user_origin(victim, victim_origin)
			
			distance = get_distance(victim_origin, floated_origin)
			distance_damage = floatround(EXPLODE_DAMAGE) - floatround(floatmul(EXPLODE_DAMAGE, floatdiv(float(distance), EXPLODE_RADIUS)))
			distance_effects = 10 - floatround(floatmul(float(10), floatdiv(float(distance), EXPLODE_RADIUS)))
		
			new health = get_user_health(victim)
							
			if(health <= distance_damage)
			{
				if(is_user_connected(owner))
				{
					make_death_message(owner, victim)
				
					set_msg_block(get_user_msgid("DeathMsg"), BLOCK_ONCE)
					set_msg_block(get_user_msgid("ScoreInfo"), BLOCK_ONCE)
					
					ExecuteHam(Ham_Killed, victim, owner, 2)
				}
			}
			else
			{
				if(is_user_connected(owner)) ExecuteHam(Ham_TakeDamage, victim, "weapon_m249", owner, float(distance_damage), DMG_BLAST)
				
				message_begin(MSG_PVS, SVC_TEMPENTITY, victim_origin) 
				write_byte(TE_BLOODSTREAM) 
				write_coord(victim_origin[0]) 
				write_coord(victim_origin[1]) 
				write_coord(victim_origin[2] + 10) 
				write_coord(random_num(-360, 360)) // x 
				write_coord(random_num(-360, 360)) // y 
				write_coord(-10) // z 
				write_byte(70) // color 
				write_byte(random_num(50, 100)) // speed 
				message_end()
				
				message_begin(MSG_PVS, SVC_TEMPENTITY, victim_origin) 
				write_byte(TE_WORLDDECAL) 
				write_coord(victim_origin[0] + random_num(-100, 100)) 
				write_coord(victim_origin[1] + random_num(-100, 100)) 
				write_coord(victim_origin[2] - 36) 
				write_byte(random_num(190, 197)) // index 
				message_end() 
				
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, victim)
				write_short((1<<12) * distance_effects)
				write_short(0)
				write_short(0x0000)
				write_byte(255)
				write_byte(0)
				write_byte(0)
				write_byte(150)
				message_end()
				
				message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, victim)
				write_short((1<<12) * distance_effects) // Amount
				write_short((1<<12) * distance_effects) // Duration
				write_short((1<<12) * distance_effects) // Frequency
				message_end()
			}
		}
		
		if(pev_valid(victim) && !is_user_connected(victim))
			Breakobject(ent, distance_damage)
	}
	
	if(!is_user_connected(touched))
		make_metal_gibs(ent)
	
	make_boom(ent)
	engfunc(EngFunc_RemoveEntity, ent)
	
	return PLUGIN_CONTINUE
}

public Breakobject(id, dmg)
{
	new Float:Origin[3]
	pev(id, pev_origin, Origin)
 
	new ent = FM_NULLENT
	while((ent = find_ent_in_sphere(ent, Origin, EXPLODE_RADIUS)) != 0)
	{
		if(pev_valid(ent) && ent != id && !is_user_connected(ent) && !is_user_alive(ent) && pev(ent,pev_takedamage) != DAMAGE_NO)
			force_use(id, ent)
	}
}

public make_boom(ent)
{
	static Float:flOrigin[3]
	pev(ent, pev_origin, flOrigin)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, flOrigin, 0)
	write_byte (TE_DLIGHT)
	engfunc(EngFunc_WriteCoord, flOrigin[0])
	engfunc(EngFunc_WriteCoord, flOrigin[1])
	engfunc(EngFunc_WriteCoord, flOrigin[2])
	write_byte(30)
	write_byte(255)
	write_byte(0)
	write_byte(0)
	write_byte(255)
	write_byte(60)
	write_byte(20)
	message_end()
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SMOKE) // Temporary entity IF
	engfunc(EngFunc_WriteCoord, flOrigin[0]) // Pos X
	engfunc(EngFunc_WriteCoord, flOrigin[1]) // Pos Y
	engfunc(EngFunc_WriteCoord, flOrigin[2]) // Pos Z
	write_short(g_index_smoke_2) // Sprite index
	write_byte(28) // Scale
	write_byte(17) // Framerate
	message_end()
			
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, flOrigin, 0)
	write_byte(TE_WORLDDECAL)
	engfunc(EngFunc_WriteCoord, flOrigin[0])
	engfunc(EngFunc_WriteCoord, flOrigin[1])
	engfunc(EngFunc_WriteCoord, flOrigin[2])
	write_byte(engfunc(EngFunc_DecalIndex, "{scorch3"))
	message_end()
			
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION) // Temporary entity ID
	engfunc(EngFunc_WriteCoord, flOrigin[0]) // engfunc because float
	engfunc(EngFunc_WriteCoord, flOrigin[1])
	engfunc(EngFunc_WriteCoord, flOrigin[2] + 39)
	write_short(g_index_explosion) // Sprite index
	write_byte(40) // Scale
	write_byte(15) // Framerate
	write_byte(0) // Flags
	message_end()
	
	engfunc(EngFunc_EmitSound, ent, CHAN_WEAPON, EXPLODE_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public make_metal_gibs(ent)
{
	static Float:flOrigin[3]
	pev(ent, pev_origin, flOrigin)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(TE_BREAKMODEL)
	engfunc(EngFunc_WriteCoord, flOrigin[0])
	engfunc(EngFunc_WriteCoord, flOrigin[1])
	engfunc(EngFunc_WriteCoord, flOrigin[2])
	engfunc(EngFunc_WriteCoord, 150)
	engfunc(EngFunc_WriteCoord, 150)
	engfunc(EngFunc_WriteCoord, 150)
	engfunc(EngFunc_WriteCoord, random_num(-50,50))
	engfunc(EngFunc_WriteCoord, random_num(-50,50))
	engfunc(EngFunc_WriteCoord, random_num(-50,50))
	write_byte(30)
	write_short(g_index_gibs)
	write_byte(random_num(20, 30))
	write_byte(20)
	write_byte(0x04) //0x02 - metal
	message_end()
}

public make_death_message(id, victim)
{
	set_user_frags(id, get_user_frags(id) + 1 )

	//Update killers scorboard with new info
	message_begin(MSG_ALL,get_user_msgid("ScoreInfo"))
	write_byte(id)
	write_short(get_user_frags(id))
	write_short(get_user_deaths(id))
	write_short(1)
	write_short(get_user_team(id))
	message_end()

	//Update victims scoreboard with correct info
	message_begin(MSG_ALL,get_user_msgid("ScoreInfo"))
	write_byte(victim)
	write_short(get_user_frags(victim))
	write_short(get_user_deaths(victim))
	write_short(0)
	write_short(get_user_team(victim))
	message_end()

	message_begin( MSG_ALL, get_user_msgid("DeathMsg"),{0,0,0},0)
	write_byte(id)
	write_byte(victim)
	write_byte(0)
	write_string("grenade")
	message_end()
}

public ham_weapon_reload(weapon_entity) 
{
	new id; id = pev(weapon_entity, pev_owner)
	
	if (!is_user_connected(id) || !g_has_svdex[id])
		return HAM_IGNORED

	new iBpAmmo = cs_get_user_bpammo(id, CSW_M249)
	new iClip = get_pdata_int(weapon_entity, 51, 4)

	if (iBpAmmo <= 0 || iClip >= CLIP || g_mode[id])
		return HAM_SUPERCEDE

	return HAM_IGNORED
}

public ham_weapon_reload_post(weapon_entity) 
{
	new id = pev(weapon_entity, pev_owner)
	
	if (!is_user_connected(id) || !g_has_svdex[id])
		return HAM_IGNORED
		
	new iBpAmmo = cs_get_user_bpammo(id, CSW_M249)
	new iClip = get_pdata_int(weapon_entity, 51, 4)

	if (iBpAmmo <= 0 || iClip >= CLIP || g_mode[id])
		return HAM_SUPERCEDE

	set_pdata_int(weapon_entity, 54, 1, 4)
	
	set_pdata_float(id, 83, TIME_RELOAD, 5)

	play_weapon_animation(id, ANIM_RELOAD)

	return HAM_IGNORED
}

public ham_traceattack(victim, attacker, Float:flDamage, Float:direction[3], ptr, damage_type)
{
	if(!is_user_connected(attacker) || !is_user_alive(attacker))
		return HAM_IGNORED
	
	if(get_user_weapon(attacker) != CSW_M249 || !g_has_svdex[attacker])
		return HAM_IGNORED
	
	if(!(damage_type & DMG_BULLET))
		return HAM_IGNORED
		
	if(g_mode[attacker])
		return HAM_SUPERCEDE
		
	return HAM_IGNORED
}

public ham_traceattack_post(victim, attacker, Float:flDamage, Float:direction[3], ptr, damage_type)
{
	if(!is_user_connected(attacker) || !is_user_alive(attacker))
		return HAM_IGNORED
	
	if(get_user_weapon(attacker) != CSW_M249 || !g_has_svdex[attacker])
		return HAM_IGNORED
	
	if(!(damage_type & DMG_BULLET))
		return HAM_IGNORED
		
	if(g_mode[attacker])
		return HAM_IGNORED
		
	static Float:flEnd[3]
	get_tr2(ptr, TR_vecEndPos, flEnd)
	
	if(!is_user_alive(victim))
	{
		if(victim)
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_DECAL)
			engfunc(EngFunc_WriteCoord, flEnd[0])
			engfunc(EngFunc_WriteCoord, flEnd[1])
			engfunc(EngFunc_WriteCoord, flEnd[2])
			write_byte(random_num(41, 45))
			write_short(victim) 
			message_end()
		}
		else
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			write_byte(TE_WORLDDECAL)
			engfunc(EngFunc_WriteCoord, flEnd[0])
			engfunc(EngFunc_WriteCoord, flEnd[1])
			engfunc(EngFunc_WriteCoord, flEnd[2])
			write_byte(random_num(41, 45))
			message_end()
		}
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)
		engfunc(EngFunc_WriteCoord, flEnd[0])
		engfunc(EngFunc_WriteCoord, flEnd[1])
		engfunc(EngFunc_WriteCoord, flEnd[2])
		write_short(attacker)
		write_byte(random_num(41, 45))
		message_end()
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_SPRITE)
		engfunc(EngFunc_WriteCoord, flEnd[0])
		engfunc(EngFunc_WriteCoord, flEnd[1]) 
		engfunc(EngFunc_WriteCoord, flEnd[2] + 3)
		write_short(g_index_smoke)
		write_byte(1)
		write_byte(50)
		message_end()
	}
	return HAM_IGNORED
}

public ham_takedamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(attacker) || victim == attacker)
		return HAM_IGNORED
		
	if(get_user_weapon(attacker) != CSW_M249 || !g_has_svdex[attacker])
		return HAM_IGNORED
		 
	if(!(damage_type & DMG_BULLET))
		return HAM_IGNORED
		
	if(g_mode[attacker]) 
	{
		SetHamParamFloat(4, 0.0)
		return HAM_SUPERCEDE
	}	
	
	SetHamParamFloat(4, damage * DAMAGE)
	
	return HAM_IGNORED
}

public EjectBrass(Player, iShellModelIndex)
{
	new  Float:upScale, Float:fwScale, Float:rgScale
	upScale = -10.0,
	fwScale = 15.0
	rgScale = 6.0
	
	static Float:vPunchAngle[ 3 ], Float:vAngle[ 3 ], xol
	xol = v_angle + punchangle
   
	if( xol & v_angle )   
		pev( Player, pev_v_angle, vAngle )
	   
	if( xol & punchangle )
		pev( Player, pev_punchangle, vPunchAngle )
   
	xs_vec_add(vAngle, vPunchAngle, vAngle)
	engfunc( EngFunc_MakeVectors, vAngle );
   
	static Float:vVel[ 3 ], Float:vOrigin[ 3 ], Float:vViewOfs[ 3 ],
	i, Float:vShellOrigin[ 3 ],  Float:vShellVelocity[ 3 ], Float:vRight[ 3 ],
	Float:vUp[ 3 ], Float:vForward[ 3 ];
	pev( Player, pev_velocity, vVel );
	pev( Player, pev_view_ofs, vViewOfs );
	pev( Player, pev_angles, vAngle );
	pev( Player, pev_origin, vOrigin );
	global_get( glb_v_right, vRight );
	global_get( glb_v_up, vUp );
	global_get( glb_v_forward, vForward );
   
	for( i = 0; i < 3; i++ )
	{
		vShellOrigin[i] = vOrigin[ i ] + vViewOfs[ i ] + vUp[ i ] * upScale + vForward[i] * fwScale + vRight[ i ] * rgScale;
		vShellVelocity[i] = vVel[ i ] + vRight[ i ] * random_float( 50.0, 70.0 ) + vUp[i] * random_float( 100.0, 150.0 ) + vForward[ i ] * 25.0;
	}
   
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vShellOrigin, 0)
	write_byte(TE_MODEL)
	engfunc(EngFunc_WriteCoord, vShellOrigin[0])
	engfunc(EngFunc_WriteCoord, vShellOrigin[1])
	engfunc(EngFunc_WriteCoord, vShellOrigin[2])   
	engfunc(EngFunc_WriteCoord, vShellVelocity[0])
	engfunc(EngFunc_WriteCoord, vShellVelocity[1])
	engfunc(EngFunc_WriteCoord, vShellVelocity[2])
	engfunc(EngFunc_WriteAngle, vAngle[ 1 ] )
	write_short(iShellModelIndex)
	write_byte(1)
	write_byte(25)
	message_end()
}

stock play_weapon_animation(const Player, const Sequence)
{
	set_pev(Player, pev_weaponanim, Sequence)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
	write_byte(Sequence)
	write_byte(pev(Player, pev_body))
	message_end()
}

stock drop_weapons(id, dropwhat)
{
	static weapons[32], wname[32], num, i, weaponid
	num = 0
	get_user_weapons(id, weapons, num)

	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i]

		if (dropwhat == 1 && ((1<<weaponid) & WEAPONS_BIT_SUM))
		{
			get_weaponname(weaponid, wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}

stock return_has_weapon(id, const findstring[])
{
	static weapons[32], wname[32], num, i, weaponid
	num = 0
	get_user_weapons(id, weapons, num)
	
	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i]
		get_weaponname(weaponid, wname, sizeof wname - 1)
		
		if(equal(wname, findstring)) 
			return 1;
	}
	return 0;
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
       
	return 1;
}

stock bartime(id, Float:value) 
{
	message_begin(MSG_ONE, get_user_msgid("BarTime"), _, id)
	write_short(floatround(value))
	message_end()
}

// only weapon index or its name can be passed, if neither is passed then the current gun will be stripped
stock bool:fm_strip_user_gun(index, wid = 0, const wname[] = "") {
	new ent_class[32];
	if (!wid && wname[0])
		copy(ent_class, sizeof ent_class - 1, wname);
	else {
		new weapon = wid, clip, ammo;
		if (!weapon && !(weapon = get_user_weapon(index, clip, ammo)))
			return false;
		
		get_weaponname(weapon, ent_class, sizeof ent_class - 1);
	}

	new ent_weap = find_ent_by_owner(-1, ent_class, index);
	if (!ent_weap)
		return false;

	engclient_cmd(index, "drop", ent_class);

	new ent_box = pev(ent_weap, pev_owner);
	if (!ent_box || ent_box == index)
		return false;

	dllfunc(DLLFunc_Think, ent_box);

	return true;
}
