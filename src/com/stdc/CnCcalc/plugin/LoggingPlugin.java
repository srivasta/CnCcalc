/*
 * <copyright>
 *  Copyright 2001-2002 S/TDC
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
import org.cougaar.core.service.AgentIdentificationService;
import org.cougaar.core.blackboard.IncrementalSubscription;
import org.cougaar.planning.ldm.asset.Asset;
import org.cougaar.planning.ldm.asset.AggregateAsset;
import org.cougaar.planning.ldm.asset.AssetGroup;
import org.cougaar.planning.ldm.asset.TypeIdentificationPG;
import org.cougaar.util.UnaryPredicate;
import org.cougaar.core.util.UID;
import org.cougaar.planning.ldm.plan.*;

import java.util.Enumeration;
import java.util.Iterator;
import java.util.Vector;
import java.util.Collection;
import java.util.Date;


/**
 * This COUGAAR Plugin subscribes to tasks and logs them as they are added to blackboard.
 * @version $Id: LoggingPlugin.java,v 1.5 2003/03/04 18:20:29 amit Exp $
 **/
public class LoggingPlugin extends ComponentPlugin
{

    /**
     * Item type codes to show interface name instead of "*Impl".
     **/
    private static final int ITEM_TYPE_ALLOCATION     = 0;
    private static final int ITEM_TYPE_EXPANSION      = 1;
    private static final int ITEM_TYPE_AGGREGATION    = 2;
    private static final int ITEM_TYPE_DISPOSITION    = 3;
    private static final int ITEM_TYPE_ASSET_TRANSFER = 4;
    private static final int ITEM_TYPE_TASK           = 5;
    private static final int ITEM_TYPE_ASSET          = 6;
    private static final int ITEM_TYPE_WORKFLOW       = 7;
    private static final int ITEM_TYPE_OTHER          = 8;
    private static String[] ITEM_TYPE_NAMES;
    static {
      ITEM_TYPE_NAMES = new String[(ITEM_TYPE_OTHER+1)];
      ITEM_TYPE_NAMES[ITEM_TYPE_ALLOCATION     ] = "Allocation";
      ITEM_TYPE_NAMES[ITEM_TYPE_EXPANSION      ] = "Expansion";
      ITEM_TYPE_NAMES[ITEM_TYPE_AGGREGATION    ] = "Aggregation";
      ITEM_TYPE_NAMES[ITEM_TYPE_DISPOSITION    ] = "Disposition";
      ITEM_TYPE_NAMES[ITEM_TYPE_ASSET_TRANSFER ] = "AssetTransfer";
      ITEM_TYPE_NAMES[ITEM_TYPE_TASK           ] = "Task";
      ITEM_TYPE_NAMES[ITEM_TYPE_ASSET          ] = "Asset";
      ITEM_TYPE_NAMES[ITEM_TYPE_WORKFLOW       ] = "Workflow";
      ITEM_TYPE_NAMES[ITEM_TYPE_OTHER          ] = null;
    }


  private LoggingService log;

  private String _agentName = null;

  public void setLoggingService(LoggingService log) {
      this.log = log;
  }

  private IncrementalSubscription taskSubscription;   // Tasks that I'm interested in

  /**
   * Predicate that matches all Test tasks
   */
  private UnaryPredicate taskPredicate = new UnaryPredicate() {
    public boolean execute(Object o) {
      return (o instanceof Task);
    }
  };


  /**
   * Establish subscription for tasks and assets
   **/
  public void setupSubscriptions() {
    // get Agent Name
    if (agentId != null)
      _agentName = agentId.getAddress();

    taskSubscription =
      (IncrementalSubscription)getBlackboardService().subscribe(taskPredicate);
  }

  /**
   * Top level plugin execute loop.  Handle changes to my subscriptions.
   **/
  public void execute() {
    if (log.isDebugEnabled()) {
        log.debug("LoggingPlugin::execute");
    }

    Collection allTasks = taskSubscription.getAddedCollection();
    // process new tasks
    StringBuffer buf = new StringBuffer();
    for (Iterator iter = allTasks.iterator (); iter.hasNext();) {
        Task task = (Task)iter.next();

        if (log.isWarnEnabled()) {
  
            buf.setLength(0);

            buf.append(_agentName);
            buf.append("|");
  
  
            // Print the task UID
            UID taskUID = null;
            String taskUIDStr = null;
            if (((taskUID = task.getUID()) != null) &&
                ((taskUIDStr = taskUID.toString()) != null))
            {
                buf.append(taskUIDStr);
            } else {
                buf.append("MISSING");
            }
            buf.append("|");
  
            //Print the Verb
            Verb verb = task.getVerb();
            if (verb != null) {
                buf.append(verb.toString());
            } else {
                buf.append("MISSING");
            }
            buf.append("|");
  
  
            //Print parent task UID
            UID parentUID = null;
            String parentUIDStr = null;
            if (task instanceof MPTask) {
                //buf.append("MPTASK:");
                Enumeration parentsEn = ((MPTask)task).getParentTasks();
                if (parentsEn.hasMoreElements()) {
                    Task pt = null;
                    while (parentsEn.hasMoreElements()) {
                        pt = (Task)parentsEn.nextElement();
                        if (pt == null) {
                          buf.append("NULL");
                        } else if ( ((parentUID = pt.getUID()) == null) ||
                                    ((parentUIDStr = parentUID.toString()) == null)) {
                          buf.append("NOT_UNIQUE");
                        } else {
                          buf.append(parentUIDStr);
                        }
                        buf.append(",");
                    }
                    buf.deleteCharAt(buf.length() - 1);
                } else {
                    buf.append("NULL");
                }
            } else {
                if ( (parentUID = task.getParentTaskUID()) == null ) {
                    buf.append("NULL");
                } else if ( (parentUIDStr = parentUID.toString()) == null ) {
                    buf.append("NOT_UNIQUE");
                } else {
                    buf.append(parentUIDStr);
                }
            }
            buf.append("|");
  
  
            //Print Direct Object
            Asset doAsset = task.getDirectObject();
            UID assetUID = null;
            String assetUIDStr = null;
            if ( doAsset == null) {
                assetUIDStr = "NULL";
            } else {
                if (((assetUID = doAsset.getUID()) == null) ||
                    ((assetUIDStr = assetUID.toString()) == null)) {
                    if (doAsset instanceof AggregateAsset) {
                        assetUIDStr = "NONUID_Aggregate";
                    } else if (doAsset instanceof AssetGroup) {
                        assetUIDStr = "NONUID_AssetGroup";
                    } else {
                        assetUIDStr = "NONUID_Asset"; // +asset.getClass().getName();
                    }
                }
            }
            if ( assetUIDStr != null ) {
               buf.append(assetUIDStr);
            } else {
               buf.append("NULL");
            }
            buf.append("|");
  
  
            //Print Type ID(NSN no) for Direct Object
            Asset infoAsset = doAsset;
            if ( infoAsset != null ) {
                if ( infoAsset instanceof AggregateAsset) {
                    AggregateAsset agg = null;
                    do {
                        agg = (AggregateAsset)infoAsset;
                        infoAsset = agg.getAsset();
                    } while (infoAsset instanceof AggregateAsset);

                }
            }
            if ( infoAsset != null ) {
                TypeIdentificationPG tipg = infoAsset.getTypeIdentificationPG();
                if (tipg != null) {
                      buf.append(tipg.getTypeIdentification());
                } else {
                      buf.append("UNKNOWN");
                }
            } else {
                      buf.append("NULL");
            }
            buf.append("|");


//            if ( doAsset == null) {
//                buf.append("NULL");
//            } else {
//               // if asset is an aggregate, info_asset is the
//               // aggregate's asset which contains Type and Item info.
//                Asset info_asset;
//  //            int quantity;
//                if (doAsset instanceof AggregateAsset) {
//                    info_asset = doAsset;
//  //                quantity = 1;
//                    do {
//                      AggregateAsset agg = (AggregateAsset)info_asset;
//                      info_asset = agg.getAsset();
//  //                  quantity *= (int)agg.getQuantity();
//                    } while (info_asset instanceof AggregateAsset);
//                } else {
//                    info_asset = doAsset;
//  //                if (doAsset instanceof AssetGroup) {
//  //                  List assets = ((AssetGroup)doAsset).getAssets();
//  //                  quantity = ((assets != null) ? assets.size() : 0);
//  //                } else {
//  //                  quantity = 1;
//  //                }
//                }
//                // show type id
//                if ( info_asset != null ) {
//                    TypeIdentificationPG tipg = info_asset.getTypeIdentificationPG();
//                    if (tipg != null) {
//                      buf.append(tipg.getTypeIdentification());
//                    } else {
//                      buf.append("NULL");
//                    }
//                } else {
//                      buf.append("NULL");
//                }
//  
//                // show item id
//  //              ItemIdentificationPG iipg = info_asset.getItemIdentificationPG();
//  //              if (iipg != null) {
//  //                buf.append(iipg.getItemIdentification());
//  //              } else {
//  //                buf.append("MISSING_ITEMID");
//  //              }
//  //              buf.append("|");
//                // show quantity
//  //              buf.append(quantity);
//            }
//            buf.append("|");
  
  
            //Print Prefrences
            Enumeration enpref = task.getPreferences();
            String startTime = "NULL";
            String endTime = "NULL";
            String quantity = "NULL";
            while (enpref.hasMoreElements()) {
                Preference pref = (Preference)enpref.nextElement();
                int type = pref.getAspectType();
                if ( (type == AspectType.START_TIME) ||
                     (type == AspectType.END_TIME)   ||
                     (type == AspectType.QUANTITY) ) {
                    ScoringFunction sf = pref.getScoringFunction();
                    AspectScorePoint best = sf.getBest();
                    double bestVal = best.getValue();
                    if ( type == AspectType.START_TIME ) {
                        startTime = getTimeString((long)bestVal);
                    } else if (type == AspectType.END_TIME ) {
                        endTime = getTimeString((long)bestVal);
                    } else if (type == AspectType.QUANTITY ) {
                        quantity = Double.toString(bestVal);
                    }
  
                }
            }
            buf.append(startTime);
            buf.append("|");
            buf.append(endTime);
            buf.append("|");
            buf.append(quantity);
            buf.append("|");
  
//            if ((type == AspectType.START_TIME) ||
//                (type == AspectType.END_TIME)) {
//              if ((type == AspectType.END_TIME) &&
//                  (sf instanceof ScoringFunction.VScoringFunction)) {
//                bestString =
//                  "[" +
//                  "Earliest=" + getTimeString(getEarlyDate (sf)) +
//                  "" +
//                  "Best=" + getTimeString((long)bestVal) +
//                  "<br>" +
//                  "Latest=" + getTimeString(getLateDate (sf));
//              } else {
//                bestString = getTimeString((long)bestVal);
//              }
//              bestString = getTimeString((long)bestVal);
//            } else {
//              bestString = Double.toString(bestVal);
//            }
            //Print Prepositional Phrases
            Enumeration enprep = task.getPrepositionalPhrases();
            String toLocation = "NULL";
            String fromLocation = "NULL";
            String forOrg = "NULL";
            while (enprep.hasMoreElements()) {
                PrepositionalPhrase pp =
                  (PrepositionalPhrase)enprep.nextElement();
                if (pp != null) {
                   String prep = pp.getPreposition();
                   Object indObj = null;
                   if ( prep.equals("To") ) {
                       indObj = pp.getIndirectObject();
                       if ( (indObj != null) && (indObj instanceof Location) ) 
                           toLocation = indObj.toString();
                   } else if ( prep.equals("From") ) {
                       indObj = pp.getIndirectObject();
                       if ( (indObj != null) && (indObj instanceof Location) ) 
                           fromLocation = indObj.toString();
                   } else if ( prep.equals("For") ) {
                       indObj = pp.getIndirectObject();
                       if ( (indObj != null) && (indObj instanceof String) ) 
                           forOrg = indObj.toString();
                   }
                }
            }
            buf.append(forOrg);
            buf.append("|");
            buf.append(fromLocation);
            buf.append("|");
            buf.append(toLocation);
            buf.append("|");
 

            //Print Plan Element
            UID peU = null;
            String peUID = null;
            PlanElement pe = task.getPlanElement();
            if (pe == null) {
                buf.append("NULL|NULL|NULL|NULL|NULL");
            } else {
                if (((peU = pe.getUID()) == null) ||
                    ((peUID = peU.toString()) == null)) {
                  buf.append("NOT_UNIQUE");
                }else{
                  buf.append(peUID);
                }
                buf.append("|");
                buf.append(ITEM_TYPE_NAMES[getItemType(pe)]);
                buf.append("|");
  
                AllocationResult ar;
                if ((ar = pe.getEstimatedResult()) == null) {
                    buf.append("NULL|NULL|NULL");
                } else {
                    int[] arTypes = ar.getAspectTypes();
                    double[] arResults = ar.getResult();
                    String earStartTime = "NULL";
                    String earEndTime = "NULL";
                    String earQuantity = "NULL";
                    for (int i = 0; i < arTypes.length; i++) {
                        int arti = arTypes[i];
                        double arri = arResults[i];
                        switch (arti) {
                          case AspectType.START_TIME:
                            earStartTime = getTimeString((long)arri);
                            break;
                          case AspectType.END_TIME:
                            earEndTime = getTimeString((long)arri);
                            break;
                          case AspectType.QUANTITY:
                            earQuantity = Double.toString(arri);
                            break;
                          default:
                            break;
                        }
                   }
                   buf.append(startTime);
                   buf.append("|");
                   buf.append(endTime);
                   buf.append("|");
                   buf.append(quantity);
                }
            }

            log.warn(buf.toString());
        }
    }
  }

    /**
     * getItemType.
     * <p>
     * Replace with synchronized hashmap lookup on obj.getClass()?
     **/
    private static int getItemType(Object obj) {
      if (obj instanceof PlanElement) {
        if (obj instanceof Allocation) {
          return ITEM_TYPE_ALLOCATION;
        } else if (obj instanceof Expansion) {
          return ITEM_TYPE_EXPANSION;
        } else if (obj instanceof Aggregation) {
          return ITEM_TYPE_AGGREGATION;
        } else if (obj instanceof Disposition) {
          return ITEM_TYPE_DISPOSITION;
        } else if (obj instanceof AssetTransfer) {
          return ITEM_TYPE_ASSET_TRANSFER;
        } else {
          return ITEM_TYPE_OTHER;
        }
      } else if (obj instanceof Task) {
        return ITEM_TYPE_TASK;
      } else if (obj instanceof Asset) {
        return ITEM_TYPE_ASSET;
      } else if (obj instanceof Workflow) {
        return ITEM_TYPE_WORKFLOW;
      } else {
        return ITEM_TYPE_OTHER;
      }
    }

    /**
     * Dates are formatted to "month_day_year_hour:minute[AM|PM]"
     */
    private static java.text.SimpleDateFormat myDateFormat;
    private static Date myDateInstance;
//    private static java.text.FieldPosition myFieldPos;
    static {
      myDateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss,SSS");
      myDateInstance = new Date();
    }

    /**
     * getTimeString.
     * <p>
     * Formats time to String.
     */
    private static String getTimeString(long time) {
      synchronized (myDateFormat) {
        myDateInstance.setTime(time);
        return
          myDateFormat.format( myDateInstance );
      }
    }

}
