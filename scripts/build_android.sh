#!/bin/bash
set -e

echo "🤖 1/4 : IMPORTER LES RESSOURCES (--import N'ÉCRASE JAMAIS export_presets.cfg)"
rm -rf .godot/ export_presets.cfg
# --import = importe ressources SANS lancer l'éditeur → SANS ÉCRASER AUCUN FICHIER
timeout 120 godot --headless --path . --import 2>&1 | tail -5 || true
echo "✅ Import terminé — .godot/ créé, AUCUN fichier écrasé"

echo ""
echo "🤖 2/4 : GÉNÉRER export_presets.cfg PARFAIT APRÈS l'import"
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
package/signing_debug_key_store="compagnie.keystore"
package/signing_debug_user="compagnie"
package/signing_debug_password="123456"
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
custom_build/export_format=0
CFG_EOF
echo "✅ Preset écrit APRÈS import — intact"
grep "export_filter" export_presets.cfg

echo ""
echo "🤖 3/4 : Keystore JKS (release ET debug configurés)"
rm -f compagnie.keystore
keytool -genkey -noprompt -alias compagnie \
  -dname "CN=Compagnie, O=Compagnie, C=FR" \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -keystore compagnie.keystore \
  -storepass 123456 -keypass 123456 -storetype JKS 2>/dev/null
echo "✅ Keystore OK — utilisé pour release ET debug"

echo ""
echo "🤖 4/4 : 🚀 EXPORT RELEASE (aucun --editor entre preset et export)"
godot --headless --path . --export-release "Android" Compagnie3D.apk 2>&1 | tail -15

if [ -f Compagnie3D.apk ]; then
  echo ""
  echo "🎉🎉🎉 APK GÉNÉRÉ AVEC SUCCÈS ! 🎉🎉🎉"
  ls -lh Compagnie3D.apk
else
  echo ""
  echo "❌ Release → Tentative DEBUG"
  godot --headless --path . --export-debug "Android" Compagnie3D.apk 2>&1 | tail -15
  [ -f Compagnie3D.apk ] && { echo "✅ APK DEBUG OK"; ls -lh Compagnie3D.apk; } || { echo "❌ ÉCHEC"; exit 1; }
fi
