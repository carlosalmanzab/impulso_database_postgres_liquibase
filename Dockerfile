#CREATE DEV DATABASE
FROM postgres:14.3-alpine AS db

ENV POSTGRES_DB=impulso_prod
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=password

WORKDIR /app

RUN echo "CREATE DATABASE {$POSTGRES_DB};" | psql -U $POSTGRES_USER

#BUILD APP
ENV DATABASE_HOST=localhost
ENV DATABASE_PORT=5432
ENV DATABASE_NAME=${POSTGRES_DB}
ENV DATABASE_USERNAME=${POSTGRES_USER}
ENV DATABASE_PASSWORD=${POSTGRES_PASSWORD}

FROM maven:3-eclipse-temurin-17-alpine AS mvn 
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -e -B package -P prod


#Final Image
FROM openjdk:17-alpine

LABEL maintainer="Carlos Almanza"
LABEL project="impulso-db-liquibase"

WORKDIR /app

COPY src/main/resources /app/resources

ARG JAR_FILE=target/*.jar

COPY --from=mvn /app/target/${JAR_FILE} impulso-bd-liquibase.jar
ENTRYPOINT ["java","-jar","impulso-bd-liquibase.jar"]

#DELETE DATABASE
WORKDIR /app
RUN echo "DROP DATABASE {$POSTGRES_DB};" | psql -U $POSTGRES_USER
