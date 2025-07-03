function SetSources(inp, flags, model)
    %
    % SetSources function uses functions specific for the LiveLink
    % for MATLAB module to set the source term for the number density balance
    % equation for each species in the COMSOL model.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input
    
    msg(1, 'Setting sources', flags);  % Display status message
    
    variablesname = 'sources';
    model.variable.create(variablesname);  % Create a variable node with the tag 
                                           % name "sources" in the COMSOL model tree.
    model.variable(variablesname).model('mod1');  % Add the model tag
    model.variable(variablesname).name('Source terms');  % Define the node name
    model.variable(variablesname).selection.named('plasmadomain');  % Specify domain (domain name must be defined
                                                                    % in the SetSection.m file)

    %% ==================================================================================
    % === Set the source term for the number density balance equation for all species ===
    % ===================================================================================
    
    for i = 1:inp.Nspec
        id = num2str(i);
        S = [];
        
        % Define the species gain in the source term
        % -------------------------------------------
       
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
        
        % Define the species loss in the source term
        % ------------------------------------------
        
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
        model.variable(variablesname).set(['S', id], S, ...
            ['Source term for species ', inp.specnames{i}]);  % Set the source term in a variable
                                                              % node with the tag name "sources"
                                                              % in the COMSOL model tree
    end
    
    %% ==========================================================
    % === Set the source term for the electron energy balance ===
    % ===========================================================
    
    % Define the power input from the electric field
    if length(strfind(inp.GeomName, 'Geom1D')) > 0  % Case: 1D Cartesian coordinates
        S = ['Phiz*F', num2str(inp.eInd), '_z'];
    elseif length(strfind(inp.GeomName, 'Geom1p5D')) > 0  % Case: 1D polar coordinates
        S = ['Phir*F', num2str(inp.eInd), '_r'];
    elseif length(strfind(inp.GeomName, 'Geom2D')) > 0  % Case: 2D Cartesian coordinates
        S = ['Phix*F', num2str(inp.eInd), '_x + Phiy*F', ...
            num2str(inp.eInd), '_y'];
    elseif length(strfind(inp.GeomName, 'Geom2p5D')) > 0  % Case: 2D cylindrical coordinates
        S = ['Phir*F', num2str(inp.eInd), '_r + Phiz*F', ...
            num2str(inp.eInd), '_z'];
    else
        error('Invalid value of GeomName in SetSources.m');
    end
    
    for i = inp.ele_processes
        id_1 = num2str(i);
        S = [S, '+Rene', id_1];  % Define the total source term for the electron energy 
                                 % balance equation
    end
    
    model.variable(variablesname).set('Seps', S, ...
        'Source term for the electron energy balance');  % Set the source term for electron
                                                         % energy balance equation in a variable
                                                         % node with the tag name "sources"
                                                         % in the COMSOL model tree
end