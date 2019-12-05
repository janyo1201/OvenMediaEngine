//==============================================================================
//
//  OvenMediaEngine
//
//  Created by Hyunjun Jang
//  Copyright (c) 2018 AirenSoft. All rights reserved.
//
//==============================================================================
#pragma once

#include "publisher.h"
#include "ice_candidates.h"
#include "p2p.h"

namespace cfg
{
	struct WebrtcPublisher : public Publisher
	{
		PublisherType GetType() const override
		{
			return PublisherType::Webrtc;
		}

		const P2P &GetP2P() const
		{
			return _p2p;
		}

		int GetServerTimeOffset() const
		{
			return _server_time_offset;
		}

		bool FakeH264SdpEntry() const
		{
			return _fake_h264_sdp_entry;
		} 

	protected:
		void MakeParseList() const override
		{
			Publisher::MakeParseList();

			RegisterValue<Optional>("Timeout", &_timeout);
			RegisterValue<Optional>("P2P", &_p2p);
			RegisterValue<Optional>("ServerTimeOffset", &_server_time_offset);
			RegisterValue<Optional>("FakeH264SdpEntry", &_fake_h264_sdp_entry);
		}

		int _timeout = 0;
		P2P _p2p;
		int _server_time_offset = 0;
		bool _fake_h264_sdp_entry = true;
	};
}