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


public class Preference
{
    private long   _runId;

    private String _taskId;

    private double  _preferredStartDate;

    private String  _scoringFnStartDate;

    private double  _prefScoreStartDate;

    private double  _preferredEndDate;

    private String  _scoringFnEndDate;

    private double  _prefScoreEndDate;

    private double  _preferredQuantity;

    private String  _scoringFnQuantity;

    private double  _prefScoreQuantity;

    private String  _scoringFnRate;

    private double  _preferredRate;

    private double  _prefScoreRate;


    public long getRunId() { return _runId; }

    public void setRunId( long r ) { this._runId = r; }

    public String getTaskId() { return _taskId; }

    public void setTaskId( String t ) { _taskId = t; }

    public double getPreferredStartDate() { return _preferredStartDate; }

    public void setPreferredStartDate( double val ) { _preferredStartDate = val; }

    public String getScoringFnStartDate() { return _scoringFnStartDate; }

    public void setScoringFnStartDate( String name ) { _scoringFnStartDate = name; }

    public double getPrefScoreStartDate() { return _prefScoreStartDate; }

    public void setPrefScoreStartDate( double val ) { _prefScoreStartDate = val; }

    public double getPreferredEndDate() { return _preferredEndDate; }

    public void setPreferredEndDate( double val ) { _preferredEndDate = val; }

    public String getScoringFnEndDate() { return _scoringFnEndDate; }

    public void setScoringFnEndDate( String name ) { _scoringFnEndDate = name; }

    public double getPrefScoreEndDate() { return _prefScoreEndDate; }

    public void setPrefScoreEndDate( double val ) { _prefScoreEndDate = val; }

    public double getPreferredQuantity() { return _preferredQuantity; }

    public void setPreferredQuantity( double val ) { _preferredQuantity = val; }

    public String getScoringFnQuantity() { return _scoringFnQuantity; }

    public void setScoringFnQuantity( String name ) { _scoringFnQuantity = name; }

    public double getPrefScoreQuantity() { return _prefScoreQuantity; }

    public void setPrefScoreQuantity( double val ) { _prefScoreQuantity = val; }

    public double getPreferredRate() { return _preferredRate; }

    public void setPreferredRate( double val ) { _preferredRate = val; }

    public String getScoringFnRate() { return _scoringFnRate; }

    public void setScoringFnRate( String name ) { _scoringFnRate = name; }

    public double getPrefScoreRate() { return _prefScoreRate; }

    public void setPrefScoreRate( double val ) { _prefScoreRate = val; }

    public String toString()
    {
        return ("Preference " + _preferredQuantity + _scoringFnQuantity + _prefScoreQuantity +
                            _preferredStartDate + _scoringFnStartDate + _prefScoreStartDate +
                                  _preferredEndDate + _scoringFnEndDate + _prefScoreEndDate +
                                            _preferredRate + _scoringFnRate + _prefScoreRate);
    }

}
