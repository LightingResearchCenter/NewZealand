function createDaysigrams
% CREATEDAYSIGRAMS

%% Prepare workspace
close all;
clc;

%% Construct directory paths
kdis01CodeDir   = pwd;
[nzCodeDir,~,~] = fileparts(kdis01CodeDir);
[githubDir,~,~] = fileparts(nzCodeDir);
circadianDir    = fullfile(githubDir,'circadian');
dataDir         = fullfile(kdis01CodeDir,'data');
logsDir         = fullfile(kdis01CodeDir,'logs');
plotsDir        = fullfile(kdis01CodeDir,'plots');

%% Construct file paths
preSurgery  = fullfile(dataDir,'KDIS01PreSurgery.mat');
postSurgery = fullfile(dataDir,'KDIS01PostSurgery.mat');
bedLog      = fullfile(logsDir,'KDIS01BedLog.mat');

%% Enable dependencies
addpath(circadianDir);

%% Prepare bed log
tempLog  = load(bedLog);
bedTime  = datenum(tempLog.bedTime);
riseTime = datenum(tempLog.riseTime);

%% Pre Surgery
daysigramPrep(preSurgery,'KDIS 01 - Pre Surgery','kdis01pre');

%% Post Surgery
daysigramPrep(postSurgery,'KDIS 01 - Post Surgery','kdis01post');

%% Nested functions
    function daysigramPrep(inputPath,sheetTitle,fileID)
        % Load the data
        tempData = load(inputPath);
        
        % Prepare variables
        timeArray       = datenum(tempData.DateTime);
        masks           = log2masks(timeArray);
        activityArray   = tempData.Activity;
        lightArray      = tempData.CS;
        
        
        % Create Daysigram
        reports.daysigram.daysigram(sheetTitle,timeArray,masks,...
            activityArray,lightArray,'cs',[0 1],9,plotsDir,fileID);
        
    end

    function masks = log2masks(timeArray)
        observationArray = true(size(timeArray));
        complianceArray  = true(size(timeArray));
        
        bedArray = false(size(timeArray)); % Create initial array
        for iBed = 1:numel(bedTime)
            tempBed  = timeArray >= bedTime(iBed) & ...
                       timeArray <= riseTime(iBed);
            bedArray = bedArray | tempBed;
        end
        
        masks = eventmasks('observation',observationArray,...
            'compliance',complianceArray,'bed',bedArray);
    end

end