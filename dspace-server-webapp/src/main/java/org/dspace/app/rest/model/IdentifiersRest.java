/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.rest.model;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Implementation of IdentifierRest REST resource, representing a list of all identifiers
 * for use with the REST API
 *
 * @author Kim Shepherd <kim@shepherd.nz>
 */
public class IdentifiersRest implements RestModel {

    // Set names used in component wiring
    public static final String NAME = "identifier";
    public static final String PLURAL_NAME = "identifiers";
    private List<IdentifierRest> identifiers;

    // Empty constructor
    public IdentifiersRest() {
        identifiers = new ArrayList<>();
    }

    // Return name for getType()
    @Override
    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    public String getType() {
        return NAME;
    }

    public List<IdentifierRest> getIdentifiers() {
        return identifiers;
    }

    public void setIdentifiers(List<IdentifierRest> identifiers) {
        this.identifiers = identifiers;
    }
}
