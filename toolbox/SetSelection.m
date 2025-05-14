function SetSelection(model, geom, sel, Name, components)

  model.selection.create(sel, 'Explicit');
  model.selection(sel).label(Name);
  model.selection(sel).geom(geom);
  if components==0
    msg(3,['no components for selection "' Name '"'])
  else
    model.selection(sel).set(components);
  end
end

