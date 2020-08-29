#include < amxmodx >
#include < fakemeta >
#include < hamsandwich >
	
#pragma semicolon 1
	
#define MAX_PLAYERS 32
	
new g_iMsgIdHostageK;
new g_iMsgIdHostagePos;
	
new g_iHostageCount;
	
new Float:g_fOldPosition[ 33 ][ 3 ];
				
public plugin_init( )
{
	
	register_plugin( "CSO Radar Shit", "1.0", "Askhanar (+ DefinitelyNotJah)" );
	
	g_iMsgIdHostageK = get_user_msgid( "HostageK" );
	g_iMsgIdHostagePos = get_user_msgid( "HostagePos" );
	
	RegisterHam( Ham_Spawn, "player", "ham_SpawnPlayerPost", true );
	
	// One second task should work just fine.
	set_task( 1.0, "task_CheckPlayers", _, _, _, "b", 0 );
	
	// Count all the hostages on the map.
	new iEnt = engfunc( EngFunc_FindEntityByString, -1, "classname", "hostage_entity" );
	while( iEnt )
	{
		if( pev_valid( iEnt ) )
		{
			g_iHostageCount++;
			iEnt = engfunc( EngFunc_FindEntityByString, iEnt, "classname", "hostage_entity" );
		}
	}
}	

public ham_SpawnPlayerPost( id )
{
	if( !is_user_alive( id ) )
		return;
		
	pev( id, pev_origin, g_fOldPosition[ id ] );
}
public task_CheckPlayers( )
{
	new iAliveTerorrists[ MAX_PLAYERS ], iAliveTerorristsNum;
	new iAliveCTs[ MAX_PLAYERS ], iAliveCTsNum;
	
	get_players( iAliveTerorrists, iAliveTerorristsNum, "aceh", "TERRORIST" );
	get_players( iAliveCTs, iAliveCTsNum, "aceh", "CT" );
	
	if( !iAliveTerorristsNum || !iAliveCTsNum )
		return;
		
	UTIL_LoopPlayers( iAliveTerorrists, iAliveTerorristsNum, iAliveCTs, iAliveCTsNum );   
	UTIL_LoopPlayers( iAliveCTs, iAliveCTsNum, iAliveTerorrists, iAliveTerorristsNum );
}

UTIL_LoopPlayers( const iTeam[ ], const iTeamCount, const iEnemies[ ], const iEnemiesCount )
{
	new iFakeIndex = g_iHostageCount;
	new i, j, id;
	for( i = 0; i < iTeamCount; i++ )
	{
		id = iTeam[ i ];
		for(j = 0; j < iEnemiesCount; j++)
		{
		    UTIL_ShowOnRadar(id, iEnemies[j], ++iFakeIndex);
		}
	}
}

UTIL_ShowOnRadar( id, iTarget, Index )
{
	new Float:fOrigin[ 3 ];
	pev( iTarget, pev_origin, fOrigin );
	
	if( get_distance_f( fOrigin, g_fOldPosition[ iTarget ] ) > 72.0 )
	{
		//Make a dot on players radar.
		message_begin( MSG_ONE_UNRELIABLE, g_iMsgIdHostagePos, .player = id );
		write_byte( 1 );
		write_byte( Index  );
		engfunc( EngFunc_WriteCoord, fOrigin[ 0 ] );
		engfunc( EngFunc_WriteCoord, fOrigin[ 1 ] );
		engfunc( EngFunc_WriteCoord, fOrigin[ 2 ] );
		message_end( );
		
		for( new i = 0; i <= 2; i++ )
			g_fOldPosition[ iTarget ][ i ] = fOrigin[ i ];
	}
	
	//Make the dot red.
	message_begin( MSG_ONE_UNRELIABLE, g_iMsgIdHostageK, .player = id );
	write_byte( Index  );
	message_end( );
	
}