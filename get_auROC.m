function [auROC_norm, auROC_raw] = get_auROC(P1,P2)

    % Computes the area under the receiver operating characteristic (ROC) curve (auROC).
    %
    % INPUTS:
    %   P1: Firing rates of a single neuron across trials in condition P1 (vector)
    %   P2: Firing rates of a single neuron across trials in condition P2 (vector)
    %
    % OUTPUTS:
    %   auROC_norm: auROC normalized to the range [0.5, 1].
    %                - auROC = 0.5 indicates no selectivity.
    %                - auROC = 1 indicates high selectivity.
    %   auROC_raw: Raw auROC value without normalization
    %
    % Valeria Fascianelli & Frances Xia
    % 2024
    
    % sort firing rates for both conditions
    P1 = sort(P1);
    P2 = sort(P2);
    
    rc1 = [];       
    rc2 = [];        
    criterions = []; % Criterion levels for ROC
    
    % loop through criterion levels from -1 to 1 spike/s greater than max firing rate
    critx = 1;	
    for k =-1:critx:(round(max(max(P1),max(P2))) + 2*critx)
        % calculate proportion of trials exceeding the criterion for both conditions
	    P1dum = (length(find(P1 > k)) / length(P1));
        P2dum = (length(find(P2 > k)) / length(P2)); 
    
        rc1 = [rc1 P1dum];
        rc2 = [rc2 P2dum];
        criterions = [criterions k];    
    end
    
    % calculate auROC
    a = 0;
    da = 0;
    for y = 1:(length(rc2) - 1)
        if rc2(y + 1) ~= rc2(y)
            da = abs((rc2(y + 1)-rc2(y)))*(abs((rc1(y)-rc1(y + 1)))/2 + min(rc1(y),rc1(y + 1)));
            a = a + da;
        end
    end
    auROC_raw = a;
    
    % normalize auROC to the range [0.5, 1]
    auROC_norm = auROC_raw;
    auROC_norm(find(auROC_norm < 0.5)) = 1 - auROC_norm(find(auROC_norm < 0.5));



