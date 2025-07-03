function SetProject(inp, flags, model)
    %
    % SetProject function configures a COMSOL Multiphysics model
    % using Livelink for MATLAB module.
    % It defines a plasma simulation study, prepares solver sequences,
    % and sets numerical parameters.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input
    
    msg(1, 'Setting project', flags);  % Display status message

    variablesname = 'plasma';  % Variable group name
    model.variable(variablesname).set('Tgas', 'T0',  ...      
                                      'Gas temperature');  % Set gas temperature
    model.variable(variablesname).set('p',    'p0',  ...      
                                      'Gas pressure');  % Set gas pressure

    model.study.create('FluidPoisson');  % Create new study 
    model.study('FluidPoisson').feature.create('time', ...
                                                'Transient');  % Add transient time-dependent step
    model.study('FluidPoisson').label('Study Plasma');  % Assign descriptive name to the study

    ActivatePlasma('FluidPoisson', true, model, inp);  % Activate user-defined plasma physics
    model.study('FluidPoisson').feature('time').set('tlist', inp.tlist);  % Set simulation time values
    model.study('FluidPoisson').feature('time').set('rtolactive','on');  % Enable relative tolerance control
    model.study('FluidPoisson').feature('time').set('rtol', '1e-4');  % Set relative tolerance value

    dp = inp.General.diel_thickness_powered;
    dg = inp.General.diel_thickness_grounded;

    if dp > 0 || dg > 0  % Case: at least one dielectric layer is present
        model.study('FluidPoisson').feature('time').set('probesel', 'manual');  % Enable manual probe selection
        model.study('FluidPoisson').feature('time').set('probes', ...
                                                        {'var1' 'var2'});  % Select specific probes
        model.study('FluidPoisson').feature('time').set('plot', true);  % Enable plotting while solving
        model.study('FluidPoisson').feature('time').set('plotgroup', 'pg5');  % Set specific plot group
    else  % Case: without dielectric layers
        model.study('FluidPoisson').feature('time').set('plot', true);  % Enable plotting while solving
        model.study('FluidPoisson').feature('time').set('plotgroup', 'pg3');  % Set specific plot group
    end

    model.sol.create('sol1');  % Create solver
    model.sol('sol1').study('FluidPoisson');  % Link solver to study

    % Set study features specific for time-dependent case
    model.study('FluidPoisson').feature('time').set('notlistsolnum', 1);
    model.study('FluidPoisson').feature('time').set('notsolnum', '1');
    model.study('FluidPoisson').feature('time').set('listsolnum', 1);
    model.study('FluidPoisson').feature('time').set('solnum', '1');
    model.study('FluidPoisson').feature('time').set('rtol', '1e-4');

    % Study step setup 
    model.sol('sol1').create('st1', 'StudyStep');  % Define simulation step control
    model.sol('sol1').feature('st1').set('study', 'FluidPoisson');
    model.sol('sol1').feature('st1').set('studystep', 'time');

    model.sol('sol1').create('v1', 'Variables');  % Add variable update node in the study
    model.sol('sol1').feature('v1').set('control', 'time');  % Variables updated after each time step

    model.sol('sol1').create('t1', 'Time');  % Create main time solver
    model.sol('sol1').feature('t1').set('tlist', inp.tlist);  % Assign simulation times
   
    model.sol('sol1').feature('t1').set('plot', 'off');  % Disable solver plotting
    model.sol('sol1').feature('t1').set('plotgroup', 'Default');
    model.sol('sol1').feature('t1').set('plotfreq', 'tout');  % Plot on output time steps
    model.sol('sol1').feature('t1').set('probesel', 'all');  % Include all probes
    model.sol('sol1').feature('t1').set('probes', {});
    model.sol('sol1').feature('t1').set('probefreq', 'tsteps');  % Record probe values at each time step
    model.sol('sol1').feature('t1').set('control', 'time');  % The solver defined by "Step: time-dependent" 

    model.sol('sol1').feature('t1').create('fc1', 'FullyCoupled');  % Fully coupled solver
    model.sol('sol1').feature('t1').feature('fc1').set('linsolver', ...
                                                       'dDef');  % Use direct solver for linear systems

    model.sol('sol1').feature('t1').feature.remove('fcDef');  % Remove redundant defaults
    model.sol('sol1').attach('FluidPoisson');  % Finalize solver-studies link

    model.sol('sol1').feature('v1').set('scalemethod', 'manual');  % Enable manual scaling
    model.sol('sol1').feature('v1').set('scaleval', '10');  % Default scale factor

    model.sol('sol1').feature('t1').feature('dDef').set('linsolver', ...
                                                        'pardiso');  % Use PARDISO for linear solver

    % Newton solver settings for nonlinear system
    model.sol('sol1').feature('t1').feature('fc1').label(           ...
                                                  'Fully Coupled Const Newton');  % Rename solver strategy
    model.sol('sol1').feature('t1').feature('fc1').set('dtech', 'const');  % Constant damping factor 1
    model.sol('sol1').feature('t1').feature('fc1').set('ratelimitactive', 'off');  % Disable limit for non
                                                                                  % linear convergence rate
    model.sol('sol1').feature('t1').feature('fc1').set('maxiter', '40');  % Max Newton iterations
        model.sol('sol1').feature('t1').feature('fc1').set('jtech', 'once');  % Compute Jacobian only 
                                                                             % once per time step
    model.sol('sol1').feature('t1').feature('fc1').set('stabacc', 'aacc');  % Use Anderson acceleration

    msg(2, 'Solver: fully coupled with const Newton iteration', flags);  % Log solver strategy

    % Time stepping setup
    model.sol('sol1').feature('t1').set('atolglobalmethod', 'unscaled');  % No scaling on abs tolerance    
    model.sol('sol1').feature('t1').set('atolglobalvaluemethod', 'manual');  % Manual absolute tolerance
    model.sol('sol1').feature('t1').set('atolglobal', '1e-4');  % Set absolute error tolerance
    model.sol('sol1').feature('t1').set('timemethod', 'bdf');  % Use BDF method (implicit)
    model.sol('sol1').feature('t1').set('initialstepgenalphaactive', 'on');  % Auto initial step option
    model.sol('sol1').feature('t1').set('initialstepbdfactive', true);  % Enable BDF step control
    model.sol('sol1').feature('t1').set('initialstepbdf', '1e-15');  % Set initial time step
    model.sol('sol1').feature('t1').set('maxorder', 2);  % Use second-order BDF
    
    model.sol('sol1').runFromTo('st1', 'v1');  % Initialize study step to variable update

end
