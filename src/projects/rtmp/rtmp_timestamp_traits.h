#pragma once

#include <cstdint>

typedef uint32_t rtmp_timestamp_t;

template<typename T>
class RtmpTimestampTraits
{
public:
    RtmpTimestampTraits() = default;

    RtmpTimestampTraits(const rtmp_timestamp_t rtmp_timestamp) : _valid(true),
        _rtmp_timestamp(rtmp_timestamp),
        _wide_rtmp_timestamp(rtmp_timestamp)
    {
    }

    const uint64_t &GetRtmpTimestamp() const
    {
        return _wide_rtmp_timestamp;
    }

    bool IsValid() const
    {
        return _valid;
    }

    void SetNextConsecutiveRtmpTimestamp(const rtmp_timestamp_t rtmp_timestamp)
    {
        // Handle wrap around
        if (rtmp_timestamp < _rtmp_timestamp)
        {
            _wide_rtmp_timestamp += (std::numeric_limits<rtmp_timestamp_t>::max() - _rtmp_timestamp) + rtmp_timestamp;
        }
        else
        {
            _wide_rtmp_timestamp += rtmp_timestamp - _rtmp_timestamp;
        }
        _rtmp_timestamp = rtmp_timestamp;
        _valid = true;
    }

protected:
    bool                _valid = false;
    rtmp_timestamp_t    _rtmp_timestamp = 0;
    uint64_t            _wide_rtmp_timestamp = 0;
};