FROM eclipse-temurin:21-jre-jammy

RUN apt-get update && apt-get install -y curl && apt-get clean

RUN mkdir -p /tmp/minecraft/plugins
WORKDIR /tmp/minecraft

# PaperMC 1.21.4
RUN curl -Lo paper.jar "https://api.papermc.io/v2/projects/paper/versions/1.21.4/builds/222/downloads/paper-1.21.4-222.jar"

# Plugins - latest stable versions
RUN curl -Lo plugins/Geyser-Spigot.jar "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot.jar"
RUN curl -Lo plugins/Dynmap.jar "https://mikeprimm.com/dynmap/builds/dynmap/Dynmap-3.7-beta-8-spigot.jar"
RUN curl -Lo plugins/ViaVersion.jar "https://ci.viaversion.com/job/ViaVersion/lastSuccessfulBuild/artifact/build/libs/ViaVersion.jar"

# Accept EULA
RUN echo "eula=true" > eula.txt

# Non-root user (recommended fix)
RUN useradd -ms /bin/bash minecraft && chown -R minecraft:minecraft /tmp/minecraft

RUN echo '#!/bin/bash\n\
if [ ! -f /opt/minecraft/paper.jar ]; then\n\
  echo "Initializing Minecraft data directory..."\n\
  cp -r /tmp/minecraft/* /opt/minecraft/\n\
fi\n\
cd /opt/minecraft\n\
exec java -Xms1G -Xmx1G -jar paper.jar --nogui' \
> /start-server.sh

RUN chmod +x /start-server.sh && chown minecraft:minecraft /start-server.sh

EXPOSE 25565/tcp 19132/udp 8123/tcp

VOLUME ["/opt/minecraft"]

# Switch to non-root user
USER minecraft

CMD ["/start-server.sh"]
