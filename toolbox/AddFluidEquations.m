function AddFluidEquations(inp, flags, model)
    %
    % AddFluidEquations function uses functions specific for the LiveLink 
    % for MATLAB module to add the balance equation for the particle 
    % number densities for each species to the COMSOL model.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input
   
    %% ====================================
    % === Add species balance equations ===
    % =====================================
    
    msg(1, 'Setting fluid equations', flags);  % Display status message
    
    if flags.SourceTermStab % Message for source term stabilization
        msg(2, 'Source term stabilization used', flags);
    else
        msg(2, 'Source term stabilization not used', flags);
    end
    
    if ~flags.LogFormulation && flags.SourceTermStab
        error(['Source term stabilization is available only when log formulation is used.']);
    end
      
    fluxexpr = mphgetexpressions(model.variable('fluxes'));  % Read expressions for fluxes
                                                             % to check zero flux
    
    for i = 1:inp.Nspec
        id = num2str(i);
        Eqid = ['eq', id];

        % Set gas density for background gas
        % -----------------------------------
        
        if any(inp.n0Ind == i)
            temp = sprintf('%.16g', inp.n0Frac(i)) + "/100";
            model.variable('specprop').set(['N', id], [char(temp), '*N'], ...
                'Constant gas density for background gas');
        
        % Set balance equations (ODE) without diffusion or drift
        % -------------------------------------------------------
        
        elseif length(find(strcmp(fluxexpr(:, 1), ...
                ['F', id, '_z']) == 1)) == 0 && ...
                length(find(strcmp(fluxexpr(:, 1), ...
                ['F', id, '_r']) == 1)) == 0 && ...
                length(find(strcmp(fluxexpr(:, 1), ...
                ['F', id, '_x']) == 1)) == 0 && ...
                length(find(strcmp(fluxexpr(:, 1), ...
                ['F', id, '_y']) == 1)) == 0
            model.physics.create(Eqid, 'DomainODE', inp.GeomName, ...
                {['N', id]});  % Create a node for balance equations (ODE) for species "Nid" 
                               % in the COMSOL model tree
            model.physics(Eqid).selection.named('plasmadomain');  % Specify domain (domain name
                                                                  % must be defined in the
                                                                  % SetSection.m file)      
            model.physics(Eqid).name(inp.specnames{i});  % Define equation name
            model.physics(Eqid).identifier(Eqid);  % Define equation identifier
            model.physics(Eqid).field('dimensionless').field(['N', ...
                id]);  % Set dependent variable name
            model.physics(Eqid).prop('Units').set('DependentVariableQuantity', ...
                'none');  % Set unit for dependent variable quantity
            model.physics(Eqid).prop('Units').set('CustomDependentVariableUnit', ...
                'm^-3');  % Set unit for dependent variable
            model.physics(Eqid).prop('Units').set('CustomSourceTermUnit', ...
                '1/(m^3*s)');  % Set unit for source term
            
            % Define source term
            if flags.SourceTermStab  % Case: with source term stabilization
                model.physics(Eqid).feature('dode1').set('f', 1, ...
                    ['S', id, ' + SrcStabFac*exp(-SrcStabPar*n', id, ')']);
            else  % Case: without source term stabilization
                model.physics(Eqid).feature('dode1').set('f', 1, ['S', id]);
            end

        % Set (Drift-) diffusion equations (general PDE)
        % -----------------------------------------------
        
        else
            model.physics.create(Eqid, 'GeneralFormPDE', inp.GeomName, ...
                {['N', id]});  % Create a node for balance equations (PDE) for species "Nid"
                               % in the COMSOL model tree
            model.physics(Eqid).selection.named('plasmadomain');  % Specify domain (domain name
                                                                  % must be defined in the
                                                                  % SetSection.m file) 
            model.physics(Eqid).name(['Species ', inp.specnames{i}]);  % Define equation name
            model.physics(Eqid).identifier(Eqid);  % Define equation identifier
            model.physics(Eqid).field('dimensionless').field(['N', ...
                id]);  % Set dependent variable name
            model.physics(Eqid).prop('Units').set('DependentVariableQuantity', 1, ...
                'none');  % Set unit for dependent variable quantity
            model.physics(Eqid).prop('Units').set('CustomDependentVariableUnit', ...
                '1/m^3');  % Set unit for dependent variable
            model.physics(Eqid).prop('Units').set('CustomSourceTermUnit', ...
                '1/(m^3*s)');  % Set unit for source term
            
            % Add fluxes, source terms and boundary conditions
            type = 'species';
            if length(strfind(inp.GeomName, 'Geom1D')) > 0 % 1D in Cartesian coordinates
                coord = 'z';
                AddFluxSourceBoundary(id, Eqid, type, coord, flags, model)
            elseif length(strfind(inp.GeomName, 'Geom1p5D')) > 0 % 1D in polar coordinates
                coord = 'r';
                AddFluxSourceBoundary(id, Eqid, type, coord, flags, model)
            elseif length(strfind(inp.GeomName, 'Geom2D')) > 0 % 2D in Cartesian coordinates
                coord = ['x'; 'y'];
                AddFluxSourceBoundary(id, Eqid, type, coord, flags, model)
            elseif length(strfind(inp.GeomName, 'Geom2p5D')) > 0 % 2D in cylindrical coordinates
                coord = ['r'; 'z'];
                AddFluxSourceBoundary(id, Eqid, type, coord, flags, model)
            else
                error('Invalid value of GeomName in AddFluidEquations.m');
            end
        end
        
        % Set initial values
        if i ~= inp.n0Ind
            model.physics(Eqid).feature('init1').set(['N', id], 1, ...
                num2str(inp.Dspec_init(i)));
        end
    end
    
    %% ===========================================
    % === Add electron energy balance equation ===
    % ============================================
    
    Eqid = ['eq', num2str(inp.Nspec + 1)];
    model.physics.create(Eqid, 'GeneralFormPDE', inp.GeomName, ...
        {'We'});  % Create a node for balance equations (PDE) for electron energy density "We" 
                  % in the COMSOL model tree
    model.physics(Eqid).selection.named('plasmadomain');  % Specify domain (domain name
                                                          % must be defined in the
                                                          % SetSection.m file) 
    model.physics(Eqid).name('Energy density of electrons');  % Define equation name
    model.physics(Eqid).identifier(Eqid);  % Define equation identifier
    model.physics(Eqid).field('dimensionless').field('We');  % Set dependent variable name
    model.physics(Eqid).prop('Units').set('DependentVariableQuantity', ...
        1, 'none');  % Set unit for dependent variable quantity
    model.physics(Eqid).prop('Units').set('CustomDependentVariableUnit', ...
        'V/m^3');  % Set unit for dependent variable
    model.physics(Eqid).prop('Units').set('CustomSourceTermUnit', ...
        'V/(m^3*s)');  % Set unit for source term
    id = 'eps';
    
    % Add fluxes, source terms and boundary conditions
    type = 'energy';
    if length(strfind(inp.GeomName, 'Geom1D')) > 0 % 1D case in Cartesian coordinates
        coord = 'z';
        AddFluxSourceBoundary(id, Eqid, type, coord, flags, model)
    elseif length(strfind(inp.GeomName, 'Geom1p5D')) > 0 % 1D case in polar coordinates
        coord = 'r';
        AddFluxSourceBoundary(id, Eqid, type, coord, flags, model)
    elseif length(strfind(inp.GeomName, 'Geom2D')) > 0 % 2D case in Cartesian coordinates
        coord = ['x'; 'y'];
        AddFluxSourceBoundary(id, Eqid, type, coord, flags, model)
    elseif length(strfind(inp.GeomName, 'Geom2p5D')) > 0 % 2D case in cylindrical coordinates
        coord = ['r'; 'z'];
        AddFluxSourceBoundary(id, Eqid, type, coord, flags, model)
    else
        error('Invalid value of GeomName in AddFluidEquations.m');
    end
    
    % Set initial values
    model.physics(Eqid).feature('init1').set('We', 1, ...
        [num2str(inp.EleEne_init),'*',num2str(inp.Dspec_init(inp.eInd)), '[1/m^3]']);
    
    % Set element order
    for i = 1:inp.Nspec + 1
        if i ~= inp.n0Ind
            id = num2str(i);
            model.physics(['eq', id]).prop('ShapeProperty').set('order', 1, '1');
        end
    end

    if flags.LogFormulation
        SetLogFormulation(inp, model);
    end
end

% ------------------------------------------------------------
function AddFluxSourceBoundary(id, Eqid, type, coord, flags, model)
% ------------------------------------------------------------
    %
    % AddFluxSourceBoundary function employs functions specific 
    % for the Live Link for MATLAB module to add fluxes, source 
    % terms and boundary conditions for balance equations.
    %
    % :param id: the first input
    % :param Eqid: the second input
    % :param type: the third input
    % :param coord: the fourth input
    % :param flags: the fifth input
    % :param model: the sixth input
    
    if strcmp(type, 'species')
        Flux = ['F', id];
        Source = ['S', id];
        StabFac = ['SrcStabFac*exp(-SrcStabPar*n', id, ')'];
    elseif strcmp(type, 'energy')
        Flux = 'Q';
        Source = 'Seps';
        StabFac = 'SrcStabFac*exp(-SrcStabPar*we)*1[V]';
    else
        error('Specified "type" is wrong.');
    end
    
    if length(coord) == 1  % 1D Cartesian and polar coordinates
        model.physics(Eqid).feature('gfeq1').set('Ga', 1, [Flux, '_', coord]);  % Define fluxes
        if strcmp(coord, 'z') % For Cartesian (x-axis) coordinates
            if flags.SourceTermStab
                model.physics(Eqid).feature('gfeq1').set('f', 1, ...
                    [Source, ' + ', StabFac]);  % Define source term
            else
                model.physics(Eqid).feature('gfeq1').set('f', 1, Source);  % Define source term
            end
        else  % For polar (r-axis) coordinates
            if flags.SourceTermStab
                model.physics(Eqid).feature('gfeq1').set('f', 1, ...
                    [Source, '-', Flux, '_r/r', '+', StabFac]);  % Define source term
            else
                model.physics(Eqid).feature('gfeq1').set('f', 1, ...
                    [Source, '-', Flux, '_r/r']);  % Define source term
            end
        end
        
        model.physics(Eqid).feature.create('flux1', 'FluxBoundary', ...
            0);  % Define flux boundary condition
        model.physics(Eqid).feature('flux1').set('g', 1, ['-', Flux, ...
            '_boundary']);  % Define flux boundary condition
        model.physics(Eqid).feature('flux1').selection.named( ...
            'plasmaboundaries');  % Specify domain (domain name must be defined in the
                                  % SetSection.m file)
    
    else  % 2D Cartesian and cylindrical coordinates
        model.physics(Eqid).feature('gfeq1').set('Ga', 1, {[Flux, '_', coord(1)], ...
            [Flux, '_', coord(2)]});  % Define fluxes
        if strcmp(coord(1), 'x') % For Cartesian (x-axis and y-axis) coordinates
            if flags.SourceTermStab
                model.physics(Eqid).feature('gfeq1').set('f', 1, ...
                    [Source, '+', StabFac]);  % Define source term
            else
                model.physics(Eqid).feature('gfeq1').set('f', 1, Source);  % Define source term
            end
        else  % For cylindrical (r-axis and z-axis) coordinates
            if flags.SourceTermStab
                model.physics(Eqid).feature('gfeq1').set('f', 1, ...
                    [Source, '-', Flux, '_r/r', '+', StabFac]);  % Define source term
            else
                model.physics(Eqid).feature('gfeq1').set('f', 1, ...
                    [Source, '-', Flux, '_r/r']);  % Define source term
            end
        end
        
        model.physics(Eqid).feature.create('flux1', ...
            'FluxBoundary', 1);  % Define flux boundary condition
        model.physics(Eqid).feature('flux1').set('g', 1, ['-', ...
            Flux, '_boundary']);  % Define flux boundary condition
        model.physics(Eqid).feature('flux1').selection.named( ...
            'plasmaboundaries');  % Specify domain (domain name must be defined in the
                                  % SetSection.m file)        
    end
end
% -------------------------------------
function SetLogFormulation(inp, model)
% ------------------------------------
       
    fluxexpr = mphgetexpressions(model.variable('fluxes'));  % Read expressions for fluxes to check for F=0
    variablesname = 'specprop';
    
    % change dependent variable N -> n = log(N) in ODE/PDE
    for i = 1:inp.Nspec
        
        id = num2str(i);
        Eqid = ['eq',id];  % Define index for species number density 
                           % balance equation
        
        if any(i == inp.n0Ind)
            continue;
        elseif length(find(strcmp(fluxexpr(:,1),['F',id,'_z'])==1)) == 0 ...
            && length(find(strcmp(fluxexpr(:,1),['F',id,'_r'])==1)) == 0 ...
            && length(find(strcmp(fluxexpr(:,1),['F',id,'_x'])==1)) == 0 ...
            && length(find(strcmp(fluxexpr(:,1),['F',id,'_y'])==1)) == 0

            model.physics(Eqid).name(inp.specnames{i});  % Define equation name
            model.physics(Eqid).identifier(Eqid);  % Define equation identifier
            model.physics(Eqid).field('dimensionless').field(['N', ...
                id]);  % Set dependent variable name
            model.physics(Eqid).prop('Units').set('DependentVariableQuantity', ...
                'none');  % Set unit for dependent variable quantity
            model.physics(Eqid).prop('Units').set('CustomDependentVariableUnit', ...
                'm^-3');  % Set unit for dependent variable
            model.physics(Eqid).prop('Units').set('CustomSourceTermUnit', ...
                '1/(m^3*s)');  % Set unit for source term


                        
            model.physics(Eqid).field('dimensionless').component(1, ...
                ['n',id]);  % Define dependent variable name
            model.physics(Eqid).prop('Units').set( ...
                'CustomDependentVariableUnit', '1');  % Set "1" for nid unit
            model.physics(Eqid).feature('dode1').set('da', 1, ['N',id]);  % Set Nid
            model.physics(Eqid).feature('init1').set(['n',id], 1, ...
                ['log(',num2str(inp.Dspec_init(i)),')']);  % Set initial value for nid
            model.variable(variablesname).set(['N',id], ...
                ['exp(n',id,')*1[1/m^3]'], ...
                ['Density of ',inp.specnames{i}]);  % Set N as N=exp(n) in variable node with
                                                    % the tag name "specprop" 
                                                    % in the COMSOL model tree
        else     
            model.physics(Eqid).field('dimensionless').component(1, ...
                ['n',id]);  % Define dependent variable name
            model.physics(Eqid).prop('Units').set( ...
                'CustomDependentVariableUnit', '1');  % Set "1" for nid unit
            model.physics(Eqid).feature('gfeq1').set('da', 1, ['N',id]);  % Set field name "Nid"
            model.physics(Eqid).feature('init1').set(['n',id], 1, ...
                ['log(',num2str(inp.Dspec_init(i)),')']);  % Set initial value for nid
            model.variable(variablesname).set(['N',id], ...
                ['exp(n',id,')*1[1/m^3]'], ...
                ['Density of ',inp.specnames{i}]);  % Set N as N=exp(n) in variable node with
                                                    % the tag name "specprop" 
                                                    % in the COMSOL model tree
        end
        
    end
    
    Eqid = ['eq',num2str(inp.Nspec+1)];  % Define index for mean electron 
                                         % energy balance equation
    model.physics(Eqid).field('dimensionless').component(1, ...
        'we');  % Define dependent variable name
    model.physics(Eqid).prop('Units').set( ...
        'CustomDependentVariableUnit', '1');  % Set "1" for nid unit
    model.physics(Eqid).prop('Units').set('CustomSourceTermUnit', ...
        'V/(m^3*s)');  % Set unit source term
    model.physics(Eqid).feature('gfeq1').set('da', 1, 'We');  % Set field name "We"
    model.physics(Eqid).feature('init1').set('we', 1, ...
        ['log(',num2str(inp.EleEne_init),'*', ...
        num2str(inp.Dspec_init(inp.eInd)),')']);  % Set initial value for we
    model.variable(variablesname).set('We', ...
        ['exp(we)*1[V/m^3]'],'Electron energy density');  % Set We as We=exp(we) in variable
                                                          % node with the tag name "specprop" 
                                                          % in the COMSOL model tree
 end
