#!/bin/bash
set -e

echo "🤖 Génération preset Android — Godot 4.2 format (TESTÉ ET FIABLE)"

cat > export_presets.cfg << 'CFG_EOF'
[preset.0]

name="Android"
platform="Android"
runnable=true
custom_features=""
export_filter="all"
include_filter=""
exclude_filter=""
export_path="Compagnie3D.apk"
encryption_include_filters=""
encryption_exclude_filters=""
patch_package=false
modify_package=false

[preset.0.options]

package_name="fr.compagnie3d.app"
version_code=1
version_name="1.0.0"
min_sdk_version=26
target_sdk_version=34
release=true
keystore/release="compagnie.keystore"
keystore/release_user="compagnie"
keystore/release_password="123456"
graphics_driver/vulkan=false
graphics_driver/opengl3=true
screen/immersive_mode=true
screen/support_small=true
screen/support_normal=true
screen/support_large=true
screen/support_xlarge=true
CFG_EOF

echo "✅ export_presets.cfg OK"
cat export_presets.cfg

echo "🚀 Export APK..."
godot --headless --path . --export-release "Android" Compagnie3D.apk

if [ -f Compagnie3D.apk ]; then
  echo "✅ APK GÉNÉRÉ !"
  ls -la Compagnie3D.apk
else
  echo "❌ ÉCHEC"
  exit 1
fi
