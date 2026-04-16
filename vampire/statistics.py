#!/usr/bin/env python3
"""
Vampire experiment-result statistics script.
Reports per-dataset unsat counts, average times, etc.
"""
import csv
from pathlib import Path

def analyze_csv_file(filepath, dataset_name):
    """Analyze a single CSV file"""
    path = Path(filepath)
    if not path.exists():
        print(f"\nFile not found: {filepath}")
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
    # Directory containing this script
    script_dir = Path(__file__).parent
    parent_dir = script_dir.parent
    
    files = [
        (script_dir / "results_20251204_121145_autoproof_default.csv", "autoproof"),
        (script_dir / "results_20251204_134755_dtt_default.csv", "dtt"),
        (script_dir / "results_20251204_141750_ind-ben_default.csv", "ind-ben"),
        (script_dir / "results_20251204_150533_vmcai15-dt_default.csv", "vmcai15-dt")
    ]
    
    print("=" * 70)
    print("Vampire experiment-result statistics (includes average times)")
    print("=" * 70)
    
    results = []
    for filepath, dataset_name in files:
        result = analyze_csv_file(filepath, dataset_name)
        if result:
            results.append(result)
            
            print(f"\nDataset: {result['dataset']}")
            print(f"  Total: {result['total']}")
            print(f"  All unsat: {result['unsat_all_count']}, average time: {result['unsat_all_avg']:.2f}s")
            print(f"  unsat < 360s: {result['unsat_360_count']}, average time: {result['unsat_360_avg']:.2f}s")
            print(f"  unsat < 1200s: {result['unsat_1200_count']}, average time: {result['unsat_1200_avg']:.2f}s")
    
    # Grand total
    if results:
        print("\n" + "=" * 70)
        print("Grand total:")
        
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
        
        print(f"  Total: {total_all}")
        print(f"  All unsat: {len(unsat_all_times_all)}, average time: {avg_all_total:.2f}s")
        print(f"  unsat < 360s: {len(unsat_360_times_all)}, average time: {avg_360_total:.2f}s")
        print(f"  unsat < 1200s: {len(unsat_1200_times_all)}, average time: {avg_1200_total:.2f}s")
        print("=" * 70)

if __name__ == "__main__":
    main()

