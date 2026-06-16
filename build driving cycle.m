function drivingCycle = build_driving_cycle(routeData, varargin)
% build_driving_cycle  Construct a time-speed driving cycle from route data
%
% INPUTS:
%   routeData   - struct from fetch_route_data
%   varargin    - optional Name-Value: 'mode' ['Eco'|'Normal'|'Performance']
%
% OUTPUT:
%   drivingCycle - struct:
%                   .time         Tx1 time vector (s)
%                   .speed        Tx1 vehicle speed (m/s)
%                   .elevation    Tx1 elevation profile (m)
%                   .grade        Tx1 road grade (%)
%                   .totalTimeS   total trip time (s)

config;

p = inputParser;
addParameter(p, 'mode', 'Normal');
parse(p, varargin{:});
mode = p.Results.mode;

switch lower(mode)
    case 'eco',         maxAccel = ECO_MAX_ACCEL;         maxSpeedKph = ECO_MAX_SPEED_KPH;
    case 'performance', maxAccel = PERFORMANCE_MAX_ACCEL;  maxSpeedKph = PERFORMANCE_MAX_SPEED_KPH;
    otherwise,          maxAccel = NORMAL_MAX_ACCEL;        maxSpeedKph = NORMAL_MAX_SPEED_KPH;
end
maxSpeed = maxSpeedKph / 3.6;

N = size(routeData.latLng, 1);
segDist = [0; cumsum(haversine_dist(routeData.latLng))];
totalDist = segDist(end);

%% Assign target speed per segment
targetSpeedKph = min(routeData.speedLimitKph(:), maxSpeedKph);
targetSpeed = interp1(linspace(0,1,numel(targetSpeedKph)), ...
    targetSpeedKph / 3.6, linspace(0,1,N), 'linear')';

%% Simple trapezoidal speed profile
dt = SIM_TIME_STEP;
v = 0;
time = []; speed = [];
for i = 2:N
    vt = targetSpeed(i);
    dv = vt - v;
    accel = sign(dv) * min(abs(dv), maxAccel * dt);
    v = max(0, v + accel);
    time(end+1) = (isempty(time)) * 0 + (numel(time) > 0) * (time(end) + dt); %#ok<AGROW>
    speed(end+1) = v; %#ok<AGROW>
end
if isempty(time), time = 0; speed = 0; end
time = (0:dt:(numel(speed)-1)*dt)';
speed = speed(:);

%% Interpolate elevation onto time axis
distPerStep = totalDist / numel(speed);
cumDistTime = (0:numel(speed)-1)' * distPerStep;
elevInterp = interp1(segDist, routeData.elevation, ...
    min(cumDistTime, segDist(end)), 'pchip');

grade = [0; diff(elevInterp) ./ max(distPerStep, 0.1) * 100];

drivingCycle.time       = time;
drivingCycle.speed      = speed;
drivingCycle.elevation  = elevInterp;
drivingCycle.grade      = grade;
drivingCycle.totalTimeS = time(end);

end

function d = haversine_dist(latLng)
R = 6371000;
lat = deg2rad(latLng(:,1));
lng = deg2rad(latLng(:,2));
dlat = diff(lat); dlng = diff(lng);
a = sin(dlat/2).^2 + cos(lat(1:end-1)) .* cos(lat(2:end)) .* sin(dlng/2).^2;
d = 2 * R * asin(sqrt(a));
end
