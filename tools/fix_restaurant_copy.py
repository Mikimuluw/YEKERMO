# One-off fix: replace typo "not't" (with Unicode apostrophe) with "not"
import pathlib
path = pathlib.Path('lib/features/restaurant/restaurant_screen.dart')
text = path.read_text(encoding='utf-8')
old = "This menu is not\u2019t available right now."
new = "This menu is not available right now."
if old in text:
    path.write_text(text.replace(old, new), encoding='utf-8')
    print('Fixed')
else:
    print('Pattern not found')
