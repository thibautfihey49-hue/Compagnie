#!/bin/bash
set -e

echo "🤖 Preset Android — CLÉS OFFICIELLES GODOT 4.2"

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
package/unique_name="fr.compagnie3d.app"
package/name="fr.compagnie3d.app"
package/min_sdk=26
package/target_sdk=34
version/code=1
version/name="1.0.0"
package/release=true
package/signing_release_key_store="compagnie.keystore"
package/signing_release_user="compagnie"
package/signing_release_password="123456"
graphics_driver/vulkan=false
graphics_driver/opengl3=true
screen/immersive_mode=true
screen/support_small=true
screen/support_normal=true
screen/support_large=true
screen/support_xlarge=true
CFG_EOF

echo "✅ Preset OK"
echo "🚀 Export..."
godot --headless --path . --export-release "Android" Compagnie3D.apk

if [ -f Compagnie3D.apk ]; then
  echo "✅ APK GÉNÉRÉ !"
  ls -la Compagnie3D.apk
else
  echo "❌ ÉCHEC"
  exit 1
fi
