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
p.inf = 5;        % units: mg/min Arbitrarily selected value

%%%%
% 1 - a0
% 2 - a1
% 3 - a2
% 4 - c_e
% 5 - CL

%%
Runcase = 3 ;

%% Local bivariate sensitivity AUC in Effect Compartment Concentration (mg/L) and sensitivity variability renderse L-Dopa ineffective
switch Runcase

    case 1
        sensi_auc = zeros(9,9);
        sensi_var = zeros(9,9);
        auc = zeros(1,9);
        sensi_auc1 = zeros(1,9);
        sensi_var1 = zeros(1,9);

        ParamDelta = 0.05;
        [Y,T] = ldopa_sim(200,2*60,4*60,p);
        auc0 = trapz(T,Y(:,4));
        Y0 = Y;
        p0 = p;
        p0names = fieldnames(p);



        for i=1:length(p0names)
            p=p0;

            p.(p0names{i})=p0.(p0names{i})*(1.0+ParamDelta);

            [Y,T] = ldopa_sim(200,2*60,4*60,p);

            auc(i) = trapz(T,Y(:,4));
            
            variance(i) = var(Y(:,4));
            
            sensi_auc1(i) =  (auc(i)-auc0)/(auc0)/(p.(p0names{i})-p0.(p0names{i}))/(p0.(p0names{i}));
            
            sensi_var1(i) =  (var(Y(:,4))-var(Y0(:,4)))/var(Y0(:,4)) /(p.(p0names{i})-p0.(p0names{i}))/(p0.(p0names{i}));
        end

        for i = 1:length(p0names)
            for j = 1:length(p0names)
                
                p.(p0names{i}) = p0.(p0names{i})*(1.0+ParamDelta);
                p.(p0names{j})=p0.(p0names{j})*(1.0+ParamDelta);
                
                [Y,T] = ldopa_sim(200,2*60,4*60,p);
                auc2 = trapz(T,Y(:,4));
                
                sensi_auc(i,j) = (auc2-auc(j))/(auc(j))/(p.(p0names{i})-p0.(p0names{i}))/(p0.(p0names{i}));
                sensi_var(i,j) = (var(Y(:,4))-variance(j))/variance(j) /(p.(p0names{i})-p0.(p0names{i}))/(p0.(p0names{i}));
            end
        end
    %% Local univariate
    case 2
        sensi_auc = zeros(1,9);

        ParamDelta = 0.05;
        [Y,T] = ldopa_sim(200,2*60,4*60,p);
        
        auc0 = trapz(T,Y(:,4));
        p0 = p;
        p0names = fieldnames(p);

        for i = 1:length(p0names)
            p.(p0names{i}) = p0.(p0names{i})*(1.0+ParamDelta);
            [Y,T] = ldopa_sim(200,2*60,4*60,p);
            auc = trapz(T,Y(:,4));
            sensi_auc(i) = (auc-auc0)/(auc0)/(p.(p0names{i})-p0.(p0names{i}))/(p0.(p0names{i}));
        end

    %% Global Sensitivity of Effect Compartment Concentration Rsyn and Cl since those seem to relate to Parkinsons Disease
    case 3

        Cl = linspace(0.1,1,100);
        Rsyn = linspace(0.1,1,100);


        auc = zeros(100,100);

        for i = 1:length(Cl)
            for j = 1:length(Rsyn)
                p.R_SYN = Cl(i);
                p.CL = Rsyn(j);

                [Y,T] = ldopa_sim(200,2*60,4*60,p);

                auc(i,j) = trapz(T,Y(:,4));
            end
        end



end


