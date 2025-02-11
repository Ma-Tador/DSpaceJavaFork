/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content.logic;

import java.util.HashMap;
import java.util.Map;

import org.dspace.identifier.DOI;
import org.dspace.identifier.Handle;
import org.dspace.identifier.Identifier;
import org.dspace.services.ConfigurationService;
import org.dspace.services.factory.DSpaceServicesFactory;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * General utility methods for logical item filtering
 *
 * @author Kim Shepherd
 */
public class FilterUtils {

    @Autowired(required = true)
    ConfigurationService configurationService;

    /**
     * Get a Filter by name
     * @param property  DSpace configuration property name (Apache Commons config)
     * @return  Filter or null
     */
    public static Filter getFilterFromConfiguration(String property) {
        String filterName = DSpaceServicesFactory.getInstance().getConfigurationService().getProperty(property);
        if (filterName != null) {
            return DSpaceServicesFactory.getInstance().getServiceManager().getServiceByName(filterName, Filter.class);
        }
        return null;
    }

    /**
     * Get a Filter by name
     * @param property  DSpace configuration property name (Apache Commons config)
     * @return  Filter or null
     */
    public static Filter getFilterFromConfiguration(String property, Filter defaultFilter) {
        Filter filter = getFilterFromConfiguration(property);
        if (filter != null) {
            return filter;
        }
        return defaultFilter;
    }

    /**
     * Get a map of identifier types and filters to use when creating workspace or archived items
     * @return
     */
    public static Map<Class<? extends Identifier>, Filter> getIdentifierFilters(String status) {
        if (status == null) {
            status = "install";
        }
        Map<Class<? extends Identifier>, Filter> filters = new HashMap<>();
        // Put DOI 'can we create DOI on install / workspace?' filter
        Filter filter = FilterUtils.getFilterFromConfiguration("identifiers.submission.filter." + status);
        // A null filter should be handled safely by the identifier provier (default, or "always true")
        filters.put(DOI.class, filter);
        // This won't have an affect until handle providers implement filtering, but is an example of
        // how the filters can be used for other types
        filters.put(Handle.class, new TrueFilter());
        return filters;
    }
}