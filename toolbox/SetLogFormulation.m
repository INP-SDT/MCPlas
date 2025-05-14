function SetLogFormulation(inp, model)

       
    % read expressions for fluxes to check for F=0
    fluxexpr = mphgetexpressions(model.variable('fluxes')); 

    % change dependent variable N -> n = log(N) in ODE/PDE
    variablesname = 'specprop';
    for i = 1:inp.Nspec
    
        id = num2str(i);
        Eqid = ['eq',id];
        
        if any(i == inp.n0Ind)
            continue;
        elseif length(find(strcmp(fluxexpr(:,1),['F',id,'_z'])==1)) == 0 ...
            && length(find(strcmp(fluxexpr(:,1),['F',id,'_r'])==1)) == 0 ...
            && length(find(strcmp(fluxexpr(:,1),['F',id,'_x'])==1)) == 0 ...
            && length(find(strcmp(fluxexpr(:,1),['F',id,'_y'])==1)) == 0
                        
            model.physics(Eqid).field('dimensionless').component(1, ['n',id]);
            model.physics(Eqid).prop('Units').set( ...
                'CustomDependentVariableUnit', '1');
            model.physics(Eqid).feature('dode1').set('da', 1, ['N',id]);
            model.physics(Eqid).feature('init1').set(['n',id], 1, ...
                ['log(',num2str(inp.Dspec_init(i)),')']);
            model.variable(variablesname).set(['N',id], ...
                ['exp(n',id,')*1[1/m^3]'], ...
                ['Density of ',inp.specnames{i}]);
        else     
            model.physics(Eqid).field('dimensionless').component(1, ['n',id]);
            model.physics(Eqid).prop('Units').set( ...
                'CustomDependentVariableUnit', '1');
            model.physics(Eqid).feature('gfeq1').set('da', 1, ['N',id]);
            model.physics(Eqid).feature('init1').set(['n',id], 1, ...
                ['log(',num2str(inp.Dspec_init(i)),')']);
            model.variable(variablesname).set(['N',id], ...
                ['exp(n',id,')*1[1/m^3]'], ...
                ['Density of ',inp.specnames{i}]);
        end
        
    end
    
    Eqid = ['eq',num2str(inp.Nspec+1)];
    model.physics(Eqid).field('dimensionless').component(1, 'we');
    model.physics(Eqid).prop('Units').set('CustomDependentVariableUnit', '1');
    model.physics(Eqid).prop('Units').set('CustomSourceTermUnit', 'V/(m^3*s)');
    model.physics(Eqid).feature('gfeq1').set('da', 1, 'We');
    model.physics(Eqid).feature('init1').set('we', 1, ...
        ['log(3*',num2str(inp.Dspec_init(inp.eInd)),')']);
    model.variable(variablesname).set('We', ...
        ['exp(we)*1[V/m^3]'],'Electron energy density');
    
end
