#!/data/data/com.termux/files/usr/bin/bash
# One-step Git conflict resolver and pusher for Niorlusx

set -e

echo "🛠 Resolving conflict in ngrok_auth_setup.sh..."
FILE="ngrok_auth_setup.sh"

# Automatically resolve common merge markers by keeping local version
if grep -q "<<<<<<<" "$FILE"; then
  awk '/^<<<<<<< HEAD$/{f=1; next} /^=======$/{f=0; next} /^>>>>>>> /{f=0; next} !f' "$FILE" > "$FILE.tmp"
  mv "$FILE.tmp" "$FILE"
  echo "✅ Conflict markers removed from $FILE"
else
  echo "ℹ️ No conflict markers found in $FILE"
fi

# Mark as resolved
git add "$FILE"

# Continue rebase
echo "🔄 Continuing rebase..."
git rebase --continue || {
  echo "❌ Rebase failed. Manual conflict may still exist."
  exit 1
}

# Push changes
echo "🚀 Pushing to GitHub..."
git config --global credential.helper store
git push origin main || {
  echo "❌ Push failed. Check authentication or try again."
  exit 1
}

echo "✅ All done! Your changes are now live on GitHub."
