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

BASE = -1.58;    % units: TRS
E_max = 2.39;    % units: TRS
EC_50 = 1.55;    % units: mg/L
gamma = 11.6;    % units: sigmoidicity 


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
num_days = 3;

%% Simulation
% 1 = normal, no missed dose
% 2 = missed infusion (t = 10)
% 3 = missed infusion (t = 20)
% 4 = missed infusion (t = 30)
% 5 = missed infusion (t = 60)
% 6 = missed infusion (t = 120)
sim_num = 6;

if sim_num == 1

    % simulation
    [T,Y] = missed_dose_normal(t_morning,t_day,t_night, num_days, D0, p );

    % Effect on a TRS scale
    c_e = Y(:,4);    % units: mg/L
    E = BASE + (E_max*c_e.^gamma)./(c_e.^gamma + EC_50^gamma);  

    % Saving Results
    C_1 = Y(:,2); C_2 = Y(:,3); 
    save results_baseline.mat T C_1 C_2 E

elseif sim_num == 2

    % simulation
    pump_off_start = 4*60;
    pump_off_time = 10;
    [T,Y] = missed_dose_infusion(t_morning,t_day,t_night, num_days, D0, p, pump_off_start, pump_off_time );

    % Effect on a TRS scale
    c_e = Y(:,4);    % units: mg/L
    E = BASE + (E_max*c_e.^gamma)./(c_e.^gamma + EC_50^gamma);  

    % Saving Results
    C_1 = Y(:,2); C_2 = Y(:,3); 
    save results_infusion_10.mat T C_1 C_2 E

elseif sim_num == 3
    
    % simulation
    pump_off_start = 4*60;
    pump_off_time = 20;
    [T,Y] = missed_dose_infusion(t_morning,t_day,t_night, num_days, D0, p, pump_off_start, pump_off_time );

    % Effect on a TRS scale
    c_e = Y(:,4);    % units: mg/L
    E = BASE + (E_max*c_e.^gamma)./(c_e.^gamma + EC_50^gamma);  

    % Saving Results
    C_1 = Y(:,2); C_2 = Y(:,3); 
    save results_infusion_20.mat T C_1 C_2 E

elseif sim_num == 4
    
    % simulation
    pump_off_start = 4*60;
    pump_off_time = 30;
    [T,Y] = missed_dose_infusion(t_morning,t_day,t_night, num_days, D0, p, pump_off_start, pump_off_time );

    % Effect on a TRS scale
    c_e = Y(:,4);    % units: mg/L
    E = BASE + (E_max*c_e.^gamma)./(c_e.^gamma + EC_50^gamma);  

    % Saving Results
    C_1 = Y(:,2); C_2 = Y(:,3); 
    save results_infusion_30.mat T C_1 C_2 E

elseif sim_num == 5
    
    % simulation
    pump_off_start = 4*60;
    pump_off_time = 60;
    [T,Y] = missed_dose_infusion(t_morning,t_day,t_night, num_days, D0, p, pump_off_start, pump_off_time );

    % Effect on a TRS scale
    c_e = Y(:,4);    % units: mg/L
    E = BASE + (E_max*c_e.^gamma)./(c_e.^gamma + EC_50^gamma);  

    % Saving Results
    C_1 = Y(:,2); C_2 = Y(:,3); 
    save results_infusion_60.mat T C_1 C_2 E    

elseif sim_num == 6
    
    % simulation
    pump_off_start = 4*60;
    pump_off_time = 120;
    [T,Y] = missed_dose_infusion(t_morning,t_day,t_night, num_days, D0, p, pump_off_start, pump_off_time );

    % Effect on a TRS scale
    c_e = Y(:,4);    % units: mg/L
    E = BASE + (E_max*c_e.^gamma)./(c_e.^gamma + EC_50^gamma);  

    % Saving Results
    C_1 = Y(:,2); C_2 = Y(:,3); 
    save results_infusion_120.mat T C_1 C_2 E  

end
 

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