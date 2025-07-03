function SetVariables(inp, flags, model)
    %
    % SetVariables function uses functions specific for the LiveLink for 
    % MATLAB module to set the necessary variables in the COMSOL model. 
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input
    
    msg(1, 'Setting variables', flags);  % Display status message
    
    %% ==========================================
    % === Set properties of powered electrode ===
    % ===========================================
    
    variablesname = 'propelecp';
    model.variable.create(variablesname);  % Create a variable node with the
                                           % tag name "propelecp" in the COMSOL model tree.
    model.variable(variablesname).model('mod1'); % Add the model tag
    model.variable(variablesname).name('Properties of powered electrode');  % Define node name
    model.variable(variablesname).selection.named('poweredelectrode');  % Specify domain
                                                                        % (domain name must be defined 
                                                                        % in the SetSection.m file)
    
    % Set secondary electron emission
    model.variable(variablesname).set('gamma', num2str(inp.GammaP), ...
        'SEE at the powered electrode');  % Set the secondary electron emission
                                          % coefficient in variable node with 
                                          % a tag "propelecp"
    
    % Set species reflection coefficients
    for i = 1:inp.Nspec
        id = num2str(i);
        model.variable(variablesname).set(['r', id], ...
            num2str(inp.ReflectionP(i)), ...
            'Reflection coefficient at powered electrode');  % Set reflection coefficients for 
                                                             % species in variable node with 
                                                             % a tag "propelecp"
    end
    
    % Set mean energy of secondary electrons
    model.variable(variablesname).set('umWall', ...
        [num2str(inp.UmeanSEP), '[V]'], ...
        'Mean energy of secondary electrons');  % Set mean energy of secondary electrons
                                                % in variable node with a tag "propelecp"
    
    %% ===========================================
    % === Set properties of grounded electrode ===
    % ============================================
    
    variablesname = 'propelecg';
    model.variable.create(variablesname);  % Create a variable node with the tag
                                           % name "propelecg" in the COMSOL model tree
    model.variable(variablesname).model('mod1');  % Add the model tag
    model.variable(variablesname).name('Properties of grounded electrode');  % Define node name
    model.variable(variablesname).selection.named('groundedelectrode');  % Specify domain (domain name must be defined
                                                                         % in the SetSection.m file)
    
    model.variable(variablesname).set('gamma', num2str(inp.GammaG), ...
        'SEE at the grounded electrode');  % Set the secondary electron emission
                                           % coefficient in variable node with 
                                           % a tag "propelecg"
    
    for i = 1:inp.Nspec
        id = num2str(i);
        model.variable(variablesname).set(['r', id], ...
            num2str(inp.ReflectionG(i)), ...
            'Reflection coefficient at grounded electrode');  % Set reflection coefficients for 
                                                              % species in variable node with 
                                                              % a tag "propelecg"
    end
    
    % Set mean energy of secondary electrons
    model.variable(variablesname).set('umWall', ...
        [num2str(inp.UmeanSEG), '[V]'], ...
        'Mean energy of secondary electrons');  % Set mean energy of secondary electrons
                                                % in variable node with a tag "propelecg"
    
    %% ==========================================
    % === Set properties of dielectric walls ====
    % ===========================================

    dp = inp.General.diel_thickness_powered;
    dg = inp.General.diel_thickness_grounded;
    
    if dp > 0 && dg == 0  % Case: powered electrode covered by dielectric layer
        
        variablesname = 'propdielectrics';
        model.variable.create(variablesname);  % Create a variable node with the tag name 
                                               % "propdielectrics" in the COMSOL model tree
        model.variable(variablesname).model('mod1');  % Add model tag
        model.variable(variablesname).name('Properties of dielectric wall');  % Define node name
        model.variable(variablesname).selection.named('dielectricwalls');  % Specify domain 
        % (name must be defined in the SetSection.m file)
        
        % Set secondary electron emission coefficient
        model.variable(variablesname).set('gamma', num2str(inp.GammaW_1), ...
            'SEE at the dielectrics');
        
        % Set species reflection coefficients
        for i = 1:inp.Nspec
            id = num2str(i);
            model.variable(variablesname).set(['r', id], ...
                num2str(inp.ReflectionW_1(i)), ...
                'Reflection coefficient at wall (dielectrics)');
        end
        
        % Set mean energy of secondary electrons
        model.variable(variablesname).set('umWall', ...
            [num2str(inp.UmeanSEW_1), '[V]'], ...
            'Mean energy of secondary electrons');

    elseif dp == 0 && dg > 0  % Case: grounded electrode covered by dielectric layer
        
        variablesname = 'propdielectrics';
        model.variable.create(variablesname);  % Create a variable node with the tag name 
                                               % "propdielectrics" in the COMSOL model tree
        model.variable(variablesname).model('mod1');  % Add model tag
        model.variable(variablesname).name('Properties of dielectric wall');  % Define node name
        model.variable(variablesname).selection.named('dielectricwalls');  % Specify domain (domain name must be
                                                                           % defined in the SetSection.m file)
        
        % Set secondary electron emission coefficient
        model.variable(variablesname).set('gamma', num2str(inp.GammaW_2), ...
            'SEE at the dielectrics');
        
        % Set species reflection coefficients
        for i = 1:inp.Nspec
            id = num2str(i);
            model.variable(variablesname).set(['r', id], ...
                num2str(inp.ReflectionW_1(i)), ...
                'Reflection coefficient at wall (dielectrics)');
        end
        
        % Set mean energy of secondary electrons
        model.variable(variablesname).set('umWall', ...
            [num2str(inp.UmeanSEW_1), '[V]'], ...
            'Mean energy of secondary electrons');        
    
    elseif dp > 0 && dg > 0  % Case: both electrodes covered by dielectric layer

        variablesname = 'propdielectrics_1';
        model.variable.create(variablesname);  % Create a variable node with the tag name 
                                               % "propdielectrics_1" in the COMSOL model tree
        model.variable(variablesname).model('mod1');  % Add model tag
        model.variable(variablesname).name('Properties of dielectric wall 1');  % Define node name
        model.variable(variablesname).selection.named('dielectricwall_1');  % Specify domain (domain name must be
                                                                            % defined in the SetSection.m file)
        % Set secondary electron emission coefficent for dielectric wall 1
        model.variable(variablesname).set('gamma', num2str( inp.GammaW_1), ...
            'SEE at the dielectrics');
        
        % Set species reflection coefficients for dielectric wall 1
        for i = 1:inp.Nspec
            id = num2str(i);
            model.variable(variablesname).set(['r', id], ...
                num2str(inp.ReflectionW_1(i)), ...
                'Reflection coefficient at wall (dielectrics)');
        end
        
        % Set mean energy of secondary electrons for dielectric wall 1
        model.variable(variablesname).set('umWall', ...
            [num2str(inp.UmeanSEW_1), '[V]'], ...
            'Mean energy of secondary electrons');
        
        variablesname = 'propdielectrics_2';
        model.variable.create(variablesname);  % Create a variable node with the tag name 
                                               % "propdielectrics_2" in the COMSOL model tree
        model.variable(variablesname).model('mod1');  % Add model tag
        model.variable(variablesname).name('Properties of dielectric wall 2');  % Define node name
        model.variable(variablesname).selection.named('dielectricwall_2');  % Specify domain% (domain name must be 
                                                                            % defined in the SetSection.m file)
        
        % Set secondary electron emission coefficient for dielectric wall 2
        model.variable(variablesname).set('gamma', num2str( inp.GammaW_2), ...
            'SEE at the dielectrics');
        
        % Set species reflection coefficients for dielectric wall 2
        for i = 1:inp.Nspec
            id = num2str(i);
            model.variable(variablesname).set(['r', id], ...
                num2str(inp.ReflectionW_2(i)), ...
                'Reflection coefficient at wall (dielectrics)');
        end
        
        % Set mean energy of secondary electrons for dielectric wall 2
        model.variable(variablesname).set('umWall', ...
            [num2str(inp.UmeanSEW_2), '[V]'], ...
            'Mean energy of secondary electrons');
    end
    
    %% ==============================
    % === Set species properties ====
    % ===============================
    
    variablesname = 'specprop';
    model.variable.create(variablesname);  % Create a variable node with the tag name
                                           % "specprop" in the COMSOL model tree
    model.variable(variablesname).model('mod1'); % Add model tag
    model.variable(variablesname).name('Species properties');  % Define node name
    model.variable(variablesname).selection.named('plasmadomain');  % Specify domain (domain name must be 
                                                                    % defined in the SetSection.m file)

    % Set species mass
    for i = 1:inp.Nspec
        id = num2str(i);
        model.variable(variablesname).set(['M', id], ...
            [num2str(inp.Mass(i).value), char("[" + inp.Mass(i).unit + "]")], ...
            ['Particle mass of species ', inp.specnames{i}]);
    end
    
    % Set species temperature
    for i = 1:inp.Nspec
        id = num2str(i);
        if i == inp.eInd
            model.variable(variablesname).set(['T', id], ...
                '2/3*Umean*e0/kB', 'Temperature of electrons');
        else
            model.variable(variablesname).set(['T', id], ...
                'Tgas', ['Temperature of species ', inp.specnames{i}]);
        end
    end

    % Set species thermal velocity
    for i = 1:inp.Nspec
        id = num2str(i);
        if i == inp.eInd
            model.variable(variablesname).set(['vth', id], ...
                ['sqrt(8*kB*T', id, '/(pi*M', id, '))'], ...
                'Thermal velocity of electrons');
        else
            model.variable(variablesname).set(['vth', id], ...
                ['sqrt(8*kB*T', id, '/(pi*M', id, '))'], ...
                ['Thermal velocity of species ', inp.specnames{i}]);
        end
    end
    
    %% ============================
    % === Set plasma variables ====
    % =============================    
    
    variablesname = 'plasma';
    model.variable.create(variablesname);  % Create a variable node with the tag name
                                           % "plasma" in the COMSOL model tree
    model.variable(variablesname).model('mod1');  % Add model tag
    model.variable(variablesname).name('Plasma variables');  % Define node name
    model.variable(variablesname).selection.named('plasmadomain');  % Specify domain (domain name must be 
                                                                    % defined in the SetSection.m file)

    % Set gas density
    model.variable(variablesname).set('N', 'p/(kB*Tgas)', 'Gas density');

    % Set mean electron energy and temperature
    model.variable(variablesname).set('Umean', ['We/N', num2str(inp.eInd)], ...
        'Mean electron energy');
    model.variable(variablesname).set('Te', '2/3*Umean*e0/kB', ...
        'Temperature of electrons');

    % Set electric field strength
    if length(strfind(inp.GeomName, 'Geom1D')) > 0  % Case: 1D in Cartesian coordinates
        model.variable(variablesname).set('E', 'abs(Phiz)', 'Electric field strength');
    elseif length(strfind(inp.GeomName, 'Geom1p5D')) > 0  % Case: 1D in polar coordinates
        model.variable(variablesname).set('E', 'abs(Phir)', 'Electric field strength');
    elseif length(strfind(inp.GeomName, 'Geom2D')) > 0  % Case: 2D in Cartesian coordinates
        model.variable(variablesname).set('E', 'sqrt(max(Phix^2+Phiy^2,eps))', ...
            'Electric field strength');
    elseif length(strfind(inp.GeomName, 'Geom2p5D')) > 0  % Case: 2D in cylindrical coordinates
        model.variable(variablesname).set('E', 'sqrt(max(Phiz^2+Phir^2,eps))', ...
            'Electric field strength');
    else
        error('Invalid value of GeomName in SetVariables.m');
    end

    % Set reduced electric field
    model.variable(variablesname).set('EdN', 'E/N', 'Reduced electric field');
    
    % Set gas temperature
    model.variable(variablesname).set('Tgas', 'T0', 'Gas temperature');

    % Set gas pressure
    model.variable(variablesname).set('p', 'p0', 'Gas pressure');

    %% ==========================
    % === Set gas properties ====
    % ===========================
    
    variablesname = 'gas';
    model.variable.create(variablesname);  % Create a variable node with the tag name
                                           % "gas" in the COMSOL model tree
    model.variable(variablesname).model('mod1');  % Add model tag
    model.variable(variablesname).name('Gas properties');  % Define node name
    model.variable(variablesname).selection.named('plasmadomain');  % Specify domain (domain name must be
                                                                    % defined in the SetSection.m file)

    % Set space charge density
    tmp = ['-N', num2str(inp.eInd)];
    for i = 1:inp.Nspec
        id = num2str(i);
        if inp.Z(i) > 0
            tmp = [tmp, '+', num2str(inp.Z(i)), '*N', id];
        elseif inp.Z(i) < 0 && i ~= inp.eInd
            tmp = [tmp, '-', num2str(abs(inp.Z(i))), '*N', id];
        end
    end
    model.variable(variablesname).set('rho', ['e0*(', tmp, ')'], ...
        'Space charge density');

    % Set relative permittivity
    model.variable(variablesname).set('epsilonr', '1', 'Relative permittivity');

    %% =================================
    % === Set dielectric properties ====
    % ==================================
        
    variablesname = 'dielectric';
    
    if dp > 0 && dg == 0  % Case: powered electrode covered by dielectric layer

        model.variable.create(variablesname);  % Create a variable node with the tag name
                                               % "dielectric" in the COMSOL model tree
        model.variable(variablesname).model('mod1'); % Add model tag
        model.variable(variablesname).name('Dielectric properties');  % Define node name
        model.variable(variablesname).selection.named('dielectric');  % Specify domain (domain name must be 
                                                                      % defined in the SetSection.m file)

        % Space charge density
        model.variable(variablesname).set('rho', '0', 'Space charge density');

        % Relative permittivity
        model.variable(variablesname).set('epsilonr', num2str(inp.General.permit_diel1), ...
        'relative permittivity');

    elseif dp == 0 && dg > 0  % Case: grounded electrode covered by dielectric layer

        model.variable.create(variablesname);  % Create a variable node with the tag name
                                               % "dielectric" in the COMSOL model tree
        model.variable(variablesname).model('mod1');  % Add model tag
        model.variable(variablesname).name('Dielectric properties');  % Define node name
        model.variable(variablesname).selection.named('dielectric');  % Specify domain (domain name must be
                                                                      % defined in the SetSection.m file)

        % Space charge density
        model.variable(variablesname).set('rho', '0', 'Space charge density');

        % Relative permittivity
        model.variable(variablesname).set('epsilonr', num2str(inp.General.permit_diel2), ...
        'relative permittivity');        

    elseif dp > 0 && dg > 0  % Case: both electrodes covered by dielectric layer

        % Set properties of dielectric 1
        variablesname = 'dielectric_1';
        model.variable.create(variablesname);  % Create a variable node with the tag name
                                               % "dielectric_1" in the COMSOL model tree
        model.variable(variablesname).model('mod1'); % Add model tag
        model.variable(variablesname).name('Dielectric properties 1');  % Define node name
        model.variable(variablesname).selection.named('dielectric_1');  % Specify domain (domain name must be
                                                                        % defined in the SetSection.m file)

        % Space charge density for dielectric 1
        model.variable(variablesname).set('rho', '0', 'Space charge density');

        % Relative permittivity for dielectric 1
        model.variable(variablesname).set('epsilonr', num2str(inp.General.permit_diel1), ...
        'relative permittivity');

        % Set properties of dielectric 2
        variablesname = 'dielectric_2';
        model.variable.create(variablesname);  % Create a variable node with the tag name
                                               % "dielectric_2" in the COMSOL model tree
        model.variable(variablesname).model('mod1'); % Add model tag
        model.variable(variablesname).name('Dielectric properties 2');  % Define node name
        model.variable(variablesname).selection.named('dielectric_2');  % Specify domain (domain name must be
                                                                        % definedin the SetSection.m file)

        % Space charge density for dielectric 2
        model.variable(variablesname).set('rho', '0', 'Space charge density');

        % Relative permittivity for dielectric 2
        model.variable(variablesname).set('epsilonr', num2str(inp.General.permit_diel2), ...
        'relative permittivity');
    end

end