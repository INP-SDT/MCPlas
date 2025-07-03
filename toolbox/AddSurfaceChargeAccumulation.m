function AddSurfaceChargeAccumulation(inp, flags, model)
    %
    % AddSurfaceChargeAccumulation function uses functions specific for the 
    % LiveLink for MATLAB module to add the balance equation for surface 
    % charge accumulation at dielectric walls to the COMSOL model.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input
    
    msg(1, 'Setting surface charge accumulation', flags);  % Display status message

    
    if inp.General.diel_thickness_powered > 0 ||... 
        inp.General.diel_thickness_grounded > 0  % Check if dielectric layers are included
        
        model.physics.create('sceq', 'BoundaryODE', ...
            inp.GeomName, {'sigma'});  % Create a node for the balance equation 
                                       % (ODE) for surface charge accumulation 
                                       % "sigma" in the COMSOL model tree
        model.physics('sceq').name('Surface charge accumulation');  % Define the equation name
        model.physics('sceq').selection.named('dielectricwalls');  % Specify domain (domain name
                                                                   % must be defined in the
                                                                   % SetSection.m file)      
        model.physics('sceq').field('dimensionless').field('sigma');  % Set dependent variable name
        model.physics('sceq').prop('Units').set( ...
            'DependentVariableQuantity', 'none');  % Set unit for dependent variable quantity
        model.physics('sceq').prop('Units').set( ...
            'CustomDependentVariableUnit', 'C/m^2');  % Set unit for dependent variable
        model.physics('sceq').prop('Units').set( ...
            'CustomSourceTermUnit', 'C/(m^2*s)');  % Set unit for source term
        model.physics('sceq').feature('dode1').set('f', 1, ...
            'NormalChCFlux');  % Set coefficient "f" (source term)
        model.physics('sceq').feature('init1').set('sigma', 1, '0');  % Set initial value
        model.physics('sceq').prop('ShapeProperty').set('order', 1, '1');  % Set element order
    else
        msg(1, 'No dielectric surface for charge accumulation', flags);
    end
end