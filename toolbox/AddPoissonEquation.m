function AddPoissonEquation(flags, model, GeomName)
%
% AddPoissonEquation function uses functions specific for Live
% link for MATLAB module to add Poisson equation in Comsol model 
%
% :param flags: the first input
% :param model: the second input
% :param GeonName: the third input

    %% Set Poisson equation
    
    msg(1, 'setting Poisson equation', flags);
    % setup equation
    model.physics.create('poeq', 'PoissonEquation', GeomName);
    model.physics('poeq').field('dimensionless').field('Phi');
    model.physics('poeq').prop('Units').set('DependentVariableQuantity', ...
    'electricpotential');
    model.physics('poeq').prop('Units').set('SourceTermQuantity', ...
    'spacechargedensity');

    % Set Poisson equation for 1D case in Cartesian coordinates
    if length(strfind(GeomName, 'Geom1D')) > 0

        model.physics('poeq').feature('peq1').set('c', 1, 'epsilon0*epsilonr');
        model.physics('poeq').feature('peq1').set('f', 1, 'rho');

        model.physics('poeq').feature.create('dir1', 'DirichletBoundary', 0);
        model.physics('poeq').feature('dir1').name('Applied voltage');
        model.physics('poeq').feature('dir1').selection.named( ...
        'poweredelectrode');
        model.physics('poeq').feature('dir1').set('r', 1, 'PoweredVoltage');

        model.physics('poeq').feature.create('dir2', 'DirichletBoundary', 0);
        model.physics('poeq').feature('dir2').name('Ground');
        model.physics('poeq').feature('dir2').selection.named( ...
        'groundedelectrode');
        model.physics('poeq').feature('dir2').set('r', 1, '0');
        model.physics('poeq').feature.create('flux1', 'FluxBoundary', 0);

        if flags.dielectric == 1 || flags.dielectric == 2  % Check if dielectric layers are included by user
            model.physics('poeq').feature('flux1').selection.named( ...
            'dielectricwalls');
            model.physics('poeq').feature('flux1').set('g', 1, 'sigma');
        end
    
    % Set Poisson equation for 1D case in polar coordinates
    elseif length(strfind(GeomName, 'Geom1p5D')) > 0

        model.physics('poeq').feature('peq1').set('c', 1, 'epsilon0*epsilonr');
        model.physics('poeq').feature('peq1').set('f', 1, ...
        'rho+epsilon0*epsilonr*d(Phi,r)/r');

        model.physics('poeq').feature.create('dir1', 'DirichletBoundary', 0);
        model.physics('poeq').feature('dir1').name('Applied voltage');
        model.physics('poeq').feature('dir1').selection.named( ...
        'poweredelectrode');
        model.physics('poeq').feature('dir1').set('r', 1, 'PoweredVoltage');

        model.physics('poeq').feature.create('dir2', 'DirichletBoundary', 0);
        model.physics('poeq').feature('dir2').name('Ground');
        model.physics('poeq').feature('dir2').selection.named( ...
        'groundedelectrode');
        model.physics('poeq').feature('dir2').set('r', 1, '0');
        model.physics('poeq').feature.create('flux1', 'FluxBoundary', 0);

        if flags.dielectric == 1 || flags.dielectric == 2  % Check if dielectric layers are included by user
            model.physics('poeq').feature('flux1').selection.named( ...
            'dielectricwalls');
            model.physics('poeq').feature('flux1').set('g', 1, 'sigma');
        end
    % Set Poisson equation for 2D case in Cartesian coordinates
    elseif length(strfind(GeomName, 'Geom2D')) > 0

        model.physics('poeq').feature('peq1').set('c', 1, ...
            {'epsilon0*epsilonr' '0' '0' 'epsilon0*epsilonr'});
        model.physics('poeq').feature('peq1').set('f', 1, 'rho');

        model.physics('poeq').feature.create('dir1', 'DirichletBoundary', 1);
        model.physics('poeq').feature('dir1').name('Applied voltage');
        model.physics('poeq').feature('dir1').selection.named( ...
        'poweredelectrode');
        model.physics('poeq').feature('dir1').set('r', 1, 'PoweredVoltage');

        model.physics('poeq').feature.create('dir2', 'DirichletBoundary', 1);
        model.physics('poeq').feature('dir2').name('Ground');
        model.physics('poeq').feature('dir2').selection.named( ...
        'groundedelectrode');

        model.physics('poeq').feature.create('flux1', 'FluxBoundary', 1);

        if flags.dielectric == 1 || flags.dielectric == 2  % Check if dielectric layers are included by user
            model.physics('poeq').feature('flux1').selection.named('dielectricwalls');
            model.physics('poeq').feature('flux1').set('g', 1, 'sigma');
        end
    % Set Poisson equation for 2D case in cylindrical coordinates
    elseif length(strfind(GeomName, 'Geom2p5D')) > 0

        model.physics('poeq').feature('peq1').set('c', 1, ...
            {'epsilon0*epsilonr' '0' '0' 'epsilon0*epsilonr'});
        model.physics('poeq').feature('peq1').set('f', 1, ...
        'rho+epsilon0*epsilonr*d(Phi,r)/r');

        model.physics('poeq').feature.create('dir1', 'DirichletBoundary', 1);
        model.physics('poeq').feature('dir1').name('Applied voltage');
        model.physics('poeq').feature('dir1').selection.named( ...
        'poweredelectrode');
        model.physics('poeq').feature('dir1').set('r', 1, 'PoweredVoltage');

        model.physics('poeq').feature.create('dir2', 'DirichletBoundary', 1);
        model.physics('poeq').feature('dir2').name('Ground');
        model.physics('poeq').feature('dir2').selection.named( ...
        'groundedelectrode');

        model.physics('poeq').feature.create('flux1', 'FluxBoundary', 1);

        if flags.dielectric == 1 || flags.dielectric == 2  % Check if dielectric layers are included by user
            model.physics('poeq').feature('flux1').selection.named('dielectricwalls');
            model.physics('poeq').feature('flux1').set('g', 1, 'sigma');
        end

    else
        error('invalid value of GeomName in AddPoissonEquation.m');
    end

    % initial value
    model.physics('poeq').feature('init1').set('Phi', 1, '0');

end
