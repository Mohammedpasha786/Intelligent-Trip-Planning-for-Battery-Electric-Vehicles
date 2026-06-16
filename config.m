% BEV Intelligent Trip Planner

%% API Configuration
GOOGLE_MAPS_API_KEY = 'YOUR_API_KEY_HERE';
MAPS_DIRECTIONS_URL = 'https://maps.googleapis.com/maps/api/directions/json';
MAPS_ELEVATION_URL  = 'https://maps.googleapis.com/maps/api/elevation/json';

%% Simulation Parameters
SIM_TIME_STEP    = 1;       % seconds
MAX_SIM_DURATION = 14400;   % 4 hours max

%% Vehicle Defaults (can be overridden in vehicle_params.m)
DEFAULT_BATTERY_CAPACITY_KWH = 60;
DEFAULT_VEHICLE_MASS_KG      = 1800;
DEFAULT_CD                   = 0.28;   % drag coefficient
DEFAULT_FRONTAL_AREA_M2      = 2.2;
DEFAULT_REGEN_EFFICIENCY     = 0.65;

%% Energy Cost
ELECTRICITY_TARIFF_PER_KWH   = 7.5;   % INR per kWh (update as needed)

%% Driving Mode Profiles
ECO_MAX_ACCEL        = 1.5;  % m/s^2
NORMAL_MAX_ACCEL     = 2.5;
PERFORMANCE_MAX_ACCEL= 4.0;

ECO_MAX_SPEED_KPH    = 90;
NORMAL_MAX_SPEED_KPH = 120;
PERFORMANCE_MAX_SPEED_KPH = 150;

%% Charging Parameters
MIN_SOC_THRESHOLD    = 0.15;  % trigger charge stop below 15%
TARGET_SOC_AFTER_CHARGE = 0.80;

%% Output Paths
OUTPUT_DIR = fullfile(pwd, 'outputs');
if ~exist(OUTPUT_DIR, 'dir'), mkdir(OUTPUT_DIR); end
