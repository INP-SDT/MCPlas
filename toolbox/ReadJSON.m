function obj = ReadJSON(file)
    %
    % ReadJSON function reads json data from file and returns json object
    % which can be accessed using usual dot notation.
    % %
    % :param JSON file: the first input
    % :returns: ``obj`` json object

    outputFile = 'temp.json';  % New JSON file (temporary)

    fid = fopen(file,'r','n','UTF-8');  % Read JSON as text
    if fid == -1
        error('Could not open input file: %s', file);
    end
    rawText = fread(fid,'*char')';
    fclose(fid);

    % Define special character replacements
    replacements = { ...
        '-'     , '_ds_'; ...     % dash
        ' '     , '_sp_'; ...     % space
        '.'     , '_dt_'; ...     % dot
        '@'     , '_at_'; ...     % at
        '#'     , '_hs_'; ...     % hash
        '$'     , '_dl_'; ...     % dollar
        '%'     , '_pc_'; ...     % percent
        '^'     , '_ct_'; ...     % caret
        '&'     , '_ad_'; ...     % and
        '*'     , '_st_'; ...     % star
        '('     , '_lp_'; ...     % left paren
        ')'     , '_rp_'; ...     % right paren
        '['     , '_lb_'; ...     % left bracket
        ']'     , '_rb_'; ...     % right bracket
        '{'     , '_lc_'; ...     % left brace
        '}'     , '_rc_'; ...     % right brace
        ':'     , '_cl_'; ...     % colon
        ';'     , '_sc_'; ...     % semicolon
        '"'     , '_qt_'; ...     % quote
        char(39), '_ap_'; ...     % apostrophe
        '<'     , '_lt_'; ...     % less than
        '>'     , '_gt_'; ...     % greater than
        '/'     , '_sl_'; ...     % slash
        '\'     , '_bs_'; ...     % backslash
        '|'     , '_pi_'; ...     % pipe
        '?'     , '_qm_'; ...     % question mark
        '!'     , '_bg_'; ...     % bang/exclamation
        '~'     , '_tl_'; ...     % tilde
        '`'     , '_bt_'; ...     % backtick
        '='     , '_eq_'; ...     % equals
        '+'     , '_pl_'; ...     % plus
        ','     , '_cm_'  ...     % comma
        };

    % Find JSON keys
    pattern = '"([^"]+)"\s*:'; % Match "keyName" followed by optional spaces and colon
    [keys, keyStarts, keyEnds] = regexp(rawText, pattern, 'tokens', 'start', 'end');

    % Flatten keys
    keys = keys(:);
    keyStarts = keyStarts(:);
    keyEnds = keyEnds(:);

    % Build modified JSON in one pass
    segments = cell(1, numel(keys)+1);
    prevEnd = 0;

    for k = 1:numel(keys)
        
        segments{k} = rawText(prevEnd+1 : keyStarts(k)-1);  % Add text before current key

        % Extract key text
        oldKey = keys{k};
        if iscell(oldKey)
            oldKey = oldKey{1};
        end
        newKey = oldKey;

        % Apply replacements
        for r = 1:size(replacements,1)
            newKey = strrep(newKey, replacements{r,1}, replacements{r,2});
        end
        
        segments{k} = [segments{k}, '"', newKey, '"'];  % Put back quotes
        prevEnd = keyEnds(k)-1;
    end

    segments{end} = rawText(prevEnd+1:end);  % Add remaining text after last key
    modifiedText = [segments{:}];  % Join all segments

    % Save modified JSON
    fid = fopen(outputFile,'w','n','UTF-8');
    if fid == -1
        error('Could not create output file: %s', outputFile);
    end
    fwrite(fid, modifiedText, 'char');
    fclose(fid);

    % Read new JSON file
    str = fileread('temp.json');
    obj = jsondecode(str);

    % Delete new JSON file (cleanup)
    if isfile(outputFile)
        delete(outputFile);
    end
end