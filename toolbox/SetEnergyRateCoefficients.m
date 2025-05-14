function SetEnergyRateCoefficients(inp, flags, model)

    msg(1, 'setting electron energy rate coefficients', flags);

    variablesname = 'electronenergyratecoefficients';
    model.variable.create(variablesname);
    model.variable(variablesname).model('mod1');
    model.variable(variablesname).name('Electron energy rate coefficients');
    model.variable(variablesname).selection.named('plasmadomain');

    for i = inp.ele_processes
        id = num2str(i);
        funcname = ['Fun_kene', id];
        temp_Rene = inp.coefficients.("Rene" + id);
        data = temp_Rene.data;

        if isfield(temp_Rene, 'type') == 1

            data_type = temp_Rene.type;

            switch data_type
                case 'Constant'
                    unit = temp_Rene.unit;
                    unit = strrep(unit, "eV", "V");
                    model.variable(variablesname).set(['kene', id], ...
                        [num2str(data), '[', char(unit), ']'], ...
                        ['Eletron energy rate coefficent', id, ': ', inp.reacnames{i}]);
                case 'LUT'
                    dep = temp_Rene.parameters(1);
                
                    if isequal(char(dep), 'E/N')
                        dep='EdN';
                    elseif isequal(char(dep), 'L') || isequal(char(dep), 'd')
                    dep='ElecDist';
                    elseif isequal(char(dep), 'R')
                        dep='ElecRadius';
                    else                     
                    end                    
                    argunit = temp_Rene.units(1);
                    argunit = strrep(argunit, "eV", "V");
                    fununit = temp_Rene.units(2);
                    fununit = strrep(fununit, "eV", "V");

                    model.func.create(funcname, 'Interpolation');
                    model.func(funcname).model('mod1');
                    model.func(funcname).name(funcname);
                    model.func(funcname).set('funcname', funcname);
                    DATA = num2strcell(data);
                    model.func(funcname).set('table', DATA);
                    model.func(funcname).set('argunit', char(argunit));
                    model.func(funcname).set('fununit', char(fununit));
                    model.variable(variablesname).set(['kene', id], ...
                        [funcname, char("(" + dep + ")")], ...
                        ['Eletron energy rate coefficent ', id, ': ', inp.reacnames{i}]);

                case 'Expression'
                    dep = temp_Rene.parameters;
                    dep = replace(dep,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);
                    fununit = temp_Rene.unit;
                    fununit = strrep(fununit, "eV", "V");
                    argunit = [];

                    for j = 1:length(dep)

                        if isequal(dep{j}, 'Tgas') || isequal(dep{j}, 'Te')
                            temp_argunit{j} = 'K';
                        elseif isequal(dep{j}, 'Umean')
                            temp_argunit{j} = 'V';
                        elseif isequal(dep{j}, 'L') || isequal(dep{j}, 'R') || ...
                                isequal(dep{j}, 'd') || isequal(dep{j}, 'ElecDist')
                            temp_argunit{j} = 'm';
                        elseif isequal(dep{j}, 'E/N')
                            temp_argunit{j} = 'Td';
                        elseif isequal(dep{j}, 'k')
                            temp_R = inp.coefficients.("R" + id);

                            if ismember('units', fieldnames(temp_R)) == 1
                                temp_argunit{j} = temp_R.units{2};
                            else
                                temp_argunit{j} = temp_R.unit;
                            end

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
                    idx = find(strcmp(dep, 'k'));

                    if ~isempty(idx)
                        dep{idx} = ['k' id];
                    end

                    temp = strjoin(dep, ',');
                    model.variable(variablesname).set(['kene', id], ...
                        [funcname, char("(" + temp + ")")], ...
                        ['Eletron energy rate coefficent ', id, ': ', inp.reacnames{i}]);

                otherwise
                    error(['Data type for energy rate coefficient', num2str(i), 'not allowed;']);
            end

        else

            temp_R = inp.coefficients.("R" + id);

            if isfield(temp_R, 'units') == 1
                argunit = temp_R.units(2);
                fununit = ['V*' argunit{1}];
            elseif isfield(temp_R, 'unit') == 1
                argunit = temp_R.unit;
                fununit = ['V*' argunit];
            else
                error(['Cannot define unit for kene based on unit for k', num2str(i), ';']);
            end

            model.func.create(funcname, 'Analytic');
            model.func(funcname).model('mod1');
            model.func(funcname).name(funcname);
            model.func(funcname).set('funcname', funcname);
            data = strrep(data, "eV", "V");
            model.func(funcname).set('expr', data);
            model.func(funcname).set('args', 'k');
            %model.func(funcname).set('args', temp);
            model.func(funcname).set('argunit', char(argunit));
            model.func(funcname).set('fununit', char(fununit));
            temp = char("(k"+id + ")");
            model.variable(variablesname).set(['kene', id], ...
                [funcname, temp], ...
                ['Eletron energy rate coefficent ', id, ': ', inp.reacnames{i}]);

        end

    end

end
