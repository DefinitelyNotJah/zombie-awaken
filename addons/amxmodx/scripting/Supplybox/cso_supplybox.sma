#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <cstrike>
#include <xs>
#include <fun>

#define PLUGIN "SupplyBox"
#define VERSION "1.1"
#define AUTHOR "Dias"

#define SUPPLYBOX_CLASSNAME "supplybox"
#define TASK_SUPPLYBOX 128256
#define TASK_SUPPLYBOX2 138266
#define TASK_SUPPLYBOX_HELP 129257
#define TASK_SUPPLYBOX_WAIT 130259

const MAX_SUPPLYBOX_ENT = 100
new const supplybox_spawn_file[] = "%s/supply_box/%s.cfg"
new const supplybox_icon_spr[] = "sprites/csozm/icon_supplybox.spr"
new const supplybox_model[][] = {
	"models/zm_cso/w_supply.mdl"
}
new const supplybox_drop_sound[][] = {
	"zm_cso/supplybox_drop.wav"
}
new const supplybox_pickup_sound[][] = {
	"zm_cso/supplybox_pickup.wav"
}

// Below here is hard code. Don't edit anything except cvars
new g_supplybox_num, g_supplybox_wait[33], supplybox_count, Array:supplybox_item, 
supplybox_ent[MAX_SUPPLYBOX_ENT], g_supplybox_icon_id, Float:g_supplybox_spawn[MAX_SUPPLYBOX_ENT][3],
g_total_supplybox_spawn
new cvar_supplybox_icon, cvar_supplybox_max, cvar_supplybox_num, cvar_supplybox_totalintime, 
cvar_supplybox_time, cvar_supplybox_delaytime, cvar_supplybox_icon_size, cvar_supplybox_icon_light
new bool:made_supplybox, Float:g_icon_delay[33], g_newround, g_endround

native give_weapon_infi(id)
native give_weapon_svdex(id)
native give_weapon_ddeagle(id)
native give_weapon_m200(id)
native give_weapon_mg3(id)
native cso_set_user_money(id, value)
native cso_get_user_money(id)

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	
	register_forward(FM_Touch, "fw_supplybox_touch")
	
	cvar_supplybox_max = register_cvar("supplybox_max", "16")
	cvar_supplybox_num = register_cvar("supplybox_num", "4")
	cvar_supplybox_totalintime = register_cvar("supplybox_totalintime", "20")
	cvar_supplybox_time = register_cvar("supplybox_time", "25")
	cvar_supplybox_icon = register_cvar("supplybox_icon", "1")
	cvar_supplybox_delaytime = register_cvar("supplybox_icon_delay_time", "0.03")	
	cvar_supplybox_icon_size = register_cvar("supplybox_icon_size", "2")
	cvar_supplybox_icon_light = register_cvar("supplybox_icon_light", "100")
	
	//set_task(2.0, "update_radar", _, _, _, "b")
}

public plugin_precache()
{
	supplybox_item = ArrayCreate(64, 1)
	
	load_supplybox_spawn()
	//load_supplybox_item()
	
	static i
	for(i = 0; i < sizeof(supplybox_model); i++)
		engfunc(EngFunc_PrecacheModel, supplybox_model[i])
	for(i = 0; i < sizeof(supplybox_drop_sound); i++)
		engfunc(EngFunc_PrecacheSound, supplybox_drop_sound[i])		
	for(i = 0; i < sizeof(supplybox_pickup_sound); i++)
		engfunc(EngFunc_PrecacheSound, supplybox_pickup_sound[i])
		
	g_supplybox_icon_id = engfunc(EngFunc_PrecacheModel, supplybox_icon_spr)
}

public plugin_cfg()
{
	set_task(0.5, "event_newround")
}

public load_supplybox_spawn()
{
	// Check for spawns points of the current map
	new cfgdir[32], mapname[32], filepath[100], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), supplybox_spawn_file, cfgdir, mapname)
	
	// Load spawns points
	if (file_exists(filepath))
	{
		new file = fopen(filepath,"rt"), row[4][6]
		
		while (file && !feof(file))
		{
			fgets(file, linedata, charsmax(linedata))
			
			// invalid spawn
			if(!linedata[0] || str_count(linedata,' ') < 2) continue;
			
			// get spawn point data
			parse(linedata,row[0],5,row[1],5,row[2],5)
			
			// origin
			g_supplybox_spawn[g_total_supplybox_spawn][0] = floatstr(row[0])
			g_supplybox_spawn[g_total_supplybox_spawn][1] = floatstr(row[1])
			g_supplybox_spawn[g_total_supplybox_spawn][2] = floatstr(row[2])

			g_total_supplybox_spawn++
			if (g_total_supplybox_spawn >= MAX_SUPPLYBOX_ENT) 
				break
		}
		if (file) fclose(file)
	}
}

/*public load_supplybox_item() 
{
	new filepath[64]
	get_configsdir(filepath, charsmax(filepath))
	
	new line[1024], key[64], value[960]
	new file = fopen(filepath, "rt")
	
	while (!feof(file) && file)
	{
		fgets(file, line, charsmax(line));
		replace(line, charsmax(line), "^n", "")
		
		if (!line[0] || line[0] == ';')
			continue
		
		strtok(line, key, charsmax(key), value, charsmax(value), '=')
		trim(key)
		trim(value)
		
		if (equali(key, "SUPPLYBOX_ITEM")) 
		{
			while (value[0] != 0 && strtok(value, key, charsmax(key), value, charsmax(value), ',')) 
			{
				trim(key)
				trim(value)
				ArrayPushString(supplybox_item, key)
			}
		}
	}
}*/

public update_radar()
{	
	for (new id = 1; id <= get_maxplayers(); id++)
	{
		if (!is_user_alive(id) || !supplybox_count || (cs_get_user_team(id) == CS_TEAM_T)) 
			continue
		
		static i, next_ent
		i = 1
		while(i <= supplybox_count)
		{
			next_ent = supplybox_ent[i]
			if (next_ent && is_valid_ent(next_ent))
			{
				static Float:origin[3]
				pev(next_ent, pev_origin, origin)
				
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostagePos"), {0,0,0}, id)
				write_byte(id)
				write_byte(i)		
				write_coord(floatround(origin[0]))
				write_coord(floatround(origin[1]))
				write_coord(floatround(origin[2]))
				message_end()
			
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("HostageK"), {0,0,0}, id)
				write_byte(i)
				message_end()
			}

			i++
		}
	}
}

public event_newround()
{
	made_supplybox = false
	g_newround = 1
	g_endround = 0
	
	remove_supplybox()
	supplybox_count = 0
	
	if(task_exists(TASK_SUPPLYBOX)) remove_task(TASK_SUPPLYBOX)
	if(task_exists(TASK_SUPPLYBOX2)) remove_task(TASK_SUPPLYBOX2)
	if(task_exists(TASK_SUPPLYBOX_HELP)) remove_task(TASK_SUPPLYBOX_HELP)
	remove_task(5120)
	set_task(30.0, "task_start_supply", 5120)
}

public logevent_round_end() g_endround = 1

public task_start_supply()
{
	if(!made_supplybox)
	{
		g_newround = 0
		made_supplybox = true
		
		if(task_exists(TASK_SUPPLYBOX)) remove_task(TASK_SUPPLYBOX)
		
		if(!g_total_supplybox_spawn)
		{
			server_print("[SupplyBox][Error] Spawn Point Not Found. Please Create Spawn Point")
		} else {
			set_task(get_pcvar_float(cvar_supplybox_time), "create_supplybox", TASK_SUPPLYBOX)
		}
	}
}

public client_PostThink(id)
{
	if (!get_pcvar_num(cvar_supplybox_icon) || !is_user_alive(id) || (cs_get_user_team(id) == CS_TEAM_T))
		return
	if((g_icon_delay[id] + get_pcvar_float(cvar_supplybox_delaytime)) > get_gametime())
		return
		
	g_icon_delay[id] = get_gametime()

	if (supplybox_count)
	{
		static i, box_ent
		i = 1
		
		while (i <= supplybox_count)
		{
			box_ent = supplybox_ent[i]
			create_icon_origin(id, box_ent, g_supplybox_icon_id)
			i++
		}
	}
}

public create_supplybox()
{
	if (supplybox_count >= get_pcvar_num(cvar_supplybox_max) || g_newround || g_endround) 
		return

	if (task_exists(TASK_SUPPLYBOX)) remove_task(TASK_SUPPLYBOX)
	set_task(get_pcvar_float(cvar_supplybox_time), "create_supplybox", TASK_SUPPLYBOX)
	
	if (get_total_supplybox() >= get_pcvar_num(cvar_supplybox_totalintime)) 
		return
		
	g_supplybox_num = 0
	create_supplybox2()
	
	static random_sound
	random_sound = random_num(0, charsmax(supplybox_drop_sound))
	client_cmd(0, "spk ^"%s^"", supplybox_drop_sound[random_sound])
	
	for(new i = 0; i < get_maxplayers(); i++)
	{
		if(is_user_alive(i) && is_user_connected(i) && (cs_get_user_team(i) == CS_TEAM_CT))
		{
			client_print(i, print_center, "SupplyBox Has Appear!")
		}
	}

	if (task_exists(TASK_SUPPLYBOX2)) remove_task(TASK_SUPPLYBOX2)
	set_task(0.5, "create_supplybox2", TASK_SUPPLYBOX2, _, _, "b")	
}

public create_supplybox2()
{
	if (supplybox_count >= get_pcvar_num(cvar_supplybox_max)
	|| get_total_supplybox() >= get_pcvar_num(cvar_supplybox_totalintime) || g_newround || g_endround)
	{
		remove_task(TASK_SUPPLYBOX2)
		return
	}
	
	supplybox_count++
	g_supplybox_num++

	static item
	item = random(ArraySize(supplybox_item))

	new ent = create_entity("info_target")
	
	entity_set_string(ent, EV_SZ_classname, SUPPLYBOX_CLASSNAME)
	entity_set_model(ent, supplybox_model[random_num(0, charsmax(supplybox_model))])	
	entity_set_size(ent,Float:{-2.0,-2.0,-2.0},Float:{5.0,5.0,5.0})
	entity_set_int(ent,EV_INT_solid,1)
	entity_set_int(ent,EV_INT_movetype,6)
	entity_set_int(ent, EV_INT_iuser1, item)
	entity_set_int(ent, EV_INT_iuser2, supplybox_count)
	
	static Float:Origin[3]
	collect_spawn_point(Origin)
	engfunc(EngFunc_SetOrigin, ent, Origin)
	
	set_pev(ent, pev_body, random_num(1, 2))
	
	supplybox_ent[supplybox_count] = ent

	if ((g_supplybox_num >= get_pcvar_num(cvar_supplybox_num)) && task_exists(TASK_SUPPLYBOX2)) 
		remove_task(TASK_SUPPLYBOX2)
}

public get_total_supplybox()
{
	new total
	for (new i = 1; i <= supplybox_count; i++)
	{
		if (supplybox_ent[i]) total += 1
	}
	return total
}
public remove_supplybox()
{
	remove_ent_by_class(SUPPLYBOX_CLASSNAME)
	new supplybox_ent_reset[MAX_SUPPLYBOX_ENT]
	supplybox_ent = supplybox_ent_reset
}

public fw_supplybox_touch(ent, id)
{
	if (!pev_valid(ent) || !is_user_alive(id) || (cs_get_user_team(id) == CS_TEAM_T) || g_supplybox_wait[id]) 
		return FMRES_IGNORED
	
	static classname[32]
	entity_get_string(ent,EV_SZ_classname,classname,31)
	
	if (equal(classname, SUPPLYBOX_CLASSNAME))
	{	
		static name[32]
		get_user_name(id, name, sizeof(name))
		
		switch(random_num(0,11))
		{
			case 0:
			{
				give_item(id, "weapon_hegrenade")
				client_print(0, print_center, "%s found HE Grenade in Supplybox!", name)
			}
			case 1:
			{
				give_item(id, "weapon_flashbang")
				client_print(0, print_center, "%s found HolyWater bomb in Supplybox!", name)
			}
			case 2:
			{
				give_weapon_infi(id)
				client_print(0, print_center, "%s found Dual Infnity in Supplybox!", name)
			}
			case 3:
			{
				give_weapon_ddeagle(id)
				client_print(0, print_center, "%s found Dual Deagle in Supplybox!", name)
			}
			case 4:
			{
				give_weapon_svdex(id)
				client_print(0, print_center, "%s found SVDEX in Supplybox!", name)
			}
			case 5:
			{
				set_user_health(id, get_user_health(id)+50)	
				client_print(0, print_center, "%s found +50 HP in Supplybox!", name)
			}
			case 6:
			{
				set_user_armor(id, 100)	
				client_print(0, print_center, "%s found 100 anti-infection armor in Supplybox!", name)
			}
			case 7:
			{
				cso_set_user_money(id, cso_get_user_money(id)+1000)
				client_print(0, print_center, "%s found 1000$ Cash in Supplybox!", name)
			}
			case 8:
			{
				give_weapon_mg3(id)
				client_print(0, print_center, "%s found MG3 in Supplybox!", name)
			}
			case 9:
			{
				give_weapon_m200(id)
				client_print(0, print_center, "%s found M200 in Supplybox!", name)
			}
			case 10:
			{
				cso_set_user_money(id, cso_get_user_money(id)+2500)
				client_print(0, print_center, "%s found 2500$ Cash in Supplybox!", name)
			}
		}
		
		static random_sound
		random_sound = random_num(0, charsmax(supplybox_pickup_sound))
		emit_sound(id, CHAN_VOICE, supplybox_pickup_sound[random_sound], 1.0, ATTN_NORM, 0, PITCH_NORM)

		new num_box = entity_get_int(ent, EV_INT_iuser2)
		supplybox_ent[num_box] = 0
		remove_entity(ent)

		g_supplybox_wait[id] = 1
		if (task_exists(id+TASK_SUPPLYBOX_WAIT)) remove_task(id+TASK_SUPPLYBOX_WAIT)
		set_task(2.0, "remove_supplybox_wait", id+TASK_SUPPLYBOX_WAIT)
	}
	
	return FMRES_IGNORED
}

public remove_supplybox_wait(id)
{
	id -= TASK_SUPPLYBOX_WAIT
	
	g_supplybox_wait[id] = 0
	if (task_exists(id+TASK_SUPPLYBOX_WAIT)) remove_task(id+TASK_SUPPLYBOX_WAIT)
}

stock collect_spawn_point(Float:origin[3])
{
	for (new i = 1; i <= g_total_supplybox_spawn *3 ; i++)
	{
		origin = g_supplybox_spawn[random(g_total_supplybox_spawn)]
		if (check_spawn_box(origin)) return 1;
	}

	return 0;
}
stock check_spawn_box(Float:origin[3])
{
	new Float:originE[3], Float:origin1[3], Float:origin2[3]
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", SUPPLYBOX_CLASSNAME)) != 0)
	{
		pev(ent, pev_origin, originE)
		
		// xoy
		origin1 = origin
		origin2 = originE
		origin1[2] = origin2[2] = 0.0
		if (vector_distance(origin1, origin2) <= 32.0) return 0;
	}
	return 1;
}

stock create_icon_origin(id, ent, sprite)
{
	if (!pev_valid(ent)) return;
	
	new Float:fMyOrigin[3]
	entity_get_vector(id, EV_VEC_origin, fMyOrigin)
	
	new target = ent
	new Float:fTargetOrigin[3]
	entity_get_vector(target, EV_VEC_origin, fTargetOrigin)
	fTargetOrigin[2] += 40.0
	
	if (!is_in_viewcone(id, fTargetOrigin)) return;

	new Float:fMiddle[3], Float:fHitPoint[3]
	xs_vec_sub(fTargetOrigin, fMyOrigin, fMiddle)
	trace_line(-1, fMyOrigin, fTargetOrigin, fHitPoint)
							
	new Float:fWallOffset[3], Float:fDistanceToWall
	fDistanceToWall = vector_distance(fMyOrigin, fHitPoint) - 10.0
	normalize(fMiddle, fWallOffset, fDistanceToWall)
	
	new Float:fSpriteOffset[3]
	xs_vec_add(fWallOffset, fMyOrigin, fSpriteOffset)
	new Float:fScale
	fScale = 0.01 * fDistanceToWall
	
	new scale = floatround(fScale)
	scale = max(scale, 1)
	scale = min(scale, get_pcvar_num(cvar_supplybox_icon_size))
	scale = max(scale, 1)

	te_sprite(id, fSpriteOffset, sprite, scale, get_pcvar_num(cvar_supplybox_icon_light))
}

stock te_sprite(id, Float:origin[3], sprite, scale, brightness)
{	
	message_begin(MSG_ONE, SVC_TEMPENTITY, _, id)
	write_byte(TE_SPRITE)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2]))
	write_short(sprite)
	write_byte(scale) 
	write_byte(brightness)
	message_end()
}

stock normalize(Float:fIn[3], Float:fOut[3], Float:fMul)
{
	new Float:fLen = xs_vec_len(fIn)
	xs_vec_copy(fIn, fOut)
	
	fOut[0] /= fLen, fOut[1] /= fLen, fOut[2] /= fLen
	fOut[0] *= fMul, fOut[1] *= fMul, fOut[2] *= fMul
}

stock str_count(const str[], searchchar)
{
	new count, i, len = strlen(str)
	
	for (i = 0; i <= len; i++)
	{
		if(str[i] == searchchar)
			count++
	}
	
	return count;
}

stock remove_ent_by_class(classname[])
{
	new nextitem  = find_ent_by_class(-1, classname)
	while(nextitem)
	{
		remove_entity(nextitem)
		nextitem = find_ent_by_class(-1, classname)
	}
}

/*stock client_print_color(const id, const input[], any:...)  
{  
    new count = 1, players[32];  
    static msg[191];  
    vformat(msg, 190, input, 3);  

    replace_all(msg, 190, "!g", "^x04"); // Green Color  
    replace_all(msg, 190, "!y", "^x01"); // Default Color  
    replace_all(msg, 190, "!t", "^x03"); // Team Color  

    if (id) players[0] = id; else get_players(players, count, "ch");  
    {  
        for (new i = 0; i < count; i++)  
        {  
            if (is_user_connected(players[i]))  
            {  
                message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]);  
                write_byte(players[i]);  
                write_string(msg);  
                message_end();  
            }  
        }  
    }  
}*/
