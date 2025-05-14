function SetConstants(flags, model)
%
% SetConstants function uses functions specific for Live link for MATLAB module to set
% necessary constants in Comsol model based on input data 
%
% :param flags: input
% :param model: input

  msg(1,'setting physical constants', flags);
  
  varname = 'constants';
  model.variable.create(varname);
  model.variable(varname).label('Physical constants');

  model.variable(varname).set('e0', '1.602176487e-19[C]', 'Elementary charge (SI)');
  model.variable(varname).set('e0fac', '1.602176487e-19', 'eV to J conversion factor');
  model.variable(varname).set('amu', '1.660538782e-27[kg]', 'Atomar mass unit (SI)');
  model.variable(varname).set('me', '9.10938215e-31[kg]', 'Electron mass (SI)');
  model.variable(varname).set('kB', '1.3806504e-23[J/K]', 'Boltzmann constant (SI)');
  model.variable(varname).set('epsilon0', '8.854187817e-12[F/m]', 'Vacuum permittivity (SI)');
    
end

