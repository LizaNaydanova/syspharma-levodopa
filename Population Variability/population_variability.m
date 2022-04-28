%%%%% Part 1: Generate a distribution of 10,000 patients by weight %%%%%

%%%% From literature, we have parameter estimates for CL, Vc, and Vp
%%%% Will use these estimates and its allometric relationship with weight
%%%% to perform population PK

Vc_coeff = 45.4 ;
Vc_expon = 1;

Vp_coeff = 44.9;
Vp_expon = 1; 

CL_coeff = 1.31;
CL_expon = 0.75;

Q_coeff  = 0.667;
Q_expon  = 0.75;

%%% Generate new virtual population
NumberOfSubjects = 500;
param_mean = 75.4;
sd   = 11.3;
cutoff = 30;
str = 'WeightDistribs_';
Assignment4Starter2022(NumberOfSubjects, param_mean, sd, cutoff, str);
Weights_output = load(strcat(str,string(NumberOfSubjects),'.mat'),'patientID','Param_Val');
Weights = Weights_output.Param_Val;

Vc_samp = Vc_coeff*(Weights/70).^Vc_expon;
Vp_samp = Vp_coeff*(Weights/70).^Vp_expon;
CL_samp = CL_coeff*(Weights/70).^CL_expon;
Q_samp  = Q_coeff*(Weights/70).^Q_expon;

%%% Generate PK Variables
% kcl_vc = CL_samp./Vc_samp;
% kcl_vp = CL_samp./Vp_samp;

%%%%% Part 2: Run the Levodopa Model on Simulated PopPK Parameters %%%%%
Vc = 11;        % units: L
Vp = 27;        % units: L
CL = 0.52;      % units: L/min
Q = 0.58;       % units: L/min

D0 = 200; %mg
AUC_central_arr1    = zeros(NumberOfSubjects, 1);
AUC_central_arr2    = zeros(NumberOfSubjects, 1);
AUC_central_arr3    = zeros(NumberOfSubjects, 1);
AUC_central_arr4    = zeros(NumberOfSubjects, 1);
AUC_central_arr5    = zeros(NumberOfSubjects, 1);
AUC_peripheral_arr1 = zeros(NumberOfSubjects, 1);
AUC_peripheral_arr2 = zeros(NumberOfSubjects, 1);
AUC_peripheral_arr3 = zeros(NumberOfSubjects, 1);
AUC_peripheral_arr4 = zeros(NumberOfSubjects, 1);
AUC_peripheral_arr5 = zeros(NumberOfSubjects, 1);

% for i = 1:NumberOfSubjects
%     [AUC_central1,AUC_peripheral1] = levodopa(CL_samp(i),Vc,Vp,Q,D0);
%     [AUC_central2,AUC_peripheral2] = levodopa(CL,Vc_samp(i),Vp,Q,D0);
%     [AUC_central3,AUC_peripheral3] = levodopa(CL,Vc,Vp_samp(i),Q,D0);
%     [AUC_central4,AUC_peripheral4] = levodopa(CL,Vc,Vp,Q_samp(i),D0);
%     [AUC_central5,AUC_peripheral5] = levodopa(CL_samp(i),Vc_samp(i),Vp_samp(i),Q_samp(i),D0);
%     
%     AUC_central_arr1(i) = AUC_central1;
%     AUC_central_arr2(i) = AUC_central2;
%     AUC_central_arr3(i) = AUC_central3;
%     AUC_central_arr4(i) = AUC_central4;
%     AUC_central_arr5(i) = AUC_central5;
%     AUC_peripheral_arr1(i) = AUC_peripheral1;
%     AUC_peripheral_arr2(i) = AUC_peripheral2;
%     AUC_peripheral_arr3(i) = AUC_peripheral3;
%     AUC_peripheral_arr4(i) = AUC_peripheral4;
%     AUC_peripheral_arr5(i) = AUC_peripheral5;
%     
% end


%%%%% Part 2: Run the Levodopa Model on Simulated PopPD Parameters %%%%%
%% Effect on a TRS scale
[~,~,c_e, T]  = levodopa(CL,Vc,Vp,Q,D0);    % units: mg/L

BASE = -1.58;    % units: TRS
E_max = 2.39;    % units: TRS
EC_50 = 1.55;    % units: mg/L
gamma = 11.6;    % units: sigmoidicity 

%% Simulate 500 Patients
EC50_sd  = 0.5;
gamma_sd = 5;
cutoff = 0;
Assignment4Starter2022(NumberOfSubjects, EC_50, EC50_sd, cutoff,'EC50Distribs_');
Assignment4Starter2022(NumberOfSubjects, gamma, gamma_sd, cutoff,'GammaDistribs_');
EC50s_out  = load(strcat('EC50Distribs_',string(NumberOfSubjects),'.mat'),'patientID','Param_Val');
Gammas_out = load(strcat('GammaDistribs_',string(NumberOfSubjects),'.mat'),'patientID','Param_Val');
EC50s = EC50s_out.Param_Val;
Gammas = Gammas_out.Param_Val;

E_norm = BASE + (E_max*c_e.^gamma)./(c_e.^gamma + EC_50^gamma);
E_EC50 = zeros(length(E_norm),NumberOfSubjects);
E_gamm = zeros(length(E_norm),NumberOfSubjects);
for i = 1:NumberOfSubjects
    patient_EC50 = EC50s(i);
    patient_gamma = Gammas(i);
    E_EC50(:,i) = BASE + (E_max*c_e.^gamma)./(c_e.^gamma + patient_EC50^gamma); 
    E_gamm(:,i) = BASE + (E_max*c_e.^patient_gamma)./(c_e.^patient_gamma + EC_50^patient_gamma); 
end

save popPK_data.mat  AUC_central_arr1 AUC_central_arr2 AUC_central_arr3 ...
     AUC_central_arr4 AUC_central_arr5 AUC_peripheral_arr1 AUC_peripheral_arr2 ...
     AUC_peripheral_arr3 AUC_peripheral_arr4 AUC_peripheral_arr5 
 
save popPD_data.mat T E_norm E_EC50 E_gamm