classdef SWMM < handle
        properties (Constant)
            % Type constants
            JUNCTION = 0;
            SUBCATCH = 1;
            NODE = 2;
            LINK = 3;
            STORAGE = 4;
            ORIFICE = 414;
            % Unit system constants
            US = 0;
            SI = 1;
            DIMENTIONLESS = 0;
            % Attribute constants
            DEPTH = 200;
            VOLUME = 201;
            FLOW = 202;
            SETTING = 203;
            FROUDE = 204;
            INFLOW = 205;
            FLOODING = 206;
            PRECIPITATION = 207;
            RUNOFF = 208;
            CAPACITY = 209;
            % Report constants
            NO_REPORT = 0;
            WRITE_REPORT = 1;
            % Input file constants
            INVERT = 400;
            DEPTH_SIZE = 401;
            STORAGE_A = 402;
            STORAGE_B = 403;
            STORAGE_C = 404;
            LENGTH = 405;
            ROUGHNESS = 406;
            IN_OFFSET = 407;
            OUT_OFFSET = 408;
            AREA = 409;
            IMPERV = 410;
            WIDTH = 411;
            SLOPE = 412;
            OUTLET = 413;
            FROM_NODE = 415;
            TO_NODE = 416;
            NONE = -400;
        end
        properties
            % Variable properties
            elapsed_time;
            timePtr;
        end
        properties (Hidden = true)
            % Error codes
            ERROR_PATH = -300;
            ERROR_ATR = -299;
            ERROR_TYPE = -298;
            ERROR_NFOUND = -297;
            ERROR_INCOHERENT = -296;
            ERROR_IS_NUMERIC = -295;
            % Error messages - Exceptions
            ERROR_MSG_NFOUND = MException('AttributeError:Check_ID', ...
                            'Error: Object not found');
            ERROR_MSG_TYPE = MException('AttributeError:Check_TYPE', ...
                            'Error: Type of object not compatible');                    
            ERROR_MSG_ATR = MException('AttributeError:Check_ATRBT', ...
                            'Error: Attribute not compatible');
            ERROR_MSG_PATH = MException('AttributeError:Check_FILE_PATH', ...
                            'Error: Incorrect file path');
            ERROR_MSG_INCOHERENT = MException('TypeError:Check_PARAMETERS', ...
                            'Error: Incoherent parameter');
            ERROR_MSG_SYSTEM = MException('systemError:SystemFailure', ...
                            'Error: The system failed - files must be closed');    
            ERROR_MSG_IS_NUMERIC = MException('AttributeError:NotNumeric', ...
                            'Error: This function just handle numerical attributes');      
        end
   %%
   methods 
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % SWMM DLL default functionality
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%
       function open(obj, input_file)
       % SWMM_OPEN_FILE
       % Inputs: input_file (str) -> Path to the input file .inp
       % Outputs: none
       % Purpose: opens the files required to run a swmm simulation
           if ~(libisloaded('swmm5'))
               loadlibrary('swmm5');
           end
           
           rpt_file = strrep(lower(input_file), '.inp', '.rpt');
           out_file = strrep(lower(input_file), '.inp', '.out');
           error = calllib('swmm5','swmm_open',input_file, rpt_file, out_file);
           if error ~= 0
                throw(obj.ERROR_MSG_PATH);
           end
       end
       %%
       function start(obj, write_report)
       % SWMM_START
       % Inputs:  write_report (int) -> constant related to the write report 
       %		  file option.
       % Outputs: None
       % Purpose: starts a SWMM simulation. Raise Exception if there is an error.
       
           if ~ismember(write_report, [obj.NO_REPORT, obj.WRITE_REPORT])
                throw(obj.ERROR_MSG_INCOHERENT);
           end       
           if ~(libisloaded('swmm5'))
               loadlibrary('swmm5');
           end
           tic;
           error = calllib('swmm5','swmm_start', write_report);
           obj.elapsed_time = 1e-6;
           obj.timePtr = libpointer('doublePtr', obj.elapsed_time);
           
           if error ~= 0
               throw(obj.ERROR_MSG_SYSTEM);
           end
       end
       %%
       function time = run_step(obj)
       % SWMM_RUN_STEP
       % Inputs:  None
       % Outputs: time (double) - Elapsed time in hours
       % Purpose: advances the simulation by one routing time step. Raise Exception 
       %   	   if there is an error.
       
            if ~(libisloaded('swmm5'))
                loadlibrary('swmm5');
            end
            
            

            error = calllib('swmm5','swmm_step', obj.timePtr);
            time  = obj.timePtr.value*24;

            if error ~= 0
                exception = MException('SystemFailure:CheckErrorCode',...
                    sprintf('Error %d ocurred at time %.2f hours', error, time));
                throw(exception);
            end
       end
       %%
       function duration = end_sim(obj)
       % SWMM_END
       % Inputs:  None
       % Outputs: None
       % Purpose: ends a SWMM simulation. Raise Exception if there is an error.

           if ~(libisloaded('swmm5'))
               loadlibrary('swmm5');
           end

           error = calllib('swmm5','swmm_end');

           if error ~= 0
               exception = MException('SystemFailure:CheckErrorCode',...
                   sprintf('Error %d: The simulation can not be ended', error));
               throw(exception);
           end
           duration = toc;       
       end
       %%
       function report(obj)
       % SWMM_SAVE_REPORT
       % Inputs:  None
       % Outputs: None
       % Purpose: writes simulation results to report file. Raise Exception if there is an error.

           if ~(libisloaded('swmm5'))
               loadlibrary('swmm5');
           end

           error = calllib('swmm5','swmm_report');

           if error ~= 0
               exception = MException('SystemFailure:CheckErrorCode',...
                   sprintf('Error %d: The report file could not be written correctly', error));
               throw(exception);
           end          
       end
       %%
       function close(obj)
       % SWMM_CLOSE 
       % Inputs:  None
       % Outputs: None
       % Purpose: closes a SWMM project. Raise Exception if there is an error.

           if ~(libisloaded('swmm5'))
               loadlibrary('swmm5');
           end

           error = calllib('swmm5','swmm_close');

           if error ~= 0
               exception = MException('SystemFailure:CheckErrorCode',...
                   sprintf('Error %d: The file can not be closed correctly', error));
               throw(exception);
           end
           unloadlibrary swmm5;
       end
       %%
       function errors = get_mass_bal_error(obj)
        % SWMM_MASS_BAL_ERR 
        % Inputs: None.
        % Outputs: errors (vector) -> Values of the errors related to mass balance.
        %		 			   [0] <- Runoff error
        %		 			   [1] <- Flow error
        %		 			   [2] <- Quality error
        % Purpose: gets the mass balance errors of the simulation.

            runOffErr = single(0);
            flowErr = single(0);
            qualErr = single(0);
            ptrRunoff = libpointer('singlePtr', runOffErr);
            ptrFlow = libpointer('singlePtr', flowErr);
            ptrQual = libpointer('singlePtr', qualErr);

            if ~(libisloaded('swmm5'))
                loadlibrary('swmm5');
            end

            error = calllib('swmm5','swmm_getMassBalErr', ptrRunoff, ptrFlow, ptrQual);
            if error ~= 0
                exception = MException('SystemFailure:CheckErrorCode',...
                    sprintf('Error %d: The errors can not be retrieved', error));
                throw(exception);
            end

            runoff = ptrRunoff.value;
            flow = ptrFlow.value;
            qual = ptrQual.value;
            errors = [runoff, flow, qual];
       end
       %%
       function bool_ans = is_over(obj)    
       % Inputs: None
       % Outputs: _ (Bool) -> True if the simulation is over, False otherwise
       % Purpose: determines if the simulation is over or not.
       
           bool_ans = obj.timePtr.value == 0;
       end
       %%
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Getters & Setters
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%
        function values = step_get(obj, list_ids, attribute, unit_system)
        % SWMM_STEP_GET
        % Purpose: Get values of multiple objects while running the
        % simulation
        % Input/Output: The same of swmm.get
        
            if isa(list_ids, 'char')
                values = obj.get(list_ids, attribute, unit_system);
            else
                values = zeros(1, length(list_ids));
                for i=1:length(list_ids)
                    values(i) = obj.get(char(list_ids(i)), attribute, unit_system);
                end
            end
        end
        %%
        function value = get_from_input(obj, input_file, object_id, attribute)
        % SWMM_GET_FROM_INPUT
        % Inputs:  input_file  (str) -> Path to input file.
        %          object_id   (str) -> ID of the object, as saved in SWMM.
        %          attribute   (int) -> constant, related to the attribute of the object.
        % Outputs: value (double) -> This is the value of the attribute being sought in the input file.
        % Purpose: returns the value of the attribute in the input file.
        
            if ~ismember(attribute, [obj.INVERT, obj.DEPTH_SIZE, obj.STORAGE_A, ...
                    obj.STORAGE_B, obj.STORAGE_C, obj.LENGTH, obj.ROUGHNESS, ...
                    obj.IN_OFFSET, obj.OUT_OFFSET, obj.AREA, obj.IMPERV,  obj.WIDTH, obj.SLOPE])
            throw(obj.ERROR_MSG_INCOHERENT);
            end
            
            if ~(libisloaded('swmm5'))
                loadlibrary('swmm5');
            end

            value = calllib('swmm5','swmm_get_from_input', input_file, object_id, attribute);
         
            if value == obj.ERROR_NFOUND
                throw(obj.ERROR_MSG_NFOUND);
            elseif value == obj.ERROR_TYPE
                throw(obj.ERROR_MSG_TYPE);
            elseif value == obj.ERROR_ATR
                throw(obj.ERROR_MSG_ATR);
            elseif value == obj.ERROR_PATH
                throw(obj.ERROR_MSG_PATH);
            end
        end
        %%
        function [id_list, value_list] = get_all(obj, input_file, object_type, attribute)
        % SWMM_GET_ALL
        % Inputs:  input_file  (str)    -> Path to input file.
        %          object_type (int)    -> constant, related to the type of the object.
        %          attribute   (int)    -> constant, related to the attribute of the object.
        % Outputs: id_list     (cell)   -> Cell of char with the IDs of the elements that were requested. 
        %          value_list  (double) -> Array of double with the values of the attributes that were requested.
        % Purpose: returns an iterable object (dict/list) with the information that was requested.
        %          If attribute == -1 -> Returns a list.
            
            if (attribute == obj.NONE)
                attribute = -1;
            end
            
            if attribute ~= -1
                if ~ismember(attribute, [obj.INVERT, obj.DEPTH_SIZE, obj.STORAGE_A, ...
                    obj.STORAGE_B, obj.STORAGE_C, obj.LENGTH, obj.ROUGHNESS, ...
                    obj.IN_OFFSET, obj.OUT_OFFSET, obj.AREA, obj.IMPERV,  obj.WIDTH, obj.SLOPE, obj.OUTLET, ...
                    obj.FROM_NODE, obj.TO_NODE])
                    throw(obj.ERROR_MSG_INCOHERENT);
                end
            end
            if ~ismember(object_type, [obj.JUNCTION, obj.SUBCATCH, obj.LINK, obj.STORAGE, obj.ORIFICE, obj.NODE])
                    throw(obj.ERROR_MSG_INCOHERENT);
            end
            
            if ~(libisloaded('swmm5'))
                loadlibrary('swmm5');
            end
    
            error = calllib('swmm5','swmm_save_all', input_file, object_type, attribute);
            
            if(error == obj.ERROR_PATH)
                throw(obj.ERROR_MSG_PATH);
            elseif (error == obj.ERROR_NFOUND)
                delete('info.dat');
                throw(obj.ERROR_MSG_NFOUND);
            elseif (error == obj.ERROR_ATR)
                delete('info.dat');
                throw(obj.ERROR_MSG_ATR);
            elseif (error == obj.ERROR_TYPE)
                delete('info.dat');
                throw(obj.ERROR_MSG_TYPE);
            end
        
            if(attribute == -1)
                IS_VECTOR = true;
            else
                IS_VECTOR = false;
            end
            
            file = fopen('info.dat','r');
            i = 1;
            if IS_VECTOR
                while ~feof(file)
                    id_list{i} = fgetl(file);
                    i = i+1;
                end
                if attribute ~= obj.OUTLET
                    value_list = [];
                else
                    value_list = {};
                end
            else
                while ~feof(file)
                    line = fgetl(file);
                    if line ~= -1
                        if ~ismember(attribute, [obj.OUTLET obj.FROM_NODE obj.TO_NODE])
                            key_value     = textscan(line, '%s %f');
                            id_list{i}    = char(key_value{1});
                            value_list(i,:) = key_value{2};
                        else
                            key_value     = textscan(line, '%s %s');
                            id_list{i}    = char(key_value{1});
                            value_list{i} = char(key_value{2});
                        end
                        
                        i = i+1;
                    end
                end
                
            end
            
            fclose(file);
            delete('info.dat');
        end
        %% 
        function modify_input(obj, input_file, object_id, attribute, value)
        % SWMM_MODIFY_INPUT
        % Inputs:  input_file 	 (str)    -> Path to the input file.
        %		   object_id	 (str)    -> ID of the object that is going to be changed.
        %		   attribute     (int)    -> Constant - Attribute that is going to be changed.
        %		   value         (double) -> Value of the attribute that is going to be changed.
        % Purpose: It modifies a specific attribute from the input file.

            if ~(libisloaded('swmm5'))
                loadlibrary('swmm5');
            end

            error = calllib('swmm5','swmm_modify_input', input_file, object_id, attribute, value);

            if error == obj.ERROR_NFOUND
                throw(obj.ERROR_MSG_NFOUND);
            elseif error == obj.ERROR_TYPE
                throw(obj.ERROR_MSG_TYPE);
            elseif error == obj.ERROR_ATR
                throw(obj.ERROR_MSG_ATR);
            elseif error == obj.ERROR_PATH
                throw(obj.ERROR_MSG_PATH);
            end
        end
        %%
        function modify_settings(obj, orifices_ids, new_settings)
        % SWMM_MODIFY_SETTINGS
        % Inputs:  orifices_ids	(str)    -> List of orifices IDs, as saved in SWMM.
        % new_setting 	(double) -> List of Percentage of openning of the orifices.
        % Outputs: None.
        % Purpose: modifies the setting of an orifice during the simulation.
            for i=1:length(orifices_ids)
                obj.modify_setting(orifice_ids(i), new_settings(i));
            end
        end
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Compacted functionality
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [errors, duration] = run_simulation(obj, input_file)
        % SWMM_RUN_SIMULATION
        % Inputs: input_file   (str) -> Path to the input file.
        % Outputs: errors   (double) -> double Array with the three errors
        %          related to the simulation.
        %          duration (double) -> duration in seconds of the
        %          simulation.
        % Purpose: Runs a SWMM simulation
          obj.initialize(input_file);
          while ~obj.is_over
            obj.run_step;
          end
          [errors, duration] = obj.finish;
        end
        function initialize(obj, input_file)
        % SWMM_INITIALIZE
        % Inputs: input_file   (str) -> Path to the input file.
        %         write_report (int) -> Constant that determines if SWMM
        %         wirtes a report file or not.
        % Outputs: None
        % Purpose: Compacts 2 methods in one
            obj.open(input_file);
            obj.start(obj.WRITE_REPORT);
        end
        %%
        function save_results(obj)
           error = calllib('swmm5','swmm_save_results');           
        end
        %%
        function [errors, duration] = finish(obj)
        % SWMM_FINISH
        % Inputs: None
        % Outputs: errors   (double) -> double Array with the three errors
        %          related to the simulation.
        %          duration (double) -> duration in seconds of the
        %          simulation.
        % Purpose: 4 methods in one
            duration = obj.end_sim;
            errors = obj.get_mass_bal_error;
            obj.report;
            if exist('Nodes') == 7
                rmdir('Nodes', 's');
            end
            if exist('Links') == 7
                rmdir('Links', 's');
            end
            if exist('Subcatchments') == 7
                rmdir('Subcatchments', 's');
            end
            if exist('Time') == 7
                rmdir('Time', 's');
            end
            obj.save_results;
            obj.close;
        end
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Auxiliar Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%
        function tflooding = total_flooding(obj)
            nodes = obj.getAllFiles('Nodes');
            tflooding = 0;
            for i=1 : length(nodes)
                current = strrep(nodes{i},'Nodes\','');
                current = strrep(current,'.csv','');
                [t,r] = obj.read_results(current, obj.NODE, obj.FLOODING);
                tflooding = tflooding + trapz(t*3600,r);
            end
        end
        %%
        function [time, result] = read_results(obj, object_id, object_type, attribute)
        % SWMM_READ_RESULTS
        % Inputs: object_id (string/cell) - IDs of the objects
        %         attribute (int) - constant related to the requested
        %         object
        % Outputs: time (double) - Vector with time in hours
        %          result (double) - Vector with the requested data
        % Purpose: Retrieve information after the simulation.
        %   Compatible attributes with Subcatchments:
        %       PRECIPITATION | RUNOFF
        %   Compatible attributes with Nodes:
        %       INFLOW | FLOODING | DEPTH | VOLUME
        %   Compatible attributes with Links:
        %       FLOW | DEPTH | VOLUME | CAPACITY
            if object_type == obj.LINK
                folder = 'Links/';
                compatible = [obj.FLOW, obj.DEPTH, obj.VOLUME, obj.CAPACITY];
                columns = [1, 3, 4, 5];
            elseif object_type == obj.NODE
                folder = 'Nodes/';
                compatible = [obj.INFLOW, obj.FLOODING, obj.DEPTH, obj.VOLUME];
                columns = [1, 2, 3, 5];
            elseif object_type == obj.SUBCATCH
                folder = 'Subcatchments/';
                compatible = [obj.PRECIPITATION, obj.RUNOFF];
                columns = [1, 4];
            else
                throw(obj.ERROR_MSG_TYPE);
            end
            [a, position] = ismember(attribute, compatible);
            if a ~= 1
                throw(obj.ERROR_MSG_ATR);
            end
            
            if ~iscell(object_id)
                object_id = {object_id};
            end
            result = [];
            for i=1 : length(object_id)
                path = strcat(folder, object_id{i}, '.csv');
                if exist(path) ~= 2
                    throw(obj.ERROR_MSG_NFOUND);
                end
                data = csvread(path);
                result(:,i) = [0;data(:,columns(position))];
            end
            info = csvread('Time/time.txt');
            time = zeros(info(2),1);
            for i=2 : info(2)+1
                time(i) = info(1)/3600 + time(i-1);
            end
        end
        %%
        function modify_setting(obj, orifice_id, new_setting)
        % SWMM_MODIFY_SETTING
        % Inputs:  orifice_id  (str)    -> ID of the orifice, as saved in SWMM.
        %          new_setting (double) -> Percentage of openning of the orifice.
        %          adj_time	 (double) -> Time taken for the orifice to adjust.
        % Outputs: None.
        % Purpose: modifies the setting of an orifice during the simulation.
        
            if ~(libisloaded('swmm5'))
                loadlibrary('swmm5');
            end

            error = calllib('swmm5','swmm_modify_setting', orifice_id, new_setting, 0);
            if error == obj.ERROR_INCOHERENT
                throw(obj.ERROR_MSG_INCOHERENT);
            elseif error == obj.ERROR_NFOUND
                throw(obj.ERROR_MSG_NFOUND);
            end
        end
        %%
        function current_time = get_time(obj)
        % SWMM_GET_TIME
        % Inputs: None
        % Outputs: current_time (double) -> Value of the current time of the simulation in hours.
        % Purpose: returns the current hour of the simulation.
            current_time = obj.timePtr.value*24;
        end
        %%
       function value = get(obj, object_id, attribute, unit_system)
       % SWMM_GET
       % Inputs: object_id	  (str) -> ID of the object, as saved in SWMM.
       %         attribute   (int) -> swmm.py constant, related to the attribute of the object.
       %         unit_system (int) -> swmm.py constant, related to the units of the attribute that is going
       %                              to be retrieved.
       % Outputs: _ (double) -> This is the value of the attribute being sought.
       % Purpose: returns the value of the attribute.
       
           if ~ismember(attribute, [obj.DEPTH, obj.VOLUME, obj.FLOW, obj.SETTING, obj.FROUDE, obj.INFLOW, obj.FLOODING, ...
                        obj.PRECIPITATION, obj.RUNOFF])
               throw(obj.ERROR_MSG_INCOHERENT);
           elseif ~ismember(unit_system, [obj.SI, obj.US, obj.DIMENTIONLESS])
               throw(obj.ERROR_MSG_INCOHERENT);            
           end
            if ~(libisloaded('swmm5'))
               loadlibrary('swmm5');
           end
           value = calllib('swmm5','swmm_get', object_id, attribute, unit_system);
           if (value == obj.ERROR_NFOUND)
               throw(obj.ERROR_MSG_NFOUND);
           elseif (value == obj.ERROR_TYPE)
               throw(obj.ERROR_MSG_TYPE);
           elseif (value == obj.ERROR_ATR)
               throw(obj.ERROR_MSG_ATR);
           end
       end
        %%
        % SWMM_GET_INCIDENCE_MATRIX
        % Inputs
        %   - input_file (str) -> path to the swmm input file.
        % Outputs: 
        %   - I (double) -> Incidence matrix
        %   - nodes (cell) -> list of the IDs of the nodes
        %   - links (cell) -> list of the IDs of the links
        % Purpose: 
        %   Returns the graph representation of the network.
        function [I, nodes, links] = get_incidence_matrix(obj, input_file)
            % Conduits
            [~, from] = obj.get_all(input_file, obj.LINK, obj.FROM_NODE);
            [conduits, to] = obj.get_all(input_file, obj.LINK, obj.TO_NODE);
            % Orifices
            [~, ofrom] = obj.get_all(input_file, obj.ORIFICE, obj.FROM_NODE);
            [orifices, oto] = obj.get_all(input_file, obj.ORIFICE, obj.TO_NODE);
            
            nodes = union(union(from, to), union(ofrom, oto));
            links = union(conduits, orifices);
            
            I = zeros(length(nodes), length(links));
            for i=1 : length(links)
                if ismember(links{i}, conduits)
                    ii = find(ismember(conduits, links{i}));
                    index_1 = find(ismember(nodes, from{ii}));
                    index_2 = find(ismember(nodes, to{ii}));
                else
                    ii = find(ismember(orifices, links{i}));
                    index_1 = find(ismember(nodes, ofrom{ii}));
                    index_2 = find(ismember(nodes, oto{ii}));
                end
                I(index_1, i) = 1; I(index_2, i) = -1;
            end
        end  
        %%
        function [M, links] = get_connectivity_matrix(obj, input_file)
           [I, ~, links] = obj.get_incidence_matrix(input_file);
           
           M = zeros(length(links));
           
           for i = find(sum(I,2) >= 0)'
              plinks = find(I(i,:) == -1);
              for j = plinks
                  I(:,j)
                  jj = I(:,j) == 1;
                  for k = find(I(jj,:) == -1)
                      M(j, k) = 1;
                  end
              end
           end
           
        end
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % External Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%
       function lineArray = read_mixed_csv(obj, fileName, delimiter)
       % Auxiliar function
       % Retrieved from -- http://stackoverflow.com/questions/4747834/import-csv-file-with-mixed-data-types
       
           fid = fopen(fileName,'r');   %# Open the file
           lineArray = cell(100,1);     %# Preallocate a cell array (ideally slightly
                                  %#   larger than is needed)
           lineIndex = 1;               %# Index of cell to place the next line in
           nextLine = fgetl(fid);       %# Read the first line from the file

           while ~isequal(nextLine,-1)         %# Loop while not at the end of the file
               lineArray{lineIndex} = nextLine;  %# Add the line to the cell array
               lineIndex = lineIndex+1;          %# Increment the line index
               nextLine = fgetl(fid);            %# Read the next line from the file
           end
           
           fclose(fid);                 %# Close the file
           lineArray = lineArray(1:lineIndex-1);  %# Remove empty cells, if needed
            
           for iLine = 1:lineIndex-1              %# Loop over lines
            lineData = textscan(lineArray{iLine},'%s',...  %# Read strings
                           'Delimiter',delimiter);
            lineData = lineData{1};              %# Remove cell encapsulation
            if strcmp(lineArray{iLine}(end),delimiter)  %# Account for when the line
                lineData{end+1} = '';                     %#   ends with a delimiter
            end
            lineArray(iLine,1:numel(lineData)) = lineData;  %# Overwrite line data
           end
       end
       %%
       function fileList = getAllFiles(obj, dirName)
          dirData = dir(dirName);      %# Get the data for the current directory
          dirIndex = [dirData.isdir];  %# Find the index for directories
          fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
          if ~isempty(fileList)
            fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
                               fileList,'UniformOutput',false);
          end
          subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
          validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                                       %#   that are not '.' or '..'
          for iDir = find(validIndex)                  %# Loop over valid subdirectories
            nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
            fileList = [fileList; getAllFiles(nextDir)];  %# Recursively call getAllFiles
          end

        end
   end
end