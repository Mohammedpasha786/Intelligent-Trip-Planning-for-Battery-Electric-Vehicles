function results = run_simulation(drivingCycle, varargin)
% run_simulation  Run full BEV trip simulation
%
% INPUTS:
%   drivingCycle  - struct from build_driving_cycle
%   varargin      - Name-Value pairs:
%                   'mode'       ['Eco'|'Normal'|'Performance'] default: 'Normal'
%                   'initialSOC' [0-1]  default: 1.0
%                   'openSimulink' [true|false] open Simulink model

config;

p = inputParser;
addParameter(p, 'mode',         'Normal');
addParameter(p, 'initialSOC',   1.0);
addParameter(p, 'openSimulink', false);
parse(p, varargin{:});

params = vehicle_params();

%% Optionally run Simulink model
if p.Results.openSimulink
    % Export driving cycle to base workspace for Simulink
    assignin('base', 'drivingCycleTime',  drivingCycle.time);
    assignin('base', 'drivingCycleSpeed', drivingCycle.speed);
    assignin('base', 'vehicleParams',     params);

    load_system('bev_model');
    set_param('bev_model', 'StopTime', num2str(drivingCycle.totalTimeS));
    sim('bev_model');
    simOut = evalin('base', 'simOut');

    results.soc     = simOut.get('SOC').Data;
    results.powerW  = simOut.get('MotorPower').Data;
    results.time    = drivingCycle.time;
else
    % Pure MATLAB energy model (no Simulink license required for quick eval)
    socResults = compute_soc(drivingCycle, params, 'initialSOC', p.Results.initialSOC);
    results = socResults;
    results.time = drivingCycle.time;
end

%% Post-process
results.energyKWh    = max(results.energyKWh, 0);
results.tripCostINR  = estimate_trip_cost(results.energyKWh);
results.mode         = p.Results.mode;
results.distanceKm   = sum(drivingCycle.speed) * ...
    (drivingCycle.time(2) - drivingCycle.time(1)) / 1000;

fprintf('--- Simulation Results [%s Mode] ---\n', results.mode);
fprintf('  Distance      : %.1f km\n',   results.distanceKm);
fprintf('  Energy used   : %.2f kWh\n',  results.energyKWh);
fprintf('  Regen recovered: %.2f kWh\n', results.regenKWh);
fprintf('  Final SOC     : %.1f%%\n',    results.finalSOC * 100);
fprintf('  Est. trip cost: ₹%.2f\n',     results.tripCostINR);
fprintf('  Range remaining: %.0f km\n',  results.rangeRemainingKm);
end
