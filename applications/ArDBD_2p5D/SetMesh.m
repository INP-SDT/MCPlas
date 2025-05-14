function SetMesh

    global model GeomName inp;
    
    MeshTitle='Locally refined mesh';
    
    msg(1,['setting mesh ' MeshTitle]);  
    
    model.mesh.create('mesh1', GeomName);
    model.mesh('mesh1').create('edg1', 'Edge');  
    model.mesh('mesh1').feature('edg1').selection.geom(GeomName);

    model.mesh('mesh1').feature('edg1').create('dis1', 'Distribution');
    model.mesh('mesh1').feature('edg1').feature('dis1').selection.set([1]);    
    model.mesh('mesh1').feature('edg1').feature('dis1').set('type', 'predefined');
    model.mesh('mesh1').feature('edg1').feature('dis1').set('symmetric', 'on');
    model.mesh('mesh1').feature('edg1').feature('dis1').set('elemcount', num2str(inp.Nelem));
    model.mesh('mesh1').feature('edg1').feature('dis1').set('elemratio', '3');
    model.mesh('mesh1').run('edg1');

    model.mesh('mesh1').feature('edg1').create('dis2', 'Distribution');
    model.mesh('mesh1').feature('edg1').feature('dis2').selection.set([2]);
    model.mesh('mesh1').feature('edg1').feature('dis2').set('numelem', '6');
    
    model.mesh('mesh1').run('edg1');    
    model.mesh('mesh1').run;    

end

