function SetTransportCoefficients(inp, flags, model)
    %
    % SetTransportCoefficients function uses functions specific for the LiveLink for
    % MATLAB module to set the species transport coefficients in the COMSOL model.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input
    
    msg(1, 'Setting transport coefficients', flags);  % Display status message
    
    variablesname = 'transportcoeffs';  
    model.variable.create(variablesname);  % Create a variable node with the tag
                                           % name "transportcoeffs" in the COMSOL model tree
    model.variable(variablesname).model('mod1');  % Add the model tag
    model.variable(variablesname).name('Transport coefficients');  % Define the node name
    model.variable(variablesname).selection.named('plasmadomain');  % Specify domain
                                                                    % (domain name must be defined 
                                                                    % in the SetSection.m file)
    
    %% ========================================================================
    % === Set the transport coefficients for all species, except electrons ====
    % =========================================================================
    
    % Set diffusion coefficients
    % --------------------------
    
    for i = 1:inp.Nspec
        if i == inp.eInd
            continue;
        end
        id = num2str(i);
        % Make temporary variables that are necessary for setting up the diffusion coefficients
        if isfield(inp.coefficients, "species" + id + "_ND")
            temp.label = ['ND' id];
            temp.factor = '/N';
            temp.data = inp.coefficients.("species" + id + "_ND");
        elseif isfield(inp.coefficients, "species" + id + "_DN")
            temp.label = ['ND' id];
            temp.factor = '/N';
            temp.data = inp.coefficients.("species" + id + "_DN");
        elseif isfield(inp.coefficients, "species" + id + "_D")
            temp.label = ['D' id];
            temp.factor = '';
            temp.data = inp.coefficients.("species" + id + "_D");
        else
            error(['No diffusion coefficient D for ', inp.specnames{i}, ' defined.']);
        end
        temp.spec = inp.specnames{i};
        temp.FullName = 'Diffusion coefficient';
        temp.name = ['D' id];
        SetData(model, variablesname, id, temp);  % Set diffusion coefficients 
                                                  % by calling the "SetData" function defined below
    end
    
    % Set mobility
    % ------------

    for i = 1:inp.Nspec
        if i == inp.eInd
            continue;
        end
        if inp.Z(i) == 0
            continue;
        end
        id = num2str(i);
        % Make temporary variables that are necessary for setting up the mobility
        if isfield(inp.coefficients, "species" + id + "_Nb")
            temp.label = ['Nb' id];
            temp.factor = '/N';
            temp.data = inp.coefficients.("species" + id + "_Nb");
        elseif isfield(inp.coefficients, "species" + id + "_bN")
            temp.label = ['Nb' id];
            temp.factor = '/N';
            temp.data = inp.coefficients.("species" + id + "_bN");
        elseif isfield(inp.coefficients, "species" + id + "_b")
            temp.label = ['b' id];
            temp.factor = '';
            temp.data = inp.coefficients.("species" + id + "_b");
        else
            error(['No mobility b for ', inp.specnames{i}, ' defined.']);
        end
        temp.spec = inp.specnames{i};
        temp.FullName = 'Mobility';
        temp.name = ['b' id];
        SetData(model, variablesname, id, temp);  % Set mobility by calling the "SetData" function defined below
    end
    
    %% ========================================================
    % === Set the transport coefficients for electrons ============
    % =========================================================
    
    i = inp.eInd;
    id = num2str(i);
    if strcmp(flags.enFlux, 'DDAn')  % Case: "DDAn" 
        % More details about the "DDAn" can be found in the following publications:
        % M. M. Becker and D. Loffhagen, AIP ADVANCES 3, 012108 (2013). 
        % doi:10.1063/1.4775771 URL: http://dx.doi.org/10.1063/1.4775771
        
        % Set momentum dissipation frequency nue
        % --------------------------------------
        
        % Make temporary variables that are necessary for setting up nue
        if isfield(inp.coefficients, "species" + id + "_nuedN")
            temp.label = 'nuedN';
            temp.factor = '*N';
            temp.data = inp.coefficients.("species" + id + "_nuedN");
        else
            error(['No momentum dissipation frequency nue for ', inp.specnames{i}, ' defined.']);
        end
        temp.spec = inp.specnames{i};
        temp.FullName = 'Momentum dissipation frequency';
        temp.name = 'nue';
        SetData(model, variablesname, id, temp);  % Set nue by calling the "SetData" function defined below
        
        % Set energy flux dissipation frequency nueps
        % -------------------------------------------
        
        % Make temporary variables that are necessary for setting up nueps
        if isfield(inp.coefficients, "species" + id + "_nuepsdN")
            temp.label = 'nuepsdN';
            temp.factor = '*N';
            temp.data = inp.coefficients.("species" + id + "_nuepsdN");
        else
            error(['No energy flux dissipation frequency nueps for ', inp.specnames{i}, ' defined.']);
        end
        temp.spec = inp.specnames{i};
        temp.FullName = 'Energy flux dissipation frequency';
        temp.name = 'nueps';
        SetData(model, variablesname, id, temp);  % Set nueps by calling the "SetData" function defined below
        
        % Set transport coefficient xi0
        % -----------------------------
        
        % Make temporary variables that are necessary for setting up xi0
        if isfield(inp.coefficients, "species" + id + "_xi0")
            temp.label = 'xi0';
            temp.factor = '';
            temp.data = inp.coefficients.("species" + id + "_xi0");
        else
            error(['No transport coefficient xi0 for ', inp.specnames{i}, ' defined.']);
        end
        temp.spec = inp.specnames{i};
        temp.FullName = 'Transport coefficient xi0';
        temp.name = 'xi0';
        SetData(model, variablesname, id, temp);  % Set xi0 by calling the "SetData" function defined below
        
        % Set transport coefficient xi2
        % -----------------------------
        
        % Make temporary variables that are necessary for setting up xi2
        if isfield(inp.coefficients, "species" + id + "_xi2")
            temp.label = 'xi2';
            temp.factor = '';
            temp.data = inp.coefficients.("species" + id + "_xi2");
        else
            error(['No transport coefficient xi2 for ', inp.specnames{i}, ' defined.']);
        end
        temp.spec = inp.specnames{i};
        temp.FullName = 'Transport coefficient xi2';
        temp.name = 'xi2';
        SetData(model, variablesname, id, temp);  % Set xi2 by calling the "SetData" function defined below
        
        % Set transport coefficient xi0eps
        % --------------------------------
        
        % Make temporary variables that are necessary for setting up xi0eps
        if isfield(inp.coefficients, "species" + id + "_xi0eps")
            temp.label = 'xi0eps';
            temp.factor = '';
            temp.data = inp.coefficients.("species" + id + "_xi0eps");
        else
            error(['No transport coefficient xi0eps for ', inp.specnames{i}, ' defined.']);
        end
        temp.spec = inp.specnames{i};
        temp.FullName = 'Transport coefficient xi0eps';
        temp.name = 'xi0eps';
        SetData(model, variablesname, id, temp);  % Set xi0eps by calling the "SetData" function defined below
        
        % Set transport coefficient xi2eps
        % --------------------------------
        
        % Make temporary variables that are necessary for setting up xi2eps
        if isfield(inp.coefficients, "species" + id + "_xi2eps")
            temp.label = 'xi2eps';
            temp.factor = '';
            temp.data = inp.coefficients.("species" + id + "_xi2eps");
        else
            error(['No transport coefficient xi2eps for ', inp.specnames{i}, ' defined.']);
        end
        temp.spec = inp.specnames{i};
        temp.FullName = 'Transport coefficient xi2eps';
        temp.name = 'xi2eps';
        SetData(model, variablesname, id, temp);  % Set xi2eps by calling the "SetData" function defined below
    else  % Case: "DDA53" and "DDAc"
        % More details about "DDA53" and "DDAc" can be found in the following publications:
        % M. M. Becker and D. Loffhagen, AIP ADVANCES 3, 012108 (2013). 
        % doi:10.1063/1.4775771 URL: http://dx.doi.org/10.1063/1.4775771
        
        % Set diffusion coefficient
        % -------------------------
        
        % Make temporary variables that are necessary for setting up the diffusion coefficient
        if isfield(inp.coefficients, "species" + id + "_ND")
            temp.label = ['ND' id];
            temp.factor = '/N';
            temp.data = inp.coefficients.("species" + id + "_ND");
        elseif isfield(inp.coefficients, "species" + id + "_DN")
            temp.label = ['ND' id];
            temp.factor = '/N';
            temp.data = inp.coefficients.("species" + id + "_DN");
        elseif isfield(inp.coefficients, "species" + id + "_D")
            temp.label = ['D' id];
            temp.factor = '';
            temp.data = inp.coefficients.("species" + id + "_D");
        else
            error(['No diffusion coefficients D for ', inp.specnames{i}, ' defined.']);
        end
        temp.spec = inp.specnames{i};
        temp.FullName = 'Diffusion coefficient';
        temp.name = ['D' id];
        SetData(model, variablesname, id, temp);  % Set the diffusion coefficient by calling
                                                  % the "SetData" function defined below
        
        % Set mobility
        % ------------
        
        % Make temporary variables that are necessary for setting up the mobility
        if isfield(inp.coefficients, "species" + id + "_Nb")
            temp.label = ['Nb' id];
            temp.factor = '/N';
            temp.data = inp.coefficients.("species" + id + "_Nb");
        elseif isfield(inp.coefficients, "species" + id + "_bN")
            temp.label = ['Nb' id];
            temp.factor = '/N';
            temp.data = inp.coefficients.("species" + id + "_bN");
        elseif isfield(inp.coefficients, "species" + id + "_b")
            temp.label = ['b' id];
            temp.factor = '';
            temp.data = inp.coefficients.("species" + id + "_b");
        else
            error(['No mobility b for ', inp.specnames{i}, ' defined.']);
        end
        temp.spec = inp.specnames{i};
        temp.FullName = 'Mobility';
        temp.name = ['b' id];
        SetData(model, variablesname, id, temp);  % Set the mobility by calling
                                                  % the "SetData" function defined below
        
        % Set electron energy diffusion coefficient Deps
        % ------------------------------------------
        
        if strcmp(flags.enFlux, 'DDA53')  % For "DDA53" 
            model.variable(variablesname).set('Deps', ['5/3*D', num2str(inp.eInd)], ...
                'Electron energy diffusion');  % Set the electron energy diffusion coefficient 
                                               % in the variable node of the COMSOL model
        elseif strcmp(flags.enFlux, 'DDAc')  % For "DDAc"
            
            % Make temporary variables that are necessary for setting up Deps
            if isfield(inp.coefficients, "species" + id + "_NDeps")
                temp.label = 'NDeps';
                temp.factor = '/N';
                temp.data = inp.coefficients.("species" + id + "_NDeps");
            elseif isfield(inp.coefficients, "species" + id + "_DepsN")
                temp.label = 'NDeps';
                temp.factor = '/N';
                temp.data = inp.coefficients.("species" + id + "_DepsN");
            elseif isfield(inp.coefficients, "species" + id + "_Deps")
                temp.label = 'Deps';
                temp.factor = '';
                temp.data = inp.coefficients.("species" + id + "_Deps");
            else
                error(['No energy diffusion Deps for ', inp.specnames{i}, ' defined.']);
            end
            temp.spec = inp.specnames{i};
            temp.FullName = 'Energy Diffusion';
            temp.name = 'Deps';
            SetData(model, variablesname, id, temp);  % Set Deps by calling 
                                                      % the "SetData" function defined below
        else
            error(['Wrong flag for electron energy flux (flags.enFlux): ', flags.enFlux]);
        end
        
        % Set electron energy mobility beps
        % ---------------------------------

        if strcmp(flags.enFlux, 'DDA53')  % For "DDA53"
            model.variable(variablesname).set('beps', ['5/3*b', num2str(inp.eInd)], ...
                'Electron energy mobility');  % Set the electron energy mobility in the 
                                              % variable node of the COMSOL model
        elseif strcmp(flags.enFlux, 'DDAc')  % For "DDAc"
            
            % Make temporary variables that are necessary for setting up beps
            if isfield(inp.coefficients, "species" + id + "_Nbeps")
                temp.label = 'Nbeps';
                temp.factor = '/N';
                temp.data = inp.coefficients.("species" + id + "_Nbeps");
            elseif isfield(inp.coefficients, "species" + id + "_bepsN")
                temp.label = 'Nbeps';
                temp.factor = '/N';
                temp.data = inp.coefficients.("species" + id + "_bepsN");
            elseif isfield(inp.coefficients, "species" + id + "_beps")
                temp.label = 'beps';
                temp.factor = '';
                temp.data = inp.coefficients.("species" + id + "_beps");
            else
                error(['No energy mobility beps for ', inp.specnames{i}, ' defined.']);
            end
            temp.spec = inp.specnames{i};
            temp.FullName = 'Energy mobility';
            temp.name = 'beps';
            SetData(model, variablesname, id, temp);  % Set beps by calling 
                                                      % the "SetData" function defined below
        else
            error(['Wrong flag for electron energy flux (flags.enFlux): ', flags.enFlux]);
        end
        msg(2, ['Model for electron energy flux: ', flags.enFlux], flags);
    end
end

%-----------------------------------------------
function SetData(model, variablesname, id, temp)
%-----------------------------------------------
    %
    % The "SetData" function reads data values for transport coefficients specified 
    % in the JSON file and employs functions that are specific for the Live Link for
    % MATLAB module to set them in the COMSOL model.
    %
    % :param model: the first input
    % :param variablesname: the second input
    % :param id: the third input
    % :param temp: the fourth input
    
    data_type = temp.data.type;
    
    switch data_type
        case 'Constant'  % Constant defined values
            data = temp.data.value;
            unit = temp.data.unit;
            unit = strrep(unit, "eV", "V");  % Replace "eV" with "V" to make 
                                             % the COMSOL model easier to handle
            if data > 0 
                if length(temp.factor) == 0  % Without factor. This means that the 
                                             % value should not be divided by or 
                                             % multiplied by any other value.
                    model.variable(variablesname).set(temp.name, ...
                        [num2str(data), '[', char(unit), ']'], ...
                        [temp.FullName, ' of ', temp.spec]);  % Set the coefficient in variable
                                                              % node with the tag name ""transportcoeffs"
                                                              % in the COMSOL model tree
                else  % With an additional factor
                    model.variable(variablesname).set(temp.name, ...
                        [num2str(data), '[', char(unit), ']', temp.factor], ...
                        [temp.FullName, ' of ', temp.spec]);  % Set the coefficient in variable
                                                              % node with the tag name ""transportcoeffs"
                                                              % in the COMSOL model tree
                end
            end
        case 'LUT'  % Data values defined as look-up tables (LUT); data for 
                    % dependent variable are stored in the first column
            data = temp.data.values;
            funcname = ['Fun_', temp.label];
            dep = temp.data.labels(1);
            
            % Change specific names for dependent variables to be consistent 
            % with earlier defined variables in the COMSOL model
            if isequal(char(dep), 'E/N') % Reduced electric field
                dep = 'EdN';
            elseif isequal(char(dep), 'L') || isequal(char(dep), 'd') % 
                % Discharge gap distance
                dep = 'DischGap';
            elseif isequal(char(dep), 'R') % Electrode radius
                dep = 'ElecRadius';
            end
            argunit = temp.data.units(1);
            argunit = strrep(argunit, "eV", "V");  % Replace "eV" with "V" to make 
                                                   % the COMSOL model easier to handle
            fununit = temp.data.units(2);
            fununit = strrep(fununit, "eV", "V");  % Replace "eV" with "V" to make 
                                                   % the COMSOL model easier to handle
            model.func.create(funcname, 'Interpolation');  % Create a function node for definition 
                                                           % of data by interpolation of table data
            model.func(funcname).model('mod1');  % Add the model tag
            model.func(funcname).name(funcname);  % Set the node name
            model.func(funcname).set('funcname', funcname);  % Set the function name
            DATA = num2strcell(data);
            model.func(funcname).set('table', DATA);  % Set the table data
            model.func(funcname).set('argunit', char(argunit));  % Set the argument unit
            model.func(funcname).set('fununit', char(fununit));  % Set the function unit
            if length(temp.factor) == 0  % Without factor. This means that the 
                                         % value should not be divided by or 
                                         % multiplied by any other value.
                model.variable(variablesname).set(temp.name, ...
                    [funcname, char("(" + dep + ")")], ...
                    [temp.FullName, ' of ', temp.spec]);  % Set the coefficient in variable
                                                          % node with the tag name ""transportcoeffs"
                                                          % in the COMSOL model tree
            else % With an additional factor exists
                model.variable(variablesname).set(temp.name, ...
                    [funcname, char("(" + dep + ")" + temp.factor)], ...
                    [temp.FullName, ' of ', temp.spec]);  % Set the coefficient in variable
                                                          % node with the tag name ""transportcoeffs"
                                                          % in the COMSOL model tree
            end
        case 'Expression'  % Data values defined as an expression (formula)
            expression = temp.data.expression;
            funcname = ['Fun_', temp.label];
            dep = {temp.data.parameters.label};
            expression = strrep(expression, 'E/N', 'EdN');  % Replace the variable name 
                                                            % "E/N" with "EdN" to be consistent 
                                                            % with earlier defined variables in 
                                                            % the COMSOL model
            expression = strrep(expression, 'eV', 'V');  % Replace the unit "eV" with "V" 
                                                         % for easier handling in the 
                                                         % COMSOL model
            dep(strcmp(dep, 'E/N')) = {'EdN'};  % Replace the dependence "E/N" with "EdN" 
                                                % to be consistent with earlier defined 
                                                % variables in the COMSOL model
            fununit = temp.data.unit;
            fununit = strrep(fununit, 'eV', 'V');  % Replace "eV" with "V" to make 
                                                   % the COMSOL model easier to handle
            argunit = {temp.data.parameters.unit};
            argunit = strjoin(argunit, ', ');
            argunit = replace(argunit, "eV", "V");  % Replace "eV" with "V" to make 
                                                    % the COMSOL model easier to handle
            model.func.create(funcname, 'Analytic');  % Create a function node for definition
                                                      % of data by analytic function
            model.func(funcname).model('mod1');  % Add the model tag
            model.func(funcname).name(funcname);  % Set the node name
            model.func(funcname).set('funcname', funcname);  % Set the function name
            model.func(funcname).set('expr', expression);  % Set the expression
            model.func(funcname).set('args', dep);  % Set the dependent variables (arguments)
            model.func(funcname).set('argunit', char(argunit));  % Set the units for 
                                                                 % dependent variables (arguments)
            model.func(funcname).set('fununit', fununit);  % Set the unit for the function
            dep(strcmp(dep, 'T')) = {['T' id]};  % Replace "T" with "Ti", where "i" is the 
                                                 % index of the corresponding species
            dep(strcmp(dep, 'b')) = {['b' id]};  % Replace "b" with "bi", where "i" is the 
                                                 % index of the corresponding species
            dep = strjoin(dep, ', ');
            dep = replace(dep, ["L", "d", "R"], ...
                ["DischGap", "DischGap", "R"]);  % Replace variable names to be 
                                                 % consistent with earlier defined 
                                                 % variables in the COMSOL model
            if length(temp.factor) == 0
                dep = char("(" + dep + ")");
            else
                dep = char("(" + dep + ")" + temp.factor);
            end
            model.variable(variablesname).set(temp.name, ...
                [funcname, dep], [temp.FullName, ' of ', temp.spec]);  % Set the coefficient in variable
                                                                       % node with the tag name ""transportcoeffs"
                                                                       % in the COMSOL model tree
        otherwise
            error(['Data type for ', temp.FullName, ' of ', temp.spec, ' not allowed.']);
    end
end