package org.red5.server.net.rtmp;

/*
 * RED5 Open Source Flash Server - http://code.google.com/p/red5/
 * 
 * Copyright (c) 2006-2010 by respective authors (see below). All rights reserved.
 * 
 * This library is free software; you can redistribute it and/or modify it under the 
 * terms of the GNU Lesser General Public License as published by the Free Software 
 * Foundation; either version 2.1 of the License, or (at your option) any later 
 * version. 
 * 
 * This library is distributed in the hope that it will be useful, but WITHOUT ANY 
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License along 
 * with this library; if not, write to the Free Software Foundation, Inc., 
 * 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 
 */

import org.apache.mina.core.session.IoSession;
import org.red5.server.net.rtmp.codec.RTMP;

/**
 * RTMP events handler
 */
public interface IRTMPHandler {
    /**
     * Connection open event
     * 
     * @param conn          Connection
     * @param state         RTMP state
     */
	public void connectionOpened(RTMPConnection conn, RTMP state);

    /**
     * Message received
     * 
     * @param message       Message
     * @param session       Connected session
     * @throws Exception    Exception
     */
	public void messageReceived(Object message, IoSession session) throws Exception;

    /**
     * Message sent
     * @param conn          Connection
     * @param message       Message
     */
	public void messageSent(RTMPConnection conn, Object message);

    /**
     * Connection closed
     * @param conn          Connection
     * @param state         RTMP state
     */
	public void connectionClosed(RTMPConnection conn, RTMP state);
	
}
