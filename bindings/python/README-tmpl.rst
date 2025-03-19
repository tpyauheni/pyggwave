..  [[[cog

    import cog
    import pyggwave as ggwave

    def indent(text, indentation = "    "):
        return indentation + text.replace("\n", "\n" + indentation)

    def comment(text):
        return "# " + text.replace("\n", "\n# ")

    def cogOutExpression(expr):
        cog.outl(indent(expr))
        cog.outl(indent(comment(str(eval(expr)))))

    ]]]
    [[[end]]]

========
pyggwave
========

A fork of tiny data-over-sound library with improved documentation and Python compatibility.

..  [[[cog

    cog.outl()
    cog.outl(".. code:: python")
    cog.outl()

    cog.outl(indent(comment('generate audio waveform for string "hello python"')))
    cog.outl(indent('waveform = pyggwave.encode("hello python")'))
    cog.outl()

    cog.outl(indent(comment('decode audio waveform')))
    cog.outl(indent('text = pyggwave.decode(instance, waveform)'))
    cog.outl()

    ]]]

.. code::

   {{ Basic code examples will be generated here. }}

..  [[[end]]]

--------
Features
--------

* Audible and ultrasound transmissions available
* Bandwidth of 8-16 bytes/s (depending on the transmission protocol)
* Robust FSK modulation
* Reed-Solomon based error correction

------------
Installation
------------
::

    pip install pyggwave

---
API
---

encode()
--------

.. code:: python

    encode(payload, [protocolId], [volume], [instance])

Encodes ``payload`` into an audio waveform.

..  [[[cog

    import pydoc
    import pyggwave

    help_str = pydoc.plain(pydoc.render_doc(pyggwave.GGWave.encode, "%s"))

    cog.outl()
    cog.outl('Output of ``help(pyggwave.encode)``:')
    cog.outl()
    cog.outl('.. code::\n')
    cog.outl(indent(help_str))

    ]]]

.. code::

   {{ Content of help(pyggwave.encode) will be generated here. }}

..  [[[end]]]

decode()
--------

.. code:: python

    decode(instance, waveform)

Analyzes and decodes ``waveform`` into to try and obtain the original payload.
A preallocated pyggwave ``instance`` is required.

..  [[[cog

    import pydoc

    help_str = pydoc.plain(pydoc.render_doc(pyggwave.GGWave.decode, "%s"))

    cog.outl()
    cog.outl('Output of ``help(pyggwave.decode)``:')
    cog.outl()
    cog.outl('.. code::\n')
    cog.outl(indent(help_str))

    ]]]

.. code::

   {{ Content of help(pyggwave.decode) will be generated here. }}

..  [[[end]]]


-----
Usage
-----

* Encode and transmit data with sound:

.. code:: python

    import pyggwave
    import pyaudio

    p = pyaudio.PyAudio()

    ggwave = pyggwave.GGWave()

    # generate audio waveform for string "hello python"
    waveform = ggwave.encode("hello python", protocol_id=3)

    print("Transmitting text 'hello python' ...")
    stream = p.open(format=pyaudio.paFloat32, channels=1, rate=48000, output=True, frames_per_buffer=4096)
    stream.write(waveform, len(waveform) // 4)

    ggwave.free()

    stream.stop_stream()
    stream.close()

    p.terminate()

* Capture and decode audio data:

.. code:: python

    import pyggwave
    import pyaudio

    p = pyaudio.PyAudio()

    ggwave = pyggwave.GGWave()

    stream = p.open(format=pyaudio.paFloat32, channels=1, rate=48000, input=True, frames_per_buffer=1024)

    print('Listening ... Press Ctrl+C to stop')

    try:
        while True:
            data = stream.read(1024, exception_on_overflow=False)
            res = ggwave.decode(data)

            if res:
                try:
                    print('Received text: ' + res.decode("utf-8"))
                except as exc:
                    print(exc)
    except KeyboardInterrupt:
        pass

    ggwave.free()

    stream.stop_stream()
    stream.close()

    p.terminate()

----
More
----

Check out `<http://github.com/ggerganov/ggwave>`_ for more information about ggwave!

-----------
Development
-----------

Check out `pyggwave python package on Github <https://github.com/tpyauheni/pyggwave/tree/master/bindings/python>`_.
