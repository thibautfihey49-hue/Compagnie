#!/bin/bash
set -e

echo "🤖 1/3 : Import des ressources"
rm -rf .godot/
timeout 60 godot --headless --path . --import 2>/dev/null || true
echo "✅ Import terminé"

echo ""
echo "🤖 2/3 : Création keystore"
rm -f compagnie.keystore
keytool -genkey -noprompt -alias compagnie \
  -dname "CN=Compagnie, O=Compagnie, C=FR" \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -keystore compagnie.keystore \
  -storepass 123456 -keypass 123456 -storetype JKS 2>/dev/null
echo "✅ Keystore OK"

echo ""
echo "🤖 3/3 : 🚀 EXPORT ANDROID — SANS export_presets.cfg"
echo "   → Utilisation des options directes Godot 4.2"

# Méthode : Créer le preset TEMPORAIREMENT, exporter, puis le supprimer
cat > /tmp/export_presets.tmp.cfg << 'CFG'
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
architectures/arm64-v8a=true
graphics_driver/opengl3=true
textures/etc2=true
CFG

# Copier le preset TEMPORAIREMENT seulement pour l'export
cp /tmp/export_presets.tmp.cfg export_presets.cfg

# Exporter
godot --headless --path . --export-release "Android" Compagnie3D.apk 2>&1 | grep -v "Custom cursor\|Blender path"

# Nettoyer
rm -f export_presets.cfg

if [ -f Compagnie3D.apk ]; then
  echo ""
  echo "🎉🎉🎉 APK GÉNÉRÉ ! 🎉🎉🎉"
  ls -lh Compagnie3D.apk
else
  echo ""
  echo "❌ ÉCHEC — Passage à Godot 4.3"
  exit 1
fi
