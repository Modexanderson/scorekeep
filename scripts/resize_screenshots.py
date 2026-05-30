"""
Resize processed phone screenshots to App Store Connect required sizes.
Also generates iPad-sized screenshots from tablet captures.

App Store Connect requirements:
- iPhone 6.7" display: 1290 x 2796 px
- iPhone 6.5" display: 1242 x 2688 px (optional if 6.7" provided)
- iPad Pro 12.9" (3rd gen+): 2048 x 2732 px
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os
import sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
PROCESSED_DIR = os.path.join(PROJECT_DIR, "assets", "screenshots", "processed")
OUTPUT_DIR_67 = os.path.join(PROJECT_DIR, "assets", "screenshots", "appstore_6.7")
OUTPUT_DIR_65 = os.path.join(PROJECT_DIR, "assets", "screenshots", "appstore_6.5")

# App Store sizes
IPHONE_67 = (1290, 2796)
IPHONE_65 = (1242, 2688)


def get_dominant_edge_color(img, edge="top", sample_height=5):
    """Sample the dominant color from an edge of the image."""
    w, h = img.size
    if edge == "top":
        region = img.crop((0, 0, w, sample_height))
    else:
        region = img.crop((0, h - sample_height, w, h))

    # Get average color
    pixels = list(region.getdata())
    r = sum(p[0] for p in pixels) // len(pixels)
    g = sum(p[1] for p in pixels) // len(pixels)
    b = sum(p[2] for p in pixels) // len(pixels)
    a = sum(p[3] for p in pixels) // len(pixels) if len(pixels[0]) == 4 else 255
    return (r, g, b, a) if len(pixels[0]) == 4 else (r, g, b)


def create_gradient_background(size, top_color, bottom_color):
    """Create a vertical gradient background."""
    w, h = size
    img = Image.new("RGBA", size)
    draw = ImageDraw.Draw(img)

    for y in range(h):
        ratio = y / h
        r = int(top_color[0] + (bottom_color[0] - top_color[0]) * ratio)
        g = int(top_color[1] + (bottom_color[1] - top_color[1]) * ratio)
        b = int(top_color[2] + (bottom_color[2] - top_color[2]) * ratio)
        a = 255
        draw.line([(0, y), (w, y)], fill=(r, g, b, a))

    return img


def resize_for_appstore(input_path, output_path, target_size):
    """
    Resize a processed screenshot to App Store dimensions.
    Scales to fit width, then extends the gradient background top/bottom.
    """
    img = Image.open(input_path).convert("RGBA")
    src_w, src_h = img.size
    target_w, target_h = target_size

    # Scale to fit width
    scale = target_w / src_w
    new_w = target_w
    new_h = int(src_h * scale)

    scaled = img.resize((new_w, new_h), Image.LANCZOS)

    # Sample colors from edges for gradient background
    top_color = get_dominant_edge_color(scaled, "top", 10)
    bottom_color = get_dominant_edge_color(scaled, "bottom", 10)

    # Create gradient background at target size
    background = create_gradient_background(target_size, top_color, bottom_color)

    # Center the scaled image vertically (bias slightly toward top for text visibility)
    y_offset = (target_h - new_h) // 3  # Position 1/3 from top

    background.paste(scaled, (0, y_offset), scaled)

    # Save as RGB (App Store doesn't want transparency)
    background = background.convert("RGB")
    background.save(output_path, "PNG", optimize=True)
    print(f"  Created: {output_path} ({target_w}x{target_h})")


def process_phone_screenshots():
    """Process all 5 phone screenshots for both iPhone sizes."""
    for output_dir, size, label in [
        (OUTPUT_DIR_67, IPHONE_67, "6.7 inch"),
        (OUTPUT_DIR_65, IPHONE_65, "6.5 inch"),
    ]:
        os.makedirs(output_dir, exist_ok=True)
        print(f"\nProcessing for iPhone {label} ({size[0]}x{size[1]}):")

        for i in range(1, 6):
            input_path = os.path.join(PROCESSED_DIR, f"{i}.png")
            output_path = os.path.join(output_dir, f"{i}.png")

            if not os.path.exists(input_path):
                print(f"  WARNING: {input_path} not found, skipping")
                continue

            resize_for_appstore(input_path, output_path, size)

    print("\nDone! Phone screenshots ready for App Store Connect.")


if __name__ == "__main__":
    process_phone_screenshots()
