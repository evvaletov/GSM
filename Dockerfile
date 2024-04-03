# Dockefile to build a Generalized Spallation Model (GSM) Docker image
# Build command: docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) -t gsm .
# Run command: docker run -it --network host -v $(pwd):/srv -w /srv gsm ./xgsm1

# Use CentOS 7 as the base image
FROM centos:7

# Install dependencies
RUN yum -y update && \
    yum -y groupinstall "Development Tools" && \
    yum -y install wget \
                   gmp-devel \
                   mpfr-devel \
                   libmpc-devel \
                   zlib-devel \
                   tar && \
    yum clean all

# Download and extract GCC 6.3.0
RUN cd /tmp && \
    wget https://ftp.gnu.org/gnu/gcc/gcc-6.3.0/gcc-6.3.0.tar.gz && \
    tar -xf gcc-6.3.0.tar.gz && \
    rm gcc-6.3.0.tar.gz

# Build and install GCC 6.3.0
RUN cd /tmp/gcc-6.3.0 && \
    ./contrib/download_prerequisites && \
    mkdir objdir && \
    cd objdir && \
    ../configure --prefix=/usr/local/gcc-6.3 --enable-languages=c,c++,fortran --disable-multilib --disable-bootstrap --with-system-zlib && \
    make -j$(nproc) && \
    make install && \
    cd / && \
    rm -rf /tmp/gcc-6.3.0

# Install CMake 3.14
RUN cd /tmp && \
    wget https://github.com/Kitware/CMake/releases/download/v3.14.0/cmake-3.14.0-Linux-x86_64.sh && \
    chmod +x cmake-3.14.0-Linux-x86_64.sh && \
    ./cmake-3.14.0-Linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm cmake-3.14.0-Linux-x86_64.sh

# Update PATH and LD_LIBRARY_PATH
ENV PATH=/usr/local/gcc-6.3/bin:$PATH \
    LD_LIBRARY_PATH=/usr/local/gcc-6.3/lib64:$LD_LIBRARY_PATH

# Clone GSM, prepare build and my_gsm directories, build xgsm1
RUN git clone https://github.com/lanl/GSM.git /opt/GSM && \
    mkdir /opt/GSM/build && \
    cd /opt/GSM/build && \
    cmake .. -DCMAKE_Fortran_COMPILER=gfortran && \
    make xgsm1 && \
    make && \
    mkdir /opt/GSM/srv

# Create a group and user with specified GID and UID
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} usergroup && \
    useradd -m -u ${UID} -g usergroup -s /bin/bash user

# Change ownership of the necessary directories to the new user
RUN chown -R user:usergroup /usr/local/bin /usr/local/gcc-6.3

# Create the entrypoint script
RUN echo -e '#!/bin/bash\n# Set stack size to unlimited\nulimit -s unlimited\n#Copy the GSM runtime files to the work directory\ncp /opt/GSM/my_gsm/* .\n# Execute the passed command\nexec "$@"' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Use the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]

# Switch to non-root user
USER user
