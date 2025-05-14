function AddFluidEquations(inp, flags, model, GeomName)
%
% AddFluidEquations function uses functions specific for Live
% link for MATLAB module to add balance equation for the particle
% number densities for each species in Comsol model 
%
% :param inp: the first input
% :param flags: the second input
% :param model: the third input
% :param GeonName: the fourth input

    %% Add Fluid equation

    msg(1, 'setting fluid equations', flags);

    if flags.SourceTermStab
        msg(2, 'source term stabilization used', flags);
    else
        msg(2, 'source term stabilization not used', flags);
    end

    if ~flags.LogFormulation && flags.SourceTermStab
        error(['Source term stabilization available only ', ...
               'when log formulation is used']);
    end

    % Read expressions for fluxes to check for F=0
    fluxexpr = mphgetexpressions(model.variable('fluxes'));

    % Buid system of fluid equations for all species
    for i = 1:inp.Nspec

        id = num2str(i);
        Eqid = ['eq', id];

        if any(inp.n0Ind == i)

            % Constant gas density for background gas
            model.variable('specprop').set(['N', id], 'N', ...
            'Constant gas density for background gas');

        elseif length(find(strcmp(fluxexpr(:, 1), ['F', id, '_z']) == 1)) == 0 ...
                && length(find(strcmp(fluxexpr(:, 1), ['F', id, '_r']) == 1)) == 0 ...
                && length(find(strcmp(fluxexpr(:, 1), ['F', id, '_x']) == 1)) == 0 ...
                && length(find(strcmp(fluxexpr(:, 1), ['F', id, '_y']) == 1)) == 0

            % Balance equations (ODE) without diffusion or drift
            model.physics.create(Eqid, 'DomainODE', GeomName, {['N', id]});
            model.physics(Eqid).selection.named('plasmadomain');
            model.physics(Eqid).name(inp.specnames{i});
            model.physics(Eqid).identifier(Eqid);
            model.physics(Eqid).field('dimensionless').field(['N', id]);
            model.physics(Eqid).prop('Units').set( ...
                'DependentVariableQuantity', 'none');
            model.physics(Eqid).prop('Units').set( ...
                'CustomDependentVariableUnit', 'm^-3');
            model.physics(Eqid).prop('Units').set( ...
                'CustomSourceTermUnit', '1/(m^3*s)');

            if flags.SourceTermStab
                model.physics(Eqid).feature('dode1').set('f', 1, ['S', id, ...
                                                              ' + SrcStabFac*exp(-SrcStabPar*n', id, ')']);
            else
                model.physics(Eqid).feature('dode1').set('f', 1, ['S', id]);
            end

        else

            % (Drift-) diffusion equations (general PDE)
            model.physics.create(Eqid, 'GeneralFormPDE', GeomName, {['N', id]});
            model.physics(Eqid).selection.named('plasmadomain');
            model.physics(Eqid).name(['Species ', inp.specnames{i}]);
            model.physics(Eqid).identifier(Eqid);
            model.physics(Eqid).field('dimensionless').field(['N', id]);
            model.physics(Eqid).prop('Units').set( ...
                'DependentVariableQuantity', 1, 'none');
            model.physics(Eqid).prop('Units').set( ...
                'CustomDependentVariableUnit', '1/m^3');
            model.physics(Eqid).prop('Units').set( ...
                'CustomSourceTermUnit', '1/(m^3*s)');

            % Add fluxes, source terms and boundary conditions for 1D case in Cartesian coordinates
            if length(strfind(GeomName, 'Geom1D')) > 0

                model.physics(Eqid).feature('gfeq1').set( ...
                    'Ga', 1, ['F', id, '_z']);

                if flags.SourceTermStab
                    model.physics(Eqid).feature('gfeq1').set('f', 1, ['S', id, ...
                                                                  ' + SrcStabFac*exp(-SrcStabPar*n', id, ')']);
                else
                    model.physics(Eqid).feature('gfeq1').set('f', 1, ['S', id]);
                end

                model.physics(Eqid).feature.create('flux1', 'FluxBoundary', 0);
                model.physics(Eqid).feature('flux1').set( ...
                    'g', 1, ['-F', id, '_boundary']);
                model.physics(Eqid).feature('flux1').selection.named( ...
                'plasmaboundaries');
            
            % Add fluxes, source terms and boundary conditions for 1D case in polar coordinates
            elseif length(strfind(GeomName, 'Geom1p5D')) > 0

                model.physics(Eqid).feature('gfeq1').set( ...
                    'Ga', 1, ['F', id, '_r']);

                if flags.SourceTermStab
                    model.physics(Eqid).feature('gfeq1').set( ...
                        'f', 1, ['S', id, '-F', id, '_r/r', ...
                              ' + SrcStabFac*exp(-SrcStabPar*n', id, ')']);
                else
                    model.physics(Eqid).feature('gfeq1').set( ...
                        'f', 1, ['S', id, '-F', id, '_r/r']);
                end

                model.physics(Eqid).feature.create('flux1', 'FluxBoundary', 0);
                model.physics(Eqid).feature('flux1').set( ...
                    'g', 1, ['-F', id, '_boundary']);
                model.physics(Eqid).feature('flux1').selection.named( ...
                'plasmaboundaries');

            % Add fluxes, source terms and boundary conditions for 2D case in Cartesian coordinates
            elseif length(strfind(GeomName, 'Geom2D')) > 0

                model.physics(Eqid).feature('gfeq1').set( ...
                    'Ga', 1, {['F', id, '_x'] ['F', id, '_y']});

                if flags.SourceTermStab
                    model.physics(Eqid).feature('gfeq1').set( ...
                        'f', 1, ['S', id, ...
                              ' + SrcStabFac*exp(-SrcStabPar*n', id, ')']);
                else
                    model.physics(Eqid).feature('gfeq1').set( ...
                        'f', 1, ['S', id]);
                end

                model.physics(Eqid).feature.create('flux1', 'FluxBoundary', 1);
                model.physics(Eqid).feature('flux1').set( ...
                    'g', 1, ['-F', id, '_boundary']);
                model.physics(Eqid).feature('flux1').selection.named( ...
                'plasmaboundaries');
            
            % Add fluxes, source terms and boundary conditions for 2D case in cylindrical coordinates
            elseif length(strfind(GeomName, 'Geom2p5D')) > 0

                model.physics(Eqid).feature('gfeq1').set( ...
                    'Ga', 1, {['F', id, '_r'] ['F', id, '_z']});

                if flags.SourceTermStab
                    model.physics(Eqid).feature('gfeq1').set( ...
                        'f', 1, ['S', id, '-F', id, '_r/r', ...
                              ' + SrcStabFac*exp(-SrcStabPar*n', id, ')']);
                else
                    model.physics(Eqid).feature('gfeq1').set( ...
                        'f', 1, ['S', id, '-F', id, '_r/r']);
                end

                model.physics(Eqid).feature.create('flux1', 'FluxBoundary', 1);
                model.physics(Eqid).feature('flux1').set( ...
                    'g', 1, ['-F', id, '_boundary']);
                model.physics(Eqid).feature('flux1').selection.named( ...
                'plasmaboundaries');

            else
                error('invalid value of GeomName in AddFluidEquations.m');
            end

        end

        % Initial values
        if i ~= inp.n0Ind
            model.physics(Eqid).feature('init1').set(['N', id], 1, num2str(inp.Dspec_init(i)));
        end

    end

    %% Add electron energy balance equation
    
    Eqid = ['eq', num2str(inp.Nspec + 1)];

    model.physics.create(Eqid, 'GeneralFormPDE', GeomName, {'We'});
    model.physics(Eqid).selection.named('plasmadomain');
    model.physics(Eqid).name('Energy density of electrons');
    model.physics(Eqid).identifier(Eqid);
    model.physics(Eqid).field('dimensionless').field('We');
    model.physics(Eqid).prop('Units').set( ...
        'DependentVariableQuantity', 1, 'none');
    model.physics(Eqid).prop('Units').set( ...
        'CustomDependentVariableUnit', 'V/m^3');
    model.physics(Eqid).prop('Units').set( ...
        'CustomSourceTermUnit', 'V/(m^3*s)');

    % Add fluxes, source terms and boundary conditions for 1D case in Cartesian coordinates
    if length(strfind(GeomName, 'Geom1D')) > 0

        model.physics(Eqid).feature('gfeq1').set('Ga', 1, ['Q_z']);

        if flags.SourceTermStab
            model.physics(Eqid).feature('gfeq1').set('f', 1, ['Seps', ...
                                                      ' + SrcStabFac*exp(-SrcStabPar*we)*1[V]']);
        else
            model.physics(Eqid).feature('gfeq1').set('f', 1, 'Seps');
        end

        model.physics(Eqid).feature.create('flux1', 'FluxBoundary', 0);
        model.physics(Eqid).feature('flux1').set('g', 1, '-Q_boundary');
        model.physics(Eqid).feature('flux1').selection.named( ...
        'plasmaboundaries');

    % Add fluxes, source terms and boundary conditions for 1D case in polar coordinates
    elseif length(strfind(GeomName, 'Geom1p5D')) > 0

        model.physics(Eqid).feature('gfeq1').set('Ga', 1, ['Q_r']);

        if flags.SourceTermStab
            model.physics(Eqid).feature('gfeq1').set('f', 1, ['Seps-Q_r/r', ...
                                                      ' + SrcStabFac*exp(-SrcStabPar*we)*1[V]']);
        else
            model.physics(Eqid).feature('gfeq1').set('f', 1, 'Seps-Q_r/r');
        end

        model.physics(Eqid).feature.create('flux1', 'FluxBoundary', 0);
        model.physics(Eqid).feature('flux1').set('g', 1, '-Q_boundary');
        model.physics(Eqid).feature('flux1').selection.named( ...
        'plasmaboundaries');
    
    % Add fluxes, source terms and boundary conditions for 2D case in Cartesian coordinates
    elseif length(strfind(GeomName, 'Geom2D')) > 0

        model.physics(Eqid).feature('gfeq1').set('Ga', 1, {['Q_x'] ['Q_y']});

        if flags.SourceTermStab
            model.physics(Eqid).feature('gfeq1').set('f', 1, ['Seps', ...
                                                      ' + SrcStabFac*exp(-SrcStabPar*we)*1[V]']);
        else
            model.physics(Eqid).feature('gfeq1').set('f', 1, 'Seps');
        end

        model.physics(Eqid).feature.create('flux1', 'FluxBoundary', 1);
        model.physics(Eqid).feature('flux1').set('g', 1, '-Q_boundary');
        model.physics(Eqid).feature('flux1').selection.named( ...
        'plasmaboundaries');
    
    % Add fluxes, source terms and boundary conditions for 2D case in cylindrical coordinates
    elseif length(strfind(GeomName, 'Geom2p5D')) > 0

        model.physics(Eqid).feature('gfeq1').set('Ga', 1, {['Q_r'] ['Q_z']});

        if flags.SourceTermStab
            model.physics(Eqid).feature('gfeq1').set('f', 1, ['Seps-Q_r/r', ...
                                                      ' + SrcStabFac*exp(-SrcStabPar*we)*1[V]']);
        else
            model.physics(Eqid).feature('gfeq1').set('f', 1, 'Seps-Q_r/r');
        end

        model.physics(Eqid).feature.create('flux1', 'FluxBoundary', 1);
        model.physics(Eqid).feature('flux1').set('g', 1, '-Q_boundary');
        model.physics(Eqid).feature('flux1').selection.named( ...
        'plasmaboundaries');

    else
        error('invalid value of GeomName in AddFluidEquations.m');
    end

    % Initial values
    model.physics(Eqid).feature('init1').set('We', 1, ['3[V]*', ...
                                                  num2str(inp.Dspec_init(inp.eInd)), '[1/m^3]']);

    % Set element order
    for i = 1:inp.Nspec + 1

        if i ~= inp.n0Ind
            id = num2str(i);
            model.physics(['eq', id]).prop('ShapeProperty').set('order', 1, '1');
        end

    end

    if flags.LogFormulation
        SetLogFormulation(inp, model);
    end

end
