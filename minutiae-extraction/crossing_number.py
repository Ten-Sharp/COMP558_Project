from PIL import Image, ImageDraw
import utils
import argparse
import math
import os
import numpy as np

cells = [(-1, -1), (-1, 0), (-1, 1), (0, 1), (1, 1), (1, 0), (1, -1), (0, -1), (-1, -1)]

def minutiae_at(pixels, i, j):
    values = [pixels[i + k][j + l] for k, l in cells]

    crossings = 0
    for k in range(0, 8):
        crossings += abs(values[k] - values[k + 1])
    crossings /= 2

    if pixels[i][j] == 1:
        if crossings == 1:
            return "ending"
        if crossings == 3:
            return "bifurcation"
    return "none"

def calculate_minutiaes(im,mask):
    pixels = utils.load_image(im)
    utils.apply_to_each_pixel(pixels, lambda x: 0.0 if x > 10 else 1.0)

    print('sizes in minutia')
    print(im.size)
    print(mask.shape)

    (x, y) = im.size
    result = im.convert("RGB")

    draw = ImageDraw.Draw(result)
    colors = {"ending" : (150, 0, 0), "bifurcation" : (0, 150, 0)}
    ellipse_size = 2

    # Define a margin to avoid detecting minutiae at the extreme borders
    marginxr = 250
    marginxl = 300
    marginy = 145

    minutiae_coords = []
    # for i in range(marginxr, x- marginxl):
    #     for j in range(marginy, y - marginy):
    #         minutiae = minutiae_at(pixels, i, j)
    #         if minutiae != "none":
    #             # Optionally, you can also impose other criteria here 
    #             # to ensure it's truly a fingerprint-related minutia
    #             draw.ellipse(
    #                 [(i - ellipse_size, j - ellipse_size),
    #                  (i + ellipse_size, j + ellipse_size)],
    #                 outline=colors[minutiae]
    #             )
    #             minutiae_coords.append((i, j, minutiae))

    window_edge = 7
    for i in range(1, x - 1):
        for j in range(1, y - 1):
            if mask[i,j] == 1:
                top = max(0, i - window_edge)
                bottom = min(mask.shape[0], i + window_edge + 1)
                left = max(0, j - window_edge)
                right = min(mask.shape[1], j + window_edge + 1)

                window = mask[top:bottom, left:right]

                if np.any(window == 0):
                    minutiae = "none"
                else:
                    minutiae = minutiae_at(pixels, i, j)

                if minutiae != "none":
                    # Optionally, you can also impose other criteria here 
                    # to ensure it's truly a fingerprint-related minutia
                    draw.ellipse(
                        [(i - ellipse_size, j - ellipse_size),
                        (i + ellipse_size, j + ellipse_size)],
                        outline=colors[minutiae]
                    )
                    minutiae_coords.append((i, j, minutiae))

    del draw
    return result, minutiae_coords

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Minutiae detection using crossing number method")
    parser.add_argument("image", nargs=1, help="Skeleton image")
    parser.add_argument("--save", action='store_true', help="Save result image as src_minutiae.gif")
    args = parser.parse_args()

    im = Image.open(args.image[0])
    im = im.convert("L")  # convert to grayscale

    result, _ = calculate_minutiaes(im)
    result.show()

    if args.save:
        base_image_name = os.path.splitext(os.path.basename(args.image[0]))[0]
        result.save(base_image_name + "_minutiae.gif", "GIF")
