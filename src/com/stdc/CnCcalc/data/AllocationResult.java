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

public class AllocationResult
{
    private long    _runId;

    private String _taskId;

    private String _planId;

    private String    _type = null;

    private boolean _phased;

    private boolean _success;

    private float _confidence;

    private ArrayList _consolidatedAspects = null;

    private ArrayList _phasedAspects = null;


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


    public String getType()
    {
        return _type;
    }


    public void setType( String type )
    {
        _type = type;
    }


    public boolean getPhased()
    {
        return _phased;
    }


    public void setPhased( boolean phased )
    {
        _phased = phased;
    }


    public boolean getSuccess()
    {
        return _success;
    }


    public void setSuccess( boolean success )
    {
        _success = success;
    }


    public float getConfidence()
    {
        return _confidence;
    }


    public void setConfidence( float confidence )
    {
        _confidence = confidence;
    }


    public ArrayList getConsolidatedAspects()
    {
        return _consolidatedAspects;
    }


    public void setConsolidatedAspects( ArrayList cav )
    {
        _consolidatedAspects = cav;
    }


    public ArrayList getPhasedAspects()
    {
        return _phasedAspects;
    }


    public void setPhasedAspects( ArrayList pav )
    {
        _phasedAspects = pav;
    }


    public String toString()
    {
        return "AR TaskId=" + _taskId + " PlanId=" + _planId + " " + _type;
    }

}
