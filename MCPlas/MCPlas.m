% Main model build script

import com.comsol.model.*
import com.comsol.model.util.*

addpath('Toolbox');

clear  model GeomName ModPath flags inp;
global model GeomName ModPath flags inp;

%---- SetDebugLevel ------------------------------------------------------------
  flags.debug    = 3;
%-------------------------------------------------------------------------------   

% define modelling geometry

ModellingGeo  = '2p5D'; % 1D | 1p5D | 2D | 2p5D

% set model name and path
ModPath = [pwd,'/Applications/Generic',ModellingGeo];
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
ModComment = ['Dielectric barrier discharge in argon'];
msg(1,ModComment);
dlmwrite([ModPath '/Comments.txt'],ModComment,'delimiter','');
model.comments(ModComment);
  
% set geometry
GeomName  = ['Geom', ModellingGeo]; 

% set various properties of the model
flags.LogFormulation = true;   % true | false
flags.SourceTermStab = true;   % true | false
flags.enFlux   = 'DDAc';   % DDAn | DDA53 | DDAc
flags.circuit  = 'RC';    % off | RC
flags.dielectric = 2;   % 0 | 1 | 2   (number of dielectric layers)
flags.nojac    = false;   % true | false
flags.convflux = 'off';   % on | off
  
% read plasma model
inp = ReadInput('Plasma/input_Ar-4Species/');
%------------------------------------------------------------------------------- 
% Comsol parameters
%------------------------------------------------------------------------------- 
    
% geometry
model.param.set('Geometry', '0', '_______________');
model.param.set('ElecDist', '3.5[mm]', 'Gap width');
model.param.set('ElecRadius', '0.5642[cm]', 'Electrode radius');
  
  
model.param.set('DBthickness_1', '0.5[mm]', 'Thickness of dielectric_1'); % for the cases flags.dielectric = 1 and flags.dielectric = 2 
model.param.set('DBthickness_2', '1.5[mm]', 'Thickness of dielectric_2'); % only for the case flags.dielectric = 2

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
 
% number of elements in plasma domain for 1D and 1p5D
inp.Nelem_1D = 100;

% maximum element size in plasma domain in meters for 2D and 2p5D
inp.Nelem_2D = 1e-4;

% time for output
inp.tlist='range(0,1e-8,1/freq)';

% secondary electron emission at powered electrode (P), 
% grounded electrode (G) and dielectric wall (W)
inp.GammaP = 0.07;
inp.GammaG = 0.07;
inp.GammaW_1 = 0.02; % only for the cases flags.dielectric = 1 and flags.dielectric = 2 
inp.GammaW_2 = 0.03; % only for the case flags.dielectric = 2
    
% energy of secondary electrons
inp.UmeanSSE   = 2;  % energy of secondary electrons at electrode (P)
  
inp.UmeanSSE_1   = 3;  % energy of secondary electrons at dielectric surface_1
inp.UmeanSSE_2   = 4;  % energy of secondary electrons at dielectric surface_2
    
% dielectric constant
inp.epsilonr_1 = 4;  % relative permittivity of dielectric layer 1
inp.epsilonr_2 = 9;  % relative permittivity of dielectric layer 2

    
% reflection coefficients at powered electrode (P), 
% grounded electrode (G) and dielectric wall (W)    
%                  Ar  Ar* Ar+  e 
inp.ReflectionP = [0.3,0.3,5e-4,0.3];
inp.ReflectionG = [0.3,0.3,5e-4,0.3];
inp.ReflectionW_1 = [0.3,0.3,5e-3,0.7];
inp.ReflectionW_2 = [0.3,0.3,5e-3,0.4];

% initial values
%                 Ar   Ar*  Ar+  e
inp.Dspec_init = [1e12,1e12,1e12,1e12];
  
%-------------------------------------------------------------------------------   

if flags.debug>0
  inp
end

addpath(ModPath);
SetGeometry;

addpath('Toolbox');
SetConstants;
SetVariables;
SetTransportCoefficients;
SetRateCoefficients;

SetFluxes;
SetSources;

AddSurfaceChargeAccumulation;
AddPoissonEquation;
AddFluidEquations;
SetElectrical;

addpath(ModPath);
SetMesh;
SetProject;

%-------------------------------------------------------------------------------

mphsave(model,[ModPath,'/',BaseName '.mph'])
msg(1,sprintf('model saved to %s.mph',BaseName));
out = model;

