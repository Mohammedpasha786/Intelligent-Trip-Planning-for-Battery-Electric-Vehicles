function tests = test_driving_cycle
tests = functiontests(localfunctions);
end

function test_output_fields(testCase)
routeData = mock_route_data();
dc = build_driving_cycle(routeData);
verifyField(testCase, dc, 'time');
verifyField(testCase, dc, 'speed');
verifyField(testCase, dc, 'elevation');
verifyField(testCase, dc, 'grade');
end

function test_speed_non_negative(testCase)
dc = build_driving_cycle(mock_route_data());
verifyGreaterThanOrEqual(testCase, dc.speed, 0);
end

function test_eco_slower_than_performance(testCase)
rd = mock_route_data();
dcEco  = build_driving_cycle(rd, 'mode', 'Eco');
dcPerf = build_driving_cycle(rd, 'mode', 'Performance');
verifyLessThanOrEqual(testCase, max(dcEco.speed), max(dcPerf.speed) + 1e-3);
end

function test_time_monotonic(testCase)
dc = build_driving_cycle(mock_route_data());
verifyEqual(testCase, dc.time, (0:length(dc.time)-1)' * 1);
end

function rd = mock_route_data()
N = 100;
rd.latLng       = [17 + linspace(0,0.5,N)', 78 + linspace(0,0.3,N)'];
rd.elevation    = 500 + 50 * sin(linspace(0, pi, N))';
rd.speedLimitKph= repmat(60, N, 1);
rd.roadType     = repmat({'urban'}, N, 1);
rd.distanceKm   = 40;
rd.durationMin  = 60;
rd.bbox         = [17 17.5 78 78.3];
end
