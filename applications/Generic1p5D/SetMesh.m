function SetMesh(inp, flags, model)
    %
    % SetMesh function uses functions specific for LiveLink for MATLAB module to set
    % computational mesh based on input data. The mesh is only defined for
    % the plasma domain. The default mesh will be used for the dielectric.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input
    
    MeshTitle = 'Geometric_1p5D';  % Set a descriptive title for the mesh label
    msg(1, ['Setting mesh ' MeshTitle], flags);  % Display status message
    model.mesh.create('mesh1', inp.GeomName);  % Create a mesh object in the specified geometry sequence
    model.mesh('mesh1').label(MeshTitle);  % Assign label to the mesh
    model.mesh('mesh1').create('edg1', 'Edge');  % Create an edge mesh feature (1D mesh along edges)
    model.mesh('mesh1').feature('edg1').create('dis1', 'Distribution');  % Create a distribution sub-feature
                                                                         % for specifying mesh element settings
    model.mesh('mesh1').feature('edg1').feature( ...
        'dis1').selection.named('plasmadomain');  % Apply the distribution
                                                  % to predefined selection
                                                  % (e.g., 'plasmadomain')
    model.mesh('mesh1').feature('edg1').feature('dis1').set('type', 'number');  % Set the mesh distribution type
                                                                                % to use a fixed number of elements
    model.mesh('mesh1').feature('edg1').feature('dis1').set('equidistant', true);  % Set equidistant mesh point distribution                                                                                
    if inp.General.num_elem_1D  > 0 
        model.mesh('mesh1').feature('edg1').feature('dis1').set('numelem', ...
            num2str(inp.General.num_elem_1D));  % Set the number of mesh elements
    else
        error('The number of mesh points is not set correctly.');
    end
    model.mesh('mesh1').run;  % Execute mesh generation with the above settings

end
