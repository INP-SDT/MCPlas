function C = num2cellstr(A)
%
% num2cellstr uses table data (A) for making cell array data type (C) for easy
% set up of variables via functions specific for Live link for MATLAB module 
%
% :param A: input
% :returns: ``C`` output

    C = cell(size(A,1),size(A,2));
    
    for i = 1:size(A,1)
        for j = 1:size(A,2)
            C{i,j} = num2str(A(i,j),'%12.7e\n');
        end
    end
    
end
