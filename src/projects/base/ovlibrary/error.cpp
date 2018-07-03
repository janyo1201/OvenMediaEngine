//==============================================================================
//
//  OvenMediaEngine
//
//  Created by Hyunjun Jang
//  Copyright (c) 2018 AirenSoft. All rights reserved.
//
//==============================================================================
#include <errno.h>
#include "error.h"

#include "log.h"

namespace ov
{
	Error::Error()
		: _domain(""),

		  _code(0)
	{
	}

	Error::Error(const ov::String &domain, int code)
		: _domain(domain),

		  _code(code)
	{
	}

	Error::Error(const ov::String &domain, int code, const char *format, ...)
		: _domain(domain),

		  _code(code)
	{
		va_list list;
		va_start(list, format);
		_message.VFormat(format, list);
		va_end(list);
	}

	Error::Error(int code)
		: _code(code)
	{
	}

	Error::Error(int code, const char *format, ...)
		: _code(code)
	{
		va_list list;
		va_start(list, format);
		_message.VFormat(format, list);
		va_end(list);
	}

	Error::Error(const Error &error)
		: _domain(error._domain),

		  _code(error._code),
		  _message(error._message)
	{
	}

	std::shared_ptr<Error> Error::CreateError(ov::String domain, int code, const char *format, ...)
	{
		String message;
		va_list list;
		va_start(list, format);
		message.VFormat(format, list);
		va_end(list);

		return std::make_shared<Error>(domain, code, message);
	}

	std::shared_ptr<Error> Error::CreateError(int code, const char *format, ...)
	{
		String message;
		va_list list;
		va_start(list, format);
		message.VFormat(format, list);
		va_end(list);

		return std::make_shared<Error>(code, message);
	}

	std::shared_ptr<Error> Error::CreateErrorFromErrno()
	{
		return std::make_shared<Error>("errno", errno, "%s", strerror(errno));
	}

	Error::~Error()
	{
	}

	int Error::GetCode() const
	{
		return _code;
	}

	String Error::GetMessage() const
	{
		return _message;
	}

	String Error::ToString() const
	{
		String description;

		if(_domain.IsEmpty() == false)
		{
			description.AppendFormat("[%s] ", _domain.CStr());
		}

		if(_message.IsEmpty() == false)
		{
			description.AppendFormat("%s (%d)", _message.CStr(), _code);
		}
		else
		{
			description.AppendFormat("(No error message) (%d)", _code);
		}

		return description;
	}
}