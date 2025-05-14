function SetMesh(inp, flags, model, GeomName)
%
% SetMesh function uses functions specific for Live link for MATLAB module to set
% computational mesh based on input data 
%
% :param inp: the first input
% :param model: the second input
% :param GeomName: the third input

    %% Set 1D mesh     

    MeshTitle = 'Geometric_1p5D';

    msg(1, ['setting mesh ' MeshTitle], flags);

    model.mesh.create('mesh1', GeomName);
    model.mesh('mesh1').label(MeshTitle);
    model.mesh('mesh1').create('edg1', 'Edge');
    model.mesh('mesh1').feature('edg1').create('dis1', 'Distribution');

    model.mesh('mesh1').feature('edg1').feature('dis1').selection.named('plasmadomain');
    model.mesh('mesh1').feature('edg1').feature('dis1').set('type', 'number');
    model.mesh('mesh1').feature('edg1').feature('dis1').set('numelem', num2str(inp.Nelem_1D));

    model.mesh('mesh1').run;
end
