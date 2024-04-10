
#BUILD APP
FROM maven:3-eclipse-temurin-17-alpine AS mvn
WORKDIR /app
COPY pom.xml .
COPY src ./src

ARG APP_PORT
ARG DATABASE_HOST
ARG DATABASE_PORT
ARG DATABASE_NAME
ARG DATABASE_USERNAME
ARG DATABASE_PASSWORD
ENV APP_PORT=$APP_PORT
ENV DATABASE_HOST=$DATABASE_HOST
ENV DATABASE_PORT=$DATABASE_PORT
ENV DATABASE_NAME=$DATABASE_NAME
ENV DATABASE_USERNAME=$DATABASE_USERNAME
ENV DATABASE_PASSWORD=$DATABASE_PASSWORD


RUN mvn -e -B package -P prod


#Final Image
FROM openjdk:17-alpine

LABEL maintainer="Carlos Almanza"
LABEL project="impulso-db-liquibase"

WORKDIR /app

COPY src/main/resources /app/resources

COPY --from=mvn /app/target/impulso_database_postgres_liquibase-1.0.0.jar impulso-bd-liquibase.jar
ENTRYPOINT ["java","-jar","impulso-bd-liquibase.jar"]
