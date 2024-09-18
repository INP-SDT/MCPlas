function [U] = sine_signal(U0,freq,t)
% a fun function
%
% :param U0: the first input
% :param freq: the second input
% :param freq: the third input
% :returns: ``[U]`` some outputs   

U = U0*sin(2*pi*freq*t);

end

