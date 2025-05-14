function SetGeometry

    global model GeomName;
    
    GeomTitle = 'Geometry';
    msg(1,['setting geometry ' GeomTitle]);
    
    % build geometry       
    model.geom.create(GeomName, 2);
    model.geom(GeomName).label(GeomTitle);
    model.geom(GeomName).axisymmetric(true);

    model.geom(GeomName).create('r1', 'Rectangle');
    model.geom(GeomName).feature('r1').label('Domain');
    model.geom(GeomName).feature('r1').setIndex('size', '2*ElecRadius', 0);
    model.geom(GeomName).feature('r1').setIndex('size', '2*ElecRadius+ElecDist', 1);    
    model.geom(GeomName).feature('r1').setIndex('pos', '-ElecRadius', 1);
    model.geom(GeomName).run('r1');  
    
    model.geom(GeomName).create('r2', 'Rectangle');
    model.geom(GeomName).feature('r2').label('PoweredElectrode');    
    model.geom(GeomName).feature('r2').set('size', {'ElecRadius' 'ElecRadius'});
    model.geom(GeomName).feature('r2').set('pos', {'0' '-ElecRadius'});
    model.geom(GeomName).run('r2');
    
    model.geom(GeomName).create('r3', 'Rectangle');
    model.geom(GeomName).feature('r3').label('Dielectric');        
    model.geom(GeomName).feature('r3').set('size', {'ElecRadius' 'ElecRadius'});
    model.geom(GeomName).feature('r3').set('pos', {'0' 'ElecDist'});
    model.geom(GeomName).run('r3');
    
    model.geom(GeomName).create('r4', 'Rectangle');
    model.geom(GeomName).feature('r4').label('GroundedElectrode');    
    model.geom(GeomName).feature('r4').set('size', {'ElecRadius-DBthickness' 'ElecRadius-DBthickness'});
    model.geom(GeomName).feature('r4').set('pos', {'0' 'ElecDist+DBthickness'});
    model.geom(GeomName).run('r4');
    
    model.geom(GeomName).create('dif1', 'Difference');
    model.geom(GeomName).feature('dif1').selection('input').set({'r1' 'r3'});
    model.geom(GeomName).feature('dif1').selection('input2').set({'r2' 'r4'});
    model.geom(GeomName).runPre('fin');
    
    model.geom(GeomName).create('fil1', 'Fillet');    
    model.geom(GeomName).feature('fil1').selection('point').set('dif1', [4]);
    model.geom(GeomName).feature('fil1').set('radius', 'ElecRadius-DBthickness');
    model.geom(GeomName).run('fil1');
    
    model.geom(GeomName).create('fil2', 'Fillet');    
    model.geom(GeomName).feature('fil2').selection('point').set('fil1', [6 7]);    
    model.geom(GeomName).feature('fil2').set('radius', 'ElecRadius');
    model.geom(GeomName).run('fil2');    
         
    model.geom(GeomName).runAll;
    model.geom(GeomName).run;
    
    % initialize selections (1=Domain, 0=Boundary)
    SetSelection(2,'plasmadomain','Plasma domain',[1]);
    SetSelection(2,'dielectric','Dielectric',[2]);
    SetSelection(1,'plasmaboundaries','Plasma boundaries',[7 8]);
    SetSelection(1,'poweredelectrode','Powered electrode',[7]);
    SetSelection(1,'groundedelectrode','Grounded electrode',[9]);
    SetSelection(1,'currentprobebndry','Current probe boundary',[8]);
    SetSelection(1,'electrodes','Electrodes',[7 9]);
    SetSelection(1,'dielectricwalls','Dielectric walls',[8]);    
    
    
end
