%% ========================================================================
%  Main Model Build Script for COMSOL Multiphysics via MATLAB LiveLink
%  ------------------------------------------------------------------------
%  This script constructs a COMSOL model for low-temperature plasma using 
%  chemistry and general input data defined in JSON files. It sets up the 
%  full modeling environment, including physics interfaces, parameters, 
%  geometry, meshing, solvers, and postprocessing configurations.
%
%  Institution: Leibniz Institute for Plasma Science and Technology (INP)
%  Date: 03/07/2025 
% =========================================================================


%% ====================================
% === Initialization and input Load ===
% =====================================

clear inp flags model GeomName ModPath;  % Clear previous data

%inp.cfg_RKM_file = 'plasma/Ar_Stankov_2022.json'; % Define path for reaction kinetic input file
%inp.cfg_General_file = 'applications/Generic1D/General_input_data.json';
inp.cfg_RKM_file = 'plasma/Ar_Becker_2009.json'; % Define path for reaction kinetic input file
inp.cfg_General_file = 'applications/Generic1D/General_input_data_Ar4spec.json';  % Define path for general model
                                                                                  % settings input file

addpath('Toolbox');  % Add a path to make the "Toolbox" folder accessible

inp.cfg_RKM_obj = ReadJSON(inp.cfg_RKM_file);  % Load chemistry model from JSON input data
inp.cfg_General_obj = ReadJSON(inp.cfg_General_file);  % Load general model settings from JSON input data

inp = InpRKM(inp); % Initialize reaction kinetic model
flags = struct();
[inp, flags, ModellingGeo] = InpGeneral(inp, flags); % Initialize general model parameters and geometry

%% ==================================
% === COMSOL model initialization ===
% ===================================

% Import COMSOL class in order to use the ModelUtil commands
import com.comsol.model.*
import com.comsol.model.util.*

flags.debug = 3; % Set debug level

ModPath  = [pwd, '/Applications/Generic', ModellingGeo]; % Define model path
pathParts = strsplit(ModPath, '/');
BaseName = pathParts{end}; % Define base name

msg(1, sprintf('Creating model %s in %s', BaseName, ModPath), flags); % Display model creation message

% Create COMSOL model and set basic identifiers
model = ModelUtil.create('Model');
model.modelPath(ModPath);
model.name([BaseName '.mph']);
model.label(BaseName);
model.modelNode.create('mod1');

% Add project comments and write to file
ModComment = 'Low-temperature plasma modelling';
msg(1, ModComment, flags); 
dlmwrite([ModPath '/Comments.txt'], ModComment, 'delimiter', '');
model.comments(ModComment);

%% =====================
% === Display input  ===
% ======================

if flags.debug > 0
    inp  % Display the input structure
end

%% ================================
% === Core Model Setup Pipeline ===
% =================================

SetParameters(inp, flags, model);  % Set user-defined parameters

addpath(ModPath);  % Ensure application path is active

SetGeometry(inp, flags, model);  % Define geometry

addpath('Toolbox');  % Ensure Toolbox path is active

SetConstants(flags, model); % Set necessary constants
SetVariables(inp, flags, model); % Define variables
SetTransportCoefficients(inp, flags, model);  % Define transport coefficients
SetRateCoefficients(inp, flags, model);  % Define rate coefficients
SetEnergyRateCoefficients(inp, flags, model);  % Define energy rate coefficients
SetRates(inp, flags, model);  % Define reaction rates
SetEnergyRates(inp, flags, model);  % Define electron energy-related rates

SetFluxes(inp, flags, model);  % Set flux terms
SetSources(inp, flags, model);  % Set source terms

AddSurfaceChargeAccumulation(inp, flags, model);  % Add equation for surface charge accumulation
AddPoissonEquation(inp, flags, model);  % Add Poisson's equation
AddFluidEquations(inp, flags, model);  % Add fluid equations

SetElectrical(inp, flags, model);  % Configure electrical settings
SetProbesAndGraphs(inp, flags, model);  % Configure probes and plots

addpath(ModPath);  % Ensure application path is active

SetMesh(inp, flags, model);  % Generate computational mesh
SetProject(inp, flags, model);  % Finalize solver, study, and output settings

%% =========================
% === Save Model to File ===
% ==========================

mphsave(model, [ModPath, '/', BaseName '.mph']);
msg(1, sprintf('Model saved to %s.mph', BaseName), flags);

out = model;  % Export final model object

