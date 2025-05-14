function SetGeometry

    global model GeomName inp flags;
    
    if length(strfind(GeomName,'Geom1D'))>0
    
        if flags.dielectric == 1
        
            GeomTitle = '1D planparallel with one dielectric';
            msg(1,['setting geometry ' GeomTitle]);
    
            % build geometry       
            model.geom.create(GeomName, 1);
            model.geom(GeomName).label(GeomTitle);
            model.geom(GeomName).lengthUnit('m');
            model.frame('material1').coord(1, 'z');
            model.frame('material1').coord(3, 'x');                
            model.geom(GeomName).feature.create('i1', 'Interval');
            model.geom(GeomName).feature('i1').set('intervals', 'many');
            model.geom(GeomName).feature('i1').set('p', '0, ElecDist, ElecDist+DBthickness_1');

            model.geom(GeomName).runAll;
            model.geom(GeomName).run; 
    
            % initialize selections (1=Domain, 0=Boundary)
            SetSelection(1,'plasmadomain','Plasma domain',1);
            SetSelection(1,'dielectric','Dielectric',2);
            SetSelection(0,'plasmaboundaries','Plasma boundaries',[1 2]);
            SetSelection(0,'poweredelectrode','Powered electrode',1);
            SetSelection(0,'groundedelectrode','Grounded electrode',3);
            SetSelection(0,'currentprobebndry','Current probe boundary',2);
            SetSelection(0,'electrodes','Electrodes',[1 3]);
            SetSelection(0,'dielectricwalls','Dielectric walls',2);   
            
        elseif flags.dielectric == 2
        
            GeomTitle = '1D planparallel with two dielectrics';
            msg(1,['setting geometry ' GeomTitle]);
    
            % build geometry       
            model.geom.create(GeomName, 1);
            model.geom(GeomName).label(GeomTitle);
            model.geom(GeomName).lengthUnit('m');
            model.frame('material1').coord(1, 'z');
            model.frame('material1').coord(3, 'x');                
            model.geom(GeomName).feature.create('i1', 'Interval');
            model.geom(GeomName).feature('i1').set('intervals', 'many');
            model.geom(GeomName).feature('i1').set('p', '0, DBthickness_1, ElecDist+DBthickness_1, ElecDist+DBthickness_1+DBthickness_2');

            model.geom(GeomName).runAll;
            model.geom(GeomName).run; 
    
            % initialize selections (1=Domain, 0=Boundary)
            SetSelection(1,'plasmadomain','Plasma domain',2);
            SetSelection(1,'dielectric_1','Dielectric 1',1);
            SetSelection(1,'dielectric_2','Dielectric 2',3);
            SetSelection(1,'dielectric','Dielectric',[1,3]);
            SetSelection(0,'plasmaboundaries','Plasma boundaries',[2 3]);
            SetSelection(0,'poweredelectrode','Powered electrode',1);
            SetSelection(0,'groundedelectrode','Grounded electrode',4);
            SetSelection(0,'currentprobebndry','Current probe boundary',2);
            SetSelection(0,'electrodes','Electrodes',[1 4]);
            SetSelection(0,'dielectricwall_1','Dielectric wall 1',2);
            SetSelection(0,'dielectricwall_2','Dielectric wall 2',3);
            SetSelection(0,'dielectricwalls','Dielectric walls',[2 3]);
        else
               
          
            GeomTitle='1D planparallel without dielectric';
            msg(1,['setting geometry ' GeomTitle]);
    
            % build geometry       
            model.geom.create(GeomName, 1);
            model.geom(GeomName).label(GeomTitle);
            model.geom(GeomName).lengthUnit('m');

            model.frame('material1').coord(1, 'z');
            model.frame('material1').coord(3, 'x');            
    
            model.geom(GeomName).feature.create('i1', 'Interval');
            model.geom(GeomName).feature('i1').set('p2', 'ElecDist');

            model.geom(GeomName).runAll;
            model.geom(GeomName).run; 
            % initialize selections (1=Domain, 0=Boundary)
            SetSelection(1,'plasmadomain','Plasma domain',1);
            SetSelection(0,'plasmaboundaries','Plasma boundaries',[1 2]);
            SetSelection(0,'poweredelectrode','Powered electrode',1);
            SetSelection(0,'groundedelectrode','Grounded electrode',2);
            SetSelection(0,'currentprobebndry','Current probe boundary',2);
            msg(2,'Anode is grounded and current probe')
            SetSelection(0,'electrodes','Electrodes',[1 2]);
            
        end;
        
    elseif length(strfind(GeomName,'Geom1p5D'))>0
        if flags.dielectric == 1
        
            GeomTitle = '1D axisymmetric with one dielectric';
            msg(1,['setting geometry ' GeomTitle]);
    
            % build geometry       
            model.geom.create(GeomName, 1);
            model.geom(GeomName).label(GeomTitle);
            model.geom(GeomName).lengthUnit('m');
            model.geom(GeomName).axisymmetric(true);
            model.frame('material1').coord(1, 'r');
            model.frame('material1').coord(3, 'z');                
            model.geom(GeomName).feature.create('i1', 'Interval');
            model.geom(GeomName).feature('i1').set('intervals', 'many');
            model.geom(GeomName).feature('i1').set('p', '0, ElecDist, ElecDist+DBthickness_1');

            model.geom(GeomName).runAll;
            model.geom(GeomName).run; 
    
            % initialize selections (1=Domain, 0=Boundary)
            SetSelection(1,'plasmadomain','Plasma domain',1);
            SetSelection(1,'dielectric','Dielectric',2);
            SetSelection(0,'plasmaboundaries','Plasma boundaries',[1 2]);
            SetSelection(0,'poweredelectrode','Powered electrode',1);
            SetSelection(0,'groundedelectrode','Grounded electrode',3);
            SetSelection(0,'currentprobebndry','Current probe boundary',2);
            SetSelection(0,'electrodes','Electrodes',[1 3]);
            SetSelection(0,'dielectricwalls','Dielectric walls',2);
            
        elseif flags.dielectric == 2
        
            GeomTitle = '1D axisymmetric with two dielectrics';
            msg(1,['setting geometry ' GeomTitle]);
    
            % build geometry       
            model.geom.create(GeomName, 1);
            model.geom(GeomName).label(GeomTitle);
            model.geom(GeomName).lengthUnit('m');
            model.geom(GeomName).axisymmetric(true);
            model.frame('material1').coord(1, 'r');
            model.frame('material1').coord(3, 'z');                
            model.geom(GeomName).feature.create('i1', 'Interval');
            model.geom(GeomName).feature('i1').set('intervals', 'many');
            model.geom(GeomName).feature('i1').set('p', '0, DBthickness_1, ElecDist+DBthickness_1, ElecDist+DBthickness_1+DBthickness_2');

            model.geom(GeomName).runAll;
            model.geom(GeomName).run; 
    
            % initialize selections (1=Domain, 0=Boundary)
            SetSelection(1,'plasmadomain','Plasma domain',2);
            SetSelection(1,'dielectric_1','Dielectric 1',1);
            SetSelection(1,'dielectric_2','Dielectric 2',3);
            SetSelection(1,'dielectric','Dielectric',[1,3]);
            SetSelection(0,'plasmaboundaries','Plasma boundaries',[2 3]);
            SetSelection(0,'poweredelectrode','Powered electrode',1);
            SetSelection(0,'groundedelectrode','Grounded electrode',4);
            SetSelection(0,'currentprobebndry','Current probe boundary',2);
            SetSelection(0,'electrodes','Electrodes',[1 4]);
            SetSelection(0,'dielectricwall_1','Dielectric wall 1',2);
            SetSelection(0,'dielectricwall_2','Dielectric wall 2',3);
            SetSelection(0,'dielectricwalls','Dielectric walls',[2 3])
            
       
            
        else 
               
          
            GeomTitle='1D planparallel without dielectric';
            msg(1,['setting geometry ' GeomTitle]);
    
            % build geometry       
            model.geom.create(GeomName, 1);
            model.geom(GeomName).label(GeomTitle);
            model.geom(GeomName).lengthUnit('m');

            model.geom(GeomName).axisymmetric(true);
            model.frame('material1').coord(1, 'r');
            model.frame('material1').coord(3, 'z');             
    
            model.geom(GeomName).feature.create('i1', 'Interval');
            model.geom(GeomName).feature('i1').set('p2', 'ElecDist');

            model.geom(GeomName).runAll;
            model.geom(GeomName).run; 
            % initialize selections (1=Domain, 0=Boundary)
            SetSelection(1,'plasmadomain','Plasma domain',1);
            SetSelection(0,'plasmaboundaries','Plasma boundaries',[1 2]);
            SetSelection(0,'poweredelectrode','Powered electrode',1);
            SetSelection(0,'groundedelectrode','Grounded electrode',2);
            SetSelection(0,'currentprobebndry','Current probe boundary',2);
            msg(2,'Anode is grounded and current probe')
            SetSelection(0,'electrodes','Electrodes',[1 2]);
            
       end;
            
       
        
    elseif length(strfind(GeomName,'Geom2D'))>0
        
        if flags.dielectric == 1
        
            GeomTitle = '2D planparallel with one dielectric';
            msg(1,['setting geometry ' GeomTitle]);
    
            % build geometry       
            model.geom.create(GeomName, 2);
            model.geom(GeomName).label(GeomTitle);
            model.geom(GeomName).lengthUnit('m');
            model.geom(GeomName).axisymmetric(false);
            model.geom(GeomName).feature.create('r1', 'Rectangle');
            model.geom(GeomName).feature('r1').setIndex('size', 'ElecRadius', 0);
            model.geom(GeomName).feature('r1').setIndex('size', 'ElecDist', 1);
            model.geom(GeomName).feature.create('r2', 'Rectangle');
            model.geom(GeomName).feature('r2').setIndex('size', 'ElecRadius', 0);
            model.geom(GeomName).feature('r2').setIndex('size', 'DBthickness_1', 1);
            model.geom(GeomName).feature('r2').setIndex('pos', 'ElecDist', 1);
            model.geom(GeomName).runAll;

            % set selections
            model.geom(GeomName).run;

            % initialize selections (1=Domain, 0=Boundary)
            SetSelection(2,'plasmadomain','Plasma domain',1);
            SetSelection(2,'dielectric','Dielectric',2);
            SetSelection(1,'plasmaboundaries','Plasma boundaries',[1 2 4 6]);
            SetSelection(1,'poweredelectrode','Powered electrode',2);
            SetSelection(1,'currentprobebndry','Current probe boundary',4);
            SetSelection(1,'groundedelectrode','Grounded electrode',5);
            msg(2,'Anode is grounded and current probe')
            SetSelection(1,'electrodes','Electrodes',[2 5]);
            SetSelection(1,'dielectricwalls','Dielectric walls',4);   
            
        elseif flags.dielectric == 2
        
            GeomTitle = '2D planparallel with two dielectrics';
            msg(1,['setting geometry ' GeomTitle]);
    
            % build geometry       
            model.geom.create(GeomName, 2);
            model.geom(GeomName).label(GeomTitle);
            model.geom(GeomName).lengthUnit('m');
            model.geom(GeomName).axisymmetric(false);
            model.geom(GeomName).feature.create('r1', 'Rectangle');
            model.geom(GeomName).feature('r1').setIndex('size', 'ElecRadius', 0);
            model.geom(GeomName).feature('r1').setIndex('size', 'DBthickness_1', 1);
            model.geom(GeomName).feature.create('r2', 'Rectangle');
            model.geom(GeomName).feature('r2').setIndex('size', 'ElecRadius', 0);
            model.geom(GeomName).feature('r2').setIndex('size', 'ElecDist', 1);
            model.geom(GeomName).feature('r2').setIndex('pos', 'DBthickness_1', 1);
            model.geom(GeomName).feature.create('r3', 'Rectangle');
            model.geom(GeomName).feature('r3').setIndex('size', 'ElecRadius', 0);
            model.geom(GeomName).feature('r3').setIndex('size', 'DBthickness_2', 1);
            model.geom(GeomName).feature('r3').setIndex('pos', 'ElecDist+DBthickness_1', 1);
            
            model.geom(GeomName).runAll;

            % set selections
            model.geom(GeomName).run;

            % initialize selections (1=Domain, 0=Boundary)
            SetSelection(2,'plasmadomain','Plasma domain',2);
            SetSelection(2,'dielectric_1','Dielectric 1',1);
            SetSelection(2,'dielectric_2','Dielectric 2',3);
            SetSelection(2,'dielectric','Dielectric',[1 3]);
            SetSelection(1,'plasmaboundaries','Plasma boundaries',[3 4 6 9]);
            SetSelection(1,'poweredelectrode','Powered electrode',2);
            SetSelection(1,'currentprobebndry','Current probe boundary',4);
            SetSelection(1,'groundedelectrode','Grounded electrode', 7);
            msg(2,'Anode is grounded and current probe')
            SetSelection(1,'electrodes','Electrodes',[2 7]);
            SetSelection(1,'dielectricwall_1','Dielectric wall 1',4);
            SetSelection(1,'dielectricwall_2','Dielectric wall 2',6);
            SetSelection(1,'dielectricwalls','Dielectric walls',[4 6]); 
          
            
        else
                       
            GeomTitle='2D planparallel without dielectric';
            msg(1,['setting geometry ' GeomTitle]);
    
            % build geometry       
            model.geom.create(GeomName, 2);
            model.geom(GeomName).label(GeomTitle);
            model.geom(GeomName).lengthUnit('m');
            model.geom(GeomName).axisymmetric(false);
            model.geom(GeomName).feature.create('r1', 'Rectangle');
            model.geom(GeomName).feature('r1').setIndex('size', 'ElecRadius', 0);
            model.geom(GeomName).feature('r1').setIndex('size', 'ElecDist', 1);
            model.geom(GeomName).runAll;

            % set selections
            model.geom(GeomName).run;

            % initialize selections (1=Domain, 0=Boundary)
            SetSelection(2,'plasmadomain','Plasma domain',1);
            SetSelection(1,'plasmaboundaries','Plasma boundaries',[1,2 3 4]);
            SetSelection(1,'poweredelectrode','Powered electrode',2);
            SetSelection(1,'currentprobebndry','Current probe boundary',3);
            SetSelection(1,'groundedelectrode','Grounded electrode',3);
            msg(2,'Anode is grounded and current probe')
            SetSelection(1,'electrodes','Electrodes',[2 3]);
        end;
    
    elseif length(strfind(GeomName,'Geom2p5D'))>0
        if flags.dielectric == 1
        
            GeomTitle = '2D axisymmetric with dielectric';
            msg(1,['setting geometry ' GeomTitle]);
    
            % build geometry       
            
            model.geom.create(GeomName, 2);
            model.geom(GeomName).label(GeomTitle);
            model.geom(GeomName).lengthUnit('m');
            model.geom(GeomName).axisymmetric(true);
            model.geom(GeomName).feature.create('r1', 'Rectangle');
            model.geom(GeomName).feature('r1').setIndex('size', 'ElecRadius', 0);
            model.geom(GeomName).feature('r1').setIndex('size', 'ElecDist', 1);
            model.geom(GeomName).feature.create('r2', 'Rectangle');
            model.geom(GeomName).feature('r2').setIndex('size', 'ElecRadius', 0);
            model.geom(GeomName).feature('r2').setIndex('size', 'DBthickness_1', 1);
            model.geom(GeomName).feature('r2').setIndex('pos', 'ElecDist', 1);
            model.geom(GeomName).runAll;


            % set selections
            model.geom(GeomName).run;

            % initialize selections (1=Domain, 0=Boundary)
            SetSelection(2,'plasmadomain','Plasma domain',1);
            SetSelection(2,'dielectric','Dielectric',2);
            SetSelection(1,'plasmaboundaries','Plasma boundaries',[2 4 6]);
            SetSelection(1,'poweredelectrode','Powered electrode',2);
            SetSelection(1,'currentprobebndry','Current probe boundary',4);
            SetSelection(1,'groundedelectrode','Grounded electrode',5);
            msg(2,'Anode is grounded and current probe')
            SetSelection(1,'electrodes','Electrodes',[2 5]);
            SetSelection(1,'dielectricwalls','Dielectric walls',4);
            
        elseif flags.dielectric == 2
        
            GeomTitle = '2D axisymmetric with two dielectrics';
            msg(1,['setting geometry ' GeomTitle]);
    
            % build geometry
            model.geom.create(GeomName, 2);
            model.geom(GeomName).label(GeomTitle);
            model.geom(GeomName).lengthUnit('m');
            model.geom(GeomName).axisymmetric(true);
            model.geom(GeomName).feature.create('r1', 'Rectangle');
            model.geom(GeomName).feature('r1').setIndex('size', 'ElecRadius', 0);
            model.geom(GeomName).feature('r1').setIndex('size', 'DBthickness_1', 1);
            model.geom(GeomName).feature.create('r2', 'Rectangle');
            model.geom(GeomName).feature('r2').setIndex('size', 'ElecRadius', 0);
            model.geom(GeomName).feature('r2').setIndex('size', 'ElecDist', 1);
            model.geom(GeomName).feature('r2').setIndex('pos', 'DBthickness_1', 1);
            model.geom(GeomName).feature.create('r3', 'Rectangle');
            model.geom(GeomName).feature('r3').setIndex('size', 'ElecRadius', 0);
            model.geom(GeomName).feature('r3').setIndex('size', 'DBthickness_2', 1);
            model.geom(GeomName).feature('r3').setIndex('pos', 'ElecDist+DBthickness_1', 1);
            model.geom(GeomName).runAll;
            % set selections
            model.geom(GeomName).run;

            % initialize selections (1=Domain, 0=Boundary)
            SetSelection(2,'plasmadomain','Plasma domain',2);
            SetSelection(2,'dielectric_1','Dielectric 1',1);
            SetSelection(2,'dielectric_2','Dielectric 2',3);
            SetSelection(2,'dielectric','Dielectric',[1 3]);
            SetSelection(1,'plasmaboundaries','Plasma boundaries',[4 6 9]);
            SetSelection(1,'poweredelectrode','Powered electrode',2);
            SetSelection(1,'currentprobebndry','Current probe boundary',4);
            SetSelection(1,'groundedelectrode','Grounded electrode',7);
            msg(2,'Anode is grounded and current probe')
            SetSelection(1,'electrodes','Electrodes',[2 7]);
            SetSelection(1,'dielectricwall_1','Dielectric wall 1',4);
            SetSelection(1,'dielectricwall_2','Dielectric wall 2',6);
            SetSelection(1,'dielectricwalls','Dielectric walls',[4 6]);
                            
            
        else
                       
            GeomTitle='2D axisymmetric without dielectric';
            msg(1,['setting geometry ' GeomTitle]);
    
            % build geometry       
            model.geom.create(GeomName, 2);
            model.geom(GeomName).label(GeomTitle);
            model.geom(GeomName).lengthUnit('m');
            model.geom(GeomName).axisymmetric(true);
            model.geom(GeomName).feature.create('r1', 'Rectangle');
            model.geom(GeomName).feature('r1').setIndex('size', 'ElecRadius', 0);
            model.geom(GeomName).feature('r1').setIndex('size', 'ElecDist', 1);
            model.geom(GeomName).runAll;

            % set selections
            model.geom(GeomName).run;

            % initialize selections (1=Domain, 0=Boundary)
            SetSelection(2,'plasmadomain','Plasma domain',1);
            SetSelection(1,'plasmaboundaries','Plasma boundaries',[2 3 4]);
            SetSelection(1,'poweredelectrode','Powered electrode',2);
            SetSelection(1,'currentprobebndry','Current probe boundary',3);
            SetSelection(1,'groundedelectrode','Grounded electrode',3);
            msg(2,'Anode is grounded and current probe')
            SetSelection(1,'electrodes','Electrodes',[2 3]);
        end;
        
    
end
