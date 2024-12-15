import subprocess
import sys
import argparse 
from pathlib import Path
import os

def main():
    arg1 = sys.argv[1]
    arg2 = sys.argv[2]
    # Define arguments for the MATLAB script
    matlab_script = "enhance_test.m"  # MATLAB script name (without .m)
    matlab_arg1 = "Hello"
    matlab_arg2 = "World"

    path1 = Path(arg1)
    path2 = Path(arg2)
    # Define arguments for the Python script
    python_script = "./minutiae-extraction/sift_compare.py"
    enhanced_1 = f"{path1.stem}{'_enhanced'}{path1.suffix}"
    enhanced_2 = f"{path2.stem}{'_enhanced'}{path2.suffix}"

    try:
        subprocess.run(
            ["matlab", "-batch", f"addpath(''); enhance_test('{arg1}', '{arg2}')"], 
            check=True
        )
        # subprocess.run(
        #     [
        #         "matlab", 
        #         "-batch", 
        #         f"{matlab_script}('{args.f1}', '{args.f2}')"
        #     ], 
        #     check=True
        # )

        subprocess.run(
            [sys.executable, python_script, enhanced_1, enhanced_2], 
            check=True
        )


    except subprocess.CalledProcessError as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()