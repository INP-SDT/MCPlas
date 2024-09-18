function SetGeometry

% a fun function
%
% :param U0: the first input
% :param freq: the second input
% :param freq: the third input
% :returns: ``[U]`` some outputs   

    global model GeomName inp flags;
    
   
    
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
            
        end
        
   
end
