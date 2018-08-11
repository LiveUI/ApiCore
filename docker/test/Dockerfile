FROM liveui/boost-base:1.1.1

WORKDIR /app

ADD .build ./.build
ADD Resources ./Resources
ADD Sources ./Sources
ADD Tests ./Tests
ADD Package.swift ./
ADD Package.resolved ./

CMD swift test

