"""
============================================
Stress-Vp 拟合脚本 (基于经验公式)
公式: V(P) = A + K*P - B*exp(-P*D)
============================================
"""

import json
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
import os

# 设置中文字体支持
plt.rcParams['font.sans-serif'] = ['SimHei', 'DejaVu Sans']
plt.rcParams['axes.unicode_minus'] = False

def model_function(P, A, K, B, D):
    """
    拟合函数: V(P) = A + K*P - B*exp(-P*D)
    """
    return A + K*P - B*np.exp(-P*D)

def save_fit_results_to_file(poly_params, ellipse_params, poly_resnorm, ellipse_resnorm,
                           poly_r_squared, ellipse_r_squared, titles, indices):
    """
    保存所有拟合相关参数到txt文件
    """
    from datetime import datetime
    
    # 生成文件名（包含时间戳）
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"fit_results_{timestamp}.txt"
    
    with open(filename, 'w', encoding='utf-8') as f:
        f.write("=" * 80 + "\n")
        f.write("应力-波速拟合结果报告\n")
        f.write(f"生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write("拟合公式: V(P) = A + K*P - B*exp(-P*D)\n")
        f.write("=" * 80 + "\n\n")
        
        # 多边形数据结果
        f.write("多边形数据拟合结果\n")
        f.write("-" * 50 + "\n")
        for i in range(len(titles)):
            data_idx = indices[i]
            f.write(f"组 {i+1} ({titles[i]}) - 数据索引: {data_idx}\n")
            f.write(f"  拟合参数:\n")
            f.write(f"    A = {poly_params[i][0]:.6f}\n")
            f.write(f"    K = {poly_params[i][1]:.6f}\n")
            f.write(f"    B = {poly_params[i][2]:.6f}\n")
            f.write(f"    D = {poly_params[i][3]:.6f}\n")
            f.write(f"  残差平方和 = {poly_resnorm[i]:.6f}\n")
            f.write(f"  R² = {poly_r_squared[i]:.6f}\n")
            f.write("\n")
        
        # 椭圆数据结果
        f.write("椭圆数据拟合结果\n")
        f.write("-" * 50 + "\n")
        for i in range(len(titles)):
            data_idx = indices[i]
            f.write(f"组 {i+1} ({titles[i]}) - 数据索引: {data_idx}\n")
            f.write(f"  拟合参数:\n")
            f.write(f"    A = {ellipse_params[i][0]:.6f}\n")
            f.write(f"    K = {ellipse_params[i][1]:.6f}\n")
            f.write(f"    B = {ellipse_params[i][2]:.6f}\n")
            f.write(f"    D = {ellipse_params[i][3]:.6f}\n")
            f.write(f"  残差平方和 = {ellipse_resnorm[i]:.6f}\n")
            f.write(f"  R² = {ellipse_r_squared[i]:.6f}\n")
            f.write("\n")
        
        # 对比分析
        f.write("多边形与椭圆数据对比分析\n")
        f.write("-" * 50 + "\n")
        for i in range(len(titles)):
            f.write(f"组 {i+1} ({titles[i]}):\n")
            f.write(f"  多边形 R² = {poly_r_squared[i]:.6f}\n")
            f.write(f"  椭圆 R² = {ellipse_r_squared[i]:.6f}\n")
            f.write(f"  R²差异 = {abs(poly_r_squared[i] - ellipse_r_squared[i]):.6f}\n")
            if poly_r_squared[i] > ellipse_r_squared[i]:
                f.write(f"  多边形拟合效果更好\n")
            elif ellipse_r_squared[i] > poly_r_squared[i]:
                f.write(f"  椭圆拟合效果更好\n")
            else:
                f.write(f"  两种数据拟合效果相当\n")
            f.write("\n")
        
        # 统计摘要
        f.write("统计摘要\n")
        f.write("-" * 50 + "\n")
        f.write(f"多边形数据平均R²: {np.mean(poly_r_squared):.6f}\n")
        f.write(f"椭圆数据平均R²: {np.mean(ellipse_r_squared):.6f}\n")
        f.write(f"多边形数据R²标准差: {np.std(poly_r_squared):.6f}\n")
        f.write(f"椭圆数据R²标准差: {np.std(ellipse_r_squared):.6f}\n")
        f.write(f"多边形数据平均残差平方和: {np.mean(poly_resnorm):.6f}\n")
        f.write(f"椭圆数据平均残差平方和: {np.mean(ellipse_resnorm):.6f}\n")
        
        f.write("\n" + "=" * 80 + "\n")
        f.write("报告结束\n")
    
    print(f"\n拟合结果已保存到文件: {filename}")
    print(f"文件包含所有拟合参数、残差、R²值等详细信息")

def main():
    # 读取属性文件
    with open('properties.json', 'r', encoding='utf-8') as f:
        prop = json.load(f)
    
    # 获取当前脚本所在目录
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 读取数据文件
    nonellipse_vp_path = os.path.join(current_dir, "..", "..", "..", "..", "isotropic_matrix", "n_20", "degree_90", "vp_polygonal.csv")
    ellipse_vp_path = os.path.join(current_dir, "..", "..", "..", "..", "isotropic_matrix", "n_20", "degree_90", "vp_ellipse.csv")
    
    nonellipse_de0_vp = pd.read_csv(nonellipse_vp_path, header=None).values
    ellipse_de0_vp = pd.read_csv(ellipse_vp_path, header=None).values
    
    cycle = 6
    
    # 初始猜测参数 - 针对不同组使用不同的初始值
    initial_params_list = [2071, 0.9, 66, 0.1]  # K和D参数相应放大
    
    # 存储拟合结果
    params_fit_all = []
    resnorm_all = []
    residual_all = []
    
    # 椭圆数据拟合结果
    ellipse_params_fit_all = []
    ellipse_resnorm_all = []
    ellipse_residual_all = []
    
    # 压力数据
    P = np.array(prop['P']) / 1e6  # 除以1,000,000转换为MPa
    
    # 执行多边形数据拟合
    print("=" * 50)
    print("开始拟合多边形数据")
    print("=" * 50)
    for i in range(cycle):
        vp = nonellipse_de0_vp[:, i]
        
        try:
            # 在拟合部分，调整参数边界
            popt, pcov = curve_fit(
                model_function, 
                P, 
                vp, 
                p0=initial_params_list,
                maxfev=20000,
                method='trf', 
                bounds=([0, 0, 0, 0], [1e6, 1e3, 1e6, 1e3])  # 调整上边界，K和D可以更大
            )
            
            # 计算拟合值
            vp_fit = model_function(P, *popt)
            
            # 计算残差和损失
            residual = vp - vp_fit
            resnorm = np.sum(residual**2)
            
            params_fit_all.append(popt)
            resnorm_all.append(resnorm)
            residual_all.append(residual)
            
            print(f"多边形组 {i+1} 拟合完成:")
            print(f"  A = {popt[0]:.9f}")
            print(f"  K = {popt[1]:.9f}")
            print(f"  B = {popt[2]:.9f}")
            print(f"  D = {popt[3]:.9f}")
            print(f"  残差平方和 = {resnorm:.6f}")
            print()
            
        except Exception as e:
            print(f"多边形组 {i+1} 拟合失败: {e}")
            # 使用初始参数作为备选
            params_fit_all.append(initial_params_list)
            resnorm_all.append(np.inf)
            residual_all.append(np.zeros_like(vp))
    
    # 执行椭圆数据拟合
    print("=" * 50)
    print("开始拟合椭圆数据")
    print("=" * 50)
    for i in range(cycle):
        vp = ellipse_de0_vp[:, i]
        
        try:
            # 在拟合部分，调整参数边界
            popt, pcov = curve_fit(
                model_function, 
                P, 
                vp, 
                p0=initial_params_list,
                maxfev=20000,
                method='trf', 
                bounds=([0, 0, 0, 0], [1e6, 1e3, 1e6, 1e3])  # 调整上边界，K和D可以更大
            )
            
            # 计算拟合值
            vp_fit = model_function(P, *popt)
            
            # 计算残差和损失
            residual = vp - vp_fit
            resnorm = np.sum(residual**2)
            
            ellipse_params_fit_all.append(popt)
            ellipse_resnorm_all.append(resnorm)
            ellipse_residual_all.append(residual)
            
            print(f"椭圆组 {i+1} 拟合完成:")
            print(f"  A = {popt[0]:.9f}")
            print(f"  K = {popt[1]:.9f}")
            print(f"  B = {popt[2]:.9f}")
            print(f"  D = {popt[3]:.9f}")
            print(f"  残差平方和 = {resnorm:.6f}")
            print()
            
        except Exception as e:
            print(f"椭圆组 {i+1} 拟合失败: {e}")
            # 使用初始参数作为备选
            ellipse_params_fit_all.append(initial_params_list)
            ellipse_resnorm_all.append(np.inf)
            ellipse_residual_all.append(np.zeros_like(vp))
    
    # 绘图
    indices = [0, 4, 3, 2, 1, 5]  # 对应MATLAB中的[1, 5, 4, 3, 2, 6]，转换为0-based索引
    titles = ['20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2']
    
    # 创建合并图形 - 椭圆和多边形数据在同一张图
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('多边形与椭圆数据 Stress-Vp 拟合结果对比', fontsize=16)
    
    # 绘制合并数据
    for group in range(cycle):
        row = group // 3
        col = group % 3
        ax = axes[row, col]
        
        # 获取对应索引的数据
        data_idx = indices[group]
        
        # 多边形数据
        poly_vp_data = nonellipse_de0_vp[:, data_idx]
        poly_vp_fit = model_function(P, *params_fit_all[indices[group]])
        
        # 椭圆数据
        ellipse_vp_data = ellipse_de0_vp[:, data_idx]
        ellipse_vp_fit = model_function(P, *ellipse_params_fit_all[indices[group]])
        
        # 绘制多边形数据
        ax.scatter(P[::3], poly_vp_data[::3], c='red', alpha=0.7, label='多边形数据', s=5, marker='o')
        ax.plot(P, poly_vp_fit, 'r-', linewidth=1.6, label='多边形拟合')
        
        # 绘制椭圆数据
        ax.scatter(P[::3], ellipse_vp_data[::3], c='blue', alpha=0.7, label='椭圆数据', s=5, marker='s')
        ax.plot(P, ellipse_vp_fit, 'b-', linewidth=1.6, label='椭圆拟合')
        
        # 设置图例
        ax.legend(loc='best', fontsize=8)
        
        # 添加参数信息作为文本 - 显示两种数据的参数（两位小数）
        poly_text = f'多边形:\nA={params_fit_all[group][0]:.2f}\nK={params_fit_all[group][1]:.2f}\nB={params_fit_all[group][2]:.2f}\nD={params_fit_all[group][3]:.2f}'
        ellipse_text = f'椭圆:\nA={ellipse_params_fit_all[group][0]:.2f}\nK={ellipse_params_fit_all[group][1]:.2f}\nB={ellipse_params_fit_all[group][2]:.2f}\nD={ellipse_params_fit_all[group][3]:.2f}'
        
        # 在左上角显示多边形参数
        ax.text(0.02, 0.98, poly_text, transform=ax.transAxes, 
                verticalalignment='top', fontsize=7, 
                bbox=dict(boxstyle='round', facecolor='lightcoral', alpha=0.8))
        
        # 在右上角显示椭圆参数
        ax.text(0.98, 0.98, ellipse_text, transform=ax.transAxes, 
                verticalalignment='top', horizontalalignment='right', fontsize=7,
                bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))
        
        # 设置标签和标题
        ax.set_xlabel('Uniaxial Stress (MPa)')
        ax.set_ylabel('v_p (m/s)')
        ax.set_title(titles[group])
        ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.show()
    
    # 计算并显示拟合优度，同时准备保存数据
    print("\n多边形数据拟合优度分析:")
    poly_r_squared_list = []
    ellipse_r_squared_list = []
    
    for i in range(cycle):
        data_idx = indices[i]
        vp_data = nonellipse_de0_vp[:, data_idx]
        vp_fit = model_function(P, *params_fit_all[i])
        
        # 计算R²
        ss_res = np.sum((vp_data - vp_fit)**2)
        ss_tot = np.sum((vp_data - np.mean(vp_data))**2)
        r_squared = 1 - (ss_res / ss_tot) if ss_tot != 0 else 0
        poly_r_squared_list.append(r_squared)
        
        print(f"多边形组 {i+1} ({titles[i]}): R² = {r_squared:.4f}")
    
    print("\n椭圆数据拟合优度分析:")
    for i in range(cycle):
        data_idx = indices[i]
        vp_data = ellipse_de0_vp[:, data_idx]
        vp_fit = model_function(P, *ellipse_params_fit_all[i])
        
        # 计算R²
        ss_res = np.sum((vp_data - vp_fit)**2)
        ss_tot = np.sum((vp_data - np.mean(vp_data))**2)
        r_squared = 1 - (ss_res / ss_tot) if ss_tot != 0 else 0
        ellipse_r_squared_list.append(r_squared)
        
        print(f"椭圆组 {i+1} ({titles[i]}): R² = {r_squared:.4f}")
    
    # 保存所有拟合相关参数到txt文件
    save_fit_results_to_file(params_fit_all, ellipse_params_fit_all, 
                            resnorm_all, ellipse_resnorm_all,
                            poly_r_squared_list, ellipse_r_squared_list,
                            titles, indices)

if __name__ == "__main__":
    main()