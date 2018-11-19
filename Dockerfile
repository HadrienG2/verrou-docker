# Configure the container's basic properties
FROM hgrasland/spack-tests
LABEL Description="openSUSE Tumbleweed with Verrou installed" Version="2.1"
CMD bash

# Install verrou
RUN spack install verrou@2.1.0

# Schedule a Verrou environment to be loaded during container startup
RUN echo "spack load verrou" >> "$SETUP_ENV"
