# Maintainer: joshlukas
pkgname=tv-play
pkgver=1.0.0
pkgrel=2
pkgdesc="Videos und Bilder per AirPlay auf ein Apple TV streamen (mit Dolphin-Kontextmenü)"
arch=('x86_64')
url="https://github.com/joshlukas/tv-play"
license=('MIT')
depends=(
  'python' 'python-aiohttp' 'python-cryptography' 'python-zeroconf' 'python-pydantic'
  'python-protobuf' 'python-requests' 'python-ifaddr' 'python-tabulate'
  'python-chacha20poly1305-reuseable' 'python-cffi' 'python-six' 'avahi' 'ffmpeg'
)
makedepends=('git' 'python-build' 'python-installer' 'python-setuptools' 'python-wheel')
optdepends=('konsole: Eintrag „Auf Apple TV abspielen“ im Dolphin-Rechtsklickmenü')
install=tv-play.install

# pyatv 0.18.0 + Korrektur für tvOS 26/27 (https://github.com/postlund/pyatv/issues/2906),
# noch nicht offiziell veröffentlicht – deshalb fest auf diesen Commit gepinnt.
_pyatv_commit=8144c77c6cecbed4f9ba2adb5a350ad86a8f6604
_pyhosted=https://files.pythonhosted.org/packages
source=(
  "pyatv::git+https://github.com/robkochman/pyatv.git#commit=${_pyatv_commit}"
  # pyatv braucht srptools 1.x (2.0 hat eine inkompatible API)
  "${_pyhosted}/8d/b8/3f935d7f7d6bc25a88859beb0a6e246313012a12ae4844665322f771a5cb/srptools-1.0.1-py2.py3-none-any.whl"
  "${_pyhosted}/cp314/m/miniaudio/miniaudio-1.71-cp314-cp314-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl"
  "${_pyhosted}/py3/t/tinytag/tinytag-2.3.2-py3-none-any.whl"
  'tv-play'
  'tv-play-konsole'
  'tv-play.desktop'
  'LICENSE'
)
noextract=(
  'srptools-1.0.1-py2.py3-none-any.whl'
  'miniaudio-1.71-cp314-cp314-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl'
  'tinytag-2.3.2-py3-none-any.whl'
)
sha256sums=(
  'SKIP'
  'fccb44c949eb2507ba19f349a3087cb8fed2393014d7f0887b06c3186f19d1e9'
  '8a28ff4ad23e55bbde8808ce525d3bb7d249d7612f77646b30e06fc6b7a778ac'
  'ebaf957915266b9c20414a10f8c5170a345aa039a794650d39d66e7d6b96199f'
  'SKIP' 'SKIP' 'SKIP' 'SKIP'
)

build() {
  cd pyatv
  python -m build --wheel --no-isolation --outdir "$srcdir/wheels"
}

package() {
  local vendor=/usr/lib/tv-play/vendor
  local stage="$srcdir/stage"
  local whl
  rm -rf "$stage"
  for whl in "$srcdir"/wheels/*.whl "$srcdir"/*.whl; do
    python -m installer --destdir="$stage" --prefix=/x --no-compile-bytecode "$whl"
  done
  # Nur die Bibliotheken übernehmen (keine Kommandozeilen-Helfer), getrennt von System-Python
  install -d "$pkgdir$vendor"
  cp -a "$stage"/x/lib/python3*/site-packages/. "$pkgdir$vendor/"
  python -m compileall -q -d "$vendor" "$pkgdir$vendor"

  install -Dm755 tv-play "$pkgdir/usr/bin/tv-play"
  install -Dm755 tv-play-konsole "$pkgdir/usr/bin/tv-play-konsole"
  install -Dm755 tv-play.desktop "$pkgdir/usr/share/kio/servicemenus/tv-play.desktop"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  install -Dm644 pyatv/LICENSE.md "$pkgdir/usr/share/licenses/$pkgname/pyatv-LICENSE.md"
}
