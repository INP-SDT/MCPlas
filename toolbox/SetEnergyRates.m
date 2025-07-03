function SetEnergyRates(inp, flags, model)
    %
    % SetEnergyRates function uses functions specific for the LiveLink 
    % for MATLAB module to set energy reaction rates in the COMSOL model 
    % for all processes involving electrons.  
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input
   
    msg(1, 'Setting energy rates', flags);  % Display status message
    
    variablesname = 'energyrates';
    model.variable.create(variablesname);  % Create a variable node with the tag
                                           % name "energyrates" in the COMSOL model tree
    model.variable(variablesname).model('mod1');  % Add the model tag
    model.variable(variablesname).name('Energy reaction rates');  % Define the node name
    model.variable(variablesname).selection.named('plasmadomain');  % Specify domain (domain name must be
                                                                    % defined in the SetSection.m file)
    
    for i = inp.ele_processes
        id = num2str(i);
        model.variable(variablesname).set(['Rene', id], inp.ReactionEnergyRates(i), ...
            ['Electron energy rate for reaction ', inp.reacnames{i}]);  % Set the energy rates in variable
                                                                        % node with a tag "rates"
    end
end