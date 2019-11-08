#pragma once

#include <cstdint>

// TODO(rubu): rework this to use the Timebase from media_type.h instead of a frequency?
class MediaTimestamp
{
public:
    MediaTimestamp() = default;

    MediaTimestamp(const uint64_t value, const uint32_t frequency) : _value(value),
        _frequency(frequency)
    {
    }

    uint32_t GetFrequency() const
    {
        return _frequency;
    }

    uint64_t GetValue() const
    {
        return _value;
    }

    bool IsValid() const
    {
        return _frequency != 0;
    }

private:
    uint64_t _value = 0;
    uint32_t _frequency = 0;
};
