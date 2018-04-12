FROM opensuse:tumbleweed
LABEL Description="openSUSE Tumbleweed with Verrou installed" Version="0.1"

# Update the host system
RUN zypper ref && zypper dup -y

# Install valgrind's run-time prerequisites (hack? what hack?)
RUN zypper in -y valgrind valgrind-devel && zypper rm -y valgrind valgrind-devel

# Install valgrind's build prerequisites
RUN zypper in -y subversion automake gcc gcc-c++ which

# Install verrou's additional build prerequisites
RUN zypper in -y git patch make perl python

# Download the valgrind source code (currently using v3.13.0)
RUN svn co --quiet svn://svn.valgrind.org/valgrind/tags/VALGRIND_3_13_0 valgrind

# Download verrou (currently using v1.1.0) and patch valgrind
RUN cd valgrind                                                                \
    && git clone --branch=v1.1.0 --single-branch                               \
                 https://github.com/edf-hpc/verrou.git verrou                  \
    && patch -p0 < verrou/valgrind.diff

# Configure valgrind
#
# NOTE: You may need to remove the --enable-verrou-fma switch if you are using
#       an old CPU or virtual machine
#
RUN cd valgrind                                                                \
    && ./autogen.sh                                                            \
    && ./configure --enable-only64bit --enable-verrou-fma=yes

# Build and install valgrind
RUN cd valgrind                                                                \
    && make -j8                                                                \
    && make install

# Run the verrou test suite to check that everything is fine
RUN cd valgrind                                                                \
    && make -C tests check                                                     \
    && make -C verrou check                                                    \
    && perl tests/vg_regtest verrou                                            \
    && make -C verrou/unitTest

# Clean up after ourselves
#
# NOTE: This step optimizes container size at the expense of hackability, feel
#       free to alter or remove it if your use case is different from mine.
#
RUN rm -rf valgrind                                                            \
    && zypper clean