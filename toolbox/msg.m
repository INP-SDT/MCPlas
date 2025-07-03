function msg(num, txt, flags)
    %
    % msg function print message txt on console depending on num:
    % 0: no messages
    % 1: main messages
    % 2: +sub messages
    % 3: detailed messages
    % 4: debug messages
    %
    % :param num: the first input
    % :param txt: the second input
    % :param flags: the third input
    
    if flags.debug >= num
        sp = '';
        for i = 2:num
            sp = [sp '  '];
        end
        disp([sp txt]);
    end
end
