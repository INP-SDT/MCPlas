function SetElectrical(inp, flags, model)
    %
    % SetElectrical function uses functions specific for the LiveLink
    % for MATLAB module to set the applied voltage and current density
    % in the COMSOL model based on input data.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input

    msg(1, 'Setting electrical properties', flags);  % Display status message

    varname = 'electrical';
    model.variable.create(varname);  % Create a variable node with the tag name
                                     % "voltage" in the COMSOL model tree
    model.variable(varname).name('Electrical');  % Define the node name
    model.variable(varname).model('mod1');  % Add the model tag

    if length(strfind(inp.GeomName,'Geom1D'))>0 ||...  % Case: 1D Cartesian or polar coordinates
        length(strfind(inp.GeomName,'Geom1p5D'))>0  
           

        model.cpl.create('intop1', 'Integration', inp.GeomName);  % Create a node for integration 
                                                                  % with the tag name "intop1"
                                                                  % in the COMSOL model tree
        model.cpl('intop1').selection.geom( ...
            inp.GeomName, 0);  % Indicate integration domain level ("0" for point)  
        model.cpl('intop1').selection.named('currentprobebndry');  % Specify boundary (boundray name
                                                                   % must be defined in the
                                                                   % SetSection.m file)
        model.cpl('intop1').set('opname', 'IntCPBoundary');  % Set operator name
        model.cpl('intop1').label('IntCPBoundary');  % Define operator label

        model.variable(varname).set('Icond', ...
            'Area*IntCPBoundary(NormalChCFlux)', ...
            'Conduction current');  % Set relation for conduction current calculation in variable
                                    % node with the tag name "electrical" in the COMSOL model tree
        model.variable(varname).set('Idispl', 'Area*IntCPBoundary(DisplacementCurrent)', ...
            'Displacement current');  % Set relation for displacement current calculation in variable
                                      % node with the tag name "electrical" in the COMSOL model tree
        model.variable(varname).set('Itotal','Icond+Idispl', ...
            'Total current');  % Set relation for total current calculation in variable
                               % node with the tag name "electrical" in the COMSOL model tree


    elseif length(strfind(inp.GeomName,'Geom2D'))>0  % Case: 2D Cartesian coordinates 
            
        model.cpl.create('intop1', 'Integration', inp.GeomName);  % Create a node for integration 
                                                                  % with the tag name "intop1"
                                                                  % in the COMSOL model tree
        model.cpl('intop1').selection.geom(inp.GeomName, 1);  % Indicate integration domain
                                                              % level ("1" for edge) 
        model.cpl('intop1').selection.named('currentprobebndry');  % Specify boundary (boundray name
                                                                   % must be defined in the
                                                                   % SetSection.m file)
        model.cpl('intop1').set('opname', 'IntCPBoundary');  % Set operator name
        model.cpl('intop1').label('IntCPBoundary');  % Define operator label

        model.variable(varname).set('Icond', ...
            'ElecWidth*IntCPBoundary(NormalChCFlux)', ...
            'Conduction current');  % Set relation for conduction current calculation in variable
                                    % node with the tag name "electrical" in the COMSOL model tree
        model.variable(varname).set('Idispl', ...
            'ElecWidth*IntCPBoundary(DisplacementCurrent)', ...
            'Displacement current');  % Set relation for displacement current calculation in variable
                                      % node with the tag name "electrical" in the COMSOL model tree
        model.variable(varname).set('Itotal', 'Icond+Idispl', ...
            'Total current');  % Set relation for total current calculation in variable
                               % node with the tag name "electrical" in the COMSOL model tree

     elseif length(strfind(inp.GeomName,'Geom2p5D'))>0  % Case: 2D cylindrical coordinates 
   
        model.cpl.create('intop1', 'Integration', inp.GeomName);  % Create a node for integration 
                                                                  % with the tag name "intop1"
                                                                  % in the COMSOL model tree
        model.cpl('intop1').selection.geom(inp.GeomName, 1);  % Indicate integration domain
                                                              % level ("1" for edge)
        model.cpl('intop1').selection.named('currentprobebndry');  % Specify boundary (boundray name
                                                                   % must be defined in the
                                                                   % SetSection.m file)
        model.cpl('intop1').set('axisym', 'on');  % Enable axisymmetric setting
                                                  % for integral to account for 
                                                  % the radial symmetry
        model.cpl('intop1').set('opname', 'IntCPBoundary');  % Set operator name
        model.cpl('intop1').label('IntCPBoundary');  % Define operator label

        model.variable(varname).set('Icond', ...
            'IntCPBoundary(NormalChCFlux)', ...
            'Conduction current');  % Set relation for conduction current calculation in variable
                                    % node with the tag name "electrical" in the COMSOL model tree
        model.variable(varname).set('Idispl', ...
            'IntCPBoundary(DisplacementCurrent)', ...
            'Displacement current');  % Set relation for displacement current calculation in variable
                                      % node with the tag name "electrical" in the COMSOL model tree
        model.variable(varname).set('Itotal', ...
            'Icond+Idispl', ...
            'Total current');  % Set relation for total current calculation in variable
                               % node with the tag name "electrical" in the COMSOL model tree
    else
        error('invalid value of GeomName in SetElectrical.m');
    end
    
    model.variable(varname).set('PoweredVoltage', inp.AppliedVoltage, ...
        'Powered voltage');  % Set the applied voltage in the variable node of the COMSOL model
end