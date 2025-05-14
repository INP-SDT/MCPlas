function SetFluxes(inp, flags, model, GeomName)
%
% SetFluxes function uses functions specific for Live link for MATLAB module to set
% species fluxes in Comsol model based on input data
%
% :param inp: the first input
% :param flags: the second input
% :param model: the third input
% :param GeonName: the fourth input

    msg(1, 'setting fluxes', flags);

    % Create section for flux variables
    variablesname = 'fluxes';
    model.variable.create(variablesname);
    model.variable(variablesname).model('mod1');
    model.variable(variablesname).name('Fluxes');
    model.variable(variablesname).selection.named('plasmadomain');

    % Create section for boundary flux variables
    variablesname = 'bndfluxes';
    model.variable.create(variablesname);
    model.variable(variablesname).model('mod1');
    model.variable(variablesname).name('Boundary fluxes');
    model.variable(variablesname).selection.named('plasmaboundaries');

    % Load expressions for transport coefficients to check for zero diffusion
    transpexpr = mphgetexpressions(model.variable('transportcoeffs'));

    % Load expressions for flow parameters to check for zero convection
    plasexpr = mphgetexpressions(model.variable('plasma'));

   
    %% Set species fluxes for 1D case in Cartesian coordinates 
   
    if length(strfind(GeomName, 'Geom1D')) > 0

        % Set drift velocity for all species, except electrons
        variablesname = 'specprop';

        for i = 1:inp.Nspec

            if i == inp.eInd
                continue
            end

            id = num2str(i);

            if flags.nojac > 0
                b = ['nojac(b' id ')'];
            else
                b = ['b' id];
            end

            if sign(inp.Z(i)) > 0 && length(find(strcmp(transpexpr(:, 1), ['b', id]) == 1)) > 0
                model.variable(variablesname).set(['V', id, '_z'], ...
                    ['-', b, '*Phiz']);
            elseif sign(inp.Z(i)) < 0 && length(find(strcmp(transpexpr(:, 1), ['b', id]) == 1)) > 0
                model.variable(variablesname).set(['V', id, '_z'], ...
                    [b, '*Phiz']);
            end

        end

        % Set drift velocity for electrons
        i = inp.eInd;
        id = num2str(i);

        if strcmp(flags.enFlux, 'DDAn')  % Electron transport defined by DDAn aproximation

            if flags.nojac > 0
                b = 'nojac(e0/(me*nue))';
            else
                b = 'e0/(me*nue)';
            end

            model.variable(variablesname).set(['V', id, '_z'], [b, '*Phiz']);
        else  % Electron transport defined by DDAc and DDA53 aproximation

            if flags.nojac > 0
                b = ['nojac(b' id ')'];
            else
                b = ['b' id];
            end

            model.variable(variablesname).set(['V', id, '_z'], [b, '*Phiz']);
        end

        % Set drift velocity for electron energy
        if strcmp(flags.enFlux, 'DDAn')  % Electron transport defined by DDAn aproximation

            if flags.nojac > 0
                model.variable(variablesname).set('Veps_z', ...
                    'nojac(e0/(me*nueps)*(5/3+2/3*xi2/xi0))*Phiz');
            else
                model.variable(variablesname).set('Veps_z', ...
                    'e0/(me*nueps)*(5/3+2/3*xi2/xi0)*Phiz');
            end

        else  % Electron transport defined by DDAc and DDA53 aproximation

            if flags.nojac > 0
                model.variable(variablesname).set('Veps_z', ...
                    'nojac(beps)*Phiz');
            else
                model.variable(variablesname).set('Veps_z', ...
                    'beps*Phiz');
            end

        end
        
        % Set species fluxes for all species, except electrons
        variablesname = 'fluxes';
        specexpr = mphgetexpressions(model.variable('specprop'));
        
        for i = 1:inp.Nspec

            if i == inp.eInd
                continue
            end

            id = num2str(i);

            if flags.nojac > 0
                D = ['nojac(D', id, ')'];
            else
                D = ['D', id];
            end

            % Drift/convection + diffusion
            if length(find(strcmp(specexpr(:, 1), ['V', id, '_z']) == 1)) > 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_z'], ...
                    ['-', D, '*d(N', id, ',z) + V', id, '_z*N', id]);

            % Only drift/convection
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_z']) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_z'], ...
                    ['V', id, '_z*N', id]);

            % Only diffusion
            elseif length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_z'], ...
                    ['-', D, '*d(N', id, ',z)']);
            end

        end

        % Set flux for electrons
        i = inp.eInd;
        id = num2str(i);

        if strcmp(flags.enFlux, 'DDAn')  % Electron transport defined by DDAn aproximation

            if flags.nojac > 0
                Douter = 'nojac(e0/(me*nue))';
                Dinner = 'nojac((xi0+xi2))';
            else
                Douter = 'e0/(me*nue)';
                Dinner = '(xi0+xi2)';
            end

            model.variable(variablesname).set(['F', id, '_z'], ...
                ['-', Douter, '*d(', Dinner, '*N', id, ',z) + V', id, '_z*N', id]);
        else  % Electron transport defined by DDAc and DDA53 aproximation

            if flags.nojac > 0
                D = ['nojac(D', id, ')'];
            else
                D = ['D', id];
            end

            model.variable(variablesname).set(['F', id, '_z'], ...
                ['-d(', D, '*N', id, ',z) + V', id, '_z*N', id]);
        end

        % Set electron energy flux
        if strcmp(flags.enFlux, 'DDAn')  % Electron transport defined by DDAn aproximation

            if flags.nojac > 0
                model.variable(variablesname).set('Q_z', ...
                    ['-nojac(e0/(me*nueps))*d(nojac((xi0eps+xi2eps))*We,z)', ...
                 ' + Veps_z*We']);
            else
                model.variable(variablesname).set('Q_z', ...
                '-e0/(me*nueps)*d((xi0eps+xi2eps)*We,z) + Veps_z*We');
            end

        else  % Electron transport defined by DDAc and DDA53 aproximation

            if flags.nojac > 0
                model.variable(variablesname).set('Q_z', ...
                '-d(nojac(Deps)*We,z) + Veps_z*We');
            else
                model.variable(variablesname).set('Q_z', ...
                '-d(Deps*We,z) + Veps_z*We');
            end

        end

        % Set boundary fluxes for all species
        variablesname = 'bndfluxes';

        for i = 1:inp.Nspec
            id = num2str(i);

            % Separate for electrons because of secondary electron emission
            if i == inp.eInd
                
                posinp.iInd = find(inp.Z(inp.iInd) > 0);  % Secondary electron emission for positive ions, only

                iflux = [];

                for j = 1:length(posinp.iInd)

                    if length(iflux) > 0
                        iflux = [iflux, '+'];
                    end

                    iflux = [iflux, 'max(F', ...
                                 num2str(inp.iInd(posinp.iInd(j))), '_boundary,0)'];
                end

                % Particle flux
                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(abs(V', id, '_z*eq', id, '.nz*N', id, ')' ...
                     ' + 0.5*vth', id, '*N', id, ') - (2*gamma/(1+r', id, '))*(', iflux, ')']);

                % Energy flux
                model.variable(variablesname).set('Q_boundary', ...
                    ['((1-r', id, ')/(1+r', id, '))*(abs(Veps_z*eq', id, '.nz*We)' ...
                     ' + 2/3*vth', id, '*We) - umWall*(2*gamma/(1+r', id, '))*(', iflux, ')']);

            % Particles with diffusion and drift/convection
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_z']) == 1)) > 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0

                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(abs(V', id, '_z*eq', id, '.nz*N', id, ')' ...
                     ' + 0.5*vth', id, '*N', id, ')']);

            % Only diffusion
            elseif length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0

                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(0.5*vth', id, '*N', id, ')']);

            % Only drift/convection
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_z']) == 1)) > 0

                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['(1-r', id, ')*((max(V', id, '_z*eq', id, '.nz,0) + 0.25*vth', id, ')*N', id, ')']);
            end

        end

        % Displacement current
        model.variable(variablesname).set('DisplacementCurrent', ...
            '-epsilon0*epsilonr*Phizt*poeq.nz', 'Displacement current density');

    %% Set species fluxes for 1D case in polar coordinates

    elseif length(strfind(GeomName, 'Geom1p5D')) > 0

        % Set drift velocity for all species, except electrons
        variablesname = 'specprop';
       
        for i = 1:inp.Nspec

            if i == inp.eInd
                continue
            end

            id = num2str(i);

            if flags.nojac > 0
                b = ['nojac(b' id ')'];
            else
                b = ['b' id];
            end

            if sign(inp.Z(i)) > 0 && length(find(strcmp(transpexpr(:, 1), ['b', id]) == 1)) > 0
                model.variable(variablesname).set(['V', id, '_r'], ...
                    ['-', b, '*Phir']);
            elseif sign(inp.Z(i)) < 0 && length(find(strcmp(transpexpr(:, 1), ['b', id]) == 1)) > 0
                model.variable(variablesname).set(['V', id, '_r'], ...
                    [b, '*Phir']);
            end

        end

        % Set drift velocity for electrons
        i = inp.eInd;
        id = num2str(i);

        if strcmp(flags.enFlux, 'DDAn') % Electron transport defined by DDAn approximation

            if flags.nojac > 0
                b = 'nojac(e0/(me*nue))';
            else
                b = 'e0/(me*nue)';
            end

            model.variable(variablesname).set(['V', id, '_r'], [b, '*Phir']);
        else  % Electron transport defined by DDAc and DDA53 approximations

            if flags.nojac > 0
                b = ['nojac(b' id ')'];
            else
                b = ['b' id];
            end

            model.variable(variablesname).set(['V', id, '_r'], [b, '*Phir']);
        end

        % Set drift velocity for electron energy
        if strcmp(flags.enFlux, 'DDAn')   % Electron transport defined by DDAn approximation

            if flags.nojac > 0
                model.variable(variablesname).set('Veps_r', ...
                    'nojac(e0/(me*nueps)*(5/3+2/3*xi2/xi0))*Phir');
            else
                model.variable(variablesname).set('Veps_r', ...
                    'e0/(me*nueps)*(5/3+2/3*xi2/xi0)*Phir');
            end

        else  % Electron transport defined by DDAc and DDA53 approximations

            if flags.nojac > 0
                model.variable(variablesname).set('Veps_r', ...
                    'nojac(beps)*Phir');
            else
                model.variable(variablesname).set('Veps_r', ...
                    'beps*Phir');
            end

        end

        % Set species fluxes for all species, except electrons
        variablesname = 'fluxes';
        specexpr = mphgetexpressions(model.variable('specprop'));
        
        for i = 1:inp.Nspec

            if i == inp.eInd
                continue
            end

            id = num2str(i);

            if flags.nojac > 0
                D = ['nojac(D', id, ')'];
            else
                D = ['D', id];
            end

            % Drift/convection + diffusion
            if length(find(strcmp(specexpr(:, 1), ['V', id, '_r']) == 1)) > 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_r'], ...
                    ['-', D, '*d(N', id, ',r) + V', id, '_r*N', id]);

            % Only drift/convection
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_r']) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_r'], ...
                    ['V', id, '_r*N', id]);

            % Only diffusion
            elseif length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_r'], ...
                    ['-', D, '*d(N', id, ',r)']);
            end

        end

        % Set flux for electrons
        i = inp.eInd;
        id = num2str(i);

        if strcmp(flags.enFlux, 'DDAn')  % Electron transport defined by DDAn approximation

            if flags.nojac > 0
                Douter = 'nojac(1/(me*nue))';
                Dinner = 'nojac((xi0+xi2))';
            else
                Douter = 'e0/(me*nue)';
                Dinner = '(xi0+xi2)';
            end

            model.variable(variablesname).set(['F', id, '_r'], ...
                ['-', Douter, '*d(', Dinner, '*N', id, ',r) + V', id, '_r*N', id]);
        else  % Electron transport defined by DDAc and DDA53 approximations

            if flags.nojac > 0
                D = ['nojac(D', id, ')'];
            else
                D = ['D', id];
            end

            model.variable(variablesname).set(['F', id, '_r'], ...
                ['-d(', D, '*N', id, ',r) + V', id, '_r*N', id]);
        end

        % Set electron energy flux
        if strcmp(flags.enFlux, 'DDAn')  % Electron transport defined by DDAn approximation

            if flags.nojac > 0
                model.variable(variablesname).set('Q_r', ...
                    ['-nojac(e0/(me*nueps))*d(nojac((xi0eps+xi2eps))*We,r)', ...
                 ' + Veps_r*We']);
            else
                model.variable(variablesname).set('Q_r', ...
                '-e0/(me*nueps)*d((xi0eps+xi2eps)*We,r) + Veps_r*We');
            end

        else  % Electron transport defined by DDAc and DDA53 approximations

            if flags.nojac > 0
                model.variable(variablesname).set('Q_r', ...
                '-d(nojac(Deps)*We,r) + Veps_r*We');
            else
                model.variable(variablesname).set('Q_r', ...
                '-d(Deps*We,r) + Veps_r*We');
            end

        end

        % Set boundary fluxes for all species
        variablesname = 'bndfluxes';

        for i = 1:inp.Nspec
            id = num2str(i);

            % Separate for electrons because of secondary electron emission
            if i == inp.eInd
                
                posinp.iInd = find(inp.Z(inp.iInd) > 0);  % Secondary electron emission for positive ions, only

                iflux = [];

                for j = 1:length(posinp.iInd)

                    if length(iflux) > 0
                        iflux = [iflux, '+'];
                    end

                    iflux = [iflux, 'max(F', ...
                                 num2str(inp.iInd(posinp.iInd(j))), '_boundary,0)'];
                end

                % Particle flux
                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(abs(V', id, '_r*eq', id, '.nr*N', id, ')' ...
                     ' + 0.5*vth', id, '*N', id, ') - (2*gamma/(1+r', id, '))*(', iflux, ')']);

                % Energy flux
                model.variable(variablesname).set('Q_boundary', ...
                    ['((1-r', id, ')/(1+r', id, '))*(abs(Veps_r*eq', id, '.nr*We)' ...
                     ' + 2/3*vth', id, '*We) - umWall*(2*gamma/(1+r', id, '))*(', iflux, ')']);

            % Particles with diffusion and drift/convection
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_r']) == 1)) > 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0

                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(abs(V', id, '_r*eq', id, '.nr*N', id, ')' ...
                     ' + 0.5*vth', id, '*N', id, ')']);

            % Only diffusion
            elseif length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0

                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(0.5*vth', id, '*N', id, ')']);

            % Only drift/convection
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_r']) == 1)) > 0

                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['(1-r', id, ')*((max(V', id, '_r*eq', id, '.nr,0) + 0.25*vth', id, ')*N', id, ')']);
            end

        end

        % Displacement current
        model.variable(variablesname).set('DisplacementCurrent', ...
            ['-epsilon0*epsilonr*Phirt*poeq.nr'], 'Displacement current density');

    %% Set species fluxes for 2D case in Cartesian coordinates
    
    elseif length(strfind(GeomName, 'Geom2D')) > 0

        variablesname = 'specprop';
        
        % Set convection velocity
        if strcmp(flags.convflux, 'on')
            msg(3, 'convection included', flags)
            vconv_x = '+u';
            vconv_y = '+w';
        else
            msg(3, 'convection not included', flags)
            vconv_x = '';
            vconv_y = '';
        end

        % Set drift velocity for all species, except electrons
        for i = 1:inp.Nspec

            if i == inp.eInd
                continue
            end

            id = num2str(i);

            if flags.nojac > 0
                b = ['nojac(b' id ')'];
            else
                b = ['b' id];
            end

            if sign(inp.Z(i)) > 0 && length(find(strcmp(transpexpr(:, 1), ['b', id]) == 1)) > 0
                model.variable(variablesname).set(['V', id, '_y'], ...
                    ['-', b, '*Phiy', vconv_y]);
                model.variable(variablesname).set(['V', id, '_x'], ...
                    ['-', b, '*Phix', vconv_x]);
            elseif sign(inp.Z(i)) < 0 && length(find(strcmp(transpexpr(:, 1), ['b', id]) == 1)) > 0
                model.variable(variablesname).set(['V', id, '_y'], ...
                    [b, '*Phiy', vconv_y]);
                model.variable(variablesname).set(['V', id, '_x'], ...
                    [b, '*Phix', vconv_x]);
            else

                if strcmp(flags.convflux, 'on')
                    model.variable(variablesname).set(['V', id, '_y'], 'w');
                    model.variable(variablesname).set(['V', id, '_x'], 'u');
                end

            end

        end

        % Set drift velocity for electrons
        i = inp.eInd;
        id = num2str(i);

        if strcmp(flags.enFlux, 'DDAn')  % Electron transport defined by DDAn approximation

            if flags.nojac > 0
                b = 'nojac(e0/(me*nue))';
            else
                b = 'e0/(me*nue)';
            end

            model.variable(variablesname).set(['V', id, '_y'], [b, '*Phiy']);
            model.variable(variablesname).set(['V', id, '_x'], [b, '*Phix']);
        else  % Electron transport defined by DDAc and DDA53 approximations

            if flags.nojac > 0
                b = ['nojac(b' id ')'];
            else
                b = ['b' id];
            end

            model.variable(variablesname).set(['V', id, '_y'], [b, '*Phiy']);
            model.variable(variablesname).set(['V', id, '_x'], [b, '*Phix']);
        end

        % Set drift velocity for electron energy
        if strcmp(flags.enFlux, 'DDAn')  % Electron transport defined by DDAn approximation

            if flags.nojac > 0
                model.variable(variablesname).set('Veps_y', ...
                    'nojac(e0/(me*nueps)*(5/3+2/3*xi2/xi0))*Phiy');
                model.variable(variablesname).set('Veps_x', ...
                    'nojac(e0/(me*nueps)*(5/3+2/3*xi2/xi0))*Phix');
            else
                model.variable(variablesname).set('Veps_y', ...
                    'e0/(me*nueps)*(5/3+2/3*xi2/xi0)*Phiy');
                model.variable(variablesname).set('Veps_x', ...
                    'e0/(me*nueps)*(5/3+2/3*xi2/xi0)*Phix');

            end

        else  % Electron transport defined by DDAc and DDA53 approximations

            if flags.nojac > 0
                model.variable(variablesname).set('Veps_y', ...
                    'nojac(beps)*Phiy');
                model.variable(variablesname).set('Veps_x', ...
                    'nojac(beps)*Phix');

            else
                model.variable(variablesname).set('Veps_y', ...
                    'beps*Phiy');
                model.variable(variablesname).set('Veps_x', ...
                    'beps*Phix');

            end

        end

        % Set species fluxes for all species, except electrons
        variablesname = 'fluxes';
        specexpr = mphgetexpressions(model.variable('specprop'));

        for i = 1:inp.Nspec

            if i == inp.eInd
                continue
            end

            id = num2str(i);

            if flags.nojac > 0
                D = ['nojac(D', id, ')'];
            else
                D = ['D', id];
            end

            % Drift/convection + diffusion
            if length(find(strcmp(specexpr(:, 1), ['V', id, '_y']) == 1)) > 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_y'], ...
                    ['-', D, '*d(N', id, ',y) + V', id, '_y*N', id]);
                model.variable(variablesname).set(['F', id, '_x'], ...
                    ['-', D, '*d(N', id, ',x) + V', id, '_x*N', id]);

            % Only drift/convection
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_y']) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_y'], ...
                    ['V', id, '_y*N', id]);
                model.variable(variablesname).set(['F', id, '_x'], ...
                    ['V', id, '_x*N', id]);

            % Only diffusion
            elseif length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_y'], ...
                    ['-', D, '*d(N', id, ',y)']);
                model.variable(variablesname).set(['F', id, '_x'], ...
                    ['-', D, '*d(N', id, ',x)']);
            end

        end

        % Set flux for electrons
        i = inp.eInd;
        id = num2str(i);

        if strcmp(flags.enFlux, 'DDAn')  % Electron transport defined by DDAn approximation

            if flags.nojac > 0
                Douter = 'nojac(1/(me*nue))';
                Dinner = 'nojac((xi0+xi2))';
            else
                Douter = 'e0/(me*nue)';
                Dinner = '(xi0+xi2)';
            end

            model.variable(variablesname).set(['F', id, '_y'], ...
                ['-', Douter, '*d(', Dinner, '*N', id, ',y) + V', id, '_y*N', id]);
            model.variable(variablesname).set(['F', id, '_x'], ...
                ['-', Douter, '*d(', Dinner, '*N', id, ',x) + V', id, '_x*N', id]);

        else  % Electron transport defined by DDAc and DDA53 approximations

            if flags.nojac > 0
                D = ['nojac(D', id, ')'];
            else
                D = ['D', id];
            end

            model.variable(variablesname).set(['F', id, '_y'], ...
                ['-d(', D, '*N', id, ',y) + V', id, '_y*N', id]);
            model.variable(variablesname).set(['F', id, '_x'], ...
                ['-d(', D, '*N', id, ',x) + V', id, '_x*N', id]);

        end

        % Set flux for electron energy
        if strcmp(flags.enFlux, 'DDAn')  % Electron transport defined by DDAn

            if flags.nojac > 0
                model.variable(variablesname).set('Q_y', ...
                    ['-nojac(e0/(me*nueps))*d(nojac((xi0eps+xi2eps))*We,y)', ...
                 ' + Veps_y*We']);
                model.variable(variablesname).set('Q_x', ...
                    ['-nojac(e0/(me*nueps))*d(nojac((xi0eps+xi2eps))*We,x)', ...
                 ' + Veps_x*We']);

            else
                model.variable(variablesname).set('Q_y', ...
                '-e0/(me*nueps)*d((xi0eps+xi2eps)*We,y) + Veps_y*We');
                model.variable(variablesname).set('Q_x', ...
                '-e0/(me*nueps)*d((xi0eps+xi2eps)*We,x) + Veps_x*We');

            end

        else  % Electron transport defined by DDAc and DDA53 approximations

            if flags.nojac > 0
                model.variable(variablesname).set('Q_y', ...
                '-d(nojac(Deps)*We,y) + Veps_y*We');
                model.variable(variablesname).set('Q_x', ...
                '-d(nojac(Deps)*We,x) + Veps_x*We');

            else
                model.variable(variablesname).set('Q_y', ...
                '-d(Deps*We,y) + Veps_y*We');
                model.variable(variablesname).set('Q_x', ...
                '-d(Deps*We,x) + Veps_x*We');

            end

        end

        % Set boundary fluxes for all species
        variablesname = 'bndfluxes';

        for i = 1:inp.Nspec
            id = num2str(i);

            % Separate for electrons because of secondary electron emission
            if i == inp.eInd

                
                posinp.iInd = find(inp.Z(inp.iInd) > 0);  % Secondary electron emission for positive ions, only

                iflux = [];

                for j = 1:length(posinp.iInd)

                    if length(iflux) > 0
                        iflux = [iflux, '+'];
                    end

                    iflux = [iflux, ...
                                 'max(F', num2str(inp.iInd(posinp.iInd(j))), '_boundary,0)'];
                end

                % Particle flux
                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(abs(V', id, '_y*eq', id, '.ny + V', id, '_x*eq', id, '.nx)*N', id, ...
                     ' + 0.5*vth', id, '*N', id, ') - (2*gamma/(1+r', id, '))*(', iflux, ')']);

                % Energy flux
                model.variable(variablesname).set('Q_boundary', ...
                    ['((1-r', id, ')/(1+r', id, '))*(abs(Veps_y*eq', id, '.ny + Veps_x*eq', id, '.nx)*We', ...
                     ' + 2/3*vth', id, '*We) - umWall*(2*gamma/(1+r', id, '))*(', iflux, ')']);

            % Particles with diffusion and drift/convection
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_y']) == 1)) > 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0

                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(abs(V', id, '_y*eq', id, '.ny + V', id, '_x*eq', id, '.nx)*N', id, ...
                     ' + 0.5*vth', id, '*N', id, ')']);

            % Only diffusion
            elseif length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0

                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(0.5*vth', id, '*N', id, ')']);

            % Only drift/convection
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_y']) == 1)) > 0

                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['(1-r', id, ')*((max(V', id, '_y*eq', id, '.ny + V', id, '_x*eq', id, '.nx,0) + 1/4*vth', id, ')*N', id, ')']);
            end

        end

        % Displacement current
        model.variable(variablesname).set('DisplacementCurrent', ...
            ['-epsilon0*epsilonr*(Phiyt*poeq.ny+Phixt*poeq.nx)'], ...
        'Displacement current density');
        
    %% Set species fluxes for 2D case in cylindrical coordinates
    
    elseif length(strfind(GeomName, 'Geom2p5D')) > 0
        
        variablesname = 'specprop';

        % Set convection velocity
        if strcmp(flags.convflux, 'on')
            msg(3, 'convection included', flags)
            vconv_r = '+u';
            vconv_z = '+w';
        else
            msg(3, 'convection not included', flags)
            vconv_r = '';
            vconv_z = '';
        end

        % Set drift velocity for all species, except electrons
        for i = 1:inp.Nspec

            if i == inp.eInd
                continue
            end

            id = num2str(i);

            if flags.nojac > 0
                b = ['nojac(b' id ')'];
            else
                b = ['b' id];
            end

            if sign(inp.Z(i)) > 0 && length(find(strcmp(transpexpr(:, 1), ['b', id]) == 1)) > 0
                model.variable(variablesname).set(['V', id, '_z'], ...
                    ['-', b, '*Phiz', vconv_z]);
                model.variable(variablesname).set(['V', id, '_r'], ...
                    ['-', b, '*Phir', vconv_r]);
            elseif sign(inp.Z(i)) < 0 && length(find(strcmp(transpexpr(:, 1), ['b', id]) == 1)) > 0
                model.variable(variablesname).set(['V', id, '_z'], ...
                    [b, '*Phiz', vconv_z]);
                model.variable(variablesname).set(['V', id, '_r'], ...
                    [b, '*Phir', vconv_r]);
            else

                if strcmp(flags.convflux, 'on')
                    model.variable(variablesname).set(['V', id, '_z'], 'w');
                    model.variable(variablesname).set(['V', id, '_r'], 'u');
                end

            end

        end

        % Set drift velocity for electrons
        i = inp.eInd;
        id = num2str(i);

        if strcmp(flags.enFlux, 'DDAn')  % Electron transport defined by DDAn approximation

            if flags.nojac > 0
                b = 'nojac(e0/(me*nue))';
            else
                b = 'e0/(me*nue)';
            end

            model.variable(variablesname).set(['V', id, '_z'], [b, '*Phiz']);
            model.variable(variablesname).set(['V', id, '_r'], [b, '*Phir']);
        else  % Electron transport defined by DDAc and DDA53 approximations

            if flags.nojac > 0
                b = ['nojac(b' id ')'];
            else
                b = ['b' id];
            end

            model.variable(variablesname).set(['V', id, '_z'], [b, '*Phiz']);
            model.variable(variablesname).set(['V', id, '_r'], [b, '*Phir']);
        end

        % Set drift velocity for electron energy
        if strcmp(flags.enFlux, 'DDAn')  % Electron transport defined by DDAn approximation

            if flags.nojac > 0
                model.variable(variablesname).set('Veps_z', ...
                    'nojac(e0/(me*nueps)*(5/3+2/3*xi2/xi0))*Phiz');
                model.variable(variablesname).set('Veps_r', ...
                    'nojac(e0/(me*nueps)*(5/3+2/3*xi2/xi0))*Phir');
            else
                model.variable(variablesname).set('Veps_z', ...
                    'e0/(me*nueps)*(5/3+2/3*xi2/xi0)*Phiz');
                model.variable(variablesname).set('Veps_r', ...
                    'e0/(me*nueps)*(5/3+2/3*xi2/xi0)*Phir');

            end

        else  % Electron transport defined by DDAc and DDA53 approximations

            if flags.nojac > 0
                model.variable(variablesname).set('Veps_z', ...
                    'nojac(beps)*Phiz');
                model.variable(variablesname).set('Veps_r', ...
                    'nojac(beps)*Phir');

            else
                model.variable(variablesname).set('Veps_z', ...
                    'beps*Phiz');
                model.variable(variablesname).set('Veps_r', ...
                    'beps*Phir');

            end

        end

        % Set species fluxes for all species, except electrons
        variablesname = 'fluxes';
        specexpr = mphgetexpressions(model.variable('specprop'));

        for i = 1:inp.Nspec

            if i == inp.eInd
                continue
            end

            id = num2str(i);

            if flags.nojac > 0
                D = ['nojac(D', id, ')'];
            else
                D = ['D', id];
            end

            % Drift/convection + diffusion
            if length(find(strcmp(specexpr(:, 1), ['V', id, '_z']) == 1)) > 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_z'], ...
                    ['-', D, '*d(N', id, ',z) + V', id, '_z*N', id]);
                model.variable(variablesname).set(['F', id, '_r'], ...
                    ['-', D, '*d(N', id, ',r) + V', id, '_r*N', id]);

            % Only drift/convection
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_z']) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_z'], ...
                    ['V', id, '_z*N', id]);
                model.variable(variablesname).set(['F', id, '_r'], ...
                    ['V', id, '_r*N', id]);

            % Only diffusion
            elseif length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0
                model.variable(variablesname).set(['F', id, '_z'], ...
                    ['-', D, '*d(N', id, ',z)']);
                model.variable(variablesname).set(['F', id, '_r'], ...
                    ['-', D, '*d(N', id, ',r)']);
            end

        end

        % Set flux for electrons
        i = inp.eInd;
        id = num2str(i);

        if strcmp(flags.enFlux, 'DDAn')  % Electron transport defined by DDAn

            if flags.nojac > 0
                Douter = 'nojac(1/(me*nue))';
                Dinner = 'nojac((xi0+xi2))';
            else
                Douter = 'e0/(me*nue)';
                Dinner = '(xi0+xi2)';
            end

            model.variable(variablesname).set(['F', id, '_z'], ...
                ['-', Douter, '*d(', Dinner, '*N', id, ',z) + V', id, '_z*N', id]);
            model.variable(variablesname).set(['F', id, '_r'], ...
                ['-', Douter, '*d(', Dinner, '*N', id, ',r) + V', id, '_r*N', id]);

        else  % Electron transport defined by DDAc and DDA53 approximations

            if flags.nojac > 0
                D = ['nojac(D', id, ')'];
            else
                D = ['D', id];
            end

            model.variable(variablesname).set(['F', id, '_z'], ...
                ['-d(', D, '*N', id, ',z) + V', id, '_z*N', id]);
            model.variable(variablesname).set(['F', id, '_r'], ...
                ['-d(', D, '*N', id, ',r) + V', id, '_r*N', id]);

        end

        % Set electron energy flux
        if strcmp(flags.enFlux, 'DDAn')  % Electron transport defined by DDAn approximation

            if flags.nojac > 0
                model.variable(variablesname).set('Q_z', ...
                    ['-nojac(e0/(me*nueps))*d(nojac((xi0eps+xi2eps))*We,z)', ...
                 ' + Veps_z*We']);
                model.variable(variablesname).set('Q_r', ...
                    ['-nojac(e0/(me*nueps))*d(nojac((xi0eps+xi2eps))*We,r)', ...
                 ' + Veps_r*We']);

            else
                model.variable(variablesname).set('Q_z', ...
                '-e0/(me*nueps)*d((xi0eps+xi2eps)*We,z) + Veps_z*We');
                model.variable(variablesname).set('Q_r', ...
                '-e0/(me*nueps)*d((xi0eps+xi2eps)*We,r) + Veps_r*We');

            end

        else  % Electron transport defined by DDAc and DDA53 approximations

            if flags.nojac > 0
                model.variable(variablesname).set('Q_z', ...
                '-d(nojac(Deps)*We,z) + Veps_z*We');
                model.variable(variablesname).set('Q_r', ...
                '-d(nojac(Deps)*We,r) + Veps_r*We');

            else
                model.variable(variablesname).set('Q_z', ...
                '-d(Deps*We,z) + Veps_z*We');
                model.variable(variablesname).set('Q_r', ...
                '-d(Deps*We,r) + Veps_r*We');

            end

        end

        % Set boundary fluxes for all species
        variablesname = 'bndfluxes';

        for i = 1:inp.Nspec
            id = num2str(i);

            % Separate for electrons because of secondary electron emission
            if i == inp.eInd

                
                posinp.iInd = find(inp.Z(inp.iInd) > 0);  % Secondary electron emission for positive ions, only

                iflux = [];

                for j = 1:length(posinp.iInd)

                    if length(iflux) > 0
                        iflux = [iflux, '+'];
                    end

                    iflux = [iflux, ...
                                 'max(F', num2str(inp.iInd(posinp.iInd(j))), '_boundary,0)'];
                end

                % Particle flux
                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(abs(V', id, '_z*eq', id, '.nz + V', id, '_r*eq', id, '.nr)*N', id, ...
                     ' + 0.5*vth', id, '*N', id, ') - (2*gamma/(1+r', id, '))*(', iflux, ')']);

                % Energy flux
                model.variable(variablesname).set(['Q_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(abs(Veps_z*eq', id, '.nz + Veps_r*eq', id, '.nr)*We', ...
                     ' + 2/3*vth', id, '*We) - umWall*(2*gamma/(1+r', id, '))*(', iflux, ')']);

            % Particles with diffusion and drift/convection
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_z']) == 1)) > 0 && ...
                    length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0

                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(abs(V', id, '_z*eq', id, '.nz + V', id, '_r*eq', id, '.nr)*N', id, ...
                     ' + 0.5*vth', id, '*N', id, ')']);

            % Only diffusion
            elseif length(find(strcmp(transpexpr(:, 1), ['D', id]) == 1)) > 0

                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['((1-r', id, ')/(1+r', id, '))*(0.5*vth', id, '*N', id, ')']);

            % Only drift/convection
            elseif length(find(strcmp(specexpr(:, 1), ['V', id, '_z']) == 1)) > 0

                model.variable(variablesname).set(['F', id, '_boundary'], ...
                    ['(1-r', id, ')*((max(V', id, '_z*eq', id, '.nz + V', id, '_r*eq', id, '.nr,0) + 1/4*vth', id, ')*N', id, ')']);
            end

        end

        % Displacement current
        model.variable(variablesname).set('DisplacementCurrent', ...
            ['-epsilon0*epsilonr*(Phizt*poeq.nz+Phirt*poeq.nr)'], ...
        'Displacement current density');

    else
        error('invalid value of GeomName in SetFluxes.m');
    end

    % Charge carrier flux onto the wall
    tmp = ['-F', num2str(inp.eInd), '_boundary'];

    for i = 1:inp.Nspec
        id = num2str(i);

        if inp.Z(i) > 0
            tmp = [tmp, '+', num2str(inp.Z(i)), '*F', id, '_boundary'];
        elseif inp.Z(i) < 0 && i ~= inp.eInd
            tmp = [tmp, '-', num2str(abs(inp.Z(i))), '*F', id, '_boundary'];
        end

    end

    model.variable(variablesname).set('NormalChCFlux', ...
        ['e0*(', tmp, ')'], 'Charge carrier flux onto the wall');

end
