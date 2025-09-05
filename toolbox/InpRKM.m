function [inp] = InpRKM(inp)
    %
    % InpRKM function uses the object structure generated from the JSON 
    % data and returns the same structure with additional fields related to
    % reaction kinetic model (RKM) necessary for setting up the COMSOL model.
    %
    % :param inp: input
    % :returns: ``inp`` output
    
    %% ================================================
    % === Define species names from JSON input file ===
    % =================================================
    names = fieldnames(inp.cfg_RKM_obj.states);
    inp.specnames = strings(length(names), 1);
    for i = 1:length(names)
        inp.specnames(i) = string(inp.cfg_RKM_obj.states.(names{i}).label); 
    end
    inp.Nspec = length(inp.specnames); % Define total number of species
    
    %% ============================================
    % === Define species indexes and properties ===
    % =============================================
    
    inp.Z = zeros(inp.Nspec, 1);
    inp.nInd = [];
    inp.iInd = [];
    j = 0; 
    k = 0;
    for i = 1:inp.Nspec
        temp_state = inp.cfg_RKM_obj.states.(names{i});
        inp.Z(i) = temp_state.charge; % Set species charge
        if any(strcmp(temp_state.particle, {'e', 'ele', 'electron'}))  % Case: electron defined as 'e' or 'ele' or 'electron'
            inp.eInd = i; % Set index for electron
        elseif temp_state.charge == 0  % Case: neutral species
            j = j + 1;
            inp.nInd(j) = i; % Set indexes for neutral species
        else   % Case: ions
            k = k + 1;
            inp.iInd(k) = i; % Set indexes for ions
        end
        if isstruct(temp_state.info)  % Case: temp_state.info is a struct array
            for s = 1:length(temp_state.info)
                if isequal(temp_state.info(s).type, "mass")
                    inp.Mass(i) = temp_state.info(s).data; % Set species mass
                    break; % Exit loop once mass is found
                end
            end

        else  % Case: temp_state.info is a cell array of structs
            for s = 1:numel(temp_state.info)
                info_s = temp_state.info{s};
                if isequal(info_s.type, "mass")
                    inp.Mass(i) = info_s.data; % Set species mass
                    break; % Exit loop once mass is found
                end
            end
        end
    end
    inp.eEnergyEqn = ['eq', num2str(inp.Nspec + 1)]; % Set index for electron energy 
                                                     % balance equation needed later
    
    %% ================================================================
    % === Define variables necessary for setting up model chemistry ===
    % =================================================================
    
    % Define reaction matrices
    % -------------------------
    
    % Reaction matrices define the gain and loss of each species.
    % Values in the gain matrix (ReacGain) correspond to the number of 
    % particular species produced in each process.
    % Values in the loss matrix (ReacLoss) correspond to the number of 
    % particular species lost in each process.
    % Values in the power matrix (ReacPower) correspond to the total number 
    % of reactants in each process.
    
    inp.Nreac = length(inp.cfg_RKM_obj.processes); % Set total number of processes
    inp.ReacGain = zeros(inp.Nreac, inp.Nspec);
    inp.ReacLoss = zeros(inp.Nreac, inp.Nspec);
    inp.ReacPower = zeros(inp.Nspec, inp.Nreac);
    
    for i = 1:inp.Nreac
        reaction = inp.cfg_RKM_obj.processes(i).reaction;
        for j = 1:inp.Nspec
            left = 0;
            for k = 1:length(reaction.lhs)
                % Check whether certain species is a reactant (left hand side of 
                % chemical reaction) in specific process.
                % If it is a reactant, determine the quantity (count).
                if strcmp(getfield(reaction.lhs(k), 'state'), ...
                        inp.specnames{j})
                    left = reaction.lhs(k).count;
                end
            end
            right = 0;
            for k = 1:length(reaction.rhs)
                % Check whether certain species is a product (right hand side of chemical reaction)
                % of specific process. If it is a product, determine the quantity (count).
                if strcmp(getfield(reaction.rhs(k), 'state'), ...
                        inp.specnames{j})
                    right = reaction.rhs(k).count;
                end
            end
            inp.ReacGain(i, j) = max(0, right - left); % Determine values of the gain 
                                                       % reaction matrix
            inp.ReacLoss(i, j) = max(0, left - right); % Determine values of the loss 
                                                       % reaction matrix
            inp.ReacPower(j, i) = left; % Determine values of the power reaction matrix
        end
    end
    
    % Identify processes involving electrons
    % --------------------------------------
   
    inp.ele_processes = [];
    ele_name = inp.specnames(inp.eInd);
    for i = 1:inp.Nreac
        reaction = inp.cfg_RKM_obj.processes(i).reaction;
        if ismember(ele_name, {reaction.lhs.state}) > 0 || ...
           ismember(ele_name, {reaction.rhs.state}) > 0
            inp.ele_processes = [inp.ele_processes, i];
        end
    end
    
    % Make a complete list of included chemical reactions
    % ---------------------------------------------------
    
    inp.reacnames = cell(inp.Nreac, 1);
    for i = 1:inp.Nreac
        reaction = inp.cfg_RKM_obj.processes(i).reaction;
        temp_state = getfield(reaction.lhs(1), 'state');
        % Define left hand side of chemical reaction
        for k = 2:getfield(reaction.lhs(1), 'count')
            temp_state = [temp_state ' + ' getfield(reaction.lhs(1), 'state')];
        end
        for j = 2:length(reaction.lhs)
            temp_state = [temp_state ' + ' getfield(reaction.lhs(j), 'state')];
            for k = 2:getfield(reaction.lhs(j), 'count')
                temp_state = [temp_state ' + ' getfield(reaction.lhs(j), 'state')];
            end
        end
        temp_state = [temp_state ' --> ' getfield(reaction.rhs(1), 'state')];
        % Define right hand side of chemical reaction
        for k = 2:getfield(reaction.rhs(1), 'count')
            temp_state = [temp_state ' + ' getfield(reaction.rhs(1), 'state')];
        end
        for j = 2:length(reaction.rhs)
            temp_state = [temp_state ' + ' getfield(reaction.rhs(j), 'state')];
            for k = 2:getfield(reaction.rhs(j), 'count')
                temp_state = [temp_state ' + ' getfield(reaction.rhs(j), 'state')];
            end
        end
        inp.reacnames(i, 1) = {temp_state}; 
    end
    
    % Define rate coefficients
    % ------------------------

    target_1 = "RateCoefficient";
    target_2 = "EnergyRateCoefficient";

    inp.RateCoefficient_id = [];  % Initialize list of reactions with rate data

    for i = 1:inp.Nreac
        temp_info = inp.cfg_RKM_obj.processes(i).info;

        if isstruct(temp_info)  % Case: 'info' is a structure
            types = {temp_info.type};

            if any(strcmp(types, target_1)) || any(strcmp(types, target_2))
                % Store RateCoefficient if available
                if any(strcmp(types, target_1))
                    temp_id = find(strcmp(types, target_1), 1);
                    inp.coefficients.("R" + num2str(i)) = temp_info(temp_id).data;
                    inp.RateCoefficient_id(end + 1) = i;
                end
            else
                error(['No rate or energy rate coefficient defined for process ', num2str(i)]);
            end

        else  % Case: 'info' is a cell array of structs
            found = false;

            for j = 1:numel(temp_info)
                type_j = temp_info{j}.type;

                if strcmp(type_j, target_1) || strcmp(type_j, target_2)
                    found = true;

                    if strcmp(type_j, target_1)
                        inp.coefficients.("R" + num2str(i)) = temp_info{j}.data;
                        inp.RateCoefficient_id(end + 1) = i;
                    end
                end
            end

            if ~found
                error(['No rate or energy rate coefficient defined for process ', num2str(i)]);
            end
        end
    end
    
    % Define energy rate coefficients
    % --------------------------------
    target_1 = "RateCoefficient";
    target_2 = "EnergyRateCoefficient";

    for i = inp.ele_processes
        temp_info = inp.cfg_RKM_obj.processes(i).info;

         if isstruct(temp_info)  % Case: 'info' is a structure
            types = {temp_info.type};
            
            if any(strcmp(types, target_2)) % Direct energy rate coefficient available
                temp_id = find(strcmp(types, target_2), 1);
                inp.coefficients.("Rene" + num2str(i)) = temp_info(temp_id).data;
            elseif any(strcmp(types, target_1))
                 % When energy rate coefficient for specific process is not
                 % defined by the user in JSON file, it will be defined as
                 % a product of the rate coefficient and energy threshold value.
                temp_id = find(strcmp(types, target_1), 1);
                if isfield(temp_info(temp_id), "threshold") && ...
                        temp_info(temp_id).threshold.value ~= 0

                    threshold = temp_info(temp_id).threshold;
                    inp.coefficients.("Rene" + num2str(i)).data = ...
                        num2str(-threshold.value) + "[" + threshold.unit + "]*k";
                else
                    error(['Threshold missing or zero for process ', num2str(i)]);
                end

            else
                error(['No energy rate coefficient or threshold for process ', num2str(i)]);
            end

         else  % Case: 'info' is a cell array of structs
            found = false;

            for j = 1:numel(temp_info)
                info_j = temp_info{j};

                if strcmp(info_j.type, target_2)  % Direct energy rate coefficient available
                    inp.coefficients.("Rene" + num2str(i)) = info_j.data;
                    found = true;
                    break;

                elseif strcmp(info_j.type, target_1) && ...
                        isfield(info_j, "threshold") && ...
                        info_j.threshold.value ~= 0
                 % When energy rate coefficient for specific process is not
                 % defined by the user in JSON file, it will be defined as
                 % a product of the rate coefficient and energy threshold value.

                    threshold = info_j.threshold;
                    inp.coefficients.("Rene" + num2str(i)).data = ...
                        num2str(-threshold.value) + "[" + threshold.unit + "]*k";
                    found = true;
                    break;
                end
            end

            if ~found
                error(['No energy rate or usable threshold for process ', num2str(i)]);
            end
        end
    end
    
    % Define reaction rates
    % ---------------------
    
    inp.ReactionRates = strings(length(inp.RateCoefficient_id), 1);
    for i = inp.RateCoefficient_id
        id = num2str(i);
        inp.ReactionRates(i) = "k" + id;
        temp = find(inp.ReacPower(:, i) ~= 0);
        for j = 1:length(temp)
            if inp.ReacPower(temp(j), i) == 1
                inp.ReactionRates(i) = inp.ReactionRates(i) + "*N" + num2str(temp(j));
            else
                inp.ReactionRates(i) = inp.ReactionRates(i) + "*N" + ...
                    num2str(temp(j)) + "^" + num2str(inp.ReacPower(temp(j), i));
            end
        end
    end
    
    % Define electron energy reaction rates
    % -------------------------------------
    
    inp.ReactionEnergyRates = strings(length(inp.ele_processes), 1);
    for i = inp.ele_processes
        id = num2str(i);
        inp.ReactionEnergyRates(i) = "kene" + id;
        temp = find(inp.ReacPower(:, i) ~= 0);
        for j = 1:length(temp)
            if inp.ReacPower(temp(j), i) == 1
                inp.ReactionEnergyRates(i) = inp.ReactionEnergyRates(i) + ...
                    "*N" + num2str(temp(j));
            else
                inp.ReactionEnergyRates(i) = inp.ReactionEnergyRates(i) + ...
                    "*N" + num2str(temp(j)) + "^" + num2str(inp.ReacPower(temp(j), i));
            end
        end
    end
    
    %% ===============================================================================
    % === Define variables necessary for setting up species transport coefficients ===
    % ================================================================================
    
    for i = 1:inp.Nspec
        temp_info = inp.cfg_RKM_obj.states.(names{i}).info;

        if isstruct(temp_info)  % Case: temp_info is a structure array
            for j = 1:length(temp_info)
                if ~isequal(temp_info(j).type, "energy") && ...
                        ~isequal(temp_info(j).type, "mass") % Exclude "energy" and "mass", since
                    % they do not belong to transport properties
                    if strcmp(temp_info(j).data.type, 'Constant') || ...
                            strcmp(temp_info(j).data.type, 'Expression')
                        temp_name = temp_info(j).data.label;
                        temp_name(temp_name == '*') = [];
                        temp_name(temp_name == '/') = 'd';
                    elseif strcmp(temp_info(j).data.type, 'LUT')
                        temp_name = temp_info(j).data.labels{2};
                        temp_name(temp_name == '*') = [];
                        temp_name(temp_name == '/') = 'd';
                    else
                        error(['No transport coefficients for ', inp.specnames{i}, ...
                            ' or data type not allowed.']);
                    end
                    inp.coefficients.("species" + num2str(i) + "_" + temp_name) = ...
                        temp_info(j).data;
                end
            end

        else  % Case: temp_info is a cell array of structures
            for j = 1:numel(temp_info)
                ti = temp_info{j};
                if ~isequal(ti.type, "energy") && ...
                        ~isequal(ti.type, "mass") % Exclude "energy" and "mass"
                    if strcmp(ti.data.type, 'Constant') || ...
                            strcmp(ti.data.type, 'Expression')
                        temp_name = ti.data.label;
                        temp_name(temp_name == '*') = [];
                        temp_name(temp_name == '/') = 'd';
                    elseif strcmp(ti.data.type, 'LUT')
                        temp_name = ti.data.labels{2};
                        temp_name(temp_name == '*') = [];
                        temp_name(temp_name == '/') = 'd';
                    else
                        error(['No transport coefficients for ', inp.specnames{i}, ...
                            ' or data type not allowed.']);
                    end
                    inp.coefficients.("species" + num2str(i) + "_" + temp_name) = ...
                        ti.data;
                end
            end
        end
    end
end