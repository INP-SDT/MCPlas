function [inp, flags, ModellingGeo] = InpGeneral(inp, flags)
    %
    % The InpGeneral function extracts general input parameters from the 
    % JSON-derived object and appends required fields to the input structures 
    % used for COMSOL model configuration.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :returns: inp, flags, ModellingGeo

    %% ====================================================
    % === Check compatibility of the species defined in ===
    % =======JSON RKM and JSON General input files ========
    % =====================================================
    temp = inp.cfg_General_obj.medium.properties.spec_prop;

    for i=1:numel(temp.background_gas)
        specnames_general(i) = string(temp.background_gas(i).name);
    end

    for i=1:numel(temp.heavy_spec)
        specnames_general(i+numel(temp.background_gas)) = string(temp.heavy_spec(i).name);
    end

    if length(inp.specnames) > length(specnames_general) + 1
        error(['A discrepancy exists in species count:' ...
            ' the General JSON file contains fewer species than the RKM JSON file']);
    elseif length(inp.specnames) < length(specnames_general) + 1
        error(['A discrepancy exists in species count:' ...
            ' the General JSON file contains more species than the RKM JSON file']);
    else
        for i=1:length(inp.specnames)
            if ismember(inp.specnames(i), ["e", "ele", "electron"])
                % Do nothing
            else
                for j=1:length(specnames_general)
                    if strcmp(inp.specnames(i),specnames_general{j}) 
                        id = i;
                        break;
                    else
                        id = 0;
                    end
                end
                if id == 0
                    error(['Species ', char(inp.specnames(i)), ...
                        ' is not defined in JSON General input data.']);
                end
            end
        end
    end
    
    %% ===============================================
    % === Define properties of Fluid-Poisson model ===
    % ================================================

    temp = inp.cfg_General_obj.diagnostics.diagnostic_properties.diagnostic_settings;
    ModellingGeo = temp.spatial_dimensions;  % Geometry: 1D, 1p5D, 2D, 2p5D
    inp.GeomName  = ['Geom', ModellingGeo];  % Define geometry name 
    flags.enFlux = temp.electron_flux;  % Electron flux flag
    flags.LogFormulation = temp.log_formulation;  % Log formulation flag
    flags.SourceTermStab = temp.stabilization;  % Source stabilization flag
    flags.nojac = temp.nojac;  % "nojac" operator flag
    inp.General.num_elem_1D = temp.element_number;  % 1D mesh resolution
    inp.General.size_elem_2D = temp.element_size;   % 2D mesh resolution
    inp.tlist = sprintf('range(%.*e, %.*e, %.*e)', 10,  temp.start_time, 10, ...
        temp.time_step, 10, temp.end_time);  % time points list for output
    
    %% ====================================================
    % === Define properties of considered plasma source ===
    % =====================================================

    temp = inp.cfg_General_obj.source.properties.geometry_settings;
    inp.General.ele_distance = temp.gap_distance;  % Electrode gap distance
    inp.General.rec_ele_length = temp.rect_electode.ele_length;  % Electrode length
    inp.General.rec_ele_width = temp.rect_electode.ele_width;  % Electrode width
    inp.General.circ_ele_radius = temp.circ_electrode.ele_radius;  % Electrode radius
    inp.General.coax_inner_ele_radius = temp.coax_eletrode.inner_ele_radius;  % Outer radius of inner electrode
    inp.General.coax_outer_ele_radius = temp.coax_eletrode.outer_ele_radius;  % Inner radius of outer electrode
    inp.General.coax_ele_length = temp.coax_eletrode.ele_length;  % Electrode length
    inp.General.diel_thickness_powered = temp.diel_thickness_powered;  % Thickness of dielectric on powered electrode
    inp.General.diel_thickness_grounded = temp.diel_thickness_grounded;  % Thickness of dielectric on grounded electrode

    temp = inp.cfg_General_obj.source.properties.source_settings;
    inp.General.app_voltage = temp.elec_prop.applied_voltage;  % Applied voltage value
    inp.General.volt_freq = temp.elec_prop.voltage_frequency;  % Voltage frequency

    if inp.General.volt_freq == 0  % Case: DC
        inp.AppliedVoltage = 'U0';                             
    else  % Case: AC
        inp.AppliedVoltage = 'U0*sin(2*pi*freq*t)';             
    end

    inp.General.permit_diel1 = temp.mat_prop.perm_diel_powered;   % Permittivity of dielectric on powered electrode
    inp.General.permit_diel2 = temp.mat_prop.perm_diel_grounded;  % Permittivity of dielectric on grounded electrode

    % Gas property configuration
    temp = inp.cfg_General_obj.medium.properties.gas_properties;
    inp.General.gas_pressure = temp.pressure;  % Set constant gas pressure
    inp.General.gas_temperature = temp.temperature;  % Set constant gas temperature

    %% =========================================
    % === Define particle species properties ===
    % ==========================================

    % Secondary electoron emission coefficients
    % -----------------------------------------
    
    temp = inp.cfg_General_obj.medium.properties.spec_prop.electron; 
    
    inp.GammaP = temp.sec_emiss_coeff.ele_powered;  % At powered electrode
    inp.GammaG = temp.sec_emiss_coeff.ele_grounded;  % At grounded electrode
    inp.GammaW_1 = temp.sec_emiss_coeff.diel_powered;  % At dielectric on powered electrode
    inp.GammaW_2 = temp.sec_emiss_coeff.diel_grounded;  % At dielectric on grounded electrode
    
    % Energy of secondary electrons
    % -----------------------------

    inp.UmeanSEP = temp.sec_ele_energy.ele_powered;  % At powered electrode
    inp.UmeanSEG = temp.sec_ele_energy.ele_grounded;  % At grounded electrode
    inp.UmeanSEW_1 = temp.sec_ele_energy.diel_powered;  % At dielectric on powered electrode
    inp.UmeanSEW_2 = temp.sec_ele_energy.diel_grounded;  % At dielectric on grounded electrode

    % Species reflection coefficient
    % ------------------------------

    temp = inp.cfg_General_obj.medium.properties.spec_prop;

    % Initialize reflection coefficient arrays
    inp.ReflectionP   = zeros(1, length(inp.specnames));  % Powered electrode
    inp.ReflectionG   = zeros(1, length(inp.specnames));  % Grounded electrode
    inp.ReflectionW_1 = zeros(1, length(inp.specnames));  % Dielectric (powered side)
    inp.ReflectionW_2 = zeros(1, length(inp.specnames));  % Dielectric (grounded side)

    % Loop through species and assign reflection data
    for i = 1:length(inp.specnames)
        species_name = inp.specnames{i};
        is_matched = false;

        % Background gas
        for j = 1:numel(temp.background_gas)
            if strcmp(species_name, temp.background_gas(j).name)
                inp.ReflectionP(i)   = 0;
                inp.ReflectionG(i)   = 0;
                inp.ReflectionW_1(i) = 0;
                inp.ReflectionW_2(i) = 0;
                is_matched = true;
                break;
            end
        end

        % Heavy species
        if ~is_matched
            for j = 1:numel(temp.heavy_spec)
                if strcmp(species_name, temp.heavy_spec(j).name)
                    inp.ReflectionP(i)   = temp.heavy_spec(j).refl_ele_powered;
                    inp.ReflectionG(i)   = temp.heavy_spec(j).refl_ele_grounded;
                    inp.ReflectionW_1(i) = temp.heavy_spec(j).refl_diel_powered;
                    inp.ReflectionW_2(i) = temp.heavy_spec(j).refl_diel_grounded;
                    is_matched = true;
                    break;
                end
            end
        end

        % Electron
        if ~is_matched
            inp.ReflectionP(i)   = temp.electron.refl_coeff.ele_powered;
            inp.ReflectionG(i)   = temp.electron.refl_coeff.ele_grounded;
            inp.ReflectionW_1(i) = temp.electron.refl_coeff.diel_powered;
            inp.ReflectionW_2(i) = temp.electron.refl_coeff.diel_grounded;
        end
    end

    % Initial values for number density of species and mean electron energy 
    % ---------------------------------------------------------------------

    temp = inp.cfg_General_obj.medium.properties.spec_prop;
    inp.Dspec_init = zeros(1, length(inp.specnames));  % Initialize number density array

    % Loop through species list
    for i = 1:length(inp.specnames)
        species_name = inp.specnames{i};
        is_matched = false;

        % Check if species is a background gas
        for j = 1:numel(temp.background_gas)
            if strcmp(species_name, temp.background_gas(j).name)
                inp.Dspec_init(i) = 1e12;  % Assign default background gas density
                is_matched = true;
                break;
            end
        end

        % Check if species is a heavy species
        if ~is_matched
            for j = 1:numel(temp.heavy_spec)
                if strcmp(species_name, temp.heavy_spec(j).name)
                    inp.Dspec_init(i) = temp.heavy_spec(j).int_dens;
                    is_matched = true;
                    break;
                end
            end
        end

        % If not found, assign electron density
        if ~is_matched
            inp.Dspec_init(i) = temp.electron.init_dens;
        end
    end

    inp.EleEne_init = temp.electron.init_ene;

    % Backgroud gas species
    % ---------------------
    
    temp = inp.cfg_General_obj.medium.properties.spec_prop;
    Sum = 0;
    for i=1:numel(temp.background_gas)
        Sum = Sum + temp.background_gas(i).background;
    end

    if Sum ~= 100;
        error('The total percentage of background gases differs from 100%.');
    end

    inp.n0Ind = zeros(1, numel(temp.background_gas));  % Initialize index array for background gases
    inp.n0Frac = zeros(1, numel(temp.background_gas));  % Initialize fraction array for background gases
    
    for i=1:length(inp.specnames)
         matched = false;
        for j=1:numel(temp.background_gas)
            if  inp.specnames(i) == temp.background_gas(j).name
                inp.n0Ind(1,i) = i;  % Set indexes for background gas
                inp.n0Frac(1,i) = temp.background_gas(j).background;  % Set fraction for background species
                matched = true;
                break;
            end
        end
       
        if ~matched
                inp.n0Ind(1,i) = 0;  % Set indexes for background gas
                inp.n0Frac(1,i) = 0;  % Set fraction for background species
               
        end
    end

end
