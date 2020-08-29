#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Zombie Awaken : Ranks"
#define VERSION "1.0"
#define AUTHOR "DefinitelyNotJah"

new message[192]
new sayText
new teamInfo
new maxPlayers

new strName[191]
new strText[191]
new alive[11]

native cso_get_user_levels(id)

new const g_szFeatures[][]=
{
	"",
	"[VIP]",
	"[HELPER]",
	"[HELPER+VIP]",
	"[ADMIN]",
	"[ADMIN+VIP]",
	"[DEVELOPER]",
	"[OWNER]"
}

new const g_szTag[][] =
{
	"1st Level Expert",
	"2nd Level Expert",
	"3rd Level Expert",
	"4rd Level Expert",
	"5th Level Expert",
	"6th Level Expert",
	"7th Level Expert",
	"8th Level Expert",
	"9th Level Expert",
	"Silver I Xuan Expert",
	"Silver II Xuan Expert",
	"Silver III Xuan Expert",
	"Silver IIII Xuan Expert",
	"Gold I Xuan Expert",
	"Gold II Xuan Expert",
	"Gold III Xuan Expert",
	"Gold IIII Xuan Expert",
	"Jade I Xuan Expert",
	"Jade II Xuan Expert",
	"Jade III Xuan Expert",
	"Jade IIII Xuan Expert",
	"Earth I Xuan Expert",
	"Earth II Xuan Expert",
	"Earth III Xuan Expert",
	"Earth IIII Xuan Expert",
	"Sky I Xuan Expert",
	"Sky II Xuan Expert",
	"Sky III Xuan Expert",
	"Sky IIII Xuan Expert",
	"Spirit I Xuan Expert",
	"Spirit II Xuan Expert",
	"Spirit III Xuan Expert",
	"Spirit IIII Xuan Expert",
	"Supreme I Xuan Expert",
	"Supreme II Xuan Expert",
	"Supreme III Xuan Expert",
	"Supreme IIII Xuan Expert",
	"Supreme+ I Xuan Expert",
	"Supreme+ II Xuan Expert",
	"Supreme+ III Xuan Expert",
	"Supreme+ IIII Xuan Expert",
	"First Venerable I",
	"First Venerable II",
	"First Venerable III",
	"First Venerable IIII",
	"Second Venerable I",
	"Second Venerable II",
	"Second Venerable III",
	"Second Venerable IIII",
	"Third Venerable I",
	"Third Venerable II",
	"Third Venerable III",
	"Third Venerable IIII",
	"Fourth Venerable I",
	"Fourth Venerable II",
	"Fourth Venerable III",
	"Fourth Venerable IIII",
	"First Saint I",
	"First Saint II",
	"First Saint III",
	"First Saint IIII",
	"Second Saint I",
	"Second Saint II",
	"Second Saint III",
	"Second Saint IIII",
	"Third Saint I",
	"Third Saint II",
	"Third Saint III",
	"Third Saint IIII",
	"Fourth Saint I",
	"Fourth Saint II",
	"Fourth Saint III",
	"Fourth Saint IIII",
	"Saint King I",
	"Saint King II",
	"Saint King III",
	"Saint King IIII",
	"Saint Emperor I",
	"Saint Emperor II",
	"Saint Emperor III",
	"Saint Emperor IIII",
	"Saint Venerable I",
	"Saint Venerable II",
	"Saint Venerable III",
	"Saint Venerable IIII",
	"Saint Monarch I",
	"Saint Monarch II",
	"Saint Monarch III",
	"Saint Monarch IIII",
	"Half-Sage",
	"Half-Sage",
	"Half-Sage",
	"Half-Sage",
	"Half-Sage",
	"Half-Sage",
	"Half-Sage",
	"Half-Sage",
	"Half-Sage",
	"Half-Sage",
	"Half-Sage",
	"Sage",
	"Sage"
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	sayText = get_user_msgid("SayText")
	teamInfo = get_user_msgid("TeamInfo")
	maxPlayers = get_maxplayers()


	register_message(sayText, "avoid_duplicated")

	register_clcmd("say", "hook_say")
	register_clcmd("say_team", "hook_teamsay")
}
public avoid_duplicated(msgId, msgDest, receiver)
{
	return PLUGIN_HANDLED
}
public hook_say(id)
{
	read_args(message, 191)
	remove_quotes(message)

	// Gungame commands and empty messages
	if(message[0] == '@' || message[0] == '/' || message[0] == '!' || equal(message, "")) // Ignores Admin Hud Messages, Admin Slash commands,
		return PLUGIN_CONTINUE

	new name[32]
	get_user_name(id, name, 31)
	new isAlive, admin
	
	if(get_user_flags(id) & ADMIN_LEVEL_B)
	{
		admin = 7
	}
	else if(get_user_flags(id) & ADMIN_IMMUNITY)
	{
		admin = 6
	}
	else if(get_user_flags(id) & ADMIN_LEVEL_H || get_user_flags(id) & ADMIN_BAN)
	{
		admin = 5
	}
	else if(get_user_flags(id) & ADMIN_BAN)
	{
		admin = 4
	}
	else if(get_user_flags(id) & ADMIN_LEVEL_H || get_user_flags(id) & ADMIN_RESERVATION)
	{
		admin = 3
	}
	else if(get_user_flags(id) & ADMIN_RESERVATION)
	{
		admin = 2
	}
	else if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		admin = 1
	}
	else
	{
		admin = 0
	}
	
	static color[10]

	if(is_user_alive(id))
	{
		isAlive = 1
		alive = "^x01"
	}
	else
	{
		isAlive = 0
		alive = "^x01*DEAD* "
	}

	format(strName, 191, "^x04%s[%s] %s^x03%s", g_szFeatures[admin], g_szTag[cso_get_user_levels(id)], alive, name)
	
	format(strText, 191, "%s", message)
	
	if(get_user_flags(id) & ADMIN_LEVEL_H)
		format(message, 191, "^x03%s^x01 :  ^x04%s", strName, strText)
	else
		format(message, 191, "^x03%s^x01 :  %s", strName, strText)

	sendMessage(color, isAlive)    // Sends the colored message

	return PLUGIN_CONTINUE
}


public hook_teamsay(id)
{
	new playerTeam = get_user_team(id)
	new playerTeamName[19]

	switch(playerTeam) // Team names which appear on team-only messages
	{
		case 1:
			copy(playerTeamName, 11, "ZOMBIE")

		case 2:
			copy(playerTeamName, 18, "HUMAN")

		default:
			copy(playerTeamName, 9, "SPECTATOR")
	}

	read_args(message, 191)
	remove_quotes(message)

	// Gungame commands and empty messages
	if(message[0] == '@' || message[0] == '/' || message[0] == '!' || equal(message, "")) // Ignores Admin Hud Messages, Admin Slash commands,
		return PLUGIN_CONTINUE

	new isAlive
	static color[10]
	
	new name[32]
	get_user_name(id, name, 31)
	new admin
	
	if(get_user_flags(id) & ADMIN_LEVEL_B)
	{
		admin = 7
	}
	else if(get_user_flags(id) & ADMIN_IMMUNITY)
	{
		admin = 6
	}
	else if(get_user_flags(id) & ADMIN_LEVEL_H || get_user_flags(id) & ADMIN_BAN)
	{
		admin = 5
	}
	else if(get_user_flags(id) & ADMIN_BAN)
	{
		admin = 4
	}
	else if(get_user_flags(id) & ADMIN_LEVEL_H || get_user_flags(id) & ADMIN_RESERVATION)
	{
		admin = 3
	}
	else if(get_user_flags(id) & ADMIN_RESERVATION)
	{
		admin = 2
	}
	else if(get_user_flags(id) & ADMIN_LEVEL_H)
	{
		admin = 1
	}
	else
	{
		admin = 0
	}
	
	if(is_user_alive(id))
	{
		isAlive = 1
		alive = "^x01"
	}
	else
	{
		isAlive = 0
		alive = "^x01*DEAD* "
	}
	
	format(strName, 191, "%s(%s)^x04%s[%s] ^x03%s", alive, playerTeamName, g_szFeatures[admin], g_szTag[cso_get_user_levels(id)], name)

	format(strText, 191, "%s", message)
	
	if(get_user_flags(id) & ADMIN_LEVEL_H)
		format(message, 191, "^x03%s ^x01:  ^x04%s", strName, strText)
	else
		format(message, 191, "^x03%s ^x01:  %s", strName, strText)

	sendTeamMessage(color, isAlive, playerTeam)    // Sends the colored message

	return PLUGIN_CONTINUE
}

public sendMessage(color[], alive)
{
	new teamName[10]

	for(new player = 1; player < maxPlayers; player++)
	{
		if(!is_user_connected(player))
			continue

		if(alive && is_user_alive(player) || !alive && !is_user_alive(player))
		{
			get_user_team(player, teamName, 9)    // Stores user's team name to change back after sending the message
			changeTeamInfo(player, color)        // Changes user's team according to color choosen
			writeMessage(player, message)        // Writes the message on player's chat
			changeTeamInfo(player, teamName)    // Changes user's team back to original
		}
	}
}


public sendTeamMessage(color[], alive, playerTeam)
{
	new teamName[10]

	for(new player = 1; player < maxPlayers; player++)
	{
		if(!is_user_connected(player))
			continue

		if(get_user_team(player) == playerTeam)
		{
			if(alive && is_user_alive(player) || !alive && !is_user_alive(player))
			{
				get_user_team(player, teamName, 9)    // Stores user's team name to change back after sending the message
				changeTeamInfo(player, color)        // Changes user's team according to color choosen
				writeMessage(player, message)        // Writes the message on player's chat
				changeTeamInfo(player, teamName)    // Changes user's team back to original
			}
		}
	}
}


public changeTeamInfo(player, team[])
{
	message_begin(MSG_ONE, teamInfo, _, player)    // Tells to to modify teamInfo(Which is responsable for which time player is)
	write_byte(player)                // Write byte needed
	write_string(team)                // Changes player's team
	message_end()                    // Also Needed
}


public writeMessage(player, message[])
{
	message_begin(MSG_ONE, sayText, {0, 0, 0}, player)    // Tells to modify sayText(Which is responsable for writing colored messages)
	write_byte(player)                    // Write byte needed
	write_string(message)                    // Effectively write the message, finally, afterall
	message_end()                        // Needed as always
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
