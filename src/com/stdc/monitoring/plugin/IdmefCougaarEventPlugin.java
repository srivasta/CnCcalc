/*
 * <copyright>
 *  Copyright 2001-2002 S/TDC (System/Technology Devlopment Corporation)
 *  under sponsorship of the Defense Advanced Research Projects Agency (DARPA).
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the Cougaar Open Source License as published by
 *  DARPA on the Cougaar Open Source Website (www.cougaar.org).
 *
 *  THE COUGAAR SOFTWARE AND ANY DERIVATIVE SUPPLIED BY LICENSOR IS
 *  PROVIDED 'AS IS' WITHOUT WARRANTIES OF ANY KIND, WHETHER EXPRESS OR
 *  IMPLIED, INCLUDING (BUT NOT LIMITED TO) ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, AND WITHOUT
 *  ANY WARRANTIES AS TO NON-INFRINGEMENT.  IN NO EVENT SHALL COPYRIGHT
 *  HOLDER BE LIABLE FOR ANY DIRECT, SPECIAL, INDIRECT OR CONSEQUENTIAL
 *  DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE OF DATA OR PROFITS,
 *  TORTIOUS CONDUCT, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 *  PERFORMANCE OF THE COUGAAR SOFTWARE.
 * </copyright>
 */

package com.stdc.monitoring.plugin;

import java.io.*;
import java.util.*;

import org.cougaar.core.plugin.ComponentPlugin;
import org.cougaar.core.service.LoggingService;
import org.cougaar.core.service.AgentIdentificationService;
import org.cougaar.core.blackboard.IncrementalSubscription;
import org.cougaar.util.UnaryPredicate;
import org.cougaar.core.service.EventService;

import org.cougaar.core.security.monitoring.blackboard.Event;
import org.cougaar.core.security.monitoring.idmef.Registration;
import org.cougaar.core.security.monitoring.idmef.AgentRegistration;
import edu.jhuapl.idmef.IDMEF_Message;

public class IdmefCougaarEventPlugin extends ComponentPlugin {
  private LoggingService _log;
  private String _agentName = null;
  private String _agentId = null;
  private String _hostname = null;
  private IncrementalSubscription _idmefEvents;
  private EventService _eventService;

  /**
   * A predicate that matches all "Event object which are not registration events"
   */
  class IdemfEventPredicate implements UnaryPredicate{
    public boolean execute(Object o) {
        if (o instanceof Event ) {
            IDMEF_Message msg=((Event)o).getEvent();
            if((msg instanceof Registration) || (msg instanceof AgentRegistration)){
                return false;
            }
            return true;
        }
        return false;
    }
  }
  
 
  /**
   * Sets the LoggingService service, Called by introspection on start
   **/
  public void setLoggingService(LoggingService log) {
      this._log = log;
  }

  /**
   * Sets the EventService, Called by introspection on start
   **/
  public void setEventService(EventService es) {
    _eventService = es;
  }

  protected void setupSubscriptions() {
      // get Agent Name
      try {
          _hostname = java.net.InetAddress.getLocalHost().getHostName();
      } catch (java.net.UnknownHostException ex) {
          _hostname = "localhost";
      }

      if (agentId != null) {
          _agentName = agentId.getAddress();
          _agentId = _hostname + ":" + _agentName;
      }

      _log.debug("Registering for IDMEF events in " + _agentName);

      _idmefEvents =
        (IncrementalSubscription)blackboard.subscribe(new IdemfEventPredicate());
  }

  protected void execute () {
      Collection events = _idmefEvents.getAddedCollection();
      Event idmefEvent = null;
      for (Iterator iter = events.iterator(); iter.hasNext();)
      {
          idmefEvent = (Event)iter.next();
          sendCougaarEvent("IDMEF", encodeXmlData(idmefEvent.getEvent().toString()));
      }
  }


  private void sendCougaarEvent(String type, String message ) {
      if (_eventService != null) {
          if (_eventService.isEventEnabled()) {
              _eventService.event( "[" + type + "] " + message );
          }
      }
  }

  private String encodeXmlData(String in) {
      StringBuffer sb = new StringBuffer();
      for ( int i = 0; i < in.length(); i++ ) {
          char c = in.charAt(i);
          if ( c == '<' )
              sb.append("&lt;");
          else if ( c == '>' )
              sb.append("&gt;");
          else if ( c == '"' )
              sb.append("&quot;");
          else if ( c == '&' )
              sb.append("&amp;");
          else
              sb.append(c);
      }
      return sb.toString();
  }

}
