clear all; close all;

% Generate data
N       = 500;
mu      = [0,0];
sigma   = [6,1];
rot1    = eye(2);   % Rotation for data1
theta   = 15*pi/180;       % Angle of rotation for data2
rot2    = [cos(theta) -sin(theta); sin(theta) cos(theta)];

data1 = (rot1*(repmat(mu,N,1)+ randn(N,2).*repmat(sigma,N,1))')';
data2 = (rot2*(repmat(mu,N,1)+ randn(N,2).*repmat(sigma,N,1))')';
d1 = rot1*[1;0];
d2 = rot2*[1;0];

% Plot the generated data and their directions
subplot(1,2,1);
scatter(data1(:,1), data1(:,2)); hold on;
scatter(data2(:,1), data2(:,2)); hold on;
plot([0 d1(1)].*max(data1(:)), [0 d1(2)].*max(data1(:)), 'linewidth',2); hold on;
plot([0 d2(1)].*max(data2(:)), [0 d2(2)].*max(data2(:)), 'linewidth',2); hold on;
legend('class 1', 'class 2', 'd_1','d_2'); hold off;
grid on; axis equal;
title('Before CSP filtering');
xlabel('Channel 1'); ylabel('Channel 2');

% CSP
X1 = data1';    % Positive class data: X1~[C x T]
X2 = data2';    % Negative class data: X2~[C x T]
[W,l,A] = csp(X1,X2);
X1_CSP = W'*X1;
X2_CSP = W'*X2;

% Plot the results
subplot(1,2,2);
scatter(X1_CSP(1,:), X1_CSP(2,:)); hold on;
scatter(X2_CSP(1,:), X2_CSP(2,:)); hold on;
legend('class 1', 'class 2'); hold off;
axis equal; grid on;
title('After CSP filtering');
xlabel('Channel 1'); ylabel('Channel 2');