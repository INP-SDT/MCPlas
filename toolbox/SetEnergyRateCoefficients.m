function SetEnergyRateCoefficients(inp, flags, model)
    %
    % SetEnergyRateCoefficients function uses functions specific for the LiveLink 
    % for MATLAB module to set the rate coefficients for the electron energy 
    % balance equation in the COMSOL model.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input
    
    msg(1, 'Setting electron energy rate coefficients', flags);  % Display status message
    
    variablesname = 'electronenergyratecoefficients';
    model.variable.create(variablesname);  % Create a variable node with the tag name 
                                           % "electronenergyratecoefficients" 
                                           % in the COMSOL model tree
    model.variable(variablesname).model('mod1');  % Add the model tag
    model.variable(variablesname).name('Electron energy rate coefficients');  % Define node name
    model.variable(variablesname).selection.named('plasmadomain');  % Specify domain (domain name 
                                                                    % must be defined in the SetSection.m file)
    
    for i = inp.ele_processes
        id = num2str(i);
        temp_label = 'kene';
        temp_data = inp.coefficients.("Rene" + id);
        temp_spec = inp.reacnames{i};
        temp_FullName = 'Energy rate coefficient';
        temp_name = 'kene';
        
        if isfield(temp_data, 'type') == 1  % Case: energy rate coefficient 
                                            % is defined in JSON input file
            data_type = temp_data.type;
            switch data_type
                case 'Constant' % Constant defined values
                    data = temp_data.value;
                    unit = temp_data.unit;
                    unit = strrep(unit, "eV", "V");  % Replace "eV" with "V" to make 
                                                     % the COMSOL model easier to handle.
                    model.variable(variablesname).set([temp_name, id], ...
                        [num2str(data), '[', char(unit), ']'], ...
                        [temp_FullName, ' of ', temp_spec]);  % Set energy rate coefficient 
                                                              % in variable node with a tag
                                                              % "electronenergyratecoefficients"
                case 'LUT'  % Data values defined as look-up tables (LUT); data for 
                            % dependent variable are stored in the first column
                    data = temp_data.values;
                    funcname = ['Fun_', temp_label, id];
                    dep = temp_data.labels(1);
                    
                    % Change specific names for dependent variables to be consistent 
                    % with earlier defined variables in the COMSOL model
                    if isequal(char(dep), 'E/N')  % Reduced electric field
                        dep = 'EdN';
                    elseif isequal(char(dep), 'L') || isequal(char(dep), 'd') % 
                        % Distance between electrodes
                        dep = 'DischGap';
                    elseif isequal(char(dep), 'R')  % Electrode radius
                        dep = 'ElecRadius';
                    end
                    argunit = temp_data.units(1);
                    argunit = strrep(argunit, "eV", "V");  % Replace "eV" with "V" to make 
                                                           % the COMSOL model easier to handle
                    fununit = temp_data.units(2);
                    fununit = strrep(fununit, "eV", "V");  % Replace "eV" with "V" to make 
                                                           % the COMSOL model easier to handle
                    model.func.create(funcname, 'Interpolation');  % Create a function node 
                                                                   % for definition of data by interpolation 
                                                                   % of table data
                    model.func(funcname).model('mod1');  % Add the model tag
                    model.func(funcname).name(funcname);  % Set the node name
                    model.func(funcname).set('funcname', funcname);  % Set the function name
                    DATA = num2strcell(data);
                    model.func(funcname).set('table', DATA);  % Set the table data
                    model.func(funcname).set('argunit', char(argunit));  % Set the argument unit
                    model.func(funcname).set('fununit', char(fununit));  % Set the function unit
                    model.variable(variablesname).set([temp_name, id], ...
                        [funcname, char("(" + dep + ")")], ...
                        [temp_FullName, ' of ', temp_spec]);  % Set energy rate coefficient 
                                                              % in variable node with a tag
                                                              % "electronenergyratecoefficients"
                case 'Expression'  % Data values defined as an expression (formula)
                    expression = temp_data.expression;
                    funcname = ['Fun_', temp_label, id];
                    dep = {temp_data.parameters.label};
                    expression = strrep(expression, 'E/N', 'EdN');  % Replace variable name "E/N" 
                                                                    % with "EdN" to be consistent 
                                                                    % with earlier defined variables 
                                                                    % in the COMSOL model
                    expression = strrep(expression, 'eV', 'V');  % Replace unit "eV" with "V" for 
                                                                 % easier handling in the COMSOL model
                    dep(strcmp(dep, 'E/N')) = {'EdN'};  % Replace dependence "E/N" with "EdN" to be 
                                                        % consistent with earlier defined variables 
                                                        % in the COMSOL model
                    fununit = temp_data.unit;
                    fununit = strrep(fununit, 'eV', 'V');  % Replace "eV" with "V" to make the 
                                                           % COMSOL model easier to handle
                    argunit = {temp_data.parameters.unit};
                    argunit = strjoin(argunit, ', ');
                    argunit = replace(argunit, "eV", "V");  % Replace "eV" with "V" to make the 
                                                            % COMSOL model easier to handle
                    model.func.create(funcname, 'Analytic');  % Create a function node for definition  
                                                              % of data by the analytic function
                    model.func(funcname).model('mod1');  % Add the model tag
                    model.func(funcname).name(funcname);  % Set the node name
                    model.func(funcname).set('funcname', funcname);  % Set the function name
                    model.func(funcname).set('expr', expression);  % Set the expression
                    model.func(funcname).set('args', dep);  % Set dependent variables (arguments)
                    model.func(funcname).set('argunit', char(argunit));  % Set units for dependent 
                                                                         % variables (arguments)
                    model.func(funcname).set('fununit', fununit);  % Set unit for the function
                    dep(strcmp(dep, 'k')) = {['k' id]};  % Replace dependence 'k' with 'ki' to be 
                                                         % consistent with earlier defined variables 
                                                         % in the COMSOL model
                    dep = strjoin(dep, ', ');
                    dep = replace(dep, ["L", "d", "R"], ...
                        ["DischGap", "DischGap", "R"]);  % Replace more variable names to be 
                                                         % consistent with earlier defined 
                                                         % variables in the COMSOL model
                    dep = char("(" + dep + ")");
                    model.variable(variablesname).set([temp_name, id], ...
                        [funcname, dep], [temp_FullName, ' of ', temp_spec]);  % Set energy rate coefficient
                                                                               % in variable nod with a tag
                                                                               % "electronenergyratecoefficients"
                otherwise
                    error(['Data type for ', temp_FullName, ' of ', temp_spec, ' not allowed.']);
            end
        else  % Case: Processes that involve electrons and for which the energy rate coefficient 
              % is not defined in the JSON input file
            temp_R = inp.coefficients.("R" + id);
            % Define units for function and argument
            if isfield(temp_R, 'units') == 1
                argunit = temp_R.units(2);
                fununit = ['V*' argunit{1}];
            elseif isfield(temp_R, 'unit') == 1
                argunit = temp_R.unit;
                fununit = ['V*' argunit];
            else
                error(['Cannot define unit for kene based on unit for k', num2str(i), ';']);
            end
            expression = temp_data.data;
            expression = strrep(expression, "eV", "V");  % Replace "eV" with "V" to make the 
                                                         % COMSOL model easier to handle
            funcname = ['Fun_', temp_label, id];
            model.func.create(funcname, 'Analytic');  % Create a function node for definition of 
                                                      % data by the analytic function
            model.func(funcname).model('mod1');  % Add the model tag
            model.func(funcname).name(funcname);  % Set the node name
            model.func(funcname).set('funcname', funcname);  % Set the function name
            model.func(funcname).set('expr', expression);  % Set the expression
            model.func(funcname).set('args', 'k');  % Set dependent variables (arguments)
            model.func(funcname).set('argunit', argunit);  % Set units for dependent variables (arguments)
            model.func(funcname).set('fununit', fununit);  % Set unit for the function
            temp = char("(k" + id + ")");
            model.variable(variablesname).set(['kene', id], ...
                [funcname, temp], ...
                ['Electron energy rate coefficient ', id, ': ', inp.reacnames{i}]);  % Set energy rate coefficient 
                                                                                     % in variable node with a tag
                                                                                     % "electronenergyratecoefficients"
        end
    end
end