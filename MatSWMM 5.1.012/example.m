%% INITIALIZE SWMM
    inp = 'swmm_files/redchicosur_gates.INP';
    swmm = SWMM;
%% RETRIEVING VARIABLE IDs FROM THE .INP
    links = swmm.get_all(inp, swmm.LINK, swmm.NONE);
    nodes = swmm.get_all(inp, swmm.NODE, swmm.NONE);
%% RUNNING A SWMM SIMULATION
    [e, d] = swmm.run_simulation(inp);
%% RETRIEVING INFORMATION
    fprintf('Total flooding = %.3f m3\n', swmm.total_flooding);
    [time, fn5] = swmm.read_results(links, swmm.LINK, swmm.VOLUME);
    plot(time, fn5);
    
    disp('MatSWMM is awesome! isn´t it?');
    
