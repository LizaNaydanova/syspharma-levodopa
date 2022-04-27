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
Assignment4Starter2022(NumberOfSubjects);
load(strcat('WeightDistribs_',string(NumberOfSubjects),'.mat'),'patientID','Weights');

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
AUC_peripheral_arr1 = zeros(NumberOfSubjects, 1);
AUC_peripheral_arr2 = zeros(NumberOfSubjects, 1);
AUC_peripheral_arr3 = zeros(NumberOfSubjects, 1);

for i = 1:NumberOfSubjects
    [AUC_central1,AUC_peripheral1] = levodopa(CL_samp(i),Vc,Vp,Q,D0);
    [AUC_central2,AUC_peripheral2] = levodopa(CL,Vc_samp(i),Vp,Q,D0);
    [AUC_central3,AUC_peripheral3] = levodopa(CL,Vc,Vp_samp(i),Q,D0);
    
    AUC_central_arr1(i) = AUC_central1;
    AUC_central_arr2(i) = AUC_central2;
    AUC_central_arr3(i) = AUC_central3;
    AUC_peripheral_arr1(i) = AUC_peripheral1;
    AUC_peripheral_arr2(i) = AUC_peripheral2;
    AUC_peripheral_arr3(i) = AUC_peripheral3;
    
end

save popPK_data.mat  AUC_central_arr1 AUC_central_arr2 AUC_central_arr3 AUC_peripheral_arr1 AUC_peripheral_arr2 AUC_peripheral_arr3 
