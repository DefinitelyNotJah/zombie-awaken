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

new g_save, g_save3

new prim[33], sec[33]
native cso_get_user_levels(id)
native cso_get_user_zombie(id)
native cso_open_knife_menu(id)
native cso_get_user_type_hero(id)
native cso_get_user_type_heroine(id)
native cso_is_round_started()

native give_weapon_luger(id)
native give_weapon_infi(id)
native give_weapon_anaconda(id)

native give_weapon_dbarrel(id)
native give_weapon_m1887(id)
native give_weapon_usas(id)
native give_weapon_ksg12(id)
native give_weapon_spas12(id)

native give_weapon_tmpdragon(id)
native give_weapon_p90lapin(id)
native give_weapon_mp5tiger(id)
native give_weapon_mp7a160r(id) 
native give_weapon_k1ase(id)
native give_weapon_thompson(id)

native give_weapon_akdragon(id)
native give_weapon_m4a1dragon(id)
native give_weapon_m14ebr(id)
native give_weapon_scar(id)
native give_weapon_tar21(id)
native give_weapon_guitar(id)
native give_weapon_xm8(id)

native give_weapon_m24(id)
native give_weapon_awpcamo(id)
//native give_weapon_m200(id)
native give_weapon_xm2010(id)
native give_weapon_vsk94(id)

native give_weapon_hk23(id)
native give_weapon_mg3(id)
native give_weapon_m60e4(id)
native give_weapon_pkm(id)

const OFFSET_CSMENUCODE = 205
const OFFSET_LINUX = 5;

new gMsg_BuyClose

const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0;

new g_secondary[33], g_primary[33]

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("say /buy", "buy_clcmd")
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn_Post", 1);
	register_menu("Buy Menu", KEYSMENU, "buy_game");// Add your code here...)
	
	g_save = nvault_open("AUTOBUY1_SAVE")
	g_save3 = nvault_open("AUTOBUY2_SAVE")

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
}
public clcmd_client_buy_open(id)
{
	message_begin(MSG_ONE, gMsg_BuyClose, _, id)
	message_end()

	return buy_clcmd(id)
}

public fw_PlayerSpawn_Post(id)
{
	g_primary[id] = false
	g_secondary[id] = false
}
public plugin_natives()
{
	register_native("cso_open_buy_menu", "native_open_buy_menu", 1)
}
public native_open_buy_menu(id)
{
	buy_clcmd(id)
}
public client_connect(id)
{
	prim[id] = 0
	sec[id] = 0
	Load_Data(id)
}
public client_disconnect(id)
{
	Save_Data(id)
	prim[id] = 0
	sec[id] = 0
}
public give_dangerous(id, item)
{
	switch(item)
	{
		case 1 :
		{
			give_item(id, "weapon_xm1014")
			cs_set_user_bpammo(id, CSW_XM1014, 200)
		}
		case 2 :
		{
			//give_item(id, "weapon_m3")
			//cs_set_user_bpammo(id, CSW_M3, 200)
		}
		case 3 :
		{
			give_item(id, "weapon_tmp")
			cs_set_user_bpammo(id, CSW_TMP, 90)
		}
		case 4 :
		{
			//give_item(id, "weapon_ump45")
			//cs_set_user_bpammo(id, CSW_UMP45, 90)
		}
		case 5 :
		{
			give_item(id, "weapon_ak47")
			cs_set_user_bpammo(id, CSW_AK47, 90)
		}
		case 6 :
		{
			give_item(id, "weapon_m4a1")
			cs_set_user_bpammo(id, CSW_M4A1, 90)
		}
		case 7 :
		{
			give_item(id, "weapon_scout")
			cs_set_user_bpammo(id, CSW_SCOUT, 90)
		}
		case 8 :
		{
			give_item(id, "weapon_awp")
			cs_set_user_bpammo(id, CSW_AWP, 90)
		}
		case 9 :
		{
			give_item(id, "weapon_m249")
			cs_set_user_bpammo(id, CSW_M249, 200)
		}
		case 10 :
		{
			give_item(id, "weapon_usp")
			cs_set_user_bpammo(id, CSW_USP, 90)
		}
		case 11 :
		{
			give_item(id, "weapon_deagle")
			cs_set_user_bpammo(id, CSW_DEAGLE, 90)
		}
	}
}
public auto_buy(id)
{
	if(!g_primary[id] && !cso_is_round_started()) 
	{
		if(prim[id] == 0)
			give_dangerous(id, 1)
		else if(prim[id] == 1)
			give_dangerous(id, 2)
		else if(prim[id] == 2)
			give_weapon_dbarrel(id)
		else if(prim[id] == 3)
			give_weapon_m1887(id)
		else if(prim[id] == 4)
			give_weapon_usas(id)
		else if(prim[id] == 5)
			give_weapon_ksg12(id)
		else if(prim[id] == 6)
			give_weapon_spas12(id)
		else if(prim[id] == 7)
			give_dangerous(id, 3)
		else if(prim[id] == 8)
			give_dangerous(id, 4)
		else if(prim[id] == 9)
			give_weapon_tmpdragon(id)
		else if(prim[id] == 10)
			give_weapon_p90lapin(id)
		else if(prim[id] == 11)
			give_weapon_mp5tiger(id)
		else if(prim[id] == 12)
			give_weapon_mp7a160r(id)
		else if(prim[id] == 13)
			give_weapon_k1ase(id)
		else if(prim[id] == 14)
			give_weapon_thompson(id)
		else if(prim[id] == 15)
			give_dangerous(id, 5)
		else if(prim[id] == 16)
			give_dangerous(id, 6)
		else if(prim[id] == 17)
			give_weapon_akdragon(id)
		else if(prim[id] == 18)
			give_weapon_m4a1dragon(id)
		else if(prim[id] == 19)
			give_weapon_m14ebr(id)
		else if(prim[id] == 20)
			give_weapon_scar(id)
		else if(prim[id] == 21)
			give_weapon_tar21(id)
		else if(prim[id] == 22)
			give_weapon_guitar(id)
		else if(prim[id] == 23)
			give_weapon_xm8(id)
		else if(prim[id] == 24)
			give_dangerous(id, 7)
		else if(prim[id] == 25)
			give_dangerous(id, 8)
		else if(prim[id] == 26)
			give_weapon_m24(id)
		else if(prim[id] == 27)
			give_weapon_awpcamo(id)
		//else if(prim[id] == 28)
			//give_weapon_m200(id)
		else if(prim[id] == 29)
			give_weapon_xm2010(id)
		else if(prim[id] == 30)
			give_weapon_vsk94(id)
		else if(prim[id] == 31)
			give_dangerous(id, 9)
		else if(prim[id] == 32)
			give_weapon_hk23(id)
		else if(prim[id] == 33)
			give_weapon_mg3(id)
		else if(prim[id] == 34)
			give_weapon_m60e4(id)	
		else if(prim[id] == 35)
			give_weapon_pkm(id)
		g_primary[id]  = true
	}
	if(!g_secondary[id] && !cso_is_round_started()) 
	{
		if(sec[id] == 0)
			give_dangerous(id, 10)
		else if(sec[id] == 1)
			give_dangerous(id, 11)
		else if(sec[id] == 2)
			give_weapon_luger(id)
		else if(sec[id] == 3)
			give_weapon_infi(id)
		else if(sec[id] == 4)
			give_weapon_anaconda(id)
		else if(sec[id] == 5)
			give_dangerous(id, 11)
		g_secondary[id] = true
	}
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
public show_buy_menu(id) {
	
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
	
	formatex(string, sizeof(string), "\wUSP \d- \yLevel 0")
	menu_additem(menu, string, "1", 0)
	
	if(level <= 4)
		formatex(string, sizeof(string), "\dDeagle - \yLevel 5")
	else
		formatex(string, sizeof(string), "\wDeagle \d- \yLevel 5")
	menu_additem(menu, string, "2", 0)
	
	if(level <= 14)
		formatex(string, sizeof(string), "\dLuger - \yLevel 15")
	else
		formatex(string, sizeof(string), "\wLuger \d- \yLevel 15")
	menu_additem(menu, string, "3", 0)
	
	if(level <= 29)
		formatex(string, sizeof(string), "\dDual Infinity - \yLevel 30")
	else
		formatex(string, sizeof(string), "\wDual Infinity \d- \yLevel 30")
	menu_additem(menu, string, "4", 0)
	
	if(level <= 49)
		formatex(string, sizeof(string), "\dAnaconda - \yLevel 50")
	else
		formatex(string, sizeof(string), "\wAnaconda \d- \yLevel 50")
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
				sec[id] = 0
			}
			case 2:
			{
				if(level <= 4)
					return
				
				give_item(id, "weapon_deagle")
				cs_set_user_bpammo(id, CSW_DEAGLE, 90)
				g_secondary[id] = true
				sec[id] = 1
			}
			case 3:
			{
				if(level <= 14)
					return
					
				give_weapon_luger(id)
				g_secondary[id] = true
				sec[id] = 2
			}
			case 4:
			{
				if(level <= 29)
					return
					
				give_weapon_infi(id)
				g_secondary[id] = true
				sec[id] = 3
			}
			case 5:
			{
				if(level <= 49)
					return
					
				give_weapon_anaconda(id)
				g_secondary[id] = true
				sec[id] = 4
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
	
	formatex(string, sizeof(string), "\wXM1014 \d- \yLevel 0")
	menu_additem(menu, string, "1", 0)
	
	if(level <= 1000)
		formatex(string, sizeof(string), "\dUNAVAILABLE - \yLevel 2")
	else
		formatex(string, sizeof(string), "\wUNAVAILABLE \d- \yLevel 2")
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
	
	if(level <= 39)
		formatex(string, sizeof(string), "\dUSAS 12 - \yLevel 40")
	else
		formatex(string, sizeof(string), "\wUSAS 12 \d- \yLevel 40")
	menu_additem(menu, string, "5", 0)

	if(level <= 59)
		formatex(string, sizeof(string), "\dKSG 12 - \yLevel 60")
	else
		formatex(string, sizeof(string), "\wKSG 12 \d- \yLevel 60")
	menu_additem(menu, string, "6", 0)
	
	if(level <= 79)
		formatex(string, sizeof(string), "\dSPAS 12 - \yLevel 80")
	else
		formatex(string, sizeof(string), "\wSPAS 12 \d- \yLevel 80")
	menu_additem(menu, string, "7", 0)
	
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
				give_item(id, "weapon_xm1014")
				cs_set_user_bpammo(id, CSW_XM1014, 200)
				g_primary[id] = true
				prim[id] = 0
			}
			case 2:
			{
				if(level <= 1000)
					return
				
				//give_item(id, "weapon_m3")
				//cs_set_user_bpammo(id, CSW_M3, 200)
				g_primary[id] = true
				prim[id] = 1
			}
			case 3:
			{
				if(level <= 4)
					return
					
				give_weapon_dbarrel(id)
				g_primary[id] = true
				prim[id] = 2
			}
			case 4:
			{
				if(level <= 19)
					return
					
				give_weapon_m1887(id)
				g_primary[id] = true
				prim[id] = 3
			}
			case 5:
			{
				if(level <= 39)
					return
					
				give_weapon_usas(id)
				g_primary[id] = true
				prim[id] = 4
			}
			case 6:
			{
				if(level <= 59)
					return
					
				give_weapon_ksg12(id)
				g_primary[id] = true
				prim[id] = 5
			}
			case 7:
			{
				if(level <= 79)
					return
					
				give_weapon_spas12(id)
				g_primary[id] = true
				prim[id] = 6
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
	
	if(level <= 2)
		formatex(string, sizeof(string), "\dTMP - \yLevel 3")
	else
		formatex(string, sizeof(string), "\wTMP \d- \yLevel 3")
	menu_additem(menu, string, "1", 0)
	
	if(level <= 4000)
		formatex(string, sizeof(string), "\dUNAVAILABLE - \yLevel 5")
	else
		formatex(string, sizeof(string), "\wUNAVAILABLE \d- \yLevel 5")
	menu_additem(menu, string, "2", 0)
	
	if(level <= 9)
		formatex(string, sizeof(string), "\dTMP Dragon - \yLevel 10")
	else
		formatex(string, sizeof(string), "\wTMP Dragon \d- \yLevel 10")
	menu_additem(menu, string, "3", 0)
	
	if(level <= 14)
		formatex(string, sizeof(string), "\dP90 Lapin - \yLevel 15")
	else
		formatex(string, sizeof(string), "\wP90 Lapin \d- \yLevel 15")
	menu_additem(menu, string, "4", 0)
	
	
	if(level <= 19)
		formatex(string, sizeof(string), "\dMP5 Tiger - \yLevel 20")
	else
		formatex(string, sizeof(string), "\wMP5 Tiger \d- \yLevel 20")
	menu_additem(menu, string, "5", 0)

	if(level <= 24)
		formatex(string, sizeof(string), "\dMP7A160R - \yLevel 25")
	else
		formatex(string, sizeof(string), "\wMP7A160R \d- \yLevel 25")
	menu_additem(menu, string, "6", 0)
	
	if(level <= 29)
		formatex(string, sizeof(string), "\dK1ASE - \yLevel 30")
	else
		formatex(string, sizeof(string), "\wK1ASE \d- \yLevel 30")
	menu_additem(menu, string, "7", 0)
	
	if(level <= 49)
		formatex(string, sizeof(string), "\dThompson - \yLevel 50")
	else
		formatex(string, sizeof(string), "\wThompson \d- \yLevel 50")
	menu_additem(menu, string, "8", 0)
	
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
				if(level <= 2)
					return
					
				give_item(id, "weapon_tmp")
				cs_set_user_bpammo(id, CSW_TMP, 90)
				g_primary[id] = true
				prim[id] = 7
			}
			case 2:
			{
				if(level <= 4000)
					return
					
				//give_item(id, "weapon_ump45")
				//cs_set_user_bpammo(id, CSW_UMP45, 90)
				g_primary[id] = true
				prim[id] = 8
			}
			case 3:
			{
				if(level <= 9)
					return
					
				give_weapon_tmpdragon(id)
				g_primary[id] = true
				prim[id] = 9
			}
			case 4:
			{
				if(level <= 14)
					return
					
				give_weapon_p90lapin(id)
				g_primary[id] = true
				prim[id] = 10
			}
			case 5:
			{
				if(level <= 19)
					return
					
				give_weapon_mp5tiger(id)
				g_primary[id] = true
				prim[id] = 11
			}
			case 6:
			{
				if(level <= 24)
					return
					
				give_weapon_mp7a160r(id)
				g_primary[id] = true
				prim[id] = 12
			}
			case 7:
			{
				if(level <= 29)
					return
					
				give_weapon_k1ase(id)
				g_primary[id] = true
				prim[id] = 13
			}
			case 8:
			{
				if(level <= 49)
					return
					
				give_weapon_thompson(id)
				g_primary[id] = true
				prim[id] = 14
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
	
	if(level <= 14)
		formatex(string, sizeof(string), "\dAK47 Red Dragon - \yLevel 15")
	else
		formatex(string, sizeof(string), "\wAK47 Red Dragon \d- \yLevel 15")
	menu_additem(menu, string, "3", 0)
	
	if(level <= 19)
		formatex(string, sizeof(string), "\dM4A1 Ice Dragon - \yLevel 20")
	else
		formatex(string, sizeof(string), "\wM4A1 Ice Dragon \d- \yLevel 20")
	menu_additem(menu, string, "4", 0)
	
	
	if(level <= 34)
		formatex(string, sizeof(string), "\dBlack Tornado M14 EBR - \yLevel 35")
	else
		formatex(string, sizeof(string), "\wBlack Tornado M14 EBR \d- \yLevel 35")
	menu_additem(menu, string, "5", 0)

	if(level <= 49)
		formatex(string, sizeof(string), "\dSCAR Limit - \yLevel 50")
	else
		formatex(string, sizeof(string), "\wSCAR Limit \d- \yLevel 50")
	menu_additem(menu, string, "6", 0)
	
	if(level <= 74)
		formatex(string, sizeof(string), "\dTavor TAR-21 - \yLevel 75")
	else
		formatex(string, sizeof(string), "\wTavor TAR-21 \d- \yLevel 75")
	menu_additem(menu, string, "7", 0)
	
	if(level <= 84)
		formatex(string, sizeof(string), "\dLightning AR-1 - \yLevel 85")
	else
		formatex(string, sizeof(string), "\wLightning AR-1 \d- \yLevel 85")
	menu_additem(menu, string, "8", 0)
	
	if(level <= 89)
		formatex(string, sizeof(string), "\dXM8 Limit - \yLevel 90")
	else
		formatex(string, sizeof(string), "\wXM8 Limit \d- \yLevel 90")
	menu_additem(menu, string, "9", 0)
	
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
				prim[id] = 15
			}
			case 2:
			{
				if(level <= 9)
					return
					
				give_item(id, "weapon_m4a1")
				cs_set_user_bpammo(id, CSW_M4A1, 90)
				g_primary[id] = true
				prim[id] = 16
			}
			case 3:
			{
				if(level <= 14)
					return
					
				give_weapon_akdragon(id)
				g_primary[id] = true
				prim[id] = 17
			}
			case 4:
			{
				if(level <= 19)
					return
					
				give_weapon_m4a1dragon(id)
				g_primary[id] = true
				prim[id] = 18
			}
			case 5:
			{
				if(level <= 34)
					return
					
				give_weapon_m14ebr(id)
				g_primary[id] = true
				prim[id] = 19
			}
			case 6:
			{
				if(level <= 49)
					return
					
				give_weapon_scar(id)
				g_primary[id] = true
				prim[id] = 20
			}
			case 7:
			{
				if(level <= 74)
					return
					
				give_weapon_tar21(id)
				g_primary[id] = true
				prim[id] = 21
			}
			case 8:
			{
				if(level <= 84)
					return
					
				give_weapon_guitar(id)
				g_primary[id] = true
				prim[id] = 22
			}
			case 9:
			{
				if(level <= 89)
					return
					
				give_weapon_xm8(id)
				g_primary[id] = true
				prim[id] = 23
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
		formatex(string, sizeof(string), "\dScout - \yLevel 8")
	else
		formatex(string, sizeof(string), "\wScout \d- \yLevel 8")
	menu_additem(menu, string, "1", 0)
	
	if(level <= 13)
		formatex(string, sizeof(string), "\dAWP - \yLevel 14")
	else
		formatex(string, sizeof(string), "\wAWP \d- \yLevel 14")
	menu_additem(menu, string, "2", 0)
	
	if(level <= 29)
		formatex(string, sizeof(string), "\dM24 - \yLevel 30")
	else
		formatex(string, sizeof(string), "\wM24 \d- \yLevel 30")
	menu_additem(menu, string, "3", 0)
	
	if(level <= 49)
		formatex(string, sizeof(string), "\dAWP Camo - \yLevel 50")
	else
		formatex(string, sizeof(string), "\wAWP Camo \d- \yLevel 50")
	menu_additem(menu, string, "4", 0)
	
	
	if(level <= 690)
		formatex(string, sizeof(string), "\dUNAVAILABLE - \yLevel 70")
	else
		formatex(string, sizeof(string), "\wUNAVAILABLE \d- \yLevel 70")
	menu_additem(menu, string, "5", 0)

	if(level <= 84)
		formatex(string, sizeof(string), "\dDevil XM2010 - \yLevel 85")
	else
		formatex(string, sizeof(string), "\wDevil XM2010 \d- \yLevel 85")
	menu_additem(menu, string, "6", 0)
	
	if(level <= 99)
		formatex(string, sizeof(string), "\dVSK 94 - \yLevel 100")
	else
		formatex(string, sizeof(string), "\wVSK 94 \d- \yLevel 100")
	menu_additem(menu, string, "7", 0)
	
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
				prim[id] = 24
			}
			case 2:
			{
				if(level <= 13)
					return
					
				give_item(id, "weapon_awp")
				cs_set_user_bpammo(id, CSW_AWP, 90)
				g_primary[id] = true
				prim[id] = 25
			}
			case 3:
			{
				if(level <= 29)
					return
					
				give_weapon_m24(id)
				g_primary[id] = true
				prim[id] = 26
			}
			case 4:
			{
				if(level <= 49)
					return
					
				give_weapon_awpcamo(id)
				g_primary[id] = true
				prim[id] = 27
			}
			case 5:
			{
				if(level <= 690)
					return
					
				//give_weapon_m200(id)
				g_primary[id] = true
				prim[id] = 28
			}
			case 6:
			{
				if(level <= 84)
					return
					
				give_weapon_xm2010(id)
				g_primary[id] = true
				prim[id] = 29
			}
			case 7:
			{
				if(level <= 99)
					return
					
				give_weapon_vsk94(id)
				g_primary[id] = true
				prim[id] = 30
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
	
	if(level <= 19)
		formatex(string, sizeof(string), "\dH&K HK23E - \yLevel 20")
	else
		formatex(string, sizeof(string), "\wH&K HK23E \d- \yLevel 20")
	menu_additem(menu, string, "2", 0)
	
	if(level <= 29)
		formatex(string, sizeof(string), "\dMG3 - \yLevel 30")
	else
		formatex(string, sizeof(string), "\wMG3 \d- \yLevel 30")
	menu_additem(menu, string, "3", 0)
	
	if(level <= 39)
		formatex(string, sizeof(string), "\dM60E4 - \yLevel 40")
	else
		formatex(string, sizeof(string), "\wM60E4 \d- \yLevel 40")
	menu_additem(menu, string, "4", 0)
	
	
	if(level <= 49)
		formatex(string, sizeof(string), "\dPKM - \yLevel 50")
	else
		formatex(string, sizeof(string), "\wPKM \d- \yLevel 50")
	menu_additem(menu, string, "5", 0)
	
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
				prim[id] = 31
			}
			case 2:
			{
				if(level <= 19)
					return
					
				give_weapon_hk23(id)
				g_primary[id] = true
				prim[id] = 32
			}
			case 3:
			{
				if(level <= 29)
					return
					
				give_weapon_mg3(id)
				g_primary[id] = true
				prim[id] = 33
			}
			case 4:
			{
				if(level <= 39)
					return
					
				give_weapon_m60e4(id)
				g_primary[id] = true
				prim[id] = 34
			}
			case 5:
			{
				if(level <= 49)
					return
					
				give_weapon_pkm(id)
				g_primary[id] = true
				prim[id] = 35
			}
		}
	return
}
// Save
public Save_Data(id)
{
	new vaultkey[64], vaultdata[256], vaultdata2[256]

	new name[33];
	get_user_name(id,name,32)
		
	format(vaultkey, 63, "%s-/", name)

	format(vaultdata, 255, "%i#", prim[id])
	
	format(vaultdata2, 255, "%i#", sec[id])
	
	nvault_set(g_save, vaultkey, vaultdata)
	nvault_set(g_save3, vaultkey, vaultdata2)
	return PLUGIN_CONTINUE;
}

public Load_Data(id)
{
	new vaultkey[64], vaultdata[256], vaultdata2[256]
	
	new name[33];
	get_user_name(id,name,32)
			
	format(vaultkey, 63, "%s-/", name)
	
	format(vaultdata, 255, "%i#", prim[id])
	
	format(vaultdata2, 255, "%i#", sec[id])
	
	
	nvault_get(g_save, vaultkey, vaultdata, 255)
	nvault_get(g_save3, vaultkey, vaultdata2, 255)
	replace_all(vaultdata, 255, "#", " ")
	replace_all(vaultdata2, 255, "#", " ")
	
	new XP[32], Level[32]
	parse(vaultdata, XP, 31)
	parse(vaultdata2, Level, 31)
	prim[id] = str_to_num(XP)
	sec[id] = str_to_num(Level)
	
	return PLUGIN_CONTINUE;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
