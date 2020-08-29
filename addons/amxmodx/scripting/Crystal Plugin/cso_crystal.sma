#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <xs>
#include <zombieplague>
#include <nvault>

#define W_Crystal "models/csoleg_crystal.mdl"
#define ClassCrystal "crystal_object"

#define PLUGIN "CSO Crystals"
#define VERSION "1.0"
#define AUTHOR "LegendofWarior"

new g_crystals[33]

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	RegisterHam(Ham_Killed, "player", "OnKilled")
	
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_touch(ClassCrystal, "player", "OnTouchCrystal")
	
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
}
public plugin_precache()
{
	precache_model(W_Crystal)
	precache_sound("csoleg_pickup.wav")
}
public event_round_start()
{
	remove_entity_name(ClassCrystal)
}
public OnKilled(id, atk, gibs)
{
	if(zp_get_user_zombie(id) && !zp_is_survivor_round())
	{
		new Rand = random(100)
		switch(Rand)
		{
			case 0..49 : client_print(id, print_center, "You got Killed")
			case 50..100 : CreateCrystal(id)
		
		}
	}
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
public OnTouchCrystal(ent, id)
{
	if(is_valid_ent(ent) && is_user_connected(id))
	{
		if(!is_user_alive(id)) 
			return PLUGIN_HANDLED;

		remove_entity(ent)
		client_print(id, print_chat, "You pickup a Crystal!")
		emit_sound(id, CHAN_WEAPON, "csoleg_pickup.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	
	return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
