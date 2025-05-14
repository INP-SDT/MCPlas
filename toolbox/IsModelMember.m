function ismember = IsModelMember(ModelNodeTags,name)  
%
% ismember = IsModelMember(ModelNodeTags,name) 
% checks if 'name' is member of the model node

  ismember = false;
  tmp = ModelNodeTags;
  for i=1:length(ModelNodeTags)
    ismember = strcmp(tmp(i),name);
    if ismember
      break;
    end   
  end   
   
end
