function tests = test_soc_computation
tests = functiontests(localfunctions);
end

function test_soc_decreases(testCase)
[dc, p] = mock_inputs();
r = compute_soc(dc, p);
verifyLessThanOrEqual(testCase, r.finalSOC, 1.0);
verifyGreaterThanOrEqual(testCase, r.finalSOC, 0.0);
end

function test_energy_positive(testCase)
[dc, p] = mock_inputs();
r = compute_soc(dc, p);
verifyGreaterThan(testCase, r.energyKWh, 0);
end

function test_regen_non_negative(testCase)
[dc, p] = mock_inputs();
r = compute_soc(dc, p);
verifyGreaterThanOrEqual(testCase, r.regenKWh, 0);
end

function test_soc_length(testCase)
[dc, p] = mock_inputs();
r = compute_soc(dc, p);
verifyEqual(testCase, length(r.soc), length(dc.time));
end

function test_initial_soc_respected(testCase)
[dc, p] = mock_inputs();
r = compute_soc(dc, p, 'initialSOC', 0.8);
verifyEqual(testCase, r.soc(1), 0.8, 'AbsTol', 1e-6);
end

function [dc, p] = mock_inputs()
T  = 500;
dt = 1;
dc.time      = (0:T-1)' * dt;
dc.speed     = [linspace(0,15,50)'; 15*ones(400,1); linspace(15,0,50)'];
dc.elevation = 500 + 20*sin(linspace(0,2*pi,T)');
dc.grade     = [0; diff(dc.elevation) ./ 15 * 100];
p = vehicle_params();
end
