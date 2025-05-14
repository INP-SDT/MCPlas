function SetSources(inp, flags, model, GeomName)
%
% SetSources function uses functions specific for Live link for MATLAB module to set
% source term for balance equation for each species in Comsol model 
%
% :param inp: the first input
% :param model: the second input
% :param GeonName: the third input

    msg(1, 'setting sources', flags);
    variablesname = 'sources';
    model.variable.create(variablesname);
    model.variable(variablesname).model('mod1');
    model.variable(variablesname).name('Source terms');
    model.variable(variablesname).selection.named('plasmadomain');

    %% Set source term for balance equation for all species 

    for i = 1:inp.Nspec

        id = num2str(i);
        S = [];

        % Define gain
        tmp = find(inp.ReacGain(:, i) ~= 0);

        for j = 1:length(tmp)
            id_1 = num2str(tmp(j));

            if length(S) > 0
                S = [S, '+'];
            end

            if inp.ReacGain(tmp(j), i) == 1
                S = [S, 'R', id_1];
            else
                S = [S, num2str(inp.ReacGain(tmp(j), i)), '*R', id_1];
            end

        end

        % Define loss
        tmp = find(inp.ReacLoss(:, i) ~= 0);

        for j = 1:length(tmp)
            id_1 = num2str(tmp(j));

            if length(S) > 0
                S = [S, '-'];
            end

            if inp.ReacLoss(tmp(j), i) == 1
                S = [S, 'R', id_1];
            else
                S = [S, num2str(inp.ReacLoss(tmp(j), i)), '*R', id_1];
            end

        end

        if length(S) == 0
            S = '0[m^-3*s^-1]';
        end

        % Set source term
        model.variable(variablesname).set(['S', id], S, ['Source term for species ', inp.specnames{i}]);

    end

    %% Set source term for electron energy balance

    % Define  power input from the electric field
    if length(strfind(GeomName, 'Geom1D')) > 0
        S = ['Phiz*F', num2str(inp.eInd), '_z'];
    elseif length(strfind(GeomName, 'Geom1p5D')) > 0
        S = ['Phir*F', num2str(inp.eInd), '_r'];
    elseif length(strfind(GeomName, 'Geom2D')) > 0
        S = ['Phix*F', num2str(inp.eInd), '_x+Phiy*F', num2str(inp.eInd), '_y'];
    elseif length(strfind(GeomName, 'Geom2p5D')) > 0
        S = ['Phir*F', num2str(inp.eInd), '_r+Phiz*F', num2str(inp.eInd), '_z'];
    else
        error('invalid value of GeomName in SetSources.m');
    end
    
    % Define  power input from the electric field
    for i = inp.ele_processes
        id_1 = num2str(i);
        S = [S, '+Rene', id_1];
    end
    
    % Set source term
    model.variable(variablesname).set('Seps', S, ...
    'Source term for electron energy balance');

end
