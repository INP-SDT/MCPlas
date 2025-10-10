function SetGeometry(inp, flags, model)
    %
    % SetGeometry function uses functions specific for the LiveLink
    % for MATLAB module to set the desired geometry in the COMSOL model.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input

    GeomTitle = '1D axisymmetric';  % Title/label for the geometry
    msg(1, ['Setting geometry ' GeomTitle], flags);  % Display status message
    model.geom.create(inp.GeomName, 1);  % Create a 1D geometry sequence with the given name
    model.geom(inp.GeomName).label(GeomTitle);  % Label the geometry sequence
    model.geom(inp.GeomName).lengthUnit('m');  % Set geometry unit to meters
    model.geom(inp.GeomName).axisymmetric(true);  % Enable axisymmetric mode

    % Check if the electrode dimensions meet the criteria for 1p5D geometry
    recL = inp.General.rec_ele_length;
    recW = inp.General.rec_ele_width;
    circ = inp.General.circ_ele_radius;
    coaxIn = inp.General.coax_inner_ele_radius;
    coaxOut = inp.General.coax_outer_ele_radius;
    coaxLen = inp.General.coax_ele_length;
    if coaxIn > 0 && coaxOut > 0 && coaxLen > 0 && recL == 0 && recW == 0 && circ == 0
        % Coaxial configuration: valid for 1p5D geometry
    else
        error(['The 1p5D geometry supports only coaxial electrodes configuration. ' ...
            'Rectangular and circular electrode shapes are not permitted.']);
    end

    dp = inp.General.diel_thickness_powered;
    dg = inp.General.diel_thickness_grounded;   

    if dp > 0 && dg == 0  % Case: powered electrode covered by dielectric layer
        
        % Create a 1D interval with multiple subintervals (many segments)
        model.geom(inp.GeomName).feature.create('i1', 'Interval');
        model.geom(inp.GeomName).feature('i1').set('intervals', 'many');
        temp = 'RadiusInnerEle, RadiusInnerEle+DBthickness, RadiusInnerEle+DBthickness+DischGap';
        model.geom(inp.GeomName).feature('i1').set('p', temp);  % Define subinterval points:
                                                                % RadiusInnerEle (start),
                                                                % RadiusInnerEle + DBthickness (dielectric), 
                                                                % RadiusInnerEle + DBthickness + DischGap (plasma) 
        % Build and finalize geometry
        model.geom(inp.GeomName).runAll;
        model.geom(inp.GeomName).run; 
        
        % Define selections for domains (1) and boundaries (0)
        SetSelection(model, 1, 'dielectric', 'Dielectric', 1);  % 1st domain = dielectric
        SetSelection(model, 1, 'plasmadomain', 'Plasma domain', 2);  % 2nd domain = plasma
        SetSelection(model, 0, 'plasmaboundaries', 'Plasma boundaries', ...
            [2 3]);  % Plasma boundaries
        SetSelection(model, 0, 'poweredelectrode', ...
            'Powered electrode', 1);  % Powered electrode boundary
        SetSelection(model, 0, 'groundedelectrode', ...
            'Grounded electrode', 3);  % Grounded electrode boundary
        SetSelection(model, 0, 'currentprobebndry', ...
            'Current probe boundary', 2);  % Current probe boundary
        SetSelection(model, 0, 'electrodes', ...
            'Electrodes', [1 3]);  % Electrodes boundaries
        SetSelection(model, 0, 'dielectricwalls', ...
            'Dielectric walls', 2);  % Dielectric wall boundary
    
    elseif dp == 0 && dg > 0  % Case: grounded electrode covered by dielectric layer
        
        % Create a 1D interval with multiple subintervals (many segments)
        model.geom(inp.GeomName).feature.create('i1', 'Interval');
        model.geom(inp.GeomName).feature('i1').set('intervals', 'many');
        temp = 'RadiusInnerEle, RadiusInnerEle+DischGap, RadiusInnerEle+DischGap+DBthickness';
        model.geom(inp.GeomName).feature('i1').set('p', temp);  % Define subinterval points:
                                                                % RadiusInnerEle (start),
                                                                % RadiusInnerEle + DischGap (plasma), 
                                                                % RadiusInnerEle + DischGap + DBthickness (dielectric)
        % Build and finalize geometry
        model.geom(inp.GeomName).runAll;
        model.geom(inp.GeomName).run; 
        
        % Define selections for domains (1) and boundaries (0)
        SetSelection(model, 1, 'plasmadomain', 'Plasma domain', 1);  % 1st domain = plasma
        SetSelection(model, 1, 'dielectric', 'Dielectric', 2);  % 2nd domain = dielectric
        SetSelection(model, 0, 'plasmaboundaries', 'Plasma boundaries', ...
            [1 2]);  % Plasma boundaries
        SetSelection(model, 0, 'poweredelectrode', ...
            'Powered electrode', 1);  % Powered electrode boundary
        SetSelection(model, 0, 'groundedelectrode', ...
            'Grounded electrode', 3);  % Grounded electrode boundary
        SetSelection(model, 0, 'currentprobebndry',...
            'Current probe boundary', 1);  % Current probe boundary
        SetSelection(model, 0, 'electrodes', ...
            'Electrodes', [1 3]);  % Electrodes boundaries
        SetSelection(model, 0, 'dielectricwalls', ...
            'Dielectric walls', 2);  % Dielectric wall boundary
        
    elseif dp > 0 && dg > 0  % Case: both electrodes covered by dielectric layer
        model.geom(inp.GeomName).feature.create('i1', 'Interval');
        model.geom(inp.GeomName).feature('i1').set('intervals', 'many');
        temp = [ 'RadiusInnerEle, RadiusInnerEle+DBthickness_1, ' ...
            'RadiusInnerEle+DBthickness_1+DischGap, ' ...
            'RadiusInnerEle+DBthickness_1+DischGap+DBthickness_2'];
        model.geom(inp.GeomName).feature('i1').set('p',temp);  % Define subinterval points:
                                                               % RadiusInnerEle (start),
                                                               % RadiusInnerEle + DBthickness_1, 
                                                               % RadiusInnerEle + DBthickness_1
                                                               % + DischGap,
                                                               % RadiusInnerEle + DBthickness_1 + DischGap
                                                               % + DBthickness_2
        % Build and finalize geometry
        model.geom(inp.GeomName).runAll;
        model.geom(inp.GeomName).run;

        % Define selections for domains (1) and boundaries (0)
        SetSelection(model, 1, 'plasmadomain', 'Plasma domain', 2);  % Plasma is the middle domain
        SetSelection(model, 1, 'dielectric_1', 'Dielectric 1', 1);  % Left dielectric
        SetSelection(model, 1, 'dielectric_2', 'Dielectric 2', 3);  % Right dielectric
        SetSelection(model, 1, 'dielectric', 'Dielectric', [1, 3]);  % Dielectric domains
        SetSelection(model, 0, 'plasmaboundaries', 'Plasma boundaries', ...
            [2 3]);  % Plasma boundaries
        SetSelection(model, 0, 'poweredelectrode', 'Powered electrode', ...
            1);  % Powered electrode boundary
        SetSelection(model, 0, 'groundedelectrode', 'Grounded electrode', ...
            4);  % Grounde electrode boundary
        SetSelection(model, 0, 'currentprobebndry', 'Current probe boundary', ...
            2);  % Current probe location
        SetSelection(model, 0, 'electrodes', 'Electrodes', [1 4]);  % Electrodes boundaries
        SetSelection(model, 0, 'dielectricwall_1', 'Dielectric wall 1', ...
            2);  % Dielectric wall 1 boundary
        SetSelection(model, 0, 'dielectricwall_2', 'Dielectric wall 2', ...
            3);  % Dielectric wall 2 boundary
        SetSelection(model, 0, 'dielectricwalls', 'Dielectric walls', ...
            [2 3]);  % Dielectric walls boundaries
    
    else % Case: no dielectric layers
        
        % Create a simple two-point interval: just a plasma domain between electrodes
        model.geom(inp.GeomName).feature.create('i1', 'Interval');
        model.geom(inp.GeomName).feature('i1').setIndex('coord', 'RadiusInnerEle', 0);
        model.geom(inp.GeomName).feature('i1').setIndex('coord', 'DischGap+RadiusInnerEle', 1);
                
        % Build and finalize geometry
        model.geom(inp.GeomName).runAll;
        model.geom(inp.GeomName).run;
        
        % Define selections for domains (1) and boundaries (0)
        SetSelection(model, 1, 'plasmadomain', 'Plasma domain', 1);  % Single plasma domain
        SetSelection(model, 0, 'plasmaboundaries', 'Plasma boundaries', ...
            [1 2]);  % Plasma boundaries
        SetSelection(model, 0, 'poweredelectrode', 'Powered electrode', ...
            1);  % Powered electrode boundary
        SetSelection(model, 0, 'groundedelectrode', 'Grounded electrode', ...
            2);  % Grounded electrode boundary
        SetSelection(model, 0, 'currentprobebndry', 'Current probe boundary', ...
            1);  % Current probe location
        SetSelection(model, 0, 'electrodes', 'Electrodes', [1 2]);  % Electrodes boundaries
        
    end
end