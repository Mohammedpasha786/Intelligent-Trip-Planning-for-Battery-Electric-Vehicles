clc; clear; close all;
config;

fprintf('=== BEV Intelligent Trip Planner ===\n\n');

%% 1. User Inputs
origin      = input('Enter origin (e.g., Warangal, Telangana): ', 's');
destination = input('Enter destination (e.g., Hyderabad, Telangana): ', 's');
mode        = input('Select driving mode [Eco / Normal / Performance]: ', 's');

%% 2. Acquire Route Data
fprintf('\n[1/4] Fetching route data from Google Maps...\n');
routeData = fetch_route_data(origin, destination, GOOGLE_MAPS_API_KEY);
fprintf('      Route distance: %.1f km | Est. time: %.0f min\n', ...
    routeData.distanceKm, routeData.durationMin);

%% 3. Build Driving Cycle
fprintf('[2/4] Constructing driving cycle...\n');
drivingCycle = build_driving_cycle(routeData);

%% 4. Run Simulink Simulation
fprintf('[3/4] Running BEV simulation in Simulink...\n');
results = run_simulation(drivingCycle, 'mode', mode);
fprintf('      Final SOC: %.1f%% | Energy used: %.2f kWh | Cost: %.2f INR\n', ...
    results.finalSOC * 100, results.energyKWh, results.tripCostINR);

%% 5. Visualize Results
fprintf('[4/4] Generating visualizations...\n');
plot_route_map(routeData);
plot_soc_trend(results);
plot_energy_summary(results);

fprintf('\n=== Simulation Complete ===\n');
fprintf('Outputs saved to: %s\n', OUTPUT_DIR);
