# Intelligent Trip Planning for Battery Electric Vehicles
> Simulate EV trips using real-time map data to evaluate energy-efficient routes and strategies.

## Overview

This project builds a simulation-based workflow for Battery Electric Vehicles (BEVs) that:

- Fetches real-time route data via the **Google Maps API**
- Constructs a time-speed **driving cycle** from elevation, traffic, and road-type data
- Simulates the BEV model in **Simulink** using the Virtual Vehicle Composer
- Evaluates **State of Charge (SOC)**, energy consumption, and estimated trip cost
- Visualizes route, elevation profile, and performance metrics via the **Mapping Toolbox**

---

## Project Structure

```
bev-trip-planner/
├── src/
│   ├── data_acquisition/
│   │   ├── fetch_route_data.m          # Google Maps API interface
│   │   ├── parse_elevation.m           # Elevation profile extractor
│   │   └── build_driving_cycle.m       # Driving cycle constructor
│   ├── vehicle_model/
│   │   ├── bev_model.slx               # Simulink BEV model (Virtual Vehicle Composer)
│   │   ├── vehicle_params.m            # Vehicle specification parameters
│   │   └── powertrain_config.m         # Motor, battery, drag configuration
│   ├── simulation/
│   │   ├── run_simulation.m            # Main simulation runner
│   │   ├── compute_soc.m               # SOC computation module
│   │   └── estimate_trip_cost.m        # Operational cost estimator
│   ├── visualization/
│   │   ├── plot_route_map.m            # Route + elevation map plot
│   │   ├── plot_soc_trend.m            # SOC over trip timeline
│   │   └── plot_energy_summary.m       # Energy KPI dashboard
│   └── optimization/ (Advanced)
│       ├── driving_mode_selector.m     # Eco / Normal / Performance modes
│       ├── charging_optimizer.m        # Optimal charging stop planner
│       └── route_optimizer.m           # Energy-aware route comparison
├── tests/
│   ├── test_fetch_route.m
│   ├── test_driving_cycle.m
│   ├── test_soc_computation.m
│   └── test_energy_estimate.m
├── docs/
│   └── project_description.docx
├── .github/
│   └── workflows/
│       └── ci.yml
├── config.m                            # API keys and global config
├── main.m                              # Entry point
├── requirements.txt                    # MATLAB toolbox dependencies
└── README.md
```

---

## Requirements

### MATLAB Toolboxes
- MATLAB R2024a or later
- Simulink
- Powertrain Blockset
- Mapping Toolbox
- Optimization Toolbox *(optional, for Advanced Work 2)*
- Virtual Vehicle Composer App

### External APIs
- Google Maps Directions API
- Google Maps Elevation API

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/bev-trip-planner.git
   cd bev-trip-planner
   ```

2. Configure API key in `config.m`:
   ```matlab
   GOOGLE_MAPS_API_KEY = 'YOUR_API_KEY_HERE';
   ```

3. Run the main entry point:
   ```matlab
   main
   ```

---

## Usage

### Basic Trip Simulation

```matlab
% Set origin and destination
origin = 'Warangal, Telangana';
destination = 'Hyderabad, Telangana';

% Fetch route + build driving cycle
routeData = fetch_route_data(origin, destination);
drivingCycle = build_driving_cycle(routeData);

% Run simulation
results = run_simulation(drivingCycle);

% Visualize
plot_route_map(routeData);
plot_soc_trend(results);
plot_energy_summary(results);
```

### Advanced: Driving Mode Comparison

```matlab
modes = {'Eco', 'Normal', 'Performance'};
for i = 1:length(modes)
    results(i) = run_simulation(drivingCycle, 'mode', modes{i});
end
compare_modes(results, modes);
```

### Advanced: Charging Stop Optimization

```matlab
chargingStations = load_charging_stations(routeData.bbox);
optPlan = charging_optimizer(drivingCycle, chargingStations);
plot_charging_plan(optPlan);
```

---

## Key Outputs

| Metric | Description |
|---|---|
| SOC (%) | State of charge over trip timeline |
| Energy (kWh) | Total energy consumed per route |
| Trip Cost (₹/$) | Estimated cost based on electricity tariff |
| Range Remaining | Predicted remaining range at destination |
| Charging Stops | Optimal stops (Advanced mode) |

---

## Simulation Architecture

```
Google Maps API
      │
      ▼
fetch_route_data.m ──► parse_elevation.m
      │
      ▼
build_driving_cycle.m
      │
      ▼
bev_model.slx (Simulink / Virtual Vehicle Composer)
      │
      ▼
run_simulation.m ──► compute_soc.m
                 └──► estimate_trip_cost.m
                        │
                        ▼
              Visualization (Mapping Toolbox)
```

---

## References

1. Z. Wang and S. Wang, "Real-Time Dynamic Route Optimization Based on Predictive Control Principle," *IEEE Access*, vol. 10, pp. 55062–55072, 2022.
2. Y. Xiang et al., "Routing Optimization of Electric Vehicles for Charging With Event-Driven Pricing Strategy," *IEEE Trans. Autom. Sci. Eng.*, vol. 19, no. 1, pp. 7–20, 2022.
3. MathWorks, *Virtual Vehicle Composer Documentation*, R2024a.

---

## License

MIT License. See [LICENSE](LICENSE) for details.
