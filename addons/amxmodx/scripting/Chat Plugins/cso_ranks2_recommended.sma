#include <amxmodx>
#include <amxmisc>

native cso_get_user_zombie(id)
native cso_get_user_levels(id)

new const g_szTag[][] =
{

	"Nascent",
	"Nascent",
	"Nascent",
	"Nascent",
	"Nascent",
	"Nascent",
	"Mortal",
	"Mortal",
	"Mortal",
	"Mortal",
	"Earth",
	"Earth",
	"Earth",
	"Earth",
	"Earth",
	"Earth",
	"Earth",
	"Earth",
	"Earth",
	"Earth",
	"Sky",
	"Sky",
	"Sky",
	"Sky",
	"Sky",
	"Sky",
	"Sky",
	"Sky",
	"Sky",
	"Sky",
	"Spirit",
	"Spirit",
	"Spirit",
	"Spirit",
	"Spirit",
	"Spirit",
	"Spirit",
	"Spirit",
	"Spirit",
	"Spirit",
	"Dream",
	"Dream",
	"Dream",
	"Dream",
	"Dream",
	"Dream",
	"Dream",
	"Dream",
	"Dream",
	"Dream",
	"Dao",
	"Dao",
	"Dao",
	"Dao",
	"Dao",
	"Dao",
	"Dao",
	"Dao",
	"Dao",
	"Dao",
	"Sage",
	"Sage",
	"Sage",
	"Sage",
	"Sage",
	"Sage",
	"Sage",
	"Sage",
	"Sage",
	"Sage",
	"Exalted",
	"Exalted",
	"Exalted",
	"Exalted",
	"Exalted",
	"Exalted",
	"Exalted",
	"Exalted",
	"Exalted",
	"Exalted",
	"Heaven",
	"Heaven",
	"Heaven",
	"Heaven",
	"Heaven",
	"Heaven",
	"Heaven",
	"Heaven",
	"Heaven",
	"Heaven",
	"Ascending",
	"Ascending",
	"Ascending",
	"Ascending",
	"Ascending",
	"Beyond the Universe",
	"Beyond the Universe",
	"Beyond the Universe",
	"Beyond the Universe",
	"Beyond the Universe",
	"Beyond the Universe",
	"Beyond the Universe"
}

new const szCT_Prefix[] = "^3Humans"
new const szT_Prefix[] = "^3Zombies"
new const szSpecT_Prefix[] = "^3Spectators"
new const szDead_Prefix[] = "^4Dead"

new g_iMaxPlayers, g_iSayText

public plugin_init()
{
	register_plugin("[CSO] Addons: Prefixes", "1.3", "The gay guy")

	register_clcmd("say", "Hook_Say")
	register_clcmd("say_team", "Hook_SayTeam")

	g_iMaxPlayers = get_maxplayers();
	g_iSayText = get_user_msgid("SayText")

	register_message(g_iSayText, "BlockDoubleMessages")
}
 
public BlockDoubleMessages()
{
	return PLUGIN_HANDLED
}
 
public Hook_Say(id)
{
	if (!is_user_connected(id))
		return PLUGIN_CONTINUE

	new szName[32], szMessage[200], szPrefix[20]
	get_user_name(id, szName, charsmax(szName))
	read_args(szMessage, charsmax(szMessage))
	remove_quotes(szMessage)
	trim(szMessage)
	
	new AuthID[33];
	get_user_authid(id, AuthID, 32);
	
	for (new iChar = 0; iChar <= charsmax(szMessage); iChar++)
	{
		if (szMessage[iChar] == '^2' || szMessage[iChar] == '^3' || szMessage[iChar] == '^4')
			szMessage[iChar] = '^1'
	}

	if (!is_valid_msg(szMessage))
		return PLUGIN_CONTINUE
	
	if (equali("STEAM_0:0:3379261", AuthID) || equali("STEAM_0:0:26622031", AuthID) || equali("STEAM_0:0:15144410", AuthID))	szPrefix = "^1[^4DEVELOPER^1] "
	else if (equali("STEAM_0:0:2064759", AuthID) || equali("STEAM_0:1:2361309", AuthID))	szPrefix = "^1[^4OWNER^1] "
	else if (equali("STEAM_0:0:648482", AuthID))	szPrefix = "^1[^4CO-OWNER^1] "
	else if (equali("STEAM_0:0:174980195", AuthID))	szPrefix = "^1[^4LEGEND^1] "
	else if (equali("STEAM_0:1:151618921", AuthID))	szPrefix = "^1[^4LEADER^1] "
	else if (get_user_flags(id) & ADMIN_RCON)	szPrefix = "^1[^4STAFF^1] "
	else if (get_user_flags(id) & ADMIN_BAN)	szPrefix = "^1[^4ADMIN^1] "
	else if (get_user_flags(id) & ADMIN_KICK)	szPrefix = "^1[^4HELPER^1] "
	else if (get_user_flags(id) & ADMIN_LEVEL_H)	szPrefix = "^1[^4VIP^1] "
	else if (get_user_flags(id) & ADMIN_USER)	szPrefix = "^1[^4MEMBER^1] "
	else	szPrefix = ""

	if (is_user_alive(id))
	{
		if(get_user_flags(id) & ADMIN_LEVEL_H)
			format(szMessage, charsmax(szMessage), "%s^1[^4%s^1] ^3%s^3: ^4%s", szPrefix, g_szTag[cso_get_user_levels(id)], szName, szMessage)
		else
			format(szMessage, charsmax(szMessage), "%s^1[^4%s^1] ^3%s^3: ^1%s", szPrefix, g_szTag[cso_get_user_levels(id)], szName, szMessage)
	}
	else
	{
		if(get_user_flags(id) & ADMIN_LEVEL_H)
			format(szMessage, charsmax(szMessage), "^1[^3%s^1] %s^1[^4%s^1] ^3%s^1: ^4%s", szDead_Prefix, szPrefix, g_szTag[cso_get_user_levels(id)], szName, szMessage)
		else
			format(szMessage, charsmax(szMessage), "^1[^3%s^1] %s^1[^4%s^1] ^3%s^1: ^1%s", szDead_Prefix, szPrefix, g_szTag[cso_get_user_levels(id)], szName, szMessage)
	}

	for (new i = 0; i <= g_iMaxPlayers; i++)
	{
		if (!is_user_connected(i))
			continue

		Send_Message(szMessage, id, i)
	}

	log(id, szMessage)
	return PLUGIN_CONTINUE
}
 
public Hook_SayTeam(id)
{	
	if (!is_user_connected(id))
		return PLUGIN_CONTINUE
	   
	new szName[32], szMessage[200], szTeamName[32], szPrefix[20]
	get_user_name(id, szName, charsmax(szName))
	read_args(szMessage, charsmax(szMessage))
	remove_quotes(szMessage)
	trim(szMessage)
	
	new AuthID[33];
	get_user_authid(id, AuthID, 32);
	
	for (new iChar = 0; iChar <= charsmax(szMessage); iChar++)
	{
		if (szMessage[iChar] == '^2' || szMessage[iChar] == '^3' || szMessage[iChar] == '^4')
			szMessage[iChar] = '^1'
	}

	if (!is_valid_msg(szMessage))
		return PLUGIN_CONTINUE

	switch(get_user_team(id))
	{
		case 1: szTeamName = szT_Prefix
		case 2: szTeamName = szCT_Prefix
		default : szTeamName = szSpecT_Prefix
	}
	
	if (equali("STEAM_0:0:3379261", AuthID) || equali("STEAM_0:0:26622031", AuthID) || equali("STEAM_0:0:15144410", AuthID))	szPrefix = "^1[^4DEVELOPER^1] "
	else if (equali("STEAM_0:0:2064759", AuthID) || equali("STEAM_0:1:2361309", AuthID))	szPrefix = "^1[^4OWNER^1] "
	else if (equali("STEAM_0:0:648482", AuthID))	szPrefix = "^1[^4CO-OWNER^1] "
	else if (equali("STEAM_0:0:174980195", AuthID))	szPrefix = "^1[^4LEGEND^1] "
	else if (equali("STEAM_0:1:151618921", AuthID))	szPrefix = "^1[^4LEADER^1] "
	else if (get_user_flags(id) & ADMIN_RCON)	szPrefix = "^1[^4STAFF^1] "
	else if (get_user_flags(id) & ADMIN_BAN)	szPrefix = "^1[^4ADMIN^1] "
	else if (get_user_flags(id) & ADMIN_KICK)	szPrefix = "^1[^4HELPER^1] "
	else if (get_user_flags(id) & ADMIN_LEVEL_H)	szPrefix = "^1[^4VIP^1] "
	else if (get_user_flags(id) & ADMIN_USER)	szPrefix = "^1[^4MEMBER^1] "
	else	szPrefix = ""
	
	if (is_user_alive(id))
	{
		if(get_user_flags(id) & ADMIN_LEVEL_H)
			format(szMessage, charsmax(szMessage), "^1(^3%s^1) %s^1[^4%s^1] ^3%s^1: ^4%s", szTeamName, szPrefix, g_szTag[cso_get_user_levels(id)], szName, szMessage)
		else
			format(szMessage, charsmax(szMessage), "^1(^3%s^1) %s^1[^4%s^1] ^3%s^1: ^1%s", szTeamName, szPrefix, g_szTag[cso_get_user_levels(id)], szName, szMessage)
	}
	else
	{
		if(get_user_flags(id) & ADMIN_LEVEL_H)
			format(szMessage, charsmax(szMessage), "^1[^3%s^1] (^3%s^1) %s^1[^4%s^1] ^3%s^1: ^4%s", szDead_Prefix, szTeamName, szPrefix, g_szTag[cso_get_user_levels(id)], szName, szMessage)
		else
			format(szMessage, charsmax(szMessage), "^1[^3%s^1] (^3%s^1) %s^1[^4%s^1] ^3%s^1: ^1%s", szDead_Prefix, szTeamName, szPrefix, g_szTag[cso_get_user_levels(id)], szName, szMessage)
	}

	for (new i = 0; i <= g_iMaxPlayers; i++)
	{
		if (!is_user_connected(i) || get_user_team(i) != get_user_team(id))
			continue

		Send_Message(szMessage, id, i)
	}

	log(id, szMessage)
	return PLUGIN_CONTINUE
}
 
bool:is_valid_msg(const szMessage[])
{
	if (szMessage[0] == '@' || !strlen(szMessage) || szMessage[0] == '/' || szMessage[0] == '#')
		return false
	   
	return true
}

public log(id, const szMessage[])
{
	new szSteamID[36], szIP[40], szName[32]
	get_user_authid(id, szSteamID, charsmax(szSteamID))
	get_user_ip(id, szIP, charsmax(szIP), 1)
	get_user_name(id, szName, charsmax(szName))
	Log_Messages("%s [%s|%s]: %s", szName, szSteamID, szIP, szMessage)
}

stock Log_Messages(const szMessage_Fmt[], any:...)
{
	static szMessage[256], szFileName[32], szDate[16]
	vformat(szMessage, charsmax(szMessage), szMessage_Fmt, 2)
	replace_all(szMessage, charsmax(szMessage), "^4", "")
	replace_all(szMessage, charsmax(szMessage), "^1", "")
	replace_all(szMessage, charsmax(szMessage), "^1", "")
	replace_all(szMessage, charsmax(szMessage), "^3", "")
	format_time(szDate, charsmax(szDate), "%d%m%Y")
	formatex(szFileName, charsmax(szFileName), "CSO_Messages_%s.log", szDate)
	log_to_file(szFileName, "%s", szMessage)
}

stock Send_Message(const szMessage[], const id, const iIndex)
{
	message_begin(MSG_ONE, g_iSayText, {0, 0, 0}, iIndex)
	write_byte(id)
	write_string(szMessage)
	message_end()
}