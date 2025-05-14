function [inp] = InpRKM(inp)
%
% InpRKM function uses the structure of objects generated from json data and returns  
% the same structure with additional fields corresponding to variables necessary for setting up Comsol model
% 
% :param inp: input
% :returns: ``inp`` output

    %% Set species names
    names = fieldnames(inp.cfg_RKM_obj.states);
    inp.specnames = strings(length(names), 1); % Preallocate list of species names

    for i = 1:length(names)
        inp.specnames(i) = string(inp.cfg_RKM_obj.states.(names{i}).label); % Set species names from "label" defined in JSON file
    end

    inp.Nspec = length(inp.specnames); % Set total number of species

    %% Set species idexes and properties
    inp.Z = zeros(inp.Nspec, 1); % Preallocate species charge
    inp.nInd = []; % Initialize indexes for neutral species as empty arrays
    inp.iInd = []; % Initialize indexes for ions as empty arrays

    j = 0; k = 0;

    for i = 1:inp.Nspec

        temp_state = inp.cfg_RKM_obj.states.(names{i});
        inp.Z(i) = temp_state.charge; % Set species charge

        if any(strcmp(temp_state.particle, {'e', 'ele', 'electron'})) % Finding electron defined as 'e' or 'ele' or 'electron'
            inp.eInd = i; % Set index for electron
        elseif temp_state.charge == 0
            j = j + 1;
            inp.nInd(j) = i; % Set indexes for neutral species
        else
            k = k + 1;
            inp.iInd(k) = i; % Set indexes for ions species
        end

        for s = 1:length(temp_state.info)

            if isequal(temp_state.info(s).type, "mass")
                inp.Mass(i) = temp_state.info(s).data; % Set species mass
                break; % Exit loop once mass is found
            end

        end

    end

    % remark: N0Ind might be part of general json input file, part of
    % medium / gas mixture
    inp.n0Ind = 1; % Set indexes for background gas
    inp.eEnergyEqn = ['eq', num2str(inp.Nspec + 1)]; % Set index for electron energy balance equation needed later

    %% Set reaction scheme

    % Set reaction matrices

    % Reaction matrices define gain and loss of each species
    % Values in the gain matrix (ReacGain) correspond to the number of
    % specific species produced in each process.
    % Values in the loss matrix (ReacLoss) correspond to the number of specific species lost in each process.
    % Values in the power matrix (ReacPower) correspond to the total number of reactants specific in each process.

    inp.Nreac = length(inp.cfg_RKM_obj.processes); % Set total number of processes

    inp.ReacGain = zeros(inp.Nreac, inp.Nspec); % Preallocate gain matrix
    inp.ReacLoss = zeros(inp.Nreac, inp.Nspec); % Preallocate loss matrix
    inp.ReacPower = zeros(inp.Nspec, inp.Nreac); % Preallocate power matrix

    for i = 1:inp.Nreac
        reaction = inp.cfg_RKM_obj.processes(i).reaction;

        for j = 1:inp.Nspec
            left = 0;

            for k = 1:length(reaction.lhs)
                % Check whether certain species is reactant (left hand side of process) in specific process.
                % If it is a reactant, determine the quantity (count).
                if strcmp(getfield(reaction.lhs(k), 'state'), ...
                        inp.specnames{j})
                    left = reaction.lhs(k).count;
                end

            end

            right = 0;

            for k = 1:length(reaction.rhs)
                % Check whether certain species is a product (right hand side of process) of specific process.
                % If it is a product, determine the quantity (count).
                if strcmp(getfield(reaction.rhs(k), 'state'), ...
                        inp.specnames{j})
                    right = reaction.rhs(k).count;
                end

            end

            inp.ReacGain(i, j) = max(0, right - left); % Defining values of gain reaction matrix
            inp.ReacLoss(i, j) = max(0, left - right); % Defining values of loss reaction matrix
            inp.ReacPower(j, i) = left; % Defining values of power reaction matrix
        end

    end

    % Identification of processes in which electrons are involved
    inp.ele_processes = [];
    ele_name = inp.specnames(inp.eInd);

    for i = 1:inp.Nreac
        reaction = inp.cfg_RKM_obj.processes(i).reaction;

        if ismember(ele_name, {reaction.lhs.state}) > 0 || ismember(ele_name, {reaction.rhs.state}) > 0
            inp.ele_processes = [inp.ele_processes, i];
        end

    end

    % Set a list of chemical equations for included processes
    inp.reacnames = cell(inp.Nreac, 1); % Preallocate chemical equation list of all included processes

    for i = 1:inp.Nreac

        reaction = inp.cfg_RKM_obj.processes(i).reaction;
        temp_state = getfield(reaction.lhs(1), 'state');

        % Defining left hand side of chemical equation
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

        % Defining right hand side of chemical equation
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

    % Set a rate coefficients and energy rate coefficients for included processes

    target_1 = "RateCoefficient";
    target_2 = "EnergyRateCoefficient";
    inp.RateCoefficient_id = [];

    for i = 1:inp.Nreac % Loop through all processes to define rate coefficients
        temp_info = inp.cfg_RKM_obj.processes(i).info;

        if ismember(target_1, {temp_info.type}) == 1 || ismember(target_2, {temp_info.type}) == 1; % Check if rate and energy rate coefficients are defined

            if ismember(target_1, {temp_info.type}) == 1
                temp_id = find({temp_info.type} == target_1);
                inp.coefficients.("R" + num2str(i)) = temp_info(temp_id).data;
                inp.RateCoefficient_id = [inp.RateCoefficient_id, i];
            end

        else
            error(['Neither the rate nor the energy rate coefficient is defined for process. ', num2str(i)]);
        end

    end

    for i = inp.ele_processes % Loop through all processes that include electron to define energy rate coefficients
        temp_info = inp.cfg_RKM_obj.processes(i).info;

        if ismember(target_2, {temp_info.type}) == 1 % Check if energy rate coefficients is defined by user in JSON file
            temp_id = find({temp_info.type} == target_2);
            inp.coefficients.("Rene" + num2str(i)) = temp_info(temp_id).data;
        else
            temp_id = find({temp_info.type} == target_1);

            if ismember("threshold", fieldnames(temp_info(temp_id))) == 1 && temp_info(temp_id).threshold.value ~= 0

                threshold.value = temp_info(temp_id).threshold.value;
                threshold.unit = temp_info(temp_id).threshold.unit;

                % When energy rate coefficients for specific processes is
                % not given by user in JSON file, it will be defined as a
                % product of rate coefficient and energy threshold value
                inp.coefficients.("Rene" + num2str(i)).data = num2str(-threshold.value) + "[" + threshold.unit + "]*k";

            else
                error(['Threshold is not defined or is set to zero for process ', num2str(i)]);
            end

        end

    end

    % Defining reaction rates
    inp.ReactionRates = strings(length(inp.RateCoefficient_id), 1);

    for i = inp.RateCoefficient_id
        id = num2str(i);
        inp.ReactionRates(i) = "k" + id;
        temp = find(inp.ReacPower(:, i) ~= 0);

        for j = 1:length(temp)

            if inp.ReacPower(temp(j), i) == 1
                inp.ReactionRates(i) = inp.ReactionRates(i) + "*N" + num2str(temp(j));
            else
                inp.ReactionRates(i) = inp.ReactionRates(i) + "*N" + num2str(temp(j)) + "^" + num2str(inp.ReacPower(temp(j), i));
            end

        end

    end

    % Defining electron energy reaction rates
    inp.ReactionEnergyRates = strings(length(inp.ele_processes), 1);

    for i = inp.ele_processes
        id = num2str(i);
        inp.ReactionEnergyRates(i) = "kene" + id;
        temp = find(inp.ReacPower(:, i) ~= 0);

        for j = 1:length(temp)

            if inp.ReacPower(temp(j), i) == 1
                inp.ReactionEnergyRates(i) = inp.ReactionEnergyRates(i) + "*N" + num2str(temp(j));
            else
                inp.ReactionEnergyRates(i) = inp.ReactionEnergyRates(i) + "*N" + num2str(temp(j)) + "^" + num2str(inp.ReacPower(temp(j), i));
            end

        end

    end

    %% Set transport coefficients

    for i = 1:inp.Nspec
        temp_info = inp.cfg_RKM_obj.states.(names{i}).info;

        for j = 1:length(temp_info)

            if ~isequal(temp_info(j).type, "energy") && ~isequal(temp_info(j).type, "mass") % Exclude "energy" and "mass", since they do not belong to transport properties
                inp.coefficients.("species" + num2str(i) + "_" + temp_info(j).type) = temp_info(j).data;
            end

        end

    end

    % Changing ".value", ".values" and ".expression" into ".data"
    % because of easy handling of ".data" naming in further script steps

    fields = fieldnames(inp.coefficients);

    for i = 1:length(fields)
        fieldName = fields(i);
        temp = inp.coefficients.(string(fieldName));

        if isfield(temp, 'value') == 1
            temp.data = temp.value;
            temp = rmfield(temp, 'value');
        elseif isfield(temp, 'values') == 1
            temp.data = temp.values;
            temp = rmfield(temp, 'values');
        elseif isfield(temp, 'expression') == 1
            temp.data = temp.expression;
            temp = rmfield(temp, 'expression');
        end

        inp.coefficients.(string(fieldName)) = temp;
    end
