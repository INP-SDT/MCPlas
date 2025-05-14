function SetGeometry(flags, model, GeomName)
%
% SetGeometry function uses functions specific for Live link for MATLAB module to set
% desire geometry in Comsol model based on input data 
%
% :param flags: the first input
% :param model: the second input
% :param GeomName: the third input

    %% Set 2D geometry (Cartesian coordinates)
    
    % Three different configurations can be set based on "flags.dielectric" input data: 
    % both electrodes without dielectric layers,
    % one electrode covered by dielectric layer, the other one is without dielectric layer
    % both electrode coverd by dielectric layers

    if flags.dielectric == 1  % One electrode covered by dielectric layer

        GeomTitle = '2D planparallel with one dielectric';
        msg(1, ['setting geometry ' GeomTitle], flags);

        % Build geometry
        model.geom.create(GeomName, 2);
        model.geom(GeomName).label(GeomTitle);
        model.geom(GeomName).lengthUnit('m');
        model.geom(GeomName).axisymmetric(false);
        model.geom(GeomName).feature.create('r1', 'Rectangle');
        model.geom(GeomName).feature('r1').setIndex('size', 'ElecRadius', 0);
        model.geom(GeomName).feature('r1').setIndex('size', 'ElecDist', 1);
        model.geom(GeomName).feature.create('r2', 'Rectangle');
        model.geom(GeomName).feature('r2').setIndex('size', 'ElecRadius', 0);
        model.geom(GeomName).feature('r2').setIndex('size', 'DBthickness_1', 1);
        model.geom(GeomName).feature('r2').setIndex('pos', 'ElecDist', 1);

        model.geom(GeomName).runAll;
        model.geom(GeomName).run;

        % Initialize selections (1=Domain, 0=Boundary)
        SetSelection(model, 2, 'plasmadomain', 'Plasma domain', 1);
        SetSelection(model, 2, 'dielectric', 'Dielectric', 2);
        SetSelection(model, 1, 'plasmaboundaries', 'Plasma boundaries', [2 4]);
        SetSelection(model, 1, 'poweredelectrode', 'Powered electrode', 2);
        SetSelection(model, 1, 'currentprobebndry', 'Current probe boundary', 4);
        SetSelection(model, 1, 'groundedelectrode', 'Grounded electrode', 5);
        msg(2, 'Anode is grounded and current probe', flags)
        SetSelection(model, 1, 'electrodes', 'Electrodes', [2 5]);
        SetSelection(model, 1, 'dielectricwalls', 'Dielectric walls', 4);

    elseif flags.dielectric == 2  % Both electrodes covered by dielectric layers

        GeomTitle = '2D planparallel with two dielectrics';
        msg(1, ['setting geometry ' GeomTitle], flags);

        % Build geometry
        model.geom.create(GeomName, 2);
        model.geom(GeomName).label(GeomTitle);
        model.geom(GeomName).lengthUnit('m');
        model.geom(GeomName).axisymmetric(false);
        model.geom(GeomName).feature.create('r1', 'Rectangle');
        model.geom(GeomName).feature('r1').setIndex('size', 'ElecRadius', 0);
        model.geom(GeomName).feature('r1').setIndex('size', 'DBthickness_1', 1);
        model.geom(GeomName).feature.create('r2', 'Rectangle');
        model.geom(GeomName).feature('r2').setIndex('size', 'ElecRadius', 0);
        model.geom(GeomName).feature('r2').setIndex('size', 'ElecDist', 1);
        model.geom(GeomName).feature('r2').setIndex('pos', 'DBthickness_1', 1);
        model.geom(GeomName).feature.create('r3', 'Rectangle');
        model.geom(GeomName).feature('r3').setIndex('size', 'ElecRadius', 0);
        model.geom(GeomName).feature('r3').setIndex('size', 'DBthickness_2', 1);
        model.geom(GeomName).feature('r3').setIndex('pos', 'ElecDist+DBthickness_1', 1);

        model.geom(GeomName).runAll;
        model.geom(GeomName).run;

        % Initialize selections (1=Domain, 0=Boundary)
        SetSelection(model, 2, 'plasmadomain', 'Plasma domain', 2);
        SetSelection(model, 2, 'dielectric_1', 'Dielectric 1', 1);
        SetSelection(model, 2, 'dielectric_2', 'Dielectric 2', 3);
        SetSelection(model, 2, 'dielectric', 'Dielectric', [1 3]);
        SetSelection(model, 1, 'plasmaboundaries', 'Plasma boundaries', [4 6]);
        SetSelection(model, 1, 'poweredelectrode', 'Powered electrode', 2);
        SetSelection(model, 1, 'currentprobebndry', 'Current probe boundary', 4);
        SetSelection(model, 1, 'groundedelectrode', 'Grounded electrode', 7);
        msg(2, 'Anode is grounded and current probe',flags)
        SetSelection(model, 1, 'electrodes', 'Electrodes', [2 7]);
        SetSelection(model, 1, 'dielectricwall_1', 'Dielectric wall 1', 4);
        SetSelection(model, 1, 'dielectricwall_2', 'Dielectric wall 2', 6);
        SetSelection(model, 1, 'dielectricwalls', 'Dielectric walls', [4 6]);

    else  % Both electrodes without dielectric layers

        GeomTitle = '2D planparallel without dielectric';
        msg(1, ['setting geometry ' GeomTitle], flags);

        % Build geometry
        model.geom.create(GeomName, 2);
        model.geom(GeomName).label(GeomTitle);
        model.geom(GeomName).lengthUnit('m');
        model.geom(GeomName).axisymmetric(false);
        model.geom(GeomName).feature.create('r1', 'Rectangle');
        model.geom(GeomName).feature('r1').setIndex('size', 'ElecRadius', 0);
        model.geom(GeomName).feature('r1').setIndex('size', 'ElecDist', 1);

        model.geom(GeomName).runAll;
        model.geom(GeomName).run;

        % Initialize selections (1=Domain, 0=Boundary)
        SetSelection(model, 2, 'plasmadomain', 'Plasma domain', 1);
        SetSelection(model, 1, 'plasmaboundaries', 'Plasma boundaries', [2 3]);
        SetSelection(model, 1, 'poweredelectrode', 'Powered electrode', 2);
        SetSelection(model, 1, 'currentprobebndry', 'Current probe boundary', 3);
        SetSelection(model, 1, 'groundedelectrode', 'Grounded electrode', 3);
        msg(2, 'Anode is grounded and current probe', flags)
        SetSelection(model, 1, 'electrodes', 'Electrodes', [2 3]);
    end

end
