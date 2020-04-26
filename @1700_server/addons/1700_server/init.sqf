
/*
    File: init.sqf
    Author: Bryan "Tonic" Boardwine

    Edit: Nanou for HeadlessClient optimization.
    Please read support for more informations.

    Description:
    Initialize the server and required systems.
*/
_timeStamp = diag_tickTime;
diag_log "----------------------------------------------------------------------------------------------------";
diag_log "----------------------------------    Starting m700 server Init    ---------------------------------";
diag_log "----------------------------------------------------------------------------------------------------";

DB_Async_Active = false;
DB_Async_ExtraLock = false;
private _extDBNotLoaded = "";

m700_server_isReady = false;
publicVariable "m700_server_isReady";


if (isNil "life_sql_id") then {
    life_sql_id = round(random(9999));
    life_sql_id = compileFinal (if (life_sql_id isEqualType "") then {life_sql_id} else {str(life_sql_id)});
    uiNamespace setVariable ["life_sql_id",life_sql_id];

    try {
        _result = "extDB3" callExtension format ["9:ADD_DATABASE:%1",getText(missionConfigFile >> "CfgServer" >> "DatabaseName")];
        if (!(_result isEqualTo "[1]")) then {throw "extDB3: Error with Database Connection"};
        _result = "extDB3" callExtension format ["9:ADD_DATABASE_PROTOCOL:%2:SQL_CUSTOM:%1:AL.ini",(call life_sql_id),getText(missionConfigFile >> "CfgServer" >> "DatabaseName")];
        if (!(_result isEqualTo "[1]")) then {throw "extDB3: Error with Database Connection"};
    } catch {
        diag_log _exception;
        _extDBNotLoaded = [true, _exception];
    };
    if (_extDBNotLoaded isEqualType []) exitWith {};
    "extDB3" callExtension "9:LOCK";
    diag_log "extDB3: Connected to Database";
} else {
    life_sql_id = uiNamespace getVariable "life_sql_id";
    life_sql_id = compileFinal (if (life_sql_id isEqualType "") then {life_sql_id} else {str(life_sql_id)});
    diag_log "extDB3: Still Connected to Database";
};


if (_extDBNotLoaded isEqualType []) exitWith {
    m700_server_extDB_notLoaded = true;
    publicVariable "m700_server_extDB_notLoaded";
};
m700_server_extDB_notLoaded = false;
publicVariable "m700_server_extDB_notLoaded";

/* Run stored procedures for SQL side cleanup */
/*
["resetLifeVehicles", 1] call DB_fnc_asyncCall;
["deleteDeadVehicles", 1] call DB_fnc_asyncCall;
["deleteOldHouses", 1] call DB_fnc_asyncCall;
["deleteOldGangs", 1] call DB_fnc_asyncCall;
*/


/*
{
    if (!isPlayer _x) then {
        _npc = _x;
        {
            if (_x != "") then {
                _npc removeWeapon _x;
            };
        } forEach [primaryWeapon _npc,secondaryWeapon _npc,handgunWeapon _npc];
    };
} forEach allUnits;
*/
//[8,true,12] execFSM "\life_server\FSM\timeModule.fsm";

//CONST(JxMxE_PublishVehicle,"false");

/* Initialize hunting zone(s) */
//aiSpawn = ["hunting_zone",30] spawn TON_fnc_huntingZone;


m700_server_isReady = true;
publicVariable "m700_server_isReady";
diag_log "----------------------------------------------------------------------------------------------------";
diag_log format ["               End of m700 server Init :: Total Execution Time %1 seconds ",(diag_tickTime) - _timeStamp];
diag_log "----------------------------------------------------------------------------------------------------";


