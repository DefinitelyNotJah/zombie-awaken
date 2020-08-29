#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <cstrike>
#include <fun>

#define PLUGIN "[CSO] Weapon: Skull-3 (Double Weapon)"
#define VERSION "2014"
#define AUTHOR "Dias Pendragon"

#define EV_INT_WEAPONKEY	EV_INT_impulse

#define DAMAGE_S 27 // 54 for Zombie

#define SPEED_S 1.25

#define CLIP_S 35

#define BPAMMO 240

#define CSW_SKULL3S CSW_MP5NAVY
#define weapon_skull3s "weapon_mp5navy"

#define TIME_CHANGE 3.0

#define PSPEED_S 240.0

#define ANIM_EXT1 "carbine"

#define WEAPON_CODE 1972

#define skull3_WEAPONKEY 	899

#define MODEL_V "models/v_skull3.mdl"
#define MODEL_P "models/p_skull3.mdl"
#define MODEL_W "models/zm_cso/w_primarynew.mdl"

new const Skull3_Sounds[5][] = 
{
	"weapons/skull3_shoot.wav",
	"weapons/skull3_shoot_2.wav",
	"weapons/skull3_idle.wav",
	"weapons/skull3_clipin.wav",
	"weapons/skull3_boltpull.wav"
}

new const Skull3_Resources[3][] =
{
	"sprites/weapon_skull3.txt",
	"sprites/skull3_hud.spr",
	"sprites/skull3_ammo.spr"
}

enum
{
	SKULL3_SINGLE = 1
}

enum
{
	ANIM_IDLE = 0,
	ANIM_RELOAD,
	ANIM_DRAW,
	ANIM_SHOOT1,
	ANIM_SHOOT2,
	ANIM_SHOOT3,
	ANIM_SWITCH
}

// MACROS
#define Get_BitVar(%1,%2) (%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2) %1 |= (1 << (%2 & 31))
#define UnSet_BitVar(%1,%2) %1 &= ~(1 << (%2 & 31))

const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_MAC10)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_MAC10)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)

new g_Had_Skull3
new g_Skull3_Mode[33], g_Skull3_BPAmmo[33], g_Skull3_Clip[33]
new g_MsgWeaponList, g_MsgCurWeapon
new g_Event_Skull3S, g_ShellId, g_SmokePuff_SprId

new Bastard[512]

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")

	RegisterHam(Ham_Item_AddToPlayer, weapon_skull3s, "fw_skull3_AddToPlayer")
	
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)	
	register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")	
	register_forward(FM_SetModel, "fw_SetModel")	
	
	register_touch("skull3", "*", "fw_Skull3_Touch")
	register_think("skull3", "fw_Skull3_Think")

	RegisterHam(Ham_Item_Deploy, weapon_skull3s, "fw_Skull3S_Deploy_Post", 1)
	RegisterHam(Ham_Item_PostFrame, weapon_skull3s, "fw_Skull3S_PostFrame")	
	RegisterHam(Ham_Weapon_Reload, weapon_skull3s, "fw_Skull3S_Reload")
	RegisterHam(Ham_Weapon_Reload, weapon_skull3s, "fw_Skull3S_Reload_Post", 1)	
	
	RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack_World")
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack_Player")		
	
	g_MsgWeaponList = get_user_msgid("WeaponList")
	g_MsgCurWeapon = get_user_msgid("CurWeapon")
	
	// Weapon Hook
	register_clcmd("weapon_skull3", "Hook_Skull3S")
}

public plugin_precache()
{
	engfunc(EngFunc_PrecacheModel, MODEL_V)
	engfunc(EngFunc_PrecacheModel, MODEL_P)
	engfunc(EngFunc_PrecacheModel, MODEL_W)
	
	for(new i = 0; i < sizeof(Skull3_Sounds); i++)
		engfunc(EngFunc_PrecacheSound, Skull3_Sounds[i])
		
	for(new i = 0; i < sizeof(Skull3_Resources); i++)
	{
		if(i == 0 || i == 1) engfunc(EngFunc_PrecacheGeneric, Skull3_Resources[i])
		else engfunc(EngFunc_PrecacheModel, Skull3_Resources[i])
	}
	
	g_ShellId = engfunc(EngFunc_PrecacheModel, "models/pshell.mdl")
	g_SmokePuff_SprId = engfunc(EngFunc_PrecacheModel, "sprites/wall_puff1.spr")
	
	register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1)
}
public plugin_natives ()
{
	register_native("give_weapon_skull3", "native_give_weapon_add", 1)
}
public native_give_weapon_add(id)
{
	if(!is_user_alive(id))	
		return
		
	drop_weapons(id)
	
	Set_BitVar(g_Had_Skull3, id)
	
	g_Skull3_Mode[id] = SKULL3_SINGLE
	g_Skull3_BPAmmo[id] = BPAMMO
	
	give_item(id, weapon_skull3s)
	
	static Ent;
	
	Ent = fm_get_user_weapon_entity(id, CSW_SKULL3S)
	if(pev_valid(Ent)) cs_set_weapon_ammo(Ent, CLIP_S)
	
	cs_set_user_bpammo(id, CSW_SKULL3S, g_Skull3_BPAmmo[id])
	
	Update_AmmoHud(id, CSW_SKULL3S, CLIP_S)

	message_begin(MSG_ONE_UNRELIABLE, g_MsgWeaponList, _, id)
	write_string("weapon_skull3")
	write_byte(10)
	write_byte(120)
	write_byte(-1)
	write_byte(-1)
	write_byte(0)
	write_byte(7)
	write_byte(CSW_SKULL3S)
	message_end()	
}
public fw_skull3_AddToPlayer(skull3, id)
{
	if(!is_valid_ent(skull3) || !is_user_connected(id))
		return HAM_IGNORED
	
	if(entity_get_int(skull3, EV_INT_WEAPONKEY) == skull3_WEAPONKEY)
	{
		Set_BitVar(g_Had_Skull3, id)

		entity_set_int(skull3, EV_INT_WEAPONKEY, 0)
		
		g_Skull3_Mode[id] = SKULL3_SINGLE
		g_Skull3_BPAmmo[id] = BPAMMO
		
		Update_AmmoHud(id, CSW_SKULL3S, CLIP_S)

		message_begin(MSG_ONE_UNRELIABLE, g_MsgWeaponList, _, id)
		write_string("weapon_skull3")
		write_byte(10)
		write_byte(120)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(7)
		write_byte(CSW_SKULL3S)
		message_end()	
			
		return HAM_HANDLED
	}
	else
	{
		message_begin(MSG_ONE_UNRELIABLE, g_MsgWeaponList, _, id)
		write_string("weapon_mp5navy")
		write_byte(10)
		write_byte(120)
		write_byte(-1)
		write_byte(-1)
		write_byte(0)
		write_byte(7)
		write_byte(CSW_MP5NAVY)
		message_end()	
	}
	return HAM_IGNORED
}
public fw_PrecacheEvent_Post(type, const name[])
{
	if(equal("events/mp5n.sc", name)) g_Event_Skull3S = get_orig_retval()	
}
public Hook_Skull3S(id)
{
	engclient_cmd(id, weapon_skull3s)
}
public fw_Skull3_Touch(Skull3, id)
{
	if(!pev_valid(Skull3))
		return
	if(!is_user_alive(id))
		return
		
	set_pev(Skull3, pev_solid, SOLID_NOT)
		
	drop_weapons(id)
	
	Set_BitVar(g_Had_Skull3, id)
	
	g_Skull3_Mode[id] = SKULL3_SINGLE
	g_Skull3_BPAmmo[id] = pev(Skull3, pev_iuser3)
	
	give_item(id, weapon_skull3s)
	
	static Ent;
	
	Ent = fm_get_user_weapon_entity(id, CSW_SKULL3S)
	if(pev_valid(Ent)) cs_set_weapon_ammo(Ent, pev(Skull3, pev_iuser1))
	
	cs_set_user_bpammo(id, CSW_SKULL3S, g_Skull3_BPAmmo[id])
	
	Update_AmmoHud(id, CSW_SKULL3S, CLIP_S)
	
	set_pev(Skull3, pev_nextthink, get_gametime() + 0.05)

	message_begin(MSG_ONE_UNRELIABLE, g_MsgWeaponList, _, id)
	write_string("weapon_skull3")
	write_byte(10)
	write_byte(120)
	write_byte(-1)
	write_byte(-1)
	write_byte(0)
	write_byte(7)
	write_byte(CSW_SKULL3S)
	message_end()			
}

public fw_Skull3_Think(id)
{
	if(!pev_valid(id))
		return
		
	set_pev(id, pev_flags, pev(id, pev_flags) | FL_KILLME)
}

public Event_CurWeapon(id)
{
	if(!Get_BitVar(g_Had_Skull3, id))
		return
	
	static CSW; CSW = read_data(2)
	static Ent
	
	switch(CSW)
	{
		case CSW_SKULL3S:
		{
			Ent = fm_get_user_weapon_entity(id, CSW_SKULL3S)
			if(pev_valid(Ent))
			{
				static Float:Delay, Float:M_Delay
				Delay = get_pdata_float(Ent, 46, 4) * SPEED_S
				M_Delay = get_pdata_float(Ent, 47, 4) * SPEED_S
				if (Delay > 0.0)
				{
					set_pdata_float(Ent, 46, Delay, 4)
					set_pdata_float(Ent, 47, M_Delay, 4)
				}
			}	
			
			set_pev(id, pev_maxspeed, PSPEED_S)
		}
	}
	
	return
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
	if(!Get_BitVar(g_Had_Skull3, id))
		return FMRES_IGNORED
	if(get_user_weapon(id) == CSW_SKULL3S)
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 
	
	return FMRES_HANDLED
}

public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
	if(!is_user_connected(invoker))
		return FMRES_IGNORED	
	if(!Get_BitVar(g_Had_Skull3, invoker))
		return FMRES_IGNORED
		
	if(get_user_weapon(invoker) == CSW_SKULL3S && eventid == g_Event_Skull3S)
	{
		engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
		
		emit_sound(invoker, CHAN_WEAPON, Skull3_Sounds[0], 1.0, ATTN_NORM, 0, PITCH_NORM)	
		Set_WeaponAnim(invoker, random_num(ANIM_SHOOT1, ANIM_SHOOT3))
		Eject_Shell(invoker, g_ShellId, 0.01)
	}
	return FMRES_IGNORED
}

public fw_SetModel(entity, model[])
{
	if(!pev_valid(entity))
		return FMRES_IGNORED;
	
	static szClassName[33]
	pev(entity, pev_classname, szClassName, charsmax(szClassName))
	
	if(!equal(szClassName, "weaponbox"))
		return FMRES_IGNORED;
	
	static id; id = pev(entity, pev_owner)
	
	if(equal(model, "models/w_mp5.mdl"))
	{
		static weapon
		weapon = find_ent_by_owner(-1, weapon_skull3s, entity)	
		
		if(!pev_valid(weapon))
			return FMRES_IGNORED
		
		if(Get_BitVar(g_Had_Skull3, id))
		{
			UnSet_BitVar(g_Had_Skull3, id)

			Bastard[weapon] = WEAPON_CODE
			engfunc(EngFunc_SetModel, entity, MODEL_W)

			entity_set_int(weapon, EV_INT_WEAPONKEY, skull3_WEAPONKEY)

			set_pev(entity, pev_body, 29)

			return FMRES_SUPERCEDE
		}
	} 
	return FMRES_IGNORED;
}
public fw_Skull3S_Deploy_Post(Ent)
{
	if(pev_valid(Ent) != 2)
		return
	static Id; Id = get_pdata_cbase(Ent, 41, 4)
	if(get_pdata_cbase(Id, 373) != Ent)
		return
	if(!Get_BitVar(g_Had_Skull3, Id))
		return

	set_pev(Id, pev_viewmodel2, MODEL_V)
	set_pev(Id, pev_weaponmodel2, MODEL_P)
	
	set_pdata_string(Id, (492) * 4, ANIM_EXT1, -1 , 20)

	Set_WeaponAnim(Id, ANIM_DRAW)

	static CSW; CSW = get_user_weapon(Id)
	if(CSW == CSW_SKULL3S)
	{
		g_Skull3_Mode[Id] = SKULL3_SINGLE
		Set_WeaponAnim(Id, ANIM_IDLE)
	}

	set_pev(Id, pev_maxspeed, PSPEED_S)
}
public fw_Skull3S_PostFrame(ent)
{
	static id; id = pev(ent, pev_owner)
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(!Get_BitVar(g_Had_Skull3, id))
		return HAM_IGNORED	
	
	static Float:flNextAttack; flNextAttack = get_pdata_float(id, 83, 5)
	static bpammo; bpammo = g_Skull3_BPAmmo[id]
	
	static iClip; iClip = get_pdata_int(ent, 51, 4)
	static fInReload; fInReload = get_pdata_int(ent, 54, 4)
	
	if(fInReload && flNextAttack <= 0.0)
	{
		static temp1
		temp1 = min(CLIP_S - iClip, bpammo)

		set_pdata_int(ent, 51, iClip + temp1, 4)
		
		Set_Skull3_BPAmmo(id, bpammo - temp1)
		set_pdata_int(ent, 54, 0, 4)
		
		fInReload = 0
	}		
	
	return HAM_IGNORED
}

public fw_Skull3S_Reload(ent)
{
	static id; id = pev(ent, pev_owner)
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(!Get_BitVar(g_Had_Skull3, id))
		return HAM_IGNORED	

	g_Skull3_Clip[id] = -1
		
	static BPAmmo; BPAmmo = g_Skull3_BPAmmo[id]
	static iClip; iClip = get_pdata_int(ent, 51, 4)
		
	if(BPAmmo <= 0)
		return HAM_SUPERCEDE
	if(iClip >= CLIP_S)
		return HAM_SUPERCEDE		
			
	g_Skull3_Clip[id] = iClip	
	
	return HAM_HANDLED
}

public fw_Skull3S_Reload_Post(ent)
{
	static id; id = pev(ent, pev_owner)
	if(!is_user_alive(id))
		return HAM_IGNORED
	if(!Get_BitVar(g_Had_Skull3, id))
		return HAM_IGNORED	
	
	if((get_pdata_int(ent, 54, 4) == 1))
	{ // Reload
		if(g_Skull3_Clip[id] == -1)
			return HAM_IGNORED
		
		set_pdata_int(ent, 51, g_Skull3_Clip[id], 4)
	}
	
	return HAM_HANDLED
}
public fw_TraceAttack_World(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{
	if(!is_user_connected(Attacker))
		return HAM_IGNORED	
	if(!Get_BitVar(g_Had_Skull3, Attacker))
		return HAM_IGNORED
		
	if(get_user_weapon(Attacker) == CSW_SKULL3S)
	{
		static Float:flEnd[3], Float:vecPlane[3]
			
		get_tr2(Ptr, TR_vecEndPos, flEnd)
		get_tr2(Ptr, TR_vecPlaneNormal, vecPlane)		
				
		Make_BulletHole(Attacker, flEnd, Damage)
		Make_BulletSmoke(Attacker, Ptr)
	
		SetHamParamFloat(3, g_Skull3_Mode[Attacker] == SKULL3_SINGLE ? float(DAMAGE_S) : Damage)
	}
	
	return HAM_IGNORED
}

public fw_TraceAttack_Player(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{
	if(!is_user_connected(Attacker))
		return HAM_IGNORED	
	if(!Get_BitVar(g_Had_Skull3, Attacker))
		return HAM_IGNORED
		
	if(get_user_weapon(Attacker) == CSW_SKULL3S)
		SetHamParamFloat(3, g_Skull3_Mode[Attacker] == SKULL3_SINGLE ? float(DAMAGE_S) : Damage)
	
	return HAM_IGNORED
}
public Update_AmmoHud(id, CSW, Clip)
{
	message_begin(MSG_ONE_UNRELIABLE, g_MsgCurWeapon, _, id)
	write_byte(1)
	write_byte(CSW)
	write_byte(Clip)
	message_end()
}

public Set_Skull3_BPAmmo(id, BPAmmo)
{
	cs_set_user_bpammo(id, CSW_SKULL3S, BPAmmo)
	
	g_Skull3_BPAmmo[id] = BPAmmo
}

public Make_Shell(id, Right)
{
	static Float:player_origin[3], Float:origin[3], Float:origin2[3], Float:gunorigin[3], Float:oldangles[3], Float:v_forward[3], Float:v_forward2[3], Float:v_up[3], Float:v_up2[3], Float:v_right[3], Float:v_right2[3], Float:viewoffsets[3];
	
	pev(id, pev_v_angle, oldangles); pev(id,pev_origin,player_origin); pev(id, pev_view_ofs, viewoffsets);

	engfunc(EngFunc_MakeVectors, oldangles)
	
	global_get(glb_v_forward, v_forward); global_get(glb_v_up, v_up); global_get(glb_v_right, v_right);
	global_get(glb_v_forward, v_forward2); global_get(glb_v_up, v_up2); global_get(glb_v_right, v_right2);
	
	xs_vec_add(player_origin, viewoffsets, gunorigin);
	
	if(!Right)
	{
		xs_vec_mul_scalar(v_forward, 10.3, v_forward); xs_vec_mul_scalar(v_right, 2.0, v_right);
		xs_vec_mul_scalar(v_up, -2.7, v_up);
		xs_vec_mul_scalar(v_forward2, 10.0, v_forward2); xs_vec_mul_scalar(v_right2, 4.0, v_right2);
		xs_vec_mul_scalar(v_up2, -3.0, v_up2);
	} else {
		xs_vec_mul_scalar(v_forward, 10.3, v_forward); xs_vec_mul_scalar(v_right, -4.0, v_right);
		xs_vec_mul_scalar(v_up, -3.7, v_up);
		xs_vec_mul_scalar(v_forward2, 10.0, v_forward2); xs_vec_mul_scalar(v_right2, 2.0, v_right2);
		xs_vec_mul_scalar(v_up2, -4.0, v_up2);
	}
	
	xs_vec_add(gunorigin, v_forward, origin);
	xs_vec_add(gunorigin, v_forward2, origin2);
	xs_vec_add(origin, v_right, origin);
	xs_vec_add(origin2, v_right2, origin2);
	xs_vec_add(origin, v_up, origin);
	xs_vec_add(origin2, v_up2, origin2);

	static Float:velocity[3]
	get_speed_vector(origin2, origin, random_float(140.0, 160.0), velocity)

	static angle; angle = random_num(0, 360)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_MODEL)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord,origin[1])
	engfunc(EngFunc_WriteCoord,origin[2])
	engfunc(EngFunc_WriteCoord,velocity[0])
	engfunc(EngFunc_WriteCoord,velocity[1])
	engfunc(EngFunc_WriteCoord,velocity[2])
	write_angle(angle)
	write_short(g_ShellId)
	write_byte(1)
	write_byte(20)
	message_end()
}

stock Make_BulletHole(id, Float:Origin[3], Float:Damage)
{
	// Find target
	static Decal; Decal = random_num(41, 45)
	static LoopTime; 
	
	if(Damage > 100.0) LoopTime = 2
	else LoopTime = 1
	
	for(new i = 0; i < LoopTime; i++)
	{
		// Put decal on "world" (a wall)
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_WORLDDECAL)
		engfunc(EngFunc_WriteCoord, Origin[0])
		engfunc(EngFunc_WriteCoord, Origin[1])
		engfunc(EngFunc_WriteCoord, Origin[2])
		write_byte(Decal)
		message_end()
		
		// Show sparcles
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_GUNSHOTDECAL)
		engfunc(EngFunc_WriteCoord, Origin[0])
		engfunc(EngFunc_WriteCoord, Origin[1])
		engfunc(EngFunc_WriteCoord, Origin[2])
		write_short(id)
		write_byte(Decal)
		message_end()
	}
}

stock Make_BulletSmoke(id, TrResult)
{
	static Float:vecSrc[3], Float:vecEnd[3], TE_FLAG
	
	get_weapon_attachment(id, vecSrc)
	global_get(glb_v_forward, vecEnd)
    
	xs_vec_mul_scalar(vecEnd, 8192.0, vecEnd)
	xs_vec_add(vecSrc, vecEnd, vecEnd)

	get_tr2(TrResult, TR_vecEndPos, vecSrc)
	get_tr2(TrResult, TR_vecPlaneNormal, vecEnd)
    
	xs_vec_mul_scalar(vecEnd, 2.5, vecEnd)
	xs_vec_add(vecSrc, vecEnd, vecEnd)
    
	TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
	TE_FLAG |= TE_EXPLFLAG_NOSOUND
	TE_FLAG |= TE_EXPLFLAG_NOPARTICLES
	
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecEnd, 0)
	write_byte(TE_EXPLOSION)
	engfunc(EngFunc_WriteCoord, vecEnd[0])
	engfunc(EngFunc_WriteCoord, vecEnd[1])
	engfunc(EngFunc_WriteCoord, vecEnd[2] - 10.0)
	write_short(g_SmokePuff_SprId)
	write_byte(2)
	write_byte(50)
	write_byte(TE_FLAG)
	message_end()
}

stock get_weapon_attachment(id, Float:output[3], Float:fDis = 40.0)
{ 
	static Float:vfEnd[3], viEnd[3] 
	get_user_origin(id, viEnd, 3)  
	IVecFVec(viEnd, vfEnd) 
	
	static Float:fOrigin[3], Float:fAngle[3]
	
	pev(id, pev_origin, fOrigin) 
	pev(id, pev_view_ofs, fAngle)
	
	xs_vec_add(fOrigin, fAngle, fOrigin) 
	
	static Float:fAttack[3]
	
	xs_vec_sub(vfEnd, fOrigin, fAttack)
	xs_vec_sub(vfEnd, fOrigin, fAttack) 
	
	static Float:fRate
	
	fRate = fDis / vector_length(fAttack)
	xs_vec_mul_scalar(fAttack, fRate, fAttack)
	
	xs_vec_add(fOrigin, fAttack, output)
}

stock Eject_Shell(id, Shell_ModelIndex, Float:Time) // By Dias
{
	static Ent; Ent = get_pdata_cbase(id, 373, 5)
	if(!pev_valid(Ent))
		return

        set_pdata_int(Ent, 57, Shell_ModelIndex, 4)
        set_pdata_float(id, 111, get_gametime() + Time)
}

stock get_speed_vector(const Float:origin1[3],const Float:origin2[3],Float:speed, Float:new_velocity[3])
{
	new_velocity[0] = origin2[0] - origin1[0]
	new_velocity[1] = origin2[1] - origin1[1]
	new_velocity[2] = origin2[2] - origin1[2]
	static Float:num; num = floatsqroot(speed*speed / (new_velocity[0]*new_velocity[0] + new_velocity[1]*new_velocity[1] + new_velocity[2]*new_velocity[2]))
	new_velocity[0] *= num
	new_velocity[1] *= num
	new_velocity[2] *= num
	
	return 1;
}

stock drop_weapons(id)
{
	static weapons[32], num, i, weaponid
	num = 0
	get_user_weapons(id, weapons, num)
	
	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i]
		
		if (((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
		{
			static wname[32]
			get_weaponname(weaponid, wname, sizeof wname - 1)
			engclient_cmd(id, "drop", wname)
		}
	}
}

stock Set_Weapon_TimeIdle(id, WeaponId ,Float:TimeIdle)
{
	static entwpn; entwpn = fm_get_user_weapon_entity(id, WeaponId)
	if(!pev_valid(entwpn)) 
		return
		
	set_pdata_float(entwpn, 46, TimeIdle, 4)
	set_pdata_float(entwpn, 47, TimeIdle, 4)
	set_pdata_float(entwpn, 48, TimeIdle + 0.5, 4)
}

stock Set_Player_NextAttack(id, Float:Time)
{
	set_pdata_float(id, 83, Time, 5)
}

stock Set_WeaponAnim(id, anim)
{
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(pev(id, pev_body))
	message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1042\\ f0\\ fs16 \n\\ par }
*/
