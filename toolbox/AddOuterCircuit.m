function OuterCircuit

  global model GeomName flags inp;
  
  % simple RC circuit
  if strcmp(flags.circuit,'RC')
    msg(1,['setting outer circuit ' flags.circuit]);
    msg(2,'requires parameters CircResist, CircCap');
    
    % add circuit elements
    model.physics.create('cir', 'Circuit', GeomName);
    model.physics('cir').feature.create('V1', 'VoltageSource', -1);
    model.physics('cir').feature('V1').label('Generator');
    model.physics('cir').feature('V1').set('DeviceName', 'VSource');
    model.physics('cir').feature('V1').set('value', inp.AppliedVoltage);

    model.physics('cir').feature.create('R1', 'Resistor', -1);
    model.physics('cir').feature('R1').label('Resistor');
    model.physics('cir').feature('R1').set('DeviceName', 'Resist');
    model.physics('cir').feature('R1').setIndex('Connections', '2', 1, 0);
    model.physics('cir').feature('R1').set('R', 'CircResist');

    model.physics('cir').feature.create('C1', 'Capacitor', -1);
    model.physics('cir').feature('C1').label('Capacitor');
    model.physics('cir').feature('C1').set('DeviceName', 'Capacitor');
    model.physics('cir').feature('C1').setIndex('Connections', '2', 0, 0);
    model.physics('cir').feature('C1').set('C', 'CircCap');

    model.physics('cir').feature.create('I1', 'CurrentSourceCircuit', -1);
    model.physics('cir').feature('I1').label('Discharge');
    model.physics('cir').feature('I1').set('DeviceName', 'Discharge');
    model.physics('cir').feature('I1').setIndex('Connections', '2', 0, 0);
    model.physics('cir').feature('I1').set('value', 'Idischarge');

    % set electrical variables depending on the circuit
    varname = 'electrical';
    if ~IsModelMember(model.variable.tags, varname)
        model.variable.create(varname);  
        model.variable(varname).name('Electrical');
        model.variable(varname).model('mod1');    
    end    
    model.variable(varname).set('PoweredVoltage', 'cir.v_2', ...
        'Powered voltage');
    model.variable(varname).set('GeneratorVoltage', 'cir.v_1', ...
        'Generator voltage');   
    model.variable(varname).set('Igen', 'cir.R1_i', ...
        'Generator current');             
  else
    error(['wrong circuit flag ' flags.circuit]);
  end  

end

