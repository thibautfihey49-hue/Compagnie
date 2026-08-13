#!/bin/bash
set -e

echo "🤖 Configuration des variables d'environnement Godot..."

# ✅ Variables d'environnement que Godot lit DIRECTEMENT
export GODOT_EXPORT_PRESET_NAME="Android"
export GODOT_EXPORT_PRESET_PLATFORM="Android"
export GODOT_ANDROID_PACKAGE_NAME="fr.compagnie3d.app"
export GODOT_ANDROID_VERSION_CODE="1"
export GODOT_ANDROID_VERSION_NAME="1.0.0"
export GODOT_ANDROID_MIN_SDK="26"
export GODOT_ANDROID_TARGET_SDK="34"
export GODOT_ANDROID_ARCH="arm64-v8a"
export GODOT_ANDROID_KEYSTORE="compagnie.keystore"
export GODOT_ANDROID_KEYSTORE_USER="compagnie"
export GODOT_ANDROID_KEYSTORE_PASSWORD="123456"

echo "✅ Variables configurées :"
echo "   Package : $GODOT_ANDROID_PACKAGE_NAME"
echo "   Version : $GODOT_ANDROID_VERSION_NAME"
echo "   Arch    : $GODOT_ANDROID_ARCH"

echo ""
echo "🤖 1/4 : Création du preset PAR GODOT (pas manuel)"
# Supprimer l'ancien preset pour que Godot le régénère
rm -f export_presets.cfg

# Créer un preset MINIMAL que Godot complète
cat > export_presets.cfg << 'CFG'
[preset.0]
name="Android"
platform="Android"
runnable=true
export_path="Compagnie3D.apk"

[preset.0.options]
package/unique_name="fr.compagnie3d.app"
package/min_sdk=26
package/target_sdk=34
version/code=1
version/name="1.0.0"
package/release=true
architectures/arm64-v8a=true
graphics_driver/opengl3=true
CFG

echo "✅ Preset minimal écrit"

echo ""
echo "🤖 2/4 : Warm-up éditeur — Godot complète le preset"
rm -rf .godot/
timeout 90 godot --headless --path . --editor --quit 2>&1 | tail -5 || true

echo ""
echo "🤖 3/4 : Vérification du preset complété par Godot"
cat export_presets.cfg | grep -E "package/unique_name|architectures"

echo ""
echo "🤖 4/4 : 🚀 Export APK..."
godot --headless --path . --export-release "Android" Compagnie3D.apk 2>&1

if [ -f Compagnie3D.apk ]; then
  echo ""
  echo "🎉🎉🎉 APK GÉNÉRÉ ! 🎉🎉🎉"
  ls -lh Compagnie3D.apk
else
  echo ""
  echo "❌ ÉCHEC — Tentative avec export-debug..."
  godot --headless --path . --export-debug "Android" Compagnie3D.apk 2>&1
  if [ -f Compagnie3D.apk ]; then
    echo "✅ APK DEBUG généré (au moins !)"
    ls -lh Compagnie3D.apk
  else
    echo "❌ ÉCHEC TOTAL"
    exit 1
  fi
fi
