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


public class Preposition
{
    private long    _runId;

    private String  _taskId;

    private String  _fromLocation = null;

    private String  _forOrganization = null;

    private String  _toLocation = null;

    private String  _maintainType = null;

    private String  _maintainTypeid = null;

    private String  _maintainItemid = null;

    private String  _maintainNomenclature = null;

    private String  _ofType = null;


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


    public String getFromLocation()
    {
        return _fromLocation;
    }


    public void setFromLocation( String val )
    {
        _fromLocation = val;
    }


    public String getForOrganization()
    {
        return _forOrganization;
    }


    public void setForOrganization( String val )
    {
        _forOrganization = val;
    }


    public String getToLocation()
    {
        return _toLocation;
    }


    public void setToLocation( String val )
    {
        _toLocation = val;
    }


    public String getMaintainType()
    {
        return _maintainType;
    }


    public void setMaintainType( String val )
    {
        _maintainType = val;
    }


    public String getMaintainTypeid()
    {
        return _maintainTypeid;
    }


    public void setMaintainTypeid( String val )
    {
        _maintainTypeid = val;
    }


    public String getMaintainItemid()
    {
        return _maintainItemid;
    }


    public void setMaintainItemid( String val )
    {
        _maintainItemid = val;
    }


    public String getMaintainNomenclature()
    {
        return _maintainNomenclature;
    }


    public void setMaintainNomenclature( String val )
    {
        _maintainNomenclature = val;
    }


    public String getOfType()
    {
        return _ofType;
    }


    public void setOfType( String val )
    {
        _ofType = val;
    }


    public String toString()
    {
        return "Preposition = " + _fromLocation + " " + _forOrganization + " " +
               _toLocation + " " + _maintainType + " " + _maintainTypeid + " " +
               _maintainItemid + " " + _maintainNomenclature + " " + _ofType;
    }
}
