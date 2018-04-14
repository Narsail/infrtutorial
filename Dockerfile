# Build image
# Get the base image
FROM norionomura/swift:swift-4.1-branch as builder
# Install all necessary dependencies
RUN apt-get -qq update && apt-get -q -y install libssl-dev pkg-config
# Switch into the WORKDIR and copy it into the build image
WORKDIR /app
COPY . .
# Create a build folder to store the necessary data for the actual production image
RUN mkdir -p /build/lib && cp -R /usr/lib/swift/linux/*.so /build/lib
RUN swift build -c release && mv `swift build -c release --show-bin-path` /build/bin

# Production image
FROM ubuntu:16.04
RUN apt-get -qq update && apt-get install -y \
  libicu55 libxml2 libbsd0 libcurl3 libatomic1 \
  libssl-dev pkg-config \
  && rm -r /var/lib/apt/lists/*
WORKDIR /app
# COPY Config/ ./Config/
# COPY Resources/ ./Resources/ # if you have Resources
# COPY Public/ ./Public/ # if you have Public
COPY --from=builder /build/bin/Run .
COPY --from=builder /build/lib/* /usr/lib/
EXPOSE 80
CMD ["./Run"]
