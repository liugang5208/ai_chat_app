from PIL import Image

img = Image.open('ui-images/mine.jpg')

# 1. Avatar (center 413.5, 413, range 227-599, width 265-562)
# Radius should be ~150-170
img.crop((263, 225, 564, 601)).save('assets/mine_user_avatar.png')
print("Saved avatar")

# 2. Settings icon
# Original script found 676-805, 50-199. This is quite big.
# Let's crop smaller around center 740, 124
img.crop((740-40, 124-40, 740+40, 124+40)).save('assets/mine_settings_icon.png')
print("Saved settings icon")

# 3. Favorite icon
# Found area 68-111, 780-825.
# Let's crop square around center 89, 802
img.crop((89.5-44, 802.5-44, 89.5+44, 802.5+44)).save('assets/mine_favorite_icon.png')
print("Saved favorite icon")
