FROM alpine:3.12.3 AS test

ENV DEBUG_ENVIRONMENT=

RUN apk -v --no-cache --update add bash curl jq gomplate git shellcheck
# latest alpine on dockerhub is 3.12.3 and it contains bats-1.2.1.  
# download it from 3.13 packages
RUN wget https://dl-cdn.alpinelinux.org/alpine/v3.13/main/x86_64/bats-1.2.1-r0.apk && apk add bats-1.2.1-r0.apk
WORKDIR /turn
COPY . /turn
RUN git clone https://github.com/bats-core/bats-support test/test_helper/bats-support && cd test/test_helper/bats-support && git checkout d140a65044b2d6810381935ae7f0c94c7023c8c3 && cd ../../..
RUN git clone https://github.com/bats-core/bats-assert test/test_helper/bats-assert && cd test/test_helper/bats-assert && git checkout 0a8dd57e2cc6d4cc064b1ed6b4e79b9f7fee096f && cd ../../..
RUN git clone https://github.com/grayhemp/bats-mock test/test_helper/bats-mock && cd test/test_helper/bats-mock && git checkout fdb01d035f20f424c594c02d05fd1fc731e02d8f && cd ../../..

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
