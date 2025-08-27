#!/bin/bash
set -euo pipefail

# ======================================================
# Fancy Daily Report generator for Gemini (macOS)
# - Spinner while generating
# - Typewriter effect when printing final markdown
# ======================================================

# ---------- Config ----------
GEMINI_API_KEY="${GEMINI_API_KEY:-}"
if [ -z "$GEMINI_API_KEY" ]; then
  echo "❌ GEMINI_API_KEY not set. Export GEMINI_API_KEY and try again."
  exit 1
fi

AUTHOR="$(git config user.name)"
SINCE="yesterday"
UNTIL="today"
OUTPUT_DIR="reports"
TMP_JSON="$(mktemp)"
TMP_RESPONSE="$(mktemp)"
# ----------------------------

# ---------- Colors ----------
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
BLUE="\033[34m"
CYAN="\033[36m"
# ----------------------------

cleanup() { rm -f "$TMP_JSON" "$TMP_RESPONSE"; }
trap cleanup EXIT

mask_key_preview() { printf "%s" "${GEMINI_API_KEY:0:6}********"; }

spinner() {
  local -a spin=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
  local i=0
  local pid=$1
  local msg="$2"
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r${BLUE}%s %s${RESET}" "${spin[i]}" "$msg"
    i=$(( (i + 1) % ${#spin[@]} ))
    sleep 0.12
  done
  printf "\r\033[K"
}

# ---------- Collect commits ----------
COMMITS=$(git log --since="$SINCE" --until="$UNTIL" --author="$AUTHOR" \
  --pretty=format:"%s" --date=short | grep -v '\[build\] \[apk\]' || true)

if [ -z "$COMMITS" ]; then
  echo -e "${YELLOW}⚠️  No commits found for ${SINCE} → ${UNTIL}.${RESET}"
  exit 0
fi

REPORT_DATE="$(date +"%d %B %Y")"

PROMPT="Rewrite the following commit messages into a clean Daily Report format for $REPORT_DATE.

Rules:
- Start with the title: Daily Report
- Use a bullet point character (•) followed by a space at the beginning of each line
- Each point should be short, clear, and professional
- Do NOT include commit prefixes like feat:, fix:, refactor:, etc.
- Keep the language simple and concise

Commit messages:
$COMMITS"

jq -n --arg text "$PROMPT" '{contents: [{parts: [{text: $text}]}]}' > "$TMP_JSON"

echo -e "${BOLD}🔐 Using GEMINI_API_KEY:${RESET} $(mask_key_preview)"

# ---------- API Call ----------
(
  curl -s -X POST \
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
    -H "Content-Type: application/json" \
    -d @"$TMP_JSON" > "$TMP_RESPONSE"
) &
CURL_PID=$!
spinner "$CURL_PID" "Generating Daily Report..."
wait "$CURL_PID"

GENERATED_TEXT=$(jq -r '.candidates[0].content.parts[0].text // empty' < "$TMP_RESPONSE")
if [ -z "$GENERATED_TEXT" ]; then
  echo -e "${RED}❌ Failed to get report from API.${RESET}"
  exit 1
fi

# ---------- Save & Clipboard ----------
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/daily_report_$(date +%Y-%m-%d).md"
echo "$GENERATED_TEXT" > "$OUTPUT_FILE"

if command -v pbcopy >/dev/null 2>&1; then
  echo -n "$GENERATED_TEXT" | pbcopy
  CLIP_MSG="${GREEN}📋 Report copied to clipboard.${RESET}"
else
  CLIP_MSG="${YELLOW}📋 pbcopy not found — saved to file only.${RESET}"
fi

echo -e "${GREEN}✅ Report saved to:${RESET} ${BOLD}${OUTPUT_FILE}${RESET}"
echo -e "$CLIP_MSG"

# ---------- Typewriter Effect ----------
echo -e "\n${CYAN}📄 Generated Daily Report:${RESET}\n"
while IFS= read -r line; do
  for ((i=0; i<${#line}; i++)); do
    printf "%s" "${line:$i:1}"
    sleep 0.015  # speed per char
  done
  printf "\n"
  sleep 0.05    # delay between lines
done <<< "$GENERATED_TEXT"

echo -e "\n${BOLD}✨ Done.${RESET}\n"
