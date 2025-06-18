# 1️⃣  Drop the files in repo root
nano ai_service.py      # paste the earlier skeleton
nano config.py          # minimal secret loader

# 2️⃣  Stage & commit
git add ai_service.py config.py
git commit -m "Add Flask AI voice service & config loader"
git push origin main

# 3️⃣  (Optional) add Procfile / deploy.sh then push again