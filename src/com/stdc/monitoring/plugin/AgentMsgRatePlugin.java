
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

import java.util.List;

import org.cougaar.core.plugin.ComponentPlugin;
import org.cougaar.core.service.LoggingService;
import org.cougaar.core.service.BlackboardService;
import org.cougaar.core.service.BlackboardQueryService;
import org.cougaar.core.service.BlackboardMetricsService;
import org.cougaar.core.service.AgentIdentificationService;
import org.cougaar.util.UnaryPredicate;
import org.cougaar.core.blackboard.IncrementalSubscription;
import org.cougaar.planning.ldm.plan.Task;
import org.cougaar.planning.ldm.plan.PlanElement;
import org.cougaar.planning.ldm.asset.Asset;
import org.cougaar.core.agent.service.alarm.Alarm;
import org.cougaar.core.service.EventService;

/**
 * This COUGAAR Plugin subscribes to tasks, planelements and calculates the rate
 * at which these objects are updated on blackboard.
 * @version $Id: AgentMsgRatePlugin.java,v 1.3 2003/03/06 22:37:19 amit Exp $
 **/
public class AgentMsgRatePlugin extends ComponentPlugin
{
  private String _agentName = null;
  private String _hostname = null;
  private Alarm _timer;
  private int _timerCount = 60;

  // The LoggingService
  private LoggingService _log;
  private BlackboardQueryService _blackboardQuery;
  private BlackboardMetricsService _metricsService;
  private EventService _eventService;

  private IncrementalSubscription _mySubscription;   // all Tasks
  private int _addedCount=0, _changedCount=0, _removedCount=0;

  /**
   * Looking for object of class task, planelements
   **/ 
  private UnaryPredicate myPredicate = new UnaryPredicate() {
    public boolean execute(Object o) {
        return (o instanceof Task || o instanceof PlanElement || o instanceof Asset);
    }
  };

  /**
   * Sets the LoggingService service, Called by introspection on start
   **/
  public void setLoggingService(LoggingService log) {
      this._log = log;
  }

  /**
   * Sets the BlackboardQueryService service, Called by introspection on start
   **/
  public void setBlackboardQueryService(BlackboardQueryService bbQueryService) {
     this._blackboardQuery = bbQueryService;
  }

  /**
   * Sets the BlackboardMetricsService service, Called by introspection on start
   **/
  public void setBlackboardMetricsService(BlackboardMetricsService metricsService) {
     this._metricsService = metricsService;
  }

  /**
   * Sets the EventService, Called by introspection on start
   **/
  public void setEventService(EventService es) {
    _eventService = es;
  }

  /**
   * Establish subscription if any and do initialization.
   **/
  public void setupSubscriptions() {

      // get Agent Name
      if (agentId != null)
          _agentName = agentId.getAddress();

      try {
          _hostname = java.net.InetAddress.getLocalHost().getHostName();
      } catch (java.net.UnknownHostException ex) {
          _hostname = "localhost";
      }

      _mySubscription =
        (IncrementalSubscription)blackboard.subscribe(myPredicate);

      List params = (List) getParameters();
      if ( params.isEmpty() ) {
          _timerCount = 60;
      } else {
          _timerCount = Integer.parseInt( params.get(0).toString() );
      }

      _timer = null;
      startTimer(_timerCount);
  }

  /**
   * Top level plugin execute loop.  Handle changes to subscriptions.
   * and timer expiry.
   **/
  public void execute() {
       if( _mySubscription.hasChanged() ) {
           _addedCount   += _mySubscription.getAddedCollection().size();
           _changedCount += _mySubscription.getChangedCollection().size();
           _removedCount += _mySubscription.getRemovedCollection().size();
       }
       if (timerExpired()) { // Timer Expired
           int totalCount = _addedCount + _changedCount + _removedCount;
           String msg = "Added=" + _addedCount  +
                        " Changed=" + _changedCount +
                        " Removed=" + _removedCount +
                        " MSG_RATE=" + (float)(totalCount*60/_timerCount);
           sendCougaarEvent("STATUS", msg);
           _addedCount = 0; _changedCount = 0; _removedCount = 0;
           _timer = null;
           startTimer(_timerCount);
       }
  }

  /**
   * Schedule a update wakeup after some interval of time. <p>
   * Uses an alarm.
   * @param delay how long to delay before the timer expires.
   * @see org.cougaar.core.agent.service.alarm.Alarm
   * @see org.cougaar.core.service.AlarmService#addRealTimeAlarm
   **/
  protected void startTimer(final long delay) {
    if (_timer != null) return;  // update already scheduled
    if (_log.isDebugEnabled())
      _log.debug(_agentName + ": " + "Starting idle timer with delay " + delay);

    _timer = new Alarm() {
      long expirationTime = System.currentTimeMillis() + delay*1000l;
      boolean expired = false;
      public long getExpirationTime() {return expirationTime;}
      public synchronized void expire() {
        if (!expired) {
          expired = true;
          blackboard.signalClientActivity();
        }
      }
      public boolean hasExpired() { return expired; }
      public synchronized boolean cancel() {
        boolean was = expired;
        expired=true;
        return was;
      }
    };
    getAlarmService().addRealTimeAlarm(_timer);
  }

  /**
   * Cancel the timer.
   **/
  protected void cancelTimer() {
    if (_timer == null) return;
    if (_log.isDebugEnabled())
      _log.debug(_agentName + ": " + "Cancelling timer");
    _timer.cancel();
    _timer = null;
  }

  /**
   * Test if the timer has expired.
   * @return false if the timer is not running or has not yet expired
   * else return true.
   **/
  protected boolean timerExpired() {
    return _timer != null && _timer.hasExpired();
  }

  private void sendCougaarEvent(String type, String message ) {
      if (_eventService != null) {
          if (_eventService.isEventEnabled()) {
              _eventService.event( "[" + type + "] " + message );
          }
      }
  }

}
