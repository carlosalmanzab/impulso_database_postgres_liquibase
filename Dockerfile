FROM maven:3-eclipse-temurin-17-alpine AS mvn 
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -e -B package -P prod


FROM openjdk:17-alpine

LABEL maintainer="Carlos Almanza"
LABEL project="impulso-db-liquibase"

WORKDIR /app

COPY src/main/resources /app/resources

ARG JAR_FILE = target/*.jar

COPY --from=mvn /app/target/${JAR_FILE} impulso-bd-liquibase.jar
ENTRYPOINT ["java","-jar","impulso-bd-liquibase.jar"]