clear; clc;

%% Parameters

% Select method for virtual compartment
% p.cleared = 'conc';

p.V1 = 11;        % units: L
p.V2 = 27;        % units: L
p.CL = 0.52;      % units: L/min
p.Q = 0.58;       % units: L/min
p.ka = 1/28.5;    % units: 1/min (1/TABS)  
p.k_EO = 1/21;    % units: 1/min (1/TKEO)  
p.BIO = .88 ;     % units: 
p.R_SYN = 0.01;   % units: mg/min 
p.inf = 0;        % units: mg/min   


lev_simulate(p,200,1,'pkpd_normal_dose.mat')
lev_simulate(p,400,2,'pkpd_double_dose.mat')
lev_simulate(p,400,1,'pkpd_double_initial_dose.mat')
lev_simulate(p,200,2,'pkpd_double_second_dose.mat')




function [T, C_1, C_2, E] = lev_simulate(p,bolus_dose,cont_dose,save_file_name)
%% Initial Conditions

D0 = bolus_dose;           % units: mg  ###NOT SURE, PLEASE CONFIRM  


%% PEDAL study run

post_bolus_interval = 0.5*60;   % units: min
continuous_interval = 10*60;   % units: min
p.inf = 0;        % units: mg/min 

% Post Morning Bolus Simulation
start_time = 0;
end_time = start_time + post_bolus_interval;
T=[0]; Y=[D0, 0, 0, 0, 0]; y0=Y; % Initial Conditions
options = odeset('MaxStep',5e-2, 'AbsTol', 1e-5,'RelTol', 1e-5,'InitialStep', 1e-2);
[t,y] = ode45(@westin_etal_eqns_levodopa,(start_time:1:end_time),y0,options,p); % simulate model
%MassBalanceD1 = mass_balance(T2,Y2,y0,p);
y_prev = y(end,:)';
T=cat(1,T,t(2:end,:));
Y=cat(1,Y,y(2:end,:));

% Continuous Dose Simulation
start_time = end_time;
end_time = end_time + continuous_interval; 
y0=y_prev; p.inf =  cont_dose; % 1.04;   % units: mg/min   1500 mg per day ###NOT SURE, PLEASE CONFIRM 
options = odeset('MaxStep',5e-2, 'AbsTol', 1e-5,'RelTol', 1e-5,'InitialStep', 1e-2);
[t,y] = ode45(@westin_etal_eqns_levodopa,(start_time:1:end_time),y0,options,p); % simulate model
%MassBalanceD1 = mass_balance(T2,Y2,y0,p);
T=cat(1,T,t(2:end,:));
Y=cat(1,Y,y(2:end,:));


% Effect on a TRS scale
c_e = Y(:,4);    % units: mg/L
BASE = -1.58;    % units: TRS
E_max = 2.39;    % units: TRS
EC_50 = 1.55;    % units: mg/L
gamma = 11.6;    % units: sigmoidicity 
E = BASE + (E_max*c_e.^gamma)./(c_e.^gamma + EC_50^gamma);   

%% Visualize

% Plotting levodopa concentration in V1
figure; 
plot(T,Y(:,2),'o-') 
title('Levodopa Conc. in V1')

% Plotting levodopa concentration in V2
figure; 
plot(T,Y(:,3),'o-') 
title('Levodopa Conc. in V2')

% Plotting Effect on a TRS scale
figure; 
plot(T,E,'o-') 
title('Effect')

%% Saving Results
C_1 = Y(:,2); C_2 = Y(:,3); 
save(save_file_name,'T','C_1','C_2','E')

end










