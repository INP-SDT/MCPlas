function SetVariables(inp, flags, model, GeomName)
%
% SetVariables function uses functions specific for Live link for MATLAB module to set
% necessary variables in Comsol model based on input data
%
% :param inp: the first input
% :param flags: the second input
% :param model: the third input
% :param GeonName: the fourth input

    msg(1, 'setting variables', flags);

    %% Set properties of powered electrode

    variablesname = 'propelecp';

    model.variable.create(variablesname);
    model.variable(variablesname).model('mod1');
    model.variable(variablesname).name('Properties of powered electrode');
    model.variable(variablesname).selection.named('poweredelectrode');

    % Secondary electron emission
    model.variable(variablesname).set('gamma', num2str(inp.GammaP), ...
    'SEE at the powered electrode');

    % Species reflection coefficients
    for i = 1:inp.Nspec
        id = num2str(i);
        model.variable(variablesname).set(['r', id], ...
            num2str(inp.ReflectionP(i)), ...
        'Reflection coefficient at powered electrode');
    end

    % Mean energy of secondary electrons
    model.variable(variablesname).set('umWall', ...
        [num2str(inp.UmeanSSE), '[V]'], ...
    'Mean energy of secondary electrons');

    %% Set properties of grounded electrode

    variablesname = 'propelecg';

    model.variable.create(variablesname);
    model.variable(variablesname).model('mod1');
    model.variable(variablesname).name('Properties of grounded electrode');
    model.variable(variablesname).selection.named('groundedelectrode');

    % Secondary electron emission
    model.variable(variablesname).set('gamma', num2str(inp.GammaG), ...
    'SEE at the powered electrode');

    % Species relection coefficients
    for i = 1:inp.Nspec
        id = num2str(i);
        model.variable(variablesname).set(['r', id], ...
            num2str(inp.ReflectionG(i)), ...
        'Reflection coefficient at grounded electrode');
    end

    % Mean energy of secondary electrons
    model.variable(variablesname).set('umWall', ...
        [num2str(inp.UmeanSSE), '[V]'], ...
    'Mean energy of secondary electrons');

    %% Set properties of dielectric walls

    if flags.dielectric == 1 % One electrode covered by dielectric layer
       
        variablesname = 'propdielectrics';
       
        model.variable.create(variablesname);
        model.variable(variablesname).model('mod1');
        model.variable(variablesname).name('Properties of dielectric walls');
        model.variable(variablesname).selection.named('dielectricwalls');

        % Secondary electron emission
        model.variable(variablesname).set('gamma', num2str(inp.GammaW_1), 'SEE at the dielectrics');

        % Species reflection coefficients
        for i = 1:inp.Nspec
            id = num2str(i);
            model.variable(variablesname).set(['r', id], num2str(inp.ReflectionW_1(i)), 'Reflection coefficient at wall (dielectrics)');
        end

        % Mean energy of secondary electrons
        model.variable(variablesname).set('umWall', [num2str(inp.UmeanSSE_1), '[V]'], 'Mean energy of secondary electrons');

    elseif flags.dielectric == 2  % Both electrodes covered by dielectric layers

        % Set properties of dielectric wall 1
        variablesname = 'propdielectrics_1';
        model.variable.create(variablesname);
        model.variable(variablesname).model('mod1');
        model.variable(variablesname).name('Properties of dielectric wall 1');
        model.variable(variablesname).selection.named('dielectricwall_1');

        % Secondary electron emission for dielectric wall 1
        model.variable(variablesname).set('gamma', num2str(inp.GammaW_1), 'SEE at the dielectrics');

        % Species reflection coefficients for dielectric wall 1
        for i = 1:inp.Nspec
            id = num2str(i);
            model.variable(variablesname).set(['r', id], num2str(inp.ReflectionW_1(i)), 'Reflection coefficient at wall (dielectrics)');
        end

        % Mean energy of secondary electrons for dielectric wall 1
        model.variable(variablesname).set('umWall', [num2str(inp.UmeanSSE_1), '[V]'], 'Mean energy of secondary electrons');

        % Set properties of dielectric wall 2
        variablesname = 'propdielectrics_2';
        model.variable.create(variablesname);
        model.variable(variablesname).model('mod1');
        model.variable(variablesname).name('Properties of dielectric wall 2');
        model.variable(variablesname).selection.named('dielectricwall_2');

        % Secondary electron emission for dielectric wall 2
        model.variable(variablesname).set('gamma', num2str(inp.GammaW_2), 'SEE at the dielectrics');

        % Species reflection coefficients for dielectric wall 2
        for i = 1:inp.Nspec
            id = num2str(i);
            model.variable(variablesname).set(['r', id], num2str(inp.ReflectionW_2(i)), 'Reflection coefficient at wall (dielectrics)');
        end

        % Mean energy of secondary electrons for dielectric wall 2
        model.variable(variablesname).set('umWall', [num2str(inp.UmeanSSE_2), '[V]'], 'Mean energy of secondary electrons');
    end

    %% Set species properties

    variablesname = 'specprop';
    
    model.variable.create(variablesname);
    model.variable(variablesname).model('mod1');
    model.variable(variablesname).name('Species properties');
    model.variable(variablesname).selection.named('plasmadomain');

    % Species mass
    for i = 1:inp.Nspec
        id = num2str(i);
        model.variable(variablesname).set(['M', id], ...
            [num2str(inp.Mass(i).value), char("[" + inp.Mass(i).unit + "]")], ...
            ['Particle mass of species ', inp.specnames{i}]);
    end

    % Species Temperature
    for i = 1:inp.Nspec
        id = num2str(i);

        if i == inp.eInd
            model.variable(variablesname).set(['T', id], '2/3*Umean*e0/kB', ...
            'Temperature of electrons');
        else
            model.variable(variablesname).set(['T', id], 'Tgas', ...
                ['Temperature of species ', inp.specnames{i}]);
        end

    end

    % Species thermal velocity
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

    %% Set plasma variables

    variablesname = 'plasma';
    
    model.variable.create(variablesname);
    model.variable(variablesname).model('mod1');
    model.variable(variablesname).name('Plasma variables');
    model.variable(variablesname).selection.named('plasmadomain');

    % Gas density
    model.variable(variablesname).set('N', 'p/(kB*Tgas)', 'Gas density');

    % Mean electron energy and temperature
    model.variable(variablesname).set('Umean', ['We/N', num2str(inp.eInd)], ...
    'Mean electron energy');
    model.variable(variablesname).set('Te', '2/3*Umean*e0/kB', ...
    'Temperature of electrons');

    % Electric field strength
    if length(strfind(GeomName, 'Geom1D')) > 0
        model.variable(variablesname).set( ...
            'E', 'abs(Phiz)', 'Electric field strenth');
    elseif length(strfind(GeomName, 'Geom1p5D')) > 0
        model.variable(variablesname).set( ...
            'E', 'abs(Phir)', 'Electric field strenth');
    elseif length(strfind(GeomName, 'Geom2D')) > 0
        model.variable(variablesname).set( ...
            'E', 'sqrt(max(Phix^2+Phiy^2,eps))', ...
        'Electric field strenth');
    elseif length(strfind(GeomName, 'Geom2p5D')) > 0
        model.variable(variablesname).set( ...
            'E', 'sqrt(max(Phiz^2+Phir^2,eps))', ...
        'Electric field strenth');
    else
        error('invalid value of GeomName in SetVariables.m');
    end

    % Reduced electric field
    model.variable(variablesname).set('EdN', 'E/N', ...
    'Reduced electric field');

    % Gas temperature
    model.variable(variablesname).set('Tgas', 'T0', ...
    'Gas temperature');

    % Gas pressure
    model.variable(variablesname).set('p', 'p0', ...
    'Gas pressure');

    %% Set gas properties
    
    variablesname = 'gas';
    
    model.variable.create(variablesname);
    model.variable(variablesname).model('mod1');
    model.variable(variablesname).name('Gas properties');
    model.variable(variablesname).selection.named('plasmadomain');

    % Space charge density
    tmp = ['-N', num2str(inp.eInd)];

    for i = 1:inp.Nspec
        id = num2str(i);

        if inp.Z(i) > 0
            tmp = [tmp, '+', num2str(inp.Z(i)), '*N', id];
        elseif inp.Z(i) < 0 & i ~= inp.eInd
            tmp = [tmp, '-', num2str(abs(inp.Z(i))), '*N', id];
        end

    end

    model.variable(variablesname).set('rho', ['e0*(', tmp, ')'], ...
    'Space charge density');

    % Relative permittivity
    model.variable(variablesname).set('epsilonr', '1', ...
    'relative permittivity');

    %% Set dielectric properties
    
    variablesname = 'dielectric';
    
    if flags.dielectric == 1  % One electrode covered by dielectric layer

        model.variable.create(variablesname);
        model.variable(variablesname).model('mod1');
        model.variable(variablesname).name('Dielectric properties');
        model.variable(variablesname).selection.named('dielectric');

        % Space charge density
        model.variable(variablesname).set('rho', '0', ...
        'Space charge density');

        % Relative permittivity
        model.variable(variablesname).set('epsilonr', num2str(inp.epsilonr_1), ...
        'relative permittivity');

    elseif flags.dielectric == 2   % Both electrodes covered by dielectric layer

        % Set properties of dielectric 1
        variablesname = 'dielectric_1';
        model.variable.create(variablesname);
        model.variable(variablesname).model('mod1');
        model.variable(variablesname).name('Dielectric properties 1');
        model.variable(variablesname).selection.named('dielectric_1');

        % Space charge density for dielectric 1
        model.variable(variablesname).set('rho', '0', ...
        'Space charge density');

        % Relative permittivity for dielectric 1
        model.variable(variablesname).set('epsilonr', num2str(inp.epsilonr_1), ...
        'relative permittivity');

        % Set properties of dielectric 2
        variablesname = 'dielectric_2';
        model.variable.create(variablesname);
        model.variable(variablesname).model('mod1');
        model.variable(variablesname).name('Dielectric properties 2');
        model.variable(variablesname).selection.named('dielectric_2');

        % Space charge density for dielectric 2
        model.variable(variablesname).set('rho', '0', ...
        'Space charge density');

        % Relative permittivity for dielectric 2
        model.variable(variablesname).set('epsilonr', num2str(inp.epsilonr_2), ...
        'relative permittivity');

    else
    end

end
