function SetFluxes(inp, flags, model)
    %
    % SetFluxes function uses functions specific for the LiveLink for
    % MATLAB module to set the species fluxes in the COMSOL model.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input
    
    msg(1, 'Setting fluxes', flags);  % Display status message
    
    variablesname = 'fluxes';
    model.variable.create(variablesname);  % Create a variable node with the tag name "fluxes" 
                                           % in the COMSOL model tree
    model.variable(variablesname).model('mod1');  % Add the model tag
    model.variable(variablesname).name('Fluxes');  % Define the node name
    model.variable(variablesname).selection.named('plasmadomain');  % Specify domain (domain name must be
                                                                    % defined in the SetSection.m file)
    variablesname = 'bndfluxes';
    model.variable.create(variablesname);  % Create a variable node with the tag name "bndfluxes" 
                                           % in the COMSOL model tree
    model.variable(variablesname).model('mod1');  % Add the model tag
    model.variable(variablesname).name('Boundary fluxes');  % Define the node name
    model.variable(variablesname).selection.named('plasmaboundaries');  % Specify domain (domain name must be
                                                                        % defined in the SetSection.m file)
    transpexpr = mphgetexpressions(model.variable('transportcoeffs'));  % Load expressions for 
                                                                        % transport coefficients to check 
                                                                        % for zero diffusion
    
    %% ==============================================================
    % === Set species fluxes for 1D case in Cartesian coordinates ===
    % ===============================================================
    
    if length(strfind(inp.GeomName, 'Geom1D')) > 0
        coord = 'z';
        SetDriftVelocity(transpexpr, coord, inp, flags, model);  % Set drift velocity
        SetSpeciesFlux(transpexpr, coord, inp, flags, model);  % Set species fluxes
        SetBoundaryFluxes(transpexpr, coord, inp, model);  % Set species boundary fluxes
    
    %% ==========================================================
    % === Set species fluxes for 1D case in polar coordinates ===
    % ===========================================================
    
    elseif length(strfind(inp.GeomName, 'Geom1p5D')) > 0
        coord = 'r';
        SetDriftVelocity(transpexpr, coord, inp, flags, model);  % Set drift velocity
        SetSpeciesFlux(transpexpr, coord, inp, flags, model);  % Set species fluxes
        SetBoundaryFluxes(transpexpr, coord, inp, model);  % Set species boundary fluxes
    
    %% ==============================================================
    % === Set species fluxes for 2D case in Cartesian coordinates ===
    % ===============================================================
    
    elseif length(strfind(inp.GeomName, 'Geom2D')) > 0
        coord = ['x'; 'y'];
        SetDriftVelocity(transpexpr, coord, inp, flags, model);  % Set drift velocity
        SetSpeciesFlux(transpexpr, coord, inp, flags, model);  % Set species fluxes
        SetBoundaryFluxes(transpexpr, coord, inp, model);  % Set species boundary fluxes
    
    %% ================================================================
    % === Set species fluxes for 2D case in cylindrical coordinates ===
    % =================================================================
    
    elseif length(strfind(inp.GeomName, 'Geom2p5D')) > 0
        coord = ['r'; 'z'];
        SetDriftVelocity(transpexpr, coord, inp, flags, model);  % Set drift velocity
        SetSpeciesFlux(transpexpr, coord, inp, flags, model);  % Set species fluxes
        SetBoundaryFluxes(transpexpr, coord, inp, model);  % Set species boundary fluxes
    
    else
        error(['Geometry name ', inp.GeomName, ' not allowed.']);
    end
end

% --------------------------------------------------------------
function SetDriftVelocity(transpexpr, coord, inp, flags, model)
% --------------------------------------------------------------
    %
    % SetDriftVelocity function employs functions specific for the Live Link
    % for MATLAB module to set the drift velocities of species in the COMSOL model.
    %
    % :param transpexpr: the first input
    % :param coord: the second input
    % :param inp: the third input
    % :param flags: the fourth input
    % :param model: the fifth input    
   
    variablesname = 'specprop';
    
    % Set the drift velocity for all species, except the electron
    % -----------------------------------------------------------
    
    for i = 1:inp.Nspec
        if i == inp.eInd
            continue;
        end
        id = num2str(i);
        if flags.nojac > 0  % With "nojac" operator
            b = ['nojac(b' id ')'];
        else  % Without "nojac" operator 
            b = ['b' id];
        end
        if length(coord) == 1  % Case: 1D Cartesian (x-axis) or polar (r-axis) coordinates
            if sign(inp.Z(i)) > 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['b', id]) == 1)) > 0
                model.variable(variablesname).set(['V', id, '_', coord], ...
                    ['-', b, '*Phi', coord]);  % Set the drift velocity in a variable node with
                                               % the tag name "specprop" in the COMSOL model tree
            elseif sign(inp.Z(i)) < 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['b', id]) == 1)) > 0
                model.variable(variablesname).set(['V', id, '_', coord], ...
                    [b, '*Phi', coord]);  % Set the drift velocity in a variable node with
                                          % the tag name "specprop" in the COMSOL model tree
            end
        else  % Case: 2D Cartesian (x-axis and y-axis) or cylindrical (r-axis and z-axis) coordinates
            if sign(inp.Z(i)) > 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['b', id]) == 1)) > 0
                model.variable(variablesname).set(['V', id, '_', coord(2)], ...
                    ['-', b, '*Phi', coord(2)]);  % Set component (y or z) of 
                                                  % the drift velocity vector in a variable
                                                  % node with the tag name "specprop" in
                                                  % the COMSOL model tree
                model.variable(variablesname).set(['V', id, '_', coord(1)], ...
                    ['-', b, '*Phi', coord(1)]);  % Set vector component (x or r) of 
                                                  % the drift velocity vector in a variable
                                                  % node with the tag name "specprop" in
                                                  % the COMSOL model tree
            elseif sign(inp.Z(i)) < 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['b', id]) == 1)) > 0
                model.variable(variablesname).set(['V', id, '_', coord(2)], ...
                    [b, '*Phi', coord(2)]);  % Set component (y or z) of 
                                             % the drift velocity vector in a variable
                                             % node with the tag name "specprop" in
                                             % the COMSOL model tree
                model.variable(variablesname).set(['V', id, '_', coord(1)], ...
                    [b, '*Phi', coord(1)]);  % Set vector component (x or r) of 
                                             % the drift velocity vector in a variable
                                             % node with the tag name "specprop" in
                                             % the COMSOL model tree
            end
        end
    end

    % Set the drift velocity for electron
    % ---------------------------------------
    
    i = inp.eInd;
    id = num2str(i);
    if strcmp(flags.enFlux, 'DDAn')  % Case: DDAn 
        if flags.nojac > 0  % With "nojac" operator
            b = 'nojac(e0/(me*nue))';
        else  % Without "nojac" operator 
            b = 'e0/(me*nue)';
        end
        if length(coord) == 1  % Cartesian (x-axis) or polar (r-axis) coordinates
            model.variable(variablesname).set(['V', id, '_', coord], ...
                [b, '*Phi', coord]);  % Set electron drift velocity in a variable node with
                                      % the tag name "specprop" in the COMSOL model tree
        else  % Cartesian (x-axis and y-axis) or cylindrical (r-axis and z-axis) coordinates
            model.variable(variablesname).set(['V', id, '_', coord(2)], ...
                [b, '*Phi', coord(2)]);  % Set component (y or z) of 
                                         % electron drift velocity vector in a variable
                                         % node with the tag name "specprop" in
                                         % the COMSOL model tree
            model.variable(variablesname).set(['V', id, '_', coord(1)], ...
                [b, '*Phi', coord(1)]);  % Set vector component (x or r) of 
                                         % electron drift velocity vector in a variable
                                         % node with the tag name "specprop" in
                                         % the COMSOL model tree
        end
    else  % Case: DDAc and DDA53 
        if flags.nojac > 0  % With "nojac" operator
            b = ['nojac(b' id ')'];
        else  % Without "nojac" operator 
            b = ['b' id];
        end
        if length(coord) == 1  % 1D Cartesian (x-axis) or polar (r-axis) coordinates
            model.variable(variablesname).set(['V', id, '_', coord], ...
                [b, '*Phi', coord]);  % Set electron drift velocity in a variable node with
                                      % the tag name "specprop" in the COMSOL model tree
        else  % 2D Cartesian (x-axis and y-axis) or cylindrical (r-axis and z-axis) coordinates
            model.variable(variablesname).set(['V', id, '_', coord(2)], ...
                [b, '*Phi', coord(2)]);  % Set component (y or z) of 
                                         % electron drift velocity vector in a variable
                                         % node with the tag name "specprop" in
                                         % the COMSOL model tree            
            model.variable(variablesname).set(['V', id, '_', coord(1)], ...
                [b, '*Phi', coord(1)]);  % Set vector component (x or r) of 
                                         % electron drift velocity vector in a variable
                                         % node with the tag name "specprop" in
                                         % the COMSOL model tree

        end
    end

    % Set the drift velocity for electron energy
    % ------------------------------------------
    
    if strcmp(flags.enFlux, 'DDAn')  % Case: DDAn
        if length(coord) == 1  % 1D Cartesian (x-axis) or polar (r-axis) coordinates
            if flags.nojac > 0  % With "nojac" operator
                model.variable(variablesname).set(['Veps_', coord], ...
                    ['nojac(e0/(me*nueps)*(5/3+2/3*xi2/xi0))*Phi', coord]);  % Set electron energy drift velocity
                                                                             % in a variable node with the tag name "specprop"
                                                                             % in the COMSOL model tree
            else  % Without "nojac" operator
                model.variable(variablesname).set(['Veps_', coord], ...
                    ['e0/(me*nueps)*(5/3+2/3*xi2/xi0)*Phi', coord]);  % Set electron energy drift velocity
                                                                      % in a variable node with the tag name "specprop"
                                                                      % in the COMSOL model tree
            end
        else  % 2D Cartesian (x-axis and y-axis) or cylindrical (r-axis and z-axis) coordinates
            if flags.nojac > 0  % With "nojac" operator
                model.variable(variablesname).set(['Veps_', coord(2)], ...
                    ['nojac(e0/(me*nueps)*(5/3+2/3*xi2/xi0))*Phi', coord(2)]);  % Set component (y or z) of 
                                                                                % electron energy drift velocity vector
                                                                                % in a variable node with the tag name 
                                                                                % "specprop" in the COMSOL model tree                 
                model.variable(variablesname).set(['Veps_', coord(1)], ...
                    ['nojac(e0/(me*nueps)*(5/3+2/3*xi2/xi0))*Phi', coord(1)]);  % Set vector component (x or r) of 
                                                                                % electron energy drift velocity vector
                                                                                % in a variable node with the tag name 
                                                                                % "specprop" in the COMSOL model tree

            else  % Without "nojac" operator
                model.variable(variablesname).set(['Veps_', coord(2)], ...
                    ['e0/(me*nueps)*(5/3+2/3*xi2/xi0)*Phi', coord(2)]);  % Set component (y or z) of 
                                                                         % electron energy drift velocity vector
                                                                         % in a variable node with the tag name 
                                                                         % "specprop" in the COMSOL model tree                
                model.variable(variablesname).set(['Veps_', coord(1)], ...
                    ['e0/(me*nueps)*(5/3+2/3*xi2/xi0)*Phi', coord(1)]);  % Set vector component (x or r) of 
                                                                         % electron energy drift velocity vector
                                                                         % in a variable node with the tag name 
                                                                         % "specprop" in the COMSOL model tree

            end
        end
    else  % Case: DDAc and DDA53
        if length(coord) == 1  % 1D Cartesian (x-axis) or polar (r-axis) coordinates
            if flags.nojac > 0  % With "nojac" operator
                model.variable(variablesname).set(['Veps_', coord], ...
                    ['nojac(beps)*Phi', coord]);  % Set electron energy drift velocity
                                                  % in a variable node with the tag name "specprop"
                                                  % in the COMSOL model tree
            else  % Without "nojac" operator
                model.variable(variablesname).set(['Veps_', coord], ...
                    ['beps*Phi', coord]);  % Set electron energy drift velocity
                                           % in a variable node with the tag name "specprop"
                                           % in the COMSOL model tree
            end
        else  % 2D Cartesian (x-axis and y-axis) or cylindrical (r-axis and z-axis) coordinates
            if flags.nojac > 0  % With "nojac" operator
                model.variable(variablesname).set(['Veps_', coord(2)], ...
                    ['nojac(beps)*Phi', coord(2)]);  % Set component (y or z) of 
                                                     % electron energy drift velocity vector
                                                     % in a variable node with the tag name 
                                                     % "specprop" in the COMSOL model tree
                model.variable(variablesname).set(['Veps_', coord(1)], ...
                    ['nojac(beps)*Phi', coord(1)]);  % Set vector component (x or r) of 
                                                     % electron energy drift velocity vector
                                                     % in a variable node with the tag name 
                                                     % "specprop" in the COMSOL model tree                                                    
            else  % Without "nojac" operator
                model.variable(variablesname).set(['Veps_', coord(2)], ...
                    ['beps*Phi', coord(2)]);  % Set component (y or z) of 
                                              % electron energy drift velocity vector
                                              % in a variable node with the tag name 
                                              % "specprop" in the COMSOL model tree                
                model.variable(variablesname).set(['Veps_', coord(1)], ...
                    ['beps*Phi', coord(1)]);  % Set vector component (x or r) of 
                                              % electron energy drift velocity vector
                                              % in a variable node with the tag name 
                                              % "specprop" in the COMSOL model tree
            end
        end
    end
end

% ------------------------------------------------------------
function SetSpeciesFlux(transpexpr, coord, inp, flags, model)
% ------------------------------------------------------------
    %
    % SetSpeciesFlux function employs functions specific for the Live Link for
    % MATLAB module to set the fluxes of species in the COMSOL model.
    %
    % :param transpexpr: the first input
    % :param coord: the second input
    % :param inp: the third input
    % :param flags: the fourth input
    % :param model: the fifth input

    % Set species fluxes for all species, except electrons
    % ----------------------------------------------------
   
    variablesname = 'fluxes';
    specexpr = mphgetexpressions(model.variable('specprop'));
    
    for i = 1:inp.Nspec
        if i == inp.eInd
            continue;
        end
        id = num2str(i);
        
        if flags.nojac > 0  % With "nojac" operator
            D = ['nojac(D', id, ')'];
        else
            D = ['D', id];
        end
        
        if length(coord) == 1  % Case: 1D Cartesian (x-axis) or polar (r-axis) coordinates
            % Drift + diffusion
            if length(find(strcmp(specexpr(:, 1), ['V', id, '_', coord]) == 1)) > 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_', coord], ...
                    ['-', D, '*d(N', id, ',', coord, ') + V', id, '_', coord, ...
                    '*N', id]);  % Set species flux in a variable node with
                                 % the tag name "fluxes" in the COMSOL model tree
            
            % Only drift
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_', coord]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_', coord], ...
                    ['V', id, '_', coord, '*N', id]);  % Set species flux in 
                                                       % a variable node with
                                                       % the tag name "fluxes" in
                                                       % the COMSOL model tree
            
            % Only diffusion
            elseif length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_', coord], ...
                    ['-', D, '*d(N', id, ',', coord, ')']);  % Set species flux in
                                                             % a variable node with
                                                             % the tag name "fluxes" in
                                                             % the COMSOL model tree
            end
        
        else % Case: 2D cartesian (x-axis and y-axis) or cylindrical (r-axis and z-axis) coordinates
            % Drift + diffusion
            if length(find(strcmp(specexpr(:, 1), ['V', id, '_', coord(1)]) == 1)) > 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_', coord(1)], ...
                    ['-', D, '*d(N', id, ',', coord(1), ') + V', id, ...
                    '_', coord(1), '*N', id]);  % Set component (x or r) of 
                                                % species flux vector in a variable
                                                % node with the tag name "fluxes" 
                                                % in the COMSOL model tree
                model.variable(variablesname).set(['F', id, '_', coord(2)], ...
                    ['-', D, '*d(N', id, ',', coord(2), ') + V', id, ...
                    '_', coord(2), '*N', id]);  % Set component (y or z) of 
                                                % species flux vector in a variable
                                                % node with the tag name "fluxes" 
                                                % in the COMSOL model tree
            
            % Only drift
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_', coord(1)]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_', coord(1)], ...
                    ['V', id, '_', coord(1), '*N', id]);  % Set component (x or r) of 
                                                          % species flux vector in a variable
                                                          % node with the tag name "fluxes" 
                                                          % in the COMSOL model tree
                model.variable(variablesname).set(['F', id, '_', coord(2)], ...
                    ['V', id, '_', coord(2), '*N', id]);  % Set component (y or z) of 
                                                          % species flux vector in a variable
                                                          % node with the tag name "fluxes" 
                                                          % in the COMSOL model tree
            % Only diffusion
            elseif length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_', coord(1)], ...
                    ['-', D, '*d(N', id, ',', coord(1), ')']);  % Set component (x or r) of 
                                                                % species flux vector in a variable
                                                                % node with the tag name "fluxes" 
                                                                % in the COMSOL model tree
                model.variable(variablesname).set(['F', id, '_', coord(2)], ...
                    ['-', D, '*d(N', id, ',', coord(2), ')']);  % Set component (y or z) of 
                                                                % species flux vector in a variable
                                                                % node with the tag name "fluxes" 
                                                                % in the COMSOL model tree
            end           
        end
    end

    % Set flux for electron
    % ---------------------
    
    i = inp.eInd;
    id = num2str(i);
    if strcmp(flags.enFlux, 'DDAn')  % Case: DDAn
        if flags.nojac > 0  % With "nojac" operator
            Douter = 'nojac(e0/(me*nue))';
            Dinner = 'nojac((xi0+xi2))';
        else
            Douter = 'e0/(me*nue)';
            Dinner = '(xi0+xi2)';
        end
        
        if length(coord) == 1  % 1D Cartesian (x-axis) or polar (r-axis) coordinates
            model.variable(variablesname).set(['F', id, '_', coord], ...
                ['-', Douter, '*d(', Dinner, '*N', id, ',', coord, ...
                ') + V', id, '_', coord, '*N', id]);  % Set electron flux in a variable node with
                                                      % the tag name "fluxes" in the COMSOL model tree
        else  % 2D Cartesian (x-axis and y-axis) or cylindrical (r-axis and z-axis) coordinates
            model.variable(variablesname).set(['F', id, '_', coord(1)], ...
                ['-', Douter, '*d(', Dinner, '*N', id, ',', coord(1), ...
                ') + V', id, '_', coord(1), '*N', id]);  % Set component (x or r) of 
                                                         % electron flux vector in a variable
                                                         % node with the tag name "fluxes" 
                                                         % in the COMSOL model tree
            model.variable(variablesname).set(['F', id, '_', coord(2)], ...
                ['-', Douter, '*d(', Dinner, '*N', id, ',', coord(2), ...
                ') + V', id, '_', coord(2), '*N', id]);  % Set component (y or z) of 
                                                         % electron flux vector in a variable
                                                         % node with the tag name "fluxes" 
                                                         % in the COMSOL model tree
        end
    else  % Case: DDAc and DDA53
        if flags.nojac > 0  % With "nojac" operator
            D = ['nojac(D', id, ')'];
        else  % Without "nojac" operator 
            D = ['D', id];
        end
        
        if length(coord) == 1  % 1D Cartesian (x-axis) or polar (r-axis) coordinates
            model.variable(variablesname).set(['F', id, '_', coord], ...
                ['-d(', D, '*N', id, ',', coord, ') + V', id, '_', coord, ...
                '*N', id]);  % Set electron flux in a variable node with
                             % the tag name "fluxes" in the COMSOL model tree
        else  % 2D Cartesian (x-axis and y-axis) or cylindrical (r-axis and z-axis) coordinates
            model.variable(variablesname).set(['F', id, '_', coord(1)], ...
                ['-d(', D, '*N', id, ',', coord(1), ') + V', id, '_', coord(1), ...
                '*N', id]);  % Set component (x or r) of 
                             % electron flux vector in a variable
                             % node with the tag name "fluxes" 
                             % in the COMSOL model tree
            
            model.variable(variablesname).set(['F', id, '_', coord(2)], ...
                ['-d(', D, '*N', id, ',', coord(2), ') + V', id, '_', coord(2), ...
                '*N', id]);  % Set component (y or z) of 
                             % electron flux vector in a variable
                             % node with the tag name "fluxes" 
                             % in the COMSOL model tree
        end
    end

    % Set electron energy flux
    % ------------------------
    
    if strcmp(flags.enFlux, 'DDAn')  % Case: DDAn
        if length(coord) == 1  % 1D Cartesian (x-axis) or polar (r-axis) coordinates
            if flags.nojac > 0  % With "nojac" operator
                model.variable(variablesname).set(['Q_', coord], ...
                    ['-nojac(e0/(me*nueps))*d(nojac((xi0eps+xi2eps))*We,', coord, ...
                    ') + Veps_', coord, '*We']);  % Set electron energy flux in
                                                  % a variable node with
                                                  % the tag name "fluxes"
                                                  % in the COMSOL model tree
            else  % Without "nojac" operator 
                model.variable(variablesname).set(['Q_', coord], ...
                    ['-e0/(me*nueps)*d((xi0eps+xi2eps)*We,', coord, ...
                    ') + Veps_', coord, '*We']);  % Set electron energy flux in
                                                  % a variable node with
                                                  % the tag name "fluxes" 
                                                  % in the COMSOL model tree
            end
        else  % 2D Cartesian (x-axis and y-axis) or cylindrical (r-axis and z-axis) coordinates
            if flags.nojac > 0  % With "nojac" operator
                model.variable(variablesname).set(['Q_', coord(1)], ...
                    ['-nojac(e0/(me*nueps))*d(nojac((xi0eps+xi2eps))*We,', ...
                    coord(1), ') + Veps_', coord(1), '*We']);  % Set component (x or r) of electron
                                                               % energy flux vector in a variable
                                                               % node with the tag name "fluxes" 
                                                               % in the COMSOL model tree
                model.variable(variablesname).set(['Q_', coord(2)], ...
                    ['-nojac(e0/(me*nueps))*d(nojac((xi0eps+xi2eps))*We,', ...
                    coord(2), ') + Veps_', coord(2), '*We']);  % Set component (y or z) of electron
                                                               % energy flux vector in a variable
                                                               % node with the tag name "fluxes" 
                                                               % in the COMSOL model tree
            else  % Without "nojac" operator 
                model.variable(variablesname).set(['Q_', coord(1)], ...
                    ['-e0/(me*nueps)*d((xi0eps+xi2eps)*We,', coord(1), ...
                    ') + Veps_', coord(1), '*We']);  % Set component (x or r) of electron
                                                     % energy flux vector in a variable
                                                     % node with the tag name "fluxes" 
                                                     % in the COMSOL model tree
                model.variable(variablesname).set(['Q_', coord(2)], ...
                    ['-e0/(me*nueps)*d((xi0eps+xi2eps)*We,', coord(2), ...
                    ') + Veps_', coord(2), '*We']);  % Set component (y or z) of electron
                                                     % energy flux vector in a variable
                                                     % node with the tag name "fluxes" 
                                                     % in the COMSOL model tree
            end   
        end            
    else  % Case: DDAc and DDA53
        if length(coord) == 1  % 1D Cartesian (x-axis) or polar (r-axis) coordinates
            if flags.nojac > 0  % With "nojac" operator
                model.variable(variablesname).set(['Q_', coord], ...
                    ['-d(nojac(Deps)*We,', coord, ') + Veps_', coord, ...
                    '*We']);  % Set electron energy flux in a variable node with
                              % the tag name "fluxes" in the COMSOL model tree
            else  % Without "nojac" operator 
                model.variable(variablesname).set(['Q_', coord], ...
                    ['-d(Deps*We,', coord, ') + Veps_', ...
                    coord, '*We']);  % Set electron energy flux in a variable node with
                                     % the tag name "fluxes" in the COMSOL model tree
            end
        else  % 2D Cartesian (x-axis and y-axis) or cylindrical (r-axis and z-axis) coordinates
            if flags.nojac > 0  % With "nojac" operator
                model.variable(variablesname).set(['Q_', coord(1)], ...
                    ['-d(nojac(Deps)*We,', coord(1), ...
                    ') + Veps_', coord(1), '*We']);  % Set component (x or r) of electron
                                                     % energy flux vector in a variable
                                                     % node with the tag name "fluxes" 
                                                     % in the COMSOL model tree
                model.variable(variablesname).set(['Q_', coord(2)], ...
                    ['-d(nojac(Deps)*We,', coord(2), ...
                    ') + Veps_', coord(2), '*We']);  % Set component (y or z) of electron
                                                     % energy flux vector in a variable
                                                     % node with the tag name "fluxes" 
                                                     % in the COMSOL model tree
            else  % Without "nojac" operator 
                model.variable(variablesname).set(['Q_', coord(1)], ...
                    ['-d(Deps*We,', coord(1), ') + Veps_', ...
                    coord(1), '*We']);  % Set component (x or r) of electron
                                        % energy flux vector in a variable
                                        % node with the tag name "fluxes" 
                                        % in the COMSOL model tree
                
                model.variable(variablesname).set(['Q_', coord(2)], ...
                    ['-d(Deps*We,', coord(2), ...
                    ') + Veps_', coord(2), '*We']);  % Set component (y or z) of electron
                                                     % energy flux vector in a variable
                                                     % node with the tag name "fluxes" 
                                                     % in the COMSOL model tree
            end
        end
    end
end

% ------------------------------------------------------------
function SetBoundaryFluxes(transpexpr, coord, inp, model)
% ------------------------------------------------------------
    %
    % BoundaryFluxes function employs functions specific for the Live Link 
    % for MATLAB module to set boundary fluxes of species in the COMSOL model.
    %
    % :param transpexpr: the first input
    % :param coord: the second input
    % :param inp: the third input
    % :param model: the fourth input
    
    variablesname = 'bndfluxes';
    specexpr = mphgetexpressions(model.variable('specprop'));
    
    for i = 1:inp.Nspec
        id = num2str(i);
        
        % Set the boundary flux for all species, except electron
        % -------------------------------------------------------
        
        if i == inp.eInd
            continue;
        end
        
        if length(coord) == 1  % Case: 1D Cartesian (x-axis) or polar (r-axis) coordinates
            
            % Particles with diffusion and drift
            if length(find(strcmp(specexpr(:, 1), ['V', id, '_', coord]) == 1)) > 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(abs(V', id, '_', coord, ...
                    '*eq', id, '.n', coord, '*N', id, ') + 0.5*vth', id, ...
                    '*N', id, ')']);  % Set species boundary flux in a variable node with
                                    % the tag name "bndfluxes" in the COMSOL model tree
            % Only diffusion
            elseif length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(0.5*vth', id, ...
                    '*N', id, ')']);  % Set species boundary flux in a variable node with
                                      % the tag name "bndfluxes" in the COMSOL model tree
            % Only drift
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_', coord]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['(1-r', id, ')*((max(V', id, '_', coord, '*eq', ...
                    id, '.n', coord, ',0) + 0.25*vth', id, ...
                    ')*N', id, ')']);  % Set species boundary flux in a variable node with
                                     % the tag name "bndfluxes" in the COMSOL model tree
            end
            
        else  % Case: 2D Cartesian (x-axis and y-axis) or cylindrical (r-axis and z-axis) coordinates
            
            % Particles with diffusion and drift
            if length(find(strcmp(specexpr(:, 1), ['V', id, '_', coord(1)]) == 1)) > 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(abs(V', id, '_', coord(2), ...
                    '*eq', id, '.n', coord(2), ' + V', id, '_', coord(1), ...
                    '*eq', id, '.n', coord(1), ')*N', id, ' + 0.5*vth', ...
                    id, '*N', id, ')']);  % Set species boundary flux in a variable node with
                                        % the tag name "bndfluxes" in the COMSOL model tree
            
            % Only diffusion
            elseif length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(0.5*vth', id, ...
                    '*N', id, ')']);  % Set species boundary flux in a variable node with
                                    % the tag name "bndfluxes" in the COMSOL model tree
            
            % Only drift
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_', coord(1)]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['(1-r', id, ')*((max(V', id, '_', coord(2), '*eq', ...
                    id, '.n', coord(2), ' + V', id, '_', coord(1), ...
                    '*eq', id, '.n', coord(1), ',0) + 1/4*vth', id, ...
                    ')*N', id, ')']);  % Set species boundary flux in a variable node with
                                     % the tag name "bndfluxes" in the COMSOL model tree
            end
        end
    end

    % Set the boundary flux for electron
    % ----------------------------------
    
    i = inp.eInd;
    id = num2str(i);
    posinp.iInd = find(inp.Z(inp.iInd) > 0);  % Secondary electron emission for positive ions only
    iflux = [];
    
    for j = 1:length(posinp.iInd)
        if length(iflux) > 0
            iflux = [iflux, '+'];
        end
        iflux = [iflux, 'max(F', num2str(inp.iInd(posinp.iInd(j))), ...
            '_boundary,0)'];  % Sum of ion boundary fluxes; needed for secondary electron emission
    end

    if length(coord) == 1  % Case: 1D Cartesian (x-axis) or polar (r-axis) coordinates
        
        % Electron flux
        model.variable(variablesname).set(['F', id, '_boundary'], ...
            ['((1-r', id, ')/(1+r', id, '))*(abs(V', id, '_', coord, ...
            '*eq', id, '.n', coord, '*N', id, ') + 0.5*vth', ...
            id, '*N', id, ') - (2*gamma/(1+r', id, '))*(', iflux, ...
            ')']);  % Set electron boundary flux in a variable node with
                    % the tag name "bndfluxes" in the COMSOL model tree
        
        % Electron energy flux
        model.variable(variablesname).set('Q_boundary', ...
            ['((1-r', id, ')/(1+r', id, '))*(abs(Veps_', coord, ...
            '*eq', id, '.n', coord, '*We) + 2/3*vth', ...
            id, '*We) - umWall*(2*gamma/(1+r', id, '))*(', iflux, ...
            ')']);  % Set electron energy boundary flux in a variable node with
                    % the tag name "bndfluxes" in the COMSOL model tree
        
    else  % Case: 2D Cartesian (x-axis and y-axis) or cylindrical (r-axis and z-axis) coordinates
        
        % Electron flux
        model.variable(variablesname).set(['F', id, '_boundary'], ...
            ['((1-r', id, ')/(1+r', id, '))*(abs(V', id, '_', coord(1), ...
            '*eq', id, '.n', coord(1), ' + V', id, '_', coord(2), ...
            '*eq', id, '.n', coord(2), ')*N', id, ' + 0.5*vth', ...
            id, '*N', id, ') - (2*gamma/(1+r', id, '))*(', iflux, ...
            ')']);  % Set electron boundary flux in a variable node with
                    % the tag name "bndfluxes" in the COMSOL model tree
        
        % Electrone energy flux
        model.variable(variablesname).set('Q_boundary', ...
            ['((1-r', id, ')/(1+r', id, '))*(abs(Veps_', coord(1), ...
            '*eq', id, '.n', coord(1), ' + Veps_', coord(2), ...
            '*eq', id, '.n', coord(2), ')*We', ...
            ' + 2/3*vth', id, '*We) - umWall*(2*gamma/(1+r', id, ...
            '))*(', iflux, ')']);  % Set electron energy boundary flux in a variable node with
                                 % the tag name "bndfluxes" in the COMSOL model tree
        
    end

    % Set the displacement current
    % ----------------------------
    
    if length(coord) == 1  % Case: 1D Cartesian (x-axis) or polar (r-axis) coordinates
        model.variable(variablesname).set('DisplacementCurrent', ...
            ['-epsilon0*epsilonr*Phi', coord, 't*poeq.n', coord], ...
            'Displacement current density');  % Set displacement current in a variable node with
                                          % the tag name "bndfluxes" in the COMSOL model tree
    else  % Case: 2D Cartesian (x-axis and y-axis) or cylindrical (r-axis and z-axis) coordinates
        model.variable(variablesname).set('DisplacementCurrent', ...
            ['-epsilon0*epsilonr*(Phi', coord(2), 't*poeq.n', ...
            coord(2), '+Phi', coord(1), 't*poeq.n', coord(1), ...
            ')'], 'Displacement current density');  % Set displacement current in a variable node with
                                                % the tag name "bndfluxes" in the COMSOL model tree
    end

    % Set charged species flux onto the wall
    % -------------------------------------

    tmp = ['-F', num2str(inp.eInd), '_boundary'];

    for i = 1:inp.Nspec
        id = num2str(i);

        if inp.Z(i) > 0  % Case: positive ions
            tmp = [tmp, '+', num2str(inp.Z(i)), '*F', id, '_boundary'];
        elseif inp.Z(i) < 0 && i ~= inp.eInd  % Case: negative ions
            tmp = [tmp, '-', num2str(abs(inp.Z(i))), '*F', id, '_boundary'];
        end

    end

    model.variable(variablesname).set('NormalChCFlux', ...
        ['e0*(', tmp, ')'], 'Charge carrier flux onto the wall');  % Set flux of charged species onto the 
                                                            % wall in a variable node with the tag
                                                            % name "bndfluxes" in the COMSOL model tree
end