function [inp] = ReadInput(inputdir)

% a fun function
%
% :param U0: the first input
% :param freq: the second input
% :param freq: the third input
% :returns: ``[U]`` some outputs   

     global flags;
    inp.inputdir = inputdir;
    
%-------------------------------------------------------------------------------        
% read species list and set species names and idexes
%-------------------------------------------------------------------------------    
    
    file = [inputdir,'speclist.cfg'];
    [fid,msg] = fopen(file);
    
    if fid < 0
        error(['Error opening ',file,': ',msg])
    end

    Nspec = 0;
    while ~feof(fid)
    
        line = fgets(fid);
        line = strtrim(line);
%        disp(line)
        
        if (length(strfind(line,'#'))==0 || strfind(line,'#') > 1 ) ...
            && length(line) > 0  
            
            if strfind(line,'#') > 0            
                line = line(1:strfind(line,'#')-1);
            end            
        
            if strfind(line,'file:') > 0
                Nspec = Nspec + 1;
                [specname,tmp,specfile] = strread(line,'%s %s %s');
                
                tmp = specfile{1};
                specfile = cellstr(tmp(1:findstr(tmp,'.cfg')-1));
                                
                inp.specnames(Nspec) = specname;
                inp.specfiles(Nspec) = specfile;

            elseif strfind(line,'=') > 0          
                eval([line,';']);            
            end            
        
        end      
          
    end
    
    inp.Nspec = Nspec;
    inp.n0Ind = n0Ind;
    inp.nInd = nInd;
    inp.iInd = iInd;
    inp.eInd = eInd;
    inp.eEnergyEqn= ['eq',num2str(inp.Nspec+1)];
    fclose(fid);

%-------------------------------------------------------------------------------        
% read properties of species
%-------------------------------------------------------------------------------    
      
    for i=1:inp.Nspec
        
        file = [inputdir,'/species/',inp.specfiles{i},'.cfg'];
        [fid,msg] = fopen(file);
    
        if fid < 0
            error(['Error opening ',file,': ',msg]);
        end

        while ~feof(fid)
        
            line = fgets(fid);
            line = strtrim(line);
%            disp(line)
            
            if (length(strfind(line,'#'))==0 || strfind(line,'#') > 1 ) ...
                && length(line) > 0                      
            
                if strfind(line,'=') > 0
                    if strfind(line,'#') > 0
                        line = line(1:strfind(line,'#')-1);
                    end
                    eval([line,';']);                   
                end                              
            
            end      
              
        end
            
        inp.Z(i) = Z;
        inp.Mass(i) = Mass;
        
        fclose(fid);
    end
    
%-------------------------------------------------------------------------------        
% read reaction scheme
%-------------------------------------------------------------------------------    
       
    file = [inputdir,'reacscheme.cfg'];
    [fid,msg] = fopen(file);
    
    if fid < 0
        error(['Error opening ',file,': ',msg]);
    end

    Nreac = 0;
    while ~feof(fid)
    
        line = fgets(fid);
        line = strtrim(line); 
%        disp(line)      
        if (length(strfind(line,'#'))==0 || min(strfind(line,'#')) > 1 ) ...
            && length(line) > 0            
        
            if length(strfind(line,'->'))==0 || ...
                length(strfind(line,'Type:'))==0 || ...
                    length(strfind(line,'Uin:'))==0 || ...
                        length(strfind(line,'Qfile:'))==0 || ...
                            length(strfind(line,'kfile:'))==0               
                            
                error(['Invalid line in ',file,': ',line]);
        
            end   
            
            Nreac = Nreac + 1;
            
            pos1 = 1;
            pos2 = strfind(line,'->');
            pos3 = strfind(line,'Type:');
            
            % set gain, loss and power matrices
            
            for i=1:inp.Nspec      
            
                Gain(Nreac,i) = max(0, ...
                    length(strfind(line(pos2:pos3),[' ',inp.specnames{i},' '])) - ...
                    length(strfind(line(pos1:pos2),[' ',inp.specnames{i},' '])));
                    
                Loss(Nreac,i) = max(0, ...
                    length(strfind(line(pos1:pos2),[' ',inp.specnames{i},' '])) - ...
                    length(strfind(line(pos2:pos3),[' ',inp.specnames{i},' '])));
                    
                Power(i,Nreac) = length(strfind(line(pos1:pos2),[' ',inp.specnames{i},' ']));
                
            end
            
            % set Uin and rate coefficient files
            
            [tmp,type,tmp,Uin,tmp,Qfile,tmp,kfile] = ...
                strread(line(pos3:end), ...
                    '%[Type:] %s %[Uin:] %f %[Qfile:] %s %[kfile:] %s');
                  
            inp.reacnames(Nreac) = cellstr(strtrim(line(1:pos3-1)));
            inp.reacfiles(Nreac) = kfile;     
            inp.Uin(Nreac) = Uin;        
 
        end      
        
    end 
    
    inp.Nreac = Nreac;
    
    fclose(fid);  
    
    inp.ReacGain = Gain;
    inp.ReacLoss = Loss;
    inp.ReacPower = Power;

%-------------------------------------------------------------------------------    
% read rate coefficients
%-------------------------------------------------------------------------------       

    for i=1:inp.Nreac
        
        file = fullfile(inputdir,'ratecoefficients',inp.reacfiles{i});
        [dep,data] = ReadDataFile(file);        
        eval(['inp.coefficients.R',num2str(i),'.dep = dep{1};']);
        eval(['inp.coefficients.R',num2str(i),'.data = data;']);        
        
    end

%-------------------------------------------------------------------------------    
% read transport coefficients
%-------------------------------------------------------------------------------    
    
    % particles
    for i=1:inp.Nspec
        
        % diffusion coefficient        
        file = [inputdir,'/transportcoefficients/',inp.specfiles{i},'_ND.dat'];
        [dep,data] = ReadDataFile(file);  
        eval(['inp.coefficients.',inp.specfiles{i},'_ND.dep = dep{1};']);                  
        eval(['inp.coefficients.',inp.specfiles{i},'_ND.data = data;']);  
        
        % mobility 
        if inp.Z(i) ~= 0    
            file = [inputdir,'/transportcoefficients/',inp.specfiles{i},'_Nb.dat'];
            [dep,data] = ReadDataFile(file);  
            eval(['inp.coefficients.',inp.specfiles{i},'_Nb.dep = dep{1};']);                  
            eval(['inp.coefficients.',inp.specfiles{i},'_Nb.data = data;']);   
        end         
    
    end   
    
    i = inp.eInd;
    % electron energy diffusion coefficient            
    file = [inputdir,'/transportcoefficients/',inp.specfiles{i},'E_ND.dat'];
    [dep,data] = ReadDataFile(file);  
    eval(['inp.coefficients.',inp.specfiles{i},'E_ND.dep = dep{1};']);                  
    eval(['inp.coefficients.',inp.specfiles{i},'E_ND.data = data;']);  
    
    % electron energy mobility   
    file = [inputdir,'/transportcoefficients/',inp.specfiles{i},'E_Nb.dat'];
    [dep,data] = ReadDataFile(file);  
    eval(['inp.coefficients.',inp.specfiles{i},'E_Nb.dep = dep{1};']);                  
    eval(['inp.coefficients.',inp.specfiles{i},'E_Nb.data = data;']);     
    
    % electron energy diffusion coefficient devided by mean energy       
    file = [inputdir,'/transportcoefficients/',inp.specfiles{i},'E_NDdUm.dat'];
    [dep,data] = ReadDataFile(file);  
    eval(['inp.coefficients.',inp.specfiles{i},'E_NDdUm.dep = dep{1};']);                  
    eval(['inp.coefficients.',inp.specfiles{i},'E_NDdUm.data = data;']);  
    
    % electron energy mobility devided by mean energy 
    file = [inputdir,'/transportcoefficients/',inp.specfiles{i},'E_NbdUm.dat'];
    [dep,data] = ReadDataFile(file);  
    eval(['inp.coefficients.',inp.specfiles{i},'E_NbdUm.dep = dep{1};']);                  
    eval(['inp.coefficients.',inp.specfiles{i},'E_NbdUm.data = data;']);
    
    % Transport coefficients for DDAn
    i = inp.eInd;
    directory = [inputdir,'/transportcoefficients/'];
    if strcmp(flags.enFlux,'DDAn')
        file = [directory,inp.specfiles{i},'_nu.dat'];
        [dep,data] = ReadDataFile(file);  
        eval(['inp.coefficients.',inp.specfiles{i},'_nu.dep = dep{1};']);                  
        eval(['inp.coefficients.',inp.specfiles{i},'_nu.data = data;']);
        
        file = [directory,inp.specfiles{i},'E_nu.dat'];
        [dep,data] = ReadDataFile(file);  
        eval(['inp.coefficients.',inp.specfiles{i},'E_nu.dep = dep{1};']);                  
        eval(['inp.coefficients.',inp.specfiles{i},'E_nu.data = data;']);    
    
        file = [directory,inp.specfiles{i},'_xi0.dat'];
        [dep,data] = ReadDataFile(file);  
        eval(['inp.coefficients.',inp.specfiles{i},'_xi0.dep = dep{1};']);                  
        eval(['inp.coefficients.',inp.specfiles{i},'_xi0.data = data;']);
        
        file = [directory,inp.specfiles{i},'_xi2.dat'];
        [dep,data] = ReadDataFile(file);  
        eval(['inp.coefficients.',inp.specfiles{i},'_xi2.dep = dep{1};']);                  
        eval(['inp.coefficients.',inp.specfiles{i},'_xi2.data = data;']);
        
        file = [directory,inp.specfiles{i},'E_xi0.dat'];
        [dep,data] = ReadDataFile(file);  
        eval(['inp.coefficients.',inp.specfiles{i},'E_xi0.dep = dep{1};']);                  
        eval(['inp.coefficients.',inp.specfiles{i},'E_xi0.data = data;']);
        
        file = [directory,inp.specfiles{i},'E_xi2.dat'];
        [dep,data] = ReadDataFile(file);  
        eval(['inp.coefficients.',inp.specfiles{i},'E_xi2.dep = dep{1};']);                  
        eval(['inp.coefficients.',inp.specfiles{i},'E_xi2.data = data;']);        
    end
end

%-------------------------------------------------------------------------------    
function [dep,data] = ReadDataFile(file)
%-------------------------------------------------------------------------------        
% a fun function
%
% :param U0: the first input
% :param freq: the second input
% :param freq: the third input
% :returns: ``[U]`` some outputs   
    [fid,msg] = fopen(file);    
    if fid < 0
        error(['Error opening ',file,': ',msg]);
    end
    
    % read dependence        
    line = fgets(fid);     
    line = strtrim(line);        
    while line(1)=='#'       
        line = fgets(fid);                                        
        if length(strfind(line,'Dependence:')) > 0                
            [tmp,dep] = strread(line(strfind(line,'Dependence:'):end), ...
                '%[Dependence:] %s ');
            break;                
        end            
    end        
    fclose(fid);  
    
    
    % read data
    [fid,msg] = fopen(file);
    line = fgets(fid);     
    line = strtrim(line);    
         
    switch char(dep)  
        case {'fun:Tgas','fun:Te,Tgas','fun:Te'}
            %tmp = char(dep);
            %dep = cellstr(tmp(strfind(tmp,':')+1:end));                
            while ~feof(fid)    
                line = fgets(fid); line = strtrim(line);                 
                if length(strfind(line,'#'))==0 && length(line) > 0                             
                    y = strread(line,'%s');                      
                    data = y;             
                    break;
                end                    
            end                  
        case {'Umean','E/N','ElecDist','Tgas','Te'}            
            j = 0;
            while ~feof(fid)    
                line = fgets(fid); line = strtrim(line);                 
                if length(strfind(line,'#'))==0 && length(line) > 0                             
                    j = j+1;                                            
                    [x,y] = strread(line,'%f %f');                                                
                    data(j,1) = x;
                    data(j,2) = y;   
                end                 
            end     

            
        case 'const'
            while ~feof(fid)    
                line = fgets(fid); line = strtrim(line);                 
                if length(strfind(line,'#'))==0 && length(line) > 0                             
                    y = strread(line,'%f');                        
                    data = y;                           
                    break;
                end                    
            end   
        case 'ESR'
            data = 0;                                            
        otherwise                
            error(['Unallowed data dependence in file ',file]);                
    end  
    fclose(fid); 
    
          
    
end

