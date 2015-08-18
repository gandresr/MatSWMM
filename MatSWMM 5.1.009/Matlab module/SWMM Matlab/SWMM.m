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
            MAX_AREA = 209;
            CAPACITY = -200;
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
            is_initialized = false;
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
       %* swmm_open *
       %
       %    This SWMM function opens the files required to run a swmm
       %    simulation
       %
       %    swmm.open(p)
       %
       %    p: path to the input file .inp
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
       %* swmm_start *
       %
       %    This SWMM function starts a SWMM simulation. 
       %    Raise Exception if there is an error
       %
       %    swmm.start(w)
       %
       %    w: constant related to the write report file option
       
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
           
           obj.is_initialized = true;
       end
       %%
       function time = run_step(obj)
       %* swmm_run_step *
       %
       %    This SWMM function advances the simulation by one routing time
       %    step. Raise Exception if there is an error
       %    
       %    t = swmm.run_step
       %
       %    t: elapsed time in hours
       
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
       %* swmm_end_sim *
       %
       %    This SWMM function ends a SWMM simulation. Raise Exception if 
       %    a SWMM simulation has not been started
       %    
       %    swmm.end_sim

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
           obj.is_initialized = false;
       end
       %%
       function report(obj)
       %* swmm_report *
       %
       %    This SWMM function writes the simulation results to report file.
       %    Raise Exception if a SWMM simulation has not been completed
       %    
       %    swmm.report

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
       %* swmm_close *
       %
       %    This SWMM function closes a SWMM project. Raise Exception if 
       %    a SWMM simulation has not been completed
       %
       %    swmm.close

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
       %*swmm_get_mass_bal_error *
       %
       %    This SWMM function gets the mass balance errors of the 
       %    simulation
       %
       %    e = swmm.get_mass_bal_error
       %
       %    e: Values of the errors related to mass balance
       %    e(1) run-off error | e(2) flow error | e(3) quality error       

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
       %* swmm_is_over * 
       %
       %    This MatSWMM function determines if the simulation is over 
       %    or not
       %
       %    b = swmm.is_over
       %
       %    b: true if the simulation is over, false otherwise
       
           bool_ans = obj.timePtr.value == 0;
       end
       %%
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Getters & Setters
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%
       function values = step_get(obj, list_ids, attribute, unit_system)
       %* swmm_step_get *
       %
       %	This MatSWMM function retrieves the values of an specific
       %    property of multiple objects while running the simulation
       %   
       %	val = swmm.step_get(id, attr, un)
       %
       %	id: ID of the object, as saved in SWMM
       %	attr: constant related to the attribute of the object
       %	un: constant related to the units of the attribute that is 
       %	going to be retrieved
       %    val: requested value
        
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
        %* swmm_get_from_input *
        %
        %	This MatSWMM function returns the value of the attribute in the
        %   input file
        %
        %   val = swmm.get_from_input(p, id, attr)
        %   
        %   p: path to input file
        %   id: ID of the object, as saved in SWMM
        %   attr: constant, related to the attribute of the object
        %   val: this is the value of the attribute being sought in the
        %   input file
        
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
        %* swmm_get_all *
        %
        %   This MatSWMM function returns all the objects of a certain type
        %   (e.g., NODES, LINK, SUBCATCH, STORAGE, OUTFALL, JUNCTION)
        %   and the value of one of their properties
        %
        %   [ids, values] = swmm.get_all(p, type, attr)
        %
        %   p: path to input file
        %   type: constant related to the type of the objecs
        %   attr: constant related to the attribute of the objects
        %   ids: IDs of the group objects that was requested
        %   values: values of the property of the group of objects
            
            if (attribute == obj.NONE)
                attribute = -1;
            end
            
            if (attribute == obj.MAX_AREA)
                if object_type ~= obj.LINK
                    throw(obj.ERROR_MSG_ATR);
                end
                id_list = obj.get_all(input_file, object_type, obj.NONE);
                obj.initialize(input_file);
                for i = 1 : length(id_list)
                    value_list(i) = obj.get(id_list{i}, obj.MAX_AREA, obj.SI);
                end
                obj.finish;
                return;
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
        %* swmm_modidfy_input *
        %
        %   This MatSWMM function modifies a specific attribute from the 
        %   input file
        %
        %   swmm.modify_input(p, id, attr, val)
        %
        %   p: path to the input file
        %	id: ID of the object that is going to be changed
        %	attr: constant related to the attribute of the objects that is going to be changed
        %	val: value of the attribute that is going to be changed

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
        %* swmm_modify_settings *
        %
        %   This MatSWMM function modifies the setting of several orifices
        %   during the simulation
        %
        %   swmm.modify_settings(ids, settings)
        %
        %   ids: IDs of the orifices as saved in SWMM
        %   settings: vector with the values of the settings
            for i=1:length(orifices_ids)
                obj.modify_setting(orifices_ids{i}, new_settings(i));
            end
        end
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Compacted functionality
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [errors, duration] = run_simulation(obj, input_file)
        %* swmm_run_simulation *
        %
        %   This MatSWMM function runs a SWMM simulation
        %
        %   [e, d] = swmm.run_simulation(p)
        %
        %   p: path to the input file
        %	e: vector of errors
        %   e(1) run-off | e(2) flow rounting | e(3) water quality
        %   d: duration in seconds of the simulation
          obj.initialize(input_file);
          while ~obj.is_over
            obj.run_step;
          end
          [errors, duration] = obj.finish;
        end
        function initialize(obj, input_file)
        %* swmm_initialize *
        %
        %   This MatSWMM function simplifies the initialization process
        %   of SWMM using two functions {open, start}
        %
        %   swmm.initialize(p)
        %
        %   p: path to the input file
            obj.open(input_file);
            obj.start(obj.WRITE_REPORT);
        end
        %%
        function save_results(obj)
        %* swmm_save_results *
        %
        %   This MatSWMM function saves all the results of the simulation 
        %   in csv files, organized in 4 folders in the workspace directory.
        %   The folders are related to the type of objects (Link, Node,
        %   Subcatch). A folder called 'Time' with information of the step
        %   size is alse saved
        %
        %   swmm.save_results
           error = calllib('swmm5','swmm_save_results');           
        end
        %%
        function [errors, duration] = finish(obj)
        %* swmm_finish *
        %
        %   This MatSWMM function 
        % Outputs: errors   (double) -> double Array with the three errors
        %          related to the simulation.
        %          duration (double) -> duration in seconds of the
        %          simulation.
        %4 methods in one
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
        %* swmm_total_flooding *
        %
        %   This MatSWMM function calculates the total flooding in the
        %   Urban Drainage System
        %
        %   f = swmm.total_flooding
        %   
        %   f: total flooding [m^3/s]
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
        %* swmm_read_results *
        %
        %   This MatSWMM function retrieves the results of an specific type
        %   of object after the simulation
        %
        %   Compatible attributes with Subcatchments
        %       PRECIPITATION | RUNOFF
        %   Compatible attributes with Nodes
        %       INFLOW | FLOODING | DEPTH | VOLUME
        %   Compatible attributes with Links
        %       FLOW | DEPTH | VOLUME | CAPACITY
        %
        %   [t, val] = swmm.read_results(id, type, attr)
        %
        %   id: IDs of the objects
        %   attr: constant related to the attribute of the requested object
        %	t: vector with time in hours
        %	val: vector with the requested data
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
        %* swmm_modify_setting *
        %
        %   This MatSWMM function modifies the setting of an orifice during
        %   the simulation
        %
        %   swmm.modify_setting(id, p)
        %
        %   id: ID of the orifice, as saved in SWMM
        %   p: new setting of the orifice
        
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
        %* swmm_get_time *
        %
        %   This MatSWMM function returns the current hour of the
        %   simulation
        %
        %   t: current time of the simulation in hours
            current_time = obj.timePtr.value*24;
        end
        %%
       function value = get(obj, object_id, attribute, unit_system)
       %* swmm_get *
       %
       %    This MatSWMM function returns the value of an attribute 
       %    of an object, during the simulation
       %
       %    val = swmm.get(id, attr, un)
       %
       %    id: ID of the object, as saved in SWMM
       %    attr: constant related to the attribute of the object
       %    un: constant related to the units of the attribute that is going
       %    to be retrieved
       %	val: value of the attribute being sought
       
       
           if ~ismember(attribute, [obj.DEPTH, obj.VOLUME, obj.FLOW, obj.SETTING, obj.FROUDE, obj.INFLOW, obj.FLOODING, ...
                        obj.PRECIPITATION, obj.RUNOFF, obj.MAX_AREA])
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
        function [I, nodes, links] = get_incidence_matrix(obj, input_file)
        %* swmm_get_incidence_matrix *
        %
        %   This MatSWMM function returns the graph representation of the
        %   network
        %   p: path to the swmm input file
        %   I: Incidence matrix
        %   nodes: ordered IDs of the nodes
        %   links: ordered IDs of the links
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
       function lineArray = read_mixed_csv(~, fileName, delimiter)
       % Auxiliar function
       % Retrieved from 
       % http://stackoverflow.com/questions/4747834/import-csv-file-with-mixed-data-types
       
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
       function fileList = getAllFiles(~, dirName)
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