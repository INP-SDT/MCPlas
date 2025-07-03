function AddPoissonEquation(inp, flags, model)
    %
    % AddPoissonEquation function uses functions specific for the LiveLink
    % for MATLAB module to add the Poisson equation to the COMSOL
    % model.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input

    msg(1, 'Setting Poisson equation', flags);  % Display status message

    %% =================================================
    % Set variables and coefficients in Poisson equation
    % ==================================================

    model.physics.create('poeq', 'PoissonEquation', inp.GeomName);  % Create a node for the
                                                                    % Poisson equation in the
                                                                    % COMSOL model tree
    model.physics('poeq').field('dimensionless').field('Phi');  % Set dependent variable name
    model.physics('poeq').prop('Units').set('DependentVariableQuantity', ...
    'electricpotential');  % Set unit for dependent variable quantity
    model.physics('poeq').prop('Units').set('SourceTermQuantity', ...
    'spacechargedensity');  % Set unit for source term quantity
        
    if length(strfind(inp.GeomName, 'Geom1D')) > 0  % Case: 1D in Cartesian coordinates
        model.physics('poeq').feature('peq1').set('c', 1, 'epsilon0*epsilonr');  % Set coefficient "c" in equation
                                                                                 % nabla(-c*nabla(Phi))=f
        model.physics('poeq').feature('peq1').set('f', 1, 'rho');  % Set "f" (source term) in
                                                                   % equation nabla(-c*nabla(Phi))=f
    elseif length(strfind(inp.GeomName, 'Geom1p5D')) > 0  % Case: 1D in polar coordinates
        model.physics('poeq').feature('peq1').set('c', 1, 'epsilon0*epsilonr');  % Set coefficient "c" in equation
                                                                                 % nabla(-c*nabla(Phi))=f
        model.physics('poeq').feature('peq1').set('f', 1, ...
        'rho+epsilon0*epsilonr*d(Phi,r)/r');  % Set "f" (source term) in equation nabla(-c * nabla(Phi)) = f

    elseif length(strfind(inp.GeomName, 'Geom2D')) > 0  % Case: 2D in Cartesian coordinates
        model.physics('poeq').feature('peq1').set('c', 1, ...
            {'epsilon0*epsilonr' '0' '0' 'epsilon0*epsilonr'});  % Set coefficient "c" in equation
                                                                 % nabla(-c*nabla(Phi))=f
        model.physics('poeq').feature('peq1').set('f', 1, 'rho');  % Set "f" (source term) in
                                                                   % equation nabla(-c*nabla(Phi))=f
    elseif length(strfind(inp.GeomName, 'Geom2p5D')) > 0  % Case: 2D in cylindrical coordinates
        model.physics('poeq').feature('peq1').set('c', 1, ...
            {'epsilon0*epsilonr' '0' '0' 'epsilon0*epsilonr'});  % Set coefficient "c" in equation
                                                                 % nabla(-c*nabla(Phi))=f
        model.physics('poeq').feature('peq1').set('f', 1, ...
        'rho+epsilon0*epsilonr*d(Phi,r)/r');  % Set "f" (source term) in equation nabla(-c * nabla(Phi)) = f
    else
        error('Invalid value of GeomName in AddPoissonEquation.m');
    end

    %% ==================================
    % Set boundary and initial conditions
    % ===================================

    if length(strfind(inp.GeomName, 'Geom1D')) > 0 ||...
        length(strfind(inp.GeomName, 'Geom1p5D')) > 0  % Case: 1D in Cartesian or polar coordinates
        model.physics('poeq').feature.create('dir1', 'DirichletBoundary', 0);  % Create a node for
                                                                               % Dirichlet boundary condition
        model.physics('poeq').feature.create('dir2', 'DirichletBoundary', 0);  % Create a node for
                                                                               % Dirichlet boundary condition                                                                              
    else  % Case: 2D in Cartesian or cylindrical coordinates
        model.physics('poeq').feature.create('dir1', 'DirichletBoundary', 1);  % Create a node for
                                                                               % Dirichlet boundary condition
        model.physics('poeq').feature.create('dir2', 'DirichletBoundary', 1);  % Create a node for
                                                                               % Dirichlet boundary condition                                                                              
    end
    
    % Set potential at powered and grounded electrodes
    % ------------------------------------------------

    model.physics('poeq').feature('dir1').name('Applied voltage');  % Define name of the node
    model.physics('poeq').feature('dir1').selection.named('poweredelectrode');  % Specify domain (domain name
                                                                                % must be defined in the
                                                                                % SetSection.m file)
    model.physics('poeq').feature('dir1').set('r', 1, 'PoweredVoltage');  % Set voltage value at the boundary
    
    model.physics('poeq').feature('dir2').name('Ground');  % Define name of the node
    model.physics('poeq').feature('dir2').selection.named('groundedelectrode');  % Specify domain (domain name
                                                                                 % must be defined in the
                                                                                 % SetSection.m file)
    model.physics('poeq').feature('dir2').set('r', 1, '0');  % Set voltage value at the boundary

    % Set surface charge accomulation "sigma" at dielectric surfaces
    % --------------------------------------------------------------
    
    dp = inp.General.diel_thickness_powered;
    dg = inp.General.diel_thickness_grounded;
    
    if length(strfind(inp.GeomName, 'Geom1D')) > 0 ||...
            length(strfind(inp.GeomName, 'Geom1p5D')) > 0  % Case: 1D in Cartesian or polar coordinates
        
        if dp > 0 || dg > 0  % Check if dielectric layers are present
            model.physics('poeq').feature.create('flux1', 'FluxBoundary', 0);  % Create a node for flux
                                                                               % boundary condition
            model.physics('poeq').feature('flux1' ...
                ).selection.named('dielectricwalls');  % Specify domain (domain name must 
                                                       % be defined in the SetSection.m file)
            model.physics('poeq').feature('flux1').set('g', 1, 'sigma');  % Set "sigma" for
                                                                          % flux boundary condition
        end
    else  % Case: 2D in Cartesian or cylindrical coordinates
        if dp > 0 || dg > 0  % Check if dielectric layers are present
            model.physics('poeq').feature.create('flux1', 'FluxBoundary', 1);  % Create a node for flux
                                                                               % boundary condition
            model.physics('poeq').feature('flux1').selection.named( ...
                'dielectricwalls');  % Specify domain (name must
                                     % be defined in the
                                     % SetSection.m file)
            model.physics('poeq').feature('flux1').set('g', ...
                1, 'sigma');  % Set the "sigma" for flux boundary condition
        end
    end

    % Set initial value
    % ------------------

    model.physics('poeq').feature('init1').set('Phi', 1, '0');  % Set zero voltage for initial value
end
