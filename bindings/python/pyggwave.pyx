"""
A backend for data-over-sound communication.

Original project: https://github.com/ggerganov/ggwave.
Modified by Yauheni.
"""

cimport cython

from libc.stdio cimport stderr
from cpython.mem cimport PyMem_Malloc, PyMem_Free

import re

cimport cggwave

def raw__get_default_parameters():
    """
    Returns default GGWave parameters.
    """

    return cggwave.ggwave_getDefaultParameters()

def raw__init(parameters = None):
    """
    Initializes GGWave instance and returns its identifier.
    """

    if (parameters is None):
        parameters = raw__get_default_parameters()

    return cggwave.ggwave_init(parameters)

def raw__free(instance: int) -> None:
    """
    Frees GGWave instance.
    """
    return cggwave.ggwave_free(instance)

def raw__encode(payload: bytes | str, protocolId: int = 1, volume: int = 10, instance: int | None = None) -> bytes:
    """ Encode payload into an audio waveform.
        @param {string} payload, the data to be encoded
        @return Generated audio waveform bytes representing 16-bit signed integer samples.
    """

    if isinstance(payload, str):
        payload = payload.encode('utf-8')
    cdef bytes data_bytes = payload

    cdef char* cdata = data_bytes

    own = False
    if (instance is None):
        own = True
        instance = raw__init(raw__get_default_parameters())

    n = cggwave.ggwave_encode(instance, cdata, len(data_bytes), protocolId, volume, NULL, 1)

    cdef bytes output_bytes = bytes(n)
    cdef char* coutput = output_bytes

    n = cggwave.ggwave_encode(instance, cdata, len(data_bytes), protocolId, volume, coutput, 0)

    if (own):
        raw__free(instance)

    return output_bytes

def raw__decode(instance: int, waveform: bytes) -> bytes | None:
    """ Analyze and decode audio waveform to obtain original payload
        @param {bytes} waveform, the audio waveform to decode
        @return The decoded payload if successful.
    """

    cdef bytes data_bytes = waveform
    cdef char* cdata = data_bytes

    cdef bytes output_bytes = bytes(256)
    cdef char* coutput = output_bytes

    rxDataLength = cggwave.ggwave_decode(instance, cdata, len(data_bytes), coutput)

    if (rxDataLength > 0):
        return coutput[:rxDataLength]

    return None

def raw__disable_log() -> None:
    """
    Disables all GGWave logging.

    It can be enabled afterwards by calling `raw__enable_log()`.
    """
    cggwave.ggwave_setLogFile(NULL);

def raw__enable_log() -> None:
    """
    Enables all GGWave logging (it's enabled by default).

    It can be disabled afterwards by calling `raw__disable_log()`.
    """
    cggwave.ggwave_setLogFile(stderr);

def raw__rx_toggle_protocol(protocolId: int, state: bool) -> None:
    """
    Toggles specific protocol ON or OFF for receiving.

    When turned off, protocol is not used for data receiving.
    """
    cggwave.ggwave_rxToggleProtocol(protocolId, state);

def raw__tx_toggle_protocol(protocolId: int, state: bool) -> None:
    """
    Toggles specific protocol ON or OFF for sending.

    When turned off, protocol is not used for data sending.
    """
    cggwave.ggwave_txToggleProtocol(protocolId, state);

def raw__rx_protocol_set_freq_start(protocolId: int, freq_start: int) -> None:
    """
    Changes start (base) frequency for speicific protocol for data receiving.
    """
    cggwave.ggwave_rxProtocolSetFreqStart(protocolId, freq_start);

def raw__tx_protocol_set_freq_start(protocolId: int, freq_start: int) -> None:
    """
    Changes start (base) frequency for speicific protocol for data sending.
    """
    cggwave.ggwave_txProtocolSetFreqStart(protocolId, freq_start);

def raw__rx_duration_frames(instance: int) -> int:
    """
    Returns number of recorded frames.
    """
    return cggwave.ggwave_rxDurationFrames(instance)

def raw__rx_receiving(instance: int) -> bool:
    """
    Returns `True` if GGWave is currently receiving message, `False` otherwise.
    """
    return cggwave.ggwave_rxReceiving(instance)

def raw__rx_analyzing(instance: int) -> bool:
    """
    Returns `True` if GGWave is currently analyzing received message, `False` otherwise.
    """
    return cggwave.ggwave_rxAnalyzing(instance)

def raw__rx_samples_needed(instance: int) -> int:
    """
    Returns amount of samples needed to decode data.
    """
    return cggwave.ggwave_rxSamplesNeeded(instance)

def raw__rx_frames_to_record(instance: int) -> int:
    """
    Returns total amount of frames to record.

    Calculated at the moment of receiving block start marker.
    Equals to `-1` if data was invalid.
    """
    return cggwave.ggwave_rxFramesToRecord(instance)

def raw__rx_frames_left_to_record(instance: int) -> int:
    """
    Returns amount of frames left until end marker is received.

    As soon as it reaches `0` analysis begins.
    """
    return cggwave.ggwave_rxFramesLeftToRecord(instance)

def raw__rx_frames_to_analyze(instance: int) -> int:
    """
    Returns total amount of frames to analyze.
    """
    return cggwave.ggwave_rxFramesToAnalyze(instance)

def raw__rx_frames_left_to_analyze(instance: int) -> int:
    """
    Returns amount of frames left until analysis is over.
    """
    return cggwave.ggwave_rxFramesLeftToAnalyze(instance)

def raw__rx_stop_receiving(instance: int) -> bool:
    """
    Stops receiving of data.

    It will be started again as soon as block start marker is received.
    """
    return cggwave.ggwave_rxStopReceiving(instance)

def raw__rx_data_length(instance: int) -> int:
    """
    Returns length of data to be received.
    """
    return cggwave.ggwave_rxDataLength(instance)


class GGWave:
    instance: int

    def __init__(self, parameters = None) -> None:
        self.instance = raw__init(parameters)

    @staticmethod
    def get_default_parameters():
        """
        Returns default GGWave parameters.
        """
        return raw__get_default_parameters()

    def free(self) -> None:
        """
        Frees GGWave instance.
        """
        raw__free(self.instance)

    def encode(self, payload: bytes | str, protocol_id: int = 5, volume: int = 100) -> bytes:
        """ Encode payload into an audio waveform.
            @param {string} payload, the data to be encoded
            @return Generated audio waveform bytes representing 16-bit signed integer samples.
        """
        return raw__encode(payload, protocol_id, volume, self.instance)

    def decode(self, frame: bytes) -> bytes | None:
        """ Analyze and decode audio waveform to obtain original payload
            @param {bytes} waveform, the audio waveform to decode
            @return The decoded payload if successful.
        """
        return raw__decode(self.instance, frame)

    @staticmethod
    def disable_log() -> None:
        """
        Disables all GGWave logging.

        It can be enabled afterwards by calling `enable_log()`.
        """
        raw__disable_log()

    @staticmethod
    def enable_log() -> None:
        """
        Enables all GGWave logging (it's enabled by default).

        It can be disabled afterwards by calling `disable_log()`.
        """
        raw__enable_log()

    @staticmethod
    def rx_toggle_protocol(protocol_id: int, state: bool) -> None:
        """
        Toggles specific protocol ON or OFF for receiving.

        When turned off, protocol is not used for data receiving.
        """
        raw__rx_toggle_protocol(protocol_id, state)

    @staticmethod
    def tx_toggle_protocol(protocol_id: int, state: bool) -> None:
        """
        Toggles specific protocol ON or OFF for sending.

        When turned off, protocol is not used for data sending.
        """
        raw__tx_toggle_protocol(protocol_id, state)

    @staticmethod
    def rx_protocol_set_freq_start(protocol_id: int, freq_start: int) -> None:
        """
        Changes start (base) frequency for speicific protocol for data receiving.
        """
        raw__rx_protocol_set_freq_start(protocol_id, freq_start)

    @staticmethod
    def tx_protocol_set_freq_start(protocol_id: int, freq_start: int) -> None:
        """
        Changes start (base) frequency for speicific protocol for data sending.
        """
        raw__tx_protocol_set_freq_start(protocol_id, freq_start)

    def rx_duration_frames(self) -> int:
        """
        Returns number of recorded frames.
        """
        return raw__rx_duration_frames(self.instance)

    def rx_receiving(self) -> bool:
        """
        Returns `True` if GGWave is currently receiving message, `False` otherwise.
        """
        return raw__rx_receiving(self.instance)

    def rx_analyzing(self) -> bool:
        """
        Returns `True` if GGWave is currently analyzing received message, `False` otherwise.
        """
        return raw__rx_analyzing(self.instance)

    def rx_samples_needed(self) -> int:
        """
        Returns amount of samples needed to decode data.
        """
        return raw__rx_samples_needed(self.instance)

    def rx_frames_to_record(self) -> int:
        """
        Returns total amount of frames to record.

        Calculated at the moment of receiving block start marker.
        Equals to `-1` if data was invalid.
        """
        return raw__rx_frames_to_record(self.instance)

    def rx_frames_left_to_record(self) -> int:
        """
        Returns amount of frames left until end marker is received.

        As soon as it reaches `0` analysis begins.
        """
        return raw__rx_frames_left_to_record(self.instance)

    def rx_frames_to_analyze(self) -> int:
        """
        Returns total amount of frames to analyze.
        """
        return raw__rx_frames_left_to_record(self.instance)

    def rx_frames_left_to_analyze(self) -> int:
        """
        Returns amount of frames left until analysis is over.
        """
        return raw__rx_frames_left_to_record(self.instance)

    def rx_stop_receiving(self) -> bool:
        """
        Stops receiving of data.

        It will be started again as soon as block start marker is received.
        """
        return raw__rx_frames_left_to_record(self.instance)

    def rx_data_length(self) -> int:
        """
        Returns length of data to be received.
        """
        return raw__rx_frames_left_to_record(self.instance)

