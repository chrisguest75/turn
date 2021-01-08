FROM alpine:3.12.3 AS test

ENV DEBUG_ENVIRONMENT=

RUN apk -v --no-cache --update add bash curl jq gomplate git bats shellcheck

WORKDIR /turn
COPY . /turn
RUN git clone https://github.com/bats-core/bats-support test/test_helper/bats-support
RUN git clone https://github.com/bats-core/bats-assert test/test_helper/bats-assert  
RUN git clone https://github.com/grayhemp/bats-mock test/test_helper/bats-mock

# run tests during build
RUN ./run_tests.sh

FROM alpine:3.12.3 AS prod

ENV DEBUG_ENVIRONMENT=

RUN apk -v --no-cache --update add bash curl jq gomplate git 

WORKDIR /turn
COPY --from=test "/turn/*.gomplate" "/turn/generate.sh" "/turn/versions.sh" "/turn/tags-to-ranges.sh" "/turn/*.json" "/turn/LICENSE" /turn/

ENTRYPOINT ["/turn/generate.sh"]
WORKDIR /repo
CMD ["/turn/generate.sh", "--action=create", "--type=ALL", "--tags", "--includenext"]
