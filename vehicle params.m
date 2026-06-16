function params = vehicle_params(varargin)
% vehicle_params  Return BEV specification struct
%
% Optional Name-Value overrides:
%   'batteryKWh'   Battery capacity (kWh)     default: 60
%   'massKg'       Vehicle mass (kg)           default: 1800
%   'Cd'           Drag coefficient            default: 0.28
%   'frontalAreaM2' Frontal area (m^2)         default: 2.2
%   'motorPeakKW'  Peak motor power (kW)       default: 150
%   'regenEff'     Regenerative brake eff.     default: 0.65
%   'wheelRadiusM' Wheel radius (m)            default: 0.33
%   'rollingRes'   Rolling resistance coeff    default: 0.012

config;

p = inputParser;
addParameter(p, 'batteryKWh',    DEFAULT_BATTERY_CAPACITY_KWH);
addParameter(p, 'massKg',        DEFAULT_VEHICLE_MASS_KG);
addParameter(p, 'Cd',            DEFAULT_CD);
addParameter(p, 'frontalAreaM2', DEFAULT_FRONTAL_AREA_M2);
addParameter(p, 'motorPeakKW',   150);
addParameter(p, 'regenEff',      DEFAULT_REGEN_EFFICIENCY);
addParameter(p, 'wheelRadiusM',  0.33);
addParameter(p, 'rollingRes',    0.012);
parse(p, varargin{:});

params = p.Results;
params.batteryCapacityJ = params.batteryKWh * 3.6e6;
params.airDensity       = 1.225;   % kg/m^3 at sea level
params.gravity          = 9.81;    % m/s^2
end
