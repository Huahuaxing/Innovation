%% ============================================
%  Stress-Vp 拟合脚本 (基于经验公式)
%  公式: V(P) = A + K*P - B*exp(-P*D)
%% ============================================
clear; clc; close all;
%% ------------------------- 定义基质弹性参数 -------------------------

v_stress= 2118.9;       % 纵波波速 (m/s)
v_shear = 1254.7;       % 横波波速 (m/s)
rho     = 2020;         % 密度 (kg/m³)
K       = 4.829e9;      % 体积模量 (Pa)
E       = 7.820e9;      % 杨氏模量 (Pa)
nu      = 0.23;         % 泊松比
lam     = 2.71e9;       % Lamé 第一参数 (Pa)
mu      = 3.180e9;      % 剪切模量 (Pa)
% lam = E*nu/((1+nu)*(1-2*nu));        % 若需用公式计算

P  = linspace(3, 600, 200);       % 3e5-6e7 Pa
P = P(:);                              % 变成列向量
cd(fileparts(mfilename('fullpath')))
nonellipse_vp_path = fullfile(".\degree_90\vp_polygonal.csv");
nonellipse_vp = readmatrix(nonellipse_vp_path);

cycle = 6;

%% 定义拟合函数
model_fun = @(params, P) params(1) + params(2)*P - params(3)*exp(-P*params(4));

params0 = [2050.1647, 0, 800, 2];

vp_culc = model_fun(params0, P);

figure;
plot(P, vp_culc)