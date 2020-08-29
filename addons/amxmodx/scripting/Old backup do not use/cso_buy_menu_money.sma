#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <fun>
#include <nvault>

#define PLUGIN "CSO Awakens || Buy Menu"
#define VERSION "1.0"
#define AUTHOR "LegendofWarior"

#define is_user_valid_connected(%1) (1 <= %1 <= g_iMaxClients && g_isconnected[%1])

native cso_blink_money(id)
native cso_set_user_money(id, value)
native cso_get_user_money(id)

native cso_get_user_zombie(id)
native cso_open_knife_menu(id)
native cso_get_user_type_hero(id)
native cso_get_user_type_heroine(id)
native cso_is_round_started()

native give_weapon_infi(id)
native give_weapon_skull1(id) //

native give_weapon_dbarrel(id)
native give_weapon_m1887(id)
native give_weapon_spas12(id) //

native give_weapon_mp7a160r(id) 
native give_weapon_k1ase(id)
native give_weapon_thompson(id)

native give_weapon_scar(id)
native give_weapon_tar21(id)
native give_weapon_guitar(id)
native give_weapon_xm8(id)
native give_weapon_skull3(id)

native give_weapon_m24(id)
native give_weapon_m200(id) //
native give_weapon_vsk94(id)

native give_weapon_mg3(id)
native give_weapon_pkm(id) //

//native give_weapon_rpg7(id)
native give_weapon_m32(id)

forward cso_round_started(id)

const OFFSET_CSMENUCODE = 205
const OFFSET_LINUX = 5;

new gMsg_BuyClose, g_iMaxClients, g_isconnected[33]

const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0;

new g_secondary[33], g_primary[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_clcmd("say /buy", "buy_clcmd")
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1);
	register_menu("Buy Menu", KEYSMENU, "buy_game");// Add your code here...)

	register_forward(FM_ClientDisconnect, "fw_ClientDisconnect")

	gMsg_BuyClose = get_user_msgid("BuyClose")
		
	register_clcmd( "buy" , "buy_clcmd" );
	register_clcmd( "client_buy_open" , "clcmd_client_buy_open" );
	register_clcmd( "autobuy" , "auto_buy" );
	register_clcmd( "cl_autobuy" , "auto_buy" );
	register_clcmd( "cl_setautobuy", "auto_buy" )
	register_clcmd( "rebuy" , "auto_buy" );
	register_clcmd( "cl_rebuy" , "auto_buy" );
	register_clcmd( "cl_setrebuy", "auto_buy" )
	register_clcmd( "buyequip" , "return_buy" );
	register_clcmd( "buyammo1" , "return_buy" );
	register_clcmd( "buyammo2" , "return_buy" );

	g_iMaxClients = get_maxplayers();
}
public clcmd_client_buy_open(id)
{
	message_begin(MSG_ONE, gMsg_BuyClose, _, id)
	message_end()

	buy_clcmd(id)

	return PLUGIN_HANDLED;
}
public fw_PlayerSpawn_Post(id)
{
	g_primary[id] = false
	g_secondary[id] = false
}
public client_putinserver(id)
{
	g_isconnected[id] = true
}
public fw_ClientDisconnect(id)
{
	g_isconnected[id] = false
}
public cso_round_started(id)
{
	if(!cso_get_user_zombie(id) && is_user_alive(id) && is_user_valid_connected(id))
	{
		if(cso_get_user_type_hero(id) || cso_get_user_type_heroine(id))
			return

		if(!g_primary[id])
		{
			if(get_user_flags(id) & ADMIN_LEVEL_H)
			{
				give_weapon_skull3(id)
				client_printc(id, "!g[CSO]!n You have not picked any PW so you received a !tSkull 3 !nsince you are a !tVIP!n.")
			}
			g_primary[id] = true
		}
		if(!g_secondary[id])
		{
			if(get_user_flags(id) & ADMIN_LEVEL_H)
			{
				give_weapon_skull1(id)
				client_printc(id, "!g[CSO]!n You have not picked any SW so you received a !tSkull 1 !nsince you are a !tVIP!n.")
			}
			g_secondary[id] = true
		}
	}
}
public plugin_natives()
{
	register_native("cso_open_buy_menu", "native_open_buy_menu", 1)
}
public native_open_buy_menu(id)
{
	buy_clcmd(id)
}
public auto_buy(id)
{
	return PLUGIN_HANDLED;
}
public return_buy(id)
{
	return PLUGIN_HANDLED
}
public buy_clcmd(id)
{
	if(!cso_is_round_started() || !cso_get_user_zombie(id))
		show_buy_menu(id)
	
	return PLUGIN_HANDLED
}
public show_buy_menu(id) 
{
	if(cso_is_round_started() || cso_get_user_zombie(id))
		return PLUGIN_HANDLED;

	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\rCSO.\yGAMERCLUB\r.net^n")
	len += formatex(menu[len], charsmax(menu) - len, "\rIP \d: \w74.91.123.95:27025^n")
	len += formatex(menu[len], charsmax(menu) - len, "\wPurchase your \rweapons^n^n")

	// Items
	if(g_secondary[id])
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r1\y].\d Secondary Pistols^n^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r1\y].\w Secondary Pistols^n^n")
		
	if(g_primary[id]){
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r2\y].\d Primary ShotGuns^n")
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r3\y].\d Primary Automates^n")
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r4\y].\d Primary Assault Rifles^n")
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r5\y].\d Primary Sniper Rifles^n")
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r6\y].\d Primary Machine Guns^n^n")
	}
	else
	{
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r2\y].\w Primary ShotGuns^n")
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r3\y].\w Primary Automates^n")
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r4\y].\w Primary Assault Rifles^n")
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r5\y].\w Primary Sniper Rifles^n")
		len += formatex(menu[len], charsmax(menu) - len, "\y[\r6\y].\w Primary Machine Guns^n^n")
	}
	len += formatex(menu[len], charsmax(menu) - len, "\y[\r7\y].\w Choose a Knife^n")
	len += formatex(menu[len], charsmax(menu) - len, "\y[\r8\y].\w Equipment")
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\y[\r0\y].\y Exit")
	 
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	show_menu(id, KEYSMENU, menu, -1, "Buy Menu")

	return PLUGIN_CONTINUE;
}
public buy_game(id, key) {
	if(cso_is_round_started() || cso_get_user_zombie(id))
		return PLUGIN_HANDLED;
	
	switch (key)
	{
	         case 0:
		{
			if(g_secondary[id])
				return PLUGIN_HANDLED;
				
			pis_h(id)
		}
	         case 1:
		{
			if(g_primary[id])
				return PLUGIN_HANDLED;
				
			sh_h(id)
		}
		case 2:
		{
			if(g_primary[id])
				return PLUGIN_HANDLED;
				
			at_h(id)
		}
		case 3:
		{
			if(g_primary[id])
				return PLUGIN_HANDLED;
				
			ar_h(id)
		}
		case 4:
		{
			if(g_primary[id])
				return PLUGIN_HANDLED;
				
			sr_h(id)
		}
		case 5:
		{
			if(g_primary[id])
				return PLUGIN_HANDLED;

			mg_h(id)
		}
		case 6:
		{
			cso_open_knife_menu(id)
		}
		case 7:
		{
			eq_m(id)
		}
	}
	return PLUGIN_HANDLED;
}
/* Pistols */
public pis_h(id)
{
	if(cso_is_round_started() || cso_get_user_zombie(id))
		return;

	static menu, string[128]
	
	formatex(string, sizeof(string), "\yPistols")
	menu = menu_create(string, "pis_handle")
	
	formatex(string, sizeof(string), "\wK&M .45 Tactical \d- \y[\rFREE\y]")
	menu_additem(menu, string, "1", 0)
	
	if(cso_get_user_money(id) < 750)
		formatex(string, sizeof(string), "\dNight Hawk .50C - \y[\r750$\y]")
	else
		formatex(string, sizeof(string), "\wNight Hawk .50C \d- \y[\r750$\y]")
	menu_additem(menu, string, "2", 0)
	
	if(cso_get_user_money(id) < 900)
		formatex(string, sizeof(string), "\d.40 Dual Elites - \y[\r1500$\y]")
	else
		formatex(string, sizeof(string), "\w.40 Dual Elites \d- \y[\r1500$\y]")
	menu_additem(menu, string, "3", 0)
	
	if(cso_get_user_money(id) < 3000)
		formatex(string, sizeof(string), "\dDual Infinity - \y[\r3000$\y]")
	else
		formatex(string, sizeof(string), "\wDual Infinity \d- \y[\r3000$\y]")
	menu_additem(menu, string, "4", 0)
	
	if(get_user_flags(id) & ADMIN_LEVEL_H)
		formatex(string, sizeof(string), "\wSoul Eater Skull 1 \d- \y[\rVIP\y]")
	else
		formatex(string, sizeof(string), "\dSoul Eater Skull 1 - \y[\rVIP\y]")
	menu_additem(menu, string, "5", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}
public pis_handle(id, menu, item)
{
	if(!is_user_connected(id))
		return
		
	if(cso_get_user_zombie(id))
		return
		
	if(cso_get_user_type_hero(id) || cso_get_user_type_heroine(id))
		return
		
	if(g_secondary[id])
		return
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return
	}
	
		new data[6], szName[64];
		new access, callback;
		menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
		new key = str_to_num(data);
	
		switch(key)
		{
			case 1:
			{
				give_item(id, "weapon_usp")
				cs_set_user_bpammo(id, CSW_USP, 90)
				g_secondary[id] = true
			}
			case 2:
			{
				if(cso_get_user_money(id) < 750)
					{
						cso_blink_money(id)
						return
					}
				
				give_item(id, "weapon_deagle")
				cs_set_user_bpammo(id, CSW_DEAGLE, 90)
				g_secondary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-750)
			}
			case 3:
			{
				if(cso_get_user_money(id) <1500)
					{
						cso_blink_money(id)
						return
					}
					
				give_item(id, "weapon_elite")
				cs_set_user_bpammo(id, CSW_ELITE, 90)
				g_secondary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-1500)
			}
			case 4:
			{
				if(cso_get_user_money(id) <3000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_infi(id)
				g_secondary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-3000)
			}
			case 5:
			{
				if(get_user_flags(id) & ADMIN_LEVEL_H)
				{
					give_weapon_skull1(id)
					g_secondary[id] = true
				}
			}
		}
	return
}
/* Shot Guns */
public sh_h(id)
{
	if(cso_is_round_started() || cso_get_user_zombie(id))
		return
		
	static menu, string[128]
	
	formatex(string, sizeof(string), "\yShotguns")
	menu = menu_create(string, "sh_handle")
	
	formatex(string, sizeof(string), "\wLeone 12 Gauge Super \d- \y[\rFREE\y]")
	menu_additem(menu, string, "1", 0)
	
	if(cso_get_user_money(id) < 1000)
		formatex(string, sizeof(string), "\dLeone YG1265 Auto Shotgun - \y[\r1000$\y]")
	else
		formatex(string, sizeof(string), "\wLeone YG1265 Auto Shotgun \d- \y[\r1000$\y]")
	menu_additem(menu, string, "2", 0)
	
	if(cso_get_user_money(id) < 2000)
		formatex(string, sizeof(string), "\dDual Barrels - \y[\r2000$\y]")
	else
		formatex(string, sizeof(string), "\wDual Barrels \d- \y[\r2000$\y]")
	menu_additem(menu, string, "3", 0)
	
	if(cso_get_user_money(id) < 3000)
		formatex(string, sizeof(string), "\dWinchester M1887 - \y[\r3000$\y]")
	else
		formatex(string, sizeof(string), "\wWinchester M1887 \d- \y[\r3000$\y]")
	menu_additem(menu, string, "4", 0)
	
	
	if(cso_get_user_money(id) < 5000)
		formatex(string, sizeof(string), "\dSPAS 12 - \y[\r5000$\y]")
	else
		formatex(string, sizeof(string), "\wSPAS 12 \d- \y[\r5000$\y]")
	menu_additem(menu, string, "5", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}
public sh_handle(id, menu, item)
{
	if(cso_get_user_type_hero(id) || cso_get_user_type_heroine(id))
		return
		
	if(cso_get_user_zombie(id))
		return
		
	if(g_primary[id])
		return
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return
	}
	
		new data[6], szName[64];
		new access, callback;
		menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
		new key = str_to_num(data);
	
		switch(key)
		{
			case 1:
			{
				give_item(id, "weapon_m3")
				cs_set_user_bpammo(id, CSW_M3, 200)

				g_primary[id] = true
			}
			case 2:
			{
				if(cso_get_user_money(id) < 1000)
					{
						cso_blink_money(id)
						return
					}
				
				give_item(id, "weapon_xm1014")
				cs_set_user_bpammo(id, CSW_XM1014, 200)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-1000)
			}
			case 3:
			{
				if(cso_get_user_money(id) < 2000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_dbarrel(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-2000)
			}
			case 4:
			{
				if(cso_get_user_money(id) < 3000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_m1887(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-3000)
			}
			case 5:
			{
				if(cso_get_user_money(id) < 5000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_spas12(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-5000)
			}
		}
	return
}
// Automates
public at_h(id)
{
	if(cso_is_round_started() || cso_get_user_zombie(id))
		return

	static menu, string[128]
	
	formatex(string, sizeof(string), "\yAutomates")
	menu = menu_create(string, "at_handle")
	
	formatex(string, sizeof(string), "\wSchmidt Machine Pistol \d- \y[\rFREE\y]")
	menu_additem(menu, string, "1", 0)
	
	if(cso_get_user_money(id) < 1500)
		formatex(string, sizeof(string), "\dK&M UMP45 - \y[\r1500$\y]")
	else
		formatex(string, sizeof(string), "\wK&M UMP45 \d- \y[\r1500$\y]")
	menu_additem(menu, string, "2", 0)
	
	if(cso_get_user_money(id) < 2000)
		formatex(string, sizeof(string), "\dK&M Sub-Machine Gun - \y[\r2000$\y]")
	else
		formatex(string, sizeof(string), "\wK&M Sub-Machine Gun \d- \y[\r2000$\y]")
	menu_additem(menu, string, "3", 0)
	
	if(cso_get_user_money(id) < 2500)
		formatex(string, sizeof(string), "\dES C90 - \y[\r2500$\y]")
	else
		formatex(string, sizeof(string), "\wES C90 \d- \y[\r2500$\y]")
	menu_additem(menu, string, "4", 0)
	
	if(cso_get_user_money(id) < 3000)
		formatex(string, sizeof(string), "\dMP7A160R - \y[\r3000$\y]")
	else
		formatex(string, sizeof(string), "\wMP7A160R \d- \y[\r3000$\y]")
	menu_additem(menu, string, "5", 0)
	
	if(cso_get_user_money(id) < 5000)
		formatex(string, sizeof(string), "\dK1ASE - \y[\r5000$\y]")
	else
		formatex(string, sizeof(string), "\wK1ASE \d- \y[\r5000$\y]")
	menu_additem(menu, string, "6", 0)
	
	if(cso_get_user_money(id) < 7500)
		formatex(string, sizeof(string), "\dThompson - \y[\r7500$\y]")
	else
		formatex(string, sizeof(string), "\wThompson \d- \y[\r7500$\y]")
	menu_additem(menu, string, "7", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}
public at_handle(id, menu, item)
{
	if(cso_is_round_started() || cso_get_user_zombie(id))
		return
		
	if(cso_get_user_type_hero(id) || cso_get_user_type_heroine(id))
		return
		
	if(cso_get_user_zombie(id))
		return
	
	if(g_primary[id])
		return
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return
	}
	
		new data[6], szName[64];
		new access, callback;
		menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
		new key = str_to_num(data);
	
		switch(key)
		{
			case 1:
			{
				give_item(id, "weapon_tmp")
				cs_set_user_bpammo(id, CSW_TMP, 90)
				g_primary[id] = true
			}
			case 2:
			{
				if(cso_get_user_money(id) < 1500)
					{
						cso_blink_money(id)
						return
					}
					
				give_item(id, "weapon_ump45")
				cs_set_user_bpammo(id, CSW_UMP45, 90)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-1500)
			}
			case 3:
			{
				if(cso_get_user_money(id) < 2000)
					{
						cso_blink_money(id)
						return
					}
					
				give_item(id, "weapon_mp5navy")
				cs_set_user_bpammo(id, CSW_MP5NAVY, 90)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-2000)
			}
			case 4:
			{
				if(cso_get_user_money(id) < 2500)
					{
						cso_blink_money(id)
						return
					}
					
				give_item(id, "weapon_p90")
				cs_set_user_bpammo(id, CSW_P90, 90)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-2500)
			}
			case 5:
			{
				if(cso_get_user_money(id) < 3000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_mp7a160r(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-3000)
			}
			case 6:
			{
				if(cso_get_user_money(id) < 5000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_k1ase(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-5000)
			}
			case 7:
			{
				if(cso_get_user_money(id) < 7500)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_thompson(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-7500)
			}
		}
	return
}
// Ausault Rifles
public ar_h(id)
{
	if(cso_is_round_started() || cso_get_user_zombie(id))
		return
		
	static menu, string[128]
	
	formatex(string, sizeof(string), "\yAssault Rifles")
	menu = menu_create(string, "ar_handle")
	
	if(cso_get_user_money(id) < 2500)
		formatex(string, sizeof(string), "\dAK47 Kalashinkov - \y[\r2500$\y]")
	else
		formatex(string, sizeof(string), "\wAK47 Kalashinkov \d- \y[\r2500$\y]")
	menu_additem(menu, string, "1", 0)
	
	if(cso_get_user_money(id) < 2500)
		formatex(string, sizeof(string), "\dM4A1 Carabine - \y[\r2500$\y]")
	else
		formatex(string, sizeof(string), "\wM4A1 Carabine \d- \y[\r2500$\y]")
	menu_additem(menu, string, "2", 0)

	if(cso_get_user_money(id) < 4000)
		formatex(string, sizeof(string), "\dSCAR Limit - \y[\r4000$\y]")
	else
		formatex(string, sizeof(string), "\wSCAR Limit \d- \y[\r4000$\y]")
	menu_additem(menu, string, "3", 0)
	
	if(cso_get_user_money(id) < 6000)
		formatex(string, sizeof(string), "\dTavor TAR-21 - \y[\r6000$\y]")
	else
		formatex(string, sizeof(string), "\wTavor TAR-21 \d- \y[\r6000$\y]")
	menu_additem(menu, string, "4", 0)
	
	if(cso_get_user_money(id) < 9000)
		formatex(string, sizeof(string), "\dLightning AR-1 - \y[\r9000$\y]")
	else
		formatex(string, sizeof(string), "\wLightning AR-1 \d- \y[\r9000$\y]")
	menu_additem(menu, string, "5", 0)
	
	if(cso_get_user_money(id) < 12000)
		formatex(string, sizeof(string), "\dXM8 Limit - \y[\r12000$\y]")
	else
		formatex(string, sizeof(string), "\wXM8 Limit \d- \y[\r12000$\y]")
	menu_additem(menu, string, "6", 0)

	if(get_user_flags(id) & ADMIN_LEVEL_H)
		formatex(string, sizeof(string), "\wSoul Eater Skull 3 \d- \y[\rVIP]")
	else
		formatex(string, sizeof(string), "\dSoul Eater Skull 3 - \y[\rVIP]")
	menu_additem(menu, string, "7", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}
public ar_handle(id, menu, item)
{
	if(cso_get_user_type_hero(id) || cso_get_user_type_heroine(id))
		return
		
	if(cso_get_user_zombie(id))
		return
		
	if(g_primary[id])
		return
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return
	}
	
		new data[6], szName[64];
		new access, callback;
		menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
		new key = str_to_num(data);
	
		switch(key)
		{
			case 1:
			{
				if(cso_get_user_money(id) < 2500)
					{
						cso_blink_money(id)
						return
					}
					
				give_item(id, "weapon_ak47")
				cs_set_user_bpammo(id, CSW_AK47, 90)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-2500)
			}
			case 2:
			{
				if(cso_get_user_money(id) < 2500)
					{
						cso_blink_money(id)
						return
					}
					
				give_item(id, "weapon_m4a1")
				cs_set_user_bpammo(id, CSW_M4A1, 90)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-2500)
			}
			case 3:
			{
				if(cso_get_user_money(id) < 4000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_scar(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-4000)
			}
			case 4:
			{
				if(cso_get_user_money(id) < 6000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_tar21(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-6000)
			}
			case 5:
			{
				if(cso_get_user_money(id) < 9000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_guitar(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-9000)
			}
			case 6:
			{
				if(cso_get_user_money(id) < 12000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_xm8(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-12000)
			}
			case 7:
			{
				if(get_user_flags(id) & ADMIN_LEVEL_H)
				{
					give_weapon_skull3(id)
					g_primary[id] = true
				}
			}
		}
	return
}
// Sniper Rifles
public sr_h(id)
{
	if(cso_is_round_started() || cso_get_user_zombie(id))
		return
		
	static menu, string[128]
	
	formatex(string, sizeof(string), "\ySniper Rifles")
	menu = menu_create(string, "sr_handle")
	
	if(cso_get_user_money(id) < 2500)
		formatex(string, sizeof(string), "\dSchmidt Scout - \y[\r2500$\y]")
	else
		formatex(string, sizeof(string), "\wSchmidt Scout \d- \y[\r2500$\y]")
	menu_additem(menu, string, "1", 0)
	
	if(cso_get_user_money(id) < 3500)
		formatex(string, sizeof(string), "\dMagnum Sniper Rifle - \y[\r3500$\y]")
	else
		formatex(string, sizeof(string), "\wMagnum Sniper Rifle \d- \y[\r3500$\y]")
	menu_additem(menu, string, "2", 0)
	
	if(cso_get_user_money(id) < 5000)
		formatex(string, sizeof(string), "\dM24 - \y[\r5000$\y]")
	else
		formatex(string, sizeof(string), "\wM24 \d- \y[\r5000$\y]")
	menu_additem(menu, string, "3", 0)
	
	if(cso_get_user_money(id) < 8000)
		formatex(string, sizeof(string), "\dChey-Tac M200 - \y[\r8000$\y]")
	else
		formatex(string, sizeof(string), "\wChey-Tac M200 \d- \y[\r8000$\y]")
	menu_additem(menu, string, "4", 0)
	
	if(cso_get_user_money(id) < 20000)
		formatex(string, sizeof(string), "\dVSK 94 - \y[\r20000$\y]")
	else
		formatex(string, sizeof(string), "\wVSK 94 \d- \y[\r20000$\y]")
	menu_additem(menu, string, "5", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}
public sr_handle(id, menu, item)
{
	if(cso_get_user_type_hero(id) || cso_get_user_type_heroine(id))
		return
		
	if(cso_get_user_zombie(id))
		return
		
	if(g_primary[id])
		return
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return
	}
	
		new data[6], szName[64];
		new access, callback;
		menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
		new key = str_to_num(data);
	
		switch(key)
		{
			case 1:
			{
				if(cso_get_user_money(id) < 2500)
					{
						cso_blink_money(id)
						return
					}
					
				give_item(id, "weapon_scout")
				cs_set_user_bpammo(id, CSW_SCOUT, 90)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-2500)
			}
			case 2:
			{
				if(cso_get_user_money(id) < 3500)
					{
						cso_blink_money(id)
						return
					}
					
				give_item(id, "weapon_awp")
				cs_set_user_bpammo(id, CSW_AWP, 90)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-3500)
			}
			case 3:
			{
				if(cso_get_user_money(id) < 5000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_m24(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-5000)
			}
			case 4:
			{
				if(cso_get_user_money(id) < 8000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_m200(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-8000)
			}
			case 5:
			{
				if(cso_get_user_money(id) < 20000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_vsk94(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-20000)
			}
		}
	return
}
// Mashin Guns
public mg_h(id)
{
	if(cso_is_round_started() || cso_get_user_zombie(id))
		return
		
	static menu, string[128]
	
	formatex(string, sizeof(string), "\yMachine Guns")
	menu = menu_create(string, "mg_handle")
	
	if(cso_get_user_money(id) < 4500)
		formatex(string, sizeof(string), "\dM249 - \y[\r4500$\y]")
	else
		formatex(string, sizeof(string), "\wM249 \d- \y[\r4500$\y]")
	menu_additem(menu, string, "1", 0)
	
	if(cso_get_user_money(id) < 10500)
		formatex(string, sizeof(string), "\dMG3 - \y[\r10500$\y]")
	else
		formatex(string, sizeof(string), "\wMG3 \d- \y[\r10500$\y]")
	menu_additem(menu, string, "2", 0)
	
	if(cso_get_user_money(id) < 11000)
		formatex(string, sizeof(string), "\dPKM - \y[\r11000$\y]")
	else
		formatex(string, sizeof(string), "\wPKM \d- \y[\r11000$\y]")
	menu_additem(menu, string, "3", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}
public mg_handle(id, menu, item)
{
	if(cso_get_user_type_hero(id) || cso_get_user_type_heroine(id))
		return
		
	if(cso_get_user_zombie(id))
		return
		
	if(g_primary[id])
		return
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return
	}
	
		new data[6], szName[64];
		new access, callback;
		menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
		new key = str_to_num(data);
	
		switch(key)
		{
			case 1:
			{
				if(cso_get_user_money(id) < 4500)
					{
						cso_blink_money(id)
						return
					}
					
				give_item(id, "weapon_m249")
				cs_set_user_bpammo(id, CSW_M249, 200)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-4500)
			}
			case 2:
			{
				if(cso_get_user_money(id) < 10500)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_mg3(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-10500)
			}
			case 3:
			{
				if(cso_get_user_money(id) < 11000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_pkm(id)
				g_primary[id] = true
				cso_set_user_money(id, cso_get_user_money(id)-11000)
			}
		}
	return
}
public eq_m(id)
{
	if(cso_is_round_started() || cso_get_user_zombie(id))
		return
		
	static menu, string[128]
	
	formatex(string, sizeof(string), "\yEquipments")
	menu = menu_create(string, "eq_handle")
	
	if(cso_get_user_money(id) < 800)
		formatex(string, sizeof(string), "\dM67 Grenade - \y[\r800$\y]")
	else
		formatex(string, sizeof(string), "\wM67 Grenade \d- \y[\r800$\y]")
	menu_additem(menu, string, "1", 0)
	
	if(cso_get_user_money(id) < 1200)
		formatex(string, sizeof(string), "\wHoly Water Bottle - \y[\r1200$\y]")
	else
		formatex(string, sizeof(string), "\wHoly Water Bottle \d- \y[\r1200$\y]")
	menu_additem(menu, string, "2", 0)
	
	if(cso_get_user_money(id) < 5000)
		formatex(string, sizeof(string), "\dAnti-Infection Armor (50)- \y[\r5000$\y]")
	else
		formatex(string, sizeof(string), "\wAnti-Infection Armor (50)\d- \y[\r5000$\y]")
	menu_additem(menu, string, "3", 0)

	if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		if(cso_get_user_money(id) < 7500)
			formatex(string, sizeof(string), "\dAnti-Infection Armor (100)- \y[\r7500$\y][\rVIP\y]")
		else
			formatex(string, sizeof(string), "\wAnti-Infection Armor (100)\d- \y[\r7500$\y][\rVIP\y]")
	}
	else
		formatex(string, sizeof(string), "\wAnti-Infection Armor (100)\d- \y[\r7500$\y][\rVIP\y]")
	menu_additem(menu, string, "4", 0)
	/*
	if(cso_get_user_money(id) < 15000)
		formatex(string, sizeof(string), "\dRPG-7 - \y[\r15000$\y]")
	else
		formatex(string, sizeof(string), "\wRPG-7 \d- \y[\r15000$\y]")
	menu_additem(menu, string, "5", 0)*/

	if(cso_get_user_money(id) < 25000)
		formatex(string, sizeof(string), "\dMilkor M32 MGL - \y[\r25000$\y]")
	else
		formatex(string, sizeof(string), "\wMilkor M32 MGL \d- \y[\r25000$\y]")
	menu_additem(menu, string, "5", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}
public eq_handle(id, menu, item)
{
	if(cso_get_user_type_hero(id) || cso_get_user_type_heroine(id))
		return
		
	if(cso_get_user_zombie(id))
		return
		
	if(g_primary[id])
		return
	
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return
	}
	
		new data[6], szName[64];
		new access, callback;
		menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
		new key = str_to_num(data);
	
		switch(key)
		{
			case 1:
			{
				if(cso_get_user_money(id) < 800)
					{
						cso_blink_money(id)
						return
					}
					
				fm_give_item(id, "weapon_hegrenade")
				cso_set_user_money(id, cso_get_user_money(id)-800)
			}
			case 2:
			{
				if(cso_get_user_money(id) < 1200)
					{
						cso_blink_money(id)
						return
					}
					
				fm_give_item(id, "weapon_flashbang")
				cso_set_user_money(id, cso_get_user_money(id)-1200)
			}
			case 3:
			{
				if(cso_get_user_money(id) < 5000)
					{
						cso_blink_money(id)
						return
					}
					
				set_user_armor(id, 50)	
				cso_set_user_money(id, cso_get_user_money(id)-5000)
			}
			case 4:
			{
				if(get_user_flags(id) & ADMIN_LEVEL_H)
				{
					if(cso_get_user_money(id) < 7500)
						{
							cso_blink_money(id)
							return
						}
						
					set_user_armor(id, 100)	
					cso_set_user_money(id, cso_get_user_money(id)-7500)
				}
			}
			/*
			case 5:
			{
				if(cso_get_user_money(id) < 15000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_rpg7(id)
				cso_set_user_money(id, cso_get_user_money(id)-15000)
			}
			*/
			case 5:
			{
				if(cso_get_user_money(id) < 25000)
					{
						cso_blink_money(id)
						return
					}
					
				give_weapon_m32(id)
				cso_set_user_money(id, cso_get_user_money(id)-25000)
			}
		}
	return
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