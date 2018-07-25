# Configure the container's basic properties
FROM hgrasland/spack-tests
LABEL Description="openSUSE Tumbleweed with Verrou installed" Version="2.0"
CMD bash

# Install verrou
RUN spack install verrou@2.0.0

# Schedule Verrou to be loaded during container startup
RUN echo "spack load verrou" >> "$SETUP_ENV"