function SetMesh(inp, flags, model, GeomName)
%
% SetMesh function uses functions specific for Live link for MATLAB module to set
% computational mesh based on input data 
%
% :param inp: the first input
% :param model: the second input
% :param GeomName: the third input

    %% Set 2D mesh     

    MeshTitle = 'Geometric_2D';

    msg(1, ['setting mesh ' MeshTitle], flags);

    model.mesh.create('mesh1', GeomName);
    model.mesh('mesh1').label(MeshTitle);

    model.mesh('mesh1').create('ftri1', 'FreeTri');
    model.mesh('mesh1').feature('ftri1').create('size1', 'Size');
    model.mesh('mesh1').feature('ftri1').feature('size1').selection.named('plasmadomain');

    model.mesh('mesh1').label('Geometric_8');
    model.mesh('mesh1').feature('ftri1').feature('size1').set('hauto', 3);
    model.mesh('mesh1').feature('ftri1').feature('size1').set('custom', 'on');
    model.mesh('mesh1').feature('ftri1').feature('size1').set('hmax', num2str(inp.Nelem_2D));
    model.mesh('mesh1').feature('ftri1').feature('size1').set('hmaxactive', true);
    model.mesh('mesh1').run;

end
