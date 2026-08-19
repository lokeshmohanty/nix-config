{ pkgs }:
# AB Download Manager — https://github.com/amir1376/ab-download-manager
#
# A Compose Desktop (Kotlin/JVM) download manager shipped as a prebuilt jpackage
# image that bundles its own JetBrains Runtime (JBR 25). Building it from source
# needs Gradle + JBR + the full Compose Multiplatform toolchain, so we wrap the
# upstream Linux x64 tarball instead and let autoPatchelfHook repair the bundled
# ELF/JNI libraries against Nix store paths. The image ships three launchers
# (GUI, CLI, browser native-messaging host) that share one runtime.
#
# Version bumps: edit `version`, then refresh the packed-tarball hash:
#   nix run nixpkgs#nix-prefetch-url --type sha256 \
#     https://github.com/amir1376/ab-download-manager/releases/download/v<ver>/ABDownloadManager_<ver>_linux_x64.tar.gz \
#     | xargs nix run nixpkgs#nix-hash -- to-sri --type sha256
let
  # Libraries the bundled JBR dlopen's at runtime (not just link-time deps).
  # autoPatchelf sets DT_RUNPATH, but dlopen() ignores DT_RUNPATH — it only
  # searches LD_LIBRARY_PATH, ld.so.cache, and /usr/lib. On NixOS none of
  # those contain Nix store libs, so every dlopen'd .so must be on
  # LD_LIBRARY_PATH via the wrapper below.
  runtimeLibs = with pkgs; [
    alsa-lib
    fontconfig
    freetype
    libGL
    stdenv.cc.cc.lib # libstdc++.so.6 / libgcc_s.so
    wayland
    libxkbcommon
    libx11
    libxext
    libxi
    libxrender
    libxtst
    libxinerama # dlopen'd by libawt_xawt.so
    libxrandr # dlopen'd by libawt_xawt.so
    libxcomposite # dlopen'd by libawt_xawt.so
    zlib
  ];
in
pkgs.stdenv.mkDerivation rec {
  pname = "ab-download-manager";
  version = "1.10.1";

  src = pkgs.fetchurl {
    url = "https://github.com/amir1376/ab-download-manager/releases/download/v${version}/ABDownloadManager_${version}_linux_x64.tar.gz";
    hash = "sha256-2q5TLfwHIx2uAvzjcaZrUObB70ypSnBbs7XyuZaCXuc=";
  };

  # The tarball extracts to a single top-level ABDownloadManager/ directory.
  sourceRoot = ".";

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.makeWrapper
  ];

  # Same set as runtimeLibs: autoPatchelf needs them as link-time deps (DT_RUNPATH
  # for the ELF binaries), and the wrapper needs them on LD_LIBRARY_PATH for the
  # libraries the JBR dlopen's at runtime (fontconfig, X11, etc.).
  buildInputs = runtimeLibs;

  # autoPatchelfHook searches buildInputs for the libs above, but the bundled
  # runtime's own .so files reference each other across subdirectories —
  # lib/runtime/lib/*.so need libjvm.so from lib/runtime/lib/server — so teach
  # the hook where to find them. (Runs before autoPatchelf's postFixup pass.)
  preFixup = ''
    addAutoPatchelfSearchPath+=(
      $out/opt/ab-download-manager/lib
      $out/opt/ab-download-manager/lib/app
      $out/opt/ab-download-manager/lib/runtime/lib
      $out/opt/ab-download-manager/lib/runtime/lib/server
    )
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Preserve the jpackage layout (bin/ + lib/) so the native launchers can
    # locate ../lib/app/*.cfg and ../lib/runtime via /proc/self/exe.
    mkdir -p $out/opt/ab-download-manager
    cp -r ABDownloadManager/* $out/opt/ab-download-manager/

    # Expose the three launchers on PATH. The jpackage launchers resolve their
    # own installation directory through /proc/self/exe, so the wrapper execs
    # the real binary by full path (not a renamed copy) — /proc/self/exe then
    # points at the original binary under opt/, and the launcher finds
    # ../lib/app/*.cfg and ../lib/runtime correctly.
    #
    # LD_LIBRARY_PATH is required because the JBR dlopen's libfontconfig.so.1
    # (and several X11 libs) at runtime; autoPatchelf's DT_RUNPATH doesn't
    # cover dlopen, so without this fontconfig init fails with
    # "Fontconfig head is null" and the GUI never appears.
    mkdir -p $out/bin
    makeWrapper $out/opt/ab-download-manager/bin/ABDownloadManager \
      $out/bin/abdownloadmanager \
      --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath runtimeLibs}
    makeWrapper $out/opt/ab-download-manager/bin/ABDownloadManagerCli \
      $out/bin/abdownloadmanager-cli \
      --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath runtimeLibs}
    makeWrapper $out/opt/ab-download-manager/bin/ABDownloadManagerNativeMessagingHost \
      $out/bin/abdownloadmanager-native-messaging-host \
      --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath runtimeLibs}

    # Desktop integration (mirrors upstream scripts/install.sh).
    install -Dm644 $out/opt/ab-download-manager/lib/ABDownloadManager.png \
      $out/share/icons/hicolor/512x512/apps/abdownloadmanager.png

    mkdir -p $out/share/applications
    cat > $out/share/applications/com.abdownloadmanager.desktop <<EOF
    [Desktop Entry]
    Name=AB Download Manager
    Comment=Manage and organize your downloads
    GenericName=Downloader
    Categories=Utility;Network;
    Exec=$out/bin/abdownloadmanager
    Icon=abdownloadmanager
    Terminal=false
    Type=Application
    StartupWMClass=com-abdownloadmanager-desktop-AppKt
    EOF

    runHook postInstall
  '';

  passthru.updateScript = pkgs.writeShellScriptBin "ab-download-manager-update-nix" ''
    set -euo pipefail
    version=$(${pkgs.curl}/bin/curl -fsSL \
      https://api.github.com/repos/amir1376/ab-download-manager/releases/latest \
      | ${pkgs.jq}/bin/jq -r .tag_name | sed 's/^v//')
    url="https://github.com/amir1376/ab-download-manager/releases/download/v''${version}/ABDownloadManager_''${version}_linux_x64.tar.gz"
    hash=$(${pkgs.nix}/bin/nix-prefetch-url --type sha256 "$url" 2>/dev/null \
      | xargs ${pkgs.nix}/bin/nix hash to-sri --type sha256)
    ${pkgs.gnused}/bin/sed -i \
      -e "s|version = \".*\";|version = \"''${version}\";|" \
      -e "s|hash = \".*\";|hash = \"''${hash}\";|" \
      ${toString ./default.nix}
    echo "Updated ab-download-manager to ''${version}"
  '';

  meta = {
    description = "Fast and modern download manager (Compose Desktop, bundles JetBrains Runtime)";
    homepage = "https://abdownloadmanager.com";
    license = pkgs.lib.licenses.asl20;
    mainProgram = "abdownloadmanager";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with pkgs.lib.sourceTypes; [ binaryNativeCode ];
  };
}
