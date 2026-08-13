#!/bin/bash
set -e

echo ""
echo "🤖 1/4 : Import (génère .import)"
rm -rf .godot/ export_presets.cfg
timeout 90 godot --headless --path . --import 2>&1 | tail -3 || true
echo "✅ Import OK"

echo ""
echo "🤖 2/4 : Vérifier que main_scene est BIEN lu par Godot"
grep "main_scene" project.godot
ls -la scenes/main.tscn

echo ""
echo "🤖 3/4 : Keystore PKCS12"
rm -f compagnie.keystore
keytool -genkey -noprompt -alias compagnie \
  -dname "CN=Compagnie, O=Compagnie, C=FR" \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -keystore compagnie.keystore \
  -storetype PKCS12 -storepass "azerty123" -keypass "azerty123" 2>/dev/null
echo "✅ Keystore OK"

echo ""
echo "🤖 4/4 : Preset + Export APK"
cat > export_presets.cfg << 'CFG'
[preset.0]
name="Android"
platform="Android"
runnable=true
export_filter="all"
include_filter=""
exclude_filter=""
export_path="Compagnie3D.apk"

[preset.0.options]
package/unique_name="fr.compagnie3d.app"
package/name="Compagnie 3D"
package/min_sdk=24
package/target_sdk=33
version/code=1
version/name="1.0.0"
package/release=false
package/signing_debug_key_store="compagnie.keystore"
package/signing_debug_user="compagnie"
package/signing_debug_password="azerty123"
package/signing_release_key_store="compagnie.keystore"
package/signing_release_user="compagnie"
package/signing_release_password="azerty123"
architectures/armeabi-v7a=true
architectures/arm64-v8a=true
graphics_driver/opengl3=true
screen/immersive_mode=true
textures/etc2=true
CFG

godot --headless --path . --export-debug "Android" Compagnie3D.apk 2>&1 | grep -v "Custom cursor\|Blender path" | tail -8

if [ -f Compagnie3D.apk ]; then
  echo ""
  echo "🎉🎉🎉 APK FINAL PRÊT ! 🎉🎉🎉"
  ls -lh Compagnie3D.apk
  echo ""
  echo "⚠️  TRÈS IMPORTANT : DÉSINSTALLE L'ANCIENNE APK SUR TON TÉLÉPHONE AVANT !"
  echo "👉 Copier → Installer → 🐱 ÇA MARCHE ENFIN !"
else
  echo "❌ ÉCHEC"
  exit 1
fi
