function ActivatePlasma(study, ok, model, inp)

  model.study(study).feature('time').activate('sceq', ok);
  model.study(study).feature('time').activate('poeq', ok);
  for i = 1:inp.Nspec
    id = num2str(i);
    Eqid = ['eq',id];
    if any(i==inp.n0Ind)            
      continue
    else     
      model.study(study).feature('time').activate(Eqid, ok);
    end
  end
  model.study(study).feature('time').activate(inp.eEnergyEqn, ok);
  tmp='deactivated';
  if (ok) 
    tmp='activated';
  end
  disp(['  Plasma equations in study ' study ' ' tmp])
end
