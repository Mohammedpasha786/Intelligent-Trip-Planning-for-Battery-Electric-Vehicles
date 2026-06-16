function plot_route_map(routeData)
% plot_route_map  Plot route on map with elevation color coding
%
% Requires: Mapping Toolbox

fig = figure('Name', 'BEV Route Map', 'NumberTitle', 'off', ...
    'Position', [100 100 1200 500]);

%% Subplot 1: Geographic Route
subplot(1, 2, 1);
lat = routeData.latLng(:, 1);
lng = routeData.latLng(:, 2);
elev = routeData.elevation;

scatter(lng, lat, 10, elev, 'filled');
colormap(gca, parula);
cb = colorbar;
cb.Label.String = 'Elevation (m)';
xlabel('Longitude'); ylabel('Latitude');
title('Route Map (Color = Elevation)');
axis tight; grid on;

%% Subplot 2: Elevation Profile
subplot(1, 2, 2);
distKm = linspace(0, routeData.distanceKm, numel(elev));
plot(distKm, elev, 'b-', 'LineWidth', 1.5);
fill([distKm, fliplr(distKm)], [elev(:)', min(elev)*ones(1,numel(elev))], ...
    'b', 'FaceAlpha', 0.15, 'EdgeColor', 'none');
xlabel('Distance (km)'); ylabel('Elevation (m)');
title('Elevation Profile');
grid on;

sgtitle(sprintf('Route: %.1f km | Est. %.0f min', ...
    routeData.distanceKm, routeData.durationMin), 'FontSize', 13, 'FontWeight', 'bold');

config;
saveas(fig, fullfile(OUTPUT_DIR, 'route_map.png'));
end
