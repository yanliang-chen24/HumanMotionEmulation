%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% generate_all_results - The code is to generate the tables for the
% evaluation results, Table 2 to 7 in the main manuscript and Table 1 to 3
% in the Supplementary Material
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
addpath('./03_metrics/')

numMeth = 7;
numMetric = 11;
numRun = 10;

tables = cell(1, numMetric);
for m = 1:numMetric
    tables{m} = zeros(6, numMeth); 
end

ref_metric = zeros(6, numMetric);
Methods = {'ISTVF', 'SIEM','PWI','VAR','GP','LSTM','GCN_Trans'};
%% === Aggregate Results of Worker Data ===  
for m = 1:numMeth
    meth = Methods{m};
    if m <= 4
        path = strcat('./06_results/WorkerData/', meth,'/');        
        runData = zeros(numRun, 5, numMetric);
        for r = 1:numRun
            fileName = fullfile(path, sprintf('run_%d.mat', r));
            data = load(fileName);
            runData(r, :, :) = data.Result.metrics;
        end
        % Compute mean across the 10 runs
        finalMeans = squeeze(mean(runData, 1));
        finalStd = squeeze(std(runData, 1));
    else 
        path = strcat('./06_results/WorkerData/Other/');
        fileName = strcat(path, meth, '_Worker_Results.mat');
        data = load(fileName);
        finalMeans = zeros(5, numMetric);        
        for s = 1:5
            subClass = sprintf('Dataset%d', s);
            finalMeans(s, :) = data.All_Results.(subClass).mean_score;
            finalStd(s, :) = std(data.All_Results.(subClass).raw_scores);
        end
    end
    %% Map means to the 11 Tables   
    for i = 1:numMetric
        tables_mean{i}(1:5, m) = finalMeans(:, i);
        tables_std{i}(1:5, m) = finalStd(:, i);
    end
end

%%%% --- Compute Reference Scores using Original Data ---
for s = 1:5
    path = strcat('./01_data/');
    fileName = strcat(path, 'RWP_',num2str(s), '_Outcome_300.mat');
    load(fileName, 'aligned', 'tree');
    load('./03_metrics/posture_modes_12.mat','posturemode')
    load('./03_metrics/Estimated_ROW.mat', 'KernelVMF')
    ref_metric(s,:) = evaluation(aligned, aligned, tree, KernelVMF, posturemode);
end

%% === Aggregate Results of Exercise Data ===
for m = 1:numMeth
    meth = Methods{m};
    if m <= 4
        path = strcat('./06_results/ExerciseData/', meth,'/');        
        runData = zeros(numRun, 1, numMetric);
        for r = 1:numRun
            fileName = fullfile(path, sprintf('run_%d.mat', r));
            data = load(fileName);
            runData(r, :, :) = data.Result.metrics;
        end
        % Compute mean across the 10 runs
        finalMeans = squeeze(mean(runData, 1))';
        finalStd = squeeze(std(runData, 1))';
    else
        path = strcat('./06_results/ExerciseData/Other/');
        fileName = strcat(path, meth, '_Exercise_Results.mat');
        data = load(fileName);     
        finalMeans = data.All_Results.mean_score;
        finalStd = std(data.All_Results.raw_scores);
    end
    
    %% Map means to the 11 Tables   
    for i = 1:numMetric
        tables_mean{i}(6, m) = finalMeans(:, i);
        tables_std{i}(6, m) = finalStd(:, i);
    end
end

%%%% --- Compute Reference Scores using Original Data ---
path = strcat('./01_data/');
fileName = strcat(path, 'MotionNew_Outcome_800.mat');
load(fileName, 'X', 'tree');
load('./03_metrics/posture_modes_new_7.mat','posturemode')
load('./03_metrics/Estimated_ROW_New.mat', 'KernelVMF')
ref_metric(6,:) = evaluation(X, X, tree, KernelVMF, posturemode);

%% === Generate Tables in the Manuscirpt===
metricNames = {'Energy Distance', 'Cross-Sectional Variance', 'Jerk', 'Acceleration', 'Posture Validity', 'Posture Integrity', 'Quantization Variability', 'KNN Classification', 'ANND', 'ANND of Max Posture Distance', 'Roughness'};
rowNames = {'Worker Motion 1', 'Worker Motion 2', 'Worker Motion 3', 'Worker Motion 4', 'Worker Motion 5', 'Exercise Motion'};
columnNames = {'ISTVF/Gaussian', 'SIEM/Gaussian', 'PWI','VAR','GP','LSTM','GCN_Trans'};

for i = 1:numMetric
    t_mean = array2table(tables_mean{i},'RowNames', rowNames,'VariableNames', columnNames); 
    t_mean.Properties.Description = sprintf('Mean Results for %s', metricNames{i});
    %% Table of Mean Results (Table 2-6 and Table S1-S11)
    T_mean{i} = t_mean;
    t_std = array2table(tables_std{i},'RowNames', rowNames,'VariableNames', columnNames);
    t_std.Properties.Description = sprintf('Std Dev Results for %s', metricNames{i});
    %% Table of Standard Deviation (S1-S11)
    T_std{i} = t_std;
end

%% === Generate Ranking Result (Table S12) ===
%%%% --- Aggragate the Ranking ---
% Selected Metrics
I = [1,3,5,7];
all_ranks = zeros(6, numMeth, 4);

for i = 1:4
    current_table = tables_mean{I(i)};    
    for d = 1:6
        % Sort the results to obtain ranking for each metric
        scores = abs(current_table(d, :)- ref_metric(d, I(i)));
        ranks = tiedrank(scores); 
        all_ranks(d, :, i) = ranks;
    end
end
% Compute average rank for each dataset
avg_rank = mean(all_ranks, 3);

% Compute the global average rank for each method
R_bar = mean(avg_rank, 1);

%%%% --- Friedman's Test on All Individual Ranks ---
N_effective = 6 * 4;                            % Total number of ranks (6 datasets X 4 metrics)
expected_rank = (numMeth + 1) / 2;              % Expected Rank
sum_squared_diff = sum((R_bar - expected_rank).^2);   
Q = (12 * N_effective / (numMeth * (numMeth + 1))) * sum_squared_diff;      % Test Statistics Q

p_friedman = 1 - chi2cdf(Q, numMeth - 1);       % p-value

%%%% --- Nemenyi Test ---
% Significant Level
alpha = 0.05;      
% Compute the Nemenyi Critical Value (q_alpha)
studentizedCDF = @(q) numMeth * integral(@(x) ...
        (normcdf(x) - normcdf(x - q)).^(numMeth - 1) .* normpdf(x), ...
        -Inf, Inf, 'ArrayValued', true) - (1 - alpha);
q_studentized = fzero(studentizedCDF, 4.0);
q_alpha = q_studentized / sqrt(2);
% Compute the Critical Difference (CD)
CD = q_alpha * sqrt((numMeth * (numMeth + 1)) / (6 * N_effective));

%% === Aggregate Results of Classification ===
load ./06_results/Classification/5NN_SIEM.mat
dataMatrix = [mean_0, std_0; ...
              mean_aug, std_aug];

T_class = array2table(dataMatrix, ...
    'VariableNames', {'Mean', 'StdDev'}, ...
    'RowNames', {'No Aug', 'Augmentation'});

disp(T_class);