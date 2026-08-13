#!/bin/bash
set -e

echo "🤖 1/5 : Preset Android AVANT warm-up"
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
package/name="Compagnie 3D"
package/min_sdk=26
package/target_sdk=34
version/code=1
version/name="1.0.0"
package/release=true
package/signing_release_key_store="compagnie.keystore"
package/signing_release_user="compagnie"
package/signing_release_password="123456"
package/signing_debug_key_store=""
package/signing_debug_user=""
package/signing_debug_password=""
package/allow_backup=true
package/is_game=false
architectures/armeabi-v7a=false
architectures/arm64-v8a=true
architectures/x86=false
architectures/x86_64=false
graphics_driver/vulkan=false
graphics_driver/opengl3=true
screen/immersive_mode=true
screen/support_small=true
screen/support_normal=true
screen/support_large=true
screen/support_xlarge=true
screen/orientation=0
user_data_backup=true
internet_permission=false
access_network_state_permission=false
access_wifi_state_permission=false
vibrate_permission=false
launcher_icons/main_192x192=""
launcher_icons/main_432x432=""
launcher_icons/adaptive_foreground_432x432=""
launcher_icons/adaptive_background_432x432=""
launcher_icons/adaptive_monochrome_432x432=""
xr_features/oculus_mobile_support=false
xr_features/openxr=false
textures/bptc=false
textures/etc2=true
textures/s3tc=false
textures/astc=false
one_shot_deploy=false
deploy_to_remote=false
custom_build/use_custom_build=false
CFG_EOF
echo "✅ Preset OK"

echo ""
echo "🤖 2/5 : Templates Android"
TPL_DIR="$HOME/.local/share/godot/export_templates/4.2.2.stable"
[ -f "$TPL_DIR/android_release.apk" ] && echo "✅ Templates OK" || { echo "❌ templates"; exit 1; }

echo ""
echo "🤖 3/5 : Keystore JKS (storepass == keypass)"
rm -f compagnie.keystore
keytool -genkey -noprompt -alias compagnie \
  -dname "CN=Compagnie, O=Compagnie, C=FR" \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -keystore compagnie.keystore \
  -storetype JKS -storepass 123456 -keypass 123456
echo "✅ Keystore JKS OK"

echo ""
echo "🤖 4/5 : Warm-up éditeur (importe ressources + charge preset)"
rm -rf .godot/
timeout 90 godot --headless --path . --editor --quit 2>&1 | tail -5 || true
echo "✅ Warm-up OK"

echo ""
echo "🤖 5/5 : 🚀 EXPORT RELEASE (Godot 4 syntaxe)"
godot --headless --path . --export-release "Android" Compagnie3D.apk 2>&1 | tail -15

if [ -f Compagnie3D.apk ]; then
  echo ""
  echo "🎉🎉🎉 APK GÉNÉRÉ AVEC SUCCÈS ! 🎉🎉🎉"
  ls -lh Compagnie3D.apk
else
  echo "❌ ÉCHEC"
  exit 1
fi
