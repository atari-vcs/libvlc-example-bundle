project('libvlc-test-bundle', 'c',
  version: '0.1.0'
)

libm_dep = meson.get_compiler('c').find_library('m')
libsdl2_dep = dependency('SDL2')
libvlc_dep = dependency('libvlc')

executable(
  'libvlc-test',
  'libvlc-test.c',
  dependencies: [
    libm_dep,
    libsdl2_dep,
    libvlc_dep,
  ]
)
