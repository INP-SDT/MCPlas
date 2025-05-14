function SetProject(inp, flags, model)
%
% SetProject function uses functions specific for Live link for MATLAB module to set
% studies in Comsol model based on input data
%
% :param inp: the first input
% :param model: the second input

    msg(1, 'setting project', flags);

    %% Set constant gas temperature and pressure

    variablesname = 'plasma';
    model.variable(variablesname).set('Tgas', 'T0', 'Gas temperature');
    model.variable(variablesname).set('p', 'p0', 'Gas pressure');

    %% Set studies

    model.study.create('FluidPoisson');
    model.study('FluidPoisson').feature.create('time', 'Transient');
    model.study('FluidPoisson').label('Study Plasma');
    ActivatePlasma('FluidPoisson', true, model, inp);

    model.study('FluidPoisson').feature('time').set('tlist', inp.tlist);

    model.study('FluidPoisson').feature('time').set('rtolactive', 'on');
    model.study('FluidPoisson').feature('time').set('rtol', '1e-3');

    model.sol.create('sol1');
    model.sol('sol1').study('FluidPoisson');

    model.study('FluidPoisson').feature('time').set('notlistsolnum', 1);
    model.study('FluidPoisson').feature('time').set('notsolnum', '1');
    model.study('FluidPoisson').feature('time').set('listsolnum', 1);
    model.study('FluidPoisson').feature('time').set('solnum', '1');

    model.sol('sol1').create('st1', 'StudyStep');
    model.sol('sol1').feature('st1').set('study', 'FluidPoisson');
    model.sol('sol1').feature('st1').set('studystep', 'time');
    model.sol('sol1').create('v1', 'Variables');
    model.sol('sol1').feature('v1').set('control', 'time');
    model.sol('sol1').create('t1', 'Time');
    model.sol('sol1').feature('t1').set('tlist', inp.tlist);
    model.sol('sol1').feature('t1').set('plot', 'off');
    model.sol('sol1').feature('t1').set('plotgroup', 'Default');
    model.sol('sol1').feature('t1').set('plotfreq', 'tout');
    model.sol('sol1').feature('t1').set('probesel', 'all');
    model.sol('sol1').feature('t1').set('probes', {});
    model.sol('sol1').feature('t1').set('probefreq', 'tsteps');
    model.sol('sol1').feature('t1').set('control', 'time');
    model.sol('sol1').feature('t1').create('seDef', 'Segregated');
    model.sol('sol1').feature('t1').create('fc1', 'FullyCoupled');
    model.sol('sol1').feature('t1').feature('fc1').set('linsolver', 'dDef');
    model.sol('sol1').feature('t1').feature.remove('fcDef');
    model.sol('sol1').feature('t1').feature.remove('seDef');
    model.sol('sol1').attach('FluidPoisson');
    model.sol('sol1').feature('v1').set('scalemethod', 'manual');
    model.sol('sol1').feature('v1').set('scaleval', '10');
    model.sol('sol1').feature('t1').feature('dDef').set('linsolver', 'pardiso');
    model.sol('sol1').feature('t1').feature('fc1').set('dtech', 'const');
    model.sol('sol1').feature('t1').feature('fc1').set('ratelimitactive', 'off');
    model.sol('sol1').feature('t1').feature('fc1').set('maxiter', '40');
    model.sol('sol1').feature('t1').feature('fc1').set('stabacc', 'aacc');
    model.sol('sol1').feature('t1').feature('fc1').set('jtech', 'once');
    model.sol('sol1').feature('t1').feature('fc1').label('Fully Coupled Const Newton');
    msg(2, 'Solver: fully coupled with const Newton iteration', flags);

    model.sol('sol1').feature('t1').set('timemethod', 'bdf');
    model.sol('sol1').feature('t1').set('initialstepgenalphaactive', 'on');
    model.sol('sol1').feature('t1').set('initialstepbdfactive', true);
    model.sol('sol1').feature('t1').set('initialstepbdf', '1e-15');
    model.sol('sol1').feature('t1').set('maxorder', 2);
    model.sol('sol1').feature('t1').set('atolglobalvaluemethod', 'manual');
    model.sol('sol1').feature('t1').set('atolglobal', '1e-4');
    model.sol('sol1').feature('t1').set('atolglobalmethod', 'unscaled');
    model.sol('sol1').feature('t1').set('rhoinf', '0');
    model.sol('sol1').feature('t1').set('predictor', 'constant');
    model.sol('sol1').feature('t1').set('stabcntrl', false);

    % Get initial values:
    model.sol('sol1').runFromTo('st1', 'v1');

end
