package com.eme.ims.server;

import java.io.InputStream;
import java.io.OutputStream;

import org.apache.mina.core.session.IoSession;
import org.apache.mina.handler.stream.StreamIoHandler;

public class FielIoHandler extends StreamIoHandler{

	@Override
	protected void processStreamIo(IoSession session, InputStream in,
			OutputStream out) {
		
	}

}
