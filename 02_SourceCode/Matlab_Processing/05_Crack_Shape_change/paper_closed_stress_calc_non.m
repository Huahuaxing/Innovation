% 该脚本计算结果显示闭合应力分别是：
% 1.2702e+07
% 3.4403e+07
% 1.7202e+07
[fPath, ~, ~] = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(fPath, 'utils')));

%% 计算单裂隙的闭合应力值
b0 = 1e-4/2;
c0 = 0.036/2;
E = 5.96e9;
nu = 0.15;
a = sigma_close_p(b0, c0, E, nu);
disp(a);

%% 计算模拟裂隙AR1的闭合应力
b1 = 2e-4 / 2;
c1 = 0.036 / 2;
E1 = 7.82e9;
nu1 = 0.23;
b = sigma_close_p(b1, c1, E1, nu1);
disp(b)

%% 计算模拟裂隙AR2的闭合应力
b2 = 1e-4/2;
c2 = 0.036/2;
E2 = 7.82e9;
nu2 = 0.23;
c = sigma_close_p(b2, c2, E2, nu2);
disp(c);