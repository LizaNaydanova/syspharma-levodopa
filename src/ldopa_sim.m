function [Y,T] = ldopa_sim(D0,post_bolus_interval,continuous_interval,p)  
    %post_bolus_interval = 4*60;   % units: min
    %acontinuous_interval = 2*60;   % units: min
    
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
    y0=y_prev; p.inf = 1.04;   % units: mg/min   1500 mg per day ###NOT SURE, PLEASE CONFIRM 
    options = odeset('MaxStep',5e-2, 'AbsTol', 1e-5,'RelTol', 1e-5,'InitialStep', 1e-2);
    [t,y] = ode45(@westin_etal_eqns_levodopa,(start_time:1:end_time),y0,options,p); % simulate model
    %MassBalanceD1 = mass_balance(T2,Y2,y0,p);
    T=cat(1,T,t(2:end,:));
    Y=cat(1,Y,y(2:end,:));

    %plot(T,Y(:,4),'o-')  % Plotting levodopa concentration in V1