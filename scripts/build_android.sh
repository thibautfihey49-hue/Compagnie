#!/bin/bash
set -euo pipefail

rm -rf .godot export_presets.cfg
timeout 90 godot --headless --path . --import >/dev/null 2>&1 || true

grep -q 'run/main_scene="res://scenes/main.tscn"' project.godot
test -f scenes/main.tscn
test -f scripts/main.gd

rm -f compagnie.keystore
keytool -genkeypair -noprompt \
  -alias compagnie \
  -dname "CN=Compagnie, O=Compagnie, C=FR" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -keystore compagnie.keystore \
  -storetype PKCS12 \
  -storepass "azerty123" \
  -keypass "azerty123" >/dev/null 2>&1

cat > export_presets.cfg <<'CFG'
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

godot --headless --path . --export-debug "Android" Compagnie3D.apk
test -f Compagnie3D.apk
