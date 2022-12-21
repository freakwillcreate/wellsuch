#include <a_samp>
#include <mxini>
#include <dc_cmd>
#include <sscanf2>
#include <foreach>

#pragma warning disable 239
#pragma warning disable 214
#define SSCANF_NO_NICE_FEATURES
#define GivePVarInt(%0,%1,%2) \
SetPVarInt(%0,%1,(GetPVarInt(%0,%1) + %2))
#define MAXLOC 2
#define TIMERELOC 1000*10*60

#define COLOR_CHAT 0xEDDCFFFF
#define COLOR_NAME 0x9E73CCFF
#define COLOR_CMD 0x63487FFF
#define COLOR_MENU 0xC590FFFF
#define COLOR_GRAY 0x746A7FFF

main(){}

enum pInfo
{
        pPassword[34],
        pName[24],
        pSkin,
        bool:PLogged,
        bool:PAccount
}
new PlayerInfo[MAX_PLAYERS char][pInfo];

//forward HealthTimer(playerid);
//new healthtimer;
//new Float:HeathRegen[MAX_PLAYERS];

new Guns[MAX_PLAYERS];
new GunSlot1[MAX_PLAYERS];
new GunSlot2[MAX_PLAYERS];
new strslots[128];
//new strslot1;
//new strslot2;

enum
{
	PUSTO,
	DESERTEAGLE,
	SNIPERRIFLE,
	SHOTGUN,
	M4
}

enum GUNS
{
	weapid,
	weapname[16]
}

/*new SLOTS[][GUNS] = {
	{0,"Пусто"},
	{24,"Desert Eagle"},
	{34,"Sniper Rifle"},
	{25,"Shotgun"},
	{31,"M4"}
};*/

//new guns[MAX_PLAYERS][sizeof(SLOTS)];

new ReLocation;
new ReLocationTimerR;

forward ReLocationTimer(playerid);

new BlackZone[MAXLOC];
new WhiteZone[MAXLOC];

new Float:SpawnLoc0[][4] = {
	{-1987.9039,-1005.8171,32.0234,90.2129},
	{-2019.6697,-975.6061,32.0234,45.2129},
	{-2056.7390,-930.2914,32.0234,90.2129},
	{-2109.3088,-895.4070,32.0234,90.2129},
	{-2130.1155,-830.5007,32.0234,12.8189},
	{-2107.3916,-826.1068,32.3828,12.8189},
	{-2051.9346,-758.1527,32.3828,295.9888},
	{-2022.6544,-743.8790,32.3828,295.9888},
	{-1992.1450,-767.8848,32.3828,205.9888},
	{-1983.7029,-788.4698,32.3828,205.9888},
	{-1977.0774,-806.2268,32.3828,205.9888},
	{-1924.3622,-761.4653,32.3828,295.9888},
	{-1907.5601,-791.0677,32.3828,295.9888},
	{-1890.9564,-824.7641,32.6066,295.9888},
	{-1949.1556,-935.4998,36.4195,178.9891},
	{-1958.8838,-900.6160,36.4195,88.9891},
	{-1953.6010,-848.0208,36.4195,352.3893},
	{-1957.7863,-775.7134,36.4195,352.3893},
	{-1957.7781,-859.4724,32.0234,90.4404},
	{-1923.5610,-999.6172,31.9688,164.8057}
};
new Float:SpawnLoc1[][4] = {
	{-1993.9108,731.3088,45.2969,269.7713},
	{-1952.2670,735.6317,45.2969,179.3641},
	{-1912.1418,731.1675,45.2969,90.8691},
	{-1949.3718,639.9861,46.2072,8.4717},
	{-1982.6438,653.7100,46.2072,267.4341},
	{-1921.2944,643.1859,46.2072,89.0894},
	{-1921.0977,685.6107,46.2072,87.5228},
	{-1950.8990,707.2629,46.2072,178.9029},
	{-1950.1835,675.4517,46.2072,94.5528},
	{-1938.4014,725.6278,45.2992,312.6172}
};


public OnGameModeInit()
{
	SetGameModeText("WSDM v1.0.0");
	UsePlayerPedAnims();
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
 	ManualVehicleEngineAndLights();

 	/*relocationtimer = */
 	SetTimer("AFKSystem", 1000, 1);
	ReLocationTimerR = SetTimer("ReLocationTimer",TIMERELOC,true);
	
	BlackZone[0] = GangZoneCreate(-3000, -3000, 3000, 3000);
	WhiteZone[0] = GangZoneCreate(-2168.535675048828, -1017.8750762939453, -1863.5356750488281, -703.8750762939453);
	WhiteZone[1] = GangZoneCreate(-2002, 612.5, -1902, 740.5);
	
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerCameraPos(playerid, -2498.0146, 1447.5419, 126.1710);
 	SetPlayerCameraLookAt(playerid, -2498.6477, 1448.3204, 126.1411);
  	if(PlayerInfo[playerid][PAccount] == true){ShowPlayerDialog(playerid,1,DIALOG_STYLE_PASSWORD,
	  	"{EDDCFF}                                                                    Авторизация","{EDDCFF}Добро пожаловать на {9E73CC}WellSuch DeathMatch\
   		\n{EDDCFF}Ваш аккаунт зарегистрирован на проекте\
   		\nЧтобы продолжить введите пароль, указанный при регистрации аккаунта\
    	\n\
    	\nПри утрате доступа к аккаунту просьба сообщить администрации в Discord сервер\
    	\n{9E73CC}WellSuch DeathMatch - discord.gg/qt5hHNYpFa\
    	\n\
    	\n{EDDCFF}Чтобы продолжить введите пароль в поле ниже","{EDDCFF}Войти","");}
   	else{ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"{EDDCFF}                                                          Регистрация","{EDDCFF}Добро пожаловать на {9E73CC}WellSuch DeathMatch\
        \n{EDDCFF}Ваш аккаунт не зарегистрирован на проекте\
        \n\
        \nПожалуйста, создайте пароль, опираясь на установленные ограничения:\
        \n{746A7F}• Длина пароля должна составлять от {9E73CC}6 {F08080}до {9E73CC}24 {746A7F}символов\
        \n• Пароль может содержать лишь латинские буквы {9E73CC}A-Z {746A7F}и числа {9E73CC}0-9\
        \n\
        \n{EDDCFF}Чтобы продолжить введите пароль в поле ниже","{EDDCFF}Далее","");}
	return 1;
}

public OnPlayerConnect(playerid)
{
    SetPlayerColor(playerid, 0xEDDCFFFF);
    for(new pInfo:e; e < pInfo; ++e) PlayerInfo[playerid][e] = 0;
    new string[MAX_PLAYER_NAME+14];
    GetPlayerName(playerid,PlayerInfo[playerid][pName],MAX_PLAYER_NAME);
    format(string,sizeof string,"Accounts/%s.ini", PlayerInfo[playerid][pName]);
    PlayerInfo[playerid][PAccount] = (fexist(string)) ? (true) : (false);
    
    Guns[playerid] = 0;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(PlayerInfo[playerid][PLogged]){SavePlayer(playerid);}
	return 1;
}

public OnPlayerSpawn(playerid)
{
    if(PlayerInfo[playerid][PAccount] == false) PlayerInfo[playerid][pSkin] = random(310);
	else SetPlayerSkin(playerid,PlayerInfo[playerid][pSkin]);
    SetPlayerHealth(playerid,100);
	SetPlayerArmour(playerid,100);
    if(Guns[playerid] == 0)
    {
        SetPlayerVirtualWorld(playerid,11);
        format(strslots,sizeof(strslots),"{C0C0C0}Слот 1                      {F08080}[%s]\
        \n{C0C0C0}Слот 2                      {F08080}[%s]");
		ShowPlayerDialog(playerid, 5, DIALOG_STYLE_LIST, "___", strslots, "Выбрать", "");
	}
	else
	{
	    switch(GunSlot1[playerid])
	    {
	        case 0: return 1;
	        case 1: GivePlayerWeapon(playerid,24,10999);
	        case 2: GivePlayerWeapon(playerid,34,10999);
	        case 3: GivePlayerWeapon(playerid,25,10999);
	        case 4: GivePlayerWeapon(playerid,31,10999);
	    }
	    switch(GunSlot2[playerid])
	    {
	        case 0: return 1;
	        case 1: GivePlayerWeapon(playerid,24,10999);
	        case 2: GivePlayerWeapon(playerid,34,10999);
	        case 3: GivePlayerWeapon(playerid,25,10999);
	        case 4: GivePlayerWeapon(playerid,31,10999);
	    }
	}
	GangZoneHideForPlayer(playerid, BlackZone[0]);
	GangZoneHideForPlayer(playerid, WhiteZone[0]);
	GangZoneHideForPlayer(playerid, WhiteZone[1]);
	
	new rand_spawn0 = random(sizeof(SpawnLoc0));
	new rand_spawn1 = random(sizeof(SpawnLoc1));
	
	if(PlayerInfo[playerid][PLogged])
	{
	switch(ReLocation)
	{
	    case 0:
	    {
	        SetPlayerPos(playerid,SpawnLoc0[rand_spawn0][0],SpawnLoc0[rand_spawn0][1],SpawnLoc0[rand_spawn0][2]);
    		SetPlayerFacingAngle(playerid,SpawnLoc0[rand_spawn0][3]);
    		SetCameraBehindPlayer(playerid);
    		
    		SetPlayerWorldBounds(playerid, -1870.0228, -2165.5188, -712.6271, -1013.2960);
    		//GangZoneDestroy(BlackZone[1]);
    		//GangZoneDestroy(WhiteZone[1]);
			GangZoneShowForPlayer(playerid, BlackZone[0], 0x000000AA);
			GangZoneShowForPlayer(playerid, WhiteZone[0], 0xAAAAAAAA);
	    }
	    case 1:
	    {
	        SetPlayerPos(playerid,SpawnLoc1[rand_spawn1][0],SpawnLoc1[rand_spawn1][1],SpawnLoc1[rand_spawn1][2]);
    		SetPlayerFacingAngle(playerid,SpawnLoc1[rand_spawn1][3]);
    		SetCameraBehindPlayer(playerid);
    		
    		SetPlayerWorldBounds(playerid, -1911.7678, -1996.0267, 735.3514, 601.3386);
    		//GangZoneDestroy(BlackZone[0]);
    		//GangZoneDestroy(WhiteZone[0]);
			GangZoneShowForPlayer(playerid, BlackZone[0], 0x000000AA);
			GangZoneShowForPlayer(playerid, WhiteZone[1], 0xAAAAAAAA);
	    }
	}
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	SetPlayerHealth(killerid,100);
	SetPlayerArmour(killerid,100);
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
    new Float:HP;
	GetPlayerHealth(playerid, HP);
	if(issuerid == INVALID_PLAYER_ID)
	{
	    SetPlayerHealth(playerid,HP);
	}
	/*switch(weaponid)
	{
	    case 24: SetPlayerHealth(playerid,HP-30);
	    case 31: SetPlayerHealth(playerid,HP-10);
	}*/
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
    if(!(0 <= playerid < MAX_PLAYERS))
    return 0;
    if(!(0 <= damagedid < MAX_PLAYERS))
    return 0;
    if (!(weaponid >= 22 && weaponid <= 34))
    return 0;
    static Float: fHealth, Float: fArmour;
	GetPlayerArmour(damagedid, fArmour);
	GetPlayerHealth(damagedid, fHealth);
	if(floatcmp(fArmour, 0.0) == 1)
	{
 		if(floatcmp(30, fArmour) == 1)
   		{
     		SetPlayerArmour(damagedid, 0.0);
       		SetPlayerHealth(damagedid, floatsub(fHealth, floatsub(30, fArmour)));
            return 0;
        }
        fArmour = floatsub(fArmour, 30);
        SetPlayerArmour(damagedid, fArmour);
	}
    if(floatcmp(fArmour, 1.0) == -1) SetPlayerHealth(damagedid, floatsub(fHealth, 30));
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
    SetPVarInt(playerid, "AFKTime", -2);
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
    	case 1:
    	{
    		if(!response || !strlen(inputtext)) return ShowPlayerDialog(playerid,1,DIALOG_STYLE_PASSWORD,
	  		"{EDDCFF}                                                                    Авторизация","{EDDCFF}Добро пожаловать на {9E73CC}WellSuch DeathMatch\
   			\n{EDDCFF}Ваш аккаунт зарегистрирован на проекте\
   			\nЧтобы продолжить введите пароль, указанный при регистрации аккаунта\
    		\n\
    		\nПри утрате доступа к аккаунту просьба сообщить администрации в Discord сервер\
    		\n{9E73CC}WellSuch DeathMatch - discord.gg/qt5hHNYpFa\
    		\n\
    		\n{EDDCFF}Чтобы продолжить введите пароль в поле ниже","{EDDCFF}Войти","");
    		OnPlayerLogin(playerid,inputtext);
    		return 1;
    	}
    	case 2:
    	{
    		if(!response || !strlen(inputtext)) return ShowPlayerDialog(playerid,2,DIALOG_STYLE_INPUT,"{EDDCFF}                                                          Регистрация","{EDDCFF}Добро пожаловать на {9E73CC}WellSuch DeathMatch\
        	\n{EDDCFF}Ваш аккаунт не зарегистрирован на проекте\
        	\n\
        	\nПожалуйста, создайте пароль, опираясь на установленные ограничения:\
        	\n{746A7F}• Длина пароля должна составлять от {9E73CC}6 {F08080}до {9E73CC}24 {746A7F}символов\
        	\n• Пароль может содержать лишь латинские буквы {9E73CC}A-Z {746A7F}и числа {9E73CC}0-9\
        	\n\
        	\n{EDDCFF}Чтобы продолжить введите пароль в поле ниже","{EDDCFF}Далее","");
    		OnPlayerRegister(playerid,inputtext);
    		return 1;
    	}
		case 3:
		{
		    if(response)
			{
			    if(listitem == 0)
			    {
					GivePlayerWeapon(playerid,24,10999);
					ShowPlayerDialog(playerid, 4, DIALOG_STYLE_LIST, "____", "{C0C0C0}- Desert Eagle\n{C0C0C0}- Shotgun\n{C0C0C0}- Sniper Rifle\n{C0C0C0}- M4", "Выбрать", "Назад");
					GunSlot1[playerid] = 1;
			    }
			    if(listitem == 1)
			    {
                    GivePlayerWeapon(playerid,34,10999);
                    ShowPlayerDialog(playerid, 4, DIALOG_STYLE_LIST, "____", "{C0C0C0}- Desert Eagle\n{C0C0C0}- Shotgun\n{C0C0C0}- Sniper Rifle\n{C0C0C0}- M4", "Выбрать", "Назад");
                    GunSlot1[playerid] = 2;
			    }
			    if(listitem == 2)
			    {
                    GivePlayerWeapon(playerid,25,10999);
                    ShowPlayerDialog(playerid, 4, DIALOG_STYLE_LIST, "____", "{C0C0C0}- Desert Eagle\n{C0C0C0}- Shotgun\n{C0C0C0}- Sniper Rifle\n{C0C0C0}- M4", "Выбрать", "Назад");
                    GunSlot1[playerid] = 3;
			    }
   				if(listitem == 3)
			    {
                    GivePlayerWeapon(playerid,31,10999);
                    ShowPlayerDialog(playerid, 4, DIALOG_STYLE_LIST, "____", "{C0C0C0}- Desert Eagle\n{C0C0C0}- Shotgun\n{C0C0C0}- Sniper Rifle\n{C0C0C0}- M4", "Выбрать", "Назад");
                    GunSlot1[playerid] = 4;
			    }
			}
			else return ShowPlayerDialog(playerid, 5, DIALOG_STYLE_LIST, "___", strslots, "Выбрать", "");
		}
		case 4:
		{
		    if(response)
			{
			    if(listitem == 0)
			    {
					GivePlayerWeapon(playerid,24,10999);
					SetPlayerVirtualWorld(playerid,1);
					GunSlot2[playerid] = 1;
					Guns[playerid] = 1;
			    }
			    if(listitem == 1)
			    {
                    GivePlayerWeapon(playerid,34,10999);
                    SetPlayerVirtualWorld(playerid,1);
                    GunSlot2[playerid] = 2;
                    Guns[playerid] = 1;
			    }
			    if(listitem == 2)
			    {
                    GivePlayerWeapon(playerid,25,10999);
                    SetPlayerVirtualWorld(playerid,1);
                    GunSlot2[playerid] = 3;
                    Guns[playerid] = 1;
			    }
   				if(listitem == 3)
			    {
                    GivePlayerWeapon(playerid,31,10999);
                    SetPlayerVirtualWorld(playerid,1);
                    GunSlot2[playerid] = 4;
                    Guns[playerid] = 1;
			    }
			}
			else return ShowPlayerDialog(playerid, 5, DIALOG_STYLE_LIST, "___", strslots, "Выбрать", "");
		}
		case 5:
		{
		    if(response)
		    {
   				if(listitem == 0)
   				{
   				    ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "____", "{C0C0C0}- Desert Eagle\n{C0C0C0}- Shotgun\n{C0C0C0}- Sniper Rifle\n{C0C0C0}- M4", "Выбрать", "Назад");
   				}
   				if(listitem == 1)
   				{
                    ShowPlayerDialog(playerid, 4, DIALOG_STYLE_LIST, "____", "{C0C0C0}- Desert Eagle\n{C0C0C0}- Shotgun\n{C0C0C0}- Sniper Rifle\n{C0C0C0}- M4", "Выбрать", "Назад");
   				}
		    }
		    else return ShowPlayerDialog(playerid, 5, DIALOG_STYLE_LIST, "___", strslots, "Выбрать", "");
		}
    }
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

/*public HealthTimer(playerid)
{
	GetPlayerHealth(playerid,HeathRegen[playerid]);
	return 1;
}*/

public ReLocationTimer(playerid)
{
	ReLocation = random(2);
	foreach(Player, i)
	{
	    if(PlayerInfo[playerid][PLogged])
	    {
			SpawnPlayer(i);
			SendClientMessage(i,0xffffffff,"Лока нахуй сменилась");
		}
 	}
	return 1;
}

forward AFKSystem();
public AFKSystem()
{
    for(new i; i<GetMaxPlayers(); i++)
    {
    	if(IsPlayerConnected(i))
    	{
    		if(GetPVarInt(i, "AFKTime") == -1 || GetPVarInt(i, "AFKTime") == -2) GivePVarInt(i, "AFKTime", 1);
    		if(GetPVarInt(i, "AFKTime") >= 0)
    		{
    			GivePVarInt(i, "AFKTime", 1);
    			new str[32];
    			format(str,32,"[AFK]: %d сек.",GetPVarInt(i, "AFKTime"));
    			SetPlayerChatBubble(i,str,0xAAAAAAAA,10.0,3000);
    		}
    	}
    }
	return 1;
}

SavePlayer(playerid)
{
    new string[MAX_PLAYER_NAME+14];
    format(string, sizeof string, "Accounts/%s.ini", PlayerInfo[playerid][pName]);
    new iniFile = ini_openFile(string);
    ini_setString(iniFile,"Password",PlayerInfo[playerid][pPassword]);
    ini_setInteger(iniFile,"Skin",PlayerInfo[playerid][pSkin]);
    ini_closeFile(iniFile);
    return 1;
}

OnPlayerRegister(playerid, password[])
{
	if(!IsPlayerConnected(playerid)) return 1;
	new string[MAX_PLAYER_NAME+14];
	format(string,sizeof string, "Accounts/%s.ini", PlayerInfo[playerid][pName]);
	new iniFile = ini_createFile(string);
	strmid(PlayerInfo[playerid][pPassword],password,0,strlen(password),34);
	ini_setString(iniFile,"Password",PlayerInfo[playerid][pPassword]);
	ini_setInteger(iniFile,"Skin",PlayerInfo[playerid][pSkin]);
	ini_closeFile(iniFile);
	ShowPlayerDialog(playerid,1,DIALOG_STYLE_PASSWORD,
	  	"{EDDCFF}                                                                    Авторизация","{EDDCFF}Добро пожаловать на {9E73CC}WellSuch DeathMatch\
   		\n{EDDCFF}Ваш аккаунт зарегистрирован на проекте\
   		\nЧтобы продолжить введите пароль, указанный при регистрации аккаунта\
    	\n\
    	\nПри утрате доступа к аккаунту просьба сообщить администрации в Discord сервер\
    	\n{9E73CC}WellSuch DeathMatch - discord.gg/qt5hHNYpFa\
    	\n\
    	\n{EDDCFF}Чтобы продолжить введите пароль в поле ниже","{EDDCFF}Войти","");
	return 1;
}

OnPlayerLogin(playerid,password[])
{
	if(!IsPlayerConnected(playerid)) return 1;
	new string[MAX_PLAYER_NAME+14], pass[34];
	format(string,sizeof string, "Accounts/%s.ini", PlayerInfo[playerid][pName]);
	new iniFile = ini_openFile(string);
	ini_getString(iniFile,"Password",pass,34);
	ini_getInteger(iniFile,"Skin",PlayerInfo[playerid][pSkin]);
	ini_closeFile(iniFile);
	if(strcmp(pass,password,true) == 0)
	{
		strmid(PlayerInfo[playerid][pPassword],pass,0,strlen(pass),34);
		SendClientMessage(playerid,0xAAAAAAAA,"....");
		SpawnPlayer(playerid);
		PlayerInfo[playerid][PLogged] = true;
		return 1;
	}
	else return ShowPlayerDialog(playerid,1,DIALOG_STYLE_PASSWORD,
	  	"{EDDCFF}                                                                    Авторизация","{EDDCFF}Добро пожаловать на {9E73CC}WellSuch DeathMatch\
   		\n{EDDCFF}Ваш аккаунт зарегистрирован на проекте\
   		\nЧтобы продолжить введите пароль, указанный при регистрации аккаунта\
    	\n\
    	\nПри утрате доступа к аккаунту просьба сообщить администрации в Discord сервер\
    	\n{9E73CC}WellSuch DeathMatch - discord.gg/qt5hHNYpFa\
    	\n\
    	\n{EDDCFF}Чтобы продолжить введите пароль в поле ниже","{EDDCFF}Войти","");
}
CMD:setgun(playerid,params[])
{
    ResetPlayerWeapons(playerid);
    ShowPlayerDialog(playerid, 5, DIALOG_STYLE_LIST, "___", strslots, "Выбрать", "");
	return 1;
}
CMD:kill(playerid,params[])
{
    SetPlayerHealth(playerid,0);
	return 1;
}

CMD:setskin(playerid,params[])
{
	new sskin;
	if(sscanf(params, "i", sskin)) return 1;
	SetPlayerSkin(playerid,sskin);
	PlayerInfo[playerid][pSkin] = sskin;
	return 1;
}
CMD:respawn(playerid,params[])
{
	SpawnPlayer(playerid);
	return 1;
}
CMD:reloc(playerid,params[])
{
	new locnum;
    if(sscanf(params, "i", locnum)) return ReLocationTimer(playerid);
	KillTimer(ReLocationTimerR);
	ReLocationTimerR = SetTimer("ReLocationTimer",TIMERELOC,true);
	ReLocation = locnum;
	foreach(Player, i)
	{
		SpawnPlayer(i);
		SendClientMessage(i,0xffffffff,"Лока нахуй сменилась");
 	}
	return 1;
}
