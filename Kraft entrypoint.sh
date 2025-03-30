FROM eclipse-temurin:17-jre-jammy

ARG KAFKA_VERSION=3.6.1
ENV KAFKA_HOME=/opt/kafka

# Install required packages
RUN apt-get update && \
    apt-get install -y curl wget

# Download and extract Kafka - using wget which handles redirects better
RUN mkdir -p $KAFKA_HOME && \
    wget -q "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz" && \
    tar -xzf "kafka_2.13-${KAFKA_VERSION}.tgz" -C $KAFKA_HOME --strip-components=1 && \
    rm "kafka_2.13-${KAFKA_VERSION}.tgz"

# Create directory for data
RUN mkdir -p $KAFKA_HOME/data/kraft

WORKDIR $KAFKA_HOME

# Create entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]



version: "3.3"

services:
  kafka1:
    build: 
      context: .
      dockerfile: Dockerfile
    container_name: kafka1
    ports:
      - "9092:9092"
      - "9093:9093"
    environment:
      NODE_ID: 1
      KRAFT_MODE: "controller,broker"
      KAFKA_ADVERTISED_HOST_NAME: kafka1
      CONTROLLER_QUORUM_VOTERS: "1@kafka1:9093,2@kafka2:9093,3@kafka3:9093"
      CLUSTER_ID: "ELuJJ-eGQGOIU_a83lOrww"
    volumes:
      - kafka1-data:/opt/kafka/data
    networks:
      - kafka-net
    healthcheck:
      test: ["CMD-SHELL", "kafka-broker-api-versions.sh --bootstrap-server localhost:9092"]
      interval: 10s
      timeout: 5s
      retries: 5

  kafka2:
    build: 
      context: .
      dockerfile: Dockerfile
    container_name: kafka2
    ports:
      - "9094:9092"
      - "9095:9093"
    environment:
      NODE_ID: 2
      KRAFT_MODE: "controller,broker"
      KAFKA_ADVERTISED_HOST_NAME: kafka2
      CONTROLLER_QUORUM_VOTERS: "1@kafka1:9093,2@kafka2:9093,3@kafka3:9093"
      CLUSTER_ID: "ELuJJ-eGQGOIU_a83lOrww"
    volumes:
      - kafka2-data:/opt/kafka/data
    networks:
      - kafka-net
    depends_on:
      - kafka1
    healthcheck:
      test: ["CMD-SHELL", "kafka-broker-api-versions.sh --bootstrap-server localhost:9092"]
      interval: 10s
      timeout: 5s
      retries: 5

  kafka3:
    build: 
      context: .
      dockerfile: Dockerfile
    container_name: kafka3
    ports:
      - "9096:9092"
      - "9097:9093"
    environment:
      NODE_ID: 3
      KRAFT_MODE: "controller,broker"
      KAFKA_ADVERTISED_HOST_NAME: kafka3
      CONTROLLER_QUORUM_VOTERS: "1@kafka1:9093,2@kafka2:9093,3@kafka3:9093"
      CLUSTER_ID: "ELuJJ-eGQGOIU_a83lOrww"
    volumes:
      - kafka3-data:/opt/kafka/data
    networks:
      - kafka-net
    depends_on:
      - kafka1
      - kafka2
    healthcheck:
      test: ["CMD-SHELL", "kafka-broker-api-versions.sh --bootstrap-server localhost:9092"]
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  kafka-net:
    driver: bridge

volumes:
  kafka1-data:
    driver: local
  kafka2-data:
    driver: local
  kafka3-data:
    driver: local




version: "3.3"

services:
  kafka1:
    build: 
      context: .
      dockerfile: Dockerfile
    container_name: kafka1
    ports:
      - "9092:9092"
      - "9093:9093"
    environment:
      NODE_ID: 1
      KRAFT_MODE: "controller,broker"
      KAFKA_ADVERTISED_HOST_NAME: kafka1
      CONTROLLER_QUORUM_VOTERS: "1@kafka1:9093,2@kafka2:9093,3@kafka3:9093"
      CLUSTER_ID: "ELuJJ-eGQGOIU_a83lOrww"
    volumes:
      - kafka1-data:/opt/kafka/data
    networks:
      - kafka-net
    healthcheck:
      test: ["CMD-SHELL", "kafka-broker-api-versions.sh --bootstrap-server localhost:9092"]
      interval: 10s
      timeout: 5s
      retries: 5

  kafka2:
    build: 
      context: .
      dockerfile: Dockerfile
    container_name: kafka2
    ports:
      - "9094:9092"
      - "9095:9093"
    environment:
      NODE_ID: 2
      KRAFT_MODE: "controller,broker"
      KAFKA_ADVERTISED_HOST_NAME: kafka2
      CONTROLLER_QUORUM_VOTERS: "1@kafka1:9093,2@kafka2:9093,3@kafka3:9093"
      CLUSTER_ID: "ELuJJ-eGQGOIU_a83lOrww"
    volumes:
      - kafka2-data:/opt/kafka/data
    networks:
      - kafka-net
    depends_on:
      - kafka1
    healthcheck:
      test: ["CMD-SHELL", "kafka-broker-api-versions.sh --bootstrap-server localhost:9092"]
      interval: 10s
      timeout: 5s
      retries: 5

  kafka3:
    build: 
      context: .
      dockerfile: Dockerfile
    container_name: kafka3
    ports:
      - "9096:9092"
      - "9097:9093"
    environment:
      NODE_ID: 3
      KRAFT_MODE: "controller,broker"
      KAFKA_ADVERTISED_HOST_NAME: kafka3
      CONTROLLER_QUORUM_VOTERS: "1@kafka1:9093,2@kafka2:9093,3@kafka3:9093"
      CLUSTER_ID: "ELuJJ-eGQGOIU_a83lOrww"
    volumes:
      - kafka3-data:/opt/kafka/data
    networks:
      - kafka-net
    depends_on:
      - kafka1
      - kafka2
    healthcheck:
      test: ["CMD-SHELL", "kafka-broker-api-versions.sh --bootstrap-server localhost:9092"]
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  kafka-net:
    driver: bridge

volumes:
  kafka1-data:
    driver: local
  kafka2-data:
    driver: local
  kafka3-data:
    driver: local
