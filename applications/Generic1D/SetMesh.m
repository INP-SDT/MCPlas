function SetMesh

% a fun function
%
% :param U0: the first input
% :param freq: the second input
% :param freq: the third input
% :returns: ``[U]`` some outputs   

  global model GeomName inp;
  
  MeshTitle='Geometric_1D';
    
  msg(1,['setting mesh ' MeshTitle]);

  model.mesh.create('mesh1', GeomName);
  model.mesh('mesh1').label(MeshTitle);
  model.mesh('mesh1').create('edg1', 'Edge');
  model.mesh('mesh1').feature('edg1').create('dis1', 'Distribution');    


  model.mesh('mesh1').feature('edg1').feature('dis1').selection.named('plasmadomain');
  model.mesh('mesh1').feature('edg1').feature('dis1').set('type', 'number');
  model.mesh('mesh1').feature('edg1').feature('dis1').set('numelem', num2str(inp.Nelem_1D));

  model.mesh('mesh1').run;
end


