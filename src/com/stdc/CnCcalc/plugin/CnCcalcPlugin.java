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
package com.stdc.CnCcalc.plugin;

import org.cougaar.core.plugin.ComponentPlugin;
import org.cougaar.core.service.LoggingService;
import org.cougaar.core.service.BlackboardService;
import org.cougaar.core.service.BlackboardQueryService;
import org.cougaar.core.service.AgentIdentificationService;
import org.cougaar.core.service.ServletService;
import org.cougaar.core.agent.service.alarm.Alarm;
import org.cougaar.core.blackboard.IncrementalSubscription;
import org.cougaar.glm.ldm.Constants;
import org.cougaar.planning.ldm.plan.*;
import org.cougaar.planning.ldm.asset.*;
import org.cougaar.glm.ldm.asset.SupplyClassPG;
import org.cougaar.util.UnaryPredicate;
import org.cougaar.util.DynamicUnaryPredicate;
import org.cougaar.util.ConfigFinder;
import org.cougaar.core.service.EventService;
import org.cougaar.core.util.UID;
import org.cougaar.core.util.UniqueObject;
import org.cougaar.bootstrap.SystemProperties;
import org.cougaar.util.log.Logger;

import java.util.Properties;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.Vector;
import java.util.Collection;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Date;
import java.util.TimeZone;
import java.text.SimpleDateFormat;
import java.net.URL;
import java.io.File;
import java.io.InputStream;
import java.io.StringReader;
import java.io.PrintWriter;
import java.io.IOException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;

import org.xml.sax.InputSource;
import org.exolab.castor.jdo.JDO;
import org.exolab.castor.jdo.Database;
import org.exolab.castor.jdo.OQLQuery;
import org.exolab.castor.jdo.QueryResults;
import org.exolab.castor.mapping.Mapping;
import org.exolab.castor.mapping.MappingException;
import org.exolab.castor.persist.spi.Complex;
import org.exolab.castor.jdo.PersistenceException;
import org.exolab.castor.jdo.QueryException;
import org.exolab.castor.jdo.TransactionNotInProgressException;
import org.exolab.castor.jdo.ClassNotPersistenceCapableException;
import org.exolab.castor.jdo.DuplicateIdentityException;
import org.exolab.castor.jdo.ObjectNotFoundException;
import org.exolab.castor.jdo.LockNotGrantedException;
import org.exolab.castor.jdo.TransactionAbortedException;
import org.exolab.castor.jdo.ObjectModifiedException;
import org.exolab.castor.jdo.DatabaseNotFoundException;

import com.stdc.CnCcalc.util.*;

/**
 * This COUGAAR Plugin subscribes to tasks and logs them when agent is quiescent.
 * @version $Id: CnCcalcPlugin.java,v 1.46 2003/12/22 21:51:53 amit Exp $
 **/
public class CnCcalcPlugin extends ComponentPlugin
{

  public static final double MY_DOUBLE_MIN_VALUE =  0d;
  public static final double MY_DOUBLE_MAX_VALUE =  Float.MAX_VALUE;

  // Number of retrial attempts to database load
  private final static int NUM_OF_RETRIAL = 10;

  public static final int UNINITIALIZED         =  0;
  public static final int WAITING_FOR_NEW_RUN   =  1;
  public static final int WAITING_FOR_GLS       =  2;
  public static final int WAITING_TO_LOG        =  3;
  public static final int READY_TO_LOG          =  4;
  public static final int LOGGING               =  5;
  public static final int END_LOGGING           =  6;

  private static String[] STATE_NAMES;
  static {
    STATE_NAMES = new String[(END_LOGGING+1)];
    STATE_NAMES[UNINITIALIZED       ] = "UNINITIALIZED";
    STATE_NAMES[WAITING_FOR_NEW_RUN ] = "WAITING_FOR_NEW_RUN";
    STATE_NAMES[WAITING_FOR_GLS     ] = "WAITING_FOR_GLS";
    STATE_NAMES[WAITING_TO_LOG      ] = "WAITING_TO_LOG";
    STATE_NAMES[READY_TO_LOG        ] = "READY_TO_LOG";
    STATE_NAMES[LOGGING             ] = "LOGGING";
    STATE_NAMES[END_LOGGING         ] = "END_LOGGING";
  }

  private static final long WAITING_FOR_RUN_DELAY   = 300000l; //milliseconds
  private static final long IDLE_DELAY              = 300000l; //milliseconds
  private static final long BEFORE_GLS_DELAY        = 300000l; //milliseconds

  private static final int SET_GLS        = 1;
  private static final int SET_TODAY      = 2;
//private static final int SET_BEGIN_LOG  = 3;
//private static final int SET_END_LOG    = 4;
  private static final int SET_RUN_STATUS = 5;

  /** current reflection of Plugin state **/
  private com.stdc.CnCcalc.data.Status _agentStatus = null;
  private com.stdc.CnCcalc.util.CnCPluginState _pluginState =  null;

  private String _agentName = null;
  private String _hostname = null;
  private Alarm _timer;

  // The LoggingService
  private LoggingService _log;
  private BlackboardQueryService _blackboardQuery;
  private ServletService _servletService;
  private EventService _eventService;

  private IncrementalSubscription glsSubscription;   // GLS Tasks

  // For Castor
  private JDO _jdo = null;

  /**
   * Looking for object of class PersistingStatus
   **/ 
  private UnaryPredicate myStatePredicate = new UnaryPredicate() {
    public boolean execute(Object o) {
        return (o instanceof com.stdc.CnCcalc.util.CnCPluginState);
    }
  };

  /**
   * Looking for tasks with verb GetLogSupport
   */
  private UnaryPredicate glsPredicate = new UnaryPredicate() {
    public boolean execute(Object o) {
      if (o instanceof Task) {
        Task task = (Task) o;

        return (task.getVerb().equals(Constants.Verb.GetLogSupport));
      }
      return false;
    }
  };

  /**
   * Looking for object of class task
   **/ 
  private UnaryPredicate taskPredicate = new UnaryPredicate() {
    public boolean execute(Object o) {
        return (o instanceof Task);
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
   * Sets the ServletService, Called by introspection on start
   **/
  public void setServletService(ServletService ss) {
    _servletService = ss;
  }

  /**
   * Sets the EventService, Called by introspection on start
   **/
  public void setEventService(EventService es) {
    _eventService = es;
  }


  /**
   * Establish subscription for tasks and assets
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

      // register with servlet service
      try {
          _servletService.register("/cnccalc", new CnCcalcServlet());
      } catch (Exception e) {
          _log.error("Error registering servlet in " + _agentName, e);
      }

      try {
          int myState = UNINITIALIZED;
          myState = handleUninitialized();

          if ( myState == UNINITIALIZED ) {
              _log.error ( "Initialisation failed in " + _agentName );
          } else if ( myState == WAITING_FOR_NEW_RUN ) {
              myState = handleWaitingForNewRun();
          }
          if ( _log.isInfoEnabled() ) {
            _log.info("--------------------------------------------------------------------");
            _log.info(_agentName + ": after initialisation");
            String msg = "   Rehydrated=" + blackboard.didRehydrate() +
                         " Run=" + _pluginState._runId + " host=" + _hostname +
                         " State=" + STATE_NAMES[_pluginState._state] +
                         " RootOnly=" + _pluginState._onlyRoot +
                         " CommitCount=" + _pluginState._tasksPerCommit +
                         " DB Config=\n" + _pluginState._dbConfigStr +
                         " Is UA agent=" + _pluginState._isUA;
            _log.info(msg);
            _log.info("--------------------------------------------------------------------");
          }
      } catch ( Exception e ) {
          String msg = "Error initializing " + _agentName + " " + e.getMessage();
          _log.error(msg, e);
          throw new CnCcalcRuntimeException(msg);
      }

  }

  /**
   * Top level plugin execute loop.  Handle changes to my subscriptions.
   **/
  public void execute() {
    if (_log.isDebugEnabled()) {
        _log.debug(_agentName + ": " + "execute");
    }

    int myState =  getState();
    if ( myState < WAITING_FOR_NEW_RUN ) {
        return;
    }
    if ( (myState == WAITING_FOR_NEW_RUN) ) {
        myState = handleWaitingForNewRun();
        if ( (myState == WAITING_FOR_NEW_RUN) )
            return;
    }

    if (myState == WAITING_FOR_GLS ) {
        myState = handleWaitingForGLS();
        return;
    } 

    if ( myState == WAITING_TO_LOG ) {
        myState = handleWaitingToLog();
        return;
    }

    if ( myState == LOGGING ) {
        myState = handleLog();

        if ( myState == END_LOGGING ) {
          boolean isRunComplete = false;
          isRunComplete = isLoggingFinished(_pluginState._runId);
          if ( isRunComplete ) {
              sendCougaarEvent("STATUS", "state=LOGGING_COMPLETE");
              if ( _log.isInfoEnabled() )
                _log.info ( _agentName + ": state=LOGGING_COMPLETE" );
              if ( updateRun(_pluginState._runId, SET_RUN_STATUS) == false ) {
                if (_log.isInfoEnabled())
                  _log.info(_agentName + " Could not update runs table in SET_RUN_STATUS");
              }
          }
        }
    }

    if ( myState == END_LOGGING ) {
        myState = handleFinished();
        if ( (myState == WAITING_FOR_NEW_RUN) ) {
            cancelTimer();
            startTimer(3000l);
        }
    }

  }

  /**
   * Initialize plugin i.e. Load Configuration Properties,  Publish status on Blackboard.
   * Transition state to WAITING_FOR_NEW_RUN
   **/
  private int handleUninitialized() {
      int retval = UNINITIALIZED;
      if ( _pluginState == null ) {
        _pluginState = new com.stdc.CnCcalc.util.CnCPluginState();
        _pluginState._state = UNINITIALIZED;
        _pluginState._rehydrateCount = 0;
        if ( blackboard.didRehydrate() )
          _pluginState._rehydrateCount = 1;
   
        Collection params = getParameters();
        if ((params != null) && (params.size() != 0)) {
          String isUA = (String) params.iterator().next();
          if ( isUA.equals("UA_Agent") )
            _pluginState._isUA = true;
        }

        Properties props = CnCPluginConfig.getProperties();

        if ( props.getProperty("plugin.onlyRoot").equals("false") ) {
          _pluginState._onlyRoot = false;
        }else{
          _pluginState._onlyRoot = true;
        }
        if ( _log.isDebugEnabled() )
          _log.debug (_agentName + ": Logging only root tasks " + _pluginState._onlyRoot);

        _pluginState._dbConfigStr = CnCPluginConfig.getDbConfigString(props);
        if ( _log.isDebugEnabled() )
          _log.debug (_agentName + ": Database Conf file\n" + _pluginState._dbConfigStr);

        String commitCount = props.getProperty("database.commitCount");
        if ( commitCount != null ) {
          try {
            _pluginState._tasksPerCommit = Integer.parseInt(commitCount);
          } catch(NumberFormatException e) {
            _pluginState._tasksPerCommit = CnCPluginConfig.DEFAULT_COMMIT_COUNT;
          }
        }
        if ( _log.isDebugEnabled() )
          _log.debug (_agentName + ": Tasks per Commit " + _pluginState._tasksPerCommit);

        if ( _pluginState._dbConfigStr != null ) {
          _jdo = getJdo(_pluginState._dbConfigStr);
          if ( _jdo != null )
            retval = transitState(UNINITIALIZED, WAITING_FOR_NEW_RUN);
        }
      } else {
        retval = _pluginState._state;
        if ( _log.isErrorEnabled() )
            _log.error ("Agent " + _agentName + " called handleUninitialized in wrong state");
      }
      return retval;
  }

  private int handleWaitingForNewRun() {
    int myState = getState();
    if ( (myState == WAITING_FOR_NEW_RUN) ) {
        com.stdc.CnCcalc.data.Run newRun = null;
        newRun = getNewRun();
        if ( newRun == null ) {
            cancelTimer();
            startTimer(WAITING_FOR_RUN_DELAY);
            //return myState;
        } else {
            _pluginState._runId = newRun.getId();
            myState = transitState(WAITING_FOR_NEW_RUN, WAITING_FOR_GLS);
            if ( (_agentStatus = createStatusEntry()) == null ) {
              _log.error ( _agentName + " error creating status entry");
            }
            doSubsciptions();
            if ( _log.isInfoEnabled() ) {
                _log.info("Agent " + _agentName + 
                          " got run id=" + _pluginState._runId);
            }

            logCnCcalcState(myState);
            //cancelTimer();
            //startTimer(BEFORE_GLS_DELAY + getRandomDelay(0));
            //return myState;
        }
    } else {
        if ( _log.isErrorEnabled() )
            _log.error ( "Agent " + _agentName + " called handleWaitingForNewRun in wrong state=" + STATE_NAMES[myState] );
    }
    return myState;
  }

  private int handleWaitingForGLS() {
    int myState = getState();
    if ( (myState == WAITING_FOR_GLS) ) {
        //if ( isRunAborted(_pluginState._runId) ) {
        //    return abortRun(myState);
        //}
        // Change State
        //if ( _agentName.equals("NCA") ) {
            Collection glsTasks = _blackboardQuery.query(glsPredicate);
            if( !glsTasks.isEmpty() ) {
                blackboard.unsubscribe(glsSubscription);

                if ( updateRun(_pluginState._runId, SET_GLS) == false ) {
                  if (_log.isInfoEnabled())
                    _log.info(_agentName + " Could not update runs table in SET_GLS");
                }

                myState = transitState(WAITING_FOR_GLS, WAITING_TO_LOG);
                _agentStatus.setState(STATE_NAMES[myState]);
                updateStatusEntry();
                logCnCcalcState(myState);

                // Start Timer
                //cancelTimer();
                //startTimer(IDLE_DELAY);

                return myState;
            }
        //} else {
        //    if( isGLSReceived(_pluginState._runId) ) {
        //        if ( updateRun(_pluginState._runId, SET_GLS) == false ) {
        //          if (_log.isInfoEnabled())
        //            _log.info(_agentName + " Could not update runs table in SET_GLS");
        //        }

        //        myState = transitState(WAITING_FOR_GLS, WAITING_TO_LOG);
        //        _agentStatus.setState(STATE_NAMES[myState]);
        //        updateStatusEntry();
        //        logCnCcalcState(myState);

        //        cancelTimer();
        //        startTimer(IDLE_DELAY);

        //        return myState;
        //    }
        //}
        // Start Timer
        //if (_log.isDebugEnabled()) {
        //    _log.debug(_agentName + ": " + "still WAITING_FOR_GLS");
        //}
        //cancelTimer();
        //startTimer(BEFORE_GLS_DELAY + getRandomDelay(0));
    } else {
        if ( _log.isErrorEnabled() )
            _log.error ( "Agent " + _agentName + " called handleWaitingForGLS in wrong state=" + STATE_NAMES[myState] );
    }
    return myState;
  }

  private int handleWaitingToLog() {
    int myState = getState();
    if ( (myState == WAITING_TO_LOG) ) {
        if ( _log.isInfoEnabled() )
            _log.info ( "Agent " + _agentName + " in handleWaitingToLog");
        //if ( isRunAborted(_pluginState._runId) ) {
        //    return abortRun(myState);
        //} else {
        //  // Start Timer
        //  cancelTimer();
        //  startTimer(IDLE_DELAY);
        //}
    } else {
        if ( _log.isErrorEnabled() )
            _log.error ( "Agent " + _agentName + " called handleWaitingToLog in wrong state=" + STATE_NAMES[myState] );
    }
    return myState;
  }

  private int handleLog() {
    int myState = getState();
    if ( (myState == LOGGING) ) {
        if ( _agentName.equals("NCA") ) {
          if ( updateRun(_pluginState._runId, SET_TODAY) == false ) {
            if (_log.isInfoEnabled())
              _log.info(_agentName + " Could not update runs table in SET_TODAY");
          }
        }
        Collection allTasks = _blackboardQuery.query(taskPredicate);
        int taskCount = allTasks.size();
        if (_log.isInfoEnabled())
            _log.info(_agentName + " Writing tasks, total count on blackboard =" + taskCount );
        _agentStatus.setToday(getCurrentDate());
        _agentStatus.setTotalTasks(taskCount);
        _agentStatus.setLogStart(System.currentTimeMillis());
        updateStatusEntry();

        int loggedCount = 0;
        try {
            loggedCount = logTasks( allTasks );
        } catch ( PersistenceException e ) {
            _log.error(_agentName + " PersistenceException in logTasks", e);
        }

        myState = transitState(LOGGING, END_LOGGING);
        _agentStatus.setLoggedTasks(loggedCount);
        _agentStatus.setState(STATE_NAMES[_pluginState._state]);
        _agentStatus.setLogEnd(System.currentTimeMillis());
        updateStatusEntry();
        logCnCcalcState(myState);
    } else {
        if ( _log.isErrorEnabled() )
            _log.error ( _agentName + " called handleLog in wrong state=" + STATE_NAMES[myState] );
    }
    return myState;
  }

  private int handleFinished() {
    int myState = getState();
    if ( (myState == END_LOGGING) ) {
        if ( isRunFinished(_pluginState._runId) ) {
            _pluginState._runId = -1;
            myState = transitState(END_LOGGING, WAITING_FOR_NEW_RUN);
            _agentStatus = null;
            logCnCcalcState(myState);
        } else {
            cancelTimer();
            startTimer(WAITING_FOR_RUN_DELAY);
        }
    } else {
        if ( _log.isErrorEnabled() )
            _log.error ( _agentName + " called handleFinished in wrong state=" + STATE_NAMES[myState] );
    }
    return myState;
  }

  private int logTasks (Collection allTasks) throws PersistenceException {
    Task task = null;
    int loggedCount = 0;
    TaskConverter tc = new TaskConverter(_agentName);
    ArrayList taskList = new ArrayList(10);
    for (Iterator iter = allTasks.iterator(); iter.hasNext();)
    {
        task = (Task)iter.next();

        if ( _pluginState._onlyRoot ) {
            String verb = task.getVerb().toString();
            if ( _pluginState._isUA ) {
              if ( verb.equals("ProjectSupply") )
                continue;
            }
            if ( verb.equals("ProjectSupply") || 
                 verb.equals("Transport") || verb.equals("Supply") ) {
                if ( task.getSource().toAddress().equals(_agentName) ) {
                    String taskParentVerb = null;
                    UID taskParentUid = null;
                    String taskParentUidStr = null;
                    if ( (taskParentUid = task.getParentTaskUID()) == null  ||
                         (taskParentUidStr = taskParentUid.toString()) == null ) {
                        continue;
                    } else {
                        UniqueObject baseObj = findUniqueObjectWithUID(taskParentUidStr);
                        if ( baseObj != null ) {
                            if (baseObj instanceof Task) {
                                taskParentVerb = ((Task)baseObj).getVerb().toString();
                            } else {
                                _log.error("UniqueObject with parent task uid " + taskParentUidStr + " not a task");
                                continue;
                            }
                        } else {
                            if ( _log.isInfoEnabled() )
                                _log.info("Could not find parent task " + taskParentUidStr +
                                          " of task " + task.getUID().toString());
                            continue;
                        }
                    }
                    if ( verb.equals("Transport") ) {
                        if ( !taskParentVerb.equals("DetermineRequirements") )
                            continue;
                    } else if ( verb.equals("Supply") ) {
                        if ( !taskParentVerb.equals("GenerateProjections") )
                            continue;
                    } else if ( verb.equals("ProjectSupply") ) {
                        if ( !taskParentVerb.equals("GenerateProjections") )
                            continue;
                    } else {
                        continue;
                    }
                } else {
                    continue;
                }
            } else {
                continue;
            }
        }

        com.stdc.CnCcalc.data.Task myTask = tc.transformTask(_pluginState._runId, task);
        if ( myTask != null) {
            taskList.add(myTask);
            if ( taskList.size() >= _pluginState._tasksPerCommit ) {
              loggedCount += createTasks(taskList);
              taskList.clear();
            }
        }
    }
    
    if ( !taskList.isEmpty() ) {
      loggedCount += createTasks(taskList);
      taskList.clear();
    }
    return loggedCount;

  }

  private JDO getJdo(String dbCfgStr) {
      JDO jdo = null;

      if ( dbCfgStr != null ) {
          try {
            jdo = new JDO();
            jdo.loadConfiguration(
              new InputSource(new StringReader(dbCfgStr)),
              null,
              getClass().getClassLoader()
            );
            jdo.setDatabaseName( "Assessment" );
          } catch (MappingException me) {
            _log.error("MappingException in getJdo", me);
            jdo = null;
          }
      } else {
          _log.error("Database config string is  null");
      }

      return jdo;
  }

  private void doSubsciptions () {
      // Do the subscriptions
      //if ( _agentName.equals("NCA") ) {
          if ( getState() == WAITING_FOR_GLS )
              glsSubscription =
                (IncrementalSubscription)blackboard.subscribe(glsPredicate);
      //}
  }

  private void sendStateCougaarEvent(int state) {
      sendCougaarEvent("STATUS", "state=" + STATE_NAMES[state]);
  }

  private void logCnCcalcState(int state) {
      if ( _log.isInfoEnabled() )
          _log.info(_agentName + ": " + "state=" + STATE_NAMES[state]);
  }

  private void sendCougaarEvent(String type, String message ) {
      if ( _log.isInfoEnabled() )
          _log.info(message);
      if (_eventService != null) {
          if (_eventService.isEventEnabled()) {
              _eventService.event( "[" + type + "] " + message );
          }
      }
  }

  /** 
   *   Accomplish the state transition.
   *   Be careful and complain if we are in an inappropriate starting state.
   **/
  private int transitState(int expectedState, int endState) {
    synchronized (_pluginState) {
        if (_pluginState._state == expectedState) {
          _pluginState._state = endState;
        } else {
          String msg = _agentName + " can't transition." + 
                                    " CurrentState=" + STATE_NAMES[_pluginState._state] +
                                    " Expected=" + STATE_NAMES[expectedState] + 
                                    " EndState=" + STATE_NAMES[endState];
          _log.error(msg);
          throw new CnCcalcRuntimeException(msg);
        }
        return _pluginState._state;
    }
  }

  private int getState() {
    if ( _pluginState != null ) {
        synchronized (_pluginState) {
            return _pluginState._state;
        }
    } else {
            return -1;
    }
  }

  private Database getDatabase() {
    int trials = 1;
    boolean succeed = false;
    Database db = null;

    while ( !succeed && trials < NUM_OF_RETRIAL ) {
      trials++;
      db = null;
      try {
        db = _jdo.getDatabase();
        succeed = true;
      } catch( DatabaseNotFoundException de) {
        _log.error(_agentName + " Database not found in getDatabase", de);
        succeed = true;
      } catch( PersistenceException pe) {
        if (_log.isDebugEnabled())
          _log.debug(_agentName + " PersistenceException in getDatabase ("+trials+")", pe);
        succeed = false;
        try {
          Thread.currentThread().sleep( getRandomDelay(trials) );
        }catch(java.lang.InterruptedException ie){}
      }
    }
    if ( db == null ) {
      _log.error(_agentName + " Error getting database connection");
    }
    return db;
  }

  private com.stdc.CnCcalc.data.Status createStatusEntry() {
      com.stdc.CnCcalc.data.Status myStatus =  null;
      boolean found = false;
      Database db = null;

      db = getDatabase();
      if ( db == null ) {
          _log.error(_agentName + " error getting db connection in  createStatusEntry");
          return null;
      }
      if ( _pluginState._runId >= 0 ) {
        try {
          try {
            db.begin();
         
            try {
                Complex statusId = new Complex( new Long(_pluginState._runId), _agentName );
                try {
                    myStatus = (com.stdc.CnCcalc.data.Status)
                                    db.load( com.stdc.CnCcalc.data.Status.class, statusId );
                    found = true;
                } catch (ObjectNotFoundException oe) { 
                    if (_log.isDebugEnabled())
                        _log.debug(_agentName + " No Status entry in database");
                }
    
                if ( myStatus == null )
                    myStatus = new com.stdc.CnCcalc.data.Status();
    
                myStatus.setRunId(_pluginState._runId);
                myStatus.setAgent(_agentName);
                myStatus.setHostname(_hostname);
                myStatus.setState(STATE_NAMES[_pluginState._state]);
                _pluginState._rehydrateCount += myStatus.getRehydrated();
                myStatus.setRehydrated(_pluginState._rehydrateCount);
                myStatus.setToday(0);
                myStatus.setTotalTasks(0);
                myStatus.setLoggedTasks(0);
                myStatus.setLogStart(0);
                myStatus.setLogEnd(0);
    
                if (found == false) 
                    db.create(myStatus);
    
                db.commit();
            } catch ( PersistenceException e ) {
                _log.error(_agentName + " persistence error in createStatusEntry", e);
            }
            if ( db.isActive() )
              db.rollback();
          } catch ( Exception e ) {
            _log.error(_agentName + " error in  createStatusEntry", e);
          }
        } finally {
          try {
            db.close();
          } catch ( PersistenceException e ) {
            _log.error(_agentName+" error closing connection in createStatusEntry");
          } catch ( Exception e ) {
            _log.warn(_agentName+" error closing connection in createStatusEntry");
          }
        }
      } else {
          if ( _log.isInfoEnabled() ) {
              _log.info(_agentName + " no status entry since run id is " + _pluginState._runId);
          }
      }
      return myStatus;
  }


  private com.stdc.CnCcalc.data.Status getStatusEntry () {
    boolean succeed = false;
    int trials = 0;
    Database db = null;
    com.stdc.CnCcalc.data.Status myStatus =  null;

    db = getDatabase();
    if ( db == null ) {
      _log.error(_agentName + " error getting db connection in  getStatusEntry");
      return null;
    }
    try {
      try {
        db.begin();
        trials = 0;

        while ( !succeed && trials < NUM_OF_RETRIAL ) {
          trials++;
          try {
            Complex statusId = new Complex( new Long(_pluginState._runId), _agentName );
            myStatus = (com.stdc.CnCcalc.data.Status)
                          db.load( com.stdc.CnCcalc.data.Status.class, statusId );
            db.commit();
            succeed = true;
          } catch ( PersistenceException e ) {
            succeed = false;
            _log.warn(_agentName+" persistence error in  getStatusEntry", e);
            Thread.currentThread().sleep( getRandomDelay(trials) );
          }
        }
        if ( db.isActive() ) 
          db.rollback();
      
      } catch ( Exception e ) {
        _log.warn(_agentName + " error in  getStatusEntry", e);
      }
    } finally {
      try {
        db.close();
      } catch ( PersistenceException e ) {
        _log.warn(_agentName + " persistence error closing connection in  getStatusEntry ");
      } catch ( Exception e ) {
        _log.warn(_agentName+" error closing connection in getStatusEntry");
      }
    }
    if ( succeed == false) {
      _log.error(_agentName + " error loading status entry");
    }
    return myStatus;
  }

  private com.stdc.CnCcalc.data.Status updateStatusEntry () {
    boolean succeed = false;
    int trials = 0;
    Database db = null;
    com.stdc.CnCcalc.data.Status myStatus =  null;

    db = getDatabase();
    if ( db == null ) {
      _log.error(_agentName + " error getting db connection in  getStatusEntry");
      return null;
    }
    try {
      try {
        db.begin();
        trials = 0;

        while ( !succeed && trials < NUM_OF_RETRIAL ) {
          trials++;
          try {
            Complex statusId = new Complex( new Long(_pluginState._runId), _agentName );
            myStatus = (com.stdc.CnCcalc.data.Status)
                          db.load( com.stdc.CnCcalc.data.Status.class, statusId );
    
            myStatus.setState(_agentStatus.getState());
            myStatus.setRehydrated(_agentStatus.getRehydrated());
            myStatus.setToday(_agentStatus.getToday());
            myStatus.setTotalTasks(_agentStatus.getTotalTasks());
            myStatus.setLoggedTasks(_agentStatus.getLoggedTasks());
            myStatus.setLogStart(_agentStatus.getLogStart());
            myStatus.setLogEnd(_agentStatus.getLogEnd());
            db.commit();
            succeed = true;
          } catch ( LockNotGrantedException e ) {
            succeed = false;
            Thread.currentThread().sleep( getRandomDelay(trials) );
          } catch ( ObjectNotFoundException e ) {
            succeed = false;
            Thread.currentThread().sleep( getRandomDelay(trials) );
          } catch ( TransactionAbortedException e ) {
            succeed = false;
            Thread.currentThread().sleep( getRandomDelay(trials) );
          } catch ( PersistenceException e ) {
            succeed = false;
            _log.warn(_agentName+" persistence error in  updateStatusEntry "+e.getMessage());
            Thread.currentThread().sleep( getRandomDelay(trials) );
          }
        }
        if ( db.isActive() ) 
          db.rollback();
      
      } catch ( Exception e ) {
        _log.error(_agentName + " error while loading in updateStatusEntry");
      }
    } finally {
      try {
        db.close();
      } catch ( PersistenceException e ) {
        _log.warn(_agentName+" persistence error closing connection in updateStatusEntry");
      } catch ( Exception e ) {
        _log.warn(_agentName+" error closing connection in updateStatusEntry");
      }
    }
    if ( succeed == false) {
      _log.error(_agentName + " error updating status entry");
    }
    return myStatus;
  }

  private com.stdc.CnCcalc.data.Run getNewRun() {
      com.stdc.CnCcalc.data.Run run = null;
      Database db = null;

      db = getDatabase();
      if ( db == null ) {
        _log.error(_agentName + " error getting db connection in  getNewRun");
        return null;
      }

      try {
        OQLQuery      runsOql = null;
        QueryResults  results = null;

        db.begin();
    
        try {
          runsOql = db.getOQLQuery( "SELECT r FROM com.stdc.CnCcalc.data.Run r WHERE status = $1" );
          runsOql.bind( com.stdc.CnCcalc.data.Run.STATUS_NEW );
          results = runsOql.execute(Database.ReadOnly);

          if ( results.hasMore() ) {
              long run_id = 0;
              com.stdc.CnCcalc.data.Run tmp_run = null;
              while ( results.hasMore() ) {
                  tmp_run = (com.stdc.CnCcalc.data.Run) results.next();
                  if ( tmp_run.getId() > run_id ) {
                      run_id = tmp_run.getId();
                      run = tmp_run;
                  }
              }
          } else {
              if (_log.isDebugEnabled())
                  _log.debug(_agentName + " No new run found" );
          }
          db.commit();
        } catch ( PersistenceException e ) {
            _log.error(_agentName + " PersistenceException in getNewRun", e);
        }
        runsOql.close();
        if ( db.isActive() ) db.rollback();
      } catch ( Exception e ) {
          _log.error(_agentName + " Exception in getNewRun", e);
      } finally {
          try {
            db.close();
          } catch ( PersistenceException e ) {
            _log.error(_agentName + " persistence error closing connection in getNewRun");
          } catch ( Exception e ) {
            _log.warn(_agentName + " error closing connection in getNewRun");
          }
      }
      if (_log.isDebugEnabled()) {
          if ( run != null )
              _log.debug( _agentName + " Found new run " +
                          " RunNo=" + run.getId()  + " ExpId=" + run.getExperimentid() +
                          " Type=" + run.getType() + " Desc=" + run.getDescription() );
      }
      return run;
  }

  private boolean updateRun(long runid, int update) {
    boolean succeed = false;
    int trials = 0;
    Database db = null;
    com.stdc.CnCcalc.data.Run run = null;

    db = getDatabase();
    if ( db == null ) {
      _log.error(_agentName + " error getting db connection in  updateRun");
      return succeed;
    }
    try {
      try {
        db.begin();

        while ( !succeed && trials < NUM_OF_RETRIAL ) {
          trials++;
          try {
            run = (com.stdc.CnCcalc.data.Run)db.load(com.stdc.CnCcalc.data.Run.class, 
                                                   new Long(runid), Database.DbLocked );
            switch (update) {
              case SET_GLS:
                setGLS(run);
                break;
              case SET_TODAY:
                setToday(run);
                break;
              case SET_RUN_STATUS:
                setRunStatus(run);
                break;
              default:
                break;
            }
            db.commit();
            succeed = true;
          } catch ( LockNotGrantedException e ) {
            succeed = false;
            Thread.currentThread().sleep( getRandomDelay(trials) );
          } catch ( ObjectNotFoundException e ) {
            succeed = false;
            Thread.currentThread().sleep( getRandomDelay(trials) );
          } catch ( TransactionAbortedException e ) {
            succeed = false;
            Thread.currentThread().sleep( getRandomDelay(trials) );
          } catch ( PersistenceException e ) {
            succeed = false;
            _log.warn(_agentName+" persistence error in  updateRun "+e.getMessage());
            Thread.currentThread().sleep( getRandomDelay(trials) );
          }
        }
        if ( db.isActive() ) 
          db.rollback();
      
      } catch ( Exception e ) {
        _log.error(_agentName + " error loading run in updateRun " + e.getMessage());
      }
    } finally {
      try {
        db.close();
      } catch ( PersistenceException e ) {
        _log.error(_agentName + " error closing connection in updateRun");
      } catch ( Exception e ) {
        _log.warn(_agentName+" error closing connection in updateRun");
      }
    }
    if ( succeed == false) {
      _log.error(_agentName + " error loading run id=" + runid);
    }
    return succeed;
  }

  private void setGLS(com.stdc.CnCcalc.data.Run run) {
    run.setGls(run.getGls() + com.stdc.CnCcalc.data.Run.GLS_RECEIVED);
    if ( _agentName.equals("NCA") ) {
      run.setStartDate(getPlanStartDate());
    }
  }

  private void setToday(com.stdc.CnCcalc.data.Run run) {
      run.setToday(getCurrentDate());
  }

  private void setRunStatus(com.stdc.CnCcalc.data.Run run) {
    run.setStatus(com.stdc.CnCcalc.data.Run.STATUS_FINISHED);
  }

  private boolean isGLSReceived(long runid) {
      boolean retFlag = false;

      com.stdc.CnCcalc.data.Run run = getRun(runid);
      if ( run != null ) {
          if ( run.getGls() >= com.stdc.CnCcalc.data.Run.GLS_RECEIVED )
              retFlag = true; 
      } else {
          _log.error(_agentName + " isGLSReceived: Run is null for id=" + runid );
      }

      return retFlag;
  }

  private boolean isLoggingFinished(long runid) {
      boolean retVal = false;
      Database db = null;

      db = getDatabase();
      if ( db == null ) {
        _log.error(_agentName + " error getting db connection in  isLoggingFinished");
        return false;
      }

      try {
        OQLQuery      statusOql = null;
        QueryResults  statusResults = null;

        db.begin();
        try {
          statusOql = db.getOQLQuery("SELECT r FROM com.stdc.CnCcalc.data.Status r WHERE runId = $1 and state != $2");
          statusOql.bind( runid );
          statusOql.bind( "END_LOGGING" );
          statusResults = statusOql.execute(Database.ReadOnly);
          if ( statusResults.hasMore() ) {
            if (_log.isInfoEnabled())
              _log.info (_agentName +" found "+ statusResults.size() +" agents still logging");
            if (_log.isDebugEnabled()) {
              com.stdc.CnCcalc.data.Status status = null;
              String agentList = " ";
              while ( statusResults.hasMore() ) {
                status = (com.stdc.CnCcalc.data.Status) statusResults.next();
                agentList.concat(status.getAgent() + " ");
              }
              _log.debug(_agentName + " Following agents Still logging" + agentList );
            }
          } else {
              if (_log.isDebugEnabled())
                  _log.debug(_agentName + " found logging is complete");
              retVal = true;
          }
          db.commit();
          statusOql.close();
        } catch ( PersistenceException e ) {
            _log.error(_agentName + " error in isLoggingFinished " + e.getMessage());
        }
        if ( db.isActive() ) db.rollback();
      } catch ( Exception e ) {
          _log.error(_agentName + " error in isLoggingFinished", e);
      } finally {
        try {
          db.close();
        } catch ( PersistenceException e ) {
          _log.error(_agentName + " persistence error closing connection in isLoggingFinished");
        } catch ( Exception e ) {
          _log.warn(_agentName+" error closing connection in isLoggingFinished");
        }
      }
      return retVal;
  }

  private boolean isRunFinished(long runid) {
      boolean retFlag = false;

      com.stdc.CnCcalc.data.Run run = getRun(runid);
      if ( run != null ) {
          int runStatus = run.getStatus();
          if( runStatus == com.stdc.CnCcalc.data.Run.STATUS_FINISHED ||
              runStatus == com.stdc.CnCcalc.data.Run.STATUS_ABORTED )
          retFlag = true; 
      } else {
          _log.error(_agentName + " isRunFinished: Run is null for id=" + runid );
      }
      return retFlag;
  }

  private boolean isRunAborted(long runid) {
      boolean retFlag = false;

      com.stdc.CnCcalc.data.Run run = getRun(runid);
      if ( run != null ) {
          int runStatus = run.getStatus();
          if( runStatus == com.stdc.CnCcalc.data.Run.STATUS_ABORTED )
          retFlag = true; 
      } else {
          _log.error(_agentName + " isRunAborted: Run is null for id=" + runid );
      }
      return retFlag;
  }

  private int abortRun(int currentState) {
      int myState = transitState(currentState, END_LOGGING);

      if ( _agentName.equals("NCA") ) {
        if ( currentState == WAITING_FOR_GLS )
          blackboard.unsubscribe(glsSubscription);
      }

      _agentStatus.setState(STATE_NAMES[myState]);
      updateStatusEntry();
      logCnCcalcState(myState);

      // Start Timer
      cancelTimer();
      startTimer(3000l);

      return myState;
  }

  private com.stdc.CnCcalc.data.Run getRun(long runid) {
    boolean succeed = false;
    int trials = 0;
    Database db = null;
    com.stdc.CnCcalc.data.Run run = null;

    db = getDatabase();
    if ( db == null ) {
      _log.error(_agentName + " error getting db connection in  getRun");
      return null;
    }
    try {
      try {
        db.begin();
        trials = 0;

        while ( !succeed && trials < NUM_OF_RETRIAL ) {
          trials++;
          try {
            run = (com.stdc.CnCcalc.data.Run)db.load(com.stdc.CnCcalc.data.Run.class, 
                                                       new Long(runid));
            db.commit();
            succeed = true;
          } catch ( LockNotGrantedException e ) {
            succeed = false;
            Thread.currentThread().sleep( getRandomDelay(trials) );
          } catch ( ObjectNotFoundException e ) {
            succeed = false;
            Thread.currentThread().sleep( getRandomDelay(trials) );
          } catch ( TransactionAbortedException e ) {
            succeed = false;
            Thread.currentThread().sleep( getRandomDelay(trials) );
          } catch ( PersistenceException e ) {
            succeed = false;
            _log.warn(_agentName+" persistence error in  getRun "+e.getMessage());
            Thread.currentThread().sleep( getRandomDelay(trials) );
          }
        }
        if ( db.isActive() ) 
          db.rollback();
      
      } catch ( Exception e ) {
        _log.error(_agentName + " error in  getRun " + e.getMessage());
      }
    } finally {
      try {
        db.close();
      } catch ( PersistenceException e ) {
        _log.error(_agentName + " persistence error closing connection in  getRun");
      } catch ( Exception e ) {
        _log.warn(_agentName+" error closing connection in getRun");
      }
    }
    if ( succeed == false) {
      _log.error(_agentName + " error loading run id=" + runid);
    }
    return run;
  }


  private int createTasks(ArrayList taskList) throws PersistenceException {
    boolean succeed = false;
    int trials = 0;
    int loggedTasks = 0;
    String taskId = null;
    Database db = null;
    com.stdc.CnCcalc.data.Task myTask = null;

    db = getDatabase();
    if ( db == null ) {
      _log.error(_agentName + " error getting db connection in  createTasks");
      return 0;
    }
    try {
      db.begin();
      trials = 0;

      while ( !succeed && trials < NUM_OF_RETRIAL ) {
        loggedTasks = 0;
        trials++;
        try {
          for (Iterator task_iter = taskList.iterator(); task_iter.hasNext();) {
            myTask = (com.stdc.CnCcalc.data.Task)task_iter.next();
            taskId = myTask.getId();
      
            db.create(myTask);
      
            ArrayList assets = myTask.getAssets();
            com.stdc.CnCcalc.data.Asset asset = null;
            if ( assets != null ) {
              for (Iterator iter = assets.iterator(); iter.hasNext();) {
                asset = (com.stdc.CnCcalc.data.Asset)iter.next();
                if ( asset != null)
                  db.create(asset);
              }
            }
      
            com.stdc.CnCcalc.data.Preference myPref = myTask.getPreferences();
            if ( myPref != null ) {
              db.create(myPref);
            }
      
            com.stdc.CnCcalc.data.Preposition myPrep = myTask.getPrepositions();
            if ( myPrep != null ) {
              db.create(myPrep);
            }
      
            com.stdc.CnCcalc.data.PlanElement myPlan = myTask.getPlanelement();
            com.stdc.CnCcalc.data.AllocationResult estAR = null;
            com.stdc.CnCcalc.data.AllocationResult repAR = null;
            ArrayList estConsAspects = null;
            ArrayList estPhasedAspects = null;
            ArrayList repConsAspects = null;
            ArrayList repPhasedAspects = null;
            if ( myPlan != null ) {
              db.create(myPlan);
              estAR = myPlan.getEstimatedAR();
              repAR = myPlan.getReportedAR();
            }
      
            if ( estAR != null ) {
              db.create(estAR);
              estConsAspects = estAR.getConsolidatedAspects();
              estPhasedAspects = estAR.getPhasedAspects();
            }
            if ( repAR != null ) {
              db.create(repAR);
              repConsAspects = repAR.getConsolidatedAspects();
              repPhasedAspects = repAR.getPhasedAspects();
            }
      
            com.stdc.CnCcalc.data.AspectValue aspect = null;
            if ( estConsAspects != null ) {
              for (Iterator iter = estConsAspects.iterator(); iter.hasNext();) {
                aspect = (com.stdc.CnCcalc.data.AspectValue)iter.next();
                if ( aspect != null ) {
                  db.create(aspect);
                }
              }
            }
            com.stdc.CnCcalc.data.ARPhase phaseAspect = null;
            if ( estPhasedAspects != null ) {
              for (Iterator iter = estPhasedAspects.iterator(); iter.hasNext();) {
                phaseAspect = (com.stdc.CnCcalc.data.ARPhase)iter.next();
                if ( phaseAspect != null ) {
                  db.create(phaseAspect);
                }
              }
            }
      
            aspect = null;
            if ( repConsAspects != null ) {
              for (Iterator iter = repConsAspects.iterator(); iter.hasNext();) {
                aspect = (com.stdc.CnCcalc.data.AspectValue)iter.next();
                if ( aspect != null ) {
                  db.create(aspect);
                }
              }
            }
            phaseAspect = null;
            if ( repPhasedAspects != null ) {
              for (Iterator iter = repPhasedAspects.iterator(); iter.hasNext();) {
                phaseAspect = (com.stdc.CnCcalc.data.ARPhase)iter.next();
                if ( phaseAspect != null ) {
                  db.create(phaseAspect);
                }
              }
            }
      
            loggedTasks++;
          }
          db.commit();
          succeed = true;
        } catch ( PersistenceException e ) {
          succeed = false;
          Thread.currentThread().sleep( getRandomDelay(trials) );
        }
      }
      if ( db.isActive() ) 
        db.rollback();
    
    } catch ( Exception e ) {
      _log.error(_agentName + " error in  createTasks " + e.toString());
    } finally {
      try {
        db.close();
      } catch ( PersistenceException e ) {
        _log.error(_agentName + " error closing connection in  createTasks " + e.toString());
      }
    }
    if ( succeed == false) {
      _log.error(_agentName + " error creating " + loggedTasks + " tasks");
      return 0;
    }
    return loggedTasks;
  }

  private UniqueObject findUniqueObjectWithUID( final String itemUID)
  {
    if (itemUID == null) {
      // missing UID
      return null;
    }
    Collection col =
      _blackboardQuery.query(
          getUniqueObjectWithUIDPred(itemUID));
    if (col.size() < 1) {
      // item not found
      return null;
    }
    // take first match
    Iterator iter = col.iterator();
    UniqueObject uo = (UniqueObject)iter.next();

    if (iter.hasNext()) {
        if (_log.isErrorEnabled()) {
            _log.error("Multiple matches for "+itemUID+"?");
        }
    }

    return uo;
  }

  private UnaryPredicate getUniqueObjectWithUIDPred(final String uidFilter)
  {
    final UID findUID = UID.toUID(uidFilter);
    return new UnaryPredicate() {
      public boolean execute(Object o) {
        if (o instanceof UniqueObject) {
          UID u = ((UniqueObject)o).getUID();
          return
            findUID.equals(u);
        }
        return false;
      }
    };
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
       long expirationTime = System.currentTimeMillis() + delay;
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

    /**
     * Dates are formatted to "month_day_year_hour:minute[AM|PM]"
     */
//  private static java.text.SimpleDateFormat myDateFormat;
//  private static Date myDateInstance;
//  static {
//    myDateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss,SSS");
//    myDateInstance = new Date();
//  }

//  private static String getTimeString(long time) {
//    synchronized (myDateFormat) {
//      myDateInstance.setTime(time);
//      return
//        myDateFormat.format( myDateInstance );
//    }
//  }

  /** encodes a time interval in a min:sec:millis format */
  protected String getElapsedTime(long diff) {
    long min  = diff/60000l;
    long sec  = (diff - (min*60000l))/1000l;
    long millis = diff - (min*60000l) - (sec*1000l);
    return min + ":" + ((sec < 10) ? "0":"") + sec + ":" +
      ((millis < 10) ? "00": ((millis < 100) ? "0":"")) + millis;
  }

  private static long getPlanStartDate()
  {
    long ctime_msec = 0L;
    String cdate = System.getProperty("org.cougaar.core.agent.startTime");
    String timezone = System.getProperty("user.timezone");
    Logger logger = org.cougaar.util.log.LoggerFactory.getInstance().createLogger(CnCcalcPlugin.class);

    if (cdate == null ) {
      return ctime_msec;
    }
    TimeZone tz = null;
    if ( timezone == null ) {
      tz = TimeZone.getTimeZone("GMT");
    } else {
      tz = TimeZone.getTimeZone(timezone);
    }
    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyy");
    sdf.setTimeZone(tz);
    try {
      ctime_msec = sdf.parse(cdate).getTime();
    } catch (java.text.ParseException pe){
      if ( logger.isInfoEnabled() )
        logger.info ("Bad StartDate, could not parse", pe);
    }
    return ctime_msec;
  }

  private long getCurrentDate()
  {
    return getAlarmService().currentTimeMillis();
  }

  private long getRandomDelay(int count) {
    long base_delay = 2000l;
    long random_max = 5000l;
    return ( (long)((base_delay * count) + (random_max * Math.random()) ) );
  }

  private class CnCcalcServlet extends HttpServlet {

      protected void doGet(HttpServletRequest request, 
                           HttpServletResponse response) throws IOException, ServletException {
          if (!request.getParameterNames().hasMoreElements ()) {
              getUsage (response.getWriter());
              return; 
          }

          if (_log.isDebugEnabled()) {
              Enumeration paramNames = request.getParameterNames();
              StringBuffer sb = new StringBuffer("ServletBase got param # ");
              for (int i = 0; paramNames.hasMoreElements (); )
                  sb.append(i++ + " - " + paramNames.nextElement ());
          }

          String command = request.getParameter("command");
    
          if (command.equals("start")) {
              if ( _log.isInfoEnabled() )
                  _log.info(_agentName + " servlet received new_run command");

              int myState = getState();
              if ((myState == WAITING_TO_LOG) || (myState == WAITING_FOR_GLS)) {
                  try {
                      blackboard.openTransaction();
                      myState = transitState(myState, LOGGING);
                      _agentStatus.setState(STATE_NAMES[myState]);
                  } catch (Throwable t) {
                      _log.error ("Error: Uncaught exception in blackboard transaction", t);
                  } finally {
                      blackboard.closeTransaction();
                  }

                  response.setContentType("text/html");
                  try {
                      PrintWriter out = response.getWriter();
                      out.print(
                        "<HTML><HEAD><TITLE>CnCcalcServlet Status</TITLE></HEAD><BODY>\n"+
                        "<H2><CENTER>CnCcalcServlet Status " + _agentName + "</CENTER></H2><P>\n");
                      out.print("Received " + request.getParameter("command") );
                      out.print(" starting to log");
                      out.print("<P>\n</BODY></HTML>");
                      out.flush();
                      out.close();
                  } catch (java.io.IOException ie) {  
                      _log.error ("Error writing http response in " + _agentName, ie);
                  }

                  cancelTimer();
                  startTimer(getRandomDelay(0));

              } else {
                  try {
                      PrintWriter out = response.getWriter();
                      out.print(
                        "<HTML><HEAD><TITLE>CnCcalcServlet Status</TITLE></HEAD><BODY>\n"+
                        "<H2><CENTER>CnCcalcServlet Status " + _agentName + "</CENTER></H2><P>\n");
                      out.print("Received " + request.getParameter("command") );
                      out.print(" could not process since state is " +  STATE_NAMES[getState()]);
                      out.print("<P>\n</BODY></HTML>");
                      out.close();
                  } catch (java.io.IOException ie) {
                      _log.error ("Error writing http response in " + _agentName, ie);
                  }
              }
          }
      }

      public void doPost(HttpServletRequest request,
                         HttpServletResponse response) throws IOException, ServletException {
          doGet (request, response);
      }

      private void getUsage (PrintWriter out) {
          out.print("<HTML><HEAD><TITLE>CnCcalcServlet Usage</TITLE></HEAD><BODY>\n"+
                    "<H2><CENTER>CnCcalcServlet Usage</CENTER></H2><P>\n");
          out.print("Invalid usage, try \"?command=start\"");
          out.print("<P>\n</BODY></HTML>");
      }

  }

}
