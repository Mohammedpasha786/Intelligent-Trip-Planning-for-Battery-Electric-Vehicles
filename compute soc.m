function results = compute_soc(drivingCycle, params, varargin)
% compute_soc  Compute SOC trajectory and energy metrics for a BEV trip
%
% INPUTS:
%   drivingCycle  - struct from build_driving_cycle
%   params        - struct from vehicle_params
%   varargin      - 'initialSOC' [0-1], default 1.0
%
% OUTPUT:
%   results.soc           Tx1 SOC trajectory [0-1]
%   results.powerW        Tx1 instantaneous power demand (W)
%   results.energyKWh     total energy consumed (kWh)
%   results.regenKWh      energy recovered via regen braking (kWh)
%   results.finalSOC      scalar final SOC
%   results.rangeRemainingKm  estimated remaining range at destination

p = inputParser;
addParameter(p, 'initialSOC', 1.0);
parse(p, varargin{:});
soc0 = p.Results.initialSOC;

v     = drivingCycle.speed;
grade = drivingCycle.grade / 100;
dt    = drivingCycle.time(2) - drivingCycle.time(1);
T     = length(v);

soc   = zeros(T, 1);
pw    = zeros(T, 1);
soc(1) = soc0;

rho  = params.airDensity;
Cd   = params.Cd;
A    = params.frontalAreaM2;
m    = params.massKg;
g    = params.gravity;
Cr   = params.rollingRes;
eta  = params.regenEff;
Ebat = params.batteryCapacityJ;

for k = 2:T
    a = (v(k) - v(k-1)) / dt;
    theta = atan(grade(k));

    F_aero  = 0.5 * rho * Cd * A * v(k)^2;
    F_roll  = Cr * m * g * cos(theta);
    F_grade = m * g * sin(theta);
    F_inert = m * a;

    F_total = F_aero + F_roll + F_grade + F_inert;
    P       = F_total * v(k);

    if P < 0
        P_bat = P * eta;   % regen: recover fraction
    else
        P_bat = P;         % propulsion: direct draw
    end

    pw(k)   = P_bat;
    deltaE  = P_bat * dt;
    soc(k)  = max(0, soc(k-1) - deltaE / Ebat);
end

regenIdx = pw < 0;
results.soc            = soc;
results.powerW         = pw;
results.energyKWh      = sum(pw(pw > 0)) * dt / 3.6e6;
results.regenKWh       = abs(sum(pw(regenIdx))) * dt / 3.6e6;
results.finalSOC       = soc(end);

socUsed = soc0 - soc(end);
if socUsed > 1e-4
    distKm = sum(v) * dt / 1000;
    results.rangeRemainingKm = soc(end) / socUsed * distKm;
else
    results.rangeRemainingKm = Inf;
end

end
