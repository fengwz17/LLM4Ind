#!/usr/bin/env python3
"""
Vampire 实验结果统计脚本
统计每个数据集的unsat数量、平均时间等信息
"""
import csv
from pathlib import Path

def analyze_csv_file(filepath, dataset_name):
    """分析单个CSV文件"""
    path = Path(filepath)
    if not path.exists():
        print(f"\n文件不存在: {filepath}")
        return None
    
    total = 0
    unsat_all_times = []
    unsat_360_times = []
    unsat_1200_times = []
    
    with open(path, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        for row in reader:
            if len(row) < 3:
                continue
            result = row[1].strip() if len(row) > 1 else ""
            time_str = row[2].strip() if len(row) > 2 else ""
            
            total += 1
            
            if result == "unsat":
                try:
                    time_val = float(time_str)
                    unsat_all_times.append(time_val)
                    if time_val < 360:
                        unsat_360_times.append(time_val)
                    if time_val < 1200:
                        unsat_1200_times.append(time_val)
                except (ValueError, TypeError):
                    pass
    
    avg_all = sum(unsat_all_times) / len(unsat_all_times) if unsat_all_times else 0
    avg_360 = sum(unsat_360_times) / len(unsat_360_times) if unsat_360_times else 0
    avg_1200 = sum(unsat_1200_times) / len(unsat_1200_times) if unsat_1200_times else 0
    
    return {
        'dataset': dataset_name,
        'total': total,
        'unsat_all_count': len(unsat_all_times),
        'unsat_all_avg': avg_all,
        'unsat_360_count': len(unsat_360_times),
        'unsat_360_avg': avg_360,
        'unsat_1200_count': len(unsat_1200_times),
        'unsat_1200_avg': avg_1200,
        'unsat_all_times': unsat_all_times,
        'unsat_360_times': unsat_360_times,
        'unsat_1200_times': unsat_1200_times
    }

def main():
    # 获取脚本所在目录
    script_dir = Path(__file__).parent
    parent_dir = script_dir.parent
    
    files = [
        (script_dir / "results_20251204_121145_autoproof_default.csv", "autoproof"),
        (script_dir / "results_20251204_134755_dtt_default.csv", "dtt"),
        (script_dir / "results_20251204_141750_ind-ben_default.csv", "ind-ben"),
        (script_dir / "results_20251204_150533_vmcai15-dt_default.csv", "vmcai15-dt")
    ]
    
    print("=" * 70)
    print("Vampire 实验结果统计（包含平均时间）")
    print("=" * 70)
    
    results = []
    for filepath, dataset_name in files:
        result = analyze_csv_file(filepath, dataset_name)
        if result:
            results.append(result)
            
            print(f"\n数据集: {result['dataset']}")
            print(f"  总数: {result['total']}")
            print(f"  所有 unsat: {result['unsat_all_count']} 个, 平均时间: {result['unsat_all_avg']:.2f}s")
            print(f"  unsat < 360s: {result['unsat_360_count']} 个, 平均时间: {result['unsat_360_avg']:.2f}s")
            print(f"  unsat < 1200s: {result['unsat_1200_count']} 个, 平均时间: {result['unsat_1200_avg']:.2f}s")
    
    # 总计
    if results:
        print("\n" + "=" * 70)
        print("总计:")
        
        total_all = sum(r['total'] for r in results)
        unsat_all_times_all = []
        unsat_360_times_all = []
        unsat_1200_times_all = []
        
        for r in results:
            unsat_all_times_all.extend(r['unsat_all_times'])
            unsat_360_times_all.extend(r['unsat_360_times'])
            unsat_1200_times_all.extend(r['unsat_1200_times'])
        
        avg_all_total = sum(unsat_all_times_all) / len(unsat_all_times_all) if unsat_all_times_all else 0
        avg_360_total = sum(unsat_360_times_all) / len(unsat_360_times_all) if unsat_360_times_all else 0
        avg_1200_total = sum(unsat_1200_times_all) / len(unsat_1200_times_all) if unsat_1200_times_all else 0
        
        print(f"  总数: {total_all}")
        print(f"  所有 unsat: {len(unsat_all_times_all)} 个, 平均时间: {avg_all_total:.2f}s")
        print(f"  unsat < 360s: {len(unsat_360_times_all)} 个, 平均时间: {avg_360_total:.2f}s")
        print(f"  unsat < 1200s: {len(unsat_1200_times_all)} 个, 平均时间: {avg_1200_total:.2f}s")
        print("=" * 70)

if __name__ == "__main__":
    main()

