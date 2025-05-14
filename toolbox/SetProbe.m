function SetProbe(type,ptable,pname,probes,varargin)
%
% Use SetProbe(model,ptable,pname,pvarname,expr,varargin) to set a probe.
% Input parameters are as follows:
%
% type:     probe type (global | point)
% ptable:   string containing the probe table name 
% pname:    string containing the probe name 
% probes:   string containing the probe expression(s)
% varargin: (for point probes only) strings containing the probe position
%
% Examples:
%   SetProbe('global','NewProbeTable','prob_Idischarge','Idispl+Icond')
%   SetProbe('point','PlasmaParameters','probPlasma',{'Phi','EdN'},'ElecDist/2')

  global model GeomName ModPath flags inp;
  
  if strcmp(flags.probes,'off')
    return
  end  
  
% check for correct number of arguments
  if strcmp(type,'global');
    if length(varargin)>0
      error('too many input arguments in call off SetProbe');
    end
  elseif strcmp(type,'point');
    if length(strfind(GeomName,'Geom1D'))>0 ...
        || length(strfind(GeomName,'Geom1p5D'))>0 
      if length(varargin)>1
        error('too many input arguments in call off SetProbe');
      end
    elseif length(strfind(GeomName,'Geom2p5D'))>0 ...
        || length(strfind(GeomName,'Geom2D'))>0
      if length(varargin)>2
        error('too many input arguments');
      end
    else
      error('invalid value of GeomName in SetProbe.m');
    end
  else
    error(['invalid probe type ',type,' in call of SetProbe']);
  end

% create table for probe data if necessary
  if ~IsModelMember(model.result.table.tags, ptable)
    file=[ModPath '/Results/' ptable '.txt'];
    
    model.result.table.create(ptable, 'Table');
    model.result.table(ptable).label(ptable);
    model.result.table(ptable).set('filename',file); 
    model.result.table(ptable).set('needsupdate', false);
    model.result.table(ptable).set('appliedstoretable', 'onfile');
    model.result.table(ptable).set('appliedfilename',file);   
    
    if strcmp(flags.probes,'inmodelandonfile')
      model.result.table(ptable).set('storetable', flags.probes);
    elseif strcmp(flags.probes,'onfile')
      model.result.table(ptable).set('storetable', flags.probes);
    else
      error(['wrong probe flag ' flags.probes]);
    end        
  end

% create probes
  if strcmp(type,'global');
  
    if strcmp(probes,'circuit')        
      if strcmp(flags.circuit,'off')
        SetGlobalProbe(model,ptable,'prob_Vgen','PoweredVoltage');
        SetGlobalProbe(model,ptable,'prob_Igen','Idischarge','mA');
        SetGlobalProbe(model,ptable,'prob_Vpow','PoweredVoltage');
        SetGlobalProbe(model,ptable,'prob_Icond','Icond','mA');
        SetGlobalProbe(model,ptable,'prob_Idispl','Idispl','mA');    
      else
        SetGlobalProbe(model,ptable,'prob_Vgen','GeneratorVoltage');
        SetGlobalProbe(model,ptable,'prob_Igen','Igen','mA');
        SetGlobalProbe(model,ptable,'prob_Vpow','PoweredVoltage');
        SetGlobalProbe(model,ptable,'prob_Icond','Icond','mA');
        SetGlobalProbe(model,ptable,'prob_Idispl','Idispl','mA'); 
      end      
    else
      SetGlobalProbe(model,ptable,pname,probes);
    end
    
  elseif strcmp(type,'point');

    model.probe.create(pname, 'DomainPoint');
    model.probe(pname).model('mod1');
    model.probe(pname).label(pname);
    
    model.probe(pname).feature.remove('ppb1');  
    
    if length(strfind(GeomName,'Geom1D'))>0 ...
        || length(strfind(GeomName,'Geom1p5D'))>0 
      ZPos = varargin{1};
      msg(1,sprintf('setting probe %s at (%s)',pname,ZPos));
      model.probe(pname).set('coords1', {'0'});
      model.probe(pname).setIndex('coords1', ZPos, 0, 0);
    elseif length(strfind(GeomName,'Geom2p5D'))>0 ...
        || length(strfind(GeomName,'Geom2D'))>0 
      ZPos = varargin{1};
      if length(varargin)==1
        RPos = '0';
        msg(2,sprintf('default radial probe position %s used',RPos));    
      else
        RPos = varargin{2};
      end
      msg(1,sprintf('setting probe %s at (%s,%s)', pname,RPos,ZPos));    
      model.probe(pname).setIndex('coords2', RPos, 0, 0);
      model.probe(pname).setIndex('coords2', ZPos, 0, 1);  
    else
      error('invalid value of GeomName in SetProbe.m');
    end   
    
    for k=1:length(probes)
      if strcmp(probes(k),'species')
        for i = 1:inp.Nspec
          id = num2str(i);
          if any(i==inp.n0Ind)            
            continue
          else     
            expr = ['N',id];
% specname could be added as probe label
%            specname = inp.specnames{i};
%            if i==inp.eInd
%              specname = 'ne';
%            end
            pvarname = [pname '_' expr];
            SetPointProbeVar(model,ptable,pname,pvarname,expr);
          end
        end
      else
        expr = probes{k};
        pvarname = [pname '_' expr];
        SetPointProbeVar(model,ptable,pname,pvarname,expr);
      end
    end
    
  else
    error(['invalid probe type ',type,' in call of SetProbe']);
  end

  % set properties for all probe plots
  tags = model.result.tags; num=0;
  for i=1:length(tags)
    tag = tags(i);
    if length(strfind(tag,'pg'))>0    
      num = num+1;
      model.result(tag).set('windowtitle',['Probe Plot ',num2str(num)]);
      model.result(tag).label(['Probe Plot ',num2str(num)]);
      tables = model.result(tag).feature.tags;
      for j=1:length(tables)
        model.result(tag).feature(['tblp',num2str(j)]).set('legend', 'on');
      end
      model.result(tag).run;
    end
  end
  
  msg(2,['data of probe ' pname ' stored in ' ...
    char(model.result.table(ptable).getString('filename'))]);
  
end

function SetGlobalProbe(model,ptable,pname,expr,varargin)
%
% SetGlobalProbe(model,ptable,pname,expr,varargin)
% sets a global probe. Input parameters are as follows:
%
% model:    comsol model 
% ptable:   string containing the probe table name 
% pname:    string containing the probe name 
% expr:     string (comsol expression) that is evaluated
% varargin: (optional) string containing the probe unit
 
  model.probe.create(pname, 'GlobalVariable');
  model.probe(pname).model('mod1');
  model.probe(pname).label(pname);
  model.probe(pname).set('probename', pname);
  model.probe(pname).set('descractive', 'on');
%  model.probe(pname).set('descr', pname);
  model.probe(pname).set('descr', expr);
  model.probe(pname).set('table', ptable);
  model.probe(pname).set('expr', expr);
  if length(varargin)>0
    model.probe(pname).set('unit', varargin{1});
  end

  windownum = num2str(sum(double(char(model.probe(pname).getString('unit')))));
  window = ['window' windownum];
  model.probe(pname).set('window', window);
  model.probe(pname).set('windowtitle',windownum);  
  
  model.probe(pname).genResult('none');
  
end

function SetPointProbeVar(model,ptable,pname,pvarname,expr,varargin)
%
% SetPointProbeVar(model,ptable,pname,pvarname,expr,varargin)
% sets a point probe. Input parameters are as follows:
%
% model:    comsol model 
% ptable:   string containing the probe table name 
% pname:    string containing the probe name 
% pvarname: string containing the probe variable name 
% expr:     string (comsol expression) that is evaluated
% varargin: (optional) string containing the probe unit

  model.probe(pname).feature.create(pvarname, 'PointExpr');
  model.probe(pname).feature(pvarname).label(pvarname);
  model.probe(pname).feature(pvarname).set('probename', pvarname);
  model.probe(pname).feature(pvarname).set('expr', expr);
  model.probe(pname).feature(pvarname).set('descractive', 'on');
  model.probe(pname).feature(pvarname).set('descr', expr);
  model.probe(pname).feature(pvarname).set('table', ptable);
  if length(varargin)>0
    model.probe(pname).feature(pvarname).set('unit', varargin{1});
  end  
  
  windownum = num2str(sum(double(char(model.probe(pname).feature(pvarname).getString('unit')))));
  window = ['window' windownum];
  model.probe(pname).feature(pvarname).set('window', window);
  model.probe(pname).feature(pvarname).set('windowtitle',windownum);  
  
  model.probe(pname).genResult('none');

end


