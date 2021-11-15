# Native LibVLC Example Bundle

This is a basic demonstration bundle using libVLC on the Atari VCS to
play a short segment of 1080p video.

## Installing

You will need to enable Atari Homebrew on your VCS. Once you have done
so, go to

  https://atari-vcs:3030/

and select `Upload`. Select the file `native-indy800-example_0.1.0.zip`
built from this repository. You can then launch this game, like any
Homebrew title, from the same interface.

## Building

You can create the bundle by running

    mkdir build
    cd build
    make_bundle.sh ../native-indy800-example.yaml


in any suitable Linux-like environment with the
[bundle-gen](https://github.com/atari-vcs/bundle-gen) script
[`make-bundle.sh`](https://github.com/atari-vcs/bundle-gen/blob/main/make-bundle.sh)
installed in your PATH, and Docker installed on your machine.

## License

This example is made available under the terms of the
[WTFPL](http://www.wtfpl.net/), following the original [libVLC
example](https://wiki.videolan.org/LibVLC_SampleCode_SDL/) that it is
based on. You should be remember that the libraries it depends on,
including libVLC, may be less permissively licensed.

The included video is a clip from [Big Buck
Bunny](https://www.bigbuckbunny.org), which is licensed under the
(Creative Commons Attribution
3.0)[http://creativecommons.org/licenses/by/3.0/] license, and is (c)
copyright 2008, Blender Foundation / www.bigbuckbunny.org.
