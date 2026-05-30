"""
Process iPad/tablet screenshots for App Store Connect.

Takes raw tablet screenshots and adds:
- Gradient background matching the phone screenshot style
- Bold text headers (same captions as phone screenshots)
- Tablet device frame (rounded corners)
- Proper App Store iPad dimensions: 2048 x 2732 px (12.9" iPad Pro)

Usage:
  1. Take 5 screenshots from the Android tablet emulator
  2. Name them 1.png through 5.png
  3. Place them in assets/screenshots/tablet_raw/
  4. Run: python scripts/process_ipad_screenshots.py
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os
import math

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
TABLET_RAW_DIR = os.path.join(PROJECT_DIR, "assets", "screenshots", "tablet_raw")
OUTPUT_DIR = os.path.join(PROJECT_DIR, "assets", "screenshots", "appstore_ipad")
FONT_DIR = os.path.join(PROJECT_DIR, "assets", "fonts")

# App Store iPad Pro 12.9" (3rd gen and later)
IPAD_SIZE = (2048, 2732)

# Screenshot captions (matching phone screenshots)
CAPTIONS = {
    "1.png": ("Track Every", "Game Night"),
    "2.png": ("Live Score", "Tracking Made\nSimple"),
    "3.png": ("Never Lose\nTrack", "of Epic Moments"),
    "4.png": ("Set Up Any\nGame", "in Seconds"),
    "5.png": ("Add Scores", "Your Way"),
}

# Colors matching the phone screenshot style
BG_TOP_COLOR = (248, 248, 255)       # Near-white with slight blue tint
BG_BOTTOM_COLOR = (200, 230, 240)    # Light cyan/teal
BOLD_TEXT_COLOR = (30, 30, 60)       # Dark navy for bold text
SUBTITLE_COLOR = (60, 60, 100)      # Slightly lighter for subtitle


def create_gradient_background(size, top_color, bottom_color):
    """Create a vertical gradient background."""
    w, h = size
    img = Image.new("RGB", size)
    draw = ImageDraw.Draw(img)
    for y in range(h):
        ratio = y / h
        r = int(top_color[0] + (bottom_color[0] - top_color[0]) * ratio)
        g = int(top_color[1] + (bottom_color[1] - top_color[1]) * ratio)
        b = int(top_color[2] + (bottom_color[2] - top_color[2]) * ratio)
        draw.line([(0, y), (w, y)], fill=(r, g, b))
    return img


def add_rounded_corners(img, radius):
    """Add rounded corners to an image using an alpha mask."""
    img = img.convert("RGBA")
    w, h = img.size
    mask = Image.new("L", (w, h), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), (w, h)], radius=radius, fill=255)
    img.putalpha(mask)
    return img


def add_device_shadow(background, device_pos, device_size, shadow_offset=15, shadow_blur=30):
    """Add a subtle drop shadow behind the device frame."""
    shadow = Image.new("RGBA", background.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(shadow)
    sx = device_pos[0] + shadow_offset
    sy = device_pos[1] + shadow_offset
    draw.rounded_rectangle(
        [(sx, sy), (sx + device_size[0], sy + device_size[1])],
        radius=40,
        fill=(0, 0, 0, 40),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=shadow_blur))

    bg_rgba = background.convert("RGBA")
    composite = Image.alpha_composite(bg_rgba, shadow)
    return composite.convert("RGB")


def load_font(bold=True, size=80):
    """Load Orbitron font or fallback."""
    font_file = "Orbitron-Bold.ttf" if bold else "Orbitron-Regular.ttf"
    font_path = os.path.join(FONT_DIR, font_file)
    try:
        return ImageFont.truetype(font_path, size)
    except (IOError, OSError):
        # Fallback to system font
        try:
            return ImageFont.truetype("arial.ttf", size)
        except (IOError, OSError):
            return ImageFont.load_default()


def draw_centered_text(draw, text, y, font, fill, canvas_width):
    """Draw text centered horizontally."""
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    x = (canvas_width - text_width) // 2
    draw.text((x, y), text, font=font, fill=fill)
    return bbox[3] - bbox[1]  # Return text height


def process_tablet_screenshot(raw_path, output_path, caption_bold, caption_light):
    """Process a single tablet screenshot into App Store format."""
    target_w, target_h = IPAD_SIZE

    # Create gradient background
    background = create_gradient_background(IPAD_SIZE, BG_TOP_COLOR, BG_BOTTOM_COLOR)

    # Load fonts
    bold_font = load_font(bold=True, size=90)
    light_font = load_font(bold=False, size=70)

    draw = ImageDraw.Draw(background)

    # Draw caption text at the top
    text_y = 80
    for line in caption_bold.split("\n"):
        h = draw_centered_text(draw, line, text_y, bold_font, BOLD_TEXT_COLOR, target_w)
        text_y += h + 10

    text_y += 5
    for line in caption_light.split("\n"):
        h = draw_centered_text(draw, line, text_y, light_font, SUBTITLE_COLOR, target_w)
        text_y += h + 8

    # Load and process the raw tablet screenshot
    raw_img = Image.open(raw_path).convert("RGBA")
    raw_w, raw_h = raw_img.size

    # Calculate device frame area (below the text, centered, with padding)
    device_top = text_y + 50
    device_bottom = target_h - 60  # Some bottom padding
    available_height = device_bottom - device_top
    available_width = target_w - 160  # Side padding

    # Scale the raw screenshot to fit within the available area
    scale_w = available_width / raw_w
    scale_h = available_height / raw_h
    scale = min(scale_w, scale_h)

    new_w = int(raw_w * scale)
    new_h = int(raw_h * scale)

    resized = raw_img.resize((new_w, new_h), Image.LANCZOS)

    # Add rounded corners to simulate tablet device frame
    corner_radius = int(min(new_w, new_h) * 0.03)
    resized = add_rounded_corners(resized, corner_radius)

    # Center the device screenshot
    device_x = (target_w - new_w) // 2
    device_y = device_top + (available_height - new_h) // 3  # Slightly biased upward

    # Add shadow
    background = add_device_shadow(background, (device_x, device_y), (new_w, new_h))

    # Paste the screenshot
    background_rgba = background.convert("RGBA")
    background_rgba.paste(resized, (device_x, device_y), resized)

    # Save as RGB
    final = background_rgba.convert("RGB")
    final.save(output_path, "PNG", optimize=True)
    print(f"  Created: {output_path} ({target_w}x{target_h})")


def main():
    os.makedirs(TABLET_RAW_DIR, exist_ok=True)
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Check if raw screenshots exist
    raw_files = [f for f in os.listdir(TABLET_RAW_DIR) if f.endswith(".png")] if os.path.exists(TABLET_RAW_DIR) else []

    if not raw_files:
        print(f"No raw tablet screenshots found in: {TABLET_RAW_DIR}")
        print(f"\nPlease:")
        print(f"  1. Run the app on your Android tablet emulator (demo data is seeded)")
        print(f"  2. Take 5 screenshots matching the phone screenshots")
        print(f"  3. Name them 1.png through 5.png")
        print(f"  4. Place them in: {TABLET_RAW_DIR}")
        print(f"  5. Run this script again")
        return

    print(f"Processing iPad screenshots ({IPAD_SIZE[0]}x{IPAD_SIZE[1]}):")

    for filename, (bold_text, light_text) in CAPTIONS.items():
        raw_path = os.path.join(TABLET_RAW_DIR, filename)
        output_path = os.path.join(OUTPUT_DIR, filename)

        if not os.path.exists(raw_path):
            print(f"  WARNING: {raw_path} not found, skipping")
            continue

        process_tablet_screenshot(raw_path, output_path, bold_text, light_text)

    print(f"\nDone! iPad screenshots saved to: {OUTPUT_DIR}")


if __name__ == "__main__":
    main()
