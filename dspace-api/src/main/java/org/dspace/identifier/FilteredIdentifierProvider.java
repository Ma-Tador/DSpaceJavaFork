/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */

package org.dspace.identifier;

import java.sql.SQLException;

import org.dspace.content.DSpaceObject;
import org.dspace.content.logic.Filter;
<<<<<<< HEAD
import org.dspace.content.logic.TrueFilter;
import org.dspace.core.Context;
=======
import org.dspace.core.Context;
import org.springframework.beans.factory.annotation.Autowired;
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb

/**
 * This abstract class adds extra method signatures so that implementing IdentifierProviders can
 * handle "skip filter" booleans, so that any configured filters can be skipped and DOI registration forced.
 *
 * @author Kim Shepherd
 * @version $Revision$
 */
public abstract class FilteredIdentifierProvider extends IdentifierProvider {

<<<<<<< HEAD
    protected Filter filter = new TrueFilter();

    /**
     * Setter for spring to set the default filter from the property in configuration XML
     * @param filter - an object implementing the org.dspace.content.logic.Filter interface
     */
    public void setFilter(Filter filter) {
        this.filter = filter;
        if (this.filter == null) {
            this.filter = new TrueFilter();
        }
=======
    protected Filter filterService;

    /**
     * Setter for spring to set the filter service from the property in configuration XML
     * @param filterService - an object implementing the org.dspace.content.logic.Filter interface
     */
    @Autowired
    public void setFilterService(Filter filterService) {
        this.filterService = filterService;
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
    }

    /**
     * Register a new identifier for a given DSpaceObject
     * @param context    - DSpace context
     * @param dso        - DSpaceObject to use for identifier registration
<<<<<<< HEAD
     * @param filter     - Logical item filter to determine whether this identifier should be registered
     * @return identifier
     * @throws IdentifierException
     */
    public abstract String register(Context context, DSpaceObject dso, Filter filter)
=======
     * @param skipFilter - boolean indicating whether to skip any filtering of items before performing registration
     * @return identifier
     * @throws IdentifierException
     */
    public abstract String register(Context context, DSpaceObject dso, boolean skipFilter)
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
        throws IdentifierException;

    /**
     * Register a specified identifier for a given DSpaceObject
     * @param context    - DSpace context
     * @param dso        - DSpaceObject identified by the new identifier
     * @param identifier - String containing the identifier to register
<<<<<<< HEAD
     * @param filter     - Logical item filter to determine whether this identifier should be registered
     * @throws IdentifierException
     */
    public abstract void register(Context context, DSpaceObject dso, String identifier, Filter filter)
=======
     * @param skipFilter - boolean indicating whether to skip any filtering of items before performing registration
     * @throws IdentifierException
     */
    public abstract void register(Context context, DSpaceObject dso, String identifier, boolean skipFilter)
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
        throws IdentifierException;

    /**
     * Reserve a specified identifier for a given DSpaceObject (eg. reserving a DOI online with a registration agency)
     * @param context    - DSpace context
     * @param dso        - DSpaceObject identified by this identifier
     * @param identifier - String containing the identifier to reserve
<<<<<<< HEAD
     * @param filter     - Logical item filter to determine whether this identifier should be reserved
=======
     * @param skipFilter - boolean indicating whether to skip any filtering of items before performing reservation
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
     * @throws IdentifierException
     * @throws IllegalArgumentException
     * @throws SQLException
     */
<<<<<<< HEAD
    public abstract void reserve(Context context, DSpaceObject dso, String identifier, Filter filter)
=======
    public abstract void reserve(Context context, DSpaceObject dso, String identifier, boolean skipFilter)
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
        throws IdentifierException, IllegalArgumentException, SQLException;

    /**
     * Mint a new identifier in DSpace - this is usually the first step of registration
     * @param context    - DSpace context
     * @param dso        - DSpaceObject identified by the new identifier
<<<<<<< HEAD
     * @param filter     - Logical item filter to determine whether this identifier should be registered
     * @return a String containing the new identifier
     * @throws IdentifierException
     */
    public abstract String mint(Context context, DSpaceObject dso, Filter filter) throws IdentifierException;
=======
     * @param skipFilter - boolean indicating whether to skip any filtering of items before minting.
     * @return a String containing the new identifier
     * @throws IdentifierException
     */
    public abstract String mint(Context context, DSpaceObject dso, boolean skipFilter) throws IdentifierException;
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb

    /**
     * Check configured item filters to see if this identifier is allowed to be minted
     * @param context    - DSpace context
     * @param dso        - DSpaceObject to be inspected
     * @throws IdentifierException
     */
    public abstract void checkMintable(Context context, DSpaceObject dso) throws IdentifierException;

<<<<<<< HEAD
    /**
     * Check configured item filters to see if this identifier is allowed to be minted
     * @param context    - DSpace context
     * @param filter     - Logical item filter
     * @param dso        - DSpaceObject to be inspected
     * @throws IdentifierException
     */
    public abstract void checkMintable(Context context, Filter filter, DSpaceObject dso) throws IdentifierException;

}
=======

}
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
