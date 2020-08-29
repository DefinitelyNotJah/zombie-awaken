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

#define PLUGIN "CSO Awakens || Buy Menu"
#define VERSION "1.0"
#define AUTHOR "LegendofWarior"

#define is_user_valid_connected(%1) (1 <= %1 <= g_iMaxClients && g_isconnected[%1])

native cso_get_user_levels(id)
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

	g_iMaxClients = get_member_game(m_nMaxPlayers);
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
		if(!g_primary[id])
		{
			if(get_user_flags(id) & ADMIN_LEVEL_H)
			{
				give_weapon_skull3(id)
				client_printc(id, "!g[CSO]!n You have not picked any PW so you received a !tSkull 3 !nsince you are a !tVIP!n.")
			}
			else
			{
				give_item(id, "weapon_tmp")
				cs_set_user_bpammo(id, CSW_TMP, 90)
				client_printc(id, "!g[CSO]!n You have not picked any PW so you received a !tTMP!n.")
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
			else
			{
				give_item(id, "weapon_usp")
				cs_set_user_bpammo(id, CSW_USP, 90)
				client_printc(id, "!g[CSO]!n You have not picked any SW so you received a !tUSP!n.")
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
	if(cso_is_round_started())
		return PLUGIN_HANDLED;

	static menu[512], len
	len = 0
	
	// Title
	len += formatex(menu[len], charsmax(menu) - len, "\yCSO Awakens \r|| \yBuy Menu^n^n")
	// Items
	if(g_secondary[id])
		len += formatex(menu[len], charsmax(menu) - len, "\r1.\d Pistols^n")
	else
		len += formatex(menu[len], charsmax(menu) - len, "\r1.\w Pistols^n")
		
	if(g_primary[id]){
		len += formatex(menu[len], charsmax(menu) - len, "\r2.\d ShotGuns^n")
		len += formatex(menu[len], charsmax(menu) - len, "\r3.\d Automates^n")
		len += formatex(menu[len], charsmax(menu) - len, "\r4.\d Assault Rifles^n")
		len += formatex(menu[len], charsmax(menu) - len, "\r5.\d Sniper Rifles^n")
		len += formatex(menu[len], charsmax(menu) - len, "\r6.\d Machine Guns^n^n")
	}
	else
	{
		len += formatex(menu[len], charsmax(menu) - len, "\r2.\w ShotGuns^n")
		len += formatex(menu[len], charsmax(menu) - len, "\r3.\w Automates^n")
		len += formatex(menu[len], charsmax(menu) - len, "\r4.\w Assault Rifles^n")
		len += formatex(menu[len], charsmax(menu) - len, "\r5.\w Sniper Rifles^n")
		len += formatex(menu[len], charsmax(menu) - len, "\r6.\w Machine Guns^n^n")
	}
	len += formatex(menu[len], charsmax(menu) - len, "\r7.\w Choose a Knife")
	len += formatex(menu[len], charsmax(menu) - len, "^n^n\r0.\y Exit")
	 
	set_pdata_int(id, OFFSET_CSMENUCODE, 0, OFFSET_LINUX)
	show_menu(id, KEYSMENU, menu, -1, "Buy Menu")

	return PLUGIN_CONTINUE;
}
public buy_game(id, key) {
	if(cso_is_round_started())
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
		
	}
	return PLUGIN_HANDLED;
}
/* Pistols */
public pis_h(id)
{
	static menu, string[128]
	
	new level = cso_get_user_levels(id)
	
	formatex(string, sizeof(string), "\yPistols")
	menu = menu_create(string, "pis_handle")
	
	formatex(string, sizeof(string), "\K&M .45 Tactical \d- \yLevel 0")
	menu_additem(menu, string, "1", 0)
	
	if(level <= 4)
		formatex(string, sizeof(string), "\dNight Hawk .50C - \yLevel 5")
	else
		formatex(string, sizeof(string), "\wNight Hawk .50C \d- \yLevel 5")
	menu_additem(menu, string, "2", 0)
	
	if(level <= 14)
		formatex(string, sizeof(string), "\d.40 Dual Elites - \yLevel 15")
	else
		formatex(string, sizeof(string), "\w.40 Dual Elites \d- \yLevel 15")
	menu_additem(menu, string, "3", 0)
	
	if(level <= 24)
		formatex(string, sizeof(string), "\dDual Infinity - \yLevel 25")
	else
		formatex(string, sizeof(string), "\wDual Infinity \d- \yLevel 25")
	menu_additem(menu, string, "4", 0)
	
	if(get_user_flags(id) & ADMIN_LEVEL_H)
		formatex(string, sizeof(string), "\wSoul Eater Skull 1 \d- \r[VIP]")
	else
		formatex(string, sizeof(string), "\dSoul Eater Skull 1 - \r[VIP]")
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
		new level = cso_get_user_levels(id)
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
				if(level <= 4)
					return
				
				give_item(id, "weapon_deagle")
				cs_set_user_bpammo(id, CSW_DEAGLE, 90)
				g_secondary[id] = true
			}
			case 3:
			{
				if(level <= 14)
					return
					
				give_item(id, "weapon_elite")
				cs_set_user_bpammo(id, CSW_ELITE, 90)
				g_secondary[id] = true
			}
			case 4:
			{
				if(level <= 24)
					return
					
				give_weapon_infi(id)
				g_secondary[id] = true
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
	static menu, string[128]
	
	new level = cso_get_user_levels(id)
	
	formatex(string, sizeof(string), "\yShotguns")
	menu = menu_create(string, "sh_handle")
	
	formatex(string, sizeof(string), "\wLeone 12 Gauge Super \d- \yLevel 0")
	menu_additem(menu, string, "1", 0)
	
	if(level <= 2)
		formatex(string, sizeof(string), "\dLeone YG1265 Auto Shotgun - \yLevel 2")
	else
		formatex(string, sizeof(string), "\wLeone YG1265 Auto Shotgun \d- \yLevel 2")
	menu_additem(menu, string, "2", 0)
	
	if(level <= 4)
		formatex(string, sizeof(string), "\dDual Barrels - \yLevel 5")
	else
		formatex(string, sizeof(string), "\wDual Barrels \d- \yLevel 5")
	menu_additem(menu, string, "3", 0)
	
	if(level <= 19)
		formatex(string, sizeof(string), "\dWinchester M1887 - \yLevel 20")
	else
		formatex(string, sizeof(string), "\wWinchester M1887 \d- \yLevel 20")
	menu_additem(menu, string, "4", 0)
	
	
	if(level <= 49)
		formatex(string, sizeof(string), "\dSPAS 12 - \yLevel 50")
	else
		formatex(string, sizeof(string), "\wSPAS 12 \d- \yLevel 50")
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
		new level = cso_get_user_levels(id)
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
				if(level <= 2)
					return
				
				give_item(id, "weapon_xm1014")
				cs_set_user_bpammo(id, CSW_XM1014, 200)
				g_primary[id] = true
			}
			case 3:
			{
				if(level <= 4)
					return
					
				give_weapon_dbarrel(id)
				g_primary[id] = true
			}
			case 4:
			{
				if(level <= 19)
					return
					
				give_weapon_m1887(id)
				g_primary[id] = true
			}
			case 5:
			{
				if(level <= 49)
					return
					
				give_weapon_spas12(id)
				g_primary[id] = true
			}
		}
	return
}
// Automates
public at_h(id)
{
	static menu, string[128]
	
	new level = cso_get_user_levels(id)
	
	formatex(string, sizeof(string), "\yAutomates")
	menu = menu_create(string, "at_handle")
	
	formatex(string, sizeof(string), "\wSchmidt Machine Pistol \d- \yLevel 0")
	menu_additem(menu, string, "1", 0)
	
	if(level <= 2)
		formatex(string, sizeof(string), "\dK&M UMP45 - \yLevel 3")
	else
		formatex(string, sizeof(string), "\wK&M UMP45 \d- \yLevel 3")
	menu_additem(menu, string, "2", 0)
	
	if(level <= 4)
		formatex(string, sizeof(string), "\dK&M Sub-Machine Gun - \yLevel 5")
	else
		formatex(string, sizeof(string), "\wK&M Sub-Machine Gun \d- \yLevel 5")
	menu_additem(menu, string, "3", 0)
	
	if(level <= 9)
		formatex(string, sizeof(string), "\dES C90 - \yLevel 10")
	else
		formatex(string, sizeof(string), "\wES C90 \d- \yLevel 10")
	menu_additem(menu, string, "4", 0)
	
	if(level <= 14)
		formatex(string, sizeof(string), "\dMP7A160R - \yLevel 15")
	else
		formatex(string, sizeof(string), "\wMP7A160R \d- \yLevel 15")
	menu_additem(menu, string, "5", 0)
	
	if(level <= 29)
		formatex(string, sizeof(string), "\dK1ASE - \yLevel 30")
	else
		formatex(string, sizeof(string), "\wK1ASE \d- \yLevel 30")
	menu_additem(menu, string, "6", 0)
	
	if(level <= 49)
		formatex(string, sizeof(string), "\dThompson - \yLevel 50")
	else
		formatex(string, sizeof(string), "\wThompson \d- \yLevel 50")
	menu_additem(menu, string, "7", 0)
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
	menu_display(id, menu, 0)
}
public at_handle(id, menu, item)
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
		new level = cso_get_user_levels(id)
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
				if(level <= 2)
					return
					
				give_item(id, "weapon_ump45")
				cs_set_user_bpammo(id, CSW_UMP45, 90)
				g_primary[id] = true
			}
			case 3:
			{
				if(level <= 4)
					return
					
				give_item(id, "weapon_mp5navy")
				cs_set_user_bpammo(id, CSW_MP5NAVY, 90)
				g_primary[id] = true
			}
			case 4:
			{
				if(level <= 9)
					return
					
				give_item(id, "weapon_p90")
				cs_set_user_bpammo(id, CSW_P90, 90)
				g_primary[id] = true
			}
			case 5:
			{
				if(level <= 14)
					return
					
				give_weapon_mp7a160r(id)
				g_primary[id] = true
			}
			case 6:
			{
				if(level <= 29)
					return
					
				give_weapon_k1ase(id)
				g_primary[id] = true
			}
			case 7:
			{
				if(level <= 49)
					return
					
				give_weapon_thompson(id)
				g_primary[id] = true
			}
		}
	return
}
// Ausault Rifles
public ar_h(id)
{
	static menu, string[128]
	
	new level = cso_get_user_levels(id)
	
	formatex(string, sizeof(string), "\yAssault Rifles")
	menu = menu_create(string, "ar_handle")
	
	if(level <= 2)
		formatex(string, sizeof(string), "\dAK47 Kalashinkov - \yLevel 5")
	else
		formatex(string, sizeof(string), "\wAK47 Kalashinkov \d- \yLevel 5")
	menu_additem(menu, string, "1", 0)
	
	if(level <= 9)
		formatex(string, sizeof(string), "\dM4A1 Carabine - \yLevel 10")
	else
		formatex(string, sizeof(string), "\wM4A1 Carabine \d- \yLevel 10")
	menu_additem(menu, string, "2", 0)

	if(level <= 19)
		formatex(string, sizeof(string), "\dSCAR Limit - \yLevel 20")
	else
		formatex(string, sizeof(string), "\wSCAR Limit \d- \yLevel 20")
	menu_additem(menu, string, "3", 0)
	
	if(level <= 29)
		formatex(string, sizeof(string), "\dTavor TAR-21 - \yLevel 30")
	else
		formatex(string, sizeof(string), "\wTavor TAR-21 \d- \yLevel 30")
	menu_additem(menu, string, "4", 0)
	
	if(level <= 49)
		formatex(string, sizeof(string), "\dLightning AR-1 - \yLevel 50")
	else
		formatex(string, sizeof(string), "\wLightning AR-1 \d- \yLevel 50")
	menu_additem(menu, string, "5", 0)
	
	if(level <= 74)
		formatex(string, sizeof(string), "\dXM8 Limit - \yLevel 75")
	else
		formatex(string, sizeof(string), "\wXM8 Limit \d- \yLevel 75")
	menu_additem(menu, string, "6", 0)

	if(get_user_flags(id) & ADMIN_LEVEL_H)
		formatex(string, sizeof(string), "\wSoul Eater Skull 3 \d- \r[VIP]")
	else
		formatex(string, sizeof(string), "\dSoul Eater Skull 3 - \r[VIP]")
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
		new level = cso_get_user_levels(id)
		menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
		new key = str_to_num(data);
	
		switch(key)
		{
			case 1:
			{
				if(level <= 4)
					return
					
				give_item(id, "weapon_ak47")
				cs_set_user_bpammo(id, CSW_AK47, 90)
				g_primary[id] = true
			}
			case 2:
			{
				if(level <= 9)
					return
					
				give_item(id, "weapon_m4a1")
				cs_set_user_bpammo(id, CSW_M4A1, 90)
				g_primary[id] = true
			}
			case 3:
			{
				if(level <= 19)
					return
					
				give_weapon_scar(id)
				g_primary[id] = true
			}
			case 4:
			{
				if(level <= 29)
					return
					
				give_weapon_tar21(id)
				g_primary[id] = true
			}
			case 5:
			{
				if(level <= 49)
					return
					
				give_weapon_guitar(id)
				g_primary[id] = true
			}
			case 6:
			{
				if(level <= 74)
					return
					
				give_weapon_xm8(id)
				g_primary[id] = true
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
	static menu, string[128]
	
	new level = cso_get_user_levels(id)
	
	formatex(string, sizeof(string), "\ySniper Rifles")
	menu = menu_create(string, "sr_handle")
	
	if(level <= 7)
		formatex(string, sizeof(string), "\dSchmidt Scout - \yLevel 8")
	else
		formatex(string, sizeof(string), "\wSchmidt Scout \d- \yLevel 8")
	menu_additem(menu, string, "1", 0)
	
	if(level <= 13)
		formatex(string, sizeof(string), "\dMagnum Sniper Rifle - \yLevel 14")
	else
		formatex(string, sizeof(string), "\wMagnum Sniper Rifle \d- \yLevel 14")
	menu_additem(menu, string, "2", 0)
	
	if(level <= 24)
		formatex(string, sizeof(string), "\dM24 - \yLevel 25")
	else
		formatex(string, sizeof(string), "\wM24 \d- \yLevel 25")
	menu_additem(menu, string, "3", 0)
	
	if(level <= 39)
		formatex(string, sizeof(string), "\dChey-Tac M200 - \yLevel 40")
	else
		formatex(string, sizeof(string), "\wChey-Tac M200 \d- \yLevel 40")
	menu_additem(menu, string, "4", 0)
	
	if(level <= 59)
		formatex(string, sizeof(string), "\dVSK 94 - \yLevel 60")
	else
		formatex(string, sizeof(string), "\wVSK 94 \d- \yLevel 60")
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
		new level = cso_get_user_levels(id)
		menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
		new key = str_to_num(data);
	
		switch(key)
		{
			case 1:
			{
				if(level <= 7)
					return
					
				give_item(id, "weapon_scout")
				cs_set_user_bpammo(id, CSW_SCOUT, 90)
				g_primary[id] = true
			}
			case 2:
			{
				if(level <= 13)
					return
					
				give_item(id, "weapon_awp")
				cs_set_user_bpammo(id, CSW_AWP, 90)
				g_primary[id] = true
			}
			case 3:
			{
				if(level <= 24)
					return
					
				give_weapon_m24(id)
				g_primary[id] = true
			}
			case 4:
			{
				if(level <= 39)
					return
					
				give_weapon_m200(id)
				g_primary[id] = true
			}
			case 5:
			{
				if(level <= 59)
					return
					
				give_weapon_vsk94(id)
				g_primary[id] = true
			}
		}
	return
}
// Mashin Guns
public mg_h(id)
{
	static menu, string[128]
	
	new level = cso_get_user_levels(id)
	
	formatex(string, sizeof(string), "\yMachine Guns")
	menu = menu_create(string, "mg_handle")
	
	if(level <= 9)
		formatex(string, sizeof(string), "\dM249 - \yLevel 10")
	else
		formatex(string, sizeof(string), "\wM249 \d- \yLevel 10")
	menu_additem(menu, string, "1", 0)
	
	if(level <= 24)
		formatex(string, sizeof(string), "\dMG3 - \yLevel 25")
	else
		formatex(string, sizeof(string), "\wMG3 \d- \yLevel 25")
	menu_additem(menu, string, "2", 0)
	
	if(level <= 49)
		formatex(string, sizeof(string), "\dPKM - \yLevel 50")
	else
		formatex(string, sizeof(string), "\wPKM \d- \yLevel 50")
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
		new level = cso_get_user_levels(id)
		menu_item_getinfo(menu, item, access, data,charsmax(data), szName,charsmax(szName), callback)
		new key = str_to_num(data);
	
		switch(key)
		{
			case 1:
			{
				if(level <= 9)
					return
					
				give_item(id, "weapon_m249")
				cs_set_user_bpammo(id, CSW_M249, 200)
				g_primary[id] = true
			}
			case 2:
			{
				if(level <= 24)
					return
					
				give_weapon_mg3(id)
				g_primary[id] = true
			}
			case 3:
			{
				if(level <= 49)
					return
					
				give_weapon_pkm(id)
				g_primary[id] = true
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
