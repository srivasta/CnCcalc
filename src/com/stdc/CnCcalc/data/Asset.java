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

public class Asset
{
    private long      _runId;

    private String    _taskId;

    private String    _id;

    private String    _classname;

    private String    _typePgId;

    private String    _itemPgId;

    private String    _supplyClass;

    private String    _supplyType;

    private boolean   _isAggregate;

    private int       _quantity;



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


    public String getClassname()
    {
        return _classname;
    }


    public void setClassname( String classname )
    {
        _classname = classname;
    }


    public String getTypePgId()
    {
        return _typePgId;
    }


    public void setTypePgId( String typeid )
    {
       this._typePgId = typeid;
    }


    public String getItemPgId()
    {
        return _itemPgId;
    }


    public void setItemPgId( String itemid )
    {
        this._itemPgId = itemid;
    }


    public String getSupplyClass()
    {
        return _supplyClass;
    }


    public void setSupplyClass( String supplyClass )
    {
        this._supplyClass = supplyClass;
    }


    public String getSupplyType()
    {
        return _supplyType;
    }


    public void setSupplyType( String supplyType )
    {
        this._supplyType = supplyType;
    }


    public boolean getIsAggregate()
    {
        return _isAggregate;
    }


    public void setIsAggregate( boolean isAgg )
    {
        _isAggregate = isAgg;
    }


    public int getQuantity()
    {
        return _quantity;
    }


    public void setQuantity( int quantity )
    {
        _quantity = quantity;
    }


    public String toString()
    {
        return _id;
    }

}
