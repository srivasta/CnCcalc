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
package com.stdc.CnCcalc.data;

import org.exolab.castor.jdo.TimeStampable;

public class Status implements TimeStampable
{

    private long   _runId = -1;

    private String _agent = null;

    private String _hostname = null;

    private String _state = null;

    private int    _rehydrated = 0;

    private long   _today = 0;

    private int    _totalTasks = 0;

    private int    _loggedTasks = 0;

    private long   _logStart = 0;

    private long   _logEnd = 0;

    private long   _timeStamp;


    public Status() {
    }

 
    public Status(long run, String agent, String host, String state) {
        _runId    = run;
        _agent    = agent;
        _hostname = host;
        _state    = state;
    }


    public long getRunId()
    {
        return _runId;
    }


    public void setRunId( long r )
    {
        this._runId = r;
    }


    public String getAgent()
    {
        return _agent;
    }


    public void setAgent( String name )
    {
        _agent = name;
    }


    public String getHostname()
    {
        return _hostname;
    }


    public void setHostname( String name )
    {
        _hostname = name;
    }


    public String getState()
    {
        return _state;
    }


    public void setState( String state )
    {
        _state = state;
    }


    public int getRehydrated()
    {
        return _rehydrated;
    }


    public void setRehydrated( int count )
    {
        _rehydrated = count;
    }


    public long getToday()
    {
        return _today;
    }


    public void setToday( long t )
    {
        _today = t;
    }


    public int getTotalTasks()
    {
        return _totalTasks;
    }


    public void setTotalTasks( int count )
    {
        _totalTasks = count;
    }


    public void addToTotalTasks( int count )
    {
        _totalTasks += count;
    }


    public int getLoggedTasks()
    {
        return _loggedTasks;
    }


    public void setLoggedTasks( int count )
    {
        _loggedTasks = count;
    }


    public long getLogStart()
    {
        return _logStart;
    }


    public void setLogStart( long t )
    {
        _logStart = t;
    }


    public long getLogEnd()
    {
        return _logEnd;
    }


    public void setLogEnd( long t )
    {
        _logEnd = t;
    }


    public long jdoGetTimeStamp()
    {
        return _timeStamp;
    }


    public void jdoSetTimeStamp( long timeStamp )
    {
        _timeStamp = timeStamp;
    }


    public String toString()
    {
        return _hostname + " " + _agent;
    }
}
