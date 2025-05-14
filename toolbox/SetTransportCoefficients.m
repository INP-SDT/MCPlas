function SetTransportCoefficients(inp, flags, model)

    msg(1, 'setting transport coefficients', flags);

    % create variable section for transport coefficients
    variablesname = 'transportcoeffs';
    model.variable.create(variablesname);
    model.variable(variablesname).model('mod1');
    model.variable(variablesname).name('Transport coefficients');
    model.variable(variablesname).selection.named('plasmadomain');

    % set diffusion coefficients
    % for all species, except electrons
    for i = 1:inp.Nspec
        if i == inp.eInd
            continue
        end

        id = num2str(i);
        funcname = ['Fun_ND', id];
        temp_data = inp.coefficients.("species" + id + "_diffusion");
        data_type = temp_data.type;

        if strcmp(data_type, 'Einstein') == 0
            data = temp_data.data;
        end

        switch data_type

            case 'Constant'
                unit = temp_data.unit;
                unit = strrep(unit, "eV", "V");

                if data > 0
                    model.variable(variablesname).set(['D', id], ...
                        [num2str(data), '[', char(unit), ']/N'], ...
                        ['Diffusion coefficient of ', inp.specnames{i}]);
                end

            case 'Einstein'
                model.variable(variablesname).set(['D', id], ...
                    ['kB/e0*T', id, '*b', id], ...
                    ['Diffusion coefficient of ', inp.specnames{i}]);
            case 'LUT'
                dep = temp_data.parameters(1);
                if isequal(char(dep), 'E/N')
                    dep='EdN';
                elseif isequal(char(dep), 'L') || isequal(char(dep), 'd')
                    dep='ElecDist';
                elseif isequal(char(dep), 'R')
                    dep='ElecRadius';
                else                     
                end
                
                argunit = temp_data.units(1);
                argunit = strrep(argunit, "eV", "V");
                fununit = temp_data.units(2);
                fununit = strrep(fununit, "eV", "V");
                
                model.func.create(funcname, 'Interpolation');
                model.func(funcname).model('mod1');
                model.func(funcname).name(funcname);
                model.func(funcname).set('funcname', funcname);
                DATA = num2strcell(data);
                model.func(funcname).set('table', DATA);
                model.func(funcname).set('argunit', char(argunit));
                model.func(funcname).set('fununit', char(fununit));
                model.variable(variablesname).set(['D', id], ...
                    [funcname, char("(" + dep + ")/N")], ...
                    ['Diffusion coefficient of ', inp.specnames{i}]);
            case 'Expression'
                dep = temp_data.parameters;
                dep = replace(dep,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);
                fununit = temp_data.unit;
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
                temp = char("("+temp + ")/N");
                model.variable(variablesname).set(['D', id], ...
                    [funcname, temp], ...
                    ['Diffusion coefficient of ', inp.specnames{i}]);

            otherwise
                error(['Data type for diffusion of ', inp.specnames{i}, 'not allowed;']);
        end

    end

    %
    %     % set mobilities
    %     % for all species, except electrons
    for i = 1:inp.Nspec

        if i == inp.eInd
            continue
        end

        if inp.Z(i) == 0
            continue;
        end

        id = num2str(i);
        funcname = ['Fun_Nb', id];

        temp_data = inp.coefficients.("species" + id + "_mobility");
        data_type = temp_data.type;
        data = temp_data.data;

        switch data_type

            case 'Constant'
                unit = temp_data.unit;
                unit = strrep(unit, "eV", "V");

                if data > 0
                    model.variable(variablesname).set(['b', id], ...
                        [num2str(data), '[', char(unit), ']/N'], ...
                        ['Mobility of ', inp.specnames{i}]);
                end

            case 'LUT'
                dep = temp_data.parameters(1);
                if isequal(char(dep), 'E/N')
                    dep='EdN';
                elseif isequal(char(dep), 'L') || isequal(char(dep), 'd')
                    dep='ElecDist';
                elseif isequal(char(dep), 'R')
                    dep='ElecRadius';
                else                     
                end

                argunit = temp_data.units(1);
                argunit = strrep(argunit, "eV", "V");
                fununit = temp_data.units(2);
                fununit = strrep(fununit, "eV", "V");

                model.func.create(funcname, 'Interpolation');
                model.func(funcname).model('mod1');
                model.func(funcname).name(funcname);
                model.func(funcname).set('funcname', funcname);
                DATA = num2strcell(data);
                model.func(funcname).set('table', DATA);
                model.func(funcname).set('argunit', char(argunit));
                model.func(funcname).set('fununit', char(fununit));
                model.variable(variablesname).set(['b', id], ...
                    [funcname, char("(" + dep + ")/N")], ...
                    ['Mobility of ', inp.specnames{i}]);

            case 'Expression'
                dep = temp_data.parameters;
                dep = replace(dep,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);
                fununit = temp_data.unit;
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
                temp = char("("+temp + ")/N");
                model.variable(variablesname).set(['b', id], ...
                    [funcname, temp], ...
                    ['Mobility of ', inp.specnames{i}]);

            otherwise
                error(['Data type for mobility of ', inp.specnames{i}, 'not allowed;']);
        end

    end

    %     % set transport data for electrons
    i = inp.eInd;
    id = num2str(i);

    if strcmp(flags.enFlux, 'DDAn')
        % nue
        funcname = 'Fun_nuedN';

        temp_data = inp.coefficients.("species" + id + "_MomentumDissipationFrequencies");
        data_type = temp_data.type;
        data = temp_data.data;

        switch data_type

            case 'LUT'
                dep = temp_data.parameters(1);
                if isequal(char(dep), 'E/N')
                    dep='EdN';
                elseif isequal(char(dep), 'L') || isequal(char(dep), 'd')
                    dep='ElecDist';
                elseif isequal(char(dep), 'R')
                    dep='ElecRadius';
                else                     
                end
                
                argunit = temp_data.units(1);
                argunit = strrep(argunit, "eV", "V");
                fununit = temp_data.units(2);
                fununit = strrep(fununit, "eV", "V");

                model.func.create(funcname, 'Interpolation');
                model.func(funcname).model('mod1');
                model.func(funcname).name(funcname);
                model.func(funcname).set('funcname', funcname);
                DATA = num2strcell(data);
                model.func(funcname).set('table', DATA);
                model.func(funcname).set('argunit', char(argunit));
                model.func(funcname).set('fununit', char(fununit));
                model.variable(variablesname).set(['nue'], ...
                    [funcname, char("(" + dep + ")*N")], ...
                    ['Momentum dissipation frequency of ', inp.specnames{i}]);

            case 'Expression'
                dep = temp_data.parameters;
                dep = replace(dep,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);
                fununit = temp_data.unit;
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
                temp = char("("+temp + ")*N");
                model.variable(variablesname).set(['nue'], ...
                    [funcname, temp], ...
                    ['Momentum dissipation frequency of ', inp.specnames{i}]);

            otherwise
                error(['Data type for momentum dissipation frequency of ', inp.specnames{i}, 'not allowed']);
        end

        % nueps
        funcname = 'Fun_nuepsdN';

        temp_data = inp.coefficients.("species" + id + "_EnergyFluxDissipationFrequencies");
        data_type = temp_data.type;
        data = temp_data.data;

        switch data_type

            case 'LUT'
                dep = temp_data.parameters(1);
                if isequal(char(dep), 'E/N')
                    dep='EdN';
                elseif isequal(char(dep), 'L') || isequal(char(dep), 'd')
                    dep='ElecDist';
                elseif isequal(char(dep), 'R')
                    dep='ElecRadius';
                else                     
                end               
                argunit = temp_data.units(1);
                argunit = strrep(argunit, "eV", "V");
                fununit = temp_data.units(2);
                fununit = strrep(fununit, "eV", "V");

                model.func.create(funcname, 'Interpolation');
                model.func(funcname).model('mod1');
                model.func(funcname).name(funcname);
                model.func(funcname).set('funcname', funcname);
                DATA = num2strcell(data);
                model.func(funcname).set('table', DATA);
                model.func(funcname).set('argunit', char(argunit));
                model.func(funcname).set('fununit', char(fununit));
                model.variable(variablesname).set(['nueps'], ...
                    [funcname, char("(" + dep + ")*N")], ...
                    ['Energy flux dissipation frequency of ', inp.specnames{i}]);

            case 'Expression'
                dep = temp_data.parameters;
                dep = replace(dep,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);
                fununit = temp_data.unit;
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
                temp = char("("+temp + ")*N");
                model.variable(variablesname).set(['nueps'], ...
                    [funcname, temp], ...
                    ['Energy flux dissipation frequency of ', inp.specnames{i}]);

            otherwise
                error(['Data type for energy flux dissipation frequency of ', inp.specnames{i}, 'not allowed']);
        end

        % xi0
        funcname = 'Fun_xi0';

        temp_data = inp.coefficients.("species" + id + "_TransportCoefficient_0");
        data_type = temp_data.type;
        data = temp_data.data;

        switch data_type

            case 'LUT'
                dep = temp_data.parameters(1);
                if isequal(char(dep), 'E/N')
                    dep='EdN';
                elseif isequal(char(dep), 'L') || isequal(char(dep), 'd')
                    dep='ElecDist';
                elseif isequal(char(dep), 'R')
                    dep='ElecRadius';
                else                     
                end               
                argunit = temp_data.units(1);
                argunit = strrep(argunit, "eV", "V");
                fununit = temp_data.units(2);
                fununit = strrep(fununit, "eV", "V");

                model.func.create(funcname, 'Interpolation');
                model.func(funcname).model('mod1');
                model.func(funcname).name(funcname);
                model.func(funcname).set('funcname', funcname);
                DATA = num2strcell(data);
                model.func(funcname).set('table', DATA);
                model.func(funcname).set('argunit', char(argunit));
                model.func(funcname).set('fununit', char(fununit));
                model.variable(variablesname).set(['xi0'], ...
                    [funcname, char("(" + dep + ")")], ...
                    ['Transport coefficient 0 of ', inp.specnames{i}]);

            case 'Expression'
                dep = temp_data.parameters;
                dep = replace(dep,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);
                fununit = temp_data.unit;
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
                model.variable(variablesname).set(['xi0'], ...
                    [funcname, temp], ...
                    ['Transport coefficient 0 of ', inp.specnames{i}]);

            otherwise
                error(['Data type for transport coefficient 0 of ', inp.specnames{i}, 'not allowed']);
        end

        % xi2
        funcname = 'Fun_xi2';

        temp_data = inp.coefficients.("species" + id + "_TransportCoefficient_2");
        data_type = temp_data.type;
        data = temp_data.data;

        switch data_type

            case 'LUT'
                dep = temp_data.parameters(1);
                if isequal(char(dep), 'E/N')
                    dep='EdN';
                elseif isequal(char(dep), 'L') || isequal(char(dep), 'd')
                    dep='ElecDist';
                elseif isequal(char(dep), 'R')
                    dep='ElecRadius';
                else                     
                end              
                argunit = temp_data.units(1);
                argunit = strrep(argunit, "eV", "V");
                fununit = temp_data.units(2);
                fununit = strrep(fununit, "eV", "V");

                model.func.create(funcname, 'Interpolation');
                model.func(funcname).model('mod1');
                model.func(funcname).name(funcname);
                model.func(funcname).set('funcname', funcname);
                DATA = num2strcell(data);
                model.func(funcname).set('table', DATA);
                model.func(funcname).set('argunit', char(argunit));
                model.func(funcname).set('fununit', char(fununit));
                model.variable(variablesname).set(['xi2'], ...
                    [funcname, char("(" + dep + ")")], ...
                    ['Transport coefficient 2 of ', inp.specnames{i}]);

            case 'Expression'
                dep = temp_data.parameters;
                dep = replace(dep,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);
                fununit = temp_data.unit;
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
                model.variable(variablesname).set(['xi2'], ...
                    [funcname, temp], ...
                    ['Transport coefficient 2 of ', inp.specnames{i}]);

            otherwise
                error(['Data type for transport coefficient 2 of ', inp.specnames{i}, 'not allowed']);
        end

        % xi0eps
        funcname = 'Fun_xi0eps';

        temp_data = inp.coefficients.("species" + id + "_EnergyTransportCoefficient_0");
        data_type = temp_data.type;
        data = temp_data.data;

        switch data_type

            case 'LUT'
                dep = temp_data.parameters(1);
                if isequal(char(dep), 'E/N')
                    dep='EdN';
                elseif isequal(char(dep), 'L') || isequal(char(dep), 'd')
                    dep='ElecDist';
                elseif isequal(char(dep), 'R')
                    dep='ElecRadius';
                else                     
                end               
                argunit = temp_data.units(1);
                argunit = strrep(argunit, "eV", "V");
                fununit = temp_data.units(2);
                fununit = strrep(fununit, "eV", "V");

                model.func.create(funcname, 'Interpolation');
                model.func(funcname).model('mod1');
                model.func(funcname).name(funcname);
                model.func(funcname).set('funcname', funcname);
                DATA = num2strcell(data);
                model.func(funcname).set('table', DATA);
                model.func(funcname).set('argunit', char(argunit));
                model.func(funcname).set('fununit', char(fununit));
                model.variable(variablesname).set(['xi0eps'], ...
                    [funcname, char("(" + dep + ")")], ...
                    ['Energy transport coefficient 0 of ', inp.specnames{i}]);

            case 'Expression'
                dep = temp_data.parameters;
                dep = replace(dep,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);
                fununit = temp_data.unit;
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
                model.variable(variablesname).set(['xi0eps'], ...
                    [funcname, temp], ...
                    ['Energy transport coefficient 0 of ', inp.specnames{i}]);

            otherwise
                error(['Data type for energy transport coefficient 0 of ', inp.specnames{i}, 'not allowed']);
        end

        % xi2eps
        funcname = 'Fun_xi2eps';
        temp_data = inp.coefficients.("species" + id + "_EnergyTransportCoefficient_2");
        data_type = temp_data.type;
        data = temp_data.data;

        switch data_type

            case 'LUT'
                dep = temp_data.parameters(1);
                if isequal(char(dep), 'E/N')
                    dep='EdN';
                elseif isequal(char(dep), 'L') || isequal(char(dep), 'd')
                    dep='ElecDist';
                elseif isequal(char(dep), 'R')
                    dep='ElecRadius';
                else                     
                end               
                argunit = temp_data.units(1);
                argunit = strrep(argunit, "eV", "V");
                fununit = temp_data.units(2);
                fununit = strrep(fununit, "eV", "V");

                model.func.create(funcname, 'Interpolation');
                model.func(funcname).model('mod1');
                model.func(funcname).name(funcname);
                model.func(funcname).set('funcname', funcname);
                DATA = num2strcell(data);
                model.func(funcname).set('table', DATA);
                model.func(funcname).set('argunit', char(argunit));
                model.func(funcname).set('fununit', char(fununit));
                model.variable(variablesname).set(['xi2eps'], ...
                    [funcname, char("(" + dep + ")")], ...
                    ['Energy transport coefficient 2 of ', inp.specnames{i}]);

            case 'Expression'
                dep = temp_data.parameters;
                dep = replace(dep,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);
                fununit = temp_data.unit;
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
                model.variable(variablesname).set(['xi2eps'], ...
                    [funcname, temp], ...
                    ['Energy transport coefficient 2 of ', inp.specnames{i}]);

            otherwise
                error(['Data type for energy transport coefficient 2 of ', inp.specnames{i}, 'not allowed']);
        end

    else
        % diffusion coefficient
        funcname = ['Fun_ND', id];

        temp_data = inp.coefficients.("species" + id + "_diffusion");
        data_type = temp_data.type;

        if strcmp(data_type, 'Einstein') == 0
            data = temp_data.data;
        end

        switch data_type

            case 'Constant'
                unit = temp_data.unit;
                unit = strrep(unit, "eV", "V");

                if data > 0
                    model.variable(variablesname).set(['D', id], ...
                        [num2str(data), '[', char(unit), ']/N'], ...
                        ['Diffusion coefficient of ', inp.specnames{i}]);
                end

            case 'Einstein'
                model.variable(variablesname).set(['D', id], ...
                    ['kB/e0*T', id, '*b', id], ...
                    ['Diffusion coefficient of ', inp.specnames{i}]);
            case 'LUT'
                dep = temp_data.parameters(1);
                if isequal(char(dep), 'E/N')
                    dep='EdN';
                elseif isequal(char(dep), 'L') || isequal(char(dep), 'd')
                    dep='ElecDist';
                elseif isequal(char(dep), 'R')
                    dep='ElecRadius';
                else                     
                end               
                argunit = temp_data.units(1);
                argunit = strrep(argunit, "eV", "V");
                fununit = temp_data.units(2);
                fununit = strrep(fununit, "eV", "V");

                model.func.create(funcname, 'Interpolation');
                model.func(funcname).model('mod1');
                model.func(funcname).name(funcname);
                model.func(funcname).set('funcname', funcname);
                DATA = num2strcell(data);
                model.func(funcname).set('table', DATA);
                model.func(funcname).set('argunit', char(argunit));
                model.func(funcname).set('fununit', char(fununit));
                model.variable(variablesname).set(['D', id], ...
                    [funcname, char("(" + dep + ")/N")], ...
                    ['Diffusion coefficient of ', inp.specnames{i}]);
            case 'Expression'
                dep = temp_data.parameters;
                dep = replace(dep,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);
                fununit = temp_data.unit;
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
                temp = char("("+temp + ")/N");
                model.variable(variablesname).set(['D', id], ...
                    [funcname, temp], ...
                    ['Diffusion coefficient of ', inp.specnames{i}]);

            otherwise
                error(['Data type for diffusion of ', inp.specnames{i}, 'not allowed;']);
        end

        % mobility
        funcname = ['Fun_Nb', id];

        temp_data = inp.coefficients.("species" + id + "_mobility");
        data_type = temp_data.type;
        data = temp_data.data;

        switch data_type

            case 'Constant'
                unit = temp_data.unit;
                unit = strrep(unit, "eV", "V");

                if data > 0
                    model.variable(variablesname).set(['b', id], ...
                        [num2str(data), '[', char(unit), ']/N'], ...
                        ['Mobility of ', inp.specnames{i}]);
                end

            case 'LUT'
                dep = temp_data.parameters(1);
                if isequal(char(dep), 'E/N')
                    dep='EdN';
                elseif isequal(char(dep), 'L') || isequal(char(dep), 'd')
                    dep='ElecDist';
                elseif isequal(char(dep), 'R')
                    dep='ElecRadius';
                else                     
                end              
                argunit = temp_data.units(1);
                argunit = strrep(argunit, "eV", "V");
                fununit = temp_data.units(2);
                fununit = strrep(fununit, "eV", "V");

                model.func.create(funcname, 'Interpolation');
                model.func(funcname).model('mod1');
                model.func(funcname).name(funcname);
                model.func(funcname).set('funcname', funcname);
                DATA = num2strcell(data);
                model.func(funcname).set('table', DATA);
                model.func(funcname).set('argunit', char(argunit));
                model.func(funcname).set('fununit', char(fununit));
                model.variable(variablesname).set(['b', id], ...
                    [funcname, char("(" + dep + ")/N")], ...
                    ['Mobility of ', inp.specnames{i}]);

            case 'Expression'
                dep = temp_data.parameters;
                dep = replace(dep,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);
                fununit = temp_data.unit;
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
                temp = char("("+temp + ")/N");
                model.variable(variablesname).set(['b', id], ...
                    [funcname, temp], ...
                    ['Mobility of ', inp.specnames{i}]);

            otherwise
                error(['Data type for mobility of ', inp.specnames{i}, 'not allowed;']);
        end

        % set diffusion coefficient for electron energy

        if strcmp(flags.enFlux, 'DDA53')
            model.variable(variablesname).set('Deps', ['5/3*D', num2str(inp.eInd)], ...
            'Electron energy diffusion');
        elseif strcmp(flags.enFlux, 'DDAc')

            funcname = 'Fun_NDdUmEps';

            temp_data = inp.coefficients.("species" + id + "_EnergyDiffusion_dUmean");
            data_type = temp_data.type;
            data = temp_data.data;

            switch data_type

                case 'LUT'
                    dep = temp_data.parameters(1);
                    if isequal(char(dep), 'E/N')
                        dep='EdN';
                    elseif isequal(char(dep), 'L') || isequal(char(dep), 'd')
                        dep='ElecDist';
                    elseif isequal(char(dep), 'R')
                        dep='ElecRadius';
                    else                     
                    end                  
                    argunit = temp_data.units(1);
                    argunit = strrep(argunit, "eV", "V");
                    fununit = temp_data.units(2);
                    fununit = strrep(fununit, "eV", "V");

                    model.func.create(funcname, 'Interpolation');
                    model.func(funcname).model('mod1');
                    model.func(funcname).name(funcname);
                    model.func(funcname).set('funcname', funcname);
                    DATA = num2strcell(data);
                    model.func(funcname).set('table', DATA);
                    model.func(funcname).set('argunit', char(argunit));
                    model.func(funcname).set('fununit', char(fununit));
                    model.variable(variablesname).set(['Deps'], ...
                        [funcname, char("(" + dep + ")/N")], ...
                        ['Electron energy diffusion coefficient']);

                case 'Expression'
                    dep = temp_data.parameters;
                    dep = replace(dep,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);
                    fununit = temp_data.unit;
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
                    temp = char("("+temp + ")/N");
                    model.variable(variablesname).set(['Deps'], ...
                        [funcname, temp], ...
                        ['Electron energy diffusion coefficient']);
                otherwise
                    error(['Data type for electron energy diffusion coefficient not allowed;']);
            end

        else
            error(['wrong flag for electron energy flux (flags.enFlux): ' flags.enFlux]);
        end

        % set mobiity for electron energy

        if strcmp(flags.enFlux, 'DDA53')
            model.variable(variablesname).set('beps', ['5/3*b', num2str(inp.eInd)], ...
            'Electron energy mobility');
        elseif strcmp(flags.enFlux, 'DDAc')

            funcname = 'Fun_NbdUmEps';

            temp_data = inp.coefficients.("species" + id + "_EnergyMobility_dUmean");
            data_type = temp_data.type;
            data = temp_data.data;

            switch data_type

                case 'LUT'
                    dep = temp_data.parameters(1);
                    if isequal(char(dep), 'E/N')
                        dep='EdN';
                    elseif isequal(char(dep), 'L') || isequal(char(dep), 'd')
                        dep='ElecDist';
                    elseif isequal(char(dep), 'R')
                        dep='ElecRadius';
                    else                     
                    end 
                    argunit = temp_data.units(1);
                    argunit = strrep(argunit, "eV", "V");
                    fununit = temp_data.units(2);
                    fununit = strrep(fununit, "eV", "V");

                    model.func.create(funcname, 'Interpolation');
                    model.func(funcname).model('mod1');
                    model.func(funcname).name(funcname);
                    model.func(funcname).set('funcname', funcname);
                    DATA = num2strcell(data);
                    model.func(funcname).set('table', DATA);
                    model.func(funcname).set('argunit', char(argunit));
                    model.func(funcname).set('fununit', char(fununit));
                    model.variable(variablesname).set(['beps'], ...
                        [funcname, char("(" + dep + ")/N")], ...
                        ['Electron energy mobility']);

                case 'Expression'
                    dep = temp_data.parameters;
                    dep = replace(dep,["eV", "L", "d", "R"], ["V", "ElecDist", "ElecDist", "R"]);
                    fununit = temp_data.unit;
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
                    temp = char("("+temp + ")/N");
                    model.variable(variablesname).set(['beps'], ...
                        [funcname, temp], ...
                        ['Electron energy mobility']);
                otherwise
                    error(['Data type for electron energy mobility not allowed;']);
            end

        else
            error(['wrong flag for electron energy flux (flags.enFlux): ' flags.enFlux]);
        end

        msg(2, ['model for electron energy flux: ' flags.enFlux], flags)
    end
end