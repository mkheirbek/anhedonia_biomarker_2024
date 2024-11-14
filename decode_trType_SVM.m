function [weight,  predictFcn] = decode_trType_SVM(trainDataX, trainDataY)
    % This function performs decoding of trial types using linear support vector
    %   machine (SVM) classifier
    % 
    % INPUTS:
    %   trainDataX: firing rate in trials x neurons
    %   trainDataY: classification (for each of the trial type)
    %
    % OUTPUTS:
    %  weight: weight of each neuron in SVM (neuron x 1)
    %  predictFcn: function to use trained model to predict classifications on test data
    %              e.g. testDataY = predictFcn(testDataX) 
    %
    % Frances Xia
    % 2024
      
    % SVM
    classificationSVM = fitcsvm(trainDataX, ...
                                trainDataY, ...
                                'KernelFunction', 'linear');
           
    % weights of neurons in SVM
    weight = classificationSVM.Beta;
    
    % outputs a predictor function that can be used to test other data
    predictorExtractionFcn = @(x) array2table(x);
    svmPredictFcn = @(x) predict(classificationSVM, x);
    predictFcn = @(x) svmPredictFcn(predictorExtractionFcn(x));


