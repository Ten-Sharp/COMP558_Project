import cv2
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
from crossing_number import calculate_minutiaes
import os

image_path1 = os.path.abspath('fingerprints/101_7_enhanced.tif')
image_path2 = os.path.abspath('fingerprints/101_8_enhanced.tif')


img1 = cv2.imread(image_path1, cv2.IMREAD_GRAYSCALE)
img2 = cv2.imread(image_path2, cv2.IMREAD_GRAYSCALE)

if img1 is None or img2 is None:
    raise ValueError("Could not load one or both fingerprint images. Check file paths.")


pil_img1 = Image.fromarray(img1)
pil_img2 = Image.fromarray(img2)


_, minutiae_list_1 = calculate_minutiaes(pil_img1)
_, minutiae_list_2 = calculate_minutiaes(pil_img2)




kp1 = [cv2.KeyPoint(x=float(x), y=float(y), size=1) for (x, y, mtype) in minutiae_list_1]
kp2 = [cv2.KeyPoint(x=float(x), y=float(y), size=1) for (x, y, mtype) in minutiae_list_2]


sift = cv2.SIFT_create()


_, des1 = sift.compute(img1, kp1)
_, des2 = sift.compute(img2, kp2)

if des1 is None or des2 is None:
    raise ValueError("Could not compute descriptors at the given minutiae locations.")

bf = cv2.BFMatcher(cv2.NORM_L2, crossCheck=False)
matches = bf.knnMatch(des1, des2, k=2)

good_matches = []
ratio_thresh = 0.75
for m, n in matches:
    if m.distance < ratio_thresh * n.distance:
        good_matches.append(m)

print(f"\nNumber of good matches: {len(good_matches)}")


NUM_TO_DRAW = min(len(good_matches), 50)
matches_to_draw = good_matches[:NUM_TO_DRAW]

matched_img = cv2.drawMatches(img1, kp1, img2, kp2, matches_to_draw, None,
                              flags=cv2.DrawMatchesFlags_NOT_DRAW_SINGLE_POINTS)

matched_img_rgb = cv2.cvtColor(matched_img, cv2.COLOR_BGR2RGB)

plt.figure(figsize=(12, 6))
plt.title('SIFT Matches Using Minutiae as Feature Points')
plt.imshow(matched_img_rgb)
plt.axis('off')
plt.show()