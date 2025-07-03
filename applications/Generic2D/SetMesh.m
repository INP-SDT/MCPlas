function SetMesh(inp, flags, model)
    %
    % SetMesh function uses functions specific for LiveLink for MATLAB module to set
    % computational mesh based on input data. The mesh is only defined for
    % the plasma domain. The default mesh will be used for the dielectric.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input
    
    MeshTitle = 'Geometric_2D';  % Set a descriptive title for the mesh label
    msg(1, ['Setting mesh ' MeshTitle], flags);  % Display status message
    model.mesh.create('mesh1', inp.GeomName);  % Create a mesh object in the specified geometry sequence
    model.mesh('mesh1').label(MeshTitle);  % Assign label to the mesh
    model.mesh('mesh1').create('ftri1', 'FreeTri');  % Create a free triangular mesh feature for 2D domains
    model.mesh('mesh1').feature('ftri1').create('size1', 'Size');  % Create a size control sub-feature for mesh
                                                                   % element sizing within the FreeTri mesh
    model.mesh('mesh1').feature('ftri1').feature('size1').selection.named( ...
        'plasmadomain');  % Apply the size setting to predefined selection
    model.mesh('mesh1').feature('ftri1').feature('size1').set('custom', 'on');  % Enable custom mesh size controls
    model.mesh('mesh1').feature('ftri1').feature('size1').set('hmaxactive', true);  % Activate the custom maximum size
    
    if inp.General.size_elem_2D  > 0  % Case: element size properly defined in JSON General input data file
        model.mesh('mesh1').feature('ftri1').feature('size1').set('hmax', ...
            num2str(inp.General.size_elem_2D));  % Set maximum element size
    else  % Case: element size not properly defined in JSON General input data file
        error('The mesh element size is not set correctly.');
    end
    
    model.mesh('mesh1').run;  % Execute mesh generation with the defined settings
end
