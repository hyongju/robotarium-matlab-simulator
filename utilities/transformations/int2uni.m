function [ dx ] = int2uni(dxi, x, lambda)
%DIFFEOMORPHISM Translates from single integrator to unicycle dynamics
%   dxi - single integrator control input 
%   x - unicycle states 3 x N
    
    % Initialize parameters
    [~, N] = size(dxi); 
    dx = zeros(2, N); 
    T = [1 0; 0 1/lambda];
    
    for i = 1:N
        dx(:, i) = T * [cos(x(3, i)) sin(x(3, i)); -sin(x(3, i)) cos(x(3,i))] * dxi(:, i);
    end
end

