#!/bin/bash
set -e

echo "🤖 Génération preset Android minimal"

cat > export_presets.cfg << 'CFG_EOF'
[preset.0]
name="Android"
platform="Android"
runnable=true
export_path="Compagnie3D.apk"

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
CFG_EOF

echo "✅ Preset généré"
echo "🚀 Export APK..."
godot --headless --path . --export-release "Android" Compagnie3D.apk

if [ -f Compagnie3D.apk ]; then
  echo "✅ APK GÉNÉRÉ !"
  ls -la Compagnie3D.apk
else
  echo "❌ ÉCHEC"
  exit 1
fi
