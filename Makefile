SAMPLERATE_VERSION:=7dcc9bb727dae4e2010cdc6ef7cda101b05509a4
SAMPLERATE:=libsamplerate-$(SAMPLERATE_VERSION)

EMCC:=emcc
EXPORTED_FUNCTIONS:='["_src_strerror", "_src_new", "_src_delete", "_src_js_process", "_src_reset", "_src_set_ratio"]'
CFLAGS:=-O2 -s ASM_JS=1 -s USE_TYPED_ARRAYS=2
LINKFLAGS:=$(CFLAGS) -s EXPORTED_FUNCTIONS=$(EXPORTED_FUNCTIONS)
EMCONFIGURE:=emconfigure
EMMAKE:=emmake
SAMPLERATE_URL:="https://github.com/erikd/libsamplerate/archive/7dcc9bb727dae4e2010cdc6ef7cda101b05509a4.tar.gz"
TAR:=tar

all: dist/libsamplerate.js

dist/libsamplerate.js: $(SAMPLERATE) src/wrapper.o src/pre.js src/post.js
	$(EMCC) $(LINKFLAGS) --pre-js src/pre.js --post-js src/post.js $(wildcard $(SAMPLERATE)/src/*.o) src/wrapper.o -o $@

$(SAMPLERATE): $(SAMPLERATE).tar.gz
	$(TAR) xzvf $@.tar.gz && \
	cd $@ && \
	./autogen.sh && \
	$(EMCONFIGURE) ./configure --disable-fftw CFLAGS="$(CFLAGS)" && \
	$(EMMAKE) make AM_DEFAULT_VERBOSITY=1

$(SAMPLERATE).tar.gz:
	test -e "$@" || wget -O $(SAMPLERATE).tar.gz $(SAMPLERATE_URL)

clean:
	$(RM) -rf $(SAMPLERATE)

src/wrapper.o: src/wrapper.c
	$(EMCC) $(CFLAGS) -I$(SAMPLERATE) -c $< -o $@

distclean: clean
	$(RM) $(SAMPLERATE).tar.gz

.PHONY: clean distclean
