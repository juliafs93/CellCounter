clear all
[Path] = uigetdir();
%
    Dummy = dir([Path,'/*.lsm']); Files = {Dummy.name};
    Dummy2 = dir([Path,'/*.oib']); Files2 = {Dummy2.name};
    FolderName = strsplit(Path,'/'); FolderName = FolderName{end};
    Files = [Files,Files2]
    %%
    
    try
        ParametersT = readtable([Path,'/',FolderName,'_parameters.txt'],'Delimiter','\t');
        ValuesT = readtable([Path,'/',FolderName,'_values.txt'], 'Delimiter','\t')
    catch
        ValuesT = table(); ParametersT = table();
    end

for i = 1:length(Files)
    reader = bfGetReader([Path,'/',Files{i}]);
    [~,Width,Height, Channels, Slices, Frames, ~, XRes, YRes, ZRes,Zoom,~,~] = readMetadataBFOME(reader);
    VoxelSize = XRes*YRes*ZRes; %size in um^3
    Stack = bfopen([Path,'/',Files{i}]);
    Ch1 = Stack{1}(1:Channels:Channels*Slices); Ch1 = double(cat(3,Ch1{:}));
    Ch2 = Stack{1}(2:Channels:Channels*Slices); Ch2 = double(cat(3,Ch2{:}));
    try
        Ch3 = Stack{1}(3:Channels:Channels*Slices); Ch3 = double(cat(3,Ch3{:}));
        Im = cat(4,Ch1,Ch2,Ch3);
    % Dimension order is XYZC !!
    catch
        Ch3 = zeros(size(Ch2));
        Im = cat(4,Ch1,Ch2,Ch3);
    end
    try
        Parameters = ParametersT(i,:);
        
    catch
        %Parameters = table('VariableNames',{'minZ','maxZ','ThresLevel','WatershedParameter','Remove','ST','FT'});
        Parameters = table();
        
    end
    % default parameters to override
    %Parameters.minZ = 1;
    %Parameters.maxZ = Slices;
    %Parameters.ThresLevel = 0.2;
    %Parameters.WatershedParameter = 0.5;
    %Parameters.Remove = 50;
    %Parameters.ST = 4.5;
    %Parameters.FT = 1000;
    
   [RProps, Parameters] = CellCounterCC(Im, Channels, Slices,VoxelSize,Parameters);
   writetable(RProps,[Path,'/',Files{i},'_RProps.txt'], 'Delimiter','\t')
    Values = table();
    Values.File = {Files{i}};
    Values.SmallHigh = length(find(log(RProps.Area) < Parameters.ST & RProps.MeanIntensity > Parameters.FT)) ;
    Values.SmallLow = length(find(log(RProps.Area) < Parameters.ST & RProps.MeanIntensity < Parameters.FT)) ;
    Values.BigHigh = length(find(log(RProps.Area) > Parameters.ST & RProps.MeanIntensity > Parameters.FT)) ;
    Values.BigLow = length(find(log(RProps.Area) > Parameters.ST & RProps.MeanIntensity < Parameters.FT)) ;
    Parameters.File = {Files{i}};
    ValuesT(i,:) = Values;
    ParametersT(i,:) = Parameters;
    
end
writetable(ValuesT,[Path,'/',FolderName,'_values.txt'], 'Delimiter','\t')
writetable(ParametersT,[Path,'/',FolderName,'_parameters.txt'],'Delimiter','\t')
