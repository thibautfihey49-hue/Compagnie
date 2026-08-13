#!/bin/bash
set -e

echo "🤖 Étape 1/4 : Génération preset Android"
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
enable_high_end_graphics=false
internet_permission=false
access_network_state_permission=false
access_wifi_state_permission=false
vibrate_permission=false
post_notifications_permission=false
external_storage_permission=0
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

echo "✅ Preset OK"

echo ""
echo "🤖 Étape 2/4 : WARM-UP ÉDITEUR (OBLIGATOIRE) — importe toutes les ressources"
echo "   → C'est l'étape qui manquait depuis le début !"
timeout 60 godot --headless --editor --quit 2>&1 | tail -20 || true
echo "✅ Warm-up terminé — cache .godot/ créé"

echo ""
echo "🤖 Étape 3/4 : Vérification preset"
cat export_presets.cfg | grep "package/"

echo ""
echo "🤖 Étape 4/4 : Export APK..."
godot --headless --path . --export-release "Android" Compagnie3D.apk 2>&1 | tail -30

if [ -f Compagnie3D.apk ]; then
  echo ""
  echo "🎉🎉🎉 APK GÉNÉRÉ AVEC SUCCÈS ! 🎉🎉🎉"
  ls -la Compagnie3D.apk
else
  echo ""
  echo "❌ ÉCHEC — Liste des fichiers pour debug :"
  ls -la
  echo ""
  echo "Contenu .godot/ :"
  ls -la .godot/ 2>/dev/null || echo "Pas de .godot/"
  exit 1
fi
