function SetElectrical

    global model GeomName inp flags;      
    
    msg(1,'setting electrical properties');   
    
    varname = 'electrical';
    if ~IsModelMember(model.variable.tags, varname)
        model.variable.create(varname);  
        model.variable(varname).name('Electrical');
        model.variable(varname).model('mod1');    
    end

% TODO: check if current calculation is correct. Multiply / devide by 2pi? 

    if length(strfind(GeomName,'Geom1D'))>0 ...
        || length(strfind(GeomName,'Geom1p5D'))>0 
    
        model.cpl.create('intop1', 'Integration', GeomName);
        model.cpl('intop1').selection.geom(GeomName, 0);
        model.cpl('intop1').selection.named('currentprobebndry');
        model.cpl('intop1').set('opname', 'IntCPBoundary');
        model.cpl('intop1').label('IntCPBoundary');     
        
        model.variable(varname).set('Icond', ...
            'NormalChCFlux', ...
            'Conduction current');
        model.variable(varname).set('Idispl', ...
            'DisplacementCurrent', ...
            'Displacement current');

    elseif length(strfind(GeomName,'Geom2p5D'))>0 ...
        || length(strfind(GeomName,'Geom2D'))>0 
    
        model.cpl.create('intop1', 'Integration', GeomName);
        model.cpl('intop1').selection.geom(GeomName, 1);
        model.cpl('intop1').selection.named('currentprobebndry');
        model.cpl('intop1').set('axisym', 'on');
        model.cpl('intop1').set('opname', 'IntCPBoundary');
        model.cpl('intop1').label('IntCPBoundary');    
        
        model.variable(varname).set('Icond', ...
            'IntCPBoundary(NormalChCFlux)/(ElecRadius^2*pi)', ...
            'Conduction current');
        model.variable(varname).set('Idispl', ...
            'IntCPBoundary(DisplacementCurrent)/(ElecRadius^2*pi)', ...
            'Displacement current');                   
        
    else
        error('invalid value of GeomName in SetElectrical.m');
    end    

    model.variable(varname).set('Idischarge', 'Icond+Idispl', ...
        'Discharge current');
    
    % additional electrical parameters are set in AddOuterCircuit if used    
    if strcmp(flags.circuit,'off')
        msg(1,['outer circuit not included']);
        model.variable(varname).set('PoweredVoltage', inp.AppliedVoltage, ...
            'Powered voltage');
    end        
    
end      

