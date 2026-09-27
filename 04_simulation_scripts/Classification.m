%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Classification - The code is to generate classification result for data
% augmentation experiment descriobed in Sec. 7.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clear

addpath('../02_functions/')
addpath('../03_metrics/')
num_runs = 30;           % Number of Independent Runs
rng(1234)               % Random Setting

%% === Load Worker Data ===
X1 = load('../01_data/RWP_1_Outcome_300.mat', 'aligned').aligned;
X2 = load('../01_data/RWP_2_Outcome_300.mat', 'aligned').aligned;
X3 = load('../01_data/RWP_3_Outcome_300.mat', 'aligned').aligned;
X4 = load('../01_data/RWP_4_Outcome_300.mat', 'aligned').aligned;
X5 = load('../01_data/RWP_5_Outcome_300.mat', 'aligned').aligned;

%% === Prepare Data ===
%%% --- Select subsequences ---
for n = 1:60
    X1n{n} = X3{n}(:,181:181+49,:);
    X2n{n} = X4{n}(:,241:241+49,:);
    X3n{n} = X5{n}(:,31:31+49,:);
end

%%% --- Prepare the lable ---
X = [X1n; X2n; X3n];
label = [ones(1,60); 2*ones(1,60); 3*ones(1,60)];
N = size(X,2);

%% === Classification ===
rng(1234) 
for n_run = 1:num_runs              % Loop over num_runs independent trials 
    
    %%% --- 1. Train/Test Split ---
    Ntrain = ceil(N/3);
    Ntest = N-Ntrain;
    Xtrain = {};
    Xtest = {};
    label_train = [];
    label_test = [];
    for c = 1:3
        I = randperm(N);
        inx_train = I(1:Ntrain);
        inx_test = I(Ntrain+1:N);    
        Xtrain = [Xtrain, X(c,inx_train)];
        label_train = [label_train, label(c,inx_train)];
        Xtest = [Xtest, X(c,inx_test)];
        label_test = [label_test, label(c,inx_test)];
    end
    
    %%% ---- 2. 5-NN Classification without Augmentation ---
    for i = 1:length(Xtest)
        di = [];
        for j = 1:length(Xtrain)
            di(j) = dist_seq_to_seq(Xtest{i}, Xtrain{j});
        end
        [dmin, ind] = mink(di, 5);
        label_est(i) = mode(label_train(ind));
    end

    acc(n_run) = sum(label_est == label_test)/length(Xtest);
    
    %%% ---- 3. Data Augmentation ---
    num_sim = 200;
    X_aug = [];
    for s = 1:3
        Xs = Xtrain(label_train == s);
        % Compute SIEM
        [Cm,V_ref,W_ref,mpos] = FormSIEM(Xs);
    
        % Spatial PCA
        D1 = 5;
        [ZZ,MuZ,UdZ,SigZ] = SpatialPCA(Cm,D1);
    
        % Functional PCA
        D2 = 5;
        [Uf,Vf,Mf,Sf] = FullfPCA(ZZ,D2);
    
        % Random Generation using Independnet Gaussian Distribution
        Snew = GaussGeneration(Sf,num_sim,1);
    
        % Reconstruction to the Posture Sequences
        % Sequential PCA Reconstruction
        Cnew = PCAReconstruction(Snew,Uf,Mf,UdZ,MuZ);
        % SIEM Reconstruction
        [Xnew,Ynew] = SIEM_to_posture(Cnew,V_ref,W_ref,mpos);
    
        X_aug = [X_aug Xnew Xs];
    end
    label_aug = [repmat(1,1,num_sim+Ntrain) repmat(2,1,num_sim+Ntrain) repmat(3,1,num_sim+Ntrain)]; 
    
    %%% ---- 4. 5-NN Classification with Augmented Data ---
    for i = 1:length(Xtest)
        for j = 1:length(X_aug)
            di(j) = dist_seq_to_seq(Xtest{i}, X_aug{j});
        end
        [dmin, ind] = mink(di,5);
        lable_est_aug(i) = mode(label_aug(ind));
    end
    acc_aug(n_run) = sum(lable_est_aug == label_test)/length(Xtest);
end

mean_0 = mean(acc);
std_0 = std(acc);
mean_aug = mean(acc_aug);
std_aug = std(acc_aug);

save('../06_results/Classification/5NN_SIEM.mat');

