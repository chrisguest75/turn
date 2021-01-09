# README.md
Unittests for the script

NOTE: Based on [13_bats](https://github.com/chrisguest75/shell_examples/tree/master/13_bats)

## Preparing the tests
```sh
brew install bats-core
git clone https://github.com/bats-core/bats-support test/test_helper/bats-support
git clone https://github.com/bats-core/bats-assert test/test_helper/bats-assert  
git clone https://github.com/grayhemp/bats-mock test/test_helper/bats-mock
```

## Run Tests
```sh
bats -t test/tests.bats --formatter junit -T -o ./test/results
test/tests.bats 
```

```sh
docker run -it bats/bats:1.2.1 --version
docker run -it -v $(pwd):/mnt --workdir /mnt bats/bats:1.2.1 test/tests.bats         
```

