%% Population decoding
% This script performs linear SVM decoding of trial types using firing rates
%       with real data labels and shuffled data labels.
%
% Frances Xia
% 2024

%% Input data and variables
% subsampling procedures to take into account different number of neurons
%       and trials across conditions
%
% 1) subsample neurons
%       different groups may have different # of neurons, thus here, we subsample
%       the # of neurons to the minimum between all groups (neuron_min_threshold)
% 2) subsample trials
%       different neurons (from different mice) may have different number of trials 
%       thus here, we subsample the # of trials to the minimum between
%       neurons
%
% note on trial types:
%       for the sucrose preference task, there are 2 current reward choices (trial n): 
%       sucrose (s), water (w); to balance previous choice, we took into account
%       animal's past choice (trial n - 1), thus we start with 4 trial types: ss, sw, ws, ww
%
%       to decode current reward choice (s vs. w) while balancing the previous trial, 
%       we combine equal numbers of ss and ws trials to form sucrose trials, and equal
%       numbers of ww and sw trials to form water trials

% define the following variables:
data_allTrTypes; % data input for decoding: {trType}{neuron}(timeBin x trials)
neuron_subsample_threshold = 60; % # of neurons to subsample per iteration (determined by min across groups)
trTypeN = size(data_allTrTypes,1); % # of trial types
trial_subsample_threshold  = 8; % # of trials to subsample per iteration (determined by min across neurons/mice)

%% Decode trial types
% randomly select a subset of neurons up to neuron_min_threshold for
%       decoding
randNeurons = 10; % # of neuron subsamplings 
validationAccuracy_neurons = []; 
for nn = 1:randNeurons
    % randomly choose a subset of neurons
    randNeuron_ID = randperm(length(data_allTrTypes{1})); 
    randNeuron_ID = randNeuron_ID(1:neuron_subsample_threshold);

    % for each set of neurons, randomly choose some trials
    randTrials = 10; % # of trial subsamplings
    validationAccuracy_trials = []; 
    for rt = 1:randTrials
        % make pseudo population using the current subsample of neurons and
        %       trials; top half of trials are trial type 1, bottom half of
        %       trials are trial type 2
        pseudo_decode = []; 
        data_trType_combined = [];
        for i = 1:length(randNeuron_ID)
            
            dataSelect = []; % trial types x timeBins x trials
            for tt = 1:trTypeN
                % randomly choose a subset of trials
                trSelect = randperm(size(data_allTrTypes{tt}{randNeuron_ID(i)},2)); 
                trSelect = trSelect(1:trial_subsample_threshold);
                dataSelect(tt,:,:) = data_allTrTypes{tt}{randNeuron_ID(i)}(:,trSelect); 
            end
 
            % combine equal number of current and past choice trials for
            %           each reward type (see notes above)
            % data_trType1: timeBin x trials
            % data_trType2: timeBin x trials
            data_trType1 = cat(2, squeeze(dataSelect(1,:,:)), squeeze(dataSelect(4,:,:))); 
            data_trType2 = cat(2, squeeze(dataSelect(2,:,:)), squeeze(dataSelect(3,:,:))); 
            
            data_trType_combined = cat(2, data_trType1, data_trType2); % timeBin x trials
            pseudo_decode = cat(3, pseudo_decode, data_trType_combined); % timeBin x trials x neurons (equal # of trials for each trial type)
        end
        
        % run decoding across all time bins
        validationAccuracy_allBins = run_svm_allBins(pseudo_decode, 0.8); 
                           
       % collect accuracy for across trial subsamplings (timeBin x randTrial)
       validationAccuracy_trials(:,rt) = validationAccuracy_allBins;   
    end
    
    % collect accuracy for across neuron subsamplings (timeBin x randTrial x randNeuron)
    validationAccuracy_neurons(:,:,nn) = validationAccuracy_trials;
    
end

%% Decode trial types - shuffled distribution
% same structure as decoding using real labels, with the addition of
%           randomly shuffling trial labels

% randomly select a subset of neurons up to neuron_min_threshold for
%       decoding
randNeurons = 10;
validationAccuracy_neurons_shuff = []; 
for nn = 1:randNeurons
    % randomly choose a subset of neurons
    randNeuron_ID = randperm(length(data_allTrTypes{1})); 
    randNeuron_ID = randNeuron_ID(1:neuron_subsample_threshold);

    % for each set of neurons, randomly choose some trials
    randTrials = 10; % # of trial subsamplings
    validationAccuracy_trials_shuff = []; 
    for rt = 1:randTrials
        % make pseudo population using the current subsample of neurons and
        %       trials
        pseudo_decode = []; 
        data_trType_combined = [];
        for i = 1:length(randNeuron_ID)
            
            dataSelect = []; % trial types x timeBins x trials
            for tt = 1:trTypeN
                % randomly choose a subset of trials
                trSelect = randperm(size(data_allTrTypes{tt}{randNeuron_ID(i)},2)); 
                trSelect = trSelect(1:trial_subsample_threshold);
                dataSelect(tt,:,:) = data_allTrTypes{tt}{randNeuron_ID(i)}(:,trSelect); 
            end
 
            data_trType1 = cat(2, squeeze(dataSelect(1,:,:)), squeeze(dataSelect(4,:,:))); 
            data_trType2 = cat(2, squeeze(dataSelect(2,:,:)), squeeze(dataSelect(3,:,:))); 
            
            data_trType_combined = cat(2, data_trType1, data_trType2); % timeBin x trials
            pseudo_decode = cat(3, pseudo_decode, data_trType_combined); % timeBin x trials x neurons (equal # of trials for each trial type)
        end
        
        %% shuffle trial label
        randShuff = 10; % # of times to shuffle
        validationAccuracy_allShuff = [];

        for rr = 1:randShuff
        
            % run decoding across all time bins
            validationAccuracy_allBins_shuff = run_svm_allBins(pseudo_decode, 0.8);
            
            % collect decoding accuracy across all shuffles (timeBin x randShuff)
            validationAccuracy_allShuff(:,rr) = validationAccuracy_allBins_shuff; % timeBin x shuff
        end
       
       % collect accuracy for across trial subsamplings (timeBin x
       %        randShuff x randTrial)
       validationAccuracy_trials_shuff(:,:,rt) = validationAccuracy_allShuff;
      end
    
    % collect decoding accuracy across neuron subsamplings (timeBin x
    %       randShuff x randTrial x randNeuron)
    validationAccuracy_neurons_shuff(:,:,:,nn) = validationAccuracy_trials_shuff;
end



