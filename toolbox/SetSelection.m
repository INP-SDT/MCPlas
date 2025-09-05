function SetSelection(model, geom, sel, Name, components)
    %
    % SetSection function uses functions specific for the LiveLink
    % for MATLAB module to group modelling domains into sections, for easier work with the generated Comsol model.
    % 	
    % :param model: the first input
    % :param geom: the second input
    % :param sel: the third input
    % :param Name: the fourth input
    % :param components: the fifth input	
	
  model.selection.create(sel, 'Explicit');
  model.selection(sel).label(Name);
  model.selection(sel).geom(geom);
  if components==0
    msg(3,['no components for selection "' Name '"'])
  else
    model.selection(sel).set(components);
  end
end

