function SetProbesAndGraphs(inp, flags, model)
    %
    % SetProbesAndGraphs function uses functions specific for the LiveLink
    % for MATLAB module to set the probes (current density and gap voltage)
    % and graphs (density and mean energy of electrons) for presenting
    % modelling results of the COMSOL model.
    %
    % :param inp: the first input
    % :param flags: the second input
    % :param model: the third input
    
    msg(1, 'Setting probes and graphs', flags);
    table_tag = 'tbl1';
    model.result.table.create(table_tag, 'Table');  % Create a node for the table in the
                                                    % results section of the COMSOL model tree
    model.result.table(table_tag).label('Probe Table 1');  % Define label for the table

    %% =========================================================
    % === Set probes and graphs for the 1D case in Cartesian ===
    % ==========================================================
   
    dp = inp.General.diel_thickness_powered;
    dg = inp.General.diel_thickness_grounded;
    
    if length(strfind(inp.GeomName, 'Geom1D')) > 0 

        if dp > 0 && dg == 0 % Powered electrode covered by a dielectric layer
          
            % Set domain probe for voltage V1 at boundary (z = DBthickness)
            probe_settings = {'pdom1', 'Electric potential boundary 1', ...
                'ppb1', 'Electric potential boundary 1', 'V1', 'Phi', 'V',  'window1'};
            probe_coordinates = {'DBthickness'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set domain probe for voltage V2 at boundary (z = DBthickness+DischGap)
            probe_settings = {'pdom2', 'Electric potential boundary 2', ...
                'ppb2', 'Electric potential boundary 2', 'V2', 'Phi', 'V',  'window2'};
            probe_coordinates = {'DBthickness+DischGap'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set domain probe for applied voltage at boundary (z = 0)
            probe_settings = {'pdom3', 'Applied voltage', ...
                'ppb3', 'Applied voltage', 'Uapp', 'Phi', 'V',  'window3'};
            probe_coordinates = {'0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set global probe for gap voltage (V1-V2)
            probe_settings = {'var1', 'Gap Voltage', 'GapVoltage', ...
                'V1-V2', 'Voltage', 'V', 'window3'};
            SetGlobalProbe(model, probe_settings, table_tag);

            % Set window3 axes
            model.result('pg3').set('window', 'window3');
            model.result('pg3').set('windowtitle', '');
            model.result('pg3').run;
            model.result('pg3').set('xlabelactive', true);
            model.result('pg3').set('ylabelactive', true);
            model.result('pg3').set('ylabel', 'Voltage (V)');

            % Set global probe for total current Itot
            probe_settings = {'var2', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window4'};
            SetGlobalProbe(model, probe_settings, table_tag);
            
            % Set line graphs for density and mean energy of electrons in the discharge gap
            graph_tag = 'pg5';
            spec_index = inp.eInd;
            SetLineGraph(model, graph_tag, spec_index);            
        
        elseif dp == 0 && dg > 0 % Grounded electrode covered by a dielectric layer
          
            % Set domain probe for voltage V1 at boundary (z = 0)
            probe_settings = {'pdom1', 'Electric potential boundary 1', ...
                'ppb1', 'Electric potential boundary 1', 'V1', 'Phi', 'V',  'window1'};
            probe_coordinates = {'0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set domain probe for voltage V2 at boundary (z = DischGap)
            probe_settings = {'pdom2', 'Electric potential boundary 2', ...
                'ppb2', 'Electric potential boundary 2', 'V2', 'Phi', 'V',  'window2'};
            probe_coordinates = {'DischGap'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set domain probe for applied voltage at boundary (z = 0)
            probe_settings = {'pdom3', 'Applied voltage', ...
                'ppb3', 'Applied voltage', 'Uapp', 'Phi', 'V',  'window3'};
            probe_coordinates = {'0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set global probe for gap voltage (V1-V2)
            probe_settings = {'var1', 'Gap Voltage', 'GapVoltage', ...
                'V1-V2', 'Gap voltage', 'V', 'window3'};
            SetGlobalProbe(model, probe_settings, table_tag);

            % Set window3 axes
            model.result('pg3').set('window', 'window3');
            model.result('pg3').set('windowtitle', '');
            model.result('pg3').run;
            model.result('pg3').set('xlabelactive', true);
            model.result('pg3').set('ylabelactive', true);
            model.result('pg3').set('ylabel', 'Voltage (V)');

            % Set global probe for total current Itot
            probe_settings = {'var2', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window4'};
            SetGlobalProbe(model, probe_settings, table_tag);
            
            % Set line graphs for density and mean energy of electrons in the discharge gap
            graph_tag = 'pg5';
            spec_index = inp.eInd; 
            SetLineGraph(model, graph_tag, spec_index);
        
        elseif dp > 0 && dg > 0  % Both electrodes covered by dielectric layers
            
            % Set domain probe for voltage V1 at boundary (z = DBthickness_1)
            probe_settings = {'pdom1', 'Electric potential boundary 1', ...
                'ppb1', 'Electric potential boundary 1', 'V1', 'Phi', 'V',  'window1'};
            probe_coordinates = {'DBthickness_1'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);  
            
            % Set domain probe for voltage V2 at boundary (z = DBthickness_1 + DischGap)
            probe_settings = {'pdom2', 'Electric potential boundary 2', ...
                'ppb2', 'Electric potential boundary 2', 'V2', 'Phi', 'V',  'window2'};
            probe_coordinates = {'DBthickness_1+DischGap'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set domain probe for applied voltage at boundary (z = 0)
            probe_settings = {'pdom3', 'Applied voltage', ...
                'ppb3', 'Applied voltage', 'Uapp', 'Phi', 'V',  'window3'};
            probe_coordinates = {'0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set global probe for gap voltage (V1-V2)
            probe_settings = {'var1', 'Gap Voltage', 'GapVoltage', ...
                'V1-V2', 'Gap voltage', 'V', 'window3'};
            SetGlobalProbe(model, probe_settings, table_tag);

            % Set window3 axes
            model.result('pg3').set('window', 'window3');
            model.result('pg3').set('windowtitle', '');
            model.result('pg3').run;
            model.result('pg3').set('xlabelactive', true);
            model.result('pg3').set('ylabelactive', true);
            model.result('pg3').set('ylabel', 'Voltage (V)');

            % Set global probe for total current Itot
            probe_settings = {'var2', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window4'};
            SetGlobalProbe(model, probe_settings, table_tag);
            
            % Set line graphs for density and mean energy of electrons in the gap
            graph_tag = 'pg5';
            spec_index = inp.eInd;
            SetLineGraph(model, graph_tag, spec_index);
        
        else % Both electrodes without dielectric layers
            
            % Set domain probe for gap voltage
            probe_settings = {'pdom1', 'Applied voltage', 'ppb1', ...
                'Applied voltage', 'U', 'Phi', 'V',  'window1'};
            probe_coordinates = {'0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set global probe for total current Itot
            probe_settings = {'var1', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window2'};
            SetGlobalProbe(model, probe_settings, table_tag);

            % Set line graphs for density and mean energy of electrons in the gap
            graph_tag = 'pg3';
            spec_index = inp.eInd;
            SetLineGraph(model, graph_tag, spec_index);
        end
    %% ========================================================================
    % === Set probes and graphs for the 1D case in polar coordinates (1p5D) ===
    % =========================================================================

    elseif length(strfind(inp.GeomName, 'Geom1p5D')) > 0

        if dp > 0 && dg == 0 % Powered electrode covered by a dielectric layer
          
            % Set domain probe for voltage V1 at boundary (r = DBthickness+RadiusInnerEle)
            probe_settings = {'pdom1', 'Electric potential boundary 1', ...
                'ppb1', 'Electric potential boundary 1', 'V1', 'Phi', 'V',  'window1'};
            probe_coordinates = {'DBthickness+RadiusInnerEle'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set domain probe for voltage V2 at boundary (r = DBthickness+RadiusInnerEle+DischGap)
            probe_settings = {'pdom2', 'Electric potential boundary 2', ...
                'ppb2', 'Electric potential boundary 2', 'V2', 'Phi', 'V',  'window2'};
            probe_coordinates = {'DBthickness+RadiusInnerEle+DischGap'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set domain probe for applied voltage at boundary (r = RadiusInnerEle)
            probe_settings = {'pdom3', 'Applied voltage', ...
                'ppb3', 'Applied voltage', 'Uapp', 'Phi', 'V',  'window3'};
            probe_coordinates = {'RadiusInnerEle'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set global probe for gap voltage (V1-V2)
            probe_settings = {'var1', 'Gap Voltage', 'GapVoltage', ...
                'V1-V2', 'Gap voltage', 'V', 'window3'};
            SetGlobalProbe(model, probe_settings, table_tag);

            % Set window3 axes
            model.result('pg3').set('window', 'window3');
            model.result('pg3').set('windowtitle', '');
            model.result('pg3').run;
            model.result('pg3').set('xlabelactive', true);
            model.result('pg3').set('ylabelactive', true);
            model.result('pg3').set('ylabel', 'Voltage (V)');

            % Set global probe for total current Itot
            probe_settings = {'var2', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window4'};
            SetGlobalProbe(model, probe_settings, table_tag);
            
            % Set line graphs for density and mean energy of electrons in the gap
            graph_tag = 'pg5';
            spec_index = inp.eInd;
            SetLineGraph(model, graph_tag, spec_index);            
        
        elseif dp == 0 && dg > 0 % Grounded electrode covered by a dielectric layer
          
            % Set domain probe for voltage V1 at boundary (r = RadiusInnerEle)
            probe_settings = {'pdom1', 'Electric potential boundary 1', ...
                'ppb1', 'Electric potential boundary 1', 'V1', 'Phi', 'V',  'window1'};
            probe_coordinates = {'RadiusInnerEle'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set domain probe for voltage V2 at boundary (r = RadiusInnerEle+DischGap)
            probe_settings = {'pdom2', 'Electric potential boundary 2', ...
                'ppb2', 'Electric potential boundary 2', 'V2', 'Phi', 'V',  'window2'};
            probe_coordinates = {'RadiusInnerEle+DischGap'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set domain probe for applied voltage at boundary (r = RadiusInnerEle)
            probe_settings = {'pdom3', 'Applied voltage', ...
                'ppb3', 'Applied voltage', 'Uapp', 'Phi', 'V',  'window3'};
            probe_coordinates = {'RadiusInnerEle'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);            
            
            % Set global probe for gap voltage (V1-V2)
            probe_settings = {'var1', 'Gap Voltage', 'GapVoltage', ...
                'V1-V2', 'Gap voltage', 'V', 'window3'};
            SetGlobalProbe(model, probe_settings, table_tag);

            % Set window3 axes
            model.result('pg3').set('window', 'window3');
            model.result('pg3').set('windowtitle', '');
            model.result('pg3').run;
            model.result('pg3').set('xlabelactive', true);
            model.result('pg3').set('ylabelactive', true);
            model.result('pg3').set('ylabel', 'Voltage (V)');

            % Set global probe for total current Itot
            probe_settings = {'var2', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window4'};
            SetGlobalProbe(model, probe_settings, table_tag);
            
            % Set line graphs for density and mean energy of electrons in the gap
            graph_tag = 'pg5';
            spec_index = inp.eInd;
            SetLineGraph(model, graph_tag, spec_index);
        
        elseif dp > 0 && dg > 0  % Both electrodes covered by dielectric layers
            
            % Set domain probe for voltage V1 at boundary (r = DBthickness_1+RadiusInnerEle)
            probe_settings = {'pdom1', 'Electric potential boundary 1', ...
                'ppb1', 'Electric potential boundary 1', 'V1', 'Phi', 'V',  'window1'};
            probe_coordinates = {'RadiusInnerEle+DBthickness_1'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);  
            
            % Set domain probe for voltage V2 at boundary 
            % (r = RadiusInnerEle+DBthickness_1+DischGap)
            probe_settings = {'pdom2', 'Electric potential boundary 2', ...
                'ppb2', 'Electric potential boundary 2', 'V2', 'Phi', 'V',  'window2'};
            probe_coordinates = {'RadiusInnerEle+DBthickness_1+DischGap'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set domain probe for applied voltage at boundary (r = RadiusInnerEle)
            probe_settings = {'pdom3', 'Applied voltage', ...
                'ppb3', 'Applied voltage', 'Uapp', 'Phi', 'V',  'window3'};
            probe_coordinates = {'RadiusInnerEle'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);            
            
            % Set global probe for gap voltage (V1-V2)
            probe_settings = {'var1', 'Gap Voltage', 'GapVoltage', ...
                'V1-V2', 'Gap voltage', 'V', 'window3'};
            SetGlobalProbe(model, probe_settings, table_tag);

            % Set window3 axes
            model.result('pg3').set('window', 'window3');
            model.result('pg3').set('windowtitle', '');
            model.result('pg3').run;
            model.result('pg3').set('xlabelactive', true);
            model.result('pg3').set('ylabelactive', true);
            model.result('pg3').set('ylabel', 'Voltage (V)');
            
            % Set global probe for total current Itot
            probe_settings = {'var2', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window4'};
            SetGlobalProbe(model, probe_settings, table_tag);
            
            % Set line graphs for density and mean energy of electrons in the gap
            graph_tag = 'pg5';
            spec_index = inp.eInd;
            SetLineGraph(model, graph_tag, spec_index);
        
        else % Both electrodes without dielectric layers
            
            % Set domain probe for gap voltage
            probe_settings = {'pdom1', 'Applied voltage', 'ppb1', ...
                'Applied voltage', 'U', 'Phi', 'V',  'window1'};
            probe_coordinates = {'RadiusInnerEle'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set global probe for total current Itot
            probe_settings = {'var1', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window2'};
            SetGlobalProbe(model, probe_settings, table_tag);

            % Set line graphs for density and mean energy of electrons in the gap
            graph_tag = 'pg3';
            spec_index = inp.eInd;
            SetLineGraph(model, graph_tag, spec_index);
        end
    
    %% =====================================================================
    % === Set probes and graphs for the 2D case in Cartesian coordinates ===
    % ======================================================================
    
    elseif length(strfind(inp.GeomName, 'Geom2D')) > 0

        if dp > 0 && dg == 0 % Powered electrode covered by a dielectric layer
            
            % Set domain probe for voltage V1 at boundary y = DBthickness in the
            % middle of electrode length (x = ElecLength/2)
            probe_settings = {'pdom1', 'Electric potential boundary 1', ...
                'ppb1', 'Electric potential boundary 1', 'V1', 'Phi', 'V',  'window1'};
            probe_coordinates = {'ElecLength/2', 'DBthickness'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set domain probe for voltage V2 at boundary y = DBthickness+DischGap in the
            % middle of electrode length (x = ElecLength/2)            
            probe_settings = {'pdom2', 'Electric potential boundary 2', ...
                'ppb2', 'Electric potential boundary 2', 'V2', 'Phi', 'V',  'window2'};
            probe_coordinates = {'ElecLength/2', 'DBthickness+DischGap'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set domain probe for applied voltage at boundary y = 0 in the
            % middle of electrode length (x = ElecLength/2)  
            probe_settings = {'pdom3', 'Applied voltage', ...
                'ppb3', 'Applied voltage', 'Uapp', 'Phi', 'V',  'window3'};
            probe_coordinates = {'ElecLength/2', '0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag); 
            
            % Set global probe for gap voltage (V1-V2)
            probe_settings = {'var1', 'Gap Voltage', 'GapVoltage', ...
                'V1-V2', 'Gap voltage', 'V', 'window3'};
            SetGlobalProbe(model, probe_settings, table_tag);

            % Set window3 axes
            model.result('pg3').set('window', 'window3');
            model.result('pg3').set('windowtitle', '');
            model.result('pg3').run;
            model.result('pg3').set('xlabelactive', true);
            model.result('pg3').set('ylabelactive', true);
            model.result('pg3').set('ylabel', 'Voltage (V)');            

            % Set global probe for total current Itot
            probe_settings = {'var2', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window4'};
            SetGlobalProbe(model, probe_settings, table_tag);            
            
            % Set surface plots for density and mean energy of electrons in plasma domain
            graph_tag = 'pg5';
            spec_index = inp.eInd;
            xlabel = 'x';
            ylabel = 'y';
            SetSurfGraph(model, inp.GeomName, graph_tag, spec_index, xlabel, ylabel); 

        elseif dp == 0 && dg > 0 % Grounded electrode covered by a dielectric layer
            
            % Set domain probe for voltage V1 at boundary y = 0 in the
            % middle of electrode length (x = ElecLength/2)
            probe_settings = {'pdom1', 'Electric potential boundary 1', ...
                'ppb1', 'Electric potential boundary 1', 'V1', 'Phi', 'V',  'window1'};
            probe_coordinates = {'ElecLength/2', '0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set domain probe for voltage V2 at boundary y = DischGap in the
            % middle of electrode length (x = ElecLength/2)            
            probe_settings = {'pdom2', 'Electric potential boundary 2', ...
                'ppb2', 'Electric potential boundary 2', 'V2', 'Phi', 'V',  'window2'};
            probe_coordinates = {'ElecLength/2', 'DischGap'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set domain probe for applied voltage at boundary y = 0 in the
            % middle of electrode length (x = ElecLength/2)  
            probe_settings = {'pdom3', 'Applied voltage', ...
                'ppb3', 'Applied voltage', 'Uapp', 'Phi', 'V',  'window3'};
            probe_coordinates = {'ElecLength/2', '0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set window3 axes
            model.result('pg3').set('window', 'window3');
            model.result('pg3').set('windowtitle', '');
            model.result('pg3').run;
            model.result('pg3').set('xlabelactive', true);
            model.result('pg3').set('ylabelactive', true);
            model.result('pg3').set('ylabel', 'Voltage (V)');
            
            % Set global probe for gap voltage (V1-V2)
            probe_settings = {'var1', 'Gap Voltage', 'GapVoltage', ...
                'V1-V2', 'Gap voltage', 'V', 'window3'};
            SetGlobalProbe(model, probe_settings, table_tag);

            % Set global probe for total current Itot
            probe_settings = {'var2', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window4'};
            SetGlobalProbe(model, probe_settings, table_tag);            
            
            % Set surface plots for density and mean energy of electrons in plasma domain
            graph_tag = 'pg5';
            spec_index = inp.eInd;
            xlabel = 'x';
            ylabel = 'y';
            SetSurfGraph(model, inp.GeomName, graph_tag, spec_index, xlabel, ylabel);   
        
        elseif dp > 0 && dg > 0 % Both electrodes covered by dielectric layers
            
            % Set domain probe for voltage V1 at boundary y = DBthickness_1 in the
            % middle of electrode length (x = ElecLength/2)            
            probe_settings = {'pdom1', 'Electric potential boundary 1', ...
                'ppb1', 'Electric potential boundary 1', 'V1', 'Phi', 'V',  'window1'};
            probe_coordinates = {'ElecLength/2', 'DBthickness_1'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set domain probe for voltage V2 at boundary y = DischGap + DBthickness_1 in the
            % middle of electrode length (x = ElecLength/2)             
            probe_settings = {'pdom2', 'Electric potential boundary 2', ...
                'ppb2', 'Electric potential boundary 2', 'V2', 'Phi', 'V',  'window2'};
            probe_coordinates = {'ElecLength/2', 'DischGap + DBthickness_1'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set domain probe for applied voltage at boundary y = 0 in the
            % middle of electrode length (x = ElecLength/2)  
            probe_settings = {'pdom3', 'Applied voltage', ...
                'ppb3', 'Applied voltage', 'Uapp', 'Phi', 'V',  'window3'};
            probe_coordinates = {'ElecLength/2', '0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set window3 axes
            model.result('pg3').set('window', 'window3');
            model.result('pg3').set('windowtitle', '');
            model.result('pg3').run;
            model.result('pg3').set('xlabelactive', true);
            model.result('pg3').set('ylabelactive', true);
            model.result('pg3').set('ylabel', 'Voltage (V)');
            
            % Set global probe for gap voltage (V1-V2)
            probe_settings = {'var1', 'Gap Voltage', 'GapVoltage', ...
                'V1-V2', 'Gap voltage', 'V', 'window3'};
            SetGlobalProbe(model, probe_settings, table_tag);

            % Set global probe for total current Itot
            probe_settings = {'var2', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window4'};
            SetGlobalProbe(model, probe_settings, table_tag); 
            
            % Set surface plots for density and mean energy of electrons in plasma domain
            graph_tag = 'pg5';
            spec_index = inp.eInd;
            xlabel = 'x';
            ylabel = 'y';
            SetSurfGraph(model, inp.GeomName, graph_tag, spec_index, xlabel, ylabel);             
        
        else % Both electrodes without dielectric layers
            
            % Set domain probe for gap voltage
            probe_settings = {'pdom1', 'Applied voltage', 'ppb1', ...
                'Applied voltage', 'U', 'Phi', 'V',  'window1'};
            probe_coordinates = {'ElecLength/2', '0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set global probe for total current Itot
            probe_settings = {'var1', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window2'};
            SetGlobalProbe(model, probe_settings, table_tag);            
            
            % Set surface plots for density and mean energy of electrons in plasma domain
            graph_tag = 'pg3';
            spec_index = inp.eInd;
            xlabel = 'x';
            ylabel = 'y';
            SetSurfGraph(model, inp.GeomName, graph_tag, spec_index, xlabel, ylabel);   
        end
    
    %% ==============================================================================
    % === Set probes and graphs for the 2D case in cylindrical coordinates (2p5D) ===
    % ===============================================================================
    
    elseif length(strfind(inp.GeomName, 'Geom2p5D')) > 0

        if dp > 0 && dg == 0 % Powered electrode covered by a dielectric layer
            
            % Set domain probe for voltage V1 at boundary z = DBthickness in the electrode center (r = 0)
            probe_settings = {'pdom1', 'Electric potential boundary 1', ...
                'ppb1', 'Electric potential boundary 1', 'V1', 'Phi', 'V',  'window1'};
            probe_coordinates = {'0', 'DBthickness'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set domain probe for voltage V2 at boundary z = DBthickness+DischGap
            % in the electrode center (r = 0)
            probe_settings = {'pdom2', 'Electric potential boundary 2', ...
                'ppb2', 'Electric potential boundary 2', 'V2', 'Phi', 'V',  'window2'};
            probe_coordinates = {'0', 'DBthickness+DischGap'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set domain probe for applied voltage at boundary y = 0 in the
            % middle of electrode length (x = ElecLength/2)  
            probe_settings = {'pdom3', 'Applied voltage', ...
                'ppb3', 'Applied voltage', 'Uapp', 'Phi', 'V',  'window3'};
            probe_coordinates = {'0', '0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag); 
            
            % Set global probe for gap voltage (V1-V2)
            probe_settings = {'var1', 'Gap Voltage', 'GapVoltage', ...
                'V1-V2', 'Gap voltage', 'V', 'window3'};
            SetGlobalProbe(model, probe_settings, table_tag);

            % Set window3 axes
            model.result('pg3').set('window', 'window3');
            model.result('pg3').set('windowtitle', '');
            model.result('pg3').run;
            model.result('pg3').set('xlabelactive', true);
            model.result('pg3').set('ylabelactive', true);
            model.result('pg3').set('ylabel', 'Voltage (V)');
            
            % Set global probe for total current Itot
            probe_settings = {'var2', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window4'};
            SetGlobalProbe(model, probe_settings, table_tag);
            
            % Set surface plots for density and mean energy of electrons in plasma domain
            graph_tag = 'pg5';
            spec_index = inp.eInd;
            xlabel = 'r';
            ylabel = 'z';
            SetSurfGraph(model, inp.GeomName, graph_tag, spec_index, xlabel, ylabel);   
        

        elseif dp == 0 && dg > 0 % Grounded electrode covered by a dielectric layer
            
            % Set domain probe for voltage V1 at boundary z = 0 in the electrode center (r = 0)
            probe_settings = {'pdom1', 'Electric potential boundary 1', ...
                'ppb1', 'Electric potential boundary 1', 'V1', 'Phi', 'V',  'window1'};
            probe_coordinates = {'0', '0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set domain probe for voltage V2 at boundary z = DischGap in the electrode center (r = 0)
            probe_settings = {'pdom2', 'Electric potential boundary 2', ...
                'ppb2', 'Electric potential boundary 2', 'V2', 'Phi', 'V',  'window2'};
            probe_coordinates = {'0', 'DischGap'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set domain probe for applied voltage at boundary y = 0 in the
            % middle of electrode length (x = ElecLength/2)  
            probe_settings = {'pdom3', 'Applied voltage', ...
                'ppb3', 'Applied voltage', 'Uapp', 'Phi', 'V',  'window3'};
            probe_coordinates = {'0', '0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set global probe for gap voltage (V1-V2)
            probe_settings = {'var1', 'Gap Voltage', 'GapVoltage', ...
                'V1-V2', 'Gap voltage', 'V', 'window3'};
            SetGlobalProbe(model, probe_settings, table_tag);

            % Set window3 axes
            model.result('pg3').set('window', 'window3');
            model.result('pg3').set('windowtitle', '');
            model.result('pg3').run;
            model.result('pg3').set('xlabelactive', true);
            model.result('pg3').set('ylabelactive', true);
            model.result('pg3').set('ylabel', 'Voltage (V)');
            

            % Set global probe for total current Itot
            probe_settings = {'var2', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window4'};
            SetGlobalProbe(model, probe_settings, table_tag);
            
            % Set surface plots for density and mean energy of electrons in plasma domain
            graph_tag = 'pg5';
            spec_index = inp.eInd;
            xlabel = 'r';
            ylabel = 'z';
            SetSurfGraph(model, inp.GeomName, graph_tag, spec_index, xlabel, ylabel);   
        
        elseif dp > 0 && dg > 0 % Both electrodes covered by dielectric layers
            
            % Set domain probe for voltage V1 at boundary z = DBthickness_1
            % in the electrode center (r = 0)
            probe_settings = {'pdom1', 'Electric potential boundary 1', ...
                'ppb1', 'Electric potential boundary 1', 'V1', 'Phi', 'V',  'window1'};
            probe_coordinates = {'0', 'DBthickness_1'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set domain probe for voltage V2 at boundary z = DischGap + DBthickness_1
            % in the electrode center (r = 0)
            probe_settings = {'pdom2', 'Electric potential boundary 2', ...
                'ppb2', 'Electric potential boundary 2', 'V2', 'Phi', 'V',  'window2'};
            probe_coordinates = {'0', 'DischGap + DBthickness_1'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set domain probe for applied voltage at boundary y = 0 in the
            % middle of electrode length (x = ElecLength/2)  
            probe_settings = {'pdom3', 'Applied voltage', ...
                'ppb3', 'Applied voltage', 'Uapp', 'Phi', 'V',  'window3'};
            probe_coordinates = {'0', '0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);
            
            % Set global probe for gap voltage (V1-V2)
            probe_settings = {'var1', 'Gap Voltage', 'GapVoltage', ...
                'V1-V2', 'Gap voltage', 'V', 'window3'};
            SetGlobalProbe(model, probe_settings, table_tag);

            % Set window3 axes
            model.result('pg3').set('window', 'window3');
            model.result('pg3').set('windowtitle', '');
            model.result('pg3').run;
            model.result('pg3').set('xlabelactive', true);
            model.result('pg3').set('ylabelactive', true);
            model.result('pg3').set('ylabel', 'Voltage (V)');
            
            % Set global probe for total current Itot
            probe_settings = {'var2', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window4'};
            SetGlobalProbe(model, probe_settings, table_tag);            
            
            % Set surface plots for density and mean energy of electrons in  plasma domain
            graph_tag = 'pg5';
            spec_index = inp.eInd;
            xlabel = 'r';
            ylabel = 'z';
            SetSurfGraph(model, inp.GeomName, graph_tag, spec_index, xlabel, ylabel);   
        
        else % Both electrodes without dielectric layers
            
            % Set domain probe for gap voltage
            probe_settings = {'pdom1', 'Applied voltage', 'ppb1', ...
                'Applied voltage', 'U', 'Phi', 'V',  'window1'};
            probe_coordinates = {'0', '0'};
            SetDomainProbe(model, probe_settings, probe_coordinates, table_tag);

            % Set global probe for total current Itot
            probe_settings = {'var1', 'Total Current', 'TotalCurrent', ...
                'Itotal', 'Total current', 'A', 'window2'};
            SetGlobalProbe(model, probe_settings, table_tag);
            
            % Set surface plots for density and mean energy of electrons in plasma domain
            graph_tag = 'pg3';
            spec_index = inp.eInd;
            xlabel = 'r';
            ylabel = 'z';
            SetSurfGraph(model, inp.GeomName, graph_tag, spec_index, xlabel, ylabel);   
        end
    end
end

%---------------------------------------------------------------------------
function SetDomainProbe(model, probe_settings, probe_coordinates, table_tag)
%---------------------------------------------------------------------------
    %
    % SetDomainProbe function uses functions specific for the Live Link
    % for MATLAB module to set the domain probes for current density and
    % voltages at boundaries.
    %
    % :param model: the first input
    % :param probe_settings: the second input
    % :param probe_coordinates: the third input
    % :param table_tag: the fourth input  
    probe_tag = probe_settings(1);  % Tag for the probe can be any short combination of
                                    % letters and numbers, e.g., "pdom1"; Same tag name
                                    % for two probes is not allowed!
    probe_label = probe_settings(2);  % Label for the probe is usually something descriptive,
                                      % e.g., "Current density"
    expression_tag = probe_settings(3);  % One domain probe can be used for more expressions
                                         % and each has its own tab, e.g., "ppb1"
    expression_label = probe_settings(4);  % Label for the expression
    expression_name = probe_settings(5);  % Expression name can be freely given for each
                                          % expression, e.g., "j" or "V1"
    expression = probe_settings(6);  % Expression is the variable or coefficient defined in
                                     % the COMSOL model
    expression_unit = probe_settings(7);  % Expression unit
    window = probe_settings(8);  % Window for displaying probe graph
    coordinate = probe_coordinates;  % The coordinates of the point at which the probe is defined
    model.component('mod1').probe.create(probe_tag, 'DomainPoint');  % Create a node for the domain
                                                                     % probe in the COMSOL model tree
    model.component('mod1').probe(probe_tag).label(probe_label);  % Define the probe label
    
    if length(coordinate) > 1  % Case: 2D Cartesian or cylindrical coordinates
        model.component('mod1').probe(probe_tag).set('coords2', ...
            {coordinate{1} coordinate{2}});  % Set probe coordinates
    else  % Case: 1D Cartesian or polar coordinates
        model.component('mod1').probe(probe_tag).setIndex('coords1', ...
            coordinate{1}, 0);  % Set probe coordinates
    end
    
    model.component('mod1').probe(probe_tag).set('bndsnap1', true);  % Activate "Snap to closest
                                                                     % point" to snap defined probe
                                                                     % point to the closest boundary point
   
    model.component('mod1').probe(probe_tag).feature( ...
        expression_tag).label(expression_label);  % Set expression label
    model.component('mod1').probe(probe_tag).feature(expression_tag).set('probename', ...
        expression_name);  % Set expression name
    model.component('mod1').probe(probe_tag).feature( ...
        expression_tag).set('expr', expression);  % Set expression
    model.component('mod1').probe(probe_tag).feature( ...
        expression_tag).set('unit', expression_unit);  % Set expression unit
    model.component('mod1').probe(probe_tag).feature( ...
        expression_tag).set('descractive', true);  % Activate "Description" to show description
                                                   % of expression at the graph
    model.component('mod1').probe(probe_tag).feature(expression_tag).set('descr', ...
        expression_label);  % Set expression description
    model.component('mod1').probe(probe_tag).feature(expression_tag).set('table', ...
        table_tag);  % Set tag for the results table
    model.component('mod1').probe(probe_tag).feature(expression_tag).set('window', ...
        window);  % Set the window for displaying probe graph 
    model.component('mod1').probe(probe_tag).genResult([]);
end

%--------------------------------------------------------
function SetGlobalProbe(model, probe_settings, table_tag)
%--------------------------------------------------------
    %
    % SetGlobalProbe function uses functions specific for the Live Link
    % for MATLAB module to set the global probes for gap voltage.
    %
    % :param model: the first input
    % :param probe_settings: the second input
    % :param table_tag: the third input  
    
    % Description for the following variables is the same as for "SetDomainProbe" function
    probe_tag = probe_settings(1);
    probe_label = probe_settings(2);
    probe_name = probe_settings(3);
    expression = probe_settings(4);
    expression_descr = probe_settings(5);
    expression_unit = probe_settings(6);
    window = probe_settings(7);
    model.component('mod1').probe.create(probe_tag, 'GlobalVariable');
    model.component('mod1').probe(probe_tag).label(probe_label);
    model.component('mod1').probe(probe_tag).set('probename', probe_name);
    model.component('mod1').probe(probe_tag).set('expr', expression);
    model.component('mod1').probe(probe_tag).set('unit', expression_unit);
    model.component('mod1').probe(probe_tag).set('descractive', true);
    model.component('mod1').probe(probe_tag).set('descr', expression_descr);
    model.component('mod1').probe(probe_tag).set('table', table_tag);
    model.component('mod1').probe(probe_tag).set('window', window);
    model.component('mod1').probe(probe_tag).genResult([]);
end

%--------------------------------------------------
function SetLineGraph(model, graph_tag, spec_index)
%--------------------------------------------------
    %
    % SetLineGraph function uses functions specific for the Live Link for
    % MATLAB module to set a 1D plot group that contains line graphs for density and mean energy of
    % electrons in the gap. The plot have two y-axes (left and rigt):
    % the left one for the electron density and
    % the right one for the mean electron energy.
    %
    % :param model: the first input
    % :param probe_tag: the second input
    % :param spec_index: the third input  
    
    model.result.create(graph_tag, 'PlotGroup1D');  % Create a node for the 1D plot group in the
                                                    % results section of the COMSOL model tree
    model.result(graph_tag).create('lngr1', 'LineGraph');  % Create line graph 1
    model.result(graph_tag).create('lngr2', 'LineGraph');  % Create line graph 2
    model.result(graph_tag).feature('lngr1').selection.named('plasmadomain');  % Set "plasmadomain" for
                                                                               % domain of the line graph 1
    temp_spec = ['N' num2str(spec_index)];
    model.result(graph_tag).feature('lngr1').set('expr', temp_spec);  % Set variable name for 
                                                                      % electron number density
                                                                      % as expression
    model.result(graph_tag).feature('lngr2').selection.named('plasmadomain');  % Set "plasmadomain" for
                                                                               % domain of the line graph 2
    model.result(graph_tag).feature('lngr2').set('expr', 'Umean');  % Set variable name for 
                                                                    % mean electron number
                                                                    % energy as expression
    model.result(graph_tag).label('Electron');  % Set label of the 1D plot group
    model.result(graph_tag).set('innerinput', 'last');  % Show only the results corresponding to
                                                        % the last calculated time point
    model.result(graph_tag).set('xlabel', 'Gap distance (m)');  % Set label for x-axis of 1D plot
    model.result(graph_tag).set('xlabelactive', true);  % Show label for x-axis on graph
    model.result(graph_tag).set('ylabel', 'Density of e (1/m<sup>3</sup>)');  % Set label for one y-axis
    model.result(graph_tag).set('yseclabel', 'Mean electron energy (V)');  % Set label for another y-axis
    model.result(graph_tag).set('twoyaxes', true);  % Show both y-axes on the graph
    model.result(graph_tag).set('plotonsecyaxis', {'Density' 'off' 'lngr1'; ...
        'Energy' 'on' 'lngr2'});  % Define mean electron energy as second axis (right-hand side axis)
    model.result(graph_tag).set('ylabelactive', false);  % Setting of label for the first y-axis
                                                         % not included from the general setting of 1D plot 
                                                         % (it is defined by setup of corresponding line graph)
    model.result(graph_tag).set('yseclabelactive', false);  % Setting of label for the second y-axis not
                                                            % included from the general setting of 1D plot 
                                                            % (it is defined by setup of corresponding line graph)
    model.result(graph_tag).feature('lngr1').label('Density');  % Set the label for the first line graph
                                                                % presented on the first y-axis (left-hand side axis)
    model.result(graph_tag).feature('lngr1').set('descractive', true);  % Set the description 
                                                                        % for the first line graph
    model.result(graph_tag).feature('lngr1').set('linewidth', 'preference');  % Set the graph line
                                                                              % width to the default value.
    model.result(graph_tag).feature('lngr1').set('legend', true);  % Show the graph legend
    model.result(graph_tag).feature('lngr1').set('autosolution', false);  % Do not show solution info
    model.result(graph_tag).feature('lngr1').set('autodescr', true);  % Show the graph description
    model.result(graph_tag).feature('lngr1').set('smooth', 'none');  % Switch off graph smoothness
    model.result(graph_tag).feature('lngr1').set('resolution', 'normal');  % Set resolution to normal
    model.result(graph_tag).feature('lngr2').label('Energy');  % Set the label for the first line graph
                                                               % presented on the second y-axis (right-hand side axis)
    model.result(graph_tag).feature('lngr2').set('descractive', true);  % Set the description for
                                                                        % the second line graph
    model.result(graph_tag).feature('lngr2').set('linewidth', 'preference');  % Set the graph line width to the default.
    model.result(graph_tag).feature('lngr2').set('legend', true);  % Show the graph legend
    model.result(graph_tag).feature('lngr2').set('autosolution', false);  % Do not show solution info
    model.result(graph_tag).feature('lngr2').set('autodescr', true);  % Show the graph description
    model.result(graph_tag).feature('lngr2').set('smooth', 'none');  % Switch off graph smoothness
    model.result(graph_tag).feature('lngr2').set('resolution', 'normal');  % Set resolution to normal
end

%----------------------------------------------------------------------------
function SetSurfGraph(model, GeomName, graph_tag, spec_index, xlabel, ylabel)
%----------------------------------------------------------------------------
    %
    % SetSurfGraph function uses functions specific for the Live Link
    % for MATLAB module to set a 2D surface plot group that contains surface graphs 
    % for density and mean energy of electrons in the plasma domain.
    %
    % :param model: the first input
    % :param GeomName: the second input
    % :param probe_tag: the third input
    % :param spec_index: the fourth input
    % :param xlabel: the fifth input 
    % :param ylabel: the sixth input     
    
    model.result.create(graph_tag, 'PlotGroup2D');  % Create a node for the 2D surface plot group
                                                    % in the results section of the COMSOL model tree
    model.result(graph_tag).create('surf1', 'Surface');  % Create surface graph 1
    model.result(graph_tag).create('surf2', 'Surface');  % Create surface graph 2
    model.result(graph_tag).label('Electron');  % Set label of the 2D surface plot group
    model.result(graph_tag).set('xlabel', xlabel);  % Set the label for the x-axis 
                                                    % of the 2D surface plot group
    model.result(graph_tag).set('xlabelactive', true);  % Show label for x-axis on graph
    model.result(graph_tag).set('ylabel', ylabel);  % Set the label for the y-axis of the
                                                    % 2D surface plot group
    model.result(graph_tag).set('ylabelactive', true);  % Show label for y-axis on graph
    model.result(graph_tag).set('frametype', 'geometry');  % Set frame for plot edges
    temp_spec = ['N' num2str(spec_index)];
    model.result(graph_tag).feature('surf1').set('expr', temp_spec);  % Set variable name for 
                                                                      % electron number density
                                                                      % as expression
    model.result(graph_tag).feature('surf1').label('Density');  % Set the label for the
                                                                % first surface graph
    model.result(graph_tag).feature('surf1').set('descractive', true);  % Set the description for the
                                                                        % first surface graph
    model.result(graph_tag).feature('surf1').set('smooth', 'none');  % Switch off graph smoothness
    model.result(graph_tag).feature('surf1').set('resolution', 'normal');  % Set resolution to normal
    model.result(graph_tag).feature('surf2').set('expr', 'Umean');  % Set variable name for 
                                                                    % mean electron energy 
                                                                    % as expression
    model.result(graph_tag).feature('surf2').label('Electron energy');  % Set the label for the 
                                                                        % second surface graph
    model.result(graph_tag).feature('surf2').set('descractive', true);  % Set the description for the
                                                                        % second surface graph
    model.result(graph_tag).feature('surf2').set('smooth', 'none');  % Switch off graph smoothness
    model.result(graph_tag).feature('surf2').set('resolution', 'normal');  % Set resolution to normal
    model.result(graph_tag).feature('surf2').create('def1', 'Deform');  % Create deformation for the 
                                                                        % second surface graph to define
                                                                        % its position in the window
    if length(strfind(GeomName, 'Geom2D')) > 0
        model.result(graph_tag).feature('surf2').feature('def1').set('expr', ...
            {'ElecLength+0.2*ElecLength' ''});  % Set the second surface graph at position
                                                % x = ElecLength+0.2*ElecLength
    else
        model.result(graph_tag).feature('surf2').feature('def1').set('expr', ...
            {'ElecRadius+0.2*ElecRadius' ''});  % Set the second surface graph at position
                                                % x = ElecRadius+0.2*ElecRadius
    end
    % Activate scale factor for deformation; Factor is set to 1 by default
    model.result(graph_tag).feature('surf2').feature('def1').set('scaleactive', true); 
end