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

public class Task
{
    private long         _runId;

    private String       _id = null;

    private String       _agent = null;

    private String       _parentid = null;

    private String       _verb = null;

    private ArrayList    _assets = new ArrayList();

    private Preference   _preferences = null;

    private Preposition  _prepositions = null;

    private PlanElement  _planelement = null;


    public long getRunId()
    {
        return _runId;
    }


    public void setRunId( long r )
    {
        this._runId = r;
    }


    public String getId()
    {
        return _id;
    }


    public void setId( String id )
    {
        _id = id;
    }


    public String getAgent()
    {
        return _agent;
    }


    public void setAgent( String name )
    {
        _agent = name;
    }


    public String getParentid()
    {
        return _parentid;
    }


    public void setParentid( String id )
    {
        _parentid = id;
    }


    public String getVerb()
    {
        return _verb;
    }


    public void setVerb( String type )
    {
        _verb = type;
    }


    public ArrayList getAssets()
    {
        return _assets;
    }


    public void setAssets( ArrayList assets )
    {
        _assets = assets;
    }


    public Preference getPreferences()
    {
        return _preferences;
    }


    public void setPreferences( Preference prefs )
    {
        _preferences = prefs;
    }


    public Preposition getPrepositions()
    {
        return _prepositions;
    }


    public void setPrepositions( Preposition preps )
    {
        _prepositions = preps;
    }


    public PlanElement getPlanelement()
    {
        return _planelement;
    }


    public void setPlanelement( PlanElement planelement )
    {
        _planelement = planelement;
    }


    public String toString()
    {
        return _id;
    }

}
