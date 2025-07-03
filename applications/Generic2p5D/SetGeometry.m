function SetGeometry(inp, flags, model)
    %
    % SetGeometry function uses functions specific for the LiveLink
    % for MATLAB module to set the desired geometry in the COMSOL model.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input


    GeomTitle = '2D axisymmetric';  % Title/label for the geometry
    msg(1, ['Setting geometry ' GeomTitle], flags);  % Display status message
    model.geom.create(inp.GeomName, 2);  % Create a 2D geometry object with the given name
    model.geom(inp.GeomName).label(GeomTitle);  % Label the geometry object
    model.geom(inp.GeomName).lengthUnit('m');  % Set units to meters
    model.geom(inp.GeomName).axisymmetric(true);  % Enable axisymmetric mode

    % Check if the electrode dimensions meet the criteria for 2p5D geometry
    circ = inp.General.circ_ele_radius;
    recL = inp.General.rec_ele_length;
    recW = inp.General.rec_ele_width;
    if circ > 0 && recL == 0 && recW == 0
        % Circular electrode: no action needed
    elseif recL > 0 && recW > 0 && circ == 0
        if recW >= recL
            model.param.set('ElecRadius', 'ElecLength/2', 'Radius of electrode in modelling domain');
        else
            model.param.set('ElecRadius', 'ElecWidth/2', 'Radius of electrode in modelling domain');
        end
    else
        error(['The 2p5D geometry supports only circular or rectangular electrode shapes. ' ...
            'Coaxial configuration is not permitted.']);
    end

    dp = inp.General.diel_thickness_powered;
    dg = inp.General.diel_thickness_grounded;

    if dp > 0 && dg == 0  % Case: powered electrode covered by dielectric layer

        % Create first rectangle representing the dielectric layer
        model.geom(inp.GeomName).feature.create('r1', 'Rectangle');
        model.geom(inp.GeomName).feature('r1').setIndex('size', 'ElecRadius', 0);  % Width
        model.geom(inp.GeomName).feature('r1').setIndex('size', 'DBthickness', 1);  % Height

        % Create second rectangle representing the plasma region
        model.geom(inp.GeomName).feature.create('r2', 'Rectangle');
        model.geom(inp.GeomName).feature('r2').setIndex('size', 'ElecRadius', 0);  % Width
        model.geom(inp.GeomName).feature('r2').setIndex('size', 'ElecDist', 1);  % Height
        model.geom(inp.GeomName).feature('r2').setIndex('pos', 'DBthickness', 1);  % Position

        % Build and finalize geometry
        model.geom(inp.GeomName).runAll;
        model.geom(inp.GeomName).run;

        % Define selections for domains (1) and boundaries (0)
        SetSelection(model, 2, 'dielectric', 'Dielectric', 1) % 1st domain = dielectric
        SetSelection(model, 2, 'plasmadomain', 'Plasma domain', 2);  % 2nd domain = plasma
        SetSelection(model, 1, 'plasmaboundaries', 'Plasma boundaries', [4 5]);  % Plasma boundaries
        SetSelection(model, 1, 'poweredelectrode', 'Powered electrode', 2);  % Powered electrode boundary
        SetSelection(model, 1, 'currentprobebndry', 'Current probe boundary', 4);  % Current probe boundary
        SetSelection(model, 1, 'groundedelectrode', 'Grounded electrode', 5);  % Grounded electrode boundary
        SetSelection(model, 1, 'electrodes', 'Electrodes', [2 5]);  % Electrodes boundaries
        SetSelection(model, 1, 'dielectricwalls', 'Dielectric walls', 4);  % Dielectric wall boundary

    elseif dp == 0 && dg > 0  % Case: grounded electrode covered by dielectric layer

        % Create first rectangle representing the plasma region
        model.geom(inp.GeomName).feature.create('r1', 'Rectangle');
        model.geom(inp.GeomName).feature('r1').setIndex('size', 'ElecRadius', 0);  % Width
        model.geom(inp.GeomName).feature('r1').setIndex('size', 'ElecDist', 1);  % Height

        % Create second rectangle representing the dielectric layer
        model.geom(inp.GeomName).feature.create('r2', 'Rectangle');
        model.geom(inp.GeomName).feature('r2').setIndex('size', 'ElecRadius', 0);  % Width
        model.geom(inp.GeomName).feature('r2').setIndex('size', 'DBthickness', 1);  % Height
        model.geom(inp.GeomName).feature('r2').setIndex('pos', 'ElecDist', 1);  % Position

        % Build and finalize geometry
        model.geom(inp.GeomName).runAll;
        model.geom(inp.GeomName).run;

        % Define selections for domains (1) and boundaries (0)
        SetSelection(model, 2, 'plasmadomain', 'Plasma domain', 1);  % 1st domain = plasma
        SetSelection(model, 2, 'dielectric', 'Dielectric', 2) % 2nd domain = dielectric
        SetSelection(model, 1, 'plasmaboundaries', 'Plasma boundaries', [2 4]);  % Plasma boundaries
        SetSelection(model, 1, 'poweredelectrode', 'Powered electrode', 2);  % Powered electrode boundary
        SetSelection(model, 1, 'currentprobebndry', 'Current probe boundary', 2);  % Current probe boundary
        SetSelection(model, 1, 'groundedelectrode', 'Grounded electrode', 5);  % Grounded electrode boundary
        SetSelection(model, 1, 'electrodes', 'Electrodes', [2 5]);  % Electrodes boundaries
        SetSelection(model, 1, 'dielectricwalls', 'Dielectric walls', 4);  % Dielectric wall boundary

    elseif dp > 0 && dg > 0  % Case: both electrodes covered by dielectric layer

        % Create first dielectric layer rectangle (left electrode)
        model.geom(inp.GeomName).feature.create('r1', 'Rectangle');
        model.geom(inp.GeomName).feature('r1').setIndex('size', 'ElecRadius', 0);  % Width
        model.geom(inp.GeomName).feature('r1').setIndex('size', 'DBthickness_1', 1);  % Height

        % Create plasma region rectangle between dielectrics
        model.geom(inp.GeomName).feature.create('r2', 'Rectangle');
        model.geom(inp.GeomName).feature('r2').setIndex('size', 'ElecRadius', 0);  % Width
        model.geom(inp.GeomName).feature('r2').setIndex('size', 'ElecDist', 1);  % Height
        model.geom(inp.GeomName).feature('r2').setIndex('pos', 'DBthickness_1', 1);  % Positioned above
                                                                                     % first dielectric

        % Create second dielectric layer rectangle (right electrode)
        model.geom(inp.GeomName).feature.create('r3', 'Rectangle');
        model.geom(inp.GeomName).feature('r3').setIndex('size', 'ElecRadius', 0);  % Width
        model.geom(inp.GeomName).feature('r3').setIndex('size', 'DBthickness_2', 1);  % Height
        model.geom(inp.GeomName).feature('r3').setIndex('pos', 'ElecDist+DBthickness_1', 1);  % Positioned above
                                                                                              % plasma region

        % Build and finalize all geometry features
        model.geom(inp.GeomName).runAll;
        model.geom(inp.GeomName).run;

        % Define selections for domains (1) and boundaries (0)
        SetSelection(model, 2, 'plasmadomain', 'Plasma domain', 2);  % Plasma is the middle domain
        SetSelection(model, 2, 'dielectric_1', 'Dielectric 1', 1);  % Left dielectric
        SetSelection(model, 2, 'dielectric_2', 'Dielectric 2', 3);  % Right dielectric
        SetSelection(model, 2, 'dielectric', 'Dielectric', [1 3]);  % Dielectric domains
        SetSelection(model, 1, 'plasmaboundaries', 'Plasma boundaries', [4 6]);  % Plasma boundaries
        SetSelection(model, 1, 'poweredelectrode', 'Powered electrode', 2);  % Powered electrode boundary
        SetSelection(model, 1, 'currentprobebndry', 'Current probe boundary', 4);  % Current probe location
        SetSelection(model, 1, 'groundedelectrode', 'Grounded electrode', 7);  % Grounded electrode boundary
        SetSelection(model, 1, 'electrodes', 'Electrodes', [2 7]);  % Electrodes boundaries
        SetSelection(model, 1, 'dielectricwall_1', 'Dielectric wall 1', 4);  % Dielectric wall 1 boundary
        SetSelection(model, 1, 'dielectricwall_2', 'Dielectric wall 2', 6);  % Dielectric wall 2 boundary
        SetSelection(model, 1, 'dielectricwalls', 'Dielectric walls', [4 6]);  % Dielectric walls boundaries

    else  % Case: no dielectric layers

        % Create rectangle representing plasma domain only (no dielectrics)
        model.geom(inp.GeomName).feature.create('r1', 'Rectangle');
        model.geom(inp.GeomName).feature('r1').setIndex('size', 'ElecRadius', 0);  % Width
        model.geom(inp.GeomName).feature('r1').setIndex('size', 'ElecDist', 1);  % Height gap distance

        % Build and finalize geometry
        model.geom(inp.GeomName).runAll;
        model.geom(inp.GeomName).run;

        % Define selections for domains (1) and boundaries (0)
        SetSelection(model, 2, 'plasmadomain', 'Plasma domain', 1);  % Single plasma domain
        SetSelection(model, 1, 'plasmaboundaries', 'Plasma boundaries', [2 3]);  % Plasma boundaries
        SetSelection(model, 1, 'poweredelectrode', 'Powered electrode', 2);  % Powered electrode boundary
        SetSelection(model, 1, 'currentprobebndry', 'Current probe boundary', 2);  % Current probe boundary
        SetSelection(model, 1, 'groundedelectrode', 'Grounded electrode', 3);  % Grounded electrode boundary
        SetSelection(model, 1, 'electrodes', 'Electrodes', [2 3]);  % Electrodes boundaries
    end

end
