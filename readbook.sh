#!/bin/bash

# Directory to search
BOOK_DIR="$HOME/Documents"

# Find all supported book types recursively
BOOK=$(find "$BOOK_DIR" \
  -type f \( -iname "*.pdf" -o -iname "*.epub" -o -iname "*.mobi" -o -iname "*.djvu" \) 2>/dev/null \
  | rofi -dmenu -i -p "📚 Select a book")

# Launch KOReader if a selection was made
if [[ -n "$BOOK" ]]; then
    koreader "$BOOK" &
else
    notify-send "KOReader" "No book selected."
fi
