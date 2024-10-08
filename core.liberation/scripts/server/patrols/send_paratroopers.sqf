params ["_targetpos", ["_qrf", false], ["_unload_dist", 400]];
if (count opfor_troup_transports_heli == 0) exitWith { grpNull };

private _name = "";
private _unit_skill = 0.65;
private _para_squad = [opfor_paratrooper,opfor_paratrooper,opfor_paratrooper,opfor_paratrooper,opfor_paratrooper,opfor_paratrooper,opfor_paratrooper,opfor_rpg];
if (_qrf == true) then {
	_name = "QRF-";
	_unload_dist = 800;
	_unit_skill = 0.75;
	_para_squad = [opfor_squad_leader,opfor_sniper,opfor_marksman,opfor_marksman,opfor_machinegunner,opfor_rpg,opfor_rpg,opfor_at,opfor_grenadier];
};

private _vehicle = [_targetpos, selectRandom opfor_troup_transports_heli] call F_libSpawnVehicle;
private _pilot_group = group driver _vehicle;
_vehicle setVariable ["GRLIB_counter_TTL", round(time + 3600)];
_vehicle setVariable ["GRLIB_battlegroup", true];
{
	_x setVariable ["GRLIB_counter_TTL", round(time + 3600)];
	_x setVariable ["GRLIB_battlegroup", true];
} foreach (crew _vehicle);
sleep 1;
private _spawnpos = getPosATL _vehicle;

[_pilot_group] call F_deleteWaypoints;
private _waypoint = _pilot_group addWaypoint [_targetpos, 100];
_waypoint setWaypointType "MOVE";
_waypoint setWaypointSpeed "FULL";
_waypoint setWaypointBehaviour "SAFE";
_waypoint setWaypointCombatMode "WHITE";
_waypoint setWaypointCompletionRadius 300;
{_x doFollow (leader _pilot_group)} foreach units _pilot_group;

private _cargo_seat_free = _vehicle emptyPositions "Cargo";
if (_cargo_seat_free > 10) then { _cargo_seat_free = 10 };
if (_cargo_seat_free == 0) exitWith { _pilot_group };
diag_log format ["Spawn (%1) %2ParaTroopers objective %3 at %4", _cargo_seat_free, _name, _targetpos, time];
stats_reinforcements_called = stats_reinforcements_called + 1;

private _unitclass = [];
while { (count _unitclass) < _cargo_seat_free } do { _unitclass pushback (selectRandom _para_squad) };
private _para_group = [zeropos, _unitclass, GRLIB_side_enemy, "para"] call F_libSpawnUnits;
private _lock = locked _vehicle;
_vehicle lock 0;
{
	_x assignAsCargoIndex [_vehicle, (_forEachIndex + 1)];
	_x moveInCargo _vehicle;
	_x setSkill _unit_skill;
	_x setSkill ["courage", 1];
	_x allowFleeing 0;
	_x setVariable ["GRLIB_counter_TTL", round(time + 3600)];
	_x setVariable ["GRLIB_battlegroup", true];
} foreach (units _para_group);
(units _para_group) allowGetIn true;
(units _para_group) orderGetIn true;
sleep 1;
_vehicle lock _lock;

if (_vehicle isKindOf "Plane_Base_F") then { _unload_dist = _unload_dist * 1.5 };

[_vehicle, _spawnpos, _targetpos, _pilot_group, _para_group, _unload_dist] spawn {
	params [ "_vehicle", "_spawnpos", "_targetpos", "_pilot_group", "_para_group", "_unload_dist"];

	waitUntil { sleep 0.2;
		//if (_vehicle distance2D _targetpos <= (_unload_dist*2)) then { _vehicle flyInHeight 150 };
		!(alive _vehicle) || (damage _vehicle > 0.2 ) || (_vehicle distance2D _targetpos <= _unload_dist)
	};
	if (!alive _vehicle) exitWith {};
	if ({alive _x} count (units _para_group) > 0) then {
		[_para_group, _vehicle] call F_ejectGroup;
		[_para_group, _targetpos] spawn battlegroup_ai;
	};

	if (!alive _vehicle) exitWith {};
	[_pilot_group] call F_deleteWaypoints;
	private _waypoint = _pilot_group addWaypoint [_spawnpos, 0];
	_waypoint setWaypointType "MOVE";
	_waypoint setWaypointSpeed "FULL";
	_waypoint setWaypointBehaviour "SAFE";
	_waypoint setWaypointCombatMode "WHITE";
	_waypoint setWaypointCompletionRadius 300;
	_waypoint setWaypointStatements ["true", "[vehicle this] spawn clean_vehicle"];
	{_x doFollow (leader _pilot_group)} foreach units _pilot_group;
};

private _hc = [] call F_lessLoadedHC;
if (!isNull _hc) then {
	_para_group setGroupOwner (owner _hc);
	sleep 1;
};

_para_group;
