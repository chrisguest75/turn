FROM alpine:3.11.5

ENV DEBUG_ENVIRONMENT=

RUN apk -v --no-cache --update \
      add \
      bash \
      curl \
      jq \
      gomplate \
      git \ 
      bats

WORKDIR /turn
COPY . /turn
RUN git clone https://github.com/bats-core/bats-support test/test_helper/bats-support
RUN git clone https://github.com/bats-core/bats-assert test/test_helper/bats-assert  

# run tests during build
RUN ./run_tests.sh

ENTRYPOINT ["/turn/generate.sh"]
WORKDIR /repo
CMD ["/turn/generate.sh", "--action=create", "--type=ALL", "--tags", "--includenext"]