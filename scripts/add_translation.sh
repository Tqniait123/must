#!/bin/bash

# Get field key, English and Arabic translations from command line arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 field_key english_translation arabic_translation"
    exit 1
fi

FIELD_KEY=$1
ENGLISH_TRANSLATION=$2
ARABIC_TRANSLATION=$3

EN_FILE="/Users/mahmoud/Desktop/Projects/four_pets/assets/translations/en.json"
AR_FILE="/Users/mahmoud/Desktop/Projects/four_pets/assets/translations/ar.json"

# Function to add the new field to a JSON file
add_to_json() {
    local file=$1
    local key=$2
    local value=$3
    
    # Get file content
    local content=$(cat "$file")
    
    # Remove last curly brace and any whitespace before it
    local content_without_last_brace=$(echo "$content" | sed 's/}\s*$//')
    
    # Check if we need to add a comma (if the file doesn't end with an opening brace or comma)
    if [[ $(echo "$content_without_last_brace" | sed 's/.*\(.\)$/\1/') != "{" && $(echo "$content_without_last_brace" | sed 's/.*\(.\)$/\1/') != "," ]]; then
        content_without_last_brace="$content_without_last_brace,"
    fi
    
    # Add new field and closing brace
    echo "$content_without_last_brace" > "$file"
    echo "  \"$key\": \"$value\"" >> "$file"
    echo "}" >> "$file"
    
    echo "Added '$key' to $(basename $file)"
}

# Add translations to both files
add_to_json "$EN_FILE" "$FIELD_KEY" "$ENGLISH_TRANSLATION"
add_to_json "$AR_FILE" "$FIELD_KEY" "$ARABIC_TRANSLATION"

echo "Translations added successfully!"
