import pyggwave as ggwave

testFailed = False

ggwave.GGWave.disable_log()
ggwave.GGWave.enable_log()

instance: ggwave.GGWave = ggwave.GGWave()

try:
    samples: bytes = instance.encode("hello python")
    assert samples
    assert instance.decode(samples) == b"hello python"

    samples2: bytes = instance.encode(b"hello bytes")
    assert samples2
    assert instance.decode(samples2) == b"hello bytes"
except AssertionError:
    print("Some of the tests failed!")
    raise
else:
    print("All tests passed!")
