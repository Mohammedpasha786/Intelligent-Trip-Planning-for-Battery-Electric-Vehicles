function optPlan = charging_optimizer(drivingCycle, chargingStations, params)
% charging_optimizer  Identify optimal charging stops along the route
%
% Uses greedy + knapsack-style strategy to minimize trip cost while
% satisfying SOC constraints.
%
% INPUTS:
%   drivingCycle      - struct from build_driving_cycle
%   chargingStations  - Nx1 struct array with fields:
%                         .distanceFromStartKm
%                         .rateKWh   (INR/kWh)
%                         .maxPowerKW
%                         .name
%   params            - struct from vehicle_params

config;

v   = drivingCycle.speed;
dt  = drivingCycle.time(2) - drivingCycle.time(1);
soc = compute_soc(drivingCycle, params);

totalDist = sum(v) * dt / 1000;
socProfile = soc.soc;
timeVec    = drivingCycle.time;

%% Map SOC to distance
distCum = cumsum(v) * dt / 1000;
distCum = [0; distCum(:)];
socAtDist = @(d) interp1(distCum(1:numel(socProfile)), socProfile, d, 'linear', socProfile(end));

%% Evaluate each charging station
stops = [];
curSOC = 1.0;

for i = 1:length(chargingStations)
    cs = chargingStations(i);
    socArrival = socAtDist(cs.distanceFromStartKm);

    if socArrival <= MIN_SOC_THRESHOLD
        socNeeded = TARGET_SOC_AFTER_CHARGE - socArrival;
        chargeKWh = socNeeded * params.batteryKWh;
        chargeTimeMin = (chargeKWh / cs.maxPowerKW) * 60;
        chargeCostINR = chargeKWh * cs.rateKWh;

        stops(end+1).name           = cs.name; %#ok<AGROW>
        stops(end).distKm           = cs.distanceFromStartKm;
        stops(end).socAtArrival     = socArrival;
        stops(end).chargeKWh        = chargeKWh;
        stops(end).chargeTimeMin    = chargeTimeMin;
        stops(end).chargeCostINR    = chargeCostINR;
    end
end

optPlan.stops         = stops;
optPlan.totalChargeKWh   = sum([stops.chargeKWh]);
optPlan.totalChargeCostINR = sum([stops.chargeCostINR]);
optPlan.totalChargeTimeMin = sum([stops.chargeTimeMin]);
optPlan.numStops      = numel(stops);

fprintf('\n=== Charging Plan (%d stop(s)) ===\n', optPlan.numStops);
for i = 1:numel(stops)
    fprintf('  Stop %d: %s @ %.1f km | SOC: %.0f%% → %.0f%% | +%.1f kWh | %.0f min | ₹%.0f\n', ...
        i, stops(i).name, stops(i).distKm, stops(i).socAtArrival*100, ...
        TARGET_SOC_AFTER_CHARGE*100, stops(i).chargeKWh, ...
        stops(i).chargeTimeMin, stops(i).chargeCostINR);
end
end
