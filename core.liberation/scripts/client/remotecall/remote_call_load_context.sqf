if (isDedicated || (!hasInterface && !isServer)) exitWith {};
params ["_grp"];

{
    _x enableIRLasers true;
    _x enableGunLights "Auto";
    _x switchMove "AmovPercMwlkSrasWrflDf";
    _x playMoveNow "AmovPercMwlkSrasWrflDf";
    [_x] spawn F_fixModUnit;
    [_x] spawn PAR_fn_AI_Damage_EH;
    [_x] joinSilent (group player);
    _x setVariable ["PAR_Grp_ID", format["Bros_%1", PAR_Grp_ID], true];
    gamelogic globalChat format ["Adds %1 (%2) to your squad.", name _x, rank _x];
    PAR_AI_bros = PAR_AI_bros + [_x];
    sleep 0.5;
} foreach (units _grp);
