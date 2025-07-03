function SetRateCoefficients(inp, flags, model)
    %
    % SetRateCoefficients function uses functions specific for the LiveLink 
    % for MATLAB module to set rate coefficients for processes in the COMSOL model.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input
    
    msg(1, 'Setting rate coefficients', flags);  % Display status message
    
    variablesname = 'ratecoefficients';
    model.variable.create(variablesname);  % Create a variable node with the tag name 
                                           % "ratecoefficients" in the COMSOL model tree 
    model.variable(variablesname).model('mod1');  % Add the model tag
    model.variable(variablesname).name('Rate coefficients');  % Define the node name
    model.variable(variablesname).selection.named('plasmadomain');  % Specify domain (domain name must
                                                                    % be defined in the SetSection.m file)
    for i = inp.RateCoefficient_id
        id = num2str(i);
        temp_label = 'k';
        temp_data = inp.coefficients.("R" + id);
        temp_spec = inp.reacnames{i};
        temp_FullName = 'Rate coefficient';
        temp_name = 'k';
        data_type = temp_data.type;
        
        switch data_type
            case 'Constant'  % Constant defined values
                data = temp_data.value;
                unit = temp_data.unit;
                unit = strrep(unit, "eV", "V");  % Replace "eV" with "V" to make the 
                                                 % COMSOL model easier to handle
                model.variable(variablesname).set([temp_name, id], ...
                    [num2str(data), '[', char(unit), ']'], ...
                    [temp_FullName, ' of ', temp_spec]);  % Set rate coefficient in variable 
                                                          % node with a tag
                                                          % "ratecoefficients"
            case 'LUT'  % Data values defined as look-up tables (LUT); data for dependent 
                        % variable are stored in the first column
                data = temp_data.values;
                funcname = ['Fun_', temp_label, id];
                dep = temp_data.labels(1);

                % Change specific names for dependent variables to be consistent with 
                % earlier defined variables in the COMSOL model
                if isequal(char(dep), 'E/N')  % Reduced electric field
                    dep = 'EdN';
                elseif isequal(char(dep), 'L') || ...
                    isequal(char(dep), 'd')  % Discharge gap distances
                    dep = 'ElecDist';
                elseif isequal(char(dep), 'R')  % Electrode radius
                    dep = 'ElecRadius';
                end
                argunit = temp_data.units(1);
                argunit = strrep(argunit, "eV", "V");  % Replace "eV" with "V" to make 
                                                       % the COMSOL model easier to handle
                fununit = temp_data.units(2);
                fununit = strrep(fununit, "eV", "V");  % Replace "eV" with "V" to make 
                                                       % the COMSOL model easier to handle
                model.func.create(funcname, 'Interpolation'); % Create a function node for defintion 
                                                              % of data by interpolation of table data
                model.func(funcname).model('mod1');  % Add model tag
                model.func(funcname).name(funcname);  % Set the node name
                model.func(funcname).set('funcname', funcname);  % Set function name
                DATA = num2strcell(data);
                model.func(funcname).set('table', DATA);  % Set table data
                model.func(funcname).set('argunit', char(argunit));  % Set argument unit
                model.func(funcname).set('fununit', char(fununit));  % Set function unit
                model.variable(variablesname).set([temp_name, id], ...
                    [funcname, char("(" + dep + ")")], ...
                    [temp_FullName, ' of ', temp_spec]);  % Set rate coefficient in 
                                                          % variable node with a
                                                          % tag "ratecoefficients"
            case 'Expression'  % Data values defined as an expression (formula)
                expression = temp_data.expression;
                funcname = ['Fun_', temp_label, id];
                dep = {temp_data.parameters.label};
                expression = strrep(expression, 'E/N', 'EdN');  % Replace variable name 'E/N' 
                                                                % with 'EdN' to be consistent 
                                                                % with earlier defined variables 
                                                                % in the COMSOL model
                expression = strrep(expression, 'eV', 'V');  % Replace unit "eV" with "V" for 
                                                             % easier handling in the COMSOL model
                dep(strcmp(dep, 'E/N')) = {'EdN'};  % Replace dependence 'E/N' with 'EdN' to be 
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
                                                          % of data by analytic function
                model.func(funcname).model('mod1');  % Add model tag
                model.func(funcname).name(funcname);  % Set the node name
                model.func(funcname).set('funcname', funcname);  % Set function name
                model.func(funcname).set('expr', expression);  % Set expression
                model.func(funcname).set('args', dep);  % Set dependent variables (arguments)
                model.func(funcname).set('argunit', char(argunit));  % Set units for dependent 
                                                                     % variables (arguments)
                model.func(funcname).set('fununit', fununit);  % Set unit for the function
                dep = strjoin(dep, ', ');
                dep = replace(dep, ["L", "d", "R"], ...
                    ["ElecDist", "ElecDist", "R"]);  % Replace more variable names to be 
                                                     % consistent with earlier defined 
                                                     % variables in the COMSOL model
                dep = char("(" + dep + ")");
                model.variable(variablesname).set([temp_name, id], ...
                    [funcname, dep], [temp_FullName, ' of ', temp_spec]);  % Set rate coefficient 
                                                                           % with all info in variable 
                                                                           % node with a tag 
                                                                           % 'ratecoefficients'
            otherwise
                error(['Data type for ', temp_FullName, ' of ', temp_spec, ' not allowed.']);
        end
    end
end