import random
import time
import sys
import subprocess
import sys
import argparse 
from pathlib import Path
import os
import time
import re
import matplotlib.pyplot as plt
import numpy as np

def generate_random_finger():
    num = random.randint(1, 10)  # Generate a random number between 1 and 10
    if num < 10:
        return f"0{num}"  # Format as 0X for single digits
    return str(num)

def generate_random_subfinger():
    num = random.randint(1, 8)
    return str(num)

def main():
    start_time = time.time()
    arg1 = int(sys.argv[1])

   
    # Define arguments for the Python script
    python_script = ".\\fingerprint_matcher.py"
    
    actual_matches = 0
    actual_non_matches = 0

    matches = 0
    non_mathces = 0
    false_positive = 0
    false_negative = 0
    errors = 0
    times = []

    match_pairs = []
    false_pos_pairs = []
    false_neg_pairs = []
    error_pairs = []


    for run in range(arg1):
        finger1 = generate_random_finger()
        finger2 = generate_random_finger()

        if finger1 == finger2:
            actual_matches += 1
        else:
            actual_non_matches += 1

        subfinger1 = generate_random_subfinger()
        subfinger2 = generate_random_subfinger()
        while subfinger1 == subfinger2:
            subfinger2 = generate_random_subfinger()

        
        fingerprint1 = f"1{finger1}_{subfinger1}.tif"
        fingerprint2 = f"1{finger2}_{subfinger2}.tif"

        print(fingerprint1)
        print(fingerprint2)

        
        result = subprocess.run(
            [sys.executable, python_script, fingerprint1,fingerprint2], 
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )

        # except subprocess.CalledProcessError as e:
        #     print(f"An error occurred: {e}")
        
        
        output = result.stdout.decode()
        match_time = re.split(r'[ ,\n\r]+', output.strip())

        print(match_time)

        if match_time[0] == "ERROR":
            error_pairs.append((fingerprint1,fingerprint2))
            errors += 1
            continue

        times.append(float(match_time[1]))

        if match_time[0] == "MATCH":
            if finger1 == finger2:
                match_pairs.append((fingerprint1,fingerprint2))
                matches += 1
            else:
                false_pos_pairs.append((fingerprint1,fingerprint2))
                false_positive += 1
        else:
            if finger1 == finger2:
                false_neg_pairs.append((fingerprint1,fingerprint2))
                false_negative += 1
            else:
                non_mathces += 1

    columns = ['Matches', 'Non-matches', 'False Positives', 'False Negatives', 'Average Time']
    data = [
        [matches, non_mathces, false_positive, false_negative, np.mean(times)]  # A single row with the respective values
    ]
    
    fig, ax = plt.subplots(figsize=(8, 2))  # You can adjust the figure size

    # Hide the axes
    ax.axis('off')

    # Create the table
    table = ax.table(cellText=data, colLabels=columns, loc='center', cellLoc='center', colColours=['#f5f5f5']*5)

    # Adjust table appearance (you can customize this further)
    table.auto_set_font_size(False)
    table.set_fontsize(12)
    table.auto_set_column_width(col=list(range(len(columns))))

    # Show the table
    plt.show()

    print('mathces:',match_pairs)
    print('false pos:',false_pos_pairs)
    print('false neg:',false_neg_pairs)
    print('errs:',error_pairs)

if __name__ == "__main__":
    main()