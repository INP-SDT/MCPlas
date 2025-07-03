function ismember = IsModelMember(ModelNodeTags, name)
    %
    % IsModelMember function checks if 'name' is member of the model node.
    %
    % :param ModelNodeTags: the first input
    % :param name:          the second input

    ismember = false;  % Initialize output as false
    tmp = ModelNodeTags;  % Temporary copy of input array

    for i = 1:length(ModelNodeTags)
        ismember = strcmp(tmp(i), name);  % Compare each entry to the target name

        if ismember
            break  % Stop search once match is found
        end
    end
end

