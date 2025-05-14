function SetEnergyRates(inp, flags, model)
%
% SetEnergyRates function uses functions specific for Live link for MATLAB module to set
% energy reaction rates in Comsol model for all processes involving electrons  
%
% :param inp: the first input
% :param model: the second input

    msg(1, 'setting energy rates', flags);
    variablesname = 'energyrates';
    model.variable.create(variablesname);
    model.variable(variablesname).model('mod1');
    model.variable(variablesname).name('Energy reaction rates');
    model.variable(variablesname).selection.named('plasmadomain');

    for i = inp.ele_processes
        id = num2str(i);
        model.variable(variablesname).set(['Rene', id], inp.ReactionEnergyRates(i), ...
            ['Electron energy rate for reaction ', inp.reacnames{i}]);
    end

end
