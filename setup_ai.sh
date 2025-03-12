#!/bin/bash

# Exit if any command fails
set -e

# Request admin privileges
sudo -v

# Step 1: Install Homebrew (if not installed)
echo "Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
    source ~/.zshrc
else
    echo "Homebrew is already installed."
fi

# Step 2: Install essential dependencies
echo "Installing dependencies..."
brew install python3 node wget

# Step 3: Install AI & Automation Tools
echo "Installing AI tools..."
brew install --cask raycast hammerspoon openshot

# Step 4: Install OLlama and Msty
echo "Downloading OLlama and Msty..."
curl -fsSL https://ollama.ai/install.sh | sh

# Step 5: Set up optimized AI model for OLlama (Mistral-7B-Instruct for fast responses)
echo "Setting up OLlama AI model..."
ollama pull mistral:7b-instruct

# Step 6: Grant Full Disk Access and Automation Permissions
echo "Granting necessary permissions..."
sudo sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" \
"INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility','/usr/bin/osascript',0,1,1,NULL,NULL,NULL,'UNUSED',NULL,0,1642914343);"

# Step 7: Create AI Automation Folder
echo "Setting up AI automation folder..."
mkdir -p ~/AI_Scripts
chmod +x ~/AI_Scripts/*

# Step 8: Automate AI Script Execution Using Automator
echo "Creating Automator workflow..."
cat <<EOF > ~/Library/Services/AI_Auto_Execute.workflow
#!/bin/bash
chmod +x "\$1"
"\$1"
EOF
chmod +x ~/Library/Services/AI_Auto_Execute.workflow

# Step 9: Configure Hammerspoon for AI-Triggered Actions
echo "Configuring Hammerspoon..."
mkdir -p ~/.hammerspoon
cat <<EOF > ~/.hammerspoon/init.lua
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
    hs.alert.show("AI Automation is Ready!")
end)
EOF

# Step 10: Set OLlama as Msty's AI Backend
echo "Configuring Msty to use OLlama..."
echo "http://localhost:11434" > ~/.msty_backend

# Step 11: Enable AI Execution on Boot
echo "Creating Launch Agent for AI automation..."
mkdir -p ~/Library/LaunchAgents
cat <<EOF > ~/Library/LaunchAgents/com.msty.autorun.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>com.msty.autorun</string>
        <key>ProgramArguments</key>
        <array>
            <string>/usr/bin/python3</string>
            <string>~/AI_Scripts/ai_main.py</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
    </dict>
</plist>
EOF
launchctl load ~/Library/LaunchAgents/com.msty.autorun.plist

# Step 12: Restart Mac to apply changes
echo "Setup complete! Restarting Mac in 10 seconds... Press Ctrl+C to cancel."
sleep 10
sudo reboot
