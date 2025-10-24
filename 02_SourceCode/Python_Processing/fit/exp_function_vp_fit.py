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

def main():
    # 读取属性文件
    with open('properties.json', 'r', encoding='utf-8') as f:
        prop = json.load(f)
    
    # 获取当前脚本所在目录
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 读取数据文件
    nonellipse_vp_path = os.path.join(current_dir, "..", "..", "..", "isotropic_matrix", "n_20", "degree_90", "vp_polygonal.csv")
    nonellipse_de0_vp = pd.read_csv(nonellipse_vp_path, header=None).values
    
    cycle = 6
    
    # 初始猜测参数
    initial_params = [2071, 0.0000009, 66, 0.0000001]
    
    # 存储拟合结果
    params_fit_all = []
    resnorm_all = []
    residual_all = []
    
    # 压力数据
    P = np.array(prop['P'])
    
    # 执行拟合
    for i in range(cycle):
        vp = nonellipse_de0_vp[:, i]
        
        try:
            # 使用curve_fit进行非线性最小二乘拟合
            popt, pcov = curve_fit(
                model_function, 
                P, 
                vp, 
                p0=initial_params,
                maxfev=10000,
                method='lm'  # Levenberg-Marquardt算法
            )
            
            # 计算拟合值
            vp_fit = model_function(P, *popt)
            
            # 计算残差和损失
            residual = vp - vp_fit
            resnorm = np.sum(residual**2)
            
            params_fit_all.append(popt)
            resnorm_all.append(resnorm)
            residual_all.append(residual)
            
            print(f"组 {i+1} 拟合完成:")
            print(f"  A = {popt[0]:.9f}")
            print(f"  K = {popt[1]:.9f}")
            print(f"  B = {popt[2]:.9f}")
            print(f"  D = {popt[3]:.9f}")
            print(f"  残差平方和 = {resnorm:.6f}")
            print()
            
        except Exception as e:
            print(f"组 {i+1} 拟合失败: {e}")
            params_fit_all.append(initial_params)
            resnorm_all.append(np.inf)
            residual_all.append(np.zeros_like(vp))
    
    # 绘图
    indices = [0, 4, 3, 2, 1, 5]  # 对应MATLAB中的[1, 5, 4, 3, 2, 6]，转换为0-based索引
    titles = ['20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2']
    
    # 创建图形
    fig, axes = plt.subplots(2, 3, figsize=(20, 12))
    fig.suptitle('Stress-Vp 拟合结果', fontsize=16)
    
    for group in range(cycle):
        row = group // 3
        col = group % 3
        ax = axes[row, col]
        
        # 获取对应索引的数据
        data_idx = indices[group]
        vp_data = nonellipse_de0_vp[:, data_idx]
        vp_fit = model_function(P, *params_fit_all[group])
        
        # 绘制原始数据和拟合曲线
        ax.plot(P, vp_data, 'r-', linewidth=1.6, label='原始数据')
        ax.plot(P, vp_fit, 'b-', linewidth=1.6, label='拟合曲线')
        
        # 设置图例
        legend_text = f'A = {params_fit_all[group][0]:.9f}\nK = {params_fit_all[group][1]:.9f}\nB = {params_fit_all[group][2]:.9f}\nD = {params_fit_all[group][3]:.9f}'
        ax.legend([legend_text], loc='best', fontsize=8)
        
        # 设置标签和标题
        ax.set_xlabel('Uniaxial Stress (Pa)')
        ax.set_ylabel('v_p (m/s)')
        ax.set_title(titles[group])
        ax.grid(True)
        ax.box(True)
    
    plt.tight_layout()
    plt.show()
    
    # 计算并显示拟合优度
    print("\n拟合优度分析:")
    for i in range(cycle):
        data_idx = indices[i]
        vp_data = nonellipse_de0_vp[:, data_idx]
        vp_fit = model_function(P, *params_fit_all[i])
        
        # 计算R²
        ss_res = np.sum((vp_data - vp_fit)**2)
        ss_tot = np.sum((vp_data - np.mean(vp_data))**2)
        r_squared = 1 - (ss_res / ss_tot) if ss_tot != 0 else 0
        
        print(f"组 {i+1} ({titles[i]}): R² = {r_squared:.4f}")

if __name__ == "__main__":
    main()