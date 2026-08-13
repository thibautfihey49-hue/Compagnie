#!/bin/bash
set -euo pipefail

echo "🤖 1/5 : Import des ressources"
timeout 120 godot --headless --path . --import >/dev/null 2>&1 || true

echo "✅ Vérification des fichiers..."
test -f project.godot && test -f scenes/main.tscn && test -f scenes/animal.tscn && test -f scenes/ui.tscn
echo "✅ Tous fichiers présents"

echo "🤖 2/5 : Création du keystore PKCS12"
rm -f compagnie.keystore
keytool -genkeypair -noprompt -alias compagnie -dname "CN=Compagnie 3D, O=Compagnie, C=FR" \
  -keyalg RSA -keysize 2048 -validity 10000 -keystore compagnie.keystore \
  -storetype PKCS12 -storepass "azerty123" -keypass "azerty123"
echo "✅ Keystore créé"

echo "🤖 3/5 : Création export_presets.cfg (Godot 4.3)"
cat > export_presets.cfg << 'CFG'
[preset.0]
name="Android"
platform="Android"
runnable=true
export_filter="all"
export_path="Compagnie3D.apk"

[preset.0.options]
package/name="Compagnie 3D"
package/unique_name="fr.compagnie3d.app"
package/min_sdk=26
package/target_sdk=34
version/code=1
version/name="1.0.0"
package/release=false
package/signing_debug_key_store="compagnie.keystore"
package/signing_debug_user="compagnie"
package/signing_debug_password="azerty123"
architectures/arm64-v8a=true
architectures/armeabi-v7a=true
graphics_driver/opengl3=true
graphics_driver/vulkan=false
CFG
echo "✅ Preset prêt"

echo "🤖 4/5 : Vérification templates Android"
TPL_DIR="$HOME/.local/share/godot/export_templates/4.3.stable"
if [ ! -f "$TPL_DIR/android_debug.apk" ]; then
  echo "📥 Téléchargement templates..."
  mkdir -p "$TPL_DIR"
  wget -q "https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_export_templates.tpz" -O templates.tpz
  unzip -q templates.tpz -d ./tmp
  cp ./tmp/templates/* "$TPL_DIR/"
  rm -rf tmp templates.tpz
fi
echo "✅ Templates prêts"

echo "🤖 5/5 : Compilation APK"
godot --headless --path . --export-debug "Android" Compagnie3D.apk
test -f Compagnie3D.apk
echo ""
echo "🎉 APK GÉNÉRÉE : $(ls -lh Compagnie3D.apk | awk '{print $5}')"
