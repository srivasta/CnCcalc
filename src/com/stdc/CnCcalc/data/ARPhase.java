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

import java.util.ArrayList;

public class ARPhase
{
    private long    _runId;

    private String _taskId;

    private String _planId;

    private String _arType = null;

    private int  _phaseNo;

    private String _aspecttype;

    private double _value;

    private double _score;


    public long getRunId()
    {
        return _runId;
    }


    public void setRunId( long r )
    {
        this._runId = r;
    }


    public String getTaskId()
    {
        return _taskId;
    }


    public void setTaskId( String t )
    {
        _taskId = t;
    }


    public String getPlanId()
    {
        return _planId;
    }


    public void setPlanId( String p )
    {
        _planId = p;
    }


    public String getArType()
    {
        return _arType;
    }


    public void setArType( String type )
    {
        _arType = type;
    }


    public int getPhaseNo()
    {
        return _phaseNo;
    }


    public void setPhaseNo( int phaseNo )
    {
        _phaseNo = phaseNo;
    }


    public String getAspecttype()
    {
        return _aspecttype;
    }


    public void setAspecttype( String type )
    {
        _aspecttype = type;
    }


    public double getValue()
    {
        return _value;
    }


    public void setValue( double val )
    {
        _value = val;
    }


    public double getScore()
    {
        return _score;
    }


    public void setScore( double val )
    {
        _score = val;
    }


    public String toString()
    {
        return ("Phased Aspect " + _aspecttype + "=" + _value) ;
    }

}
