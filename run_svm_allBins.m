function validationAccuracy_allBins = run_svm_allBins(pseudo_decode, trialSplit_trainFraction)

    % This function runs linear SVM decoding for two trial types
    %
    % INPUTS:
    %       pseudo_decode: neuron firing rates across across trials and time bins
    %                      (matrix of timeBins x trials x neurons)
    %                      top half of the trials are trial type 1, and 
    %                      bottom half of the trials are trial type 2
    %       trialSplit_trainFraction: fraction of input trials to use for training;
    %                       the rest will be used for testing
    %
    % OUTPUTS:
    %       validationAccuracy_allBins: validation accuracy for each time bin
    %                                   (vector of 1 x timeBins)
    %
    % Frances Xia
    % 2024

    % loop through time bins
    validationAccuracy_allBins = zeros(1,size(pseudo_decode,1)); 
    for tb = 1:size(pseudo_decode,1)

        % label trial types as 1 or 2
        % 1: data_trType1
        % 2: data_trType2
        a = repmat(1, 1, size(pseudo_decode,2)/2);
        b = repmat(2, 1, size(pseudo_decode,2)/2);
        c = [a, b]; % trial labels
        
        % data input for SVM
        %   trials x neurons
        %   trial label in last column
        pseudo_svm = cat(2, squeeze(pseudo_decode(tb,:,:)), c');

        %% train linear SVM
        % split training and testing dataset  
        [trainDataX, trainDataY, trialID_test] = split_train_test(pseudo_svm, trialSplit_trainFraction);

        % test dataset
        testDataX = pseudo_svm(trialID_test, 1:end-1);
        testDataY = pseudo_svm(trialID_test, end);

        % train SVM
        [~, predictFcn] = decode_trType_SVM(trainDataX, trainDataY);

        % test SVM
        testVal = predictFcn(testDataX);
        
        % calculate decoding accuracy
        confmat = confusionmat(testDataY,testVal);
        accuracy = (confmat(2,2) + confmat(1,1)) / sum(sum(confmat));

        % collect decoding accuracy across all time bins (timeBin x 1)
        validationAccuracy_allBins(tb) = accuracy;
    end