#pragma once

#include "rtmp_timestamp_traits.h"

#include <cstdint>

class RtmpFiData : public RtmpTimestampTraits<RtmpFiData>
{
public:
    RtmpFiData() = default;

    RtmpFiData(const uint32_t rtmp_timestamp, const uint64_t rtmp_fi_data) : RtmpTimestampTraits<RtmpFiData>(rtmp_timestamp),
        _rtmp_fi_data(rtmp_fi_data)
    {
    }

    RtmpFiData &operator=(const RtmpFiData& rtmp_fi_data)
    {
        SetNextConsecutiveRtmpTimestamp(rtmp_fi_data._rtmp_timestamp);
        _rtmp_fi_data = rtmp_fi_data._rtmp_fi_data;
        return *this;
    }

    const uint64_t &GetFiData() const
    {
        return _rtmp_fi_data;
    }

private:
    uint64_t _rtmp_fi_data = 0;
};