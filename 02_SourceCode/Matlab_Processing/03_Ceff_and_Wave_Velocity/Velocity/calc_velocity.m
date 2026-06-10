%% 读取数据
ellipse_C_eff = load("D:\Projects\02_Innovation\06_ProcessedData\02_C_eff\ellipse_C_eff.mat");
ellipseC_eff = ellipse_C_eff.C_eff_ellipse;
ellipseAligned_C_eff = load("D:\Projects\02_Innovation\06_ProcessedData\02_C_eff\ellipseAligned_C_eff.mat");
ellipseAlignedC_eff = ellipseAligned_C_eff.C_eff_ellipseAligned;
nonellipse_C_eff = load("D:\Projects\02_Innovation\06_ProcessedData\02_C_eff\nonellipse_C_eff.mat");
nonellipseC_eff = nonellipse_C_eff.C_eff_nonellipse;

ellipseData = load('D:\Projects\02_Innovation\06_ProcessedData\01_aperture_radius_record\Ellipse_Record.mat');
ellipseAlignedData = load('D:\Projects\02_Innovation\06_ProcessedData\01_aperture_radius_record\EllipseAligned_Record.mat');
nonellipseData = load('D:\Projects\02_Innovation\06_ProcessedData\01_aperture_radius_record\Nonellipse_Record.mat');

apertureEllipse = ellipseData.aperture_record;      % (200,6)
radiusEllipse = ellipseData.radius_record;          % (200,6)
apertureEllipseAligned = ellipseAlignedData.aperture_record;
radiusEllipseAligned = ellipseAlignedData.radius_record;
apertureNonEllipse = nonellipseData.aperture_record;
radiusNonEllipse = nonellipseData.radius_record;

params = jsondecode(fileread('parameters.json'));
c_1 = params.c_1;
B = params.B;
sita = params.sita;
density = params.density;
dimention = params.dimention;
n = params.n;


%% 计算波速并以csv格式保存
% V_dry(200,3,31,6),200个单轴应力状态，3种波速（vp，vsh，vsv），31个波速传播角度（0度表示竖直向下，索引16表示90度），6组模型
V_dry_ellipse = Func_Velocity(ellipseC_eff, c_1, sita, density, B, apertureEllipse, radiusEllipse, dimention, n);
V_dry_ellipseAligned = Func_Velocity(ellipseAlignedC_eff, c_1, sita, density, B, apertureEllipseAligned, radiusEllipseAligned, dimention, n);
V_dry_nonellipse = Func_Velocity(nonellipseC_eff, c_1, sita, density, B, apertureNonEllipse, radiusNonEllipse, dimention, n);

% 0度波速保存
writematrix(V_dry_ellipse(:, 1, 1, :), 'D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_0\vp\vp_ellipse.csv');
writematrix(V_dry_ellipseAligned(:, 1, 1, :), 'D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_0\vp\vp_ellipseAligned.csv');
writematrix(V_dry_nonellipse(:, 1, 1, :), 'D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_0\vp\vp_nonellipse.csv');

writematrix(V_dry_ellipse(:, 3, 1, :), 'D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_0\vsv\vsv_ellipse.csv');
writematrix(V_dry_ellipseAligned(:, 3, 1, :), 'D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_0\vsv\vsv_ellipseAligned.csv');
writematrix(V_dry_nonellipse(:, 3, 1, :), 'D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_0\vsv\vsv_nonellipse.csv');

% 90度波速保存
writematrix(V_dry_ellipse(:, 1, 16, :), 'D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_90\vp\vp_ellipse.csv');
writematrix(V_dry_ellipseAligned(:, 1, 16, :), 'D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_90\vp\vp_ellipseAligned.csv');
writematrix(V_dry_nonellipse(:, 1, 16, :), 'D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_90\vp\vp_nonellipse.csv');

writematrix(V_dry_ellipse(:, 3, 16, :), 'D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_90\vsv\vsv_ellipse.csv');
writematrix(V_dry_ellipseAligned(:, 3, 16, :), 'D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_90\vsv\vsv_ellipseAligned.csv');
writematrix(V_dry_nonellipse(:, 3, 16, :), 'D:\Projects\02_Innovation\06_ProcessedData\03_velocity\n_20_degree_90\vsv\vsv_nonellipse.csv');