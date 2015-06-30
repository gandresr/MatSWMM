% Get the toolbox constants and variables
swmm_get_constants;

% ***********************************************************************
%  Declaration of simulation files and variables
% ***********************************************************************

inp     = 'swmm_files/3tanks.inp';  % Input files
report  = 'swmm_files/3tanks.rpt';  % Report file
out     = 'swmm_files/3tanks.out';  % Output file
i       = 1;  % Index for vectors

% ***********************************************************************
%  Initializing SWMM
% ***********************************************************************

swmm_open(inp, report, out); % Step 1
swmm_start(NO_REPORT); % Step 2

% ***********************************************************************
%  Step Running
% ***********************************************************************

% Main loop: finished when the simulation time is over.
% The simulation is over when elapsed_time == 0.
while elapsed_time ~= 0  
    
    % ----------------- Run step and retrieve simulation time -----------
    
    time(i,:) = elapsed_time;
    elapsed_time = swmm_step; % Step 3
    
    % --------- Retrieve & modify information during simulation ---------
    % Retrieve information about flow in C-5 and volume in V-1
    flow(i,:) = swmm_get(LINK, 'C-5', FLOW, SI);
    volume(i,:) = (NODE, 'V-1', VOLUME, SI);

    % --------------------------- Control Actions ------------------------
    
    % If the flow in C-5 is greater or equal than 2 m3/s the setting 
    % upstream of the link is completely closed, else it is completely 
    % opened.

    if flow(i,:) >= 2
        swmm_modify_setting('R-4', 0);
    else
        swmm_modify_setting('R-4', 1);
    end
    
    i = i+1;
    
end

% ************************************************************************
%  End of simulation
% ************************************************************************

swmm_end; % Step 4
errors = swmm_massBalErr; % Step 5
swmm_report; % Step 6
swmm_close; % Step 7

% ************************************************************************
%  Interacting with the retrieved data
% ************************************************************************

disp(sprintf('Runoff error: %.2f%%'    , errors(1)));
disp(sprintf('Hydrologic error: %.2f%%', errors(2)));
disp(sprintf('Quality error: %.2f%%\n' , errors(3)));

plot(time, flow);

