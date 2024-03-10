# Use an official Maven image as a base image for building
FROM maven:3.8.4-openjdk-8 AS builder

# Set the working directory in the container
WORKDIR /app

# Copy the POM file to download dependencies
COPY pom.xml .

# Download dependencies and plugins
RUN mvn dependency:go-offline

# Copy the rest of the application code
COPY src ./src

# Build the application
RUN mvn install

# Use an official Tomcat image as a base image for runtime
FROM tomcat:9.0-jdk8-openjdk-slim

# Remove the default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file from the builder stage to Tomcat's webapps directory
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=builder /app/target/addressbook.war /usr/local/tomcat/webapps/ROOT.war

# Expose the port that Tomcat runs on
EXPOSE 8080

# Specify the command to run on container start
CMD ["catalina.sh", "run"]
