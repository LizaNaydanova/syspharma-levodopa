
function [T,Y] = missed_dose_infusion(t_morning,t_day,t_night, num_days, D0, p, pump_off_start, pump_off_time )

    % Set options for solver
    options = odeset('MaxStep',5e-2, 'AbsTol', 1e-5,'RelTol', 1e-5,'InitialStep', 1e-2);

    % Set initial conditions
    T = [0];
    Y = [D0, 0, 0, 0, 0];

    %% First dose
    % First dose is the morning bolus dose, administered over 30 mins

    % Set the times and initial conditions
    start_time = 0;                     % bolus begins at time 0
    end_time = start_time + t_morning;  % ends after 30 mins
    y0 = Y;                             % Initial Conditions
    
    % run simulation 
    [t,y] = ode45(@westin_etal_eqns_levodopa,(start_time:1:end_time),y0,options,p); % simulate model
    y_prev = y(end,:)';
    T=cat(1,T,t(2:end,:));
    Y=cat(1,Y,y(2:end,:));

    %% Loop through for multiple days (timestep is 1 day, length is 7 days):
    for time = 0:24*60:num_days*24*60

        if time >= 24*60 && time < 24*60*2

            % Set the times and initial conditions
            start_time = end_time;
            end_time = end_time + pump_off_start; 
            y0 = y_prev; 
            p.inf = 2; % 1.04;   % units: mg/min   1500 mg per day ###NOT SURE, PLEASE CONFIRM 
    
            % run simulation
            [t,y] = ode45(@westin_etal_eqns_levodopa,(start_time:1:end_time),y0,options,p); % simulate model
            y_prev = y(end,:)';
            T=cat(1,T,t(2:end,:));
            Y=cat(1,Y,y(2:end,:));

            % Set the times and initial conditions
            start_time = end_time;
            end_time = end_time + pump_off_time; 
            y0 = y_prev; 
            p.inf = 0; % 1.04;   % units: mg/min   1500 mg per day ###NOT SURE, PLEASE CONFIRM 
    
            % run simulation
            [t,y] = ode45(@westin_etal_eqns_levodopa,(start_time:1:end_time),y0,options,p); % simulate model
            y_prev = y(end,:)';
            T=cat(1,T,t(2:end,:));
            Y=cat(1,Y,y(2:end,:));

            % Set the times and initial conditions
            start_time = end_time;
            end_time = end_time + (t_day - pump_off_start - pump_off_time); 
            y0 = y_prev; 
            p.inf = 2; % 1.04;   % units: mg/min   1500 mg per day ###NOT SURE, PLEASE CONFIRM 
    
            % run simulation
            [t,y] = ode45(@westin_etal_eqns_levodopa,(start_time:1:end_time),y0,options,p); % simulate model
            y_prev = y(end,:)';
            T=cat(1,T,t(2:end,:));
            Y=cat(1,Y,y(2:end,:));

        else

            %% Continuous Infusion
            % After the morning bolus dose, continuous dose infusion is given
            % for 11.5 hours
            
            % Set the times and initial conditions
            start_time = end_time;
            end_time = end_time + t_day; 
            y0 = y_prev; 
            p.inf = 2; % 1.04;   % units: mg/min   1500 mg per day ###NOT SURE, PLEASE CONFIRM 
    
            % run simulation
            [t,y] = ode45(@westin_etal_eqns_levodopa,(start_time:1:end_time),y0,options,p); % simulate model
            y_prev = y(end,:)';
            T=cat(1,T,t(2:end,:));
            Y=cat(1,Y,y(2:end,:));

        end

        %% No infusion
        % At night (12 hours), pump is switched off and p.inf is 0

        % Set the times and initial conditions
        start_time = end_time;
        end_time = end_time + t_night; 
        y0 = y_prev; 
        p.inf =  0; % 1.04;   % units: mg/min   1500 mg per day ###NOT SURE, PLEASE CONFIRM 

        % run simulation
        [t,y] = ode45(@westin_etal_eqns_levodopa,(start_time:1:end_time),y0,options,p); % simulate model
        y_prev = y(end,:)';
        T=cat(1,T,t(2:end,:));
        Y=cat(1,Y,y(2:end,:));

        %% Morning bolus
        % The following morning another bolus dose is given

        % Set the times and initial conditions
        start_time = end_time;
        end_time = end_time + t_morning; 
        y0 = y_prev + [D0, 0, 0, 0, 0]'; 

        % run simulation
        [t,y] = ode45(@westin_etal_eqns_levodopa,(start_time:1:end_time),y0,options,p); % simulate model
        y_prev = y(end,:)';
        T=cat(1,T,t(2:end,:));
        Y=cat(1,Y,y(2:end,:));

    end





end


