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

#include <regex>
#undef REQUIRE_PLUGIN
#include <sourceirc>

int wave_index=0;
int max_waves=0;

public Plugin:myinfo = {
	name = "SourceIRC -> MvM Support",
	author = "N3X15",
	description = "Relays MvM wave state.",
	version = IRC_VERSION,
	url = "http://nexisonline.net/"
};

public OnPluginStart() {
	/*
	mvm_begin_wave
	Name: 	mvm_begin_wave
	Structure:
	short 	wave_index
	short 	max_waves
	short 	advanced
	*/
	HookEvent("mvm_begin_wave", Event_WaveStart, EventHookMode_Post);
	/*
	mvm_wave_complete
	Name: 	mvm_wave_complete
	*/
	HookEvent("mvm_wave_complete", Event_WaveComplete, EventHookMode_Post);
	LoadTranslations("sourceirc.phrases");
}

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
	//IRC_HookEvent("PRIVMSG", Event_PRIVMSG);
}

public Action Event_WaveStart(Handle event, const char[] name, bool dontBroadcast)
{
	/*
	mvm_begin_wave
	Name: 	mvm_begin_wave
	Structure:
	short 	wave_index
	short 	max_waves
	short 	advanced
	*/
	wave_index = GetEventInt(event, "wave_index");
	max_waves = GetEventInt(event, "max_waves");

	char result[IRC_MAXLEN];
	char message[256];
	result[0] = '\0';
	Format(result, sizeof(result), "%t", "Wave Started", wave_index, max_waves);

	IRC_MsgFlaggedChannels("relay", result);
	return;
}

public Action Event_WaveComplete(Handle event, const char[] name, bool dontBroadcast)
{
	char result[IRC_MAXLEN];
	char message[256];
	result[0] = '\0';
	Format(result, sizeof(result), "%t", "Wave Complete", wave_index, max_waves);

	IRC_MsgFlaggedChannels("relay", result);
	return;
}

public OnPluginEnd() {
	IRC_CleanUp();
}

// http://bit.ly/defcon
