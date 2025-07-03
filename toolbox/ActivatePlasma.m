function ActivatePlasma(study, ok, model, inp)
    %
    % The ActivatePlasma function enables or disables plasma-related physics 
    % interfaces in a COMSOL study step, based on input flags.
    %
    % :param study:     the first input
    % :param ok:        the second input
    % :param model:     the third input
    % :param inp:       the fourth input

    model.study(study).feature('time').activate('sceq', ok);  % Surface charge accumulation equation
    model.study(study).feature('time').activate('poeq', ok);  % Poisson's equation

    for i = 1:inp.Nspec
        id   = num2str(i);                
        Eqid = ['eq', id];                % Build equation identifier

        if any(i == inp.n0Ind)
            continue                      % Skip neutral species
        else
            model.study(study).feature('time').activate(Eqid, ok); % Activate species eq
        end
    end

    model.study(study).feature('time').activate(inp.eEnergyEqn, ok); % Activate electron energy

    % Display status message
    status = 'deactivated';
    if ok
        status = 'activated';
    end
    disp(['  Plasma equations in study ' study ' ' status]); % Final message

end
