function routeData = fetch_route_data(origin, destination, apiKey)
% fetch_route_data  Fetch route info from Google Maps Directions + Elevation APIs
%
% INPUTS:
%   origin      - string, e.g. 'Warangal, Telangana'
%   destination - string, e.g. 'Hyderabad, Telangana'
%   apiKey      - Google Maps API key string
%
% OUTPUT:
%   routeData   - struct with fields:
%                   .distanceKm       total route distance (km)
%                   .durationMin      estimated travel time (min)
%                   .latLng           Nx2 array of [lat, lng] waypoints
%                   .elevation        Nx1 elevation (m) at each waypoint
%                   .speedLimitKph    Nx1 speed limit estimates (kph)
%                   .roadType         Nx1 cell array of road classifications
%                   .bbox             [minLat maxLat minLng maxLng]

config;

origin_enc      = urlencode(origin);
destination_enc = urlencode(destination);

%% Directions API
dirURL = sprintf('%s?origin=%s&destination=%s&key=%s', ...
    MAPS_DIRECTIONS_URL, origin_enc, destination_enc, apiKey);
dirResp = webread(dirURL);

if ~strcmp(dirResp.status, 'OK')
    error('Directions API error: %s', dirResp.status);
end

leg = dirResp.routes(1).legs(1);
routeData.distanceKm  = leg.distance.value / 1000;
routeData.durationMin = leg.duration.value / 60;

% Decode polyline to lat/lng
polyline = dirResp.routes(1).overview_polyline.points;
routeData.latLng = decode_polyline(polyline);

% Road type from steps
steps = leg.steps;
roadTypes = {};
speedLimits = [];
for i = 1:length(steps)
    rt = classify_road_type(steps(i).html_instructions);
    roadTypes{end+1} = rt; %#ok<AGROW>
    speedLimits(end+1) = estimate_speed_limit(rt); %#ok<AGROW>
end
routeData.roadType    = roadTypes;
routeData.speedLimitKph = speedLimits;

%% Elevation API (batch waypoints)
N = size(routeData.latLng, 1);
sampleIdx = round(linspace(1, N, min(N, 512)));
latLngSampled = routeData.latLng(sampleIdx, :);

locStr = strjoin(arrayfun(@(r) sprintf('%.6f,%.6f', ...
    latLngSampled(r,1), latLngSampled(r,2)), ...
    (1:size(latLngSampled,1))', 'UniformOutput', false), '|');

elevURL = sprintf('%s?locations=%s&key=%s', MAPS_ELEVATION_URL, locStr, apiKey);
elevResp = webread(elevURL);

if strcmp(elevResp.status, 'OK')
    elev = arrayfun(@(r) r.elevation, elevResp.results);
    routeData.elevation = interp1(sampleIdx, elev, 1:N, 'pchip')';
else
    warning('Elevation API failed; using flat profile.');
    routeData.elevation = zeros(N, 1);
end

%% Bounding box
routeData.bbox = [min(routeData.latLng(:,1)), max(routeData.latLng(:,1)), ...
                  min(routeData.latLng(:,2)), max(routeData.latLng(:,2))];

end

function latLng = decode_polyline(encoded)
% Decode Google Maps encoded polyline to Nx2 [lat lng]
idx = 1; lat = 0; lng = 0; coords = [];
while idx <= length(encoded)
    [dlat, idx] = decode_value(encoded, idx);
    [dlng, idx] = decode_value(encoded, idx);
    lat = lat + dlat;
    lng = lng + dlng;
    coords(end+1, :) = [lat/1e5, lng/1e5]; %#ok<AGROW>
end
latLng = coords;
end

function [val, idx] = decode_value(encoded, idx)
shift = 0; result = 0;
while true
    b = double(encoded(idx)) - 63;
    idx = idx + 1;
    result = bitor(result, bitshift(bitand(b, 31), shift));
    shift = shift + 5;
    if b < 32, break; end
end
val = bitshift(result, -1);
if bitand(result, 1), val = -val; end
end

function rt = classify_road_type(instruction)
inst = lower(instruction);
if contains(inst, 'highway') || contains(inst, 'expressway')
    rt = 'highway';
elseif contains(inst, 'main') || contains(inst, 'national')
    rt = 'arterial';
else
    rt = 'urban';
end
end

function spd = estimate_speed_limit(roadType)
switch roadType
    case 'highway',  spd = 100;
    case 'arterial', spd = 60;
    otherwise,       spd = 40;
end
end
