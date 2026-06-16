function tests = test_energy_estimate
tests = functiontests(localfunctions);
end

function test_cost_scales_with_energy(testCase)
c1 = estimate_trip_cost(10);
c2 = estimate_trip_cost(20);
verifyEqual(testCase, c2, c1 * 2, 'RelTol', 1e-6);
end

function test_zero_energy_zero_cost(testCase)
verifyEqual(testCase, estimate_trip_cost(0), 0, 'AbsTol', 1e-9);
end

function test_custom_tariff(testCase)
cost = estimate_trip_cost(10, 'tariff', 5.0);
verifyEqual(testCase, cost, 50.0, 'AbsTol', 1e-6);
end
