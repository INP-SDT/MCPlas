function obj = ReadJSON(file)
%
% ReadJSON function reads json data from file and returns json object 
% which can be accessed using usual dot notation.
% %
% :param JSON file: the first input
% :returns: ``obj`` json object

    str = fileread(file);
    obj = jsondecode(str);

end
