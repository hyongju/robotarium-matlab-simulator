%Formation control utilizing edge tension energy with a static, undirected
%communication topology
%Paul Glotfelter 
%3/24/2016

% Get Robotarium object used to communicate with the robots/simulator
r = Robotarium();

% Get the number of available agents from the Robotarium.  We don't need a
% specific value for this algorithm
N = 6; 

% Initialize the Robotarium object with the desired number of agents
r.initialize(N);

%Gains for the transformation from single-integrator to unicycle dynamics
linearVelocityGain = 1; 
angularVelocityGain = pi/2;
formationControlGain = 4;

% Select the number of iterations for the experiment.  This value is
% arbitrary
iterations = 100000;

% Communication topology for the desired formation.  We need 2 * N - 3 = 9
% edges to ensure that the formation is rigid.
L = [3 -1 0 -1 0 -1 ; ... 
    -1 3 -1 0 -1 0 ; ... 
    0 -1 3 -1 0 -1 ; ... 
    -1 0 -1 3 -1 0 ; ... 
    0 -1 0 -1 3 -1 ; ... 
   -1 0 -1 0 -1 3];

% The desired inter-agent distance for the formation
d = 0.2; 

% Pre-compute diagonal values for the rectangular formation
ddiag = sqrt((2*d)^2 + d^2);

% Weight matrix containing the desired inter-agent distances to achieve a
% rectuangular formation
weights = [ 0 d 0 d 0 ddiag; ... 
            d 0 d 0 d 0; ... 
            0 d 0 ddiag 0 d; ... 
            d 0 ddiag 0 d 0; ... 
            0 d 0 d 0 d; ... 
            ddiag 0 d 0 d 0];
    
% Initialize velocity vector for agents.  Each agent expects a 2 x 1
% velocity vector containing the linear and angular velocity, respectively.
dx = zeros(2, N);

% Iterate for the previously specified number of iterations
for t = 0:iterations
    
    
    % Retrieve the most recent poses from the Robotarium.  The time delay is
    % approximately 0.033 seconds
    x = r.getPoses();
    
    %%% ALGORITHM %%%
    
    %This section contains the actual algorithm for formation control!
    
    %Calculate single integrator control inputs using edge-energy consensus
    for i = 1:N
        
        % Initialize velocity to zero for each agent.  This allows us to sum
        % over agent i's neighbors
        dx(:, i) = [0 ; 0];
        
        % Get the topological neighbors of agent i from the communication
        % topology
        for j = r.getTopNeighbors(i, L)
                
            % For each neighbor, calculate appropriate formation control term and
            % add it to the total velocity

            %%% FORMATION CONTROL %%%

            dx(:, i) = dx(:, i) + ...
            formationControlGain*(norm(x(1:2, i) - x(1:2, j))^2 - weights(i, j)^2) ... 
            *(x(1:2, j) - x(1:2, i));

            %%% END FORMATION CONTROL %%%
        end 
    end
    
    %%% END ALGORITHM %%%
    
    % Transform the single-integrator dynamics to unicycle dynamics using a provided utility function
    dx = int2uni2(dx, x, linearVelocityGain, angularVelocityGain);  
    
    % Set velocities of agents 1:N
    r.setVelocities(1:N, dx);
    
    % Send the previously set velocities to the agents.  This function must be called!
    r.step();   
end


