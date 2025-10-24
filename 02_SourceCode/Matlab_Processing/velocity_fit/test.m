%% ============================================
%  Stress-Vp 拟合脚本 (基于经验公式)
%  公式: V(P) = A + K*P - B*exp(-P*D)
%% ============================================
clear; clc; close all;
prop = jsondecode(fileread('properties.json'));

%% 定义拟合函数
model_fun = @(params, P) params(1) + params(2)*P - params(3)*exp(-P*params(4));

params0 = [2071, 0.0000009, 66, 0.0000001];

vp_culc = model_fun(params0, prop.P);

figure;
plot(prop.P, vp_culc)