#!/bin/bash
set -euo pipefail

godot --headless --path . --import >/dev/null 2>&1 || true

cat > export_presets.cfg << 'CFG'
[preset.0]
name="Android"
platform="Android"
runnable=true
export_filter="all"
export_path="Compagnie3D.apk"

[preset.0.options]
package/name="Compagnie 3D"
package/unique_name="fr.compagnie3d.app"
package/min_sdk=26
package/target_sdk=34
version/code=1
version/name="1.0.0"
package/release=false
architectures/arm64-v8a=true
architectures/armeabi-v7a=true
graphics_driver/opengl3=true
graphics_driver/vulkan=false
CFG

godot --headless --path . --export-debug "Android" Compagnie3D.apk
