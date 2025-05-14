function SetRates(inp, flags, model)
%
% SetRates function uses functions specific for Live link for MATLAB module to set
% reaction rates in Comsol model based on input data 
%
% :param inp: the first input
% :param model: the second input

    msg(1, 'setting rates', flags);
    variablesname = 'rates';
    model.variable.create(variablesname);
    model.variable(variablesname).model('mod1');
    model.variable(variablesname).name('Reaction rates');
    model.variable(variablesname).selection.named('plasmadomain');
    
    for i = inp.RateCoefficient_id
        id = num2str(i);
        model.variable(variablesname).set(['R', id], inp.ReactionRates(i), ['Rate for reaction ', inp.reacnames{i}]);
    end

end
