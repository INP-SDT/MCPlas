function PrepPostPlasma(varargin)
%
% Use PrepPostPlasma(varargin) to prepare the post processing.
% Input parameters are as follows:
%
% varargin: arbitrary number of cut structures of the following form:
%   cut.name:   string containing the cut name
%   cut.r1:     radial position of first point
%   cut.z1:     axial position of first point
%   cut.r2:     radial position of second point
%   cut.z2:     axial position of second point
% Examples:
%   AxCut.name='AxialCut';
%   AxCut.r1 = '0'; AxCut.z1 = '0'; AxCut.r2 = '0'; AxCut.z2 = 'ElecDist';
%   RadCut.name = 'RadialCut';
%   RadCut.r1 = '0'; RadCut.z1 = '0'; RadCut.r2 = 'ElecRadius'; RadCut.z2 = '0';
%   PrepPostPlasma(AxCut,RadCut);

  global model GeomName inp;

  msg(1,'preparing plots for plasma variables');

 if strcmp(GeomName,'Geom1D') || strcmp(GeomName,'Geom1p5D')
  msg(1,sprintf('setting 1D plots for plasma variables'));
  PName='DensPlot';
  model.result.create(PName, 'PlotGroup1D');
  model.result(PName).label('Densities');

  model.result(PName).set('legendpos', 'lowerright');
  model.result(PName).set('titletype', 'manual');
  model.result(PName).set('title', ['densities ' ...
    native2unicode(hex2dec({'00' '09'}), 'unicode') '(1/m<sup>3</sup>)']);

  for i = 1:inp.Nspec
    if any(i==inp.n0Ind)            
      continue
    end    
    id       = num2str(i);
    name=inp.specnames{i};
    if strcmp(name,'e')
      name='ne';
      DensLine(PName,name,['N' id]);
    else
      DensLineFixLeg(PName,name,['N' id]);
    end
    model.result(PName).feature(name).selection.named('plasmadomain');
  end
  model.result(PName).setIndex('looplevelinput', 'last', 0);
   
 elseif strcmp(GeomName,'Geom2p5D') || strcmp(GeomName,'Geom2D')
  % surface plots  
  for i = 1:inp.Nspec
    id = num2str(i);
    if any(i==inp.n0Ind)            
      continue
    else     
      Var= ['N',id];
      specname=inp.specnames(i);
      if strcmp(specname,'e')
        DensSurfaceLog(inp,'ne', Var);
      else            
        DensSurfaceLog(inp,specname, Var);
      end
    end
  end

  MySurface(inp,'Umean',  'Umean','1','5','range(1,1,5)','1');
  MySurface(inp,'Pot',  'Phi','0','30','range(5,5,50)','2');
  msg(2,'2D graphs defined');

  nCuts=length(varargin);
  for ic=1:nCuts
    cut= varargin{ic};
    msg(2,sprintf('Cut: %s (%s,%s) - (%s,%s)', ...
        cut.name,cut.r1,cut.z1,cut.r2,cut.z2))
    cname=['cl' cut.name];
    model.result.dataset.create(cname, 'CutLine2D');
    model.result.dataset(cname).label(cut.name);
    model.result.dataset(cname).setIndex('genpoints', cut.r1, 0, 0);
    model.result.dataset(cname).setIndex('genpoints', cut.z1, 0, 1);
    model.result.dataset(cname).setIndex('genpoints', cut.r2, 1, 0);
    model.result.dataset(cname).setIndex('genpoints', cut.z2, 1, 1); 
    model.result.dataset(cname).set('data', inp.DataSet);
  
    PName=['DensPlot' cut.name];
    model.result.create(PName, 'PlotGroup1D');
    model.result(PName).label(['DensCut_' cut.name]);
    model.result(PName).set('data', cname);
    model.result(PName).set('legendpos', 'lowerright');
    model.result(PName).set('titletype', 'manual');
    model.result(PName).set('title', ['densities ' ...
        native2unicode(hex2dec({'00' '09'}), 'unicode') '(1/m<sup>3</sup>)']);
    model.result(PName).set('legendpos', 'upperleft');  

   for i = 1:inp.Nspec
    id = num2str(i);
    if any(i==inp.n0Ind)            
      continue
    else     
      Var= ['N',id];
      specname=inp.specnames(i);
      if strcmp(specname,'e')
        DensLine(PName,'ne',Var)
      else
        DensLineFixLeg(PName,specname, Var)
      end
    end
   end
  end
  model.result(PName).setIndex('looplevelinput', 'last', 0);
  msg(2,'1D axial cut defined');
 end
end

function DensSurfaceLog(inp,pg,expr)    
  global model;
  % set Density plot
  logexpr=['log10(' expr ')'];
  model.result.create(pg, 'PlotGroup2D');
  model.result(pg).label(pg);
  model.result(pg).set('data', inp.DataSet);
%  model.result(pg).set('view', 'VHideInner');
  model.result(pg).create('surf1', 'Surface');
  model.result(pg).feature('surf1').set('expr', logexpr);
  model.result(pg).create('con1', 'Contour');
  model.result(pg).feature('con1').set('expr', logexpr);
  model.result(pg).feature('con1').set('levelmethod', 'levels');
  model.result(pg).feature('con1').set('levels', 'range(10,1,20)');
  model.result(pg).feature('con1').set('coloring', 'uniform');
  model.result(pg).feature('con1').set('color', 'black');
  model.result(pg).feature('con1').set('contourlabels', 'on');
  model.result(pg).feature('con1').set('colorlegend', 'off');
  model.result(pg).feature('con1').set('labelprec', '2');
end



function DensLine(pg,Title,expr)
  global model;
  model.result(pg).create(Title, 'LineGraph');
  model.result(pg).feature(Title).label(Title);
%  model.result(pg).feature(pg).selection.named('plasmadomain');
  model.result(pg).feature(Title).set('expr', expr);
  model.result(pg).feature(Title).set('xdata', 'expr');
  model.result(pg).feature(Title).set('xdataexpr', 'z');
  model.result(pg).feature(Title).set('xdataunit', 'mm');
  model.result(pg).feature(Title).set('legend', 'on');
end

function DensLineFixLeg(pg,Title,expr)
  global model;
  model.result(pg).create(Title, 'LineGraph');
  model.result(pg).feature(Title).label(Title);
%  model.result(pg).feature(pg).selection.named('plasmadomain');
  model.result(pg).feature(Title).set('expr', expr);
  model.result(pg).feature(Title).set('xdata', 'expr');
  model.result(pg).feature(Title).set('xdataexpr', 'z');
  model.result(pg).feature(Title).set('xdataunit', 'mm');
  model.result(pg).feature(Title).set('legend', 'on');
  model.result(pg).feature(Title).set('legendmethod', 'manual');
  model.result(pg).feature(Title).setIndex('legends', Title, 0);
end

function MySurface(inp,pg,expr,Cmin,Cmax,ContourLevels,labelprec)
  global model;

 model.result.create(pg, 'PlotGroup2D');
  model.result(pg).label(pg);
  model.result(pg).set('data', inp.DataSet);
%  model.result(pg).set('view', 'VHideInner');
 model.result(pg).create('surf1', 'Surface');
  model.result(pg).feature('surf1').set('expr', expr);
  model.result(pg).feature('surf1').set('rangecoloractive', 'on');
  model.result(pg).feature('surf1').set('rangecolormin', Cmin);
  model.result(pg).feature('surf1').set('rangecolormax', Cmax);
 model.result(pg).create('con1', 'Contour');
  model.result(pg).feature('con1').set('expr', expr);
  model.result(pg).feature('con1').set('levelmethod', 'levels');
  model.result(pg).feature('con1').set('levels', ContourLevels);
  model.result(pg).feature('con1').set('coloring', 'uniform');
  model.result(pg).feature('con1').set('color', 'black');
  model.result(pg).feature('con1').set('contourlabels', 'on');
  model.result(pg).feature('con1').set('colorlegend', 'off');
  model.result(pg).feature('con1').set('labelprec', labelprec);
end

