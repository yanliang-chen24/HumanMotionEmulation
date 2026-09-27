%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% LevelTwoSimulation_ISTVF_IG - The code is to generate and test the second
% level simulation(as ground truth) described in Sec. 7
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clear
addpath('../02_functions/')
addpath('../03_metrics/')
num_runs = 1;           % Number of Independent Runs
rng(123456)             % Random Setting

%% === Load Data ===
load ../06_results/TwoLevelSimulation/LevelOne/ISTVF_IG_run_1.mat
X0 = Result.SimulatedData;
[S,M] = size(X0);

for s = 1:S                                                                 % Loop Through 5 motion classes
    %% === Read the Level One Simulation (Reference Groud Truth) ===
    X = X0(s,:);
    ClassName = sprintf('class_%d', s);
    Uf = Result.params.(ClassName).fPCcom;
    Mf = Result.params.(ClassName).fPCAmean;
    UdZ = Result.params.(ClassName).SPCcom;
    MuZ = Result.params.(ClassName).SPCAmean;
    Vf = Result.params.(ClassName).Variance;
    %% ===Step 1: Compute ISTVF ===
    [Cm,V_ref,W_ref,mpos] = FormISTVF(X);
    
    %% === Train Test Split ===
    I = randperm(M);
    Ntrain = 0.8*M;
    Ntest = M-Ntrain;
    Xtrain = X(I(1:Ntrain));
    Xtest = X(I(Ntrain+1:M));
    
    Ctrain = Cm(:,I(1:Ntrain),:);
    Ctest = Cm(:,I(Ntrain+1:M),:);

    %% === Step 2: Spatial PCA ===
    D1 = 4;
    [Z,Mu,Ud,~] = SpatialPCA(Ctrain,D1);

    %% === Step 3: Function PCA ===
    % Set # of coefficients
    D2 = 4;
    [Un,Vn,Mn,S,~,~,~] = FullfPCA(Z,D2);
    
    %% Step 4: Level Two Simulation
    %%%% --- a). ISTVF Independent Gaussian ---
    
    %Indepedent Gaussian Distribution
    SnewIG = GaussGeneration(S,Ntest,1);        
    % Sequential PCA Reconstruction
    CnewIG = PCAReconstruction(SnewIG,Un,Mn,Ud,Mu);
    % ISTVF Reconstruction
    [Xig,YnewI] = ISTVF_to_posture(CnewIG,V_ref,W_ref,mpos);
    XnewIG(s,:) = Xig;

    %%%% --- b). ISTVF Multivariate Gaussian ---

    %Multivariate Gaussian Distribution
    SnewMG = GaussGeneration(S,Ntest,0);
    % Sequential PCA Reconstruction
    CnewMG = PCAReconstruction(SnewMG,Un,Mn,Ud,Mu);
    % ISTVF Reconstruction
    [Xmg,YnewM] = ISTVF_to_posture(CnewMG,V_ref,W_ref,mpos);
    XnewMG(s,:) = Xmg;
                              
    %%%% --- c). PWI Generation ---
    [Xi] = IntrinsicGen(Xtrain,Ntest);
    XnewI(s,:) = Xi;
    
    %% Step 5. Evaluation
    %%%% --- Metric 1. Distance Matrix & 2 Sample Test ---

    % ISTVF/Independent Gaussian Distributio    
    p1(s) = twosampletest(Xtest,XnewIG(s,:),10000);
    
    % ISTVF/Multi Gaussian Distribution
    p2(s) = twosampletest(Xtest,XnewMG(s,:),10000);

    % Intrinsic
    p3(s) = twosampletest(Xtest,XnewI(s,:),10000);
    
    %%%% ---Metric 2. Loglikelihood ---

    % a). Loglikelihood For Training Set
    % Compute the PCA Scores
    [Strain,Ztrain] = ScoreGen(Ctrain,Uf,Mf,UdZ,MuZ);
    % Compute the Loglikelihood
    [L] = LogLikeIndepGauss(Strain,Vf);
    Ltrain(s,:) = L;

    % b). Loglikelihood For Test Set
    % Compute the PCA Scores
    [Stest,Ztest] = ScoreGen(Ctest,Uf,Mf,UdZ,MuZ);
    % Compute the Loglikelihood
    [L] = LogLikeIndepGauss(Stest,Vf);
    Ltest(s,:) = L;

    % c). Loglikelihood For Independent Gaussian Generated Sequences
    % Compute ISTVF
    [Cig,~,~,~] = FormISTVF(Xig);
    % Compute the PCA Scores
    [Sig,Zig] = ScoreGen(Cig,Uf,Mf,UdZ,MuZ);
    % Compute the Loglikelihood
    [L] = LogLikeIndepGauss(Sig,Vf);
    Lig(s,:) = L;

    % d). Loglikelihood For Multivariate Gaussian Generated Sequences
    % Compute ISTVF
    [Cmg,~,~,~] = FormISTVF(Xmg);
    % Compute the PCA Scores
    [Smg,Zmg] = ScoreGen(Cmg,Uf,Mf,UdZ,MuZ);
    % Compute the Loglikelihood
    [L] = LogLikeIndepGauss(Smg,Vf);
    Lmg(s,:) = L;

    % e). Loglikelihood For Intrinsic Generated Sequences
    % Compute ISTVF
    [Ci,~,~,~] = FormISTVF(Xi);
    % Compute the PCA Scores
    [Si,Zi] = ScoreGen(Ci,Uf,Mf,UdZ,MuZ);
    % Compute the Loglikelihood
    [L] = LogLikeIndepGauss(Si,Vf);
    Li(s,:) = L;

    disp(['Motion ', num2str(s),' completed']);
end

beep
%% Save
save('../06_results/TwoLevelSimulation/LevelTwo/SimLevelTwoTest_ISTVF_IG.mat')