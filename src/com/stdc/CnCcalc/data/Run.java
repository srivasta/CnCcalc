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

public class Run
{

    public static final int STATUS_NEW = 0;
    public static final int STATUS_ABORTED = 55;
    public static final int STATUS_FINISHED = 100;

    public static final int NO_GLS = 0;
    public static final int GLS_RECEIVED = 1;

    public static final int NOT_LOGGING = 0;
    public static final int LOGGING = 1;

    public static final int NOT_FINISHED = 0;
    public static final int FINISHED = 1;

    private long      _id;

    private int       _status;

    private int       _gls = NO_GLS;

//    private int       _logging = NOT_LOGGING;

//    private int       _finished = NOT_FINISHED;

    private String    _type;

    private String    _experimentid;

    private String    _description;

    private long      _startDate;

    private long      _today;

//    private long      _logStart;

//    private long      _logEnd;

    public long getId()
    {
        return _id;
    }


    public void setId( long id )
    {
        _id = id;
    }


    public int getStatus()
    {
        return _status;
    }


    public void setStatus( int stat )
    {
        _status = stat;
    }


    public int getGls()
    {
        return _gls;
    }


    public void setGls( int gls )
    {
        _gls = gls;
    }


//    public int getLogging()
//    {
//        return _logging;
//    }
//
//
//    public void setLogging( int logging )
//    {
//        _logging = logging;
//    }


//    public int getFinished()
//    {
//        return _finished;
//    }
//
//
//    public void setFinished( int finished )
//    {
//        _finished = finished;
//    }


    public String getType()
    {
        return _type;
    }


    public void setType( String type )
    {
        _type = type;
    }


    public String getExperimentid()
    {
        return _experimentid;
    }


    public void setExperimentid( String name )
    {
        _experimentid = name;
    }


    public String getDescription()
    {
        return _description;
    }


    public void setDescription( String desc )
    {
        _description = desc;
    }


    public long getStartDate()
    {
        return _startDate;
    }


    public void setStartDate( long t )
    {
        _startDate = t;
    }


    public long getToday()
    {
        return _today;
    }


    public void setToday( long t )
    {
        _today = t;
    }


//    public long getLogStart()
//    {
//        return _logStart;
//    }
//
//
//    public void setLogStart( long t )
//    {
//        _logStart = t;
//    }


//    public long getLogEnd()
//    {
//        return _logEnd;
//    }
//
//
//    public void setLogEnd( long t )
//    {
//        _logEnd = t;
//    }


    public String toString()
    {
        return _id + " " + _experimentid + " " + _type;
    }
}
