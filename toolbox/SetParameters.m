function SetParameters(inp, flags, model)
    %
    % SetParameters function uses functions specific for the LiveLink for
    % MATLAB module to set general global parameters in the COMSOL model.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input

    msg(1, 'Setting global parameters', flags);  % Display status message

    model.param.set('DischGap', num2str(inp.General.ele_distance) ...
        + "[m]", 'Gap width'); % Set plasma gap distance

    % Extract electrode dimension values from input to improve clarity
    circ    = inp.General.circ_ele_radius;
    recL    = inp.General.rec_ele_length;
    recW    = inp.General.rec_ele_width;
    coaxIn  = inp.General.coax_inner_ele_radius;
    coaxOut = inp.General.coax_outer_ele_radius;
    coaxLen = inp.General.coax_ele_length;

    % Identify which electrode configuration is active
    isCirc = circ > 0;
    isRect = recL > 0 && recW > 0;
    isCoax = coaxIn > 0 && coaxOut > 0;

    % Validate that exactly one configuration is defined
    configCount = isCirc + isRect + isCoax;
    if configCount ~= 1
        error(['Exactly one electrode configuration (circular, rectangular, or coaxial) ' ...
            'must be fully (all included dimensions) defined in the general JSON input file.']);
    end

    % Set electrode parameters based on configuration type
    if isCirc % Cylindrical electrodes
        model.param.set('ElecRadius', num2str(circ) + ...
            "[m]", 'Electrode radius');  % Set the radius of electrodes
        model.param.set('Area', "ElecRadius*ElecRadius*pi", ...
            'Electrode area');   % Set electrode area
    elseif isRect % Rectangular electrodes
        model.param.set('ElecLength', num2str(recL) + ...
            "[m]", 'Electrode length');  % Set electrode length
        model.param.set('ElecWidth',  num2str(recW) + ...
            "[m]", 'Electrode width');  % Set electrode width
        model.param.set('Area', "ElecLength*ElecWidth", ...
            'Electrode area');  % Set electrode area
    elseif isCoax % Coaxial electrodes configuration

        if coaxOut > coaxIn
            model.param.set('RadiusInnerEle', num2str(coaxIn) + ...
                "[m]", 'Outer radius of inner electrode');  % Set outer radius of the inner electrode
            model.param.set('InnerRadiusOuterEle', num2str(coaxOut) + ...
                "[m]", 'Inner radius of outer electrode');  % Set inner radius of the outer electrode
        else
            error('Radius of inner electrode cannot be equal or larger than radius of outer electrode');
        end
        if coaxLen > 0
            model.param.set('ElecLength', num2str(coaxLen) + ...
                "[m]", 'Electrode length');  % Set electrode length
            model.param.set('Area', "2*pi*RadiusInnerEle*ElecLength", ...
                'Electrode area');  % Set electrode area
        else
            error('Electrode length must be > 0');
        end

    end

    % Set dielectric layer parameters
    dp = inp.General.diel_thickness_powered;
    dg = inp.General.diel_thickness_grounded;

    if dp > 0 && dg == 0  % Case: powered electrode covered by dielectric layer
        model.param.set('DBthickness', dp + "[m]", ...
            'Thickness of dielectric at powered electrode');  % Set the thickness of dielectric
        % on powered electrode
        if isCoax % Coaxial electrodes configuration
            if coaxOut-(coaxIn+dp)==inp.General.ele_distance
                model.param.set('Area', "2*pi*(RadiusInnerEle+DBthickness)*ElecLength", ...
                    'Area for current calculations');  % Set the area of the dielectric surface
            else
                error('Discharge gap or electrode radius or dielectric thickness values are not set correctly.');
            end
        end
    elseif dp == 0 && dg > 0  % Case: grounded electrode covered by dielectric layer
        model.param.set('DBthickness', dg + "[m]", ...
            'Thickness of dielectric at grounded electrode');  % Set the thickness of dielectric
        % on grounded electrode
        if isCoax % Coaxial electrodes configuration
            if coaxOut-dg-coaxIn==inp.General.ele_distance
                model.param.set('Area', "2*pi*RadiusInnerEle*ElecLength", ...
                    'Area for current calculations');  % Set the electrode area
            else
                error('Discharge gap or electrode radius or dielectric thickness values are not set correctly.');
            end
        end
    elseif dp > 0 && dg > 0  % Case: both electrodes covered by dielectric layer
        model.param.set('DBthickness_1', dp + "[m]", ...
            'Thickness of dielectric at powered electrode');  % Set the thickness of dielectric
        % on powered electrode
        model.param.set('DBthickness_2', dg + "[m]", ...
            'Thickness of dielectric at grounded electrode');  % Set the thickness of dielectric
        % on grounded electrode
        if isCoax % Coaxial electrodes configuration
            if coaxOut-dp-dg-coaxIn==inp.General.ele_distance
                model.param.set('Area', "2*pi*(RadiusInnerEle+DBthickness_1)*ElecLength", ...
                    'Area for current calculations');  % Set the area of the dielectric surface
            else
                error('Discharge gap or electrode radius or dielectric thickness values are not set correctly.');
            end

        end
    else
        if isCoax % Coaxial electrodes configuration
            if coaxOut-coaxIn==inp.General.ele_distance
                model.param.set('Area', "2*pi*RadiusInnerEle*ElecLength", ...
                    'Area for current calculations');  % Set the electrode area
            else
                error('Discharge gap or electrode radius values are not set correctly.');
            end
        end

    end

    % Set discharge parameters
    model.param.set('U0', inp.General.app_voltage + "[V]", ...
        'Applied voltage');  % Set applied voltage
    model.param.set('p0', inp.General.gas_pressure + "[Pa]", ...
        'Constant gas pressure');  % Set gas pressure
    model.param.set('T0', inp.General.gas_temperature + "[K]", ...
        'Constant gas temperature');  %Set gas temperature

    % Source term stabilization parameters (if enabled)
    if flags.SourceTermStab
        model.param.set('SrcStabFac', 'N_A_const[mol]*1[m^-3*s^-1]', ...
            'Factor for source term stabilization');  % Stabilization factor
        model.param.set('SrcStabPar', '1', 'Parameter for source term stabilization');  % Stabilization parameter
    end
end
