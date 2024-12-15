from pathlib import Path
import cv2
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
from crossing_number import calculate_minutiaes
import os
import sys
from scipy.io import loadmat

def pointFeature_to_descriptor(map1,map2):
    freq_max = max(np.max(map1),np.max(map2))
    freq_min = min(np.min(map1),np.min(map2))

    denom = freq_max - freq_min

    map1 = map1 - freq_min
    map1 = map1 / denom
    map1 * 255.0

    map2 = map2 - freq_min
    map2 = map2 / denom
    map2 * 255.0

    return [map1,map2]

def adjust_orientations(ori_map1,mask1,ori_map2,mask2):
    orientations1 = ori_map1[mask1 == 1]
    orientations2 = ori_map2[mask2 == 1]

    ori_mean1 = np.mean(orientations1)
    ori_mean2 = np.mean(orientations2)

    ori_map2 = ori_map2 + (ori_mean1 - ori_mean2)
    
    return ori_map2

def get_minutia_type(minutia_list,kps):
    matching_points = [m for (x,y,m) in minutia_list 
                   for kp in kps 
                   if (x == kp.pt[0] and y == kp.pt[1])]
    
    matching_points = [0 if s == "ending" else 255 for s in matching_points]

    return np.array(matching_points)

def main():
    # parser = argparse.ArgumentParser()

    # parser.add_argument('-i',required=True,dest='f1',help='first fingerprint')
    # parser.add_argument('-ii',required=True,dest='f2',help='second fingerprint')

    # args = parser.parse_args()


    # image_path1 = os.path.abspath('fingerprints/101_7_enhanced.tif')
    # image_path2 = os.path.abspath('fingerprints/101_8_enhanced.tif')
    arg1 = sys.argv[1]
    arg2 = sys.argv[2]
    arg3 = sys.argv[3]
    arg4 = sys.argv[4]

    maps_path1 = Path(arg1).stem + '_maps.mat'
    maps_path2 = Path(arg2).stem + '_maps.mat'

    f1_data = loadmat(maps_path1)
    f2_data = loadmat(maps_path2)

    f1_ori = f1_data['ori_map']
    f1_freq = np.round(f1_data['freq_map'] * 100) /100
    f1_mask = f1_data['mask_map']

    f2_ori = f2_data['ori_map']
    f2_freq = np.round(f2_data['freq_map'] * 100) / 100
    f2_mask = f2_data['mask_map']

    img1 = cv2.imread(arg1, cv2.IMREAD_GRAYSCALE)
    img2 = cv2.imread(arg2, cv2.IMREAD_GRAYSCALE)
    img1_bin = cv2.imread(arg3, cv2.IMREAD_GRAYSCALE)
    img2_bin = cv2.imread(arg4, cv2.IMREAD_GRAYSCALE)


    if img1 is None or img2 is None:
        raise ValueError("Could not load one or both fingerprint images. Check file paths.")


    pil_img1 = Image.fromarray(img1)
    pil_img2 = Image.fromarray(img2)


    _, minutiae_list_1 = calculate_minutiaes(pil_img1,f1_mask)
    _, minutiae_list_2 = calculate_minutiaes(pil_img2,f2_mask)

    print('number of features in 1: ',len(minutiae_list_1))
    print('number of features in 2: ',len(minutiae_list_2))
    #transpose here
    f1_freq = f1_freq.T
    f1_ori = f2_ori.T
    f1_mask = f1_mask.T

    f2_freq = f2_freq.T
    f2_ori = f2_ori.T
    f2_mask = f2_mask.T

    kp1 = [cv2.KeyPoint(x=float(x), y=float(y), size=1) for (x, y, mtype) in minutiae_list_1]
    kp2 = [cv2.KeyPoint(x=float(x), y=float(y), size=1) for (x, y, mtype) in minutiae_list_2]

    orb = cv2.ORB_create()


    kps1, des1 = orb.compute(img1, kp1)
    kps2, des2 = orb.compute(img2, kp2)

    f2_ori = adjust_orientations(f1_ori,f1_mask,f2_ori,f2_mask)

    keypoint_freq_1 = [f1_freq[int(keypoint.pt[0]),int(keypoint.pt[1])] for keypoint in kps1]
    keypoint_freq_2 = [f2_freq[int(keypoint.pt[0]),int(keypoint.pt[1])] for keypoint in kps2]

    keypoint_ori_1 = [f1_ori[int(keypoint.pt[0]),int(keypoint.pt[1])] for keypoint in kps1]
    keypoint_ori_2 = [f2_ori[int(keypoint.pt[0]),int(keypoint.pt[1])] for keypoint in kps2]

    [frequencies_1,frequencies_2] = pointFeature_to_descriptor(keypoint_freq_1,keypoint_freq_2)
    [orientations_1,orientations_2] = pointFeature_to_descriptor(keypoint_ori_1,keypoint_ori_2)
    
    minutiae_types_1 = get_minutia_type(minutiae_list_1,kps1)
    minutiae_types_2 = get_minutia_type(minutiae_list_2,kps2)

    des1_with_freq = np.hstack([des1, frequencies_1[:, np.newaxis].astype(np.uint8),orientations_1[:, np.newaxis].astype(np.uint8),minutiae_types_1[:, np.newaxis].astype(np.uint8)])
    des2_with_freq = np.hstack([des2, frequencies_2[:, np.newaxis].astype(np.uint8),orientations_2[:, np.newaxis].astype(np.uint8),minutiae_types_2[:, np.newaxis].astype(np.uint8)])

    if des1 is None or des2 is None:
        raise ValueError("Could not compute descriptors at the given minutiae locations.")

    bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=False)
    matches = bf.knnMatch(des1_with_freq, des2_with_freq, k=2)

    good_matches = []
    ratio_thresh = 0.8
    for m, n in matches:
        if m.distance < ratio_thresh * n.distance:
            good_matches.append(m)

    print(f"\nNumber of good matches: {len(good_matches)}")

    points1 = np.float32([kps1[m.queryIdx].pt for m in good_matches])
    points2 = np.float32([kps2[m.trainIdx].pt for m in good_matches])

    # Compute homography
    homography_matrix, mask = cv2.findHomography(points1, points2, cv2.RANSAC, 5.0)
    homography_matrix_inverse = np.linalg.inv(homography_matrix)

    height, width = img1_bin.shape[:2]
    warped_image2 = cv2.warpPerspective(img2_bin, homography_matrix_inverse, (width, height))
    warped_mask2 = cv2.warpPerspective(f2_mask.astype(np.uint8), homography_matrix_inverse, (width, height))


    valid_mask = np.logical_and(f1_mask, warped_mask2).astype(np.uint8)

    print(np.unique(valid_mask))

    overlay_image = np.ones((img1_bin.shape[0], img1_bin.shape[1], 3), dtype=np.uint8) * 255  # White background

    # Apply red hue to areas where img1_bin has 255 (and warped_image2 has 0)
    overlay_image[(img1_bin == 0) & (warped_image2 == 255) & (valid_mask == 1)] = [255, 0, 0]  # Red for img1_bin

    # Apply blue hue to areas where warped_image2 has 255 (and img1_bin has 0)
    overlay_image[(warped_image2 == 0) & (img1_bin == 255) & (valid_mask == 1)] = [0, 0, 255]  # Blue for warped_image2

    # Apply black for overlapping areas where both images have 255
    overlay_image[(img1_bin == 0) & (warped_image2 == 0) & (valid_mask == 1)] = [0, 0, 0]

    plt.figure(figsize=(12, 6))
    plt.title('SIFT Matches Using Minutiae as Feature Points')
    plt.imshow(overlay_image)
    plt.axis('off')
    plt.show()

    img1_bin = img1_bin.astype(np.uint8) // 255
    warped_image2 = warped_image2.astype(np.uint8) // 255

    print(np.unique(img1_bin))
    print(np.unique(warped_image2))

    difference = np.abs(img1_bin - warped_image2)
    difference[difference == 255] = 1
    print(np.unique(difference))

    difference_valid = difference * (valid_mask)

    print(np.sum(valid_mask))
    print(np.sum(difference_valid))

    total_diff = 1 - (np.sum(difference_valid) / np.sum((valid_mask)))
    print(total_diff)
    if total_diff >= 0.6:
        print('\nFINGERPRINT MATCH')
    else:
        print('\nNO MATCH')

    NUM_TO_DRAW = min(len(good_matches), 100)
    matches_to_draw = good_matches[:NUM_TO_DRAW]

    matched_img = cv2.drawMatches(img1, kp1, img2, kp2, matches_to_draw, None,
                                flags=cv2.DrawMatchesFlags_NOT_DRAW_SINGLE_POINTS)

    matched_img_rgb = cv2.cvtColor(matched_img, cv2.COLOR_BGR2RGB)

    plt.figure(figsize=(12, 6))
    plt.title('SIFT Matches Using Minutiae as Feature Points')
    plt.imshow(matched_img_rgb)
    plt.axis('off')
    plt.show()

if __name__ == "__main__":
    main()