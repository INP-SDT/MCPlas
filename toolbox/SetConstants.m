function SetConstants(flags, model)
    %
    % SetConstants function uses functions specific for the LiveLink for
    % MATLAB module to set necessary constants in the COMSOL model.
    %
    % :param flags: the first input
    % :param model: the second input

    msg(1, 'Setting physical constants', flags);  % Display status message

    varname = 'constants';
    model.variable.create(varname); % Create a variable node with the tag name "constants" 
                                    % in the COMSOL model tree
    model.variable(varname).label('Physical constants'); % Set label name for the node

    % Set constants
    model.variable(varname).set('e0', '1.602176487e-19[C]', 'Elementary charge (SI)');
    model.variable(varname).set('e0fac', '1.602176487e-19', 'eV to J conversion factor');
    model.variable(varname).set('amu', '1.660538782e-27[kg]', 'Atomar mass unit (SI)');
    model.variable(varname).set('me', '9.10938215e-31[kg]', 'Electron mass (SI)');
    model.variable(varname).set('kB', '1.3806504e-23[J/K]', 'Boltzmann constant (SI)');
    model.variable(varname).set('epsilon0', '8.854187817e-12[F/m]', 'Vacuum permittivity (SI)');

end
