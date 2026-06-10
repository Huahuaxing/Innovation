% =============================================
% Conceptual Fitting Visualization: Vp vs. Inclination Models
% This script compares nonelliptical vs. elliptical cracks for Vp fitting.
% Parameters: A, K, B, D; Multiple models (a-f); Plots results for visual comparison.
% =============================================
clear; clc;

% --------- Initialize Model Parameters ---------
% p: Nonelliptical crack results (A, K, B, D)
% q: Elliptical crack results (A, K, B, D)
% pq: Reference/standard values (A, K, B, D)
p = zeros(6,4); pq = zeros(6,4); q = zeros(6,4);

% Model 1
p(1,:) = [2149.23, 1.34e-9, 109.98, 0.023];
q(1,:) = [2723.44, 0.00118, 682.8, 0.0016];
pq(1,:) = [2120, 0, 71.5, 0.08];

% Model 2
p(2,:) = [2133.45, 6.7e-9, 96.31, 0.0388];
q(2,:) = [2180.69, 1.07e-13, 140.28, 0.012];
pq(2,:) = [2120, 0, 71.5, 0.08];

% Model 3
p(3,:) = [2131.82, 1.33e-12, 93.62, 0.04];
q(3,:) = [2242.8, 2.9e-7, 203, 0.008];
pq(3,:) = [2120, 0, 71.5, 0.08];

% Model 4
p(4,:) = [2125.76, 2.11e-8, 88.4, 0.054];
q(4,:) = [2138.21, 4.94e-9, 101.6, 0.0284];
pq(4,:) = [2120, 0, 71.5, 0.08];

% Model 5
p(5,:) = [2123.73, 7.56e-9, 89.31, 0.0648];
q(5,:) = [2136.94, 4.06e-9, 100.89, 0.03];
pq(5,:) = [2120, 0, 71.5, 0.08];

% Model 6
p(6,:) = [2121.45, 2.32736e-9, 87.33, 0.086];
q(6,:) = [2124.42, 2.54943e-8, 93.57, 0.06];
pq(6,:) = [2120, 0, 71.5, 0.08];

% --------- Subplot Visualization ---------
figure('Position', [100 100 1200 700]);

% --- A parameter ---
subplot(2,2,1)
plot(p(:,1),'cs','MarkerSize',8); hold on;
plot(q(:,1),'r*','MarkerSize',8);
plot(pq(:,1),'k-.','LineWidth', 1.5);
legend('Nonelliptical crack','Elliptical crack','Standard value');
xticks(1:6);
xticklabels({'Model a','Model b','Model c','Model d','Model e','Model f'});
ylabel('A value');
title('(a) A Parameter','fontsize',14,'fontname','Times New Roman')
grid on;

% --- K parameter ---
subplot(2,2,2)
plot(p(:,2),'cs','MarkerSize',8); hold on;
plot(q(:,2),'r*','MarkerSize',8);
plot(pq(:,2),'k-.','LineWidth', 1.5);
legend('Nonelliptical crack','Elliptical crack','Standard value');
xticks(1:6); ylabel('K value'); ylim([-0.2e-3 1.5e-3]);
xticklabels({'Model a','Model b','Model c','Model d','Model e','Model f'});
title('(b) K Parameter','fontsize',14,'fontname','Times New Roman');
grid on;

% --- B parameter ---
subplot(2,2,3)
plot(p(:,3),'cs','MarkerSize',8); hold on;
plot(q(:,3),'r*','MarkerSize',8);
plot(pq(:,3),'k-.','LineWidth', 1.5);
legend('Nonelliptical crack','Elliptical crack','Standard value');
xticks(1:6); ylabel('B value');
xticklabels({'Model a','Model b','Model c','Model d','Model e','Model f'});
title('(c) B Parameter','fontsize',14,'fontname','Times New Roman');
grid on;

% --- D parameter ---
subplot(2,2,4)
plot(p(:,4),'cs','MarkerSize',8); hold on;
plot(q(:,4),'r*','MarkerSize',8);
legend('Nonelliptical crack','Elliptical crack');
xticks(1:6); ylabel('D value');
xticklabels({'Model a','Model b','Model c','Model d','Model e','Model f'});
title('(d) D Parameter','fontsize',14,'fontname','Times New Roman');
grid on;
