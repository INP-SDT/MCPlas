function SetMesh

% a fun function
%
% :param U0: the first input
% :param freq: the second input
% :param freq: the third input
% :returns: ``[U]`` some outputs   

  global model GeomName inp;
  
  MeshTitle='Geometric_2D';
    
  msg(1,['setting mesh ' MeshTitle]);

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


