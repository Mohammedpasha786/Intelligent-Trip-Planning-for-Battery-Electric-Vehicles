function plot_energy_summary(results)
% plot_energy_summary  Dashboard of key energy KPIs

fig = figure('Name', 'Energy Summary', 'NumberTitle', 'off', ...
    'Position', [100 100 900 400]);

metrics = {'Energy Used (kWh)', 'Regen (kWh)', 'Trip Cost (INR)', ...
           'Final SOC (%)', 'Range Left (km)'};
values  = [results.energyKWh, results.regenKWh, results.tripCostINR, ...
           results.finalSOC * 100, min(results.rangeRemainingKm, 999)];
colors  = [0.85 0.33 0.10;   % orange  - energy
           0.47 0.67 0.19;   % green   - regen
           0.00 0.45 0.74;   % blue    - cost
           0.93 0.69 0.13;   % yellow  - SOC
           0.49 0.18 0.56];  % purple  - range

b = bar(values, 'FaceColor', 'flat');
b.CData = colors;
set(gca, 'XTickLabel', metrics, 'XTickLabelRotation', 15, 'FontSize', 10);
ylabel('Value');
title(sprintf('Trip Energy Summary — %s Mode', results.mode), 'FontSize', 13);

for i = 1:numel(values)
    text(i, values(i) + max(values)*0.02, sprintf('%.1f', values(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
end
grid on;

config;
saveas(fig, fullfile(OUTPUT_DIR, 'energy_summary.png'));
end
