/*
       This file is part of SourceIRC.

    SourceIRC is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SourceIRC is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with SourceIRC.  If not, see <http://www.gnu.org/licenses/>.
*/

#undef REQUIRE_PLUGIN
#include <sourceirc>
#include <sdktools>

#pragma semicolon 1
#pragma dynamic 65535


public Plugin:myinfo = {
	name = "SourceIRC -> Status",
	author = "Azelphur",
	description = "Adds status and gameinfo commands show server status and who's online.",
	version = IRC_VERSION,
	url = "http://Azelphur.com/project/sourceirc"
};

public OnAllPluginsLoaded() {
	if (LibraryExists("sourceirc"))
		IRC_Loaded();
}

public OnLibraryAdded(const String:name[]) {
	if (StrEqual(name, "sourceirc"))
		IRC_Loaded();
}

IRC_Loaded() {
	IRC_CleanUp(); // Call IRC_CleanUp as this function can be called more than once.
	IRC_RegCmd("gameinfo", Command_GameInfo, "gameinfo - Shows the server name, ip, map, nextmap, how many players are online and timeleft (If supported).");
	IRC_RegCmd("players", Command_Players, "players - Shows players who are online.");
	IRC_RegCmd("playerinfo", Command_Player, "playerinfo - Show info on a selected player.");
}

public Action:Command_GameInfo(const String:nick[], args) {
	decl String:hostname[256], String:serverdomain[128], String:map[64], String:nextmap[64], String:hostmask[512], String:timestring[32];

	GetClientName(0, hostname, sizeof(hostname));
	IRC_GetHostMask(hostmask, sizeof(hostmask));
	IRC_GetServerDomain(serverdomain, sizeof(serverdomain));
	GetCurrentMap(map, sizeof(map));
	GetNextMap(nextmap, sizeof(nextmap));
	new timeleft;
	
	if (GetMapTimeLeft(timeleft)) {
		if (timeleft >= 0)
			Format(timestring, sizeof(timestring), "%d:%02d", timeleft / 60, timeleft % 60);
		else
			timestring = "N/A";
	}
	IRC_ReplyToCommand(nick, "%s: IP: %s  Map: %s  Next map: %s  Players: %d/%d  Time left: %s", hostname, serverdomain, map, nextmap, GetClientCount(), GetMaxClients(), timestring );
	
	return Plugin_Handled;
}

public Action:Command_Players(const String:nick[], args) {
	IRC_ReplyToCommand(nick, "Total Players: %d", GetClientCount());

	for(new i = GetTeamCount() - 1; i >= 0; i--) {
		new color = IRC_GetTeamColor(i);
		if (!GetTeamClientCount(i))
			continue;

		decl String:sBuffer[4096] = "", String:sName[MAX_NAME_LENGTH + 1], String:sTeam[MAX_NAME_LENGTH + 1];

		GetTeamName(i, sTeam, sizeof(sTeam));
		if (color != -1) {
			Format(sTeam, sizeof(sTeam), "\x03%02d%s\x03", color, sTeam);
		}
			
		for (new j = 1; j <= GetMaxClients(); j++) {
			if(IsFakeClient(j) || !IsClientInGame(j) || GetClientTeam(j) != i)
				continue;
				
			GetClientName(j, sName, sizeof(sName));

//			if (StrEqual(sName, "replay", true))
//				continue;
			
			if (color == -1) {
				StrCat(sBuffer, sizeof(sBuffer), ", ");
				StrCat(sBuffer, sizeof(sBuffer), sName);
			}
			else {
				Format(sName, sizeof(sName), "\x03%02d%s\x03", color, sName);
				StrCat(sBuffer, sizeof(sBuffer), sName);
				StrCat(sBuffer, sizeof(sBuffer), ", ");
			}
		}	
		sBuffer[strlen(sBuffer)-2] = '\0';
		IRC_ReplyToCommand(nick, "%s (%d): %s", sTeam, GetTeamClientCount(i), sBuffer); // Skip the ', ' from the front
	}
	return Plugin_Handled;
}

public Action:Command_Player(const String:nick[], args) {
	if (args < 1)
	{
		IRC_ReplyToCommand(nick, "Usage: playerinfo <#userid|name>");
		return Plugin_Handled;
	}

	decl String:target_name[MAX_TARGET_LENGTH], String:text[IRC_MAXLEN];
	decl target_list[MAXPLAYERS], bool:tn_is_ml;
	IRC_GetCmdArgString(text, sizeof(text));
	if (ProcessTargetString(
			text,
			0, 
			target_list, 
			MAXPLAYERS, 
			COMMAND_FILTER_CONNECTED,
			target_name,
			sizeof(target_name),
			tn_is_ml) == 0)
	{
		IRC_ReplyToCommand(nick, "%s : Invalid player specified.", text);
		return Plugin_Handled;
	}
	
	decl String:sAuth[20], String:sIp[15], String:sName[MAX_NAME_LENGTH + 1];
	GetClientAuthString(target_list[0], sAuth, sizeof(sAuth));
	GetClientIP(target_list[0],         sIp,   sizeof(sIp));
	GetClientName(target_list[0],   sName, sizeof(sName));
	
	IRC_ReplyToCommand(nick, "%s (%i, %s, %s) - Score/Deaths: %i/%i - HP/AP: %i/%i - Ping: %i",
												sName, GetClientUserId(target_list[0]), sAuth, sIp, GetClientFrags(target_list[0]),
												GetClientDeaths(target_list[0]), GetClientHealth(target_list[0]), GetClientArmor(target_list[0]),
												IsFakeClient(target_list[0]) ? 0 : RoundToNearest(GetClientAvgLatency(target_list[0], NetFlow_Outgoing) * 1000.0));
	return Plugin_Handled;
}
public OnPluginEnd() {
	IRC_CleanUp();
}

// http://bit.ly/defcon
