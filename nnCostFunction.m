function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1)); % 25 x 401
Theta2_grad = zeros(size(Theta2)); % 10 x 26

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

% Compute Cost
X = [ones(m,1) X];
z2 = X*Theta1';
a2 = [ones(m,1) sigmoid(z2)];
z3 = a2*Theta2';
h = sigmoid(z3);
            
y_new = zeros(m,num_labels);
index = 0;
cur_y = zeros(1,num_labels);

for i = 1 : m,
    index = y(i,1);
    y_new(i,index) = 1;
    cur_y = y_new(i,:);
    J += sum((-cur_y .* log(h(i,:))) - ((1-cur_y) .* log(1-h(i,:))));
end;
            
J = J/m;
            
% Adding on regularization
T1 = Theta1;
T2 = Theta2;

T1(:,1) = zeros(hidden_layer_size, 1);
T2(:,1) = zeros(num_labels, 1);

J += (lambda / (2*m)) * (sum(sum(T1 .^ 2)) + sum(sum(T2 .^ 2)));


% Gradient calculation
delta1 = zeros(size(Theta1));
delta2 = zeros(size(Theta2));
z2 = [ones(m,1) z2];

for t = 1:m,
    error3 = h(t,:) - y_new(t,:); % 1 x 10 vector
    error2 = (Theta2' * error3')' .* sigmoidGradient(z2(t,:));
    error2 = error2(2:end); % 1 x 25 vector
              
    a = a2(t,:);
    b = X(t,:);
    
    delta2 += (error3' * a);
    delta1 += (error2' * b);
end;
              
Theta1_grad = (1/m) * delta1;
Theta2_grad = (1/m) * delta2;

% Adding on regularization
               
Theta1(:,1) = zeros(hidden_layer_size,1);
Theta2(:,1) = zeros(num_labels,1);
                
Theta1_grad = Theta1_grad .+ ((lambda/m) * Theta1);
Theta2_grad = Theta2_grad .+ ((lambda/m) * Theta2);
               
% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
