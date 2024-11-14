function [trainDataX, trainDataY, test_trialID] = split_train_test(trainData, train_fraction)

    % This function splits the input data into a training set and a testing set
    %       according to the specified fraction.
    %
    % INPUTS:
    %       trainData: trial x neurons, with last column = trial type label
    %                       1 or 2
    %                  assuming equal # of trials for trial type 1 and 2
    %       train_fraction: fraction of input trials to use for training;
    %                       the rest will be used for testing
    %
    % OUTPUTS:
    %       trainDataX: trial x neurons
    %       trainDataY: label for above trainDataX
    %       test_trialID: trial ID referencing original trainData that will
    %               be used for testing; non-overlapping from training set
    %
    % Frances Xia
    % 2024

    % Determine the number of trials for 1 of the 2 trial types, assuming
    %       equal # of trials for each of the 2 trial types
    trN_perTrType = size(trainData((trainData(:, end) == 1), :), 1);
    
    % Calculate the number of trials for training based on the specified fraction
    train_trialN_perTrType = floor(trN_perTrType * train_fraction);
    test_trialN_perTrType = trN_perTrType - train_trialN_perTrType;
    
    % Split the data into trial types
    trainData_type1 = trainData((trainData(:, end) == 1), :); % trial type 1 data
    trainData_type2 = trainData((trainData(:, end) == 2), :); % trial type 2 data
    trainData_type2_startID = find((trainData(:, end) == 2),1);
    trainData_type2_startID = trainData_type2_startID(1);

    % Randomly select trials for training for each trial type
    trainID_type1 = randperm(size(trainData_type1, 1), train_trialN_perTrType);
    trainID_type2 = randperm(size(trainData_type2, 1), train_trialN_perTrType);
    
    % Select the training and testing data based on the trial IDs
    train_trialID = cat(2, trainID_type1, trainID_type2 + trainData_type2_startID - 1);
    trainDataX = trainData(train_trialID, 1:end-1);
    trainDataY = trainData(train_trialID, end);
    
    test_trialID = setdiff(1:trN_perTrType*2, train_trialID);

end
