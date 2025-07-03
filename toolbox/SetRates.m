function SetRates(inp, flags, model)
    %
    % SetRates function uses functions specific for the LiveLink 
    % for MATLAB module to set reaction rates in the COMSOL model 
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input
    
    msg(1, 'Setting rates', flags);  % Display status message
    
    variablesname = 'rates'; 
    model.variable.create(variablesname);  % Create a variable node with the tag 
                                           % name "rates" in the Comsol model tree
    model.variable(variablesname).model('mod1');  % Add the model tag
    model.variable(variablesname).name('Reaction rates');  % Define the node name
    model.variable(variablesname).selection.named('plasmadomain');  % Specify domain (domain name must be
                                                                    % defined in the SetSection.m file)
    
    for i = inp.RateCoefficient_id
        id = num2str(i);
        model.variable(variablesname).set(['R', id], inp.ReactionRates(i), ...
            ['Rate for reaction ', inp.reacnames{i}]);  % Set the rates in variable node with a tag "rates"
    end
end