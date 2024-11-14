%% Single neuron selectivity
% This script calculates the area under the receiver operating characteristic (auROC) 
%       for individual neurons across specified time bins and trials for two trial types.
%
% Frances Xia
% 2024

%% auROC calculation
% Inputs: firing rate of single neurons across time bins and trials for
%               each trial type
%         - data_trType1: {neuron}(timeBins x trials)
%         - data_trType2: {neuron}(timeBins x trials)
%
% Outputs: 
%         - auROC: auROC values (# neurons x timeBins)
%         - auROC_shuff: auROC of shuffles (# of shuffles x neurons x timeBins)

auROC = [];       % initialize auROC array (# neurons x timeBins)
auROC_shuff = []; % initialize shuffled auROC array (# neurons x # shuffles x timeBins)
% iterate through each neuron
for nn = 1:length(data_trType1)

    data_trType1_neuron = data_trType1{nn}; % timeBins x trials
    data_trType2_neuron = data_trType2{nn};

    auROC_timeBin = [];          % initialize auROC for each time bin (1 x timeBins)
    auROC_timeBin_shuff = [];    % initialize shuffled auROC for each time bin (1 x # of shuffles x timeBins)

    % iterate through each time bin
    for tb = 1:size(data_trType1_neuron, 1)
        data_trType1_timeBin = data_trType1_neuron(tb,:); % firing rate for trType1 in this time bin
        data_trType2_timeBin = data_trType2_neuron(tb,:); % firing rate for trType2 in this time bin

        % calculate auROC
        auROC_timeBin(:,tb) = get_auROC(data_trType1_timeBin, data_trType2_timeBin);

        % calculate chance auROC by shuffling data labels
        randShuff = 10; % # of times to shuffle
        auROC_perTimeBin_shuffle = [];
        parfor ii = 1:randShuff
            % combine trType1 and trType2 data for shuffling
            dataShuff = cat(2, data_trType2_timeBin, data_trType1_timeBin);
            shuffID = randperm(size(dataShuff,2));
            shuffID_trType2 = shuffID(1:size(data_trType2_timeBin,2));
            shuffID_trType1 = setdiff(shuffID, shuffID_trType2, 'stable');

            % create shuffled dataset
            data_trType2_shuff = dataShuff(:,shuffID_trType2);
            data_trType1_shuff = dataShuff(:,shuffID_trType1);

            % calculate shuffled auROC
            auROC_perTimeBin_shuffle(ii) = get_auROC(data_trType1_shuff, data_trType2_shuff);
        end

        auROC_timeBin_shuff(:,:,tb) = auROC_perTimeBin_shuffle; % store auROC of individual shuffles
    end

    auROC = cat(1, auROC, auROC_timeBin);  
    auROC_shuff = cat(1, auROC_shuff, auROC_timeBin_shuff); 
end

%% Fraction of selective neurons for specified time bin
% Selective neuron: a neuron is considered significantly selective if 
%                   its mean auROC across time bins of interest is outisde 
%                   of its chance distribution (mean shuffle +/- 2 x STD of shuffle)

% define time bin for analysis
timeBins_analysis = timeBins_1:timeBins_2; % indices of timeBins of interest
shuffTh = 2; % standard deviation threshold for significance (ie/ 2 x STD)

% calculate mean auROC for each neuron within time bin of interest
auROC_mean = mean(auROC(:, timeBins_analysis),2);

% calculate chance distribution for each neuron
auROC_shuff_mean = squeeze(mean(auROC_shuff,2)); % mean shuffle; output: neuron x timebins
auROC_shuff_std = squeeze(std(auROC_shuff, [], 2) * shuffTh); % std of shuffles; output: neuron x timeBins
auROC_shuff_range = [mean(auROC_shuff_mean,2) - mean(auROC_shuff_std,2), mean(auROC_shuff_mean,2) + mean(auROC_shuff_std,2)]; 

% auROC of selective neurons
auROC_selective = find(auROC_mean <= auROC_shuff_range(:, 1) | auROC_mean >= auROC_shuff_range(:, 2));

% proportion of selective neurons
auROC_selective_frac = length(auROC_selective)/length(auROC_mean);

% # of non-selective neurons
auROC_non_selective_num = length(auROC_mean) - length(auROC_selective);


