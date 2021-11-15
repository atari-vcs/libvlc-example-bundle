project('libvlc-test-bundle', 'c',
  version: '0.1.0'
)

cc = meson.get_compiler('c')
libm_dep = cc.find_library('m')
libidn_dep = cc.find_library('idn')
libsdl2_dep = dependency('SDL2')
libvlc_dep = dependency('libvlc')

executable(
  'libvlc-test',
  'libvlc-test.c',
  dependencies: [
    libm_dep,
    libidn_dep,
    libsdl2_dep,
    libvlc_dep,
  ]
)
