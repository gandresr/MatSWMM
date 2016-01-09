classdef SWMM < handle
	properties (Constant)
		sys = struct(...
			'fileType', struct(...
				'RAINFALL_FILE', 0, 'RUNOFF_FILE', 1, 'HOTSTART_FILE', 2, ...
				'RDII_FILE', 3, 'INFLOWS_FILE', 4, 'OUTFLOWS_FILE', 5),...
			'fileUsageType', struct(...
				'NO_FILE', 0, 'SCRATCH_FILE', 1, 'USE_FILE', 2, 'SAVE_FILE', 3),...
			'gageDataType', struct('RAIN_TSERIES', 0, 'RAIN_FILE', 1),...
			'unitType', struct('US', 0, 'SI', 1),...
			'flowUnitsType', struct(...
				'CFS', 0, 'GPM', 1, 'MGD', 2, 'CMS', 3, 'LPS', 4, 'MLD', 5),...
			'concUnitsType', struct('MG', 0, 'UG', 1, 'COUNT', 2),...
			'conversionType', struct(...
				'RAINFALL', 0, 'RAINDEPTH', 1, 'EVAPRATE', 2, 'LENGTH', 3, ...
				'LANDAREA', 4, 'VOLUME', 5, 'WINDSPEED', 6, 'TEMPERATURE', 7, ...
				'MASS', 8, 'GWFLOW', 9, 'FLOW', 10),...
			'sysFlowType', struct(...
				'SYS_TEMPERATURE', 0, 'SYS_RAINFALL', 1, 'SYS_SNOWDEPTH', 2, ...
				'SYS_INFIL', 3, 'SYS_RUNOFF', 4, 'SYS_DWFLOW', 5, 'SYS_GWFLOW', 6, ...
				'SYS_IIFLOW', 7, 'SYS_EXFLOW', 8, 'SYS_INFLOW', 9, 'SYS_FLOODING', 10 ,...
				'SYS_OUTFLOW', 11, 'SYS_STORAGE', 12, 'SYS_EVAP', 13),...
			'flowClassType', struct(...
				'DRY', 0, 'UP_DRY', 1, 'DN_DRY', 2, 'SUBCRITICAL', 3, 'SUPCRITICAL', 4, ...
				'UP_CRITICAL', 5, 'DN_CRITICAL', 6, 'MAX_FLOW_CLASSES', 7, 'UP_FULL', 8, ...
				'DN_FULL', 9, 'ALL_FULL', 10),...
			'runoffFlowType', struct(...
				'RUNOFF_RAINFALL', 0, 'RUNOFF_EVAP', 1, 'RUNOFF_INFIL', 2, 'RUNOFF_RUNOFF', ...
				3, 'RUNOFF_DRAINS', 4, 'RUNOFF_RUNON', 5),...
			'loadingType', struct(...
				'BUILDUP_LOAD', 0, 'DEPOSITION_LOAD', 1, 'SWEEPING_LOAD', 2, ...
				'BMP_REMOVAL_LOAD', 3, 'INFIL_LOAD', 4, 'RUNOFF_LOAD', 5, ...
				'FINAL_LOAD', 6));
		results = struct(...
			'SUBCATCH', struct(...
				'SUBCATCH_RAINFALL', 0, 'SUBCATCH_SNOWDEPTH', 1, 'SUBCATCH_EVAP', 2, ...
				'SUBCATCH_INFIL', 3, 'SUBCATCH_RUNOFF', 4, 'SUBCATCH_GW_FLOW', 5, ...
				'SUBCATCH_GW_ELEV', 6, 'SUBCATCH_SOIL_MOIST', 7, 'SUBCATCH_WASHOFF', 8),...
			'NODE', struct(...
				'NODE_DEPTH', 0, 'NODE_HEAD', 1, 'NODE_VOLUME', 2, 'NODE_LATFLOW', 3,...
				'NODE_INFLOW', 4, 'NODE_OVERFLOW', 5, 'NODE_QUAL', 6),...
			'LINK', struct(...
				'LINK_FLOW', 0, 'LINK_DEPTH', 1, 'LINK_VELOCITY', 2, 'LINK_VOLUME', ...
				3, 'LINK_CAPACITY', 4, 'LINK_QUAL', 5));
		types = struct(...
			'objects', struct( ...
				'GAGE', 0, 'SUBCATCH', 1, 'NODE', 2, 'LINK', 3, ...
				'POLLUT', 4, 'LANDUSE', 5, 'TIMEPATTERN', 6, 'CURVE', 7, ...
				'TSERIES', 8, 'CONTROL', 9, 'TRANSECT', 10, 'AQUIFER', 11, ...
				'UNITHYD', 12, 'SNOWMELT', 13, 'SHAPE', 14, 'LID', 15, ...
				'MAX_OBJ_TYPES', 16), ...
			'nodeSubType', struct(...
				'JUNCTION', 0, 'OUTFALL', 1, 'STORAGE', 2, 'DIVIDER', 3), ...
			'linkSubType', struct(...
				'CONDUIT', 0, 'PUMP', 1, 'ORIFICE', 2, 'WEIR', 3, 'OUTLET', 4));
		sect = struct(...
			'xSectType', struct(...
				'DUMMY', 0, 'CIRCULAR', 1, 'FILLED_CIRCULAR', 2, 'RECT_CLOSED', 3, ...
				'RECT_OPEN', 4, 'TRAPEZOIDAL', 5, 'TRIANGULAR', 6, 'PARABOLIC', 7, ...
				'POWERFUNC', 8, 'RECT_TRIANG', 9, 'RECT_ROUND', 10, 'MOD_BASKET', ...
				11, 'HORIZ_ELLIPSE', 12, 'VERT_ELLIPSE', 13, 'ARCH', 14, 'EGGSHAPED', 15, ...
				'HORSESHOE', 16, 'GOTHIC', 17, 'CATENARY', 18, 'SEMIELLIPTICAL', 19, ...
				'BASKETHANDLE', 20, 'SEMICIRCULAR', 21, 'IRREGULAR', 22, 'CUSTOM', 23,...
				'FORCE_MAIN', 24));
		props = struct(...
			'SUBCATCH', struct(...
				'GAGE', 0, 'OUTNODE', 1, 'OUTSUBCATCH', 2, 'INFIL', 3, 'WIDTH', 4, 'AREA', 5, ...
        		'FRACIMPERV', 6, 'SLOPE', 7, 'CURBLENGTH', 8, 'INITBUILDUP', 9, 'LIDAREA', 10), ...
			'NODE', struct('INVERTELEV', 0, 'INITDEPTH', 1, 'FULLDEPTH', 2, 'SURDEPTH', 3, ...
				'PONDEDAREA', 4, 'DEGREE', 5, 'CROWNELEV', 6, 'LOSSES', 7, 'FULLVOLUME', 8), ...
			'LINK', struct('NODE1', 0, 'NODE2', 1, 'OFFSET1', 2, 'OFFSET2', 3, 'XSECT', 4, ...
				'Q0', 5, 'QLIMIT', 6, 'CLOSSINLET', 7, 'CLOSSOUTLET', 8, 'CLOSSAVG', 9, 'SEEPRATE', 10, ...
				'HASFLAPGATE', 11, 'SURFAREA1', 12, 'SURFAREA2', 13, 'QFULL', 14, 'SETTING', 15, ...
				'FROUDE', 16, 'FLOWCLASS', 17, 'DQDH', 18, 'DIRECTION', 19));
		subprops = struct(...
			'LINK', struct(...
				'CONDUIT', struct('LENGTH', 0, 'ROUGHNESS', 1, 'BARRELS', 2, 'MODLENGTH', 3, ...
					'ROUGHFACTOR', 4, 'SLOPE', 5, 'BETA', 6, 'QMAX', 7, 'A1', 8, 'A2', 9, 'Q1', 10, ...
					'Q2', 11, 'Q1OLD', 12, 'Q2OLD', 13, 'EVAPLOSSRATE', 14, 'SEEPLOSSRATE', 15, ...
					'CAPACITYLIMITED', 16, 'SUPERCRITICAL', 17, 'HASLOSSES', 18, 'FULLSTATE', 19), ...
				'PUMP', struct('INITSETTING', 0, 'YON', 1, 'YOFF', 2, 'XMIN', 3, 'XMAX', 4,), ...
				'ORIFICE', struct('CDISCH1', 0, 'CDISCH2', 1, 'ENDCON', 2, 'CANSURCHARGE', 3, 'CSURCHARGE', 4, ...
					'LENGTH', 5, 'SLOPE', 6, 'SURFAREA', 7), ...
				'WEIR', struct('TYPE', 0, 'SHAPE', 1, 'CDISCH1', 2, 'CDISCH2', 3, 'ENDCON', 4, ...
					'CANSURCHARGE', 5, 'CSURCHARGE', 6, 'LENGTH', 7, 'SLOPE', 8, 'SURFAREA', 9), ...
				'OUTLET', struct('QCOEFF', 0, 'QEXPON', 1, 'QCURVE', 2, 'CURVETYPE', 3)));
	end
	properties
		elapsed_time;
		timePtr;
		isRunning = false;
		inp = '';
		changes = '';
		saveCSV = false;
		time = []; % Vector of time
		it = 0; % Iteration
		units = 1; % SI units by default
	end
	properties (Hidden = true)
		errors = struct(...
			'ERROR_NFOUND', MException('AttributeError:Check_ID', ...
			'Error: Object not found'), ...
			'ERROR_TYPE',  MException('AttributeError:Check_TYPE', ...
			'Error: Type of object not compatible'), ...
			'ERROR_ATR', MException('AttributeError:Check_ATRBT', ...
			'Error: Attribute not compatible'), ...
			'ERROR_PATH', MException('AttributeError:Check_FILE_PATH', ...
			'Error: Incorrect file path'), ...
			'ERROR_INCOHERENT', MException('TypeError:Check_PARAMETERS', ...
			'Error: Incoherent parameter'), ...
			'ERROR_SYSTEM', MException('systemError:SystemFailure', ...
			'Error: The system failed - files must be closed'), ...
			'ERROR_IS_NUMERIC', MException('AttributeError:NotNumeric', ...
			'Error: This function just handle numerical attributes'), ...
			'ERROR_NRUNNING', MException('systemError:SystemFailure', ...
			'Error: There is no SWMM simulation running, please start the SWMM engine using swmm.run'), ...
			'ERROR_NOVER', MException('systemError:SystemFailure', ...
			'Error: There is a SWMM simulation running and it is not over yet, please use swmm.run_step until the end'));
		error_codes = struct(...
			'ERROR_PATH', -300, 'ERROR_ATR', -299, 'ERROR_TYPE', -298, ...
			'ERROR_NFOUND', -297, 'ERROR_INCOHERENT', -296, ...
			'ERROR_IS_NUMERIC', -295, 'ERROR_NRUNNING', -294, 'ERROR_NOVER', -293);
	end

	methods

		function throw_error(obj, error_code)
		% TODO - documentation
			fields = fieldnames(obj.error_codes);
			for i=1 : length(fields)
				code = extractfield(obj.error_codes, fields{i});
				if error_code == code
					error = extractfield(obj.errors, fields{i});
					throw(error{1});
				end
			end

			exception = MException('SystemFailure:CheckErrorCode',...
				sprintf('Error %d occurred, check the SWMM documentation', error_code));
			throw(exception);
		end

		function load_changes(obj)
		% TODO - documentation
			if isequal(obj.changes, '')
				return;
			end

			% TODO - define the codification of the 'changes' file, and the algorithm to read it
			% and save the modifications into the SWMM workspace. Define exceptions.
		end

		function open(obj)
		%* swmm.open *
		%
		% This SWMM function opens the files required to run a swmm
		% simulation
		%
		% swmm.open(p)
		%
		% p: path to the input file .inp

			if ~(libisloaded('swmm5'))
				loadlibrary('swmm5');
			end

			rpt = strrep(lower(obj.inp), '.inp', '.rpt'); % Report file .rpt
			out = strrep(lower(obj.inp), '.inp', '.out'); % Output file .out
			error = calllib('swmm5','swmm_open', obj.inp, rpt, out);
			if (error ~= 0) obj.throw_error(error); end
		end

		function start(obj)
		%* swmm.start *
		%
		% This SWMM function starts a SWMM simulation.
		% Raise Exception if there is an error
		%
		% swmm.start(w)
		%
		% w: constant related to the write report file option

			error = calllib('swmm5','swmm_start', 1); % 1 -> WRITE REPORT
			if (error ~= 0) obj.throw_error(error); end
			obj.elapsed_time = 1e-6;
			obj.timePtr = libpointer('doublePtr', obj.elapsed_time);

			error = calllib('swmm5', 'swmm_store_ids');
			if (error ~= 0) obj.throw_error(error); end

			obj.load_changes;
			obj.isRunning = true;
		end

		function end_sim(obj)
		%* swmm.end_sim *
		%
		% This SWMM function ends a SWMM simulation. Raise Exception if
		% a SWMM simulation has not been started
		%
		% swmm.end_sim

			error = calllib('swmm5','swmm_end');
			if (error ~= 0) obj.throw_error(error); end
		end

		function errors = get_mass_bal_error(obj)
		%*swmm.get_mass_bal_error *
		%
		% This SWMM function gets the mass balance errors of the
		% simulation
		%
		% e = swmm.get_mass_bal_error
		%
		% e: Values of the errors related to mass balance
		% e(1) run-off error | e(2) flow error | e(3) quality error

			runOffErr = single(0);
			flowErr = single(0);
			qualErr = single(0);
			ptrRunoff = libpointer('singlePtr', runOffErr);
			ptrFlow = libpointer('singlePtr', flowErr);
			ptrQual = libpointer('singlePtr', qualErr);


			error = calllib('swmm5','swmm_getMassBalErr', ptrRunoff, ptrFlow, ptrQual);
			if (error ~= 0) obj.throw_error(error); end

			runoff = ptrRunoff.value;
			flow = ptrFlow.value;
			qual = ptrQual.value;
			errors = [runoff, flow, qual];
		end

		function report(obj)
		%* swmm.report *
		%
		% This SWMM function writes the simulation results to report file.
		% Raise Exception if a SWMM simulation has not been completed
		%
		% swmm.report

			error = calllib('swmm5','swmm_report');
			if (error ~= 0) obj.throw_error(error);	end
		end

		function close(obj)
		%* swmm.close *
		%
		% This SWMM function closes a SWMM project. Raise Exception if
		% a SWMM simulation has not been completed
		%
		% swmm.close
			if obj.isRunning && ~obj.is_over
				throw(obj.errors.ERROR_NOVER);
			end

			error = calllib('swmm5','swmm_close');

			if error ~= 0
				exception = MException('SystemFailure:CheckErrorCode',...
				sprintf('Error %d occured, maybe there is no SWMM simulation running', error));
				throw(exception);
			end
			obj.it = 0; obj.time = []; % Clear time vector
			obj.isRunning = false;
		end

		function run_step(obj)
		%* swmm.run_step *
		%
		% This SWMM function advances the simulation by one routing time
		% step. Raise Exception if there is an error
		%
		% t = swmm.run_step
		%
		% t: elapsed time in hours
			if (~obj.isRunning) throw(obj.errors.ERROR_NRUNNING); end
			obj.it = obj.it + 1;
			obj.time(obj.it)  = obj.timePtr.value * 24;
			error = calllib('swmm5','swmm_step', obj.timePtr);

			if error ~= 0
				exception = MException('SystemFailure:CheckErrorCode',...
				sprintf('Error %d occurred at time %.2f hours', error, time));
				obj.it = 0; obj.time = []; % Clear time vector
				throw(exception);
			end
		end

		function bool_ans = is_over(obj)
		%* swmm.is_over *
		%
		% This MatSWMM function determines if the simulation is over
		% or not. And ends the simulation if b == true.
		%
		% b = swmm.is_over
		%
		% b: true if the simulation is over, i.e., if the current time
		% after initializing the simulation is equal to zero, false otherwise
			if (~obj.isRunning) throw(obj.errors.ERROR_NRUNNING); end
			bool_ans = obj.timePtr.value == 0;
			if bool_ans
				obj.end_sim;
				errors = obj.get_mass_bal_error; % TODO - define if errors are stored in a file or not
				obj.report;
				if obj.saveCSV
					obj.save_results;
				end
			end
		end

		function ask_files(obj, varargin)
		%* swmm.ask_files *
		%
		% This MatSWMM function can be used to update the input and changes
		% files that are required to run a SWMM simulation.
		%
		% swmm.ask_files() - The paths to the input and changes file
		% are requested through the command windows
		%
		% swmm.ask_files(cell)
		%
		% cell: it can be composed of one or two elements
		% cell == {inp} || cell == {inp, changes}
		%  inp: path to the SWMM input file
		%  changes: path to the MatSWMM changes file

			varargin = varargin{1};
			if ~isequal(obj.inp, '')
				return;
			elseif length(varargin) == 1
				obj.inp = varargin{1};
			elseif length(varargin) == 2
				obj.inp = varargin{1};
				obj.changes = varargin{2};
			else
				fprintf('\n--- MatSWMM 2 - Succesfully initialized ---\n');
				fprintf('\nPlease enter the path to the SWMM input file (.inp)\n');
				obj.inp = input('Path (.inp): ', 's');
				fprintf('\nPlease enter the path to the changes file\n');
				fprintf('\n[Press enter if you do not want to include changes]\n');
				obj.changes = input('Path to changes: ', 's');
			end
		end

		function run(obj, varargin)
		% TODO - documentation
			if obj.isRunning
				obj.close;
			end
			obj.ask_files(varargin)
			obj.open;
			obj.start;
		end

		function [ids, values] = get(obj, varargin)
		%* swmm.get *
		%
		% This MatSWMM function can be used to retrieve values of
		% properties or results, for an specific type of object(s).
		%
		% [IDs, values] = swmm.get(swmmType)
		% [IDs, values] = swmm.get(swmmType, swmmProp)
		% [IDs, values] = swmm.get(swmmType, swmmSubType, swmmProp)
		% [IDs, values] = swmm.get(ID, swmmType, swmmProp)
		% [IDs, values] = swmm.get(IDs, swmmType, swmmProp)
		% [IDs, values] = swmm.get(ID, swmmType, swmmSubType, swmmProp)
		% [IDs, values] = swmm.get(IDs, swmmType, swmmSubType, swmmProp)
		%
		% swmmType: type of object(s) that is(are) going
		% to be requested. It is part of the set of constants
		% in swmm.types.objects.
		% swmmSubType: subtype of object(s) that is(are) going
		% to be requested. It is part of the set of constants
		% in ->
		%     swmm.types.linkSubType,
		%     swmm.types.nodeSubType.
		% swmmProp: property of object(s) that is(are) going
		% to be requested. It is part of the set of constants
		% in ->
		%     swmm.props,
		%     swmm.subprops (if swmmType == swmm.types.objects.LINK ...
		%         && swmmSubType \in swmm.types.linkSubType),
		%     swmm.results
		% ID: identification name given in SWMM for the
		% requested object.
		% IDs: cell with identifications of requested objects.
		% values: it can be a matrix or a vector.
		% If the swmm.get function is invoked when the simulation is over,
		% the engine is still running (i.e., swmm.isRunning), and the
		% requested property (swmmProp) is in swmm.results, (values) is a
		% matrix, each column contains a vector with the simulation results
		% for each of the requested objects.
		% If only the swmm.isRunning condition is true, then values is a
		% vector with the values of the requested swmmProp. If swmmProp is
		% in swmm.results, then the last result is returned for each object.
		%
		% IMPORTANT -> Currently swmm.get can only be used for:
		%     swmmProp = swmm.types.objects.SUBCATCH
		%     swmmProp = swmm.types.objects.LINK
		%     swmmProp = swmm.types.objects.NODE

			if (~obj.isRunning) throw(obj.errors.ERROR_NRUNNING); end
			ids = {};
			getAll = false;

			if isa(varargin{1}, 'char')
				ids{1} = varargin{1};
			elseif isa(varargin{1}, 'cell')
				ids = varargin{1};
			end

			if isa(varargin{1}, 'double')
				getAll = true;
			end

			if getAll
				% The parameters for the DLL are defined
				swmmType = varargin{1};
				swmmSubType = -1; % -1 if no subtype is requested
				if nargin == 3
					swmmProp = varargin{2};
				elseif nargin == 4
					swmmSubType = varargin{2};
					swmmProp = varargin{3};
				end

				nObjects = calllib('swmm5', 'swmm_get_nobjects', swmmType, swmmSubType);
				idsPtr = libpointer('stringPtrPtr', cell(1, nObjects));
				calllib('swmm5', 'swmm_get_all', idsPtr, swmmType, swmmSubType);
				valuesPtr = libpointer('doublePtr', zeros(1, nObjects));
				error = calllib('swmm5', 'swmm_get', idsPtr, valuesPtr, swmmProp, swmmType, swmmSubType);
				if (error ~= 0) obj.throw_error(error); end
				ids = idsPtr.value;
				values = valuesPtr.value;
			else
				% The parameters for the DLL are defined
				swmmType = varargin{2};
				swmmSubType = -1; % -1 if no subtype is requested
				if nargin == 4
					swmmProp = varargin{3};
				elseif nargin == 5
					swmmSubType = varargin{3};
					swmmProp = varargin{4};
				end

				nObjects = length(ids);
				valuesPtr = libpointer('doublePtr', zeros(1, nObjects));
				error = calllib('swmm5', 'swmm_get', idsPtr, valuesPtr, swmmProp, swmmType, swmmSubType);
				if (error ~= 0) obj.throw_error(error);	end
				values = valuesPtr.value;
			end
		end

		%%
		function set(obj, varargin)
		%* swmm.set *
		% TODO - Complete documentation
		%
		% swmm.get(swmmType, swmmProp, values)
		% swmm.get(swmmType, swmmSubType, swmmProp, values)
		% swmm.get(ID, swmmType, swmmProp, values)
		% swmm.get(IDs, swmmType, swmmProp, values)
		% swmm.get(ID, swmmType, swmmSubType, swmmProp, values)
		% swmm.get(IDs, swmmType, swmmSubType, swmmProp, values)
		%
		% swmmType: type of object(s) that is(are) going
		% to be requested.
		% swmmSubType: subtype of object(s) that is(are) going
		% to be requested.
		% swmmProp: property of object(s) that is(are) going
		% to be requested.
		% ID: identification name given in SWMM for the
		% requested object.
		% IDs: cell with identifications of several objects.
			if (~obj.isRunning) throw(obj.errors.ERROR_NRUNNING); end
			ids = {};
			getAll = false;

			if isa(varargin{1}, 'char')
				ids{1} = varargin{1};
			elseif isa(varargin{1}, 'cell')
				ids = varargin{1};
			end

			if isa(varargin{1}, 'double')
				getAll = true;
			end

			if getAll
				% The parameters for the DLL are defined
				swmmType = varargin{1};
				swmmSubType = -1; % -1 if no subtype is requested
				if nargin == 4
					swmmProp = varargin{2};
					values = varargin{3}
				elseif nargin == 5
					swmmSubType = varargin{2};
					swmmProp = varargin{3};
					values = varargin{4}
				end

				nObjects = calllib('swmm5', 'swmm_get_nobjects', swmmType, swmmSubType);
				idsPtr = libpointer('stringPtrPtr', cell(1, nObjects));
				calllib('swmm5', 'swmm_get_all', idsPtr, swmmType, swmmSubType);
				ids = idsPtr.value;
			else
				% The parameters for the DLL are defined
				swmmType = varargin{2};
				swmmSubType = -1; % -1 if no subtype is requested
				if nargin == 5
					swmmProp = varargin{3};
					values = varargin{4}
				elseif nargin == 6
					swmmSubType = varargin{3};
					swmmProp = varargin{4};
					values = varargin{5}
				end
				idsPtr = libpointer('stringPtrPtr', ids);
			end

			valuesPtr = libpointer('doublePtr', values);
			error = calllib('swmm5', 'swmm_set', idsPtr, valuesPtr, swmmProp, swmmType, swmmSubType);
			if (error ~= 0) obj.throw_error(error);	end
		end

		function save_results(obj)
		%* swmm.save_results *
		%
		% This MatSWMM function saves all the results of the simulation
		% in csv files, organized in 4 folders in the workspace directory.
		% The folders are related to the type of objects (Link, Node,
		% Subcatch). A folder called 'Time' with information of the step
		% size is also saved
		%
		% swmm.save_results
			error = calllib('swmm5','swmm_save_results');
			if (error ~= 0) obj.throw_error(error);	end
		end

		function total_flooding = total_flooding(obj)
		%* swmm.total_flooding *
		%
		% This MatSWMM function calculates the total flooding in the
		% Urban Drainage System, for the simulation that is running.
		%
		% f = swmm.total_flooding
		%
		% f: total flooding [m^3/s]
			if (~obj.isRunning) throw(obj.errors.ERROR_NRUNNING); end
			floodPtr = libpointer('doublePtr', 0);
			error = calllib('swmm5', 'get_total_flooding', floodPtr);
			if (error ~= 0) obj.throw_error(error); end
			total_flooding = floodPtr.value;
		end

		%%
		function [time, result] = read_results(obj, object_id, object_type, attribute)
		%* swmm.read_results *
		%
		% This MatSWMM function retrieves the results of an specific type
		% of object after the simulation
		%
		% Compatible attributes with Subcatchments
		%  PRECIPITATION | RUNOFF
		% Compatible attributes with Nodes
		%  INFLOW | FLOODING | DEPTH | VOLUME
		% Compatible attributes with Links
		%  FLOW | DEPTH | VOLUME | CAPACITY
		%
		% [t, val] = swmm.read_results(id, type, attr)
		%
		% id: IDs of the objects
		% attr: constant related to the attribute of the requested object
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
		function current_time = get_time(obj)
		%* swmm.get_time *
		%
		% This MatSWMM function returns the current hour of the
		% simulation
		%
		% t: current time of the simulation in hours
		current_time = obj.timePtr.value*24;
		end
		%%

		function [I, nodes, links] = get_incidence_matrix(obj, inp)
		%* swmm.get_incidence_matrix *
		%
		% This MatSWMM function returns the graph representation of the
		% network
		% p: path to the swmm input file
		% I: Incidence matrix
		% nodes: ordered IDs of the nodes
		% links: ordered IDs of the links
		% Conduits
			if (~obj.isRunning) throw(obj.errors.ERROR_NRUNNING); end
		[~, from] = obj.get_all(inp, obj.LINK, obj.FROM_NODE);
		[conduits, to] = obj.get_all(inp, obj.LINK, obj.TO_NODE);
		% Orifices
		[~, ofrom] = obj.get_all(inp, obj.ORIFICE, obj.FROM_NODE);
		[orifices, oto] = obj.get_all(inp, obj.ORIFICE, obj.TO_NODE);

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
		function [M, links] = get_connectivity_matrix(obj, inp)
			if (~obj.isRunning) throw(obj.errors.ERROR_NRUNNING); end
		[I, ~, links] = obj.get_incidence_matrix(inp);

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

		%------------------------------------------------------------------------
		% Control functionalities
		%------------------------------------------------------------------------

		function K = nashK(V, Qout)
		n = size(Qout, 2);
		K = zeros(n,1);
		for i=1 : n
		% Least squares with Yalmip
		k = sdpvar(1,1);
		Qout_hat = k*V(:,i);
		objective = norm(Qout_hat - Qout(:,i),2);
		optimize([],objective);
		K(i) = value(k);
		end
		end
		function [A, B] = muskingum(obj, V, Qin, Qout)
		n = size(Qout, 2);
		A = zeros(n,1); B = zeros(n,1);
		for i=1 : n
		% Least squares with Yalmip
		a = sdpvar(1,1);
		b = sdpvar(1,1);
		V_hat = A*Qin(:,i) + B*Qout(:,i);
		objective = norm(V_hat - V(:,i),2);
		optimize([],objective);
		A(i) = value(a);
		B(i) = value(b);
		end
		end

		function output = pdyncontrol(obj, controller, type, w0, v, dt, varagin)
		% * swmm.pdyncontrol *
		%
		% TODO - re-write documentation
		%
		% Parameters (all the parameters must be row vectors)
		% - controller (char) ['replicator', 'smith', 'projection']
		% - type (char) topology of the network associated to the controller
		%  ['divergence', 'convergence']
		% - w0 (double) row vector of assignment x_k
		% - v (double) row vector of available resources
		% - dt (double) sampling time
		% - bta (double) adjustment factor

			if strcmp('divergence', type) % n
				f = 1-v(:);
			else
				f = v(:);
			end

			if nargin == 6
				bta = varagin(1);
			end

			n = length(w0);
			if strcmp(controller, 'replicator')
				% bta: sintonization parameter
				output = (bta + f(:))/(bta + w0(:)'*f(:)) .* w0(:);
			elseif strcmp(controller, 'smith')
				fik_fjk = repmat(f(:), 1, n)' - repmat(f(:), 1, n);
				fjk_fik = -fik_fjk;
				output = dt *( max(0, (fik_fjk))'*w0(:) - w0(:).*sum(max(0, fjk_fik))' ) + w0(:);
			elseif strcmp(controller, 'projection')
				output = dt * (f(:) - (1/n)*sum(f)) + w0(:);
			end
		end

		%------------------------------------------------------------------------
		% External Methods
		%------------------------------------------------------------------------

		function lineArray = read_mixed_csv(~, fileName, delimiter)
		% *swmm.read_mixed_csv *
		%
		% Auxiliar function
		% Retrieved from: http://goo.gl/nyTKBh
		% It is useful to read a CSV file with mixed data types (e.g., int, char)
		% It returns a cell array with the values retrieved from the CSV file.
		%
		% array = swmm.read_mixed_csv(fileName, delimiter);
		%
		% fileName: path to the CSV file
		% delimiter: delimiter used in the CSV file (e.g., ',', ';')

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
	end
end
