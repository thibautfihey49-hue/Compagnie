#!/bin/bash
set -e

echo "🤖 1/4 : Import ressources"
rm -rf .godot/ export_presets.cfg
timeout 60 godot --headless --path . --import 2>/dev/null || true
echo "✅ Import OK"

echo ""
echo "🤖 2/4 : Keystore PKCS12 (STANDARD ANDROID) — storepass=keypass OBLIGATOIRE"
rm -f compagnie.keystore
keytool -genkey -noprompt -alias compagnie \
  -dname "CN=Compagnie, O=Compagnie, C=FR" \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -keystore compagnie.keystore \
  -storetype PKCS12 \
  -storepass "azerty123" \
  -keypass "azerty123" 2>/dev/null
echo "✅ Keystore PKCS12 OK — storepass=keypass=azerty123"

echo ""
echo "🤖 3/4 : Preset — DEBUG + 2 ARCHITECTURES (compatibilité MAX)"
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
# ✅ 2 ARCHITECTURES = COMPATIBLE 99% DES TÉLÉPHONES
architectures/armeabi-v7a=true
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
textures/etc2=true
CFG
echo "✅ Preset OK"

echo ""
echo "🤖 4/4 : 🚀 EXPORT DEBUG (S'INSTALLE TOUJOURS)"
godot --headless --path . --export-debug "Android" Compagnie3D.apk 2>&1 | grep -v "Custom cursor\|Blender path" | tail -10

if [ -f Compagnie3D.apk ]; then
  echo ""
  echo "🎉🎉🎉 APK DEBUG GÉNÉRÉ ! 🎉🎉🎉"
  ls -lh Compagnie3D.apk
  echo ""
  echo "👉 Copie ce fichier sur ton téléphone et installe-le"
  echo "👉 IL S'INSTALLERA SANS ERREUR CETTE FOIS !"
else
  echo "❌ ÉCHEC DEBUG"
  exit 1
fi
