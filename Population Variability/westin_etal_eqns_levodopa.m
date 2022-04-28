function dydt = westin_etal_eqns_levodopa(t,y,p)
% This function defines equations to simulate the concentration of
% levodopa. Our main code doesn't call
% this function directly; it calls an ODE solver, which then calls this
% function repeatedly - i.e. at each time step - to calculate dydt
%
%% THIS FUNCTION RETURNS:
% dydt = the rates of change of the concentrations of
%  the molecules we are simulating
%
%% ARGUMENTS
% t = current time (this is passed from the ODE solver to here)
% y = current value of the concentrations (this is passed from the ode 
% solver to here; this will have three elements, one for each molecule)
% p = structured parameter set (we define this in our main code, and pass
% it to the ODE solver, which passes it to this function)

%% EQUATIONS

% this line just defines how many equations there will be
dydt = zeros(5,1);    % make it a column vector (e.g. (3,1))

% List of equations. Equation (1) is the ODE associated with the
% amount of levodopa (1); but note that each equation might depend
% on the concentrations of multiple molecules. This is what makes these
% 'coupled ODEs'
dydt(1) = p.inf - p.ka*y(1);                                      % Duodenal Compartment
dydt(2) = p.BIO*p.ka*y(1) - ((p.Q/p.V1)+(p.CL/p.V1))*y(2) +...    % Central Compartment
    (p.Q/p.V2)*y(3) + p.R_SYN; 
dydt(3) = (p.Q/p.V1)*y(2) - (p.Q/p.V2)*y(3);                      % Peripheral Compartment
dydt(4) = p.k_EO*((y(2)/p.V1) - y(4));                            % Effect Compartment
dydt(5) = p.CL*y(2)/p.V1;                                         % CL 


