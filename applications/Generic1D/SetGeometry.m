function SetGeometry(flags, model, GeomName)
%
% SetGeometry function uses functions specific for Live link for MATLAB module to set
% desire geometry in Comsol model based on input data 
%
% :param flags: the first input
% :param model: the second input
% :param GeomName: the third input

    %% Set 1D geometry (Cartesian coordinates)
    
    % Three different configurations can be set based on "flags.dielectric" input data: 
    % both electrodes without dielectric layers,
    % one electrode covered by dielectric layer, the other one is without dielectric layer
    % both electrode coverd by dielectric layers

    if flags.dielectric == 1  % One electrode covered by dielectric layer

        GeomTitle = '1D planparallel with one dielectric';
        msg(1, ['setting geometry ' GeomTitle], flags);

        % Build geometry
        model.geom.create(GeomName, 1);
        model.geom(GeomName).label(GeomTitle);
        model.geom(GeomName).lengthUnit('m');
        model.frame('material1').coord(1, 'z');
        model.frame('material1').coord(3, 'x');
        model.geom(GeomName).feature.create('i1', 'Interval');
        model.geom(GeomName).feature('i1').set('intervals', 'many');
        model.geom(GeomName).feature('i1').set('p', '0, ElecDist, ElecDist+DBthickness_1');

        model.geom(GeomName).runAll;
        model.geom(GeomName).run;

        % Initialize selections (1=Domain, 0=Boundary)
        SetSelection(model, 1, 'plasmadomain', 'Plasma domain', 1);
        SetSelection(model, 1, 'dielectric', 'Dielectric', 2);
        SetSelection(model, 0, 'plasmaboundaries', 'Plasma boundaries', [1 2]);
        SetSelection(model, 0, 'poweredelectrode', 'Powered electrode', 1);
        SetSelection(model, 0, 'groundedelectrode', 'Grounded electrode', 3);
        SetSelection(model, 0, 'currentprobebndry', 'Current probe boundary', 2);
        SetSelection(model, 0, 'electrodes', 'Electrodes', [1 3]);
        SetSelection(model, 0, 'dielectricwalls', 'Dielectric walls', 2);

    elseif flags.dielectric == 2  % Both electrodes covered by dielectric layers

        GeomTitle = '1D planparallel with two dielectrics';
        msg(1, ['setting geometry ' GeomTitle], flags);

        % Build geometry
        model.geom.create(GeomName, 1);
        model.geom(GeomName).label(GeomTitle);
        model.geom(GeomName).lengthUnit('m');
        model.frame('material1').coord(1, 'z');
        model.frame('material1').coord(3, 'x');
        model.geom(GeomName).feature.create('i1', 'Interval');
        model.geom(GeomName).feature('i1').set('intervals', 'many');
        model.geom(GeomName).feature('i1').set('p', '0, DBthickness_1, ElecDist+DBthickness_1, ElecDist+DBthickness_1+DBthickness_2');

        model.geom(GeomName).runAll;
        model.geom(GeomName).run;

        % Initialize selections (1=Domain, 0=Boundary)
        SetSelection(model, 1, 'plasmadomain', 'Plasma domain', 2);
        SetSelection(model, 1, 'dielectric_1', 'Dielectric 1', 1);
        SetSelection(model, 1, 'dielectric_2', 'Dielectric 2', 3);
        SetSelection(model, 1, 'dielectric', 'Dielectric', [1, 3]);
        SetSelection(model, 0, 'plasmaboundaries', 'Plasma boundaries', [2 3]);
        SetSelection(model, 0, 'poweredelectrode', 'Powered electrode', 1);
        SetSelection(model, 0, 'groundedelectrode', 'Grounded electrode', 4);
        SetSelection(model, 0, 'currentprobebndry', 'Current probe boundary', 2);
        SetSelection(model, 0, 'electrodes', 'Electrodes', [1 4]);
        SetSelection(model, 0, 'dielectricwall_1', 'Dielectric wall 1', 2);
        SetSelection(model, 0, 'dielectricwall_2', 'Dielectric wall 2', 3);
        SetSelection(model, 0, 'dielectricwalls', 'Dielectric walls', [2 3]);
    
    else  % Both electrodes without dielectric layers

        GeomTitle = '1D planparallel without dielectric';
        msg(1, ['setting geometry ' GeomTitle], flags);

        % Build geometry
        model.geom.create(GeomName, 1);
        model.geom(GeomName).label(GeomTitle);
        model.geom(GeomName).lengthUnit('m');

        model.frame('material1').coord(1, 'z');
        model.frame('material1').coord(3, 'x');

        model.geom(GeomName).feature.create('i1', 'Interval');
        model.geom(GeomName).feature('i1').set('p2', 'ElecDist');

        model.geom(GeomName).runAll;
        model.geom(GeomName).run;

        % Initialize selections (1=Domain, 0=Boundary)
        SetSelection(model, 1, 'plasmadomain', 'Plasma domain', 1);
        SetSelection(model, 0, 'plasmaboundaries', 'Plasma boundaries', [1 2]);
        SetSelection(model, 0, 'poweredelectrode', 'Powered electrode', 1);
        SetSelection(model, 0, 'groundedelectrode', 'Grounded electrode', 2);
        SetSelection(model, 0, 'currentprobebndry', 'Current probe boundary', 2);
        msg(2, 'Anode is grounded and current probe', flags)
        SetSelection(model, 0, 'electrodes', 'Electrodes', [1 2]);

    end

end
