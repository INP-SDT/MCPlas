function AddSurfaceChargeAccumulation(flags, model, GeomName)
%
% AddSurfaceChargeAccumulation function uses functions specific for Live
% link for MATLAB module to add balance equation for surface charge
% accomulation at dielectric walls in Comsol model 
%
% :param flags: the first input
% :param model: the second input
% :param GeonName: the third input

    %% Set balance equation for surface charge accomulation
    
    msg(1, 'setting surface charge accumulation', flags);

    if flags.dielectric == 1 || flags.dielectric == 2  % Check if dielectric layers are included by user
        % equation
        model.physics.create('sceq', 'BoundaryODE', GeomName, {'sigma'});
        model.physics('sceq').name('Surface charge accumulation');
        model.physics('sceq').selection.named('dielectricwalls');
        model.physics('sceq').field('dimensionless').field('sigma');
        model.physics('sceq').prop('Units').set( ...
            'DependentVariableQuantity', 'none');
        model.physics('sceq').prop('Units').set( ...
            'CustomDependentVariableUnit', 'C/m^2');
        model.physics('sceq').prop('Units').set( ...
            'CustomSourceTermUnit', 'C/(m^2*s)');
        model.physics('sceq').feature('dode1').set('f', 1, 'NormalChCFlux');

        % initial value
        model.physics('sceq').feature('init1').set('sigma', 1, '0');

        % element order
        model.physics('sceq').prop('ShapeProperty').set('order', 1, '1');

    else
        msg(1, 'no dielectric surface for charge accumulation', flags);

    end
