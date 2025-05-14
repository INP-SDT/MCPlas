function SetRateCoefficients(inp, flags, model)

    msg(1, 'setting rate coefficients', flags);

    variablesname = 'ratecoefficients';
    model.variable.create(variablesname);
    model.variable(variablesname).model('mod1');
    model.variable(variablesname).name('Rate coefficients');
    model.variable(variablesname).selection.named('plasmadomain');

    for i = inp.RateCoefficient_id

        id = num2str(i);
        funcname = ['Fun_k' id];
        temp_R = inp.coefficients.("R" + id);
        data_type = temp_R.type;
        data = temp_R.data;

        switch data_type
            case 'Constant'
                unit = temp_R.unit;
                unit = strrep(unit, "eV", "V");
                model.variable(variablesname).set(['k', id], ...
                    [num2str(data), '[', char(unit), ']'], ...
                    ['Rate coefficent ', id, ': ', inp.reacnames{i}]);

            case 'LUT'
                dep = temp_R.parameters(1);
                
                if isequal(char(dep), 'E/N')
                    dep='EdN';
                elseif isequal(char(dep), 'L') || isequal(char(dep), 'd')
                    dep='ElecDist';
                elseif isequal(char(dep), 'R')
                    dep='ElecRadius';
                else                     
                end
                
                argunit = temp_R.units(1);
                argunit = strrep(argunit, "eV", "V");
                fununit = temp_R.units(2);
                fununit = replace(fununit,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);

                model.func.create(funcname, 'Interpolation');
                model.func(funcname).model('mod1');
                model.func(funcname).name(funcname);
                model.func(funcname).set('funcname', funcname);
                DATA = num2strcell(data);
                model.func(funcname).set('table', DATA);
                model.func(funcname).set('argunit', char(argunit));
                model.func(funcname).set('fununit', char(fununit));
                model.variable(variablesname).set(['k', id], ...
                    [funcname, char("(" + dep + ")")], ...
                    ['Rate coefficent ', id, ': ', inp.reacnames{i}]);

            case 'Expression'
                dep = temp_R.parameters;
                dep = replace(dep,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);
                fununit = temp_R.unit;
                fununit = strrep(fununit, "eV", "V");
                argunit = [];

                for j = 1:length(dep)

                    if isequal(dep{j}, 'Tgas') || isequal(dep{j}, 'Te')
                        temp_argunit{j} = 'K';
                    elseif isequal(dep{j}, 'Umean')
                        temp_argunit{j} = 'V';
                    elseif isequal(dep{j}, 'L') || isequal(dep{j}, 'R') || isequal(dep{j}, 'd') || isequal(dep{j}, 'ElecDist')
                        temp_argunit{j} = 'm';
                    elseif isequal(dep{j}, 'E/N')
                        dep{j} = 'EdN';
                        temp_argunit{j} = 'Td';
                    end

                    if j == 1
                        argunit = [argunit, temp_argunit{j}];
                    else
                        argunit = [argunit, ',', temp_argunit{j}];
                    end

                end

                model.func.create(funcname, 'Analytic');
                model.func(funcname).model('mod1');
                model.func(funcname).name(funcname);
                model.func(funcname).set('funcname', funcname);
                data = strrep(data, "eV", "V");
                model.func(funcname).set('expr', data);
                temp = strjoin(dep, ',');
                model.func(funcname).set('args', temp);
                model.func(funcname).set('argunit', char(argunit));
                model.func(funcname).set('fununit', char(fununit));
                temp = char("("+temp + ")");
                model.variable(variablesname).set(['k', id], ...
                    [funcname, temp], ...
                    ['Rate coefficent ', id, ': ', inp.reacnames{i}]);

            otherwise
                error(['Data type for rate coefficient', num2str(i), 'not allowed;']);

        end

    end

end
