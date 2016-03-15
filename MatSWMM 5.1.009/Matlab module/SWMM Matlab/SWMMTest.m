swmm = SWMM;
inp = 'swmm_files/3tanks.inp';

% Testing open, start
swmm.initialize(inp);
i = 1;

while ~swmm.is_over % Testing is_over
    % Testing run_step
    time(i) = swmm.run_step;
    i = i+1;
end
assert(swmm.is_over == 1)
assert(isequal(time, timeTest))

% Testing finish, close, end_sim, report
[e, d] = swmm.finish;
assert(length(e) == 3)
assert( isequal(e, eTest) )
assert(d > 0)
assert(exist('swmm_files/3tanks.inp','file') == 2)
assert(exist('swmm_files/3tanks.rpt','file') == 2)
assert(exist('swmm_files/3tanks.out','file') == 2)
assert(~libisloaded('swmm5'))
assert(swmm.timePtr.value == 0)

% Testing save_results
[~, precipitation] = swmm.read_results('C-4', swmm.SUBCATCH, swmm.PRECIPITATION);
[~, runoff] = swmm.read_results('C-4', swmm.SUBCATCH, swmm.RUNOFF);
[~, flow] = swmm.read_results('C-1', swmm.LINK, swmm.FLOW);
[~, depth] = swmm.read_results('C-1', swmm.LINK, swmm.DEPTH);
[~, volume] = swmm.read_results('C-1', swmm.LINK, swmm.VOLUME);
[~, capacity] = swmm.read_results('C-1', swmm.LINK, swmm.CAPACITY);
[~, inflow] = swmm.read_results('N-7', swmm.NODE, swmm.INFLOW);
[~, flooding] = swmm.read_results('N-7', swmm.NODE, swmm.FLOODING);
[~, nodeDepth] = swmm.read_results('N-7', swmm.NODE, swmm.DEPTH);
[t, nodeVolume] = swmm.read_results('N-7', swmm.NODE, swmm.VOLUME);
assert(isequal(tTest, t))
assert(isequal(precipitationTest, precipitation))
assert(isequal(runoffTest, runoff))
assert(isequal(flowTest, flow))
assert(isequal(depthTest, depth))
assert(isequal(volumeTest, volume))
assert(isequal(capacityTest, capacity))
assert(exist('Time','dir') == 7)
assert(exist('Subcatchments','dir') == 7)
assert(exist('Nodes','dir') == 7)
assert(exist('Links','dir') == 7)
