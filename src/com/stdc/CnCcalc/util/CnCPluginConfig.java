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

import java.util.Properties;
import java.io.InputStream;
import java.io.IOException;
import java.io.File;

import org.cougaar.util.ConfigFinder;
import org.cougaar.util.log.Logger;

import com.stdc.CnCcalc.plugin.CnCcalcPlugin;

public class CnCPluginConfig
{
  public static final String PREFIX = "com.stdc.CnCcalc.";
  public static final String FILE_NAME_PROPERTY = PREFIX + "config.filename";
  private static final boolean ONLY_ROOT  = true;
  public static final int DEFAULT_COMMIT_COUNT  = 10;

  private static Properties _defaultProps;
  static {
    // take filename property, load from file
    _defaultProps = new Properties();
    _defaultProps.setProperty("plugin.onlyRoot", Boolean.toString(ONLY_ROOT));
    _defaultProps.setProperty("database.engine", "postgresql");
    _defaultProps.setProperty("database.driver", "org.postgresql.Driver");
    _defaultProps.setProperty("database.user", "postgres");
    _defaultProps.setProperty("database.passwd", "");
    _defaultProps.setProperty("database.mapping", "CnCcalcPostgresMapping.xml");
    _defaultProps.setProperty("database.commitCount", Integer.toString(DEFAULT_COMMIT_COUNT));
  }

  public static Properties getProperties() {
    Logger logger = org.cougaar.util.log.LoggerFactory.getInstance().createLogger(CnCcalcPlugin.class);
    String filename = System.getProperty(FILE_NAME_PROPERTY);
    Properties props = new Properties(_defaultProps);
    if (filename != null) {
      if ( logger.isDebugEnabled() )
        logger.debug("Loading properties from file " + filename);
      try {
        InputStream in = ConfigFinder.getInstance().open(filename);
        props.load(in);
      } catch (IOException ioe) {
        logger.error("Error loading properties from CnCcalcPlugin config file \""+filename+"\":", ioe);
        logger.info("Using default properties");
      }
    } else {
        if ( logger.isDebugEnabled() )
          logger.debug("Properties file not specified");
    }
    String tmpProp = null;
    if ( (tmpProp = System.getProperty(PREFIX + "plugin.onlyRoot")) != null ) {
      props.setProperty("plugin.onlyRoot", tmpProp);
    }
    if ( (tmpProp = System.getProperty(PREFIX + "database.engine")) != null ) {
      props.setProperty("database.engine", tmpProp);
    }
    if ( (tmpProp = System.getProperty(PREFIX + "database.driver")) != null ) {
      props.setProperty("database.driver", tmpProp);
    }
    if ( (tmpProp = System.getProperty(PREFIX + "database.url")) != null ) {
      props.setProperty("database.url", tmpProp);
    }
    if ( (tmpProp = System.getProperty(PREFIX + "database.user")) != null ) {
      props.setProperty("database.user", tmpProp);
    }
    if ( (tmpProp = System.getProperty(PREFIX + "database.passwd")) != null ) {
      props.setProperty("database.passwd", tmpProp);
    }
    if ( (tmpProp = System.getProperty(PREFIX + "database.mapping")) != null ) {
      props.setProperty("database.mapping", tmpProp);
    }
    if ( (tmpProp = System.getProperty(PREFIX + "database.pooling")) != null ) {
      props.setProperty("database.pooling", tmpProp);
    }
    if ( (tmpProp = System.getProperty(PREFIX + "database.commitCount")) != null ) {
      props.setProperty("database.commitCount", tmpProp);
    }
    if ( props.getProperty("database.url") == null ) {
      if ( logger.isInfoEnabled() )
        logger.info("Database URL is not specified, plugin will not log any data.");
    }
    return props;
  }
    
  public static String getDbConfigString(Properties props) {
    Logger logger = org.cougaar.util.log.LoggerFactory.getInstance().createLogger(CnCcalcPlugin.class);
    if ( ( props.getProperty("database.url") == null ) ) {
      if ( logger.isInfoEnabled() )
        logger.info("Database URL not specified, plugin will not log any data.");
      return null;
    } else {
      StringBuffer sb = new StringBuffer( 
                           "<!DOCTYPE\n" +
                           "     databases\n" +
                           "     PUBLIC \"-//EXOLAB/Castor JDO Configuration DTD Version 1.0//EN\"\n" +
                           "     \"http://castor.exolab.org/jdo-conf.dtd\"\n" +
                           ">\n" );

      sb.append ( "<database name=\"Assessment\" engine=\"" + props.getProperty("database.engine") + "\" >\n" );
      if ( props.getProperty("database.pooling") != null  &&
           props.getProperty("database.pooling").equals("true")) {
        sb.append ( "    <driver class-name=\"" + props.getProperty("database.driver") + "\" url=\"" + props.getProperty("database.url") + "\" />\n" );
      } else {
        sb.append ( "    <driver class-name=\"" + props.getProperty("database.driver") + "\" url=\"" + props.getProperty("database.url") + "\" >\n" );
        sb.append ( "        <param name=\"user\" value=\"" + props.getProperty("database.user") + "\" />\n" );
        sb.append ( "        <param name=\"password\" value=\"" + props.getProperty("database.passwd") + "\" />\n" );
        sb.append ( "    </driver>\n" );
      }

      String mapFileName = props.getProperty("database.mapping");
      File mapFile = ConfigFinder.getInstance().locateFile(mapFileName);
      String mapFilePath  = null;
      if ( mapFile != null) {
        mapFilePath  = mapFile.getAbsolutePath();
      } else {
        if ( logger.isErrorEnabled() )
          logger.error("Could not locate mapping file in config path, plugin will not log any data."); 
        return null;
      }

      if ( mapFilePath != null ) {
        sb.append ( "    <mapping href=\"" + mapFilePath + "\" />\n" );
      } else {
        if ( logger.isErrorEnabled() )
          logger.error("Mapping file path is null, plugin will not log any data."); 
        return null;
      }
      sb.append ( "</database>\n" );

      return sb.toString();
    }
  }
}
