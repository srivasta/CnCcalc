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

public class PlanElement
{
    private long   _runId;

    private String _taskId;

    private String _id;

    private String _type = null;

    private AllocationResult _estimatedAR = null;

    private AllocationResult _reportedAR = null;


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


    public void setTaskId( String id )
    {
        _taskId = id;
    }


    public String getId()
    {
        return _id;
    }


    public void setId( String id )
    {
        _id = id;
    }


    public String getType()
    {
        return _type;
    }


    public void setType( String type )
    {
        _type = type;
    }


    public AllocationResult getEstimatedAR()
    {
        return _estimatedAR;
    }


    public void setEstimatedAR( AllocationResult ar )
    {
        _estimatedAR = ar;
    }


    public AllocationResult getReportedAR()
    {
        return _reportedAR;
    }


    public void setReportedAR( AllocationResult ar )
    {
        _reportedAR = ar;
    }


    public String toString()
    {
        return _id;
    }

}
