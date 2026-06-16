function modeResults = driving_mode_selector(routeData)
% driving_mode_selector  Compare Eco / Normal / Performance modes
%
% OUTPUT:
%   modeResults  - 1x3 struct array of simulation results per mode

modes = {'Eco', 'Normal', 'Performance'};
modeResults = struct();

for i = 1:length(modes)
    dc = build_driving_cycle(routeData, 'mode', modes{i});
    r  = run_simulation(dc, 'mode', modes{i});
    modeResults(i) = r;
    modeResults(i).modeName = modes{i};
end

%% Comparison table
fprintf('\n=== Mode Comparison ===\n');
fprintf('%-15s %-12s %-12s %-12s %-12s\n', ...
    'Mode', 'Energy(kWh)', 'Cost(INR)', 'FinalSOC(%)', 'Duration(min)');
fprintf('%s\n', repmat('-', 1, 65));
for i = 1:length(modes)
    fprintf('%-15s %-12.2f %-12.2f %-12.1f %-12.1f\n', ...
        modes{i}, modeResults(i).energyKWh, modeResults(i).tripCostINR, ...
        modeResults(i).finalSOC * 100, modeResults(i).time(end) / 60);
end

%% Bar comparison chart
fig = figure('Name', 'Mode Comparison', 'Position', [100 100 900 400]);
energies = [modeResults.energyKWh];
bar(energies, 'FaceColor', 'flat', 'CData', [0.47 0.67 0.19; 0 0.45 0.74; 0.85 0.33 0.10]);
set(gca, 'XTickLabel', modes, 'FontSize', 11);
ylabel('Energy Consumed (kWh)');
title('Energy Consumption by Driving Mode');
grid on;

config;
saveas(fig, fullfile(OUTPUT_DIR, 'mode_comparison.png'));
end
