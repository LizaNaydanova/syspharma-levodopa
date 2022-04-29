clear; clc;

%% Parameters

% Select method for virtual compartment
%p.cleared = 'conc';

p.V1 = 11;        % units: L
p.V2 = 27;        % units: L
p.CL = 0.52;      % units: L/min
p.Q = 0.58;       % units: L/min
p.ka = 1/28.5;    % units: 1/min (1/TABS)  
p.k_EO = 1/21;    % units: 1/min (1/TKEO)  
p.BIO = .88 ;     % units: 
p.R_SYN = 0.01;   % units: mg/min 
p.inf = 0;        % units: mg/min   


%% Initial Conditions

D0 = 400;           % units: mg  ###NOT SURE, PLEASE CONFIRM 

%% Timing of doses

% length of time when morning bolus dose is administered
t_morning   = 0.5*60;                       % units: min
% night time when pump is turned off (12 hrs for now)
t_night     = 12*60;  % units: min
% length of time that infusion pump is running during the day
t_day       = 24*60 - t_morning - t_night;                      % units: min

% number of days we will run the simulation for
num_days = 7;

%% Simulation

[T,Y] = missed_dose_normal(t_morning,t_day,t_night, num_days, D0, p );

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
plot(T,Y(:,2),'-') 
title('Levodopa Conc. in V1')

% Plotting levodopa concentration in V2
figure; 
plot(T,Y(:,3),'-') 
title('Levodopa Conc. in V2')

% Plotting Effect on a TRS scale
figure; 
plot(T,E,'-') 
title('Effect')

%% Saving Results
C_1 = Y(:,2); C_2 = Y(:,3); 
save pkpd_results.mat T C_1 C_2 E