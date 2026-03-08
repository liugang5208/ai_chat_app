from PIL import Image

img = Image.open('ui-images/mine.jpg')

# Avatar analysis:
# Width: 265 to 562 -> width = 297, center_x = 413.5
# If we assume it's a circle, the height should also be ~297.
# center_y is around 413.
# Fine-tune: reduce top by 1px and right side by 3px from previous crop.
# x1 = 261
# x2 = 577
# y1 = 217
# y2 = 533

img.crop((261, 217, 577, 533)).save('assets/mine_user_avatar.png')
print("Saved avatar with tuned crop (316x316)")

# Favorite icon (center 89.5, 802.5 from previous analysis)
# Let's use r=40 to be tighter and avoid text/borders
img.crop((89.5-40, 802.5-40, 89.5+40, 802.5+40)).save('assets/mine_favorite_icon.png')
print("Saved favorite icon with r=40")
