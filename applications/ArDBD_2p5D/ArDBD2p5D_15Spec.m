% Main model build script

import com.comsol.model.*
import com.comsol.model.util.*

addpath('../../Toolbox');

clear  model GeomName ModPath flags inp;
global model GeomName ModPath flags inp;

%---- SetDebugLevel ------------------------------------------------------------
  flags.debug    = 3;
%-------------------------------------------------------------------------------   

% set model name and path
ModPath = pwd;
p=strsplit(ModPath,'/');
BaseName = p(length(p));  BaseName = BaseName{1};

msg(1,sprintf('Creating model %s in %s',BaseName, ModPath));

model = ModelUtil.create('Model');
model.modelPath(ModPath);
model.name([BaseName '.mph']);
model.label(BaseName);

model.modelNode.create('mod1');

%---- SetParamaters ------------------------------------------------------------

  % set comments
  ModComment = ['Asymmetric dielectric barrier discharge in argon'];
  msg(1,ModComment);
  dlmwrite([ModPath '/Comments.txt'],ModComment,'delimiter','');
  model.comments(ModComment);
  
  % set geometry
  GeomName  = 'Geom2p5D';

  % set stabilization
  flags.LogFormulation = true;
  flags.SourceTermStab = true;
  flags.enFlux   = 'DDA53';   % DDA53 | DDAk
  flags.circuit  = 'off';     % off | RC
  flags.dielectric = true;  
  flags.probes   = 'inmodelandonfile'; % inmodelandonfile | onfile
  flags.nojac    = false;
  flags.convflux = false;
     
  % read plasma model
  inp = ReadInput('../../Plasma/input_Ar-15Species_Aleksandar/');
     
%------------------------------------------------------------------------------- 
% Comsol parameters
%------------------------------------------------------------------------------- 
    
  % geometry
  model.param.set('Geometry', '0', '_______________');
  model.param.set('ElecDist', '1.5[mm]', 'Gap width');
  model.param.set('ElecRadius', '2[mm]', 'Electrode radius');
  model.param.set('DBthickness', '0.5[mm]', 'Thickness of dielectric');  

  % discharge parameters
  model.param.set('Discharge','0', '_______________');    
  model.param.set('U0', '6[kV]', 'Applied voltage');
  model.param.set('p0', '760[Torr]', 'Constant gas pressure');  
  model.param.set('T0', '300[K]','Constant gas temperature');
  model.param.set('freq', '60[kHz]','Frequency');
  inp.AppliedVoltage = 'U0*sin(2*pi*freq*t)'; 
  
  % source term stabilization
  if flags.SourceTermStab
    model.param.set('Stabilization', '0',        '_______________');      
    model.param.set('SrcStabFac', 'N_A_const[mol]*1[m^-3*s^-1]', ...
        'Factor for source term stabilization');       
    model.param.set('SrcStabPar','1','Parameter for source term stabilization');
  end

%------------------------------------------------------------------------------- 
% Additional input variables
%------------------------------------------------------------------------------- 
 
  % number of elements in axial direction
  inp.Nelem = 900;

  % time for output
  inp.tlist='range(0,1e-8,1/freq)';

  % secondary electron emission at powered electrode (P), 
  % grounded electrode (G) and dielectric wall (W)
  inp.GammaP = 0.07;
  inp.GammaG = 0.07;
  inp.GammaW = 0;
    
  % energy of secondary electrons
  inp.UmeanSSE   = 2;
    
  % dielectric constant
  inp.epsilonr = 9;
    
    
  % reflection coefficients at powered electrode (P), 
  % grounded electrode (G) and dielectric wall (W)    
  %                  1p0 1s5 1s4 1s3 1s2 2p  2p' hl  3Sv 1Sv 3S0 1S0 Ar+  Ar2+ e
  inp.ReflectionP = [0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,5e-4,5e-4,0.3];
  inp.ReflectionG = [0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,5e-4,5e-4,0.3];
  inp.ReflectionW = [0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,0.3,5e-3,5e-3,0.7];

  % initial values
  %                 1p0  1s5  1s4  1s3  1s2  2p   2p'  hl   3Sv  1Sv  3S0  1S0  Ar+  Ar2+ e
  inp.Dspec_init = [1e12,1e12,1e12,1e12,1e12,1e12,1e12,1e12,1e12,1e12,1e12,1e12,1e12,1e12,2e12];
  
%-------------------------------------------------------------------------------   

if flags.debug>0
  inp
end

SetGeometry;
SetConstants;
SetVariables;
SetTransportCoefficients;
SetRateCoefficients;

SetFluxes_DDAn;
SetSources;

AddSurfaceChargeAccumulation;
AddPoissonEquation;
AddFluidEquations;
SetElectrical;

%SetMesh;
SetProject;

%-------------------------------------------------------------------------------

mphsave(model,[BaseName '.mph'])
msg(1,sprintf('model saved to %s.mph',BaseName));
out = model;

