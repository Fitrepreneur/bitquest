FROM debian:stretch
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y wget
RUN apt-get install -y openjdk-8-jre
RUN apt-get install -y openjdk-8-jdk
RUN apt-get install -y git

RUN mkdir /bitquest
COPY . /bitquest/
RUN mkdir -p /spigot/plugins

WORKDIR /spigot
RUN wget http://ci.md-5.net/job/NoCheatPlus/lastSuccessfulBuild/artifact/target/NoCheatPlus.jar -O /spigot/plugins/NoCheatPlus.jar

# DOWNLOAD AND BUILD SPIGOT
RUN wget https://hub.spigotmc.org/jenkins/job/BuildTools/64/artifact/target/BuildTools.jar -O /tmp/BuildTools.jar
RUN export SHELL=/bin/bash && cd /tmp && java -jar BuildTools.jar --rev 1.12.2
RUN cp /tmp/Spigot/Spigot-Server/target/spigot-*.jar /spigot/spigot.jar
RUN cd /spigot && echo "eula=true" > eula.txt
COPY server.properties /spigot/
COPY bukkit.yml /spigot/
COPY spigot.yml /spigot/


RUN export SHELL=/bin/bash && cd /bitquest/ && ./gradlew setupWorkspace
RUN cd /bitquest/ && ./gradlew shadowJar
RUN cp /bitquest/build/libs/bitquest-2.0-all.jar /spigot/plugins/

CMD java -jar spigot.jar
