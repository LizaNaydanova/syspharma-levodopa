
function [outAUC1,outAUC2, out3, T] = levodopa(CL,Vc,Vp,Q, Dose) 

%% Parameters

% Select method for virtual compartment
%p.cleared = 'conc';

p.V1 = Vc;        % units: L
p.V2 = Vp;        % units: L
p.CL = CL;      % units: L/min
p.Q = Q;       % units: L/min
p.ka = 1/28.5;    % units: 1/min (1/TABS)  
p.k_EO = 1/21;    % units: 1/min (1/TKEO)  
p.BIO = .88 ;     % units: 
p.R_SYN = 0.01;   % units: mg/min 
p.inf = 0;        % units: mg/min   


%% Initial Conditions

D0 = Dose;           % units: 200 mg  ###NOT SURE, PLEASE CONFIRM  


%% PEDAL study run

post_bolus_interval = 0.5*60;   % units: min
continuous_interval = 10*60;   % units: min

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
y0=y_prev; p.inf =  1; % 1.04;   % units: mg/min   1500 mg per day ###NOT SURE, PLEASE CONFIRM 
options = odeset('MaxStep',5e-2, 'AbsTol', 1e-5,'RelTol', 1e-5,'InitialStep', 1e-2);
[t,y] = ode45(@westin_etal_eqns_levodopa,(start_time:1:end_time),y0,options,p); % simulate model
%MassBalanceD1 = mass_balance(T2,Y2,y0,p);
T=cat(1,T,t(2:end,:));
Y=cat(1,Y,y(2:end,:));

%% RETURN THE CALCULATED AUC AND EFFECT VALUES

outAUC1=trapz(T,Y(:,2)); % concentrations are mg/L so AUC units = mg/L*hr % Central
outAUC2=trapz(T,Y(:,3)); % Peripheral
out3=Y(:,4); % Concentration of Effect Compartment
end