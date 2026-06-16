function cost = estimate_trip_cost(energyKWh, varargin)
% estimate_trip_cost  Compute estimated trip electricity cost
%
% INPUTS:
%   energyKWh      energy consumed (kWh)
%   varargin       'tariff' cost per kWh (INR), default from config
%
% OUTPUT:
%   cost           trip cost in INR

config;
p = inputParser;
addParameter(p, 'tariff', ELECTRICITY_TARIFF_PER_KWH);
parse(p, varargin{:});
cost = energyKWh * p.Results.tariff;
end
