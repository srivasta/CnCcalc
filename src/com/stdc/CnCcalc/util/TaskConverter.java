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
package com.stdc.CnCcalc.util;

import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Collections;
import java.lang.reflect.Constructor;

import org.cougaar.planning.ldm.plan.*;
import org.cougaar.planning.ldm.asset.*;
import org.cougaar.glm.ldm.plan.GeolocLocation;
import org.cougaar.glm.ldm.plan.AlpineAspectType;
import org.cougaar.planning.ldm.measure.Rate;
import org.cougaar.glm.ldm.asset.SupplyClassPG;
import org.cougaar.core.util.UID;
import org.cougaar.util.log.LoggerFactory;
import org.cougaar.util.log.Logger;

public class TaskConverter
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
  private static Map _minAspectMap = Collections.synchronizedMap(new HashMap(3));
  private static Map _maxAspectMap = Collections.synchronizedMap(new HashMap(3));


  private Logger _log;
  private String _agentName = null;

  public TaskConverter(String agent) {
      this._agentName = agent;
      this._log = LoggerFactory.getInstance().createLogger(TaskConverter.class);
  }

  public void setAgent(String agent) {
      this._agentName = agent;
  }

  public com.stdc.CnCcalc.data.Task transformTask(long runId, Task task) {
    com.stdc.CnCcalc.data.Task myTask = getMyTask(runId, task);
    if ( myTask == null) {
        return null;
    }

    Enumeration enpref = task.getPreferences();
    HashMap prefMap = new HashMap();
    com.stdc.CnCcalc.data.Preference myPreference = getMyPreference(myTask, enpref, prefMap);
    myTask.setPreferences(myPreference);

    Enumeration enprep = task.getPrepositionalPhrases();
    com.stdc.CnCcalc.data.Preposition myPreposition = getMyPreposition(myTask, enprep);
    myTask.setPrepositions(myPreposition);

    //Create Plan Element
    PlanElement pe = null;
    com.stdc.CnCcalc.data.PlanElement myPlanelement = null;
    if ( (pe = task.getPlanElement()) != null ) {
       myPlanelement = getMyPlanElement(myTask, pe, prefMap);
       if ( myPlanelement != null ) {
            myTask.setPlanelement(myPlanelement);
       }
    }
 
    Asset directObj = null;
    ArrayList assetList = null;
    if ( (directObj = task.getDirectObject()) != null ) {
        assetList = getMyDirectObject(myTask, directObj);
        if ( assetList != null )
            myTask.setAssets(assetList);
    }

    return myTask;
  }

  private com.stdc.CnCcalc.data.Task getMyTask(long runId, Task task) {
      com.stdc.CnCcalc.data.Task myTask = null;
      // Print the task UID
      UID taskUID = null;
      String taskUIDStr = null;
      if (((taskUID = task.getUID()) != null) &&
          ((taskUIDStr = taskUID.toString()) != null))
      {
          if (task instanceof MPTask) {
             myTask = new com.stdc.CnCcalc.data.MPTask();
          } else {
             myTask = new com.stdc.CnCcalc.data.Task();
          }

          myTask.setId(taskUIDStr);
          myTask.setRunId(runId);
      } else {
          _log.error("Found a task with missing UID");
          return null;
      }
  
      myTask.setAgent(_agentName);
  
      //Print the Verb
      Verb verb = task.getVerb();
      if (verb != null) {
          myTask.setVerb(verb.toString());
      } else {
          myTask.setVerb("MISSING");
      }
  
  
      //Print parent task UID
      UID parentUID = null;
      String parentUIDStr = null;
      if (task instanceof MPTask) {
          if (_log.isDebugEnabled())
              _log.debug(taskUIDStr + " has multiple parents (MPTask)");

//          myTask.setParentid("MPTask");
//          StringBuffer queryBuf = new StringBuffer("CALL SQL select id from tasks where id in (")
//
//          Enumeration parentsEn = ((MPTask)task).getParentTasks();
//          if (parentsEn.hasMoreElements()) {
//              Task pt = null;
//              while (parentsEn.hasMoreElements()) {
//                  pt = (Task)parentsEn.nextElement();
//                  if (pt != null) {
//                    if ( ((parentUID = pt.getUID()) != null) &&
//                         ((parentUIDStr = parentUID.toString()) != null) ) {
//                        queryBuf.append( " '" + parentUIDStr + "'," );
//                    }
//                  }
//              }
//              queryBuf.setCharAt(buf.length() - 1, ')');
//         }
//         queryBuf.append(" AS com.stdc.CnCcalc.data.Task");
      } else {
          parentUID = task.getParentTaskUID();
          if ( parentUID != null ) {
              if ( (parentUIDStr = parentUID.toString()) == null ) {
                  myTask.setParentid("NOT_UNIQUE");
              } else {
                  myTask.setParentid(parentUIDStr);
              }
          }
      }
      return myTask;
  }

  private ArrayList getMyDirectObject(com.stdc.CnCcalc.data.Task myTask, Asset directObj) {
      com.stdc.CnCcalc.data.Asset myAsset = null;
      ArrayList assetList = null;

      if ( directObj  != null ) {
          if (directObj instanceof AssetGroup) {
              List assets = ((AssetGroup)directObj).getAssets();
              int nAssets = ((assets != null) ? assets.size() : 0);
              assetList = new ArrayList(nAssets);
              for (int i = 0; i < nAssets; i++) {
                  Asset asset = (Asset)assets.get(i);

                  myAsset = getMyAsset(myTask, asset);
                  if ( myAsset != null )
                      assetList.add(myAsset);
              }
          } else {
              myAsset = getMyAsset(myTask, directObj);
              if ( myAsset != null ) {
                  assetList = new ArrayList(1);
                  assetList.add(myAsset);
              }
          }
      }
      return assetList;
  }

  private com.stdc.CnCcalc.data.Asset getMyAsset( com.stdc.CnCcalc.data.Task myTask, Asset asset) {
      com.stdc.CnCcalc.data.Asset myAsset = null;

      if ( asset != null) {
          UID assetUid = null;
          String assetUidStr = null;
          if (((assetUid = asset.getUID()) != null) &&
              ((assetUidStr = assetUid.toString()) != null))
          {
              myAsset = new com.stdc.CnCcalc.data.Asset();
              myAsset.setId(assetUidStr);
              myAsset.setTaskId(myTask.getId());
              myAsset.setRunId(myTask.getRunId());
          } else {
              _log.error("Found a task with missing UID");
              return null;
          }
  
          // if asset is an aggregate, infoAsset is the
          // asset which contains Type and Item info.
          Asset infoAsset = asset;
          int quantity = 1;
          boolean isAggregateAsset = (asset instanceof AggregateAsset);
          if (isAggregateAsset) {
              do {
                AggregateAsset agg = (AggregateAsset)infoAsset;
                quantity *= (int)agg.getQuantity();
                infoAsset = agg.getAsset();
              } while (infoAsset instanceof AggregateAsset);
          }

          myAsset.setClassname(infoAsset.getClass().getName());

          myAsset.setIsAggregate(isAggregateAsset);

          myAsset.setQuantity(quantity);

          TypeIdentificationPG typePG = infoAsset.getTypeIdentificationPG();
          if (typePG != null) {
              myAsset.setTypePgId(typePG.getTypeIdentification());
          }

          ItemIdentificationPG itemPG = infoAsset.getItemIdentificationPG();
          if (itemPG != null) {
              myAsset.setItemPgId(itemPG.getItemIdentification());
          }

          SupplyClassPG supClassPG = 
                         (SupplyClassPG)infoAsset.searchForPropertyGroup(SupplyClassPG.class);
          if (supClassPG != null) {
              myAsset.setSupplyClass(supClassPG.getSupplyClass());
              myAsset.setSupplyType(supClassPG.getSupplyType());
          }

      }
      return myAsset;
  }

  private com.stdc.CnCcalc.data.Preference getMyPreference(com.stdc.CnCcalc.data.Task myTask,
                                                           Enumeration enpref, HashMap prefMap)
  {
    com.stdc.CnCcalc.data.Preference myPref = new com.stdc.CnCcalc.data.Preference();
    myPref.setTaskId(myTask.getId());
    myPref.setRunId(myTask.getRunId());
    while (enpref.hasMoreElements()) {
      Preference pref = (Preference)enpref.nextElement();
      if (pref != null) {
        int aspectType = pref.getAspectType();
        ScoringFunction sf = pref.getScoringFunction();
        AspectScorePoint bestPoint = sf.getBest();
        AspectValue bestAspectValue = bestPoint.getAspectValue();

        switch (aspectType) {
          case AlpineAspectType.START_TIME:
            myPref.setPreferredStartDate(bestAspectValue.getValue());
            myPref.setScoringFnStartDate(sf.getClass().getName());
            myPref.setPrefScoreStartDate(bestPoint.getScore());
            prefMap.put(new Integer(aspectType), sf);
            break;
          case AlpineAspectType.END_TIME:
            myPref.setPreferredEndDate(bestAspectValue.getValue());
            myPref.setScoringFnEndDate(sf.getClass().getName());
            myPref.setPrefScoreEndDate(bestPoint.getScore());
            prefMap.put(new Integer(aspectType), sf);
            break;
          case AlpineAspectType.QUANTITY:
            myPref.setPreferredQuantity(bestAspectValue.getValue());
            myPref.setScoringFnQuantity(sf.getClass().getName());
            myPref.setPrefScoreQuantity(bestPoint.getScore());
            prefMap.put(new Integer(aspectType), sf);
            break;
          case AlpineAspectType.DEMANDRATE:
            myPref.setPreferredRate(bestAspectValue.getValue());
            myPref.setScoringFnRate(sf.getClass().getName());
            myPref.setPrefScoreRate(bestPoint.getScore());
            prefMap.put(new Integer(aspectType), sf);
            break;
          default:
            break;
        }
      }
    }
    return myPref;
  }

  private com.stdc.CnCcalc.data.Preposition getMyPreposition(com.stdc.CnCcalc.data.Task myTask,
                                                             Enumeration preps)
  {
    com.stdc.CnCcalc.data.Preposition myPrep = new com.stdc.CnCcalc.data.Preposition();
    myPrep.setTaskId(myTask.getId());
    myPrep.setRunId(myTask.getRunId());
    while (preps.hasMoreElements()) {
      PrepositionalPhrase prep = (PrepositionalPhrase)preps.nextElement();
      if (prep != null) {
        String phrase = prep.getPreposition();
        Object indObj = prep.getIndirectObject();
         
        if ( phrase == null || indObj == null ) {
          _log.warn(_agentName + " Phrase or Indirect Object is null task " + myTask.getId());
          continue;
        }
        if ( phrase.equals("From") ) {
          if ( indObj instanceof GeolocLocation ) {
            GeolocLocation loc = (GeolocLocation)indObj;
            myPrep.setFromLocation(loc.getGeolocCode());
          } else {
            _log.warn(_agentName + " Invalid value for From Preposition  " + myTask.getId());
          }
        } else if ( phrase.equals("For") ) {
          if ( indObj instanceof String ) {
            myPrep.setForOrganization((String)indObj);
          } else {
            _log.warn(_agentName + " Invalid value for For Preposition  " + myTask.getId());
          }
        } else if ( phrase.equals("To") ) {
          if ( indObj instanceof GeolocLocation ) {
            GeolocLocation loc = (GeolocLocation)indObj;
            myPrep.setToLocation(loc.getGeolocCode());
          } else {
            _log.warn(_agentName + " Invalid value for To Preposition  " + myTask.getId());
          }
        } else if ( phrase.equals("Maintaining") ) {
          if ( indObj instanceof org.cougaar.logistics.plugin.inventory.MaintainedItem ) {
            org.cougaar.logistics.plugin.inventory.MaintainedItem mi = 
              (org.cougaar.logistics.plugin.inventory.MaintainedItem)indObj;
            myPrep.setMaintainType(mi.getMaintainedItemType());
            myPrep.setMaintainTypeid(mi.getTypeIdentification());
            myPrep.setMaintainItemid(mi.getItemIdentification());
            myPrep.setMaintainNomenclature(mi.getNomenclature());
          } else {
            _log.warn(_agentName + " Invalid value for Maintaining Preposition  " + myTask.getId());
          }
        } else if ( phrase.equals("OfType") ) {
          if ( indObj instanceof String ) {
            myPrep.setOfType((String)indObj);
          } else {
            _log.warn(_agentName + " Invalid value for OfType Preposition  " + myTask.getId());
          }
        } else {
          _log.info(_agentName + " Unknown preposition " + phrase + " in " + myTask.getId());
        }
      }
    }
    return myPrep;
  }

  private com.stdc.CnCcalc.data.PlanElement getMyPlanElement(com.stdc.CnCcalc.data.Task myTask, PlanElement pe, HashMap prefMap) {
      UID peU = null;
      String peUID = null;
      com.stdc.CnCcalc.data.PlanElement myPlanelement = null;
      if (pe != null) {
          if (((peU = pe.getUID()) == null) ||
              ((peUID = peU.toString()) == null)) {
            //myPlanelement.setId("NOT_UNIQUE");
            _log.error("Found a planelement with missing UID");
            return null;
          } else {
            myPlanelement = new com.stdc.CnCcalc.data.PlanElement();
            myPlanelement.setTaskId(myTask.getId());
            myPlanelement.setRunId(myTask.getRunId());
            myPlanelement.setId(peUID);
          }

          myPlanelement.setType(ITEM_TYPE_NAMES[getItemType(pe)]);
 
          com.stdc.CnCcalc.data.AllocationResult myEstimatedAR = null;
          AllocationResult estAR = pe.getEstimatedResult();
          if ( estAR != null ) {
              myEstimatedAR = getMyAllocationResult(myPlanelement, estAR, prefMap, "ESTIMATED");
              if ( myEstimatedAR != null ) {
                  myPlanelement.setEstimatedAR(myEstimatedAR);
              }
          }

          com.stdc.CnCcalc.data.AllocationResult myreportedAR = null;
          AllocationResult repAR = pe.getReportedResult();
          if ( repAR != null ) {
              myreportedAR = getMyAllocationResult(myPlanelement, repAR, prefMap, "REPORTED");
              if ( myreportedAR != null ) {
                  myPlanelement.setReportedAR(myreportedAR);
              }
          }
      }
      return myPlanelement;
  }

  private com.stdc.CnCcalc.data.AllocationResult getMyAllocationResult(com.stdc.CnCcalc.data.PlanElement myPlanElement, AllocationResult ar, HashMap prefMap, String type) {
      com.stdc.CnCcalc.data.AllocationResult myAllocationResult = null;
      if ( ar != null ) {
          myAllocationResult = new com.stdc.CnCcalc.data.AllocationResult();
          myAllocationResult.setType(type);
          myAllocationResult.setPlanId(myPlanElement.getId());
          myAllocationResult.setTaskId(myPlanElement.getTaskId());
          myAllocationResult.setRunId(myPlanElement.getRunId());
          myAllocationResult.setSuccess(ar.isSuccess());
          myAllocationResult.setConfidence((float)ar.getConfidenceRating());
          boolean isPhased = ar.isPhased();

          ArrayList myConsolidatedAspects = getMyConsolidatedAspects(myAllocationResult, ar.getAspectValueResults(), prefMap);
          myAllocationResult.setConsolidatedAspects(myConsolidatedAspects);

          ArrayList myPhasedAspects = null;
          List phasedList = null;
          if ( isPhased ) {
              phasedList = ar.getPhasedAspectValueResults();
              if ( phasedList.size() == 1 )
                isPhased = false;
          } else {
              phasedList = new ArrayList(1);
              phasedList.add(ar.getAspectValueResults());
              
          }
          myAllocationResult.setPhased(isPhased);
          myPhasedAspects = 
              getMyPhasedAspects(myAllocationResult, phasedList, prefMap);
          myAllocationResult.setPhasedAspects(myPhasedAspects);
      }

      return myAllocationResult;
  }

  private ArrayList getMyConsolidatedAspects (com.stdc.CnCcalc.data.AllocationResult myAR, AspectValue[] avResults, HashMap prefMap) {
      ArrayList aspects = null;
      if (  avResults.length > 0 ) {
          aspects = new ArrayList();
      }
      for (int i = 0; i < avResults.length; i++) {
          AspectValue av = avResults[i];
          int aspectType = av.getAspectType();
          Integer mapKey = new Integer(aspectType);
          if ( prefMap.containsKey(mapKey) ){
              com.stdc.CnCcalc.data.AspectValue myAspect = new com.stdc.CnCcalc.data.AspectValue();

              myAspect.setArType(myAR.getType());
              myAspect.setPlanId(myAR.getPlanId());
              myAspect.setTaskId(myAR.getTaskId());
              myAspect.setRunId(myAR.getRunId());
              myAspect.setAspecttype(AspectValue.aspectTypeToString(aspectType));
              myAspect.setValue(av.getValue());

              ScoringFunction sf = (ScoringFunction)prefMap.get(mapKey);
              double score = sf.getScore(av);
              myAspect.setScore(score);

              aspects.add(myAspect);
          }
      }
      return aspects;
  }

  private ArrayList getMyPhasedAspects (com.stdc.CnCcalc.data.AllocationResult myAR, List phasedAR, HashMap prefMap) {
      com.stdc.CnCcalc.data.ARPhase myARPhase = null;
      ArrayList aspects = null;
      if ( phasedAR.size() >0 ) {
          aspects = new ArrayList();
      }
      for (int i = 0, n = phasedAR.size(); i < n; i++) {
          AspectValue[] aspectvals = (AspectValue[])phasedAR.get(i);
          for (int j = 0; j < aspectvals.length; j++) {
              int aspectType = aspectvals[j].getAspectType();
              Integer mapKey = new Integer(aspectType);
              if ( prefMap.containsKey(mapKey) ){
                  myARPhase = new com.stdc.CnCcalc.data.ARPhase();
                  myARPhase.setArType(myAR.getType());
                  myARPhase.setPlanId(myAR.getPlanId());
                  myARPhase.setTaskId(myAR.getTaskId());
                  myARPhase.setRunId(myAR.getRunId());
                  myARPhase.setPhaseNo(i);

                  myARPhase.setAspecttype(AspectValue.aspectTypeToString(aspectType));
                  myARPhase.setValue(aspectvals[j].getValue());

                  ScoringFunction sf = (ScoringFunction)prefMap.get(mapKey);
                  double score = sf.getScore(aspectvals[j]);
                  myARPhase.setScore(score);

                  aspects.add(myARPhase);
              }
          }
      }
      return aspects;
  }

  private static AspectValue getBoundryAspectValue(AspectValue av, boolean min, String agent) {
      Logger logger = org.cougaar.util.log.LoggerFactory.getInstance().createLogger(TaskConverter.class);
      Map aspectMap = null;
      if ( min ) {
         aspectMap = _minAspectMap;
      } else {
         aspectMap = _maxAspectMap;
      }
      int type = av.getType();
      Integer aspectKey = new Integer(type);
      Map valueMap = null;
      synchronized(aspectMap) {
          valueMap = (Map)aspectMap.get(aspectKey);
          if (valueMap == null) {
              valueMap = Collections.synchronizedMap(new HashMap(3));
              aspectMap.put(aspectKey,valueMap);
              logger.info (agent + " : " + "Added AspectMap for (" + type + ")" + "MIN=" + min);
          }
      }
      String valueKey = null;
      AspectValue boundryAspect = null;
      boolean addValue = false;
      if (av instanceof TypedAspectValue) {
          if (av instanceof IntAspectValue) {
              valueKey = "int";
              boundryAspect = (AspectValue)valueMap.get(valueKey);
              if ( boundryAspect == null ) {
                  addValue = true;
                  if (min ) {
                      boundryAspect = AspectValue.newAspectValue(type, 0);
                  } else {
                      boundryAspect = AspectValue.newAspectValue(type, Integer.MAX_VALUE);
                  }
              }
          } else if (av instanceof LongAspectValue) {
              valueKey = "long";
              boundryAspect = (AspectValue)valueMap.get(valueKey);
              if ( boundryAspect == null ) {
                  addValue = true;
                  if (min ) {
                      boundryAspect = AspectValue.newAspectValue(type, 0l);
                  } else {
                      boundryAspect = AspectValue.newAspectValue(type, Long.MAX_VALUE);
                  }
              }
          } else if (av instanceof FloatAspectValue) {
              valueKey = "float";
              boundryAspect = (AspectValue)valueMap.get(valueKey);
              if ( boundryAspect == null ) {
                  addValue = true;
                  if (min ) {
                      boundryAspect = AspectValue.newAspectValue(type, 0f);
                  } else {
                      boundryAspect = AspectValue.newAspectValue(type, Float.MAX_VALUE);
                  }
              }
          } else if (av instanceof DoubleAspectValue) {
              valueKey = "double";
              boundryAspect = (AspectValue)valueMap.get(valueKey);
              if ( boundryAspect == null ) {
                  addValue = true;
                  if (min ) {
                      boundryAspect = AspectValue.newAspectValue(type, 0d);
                  } else {
                      boundryAspect = AspectValue.newAspectValue(type, Double.MAX_VALUE);
                  }
              }
          } else if (av instanceof AspectRate) {
              Rate rate = ((AspectRate)av).rateValue();
              valueKey = rate.getClass().getName();
              boundryAspect = (AspectValue)valueMap.get(valueKey);
              if ( boundryAspect == null ) {
                  addValue = true;
                  Class[] types = {Double.TYPE, Integer.TYPE};
                  Object[] args = {new Double(0d), new Integer(0)};
                  if ( !min ) {
                      args[0] = new Double(Double.MAX_VALUE);
                  }
                  Constructor c = null;
                  Rate boubdryRate = null;
                  try {
                      c = rate.getClass().getConstructor(types);
                      boubdryRate = (Rate) c.newInstance(args);
                  } catch (java.lang.NoSuchMethodException e) {
                      logger.info ("NoSuchMethodException in getBoundryAspectValue", e);
                  } catch (java.lang.InstantiationException e) {
                      logger.info ("InstantiationException in getBoundryAspectValue", e);
                  } catch (java.lang.IllegalAccessException e) {
                      logger.info ("IllegalAccessException in getBoundryAspectValue", e);
                  } catch (java.lang.reflect.InvocationTargetException e) {
                      logger.info ("InvocationTargetException in getBoundryAspectValue", e);
                  }
                  if ( boubdryRate != null) {
                      boundryAspect = AspectValue.newAspectValue(type, boubdryRate);
                  }
              }
          }
          synchronized(valueMap) {
              if ( addValue && boundryAspect != null ) {
                  valueMap.put(valueKey,boundryAspect);
                  logger.info (agent + " : " + "Added AspectValue for (" + type + " , " + valueKey + ")" 
                                + "MIN=" + min);
              }
          }
      }
      return boundryAspect;
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

}
