/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.ctask.general;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

import org.dspace.app.util.DCInput;
import org.dspace.app.util.DCInputSet;
import org.dspace.app.util.DCInputsReader;
import org.dspace.app.util.DCInputsReaderException;
import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.MetadataValue;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.CollectionService;
import org.dspace.core.Constants;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;
import org.dspace.curate.Suspendable;

/**
 * It will be used to update dc.identifier.uri with the handle saved in database. 
 * When we change the handle in the database, the dc.identifier.uri is not automatically updated,
 * thus pointing to the old handle which can not be resolved by dspace
 *
 * @author steli
 */
@Suspendable
public class UpdateHandleFromDB extends AbstractCurationTask {
    // The status of this item
    protected int status = Curator.CURATE_UNSET;
    protected CollectionService collectionService = ContentServiceFactory.getInstance().getCollectionService();

    @Override
    public void init(Curator curator, String taskId) throws IOException {
        super.init(curator, taskId);
    }

    /**
     * Perform the curation task upon passed DSO
     *
     * @param dso the DSpace object
     * @throws IOException if IO error
     */
    @Override
    public int perform(DSpaceObject dso) throws IOException {
        StringBuilder sb = new StringBuilder();
        sb.append("DSpace Object with UUID: ").append(dso.getID());
        //if item, collection or community, go update the handle
        switch (dso.getType()) {
            case Constants.ITEM:
                sb.append("is ITEM. ");
                Item item = (Item) dso;
                try {
                    String dbHandle = item.getHandle();
                    if (dbHandle == null) {
                        // we are still in workflow - no handle assigned so SKIP dso
                        sb.append("Database handle NOT found...SKIPPING");
                        status = Curator.CURATE_SKIP;
                    }else{
                        sb.append("Database handle is: ").append(dbHandle);
                        sb.append(" Found Handle: ");
                        List<MetadataValue> values = itemService.getMetadataByMetadataString(item, "dc.identifier.uri");
                        itemService.getMetadataByMetadataString(item, "dc.identifier.uri")
                            .stream().map((mv)-> { return mv.getValue();}).forEach((val)-> {sb.append(val);});
                        
//                        itemService.replaceMetadata(Curator.curationContext(), item, "dc", 
//                                "identifier", "uri", "en", dbHandle,null, 0, 0);
                        itemService.removeMetadataValues(Curator.curationContext(), item, values);
                        itemService.setMetadataSingleValue(Curator.curationContext(),item, "dc", "identifier",
                                 "uri", "en", "https://repotest.ub.fau.de/handle/" + dbHandle);
                        sb.append(" Updated with Handle: ");
                        itemService.getMetadataByMetadataString(item, "dc.identifier.uri")
                            .stream().map((mv)-> { return mv.getValue();}).forEach((val)-> {sb.append(val);});
                        status = Curator.CURATE_SUCCESS;
                    }
                    report(sb.toString());
                    setResult(sb.toString());              
                } catch (SQLException ex) {
                    Logger.getLogger(UpdateHandleFromDB.class.getName()).log(Level.SEVERE, null, ex);
                    status = Curator.CURATE_ERROR;
                }
                break;
            case Constants.COLLECTION:
                sb.append("is COLLECTION. ");
                Collection collection = (Collection) dso;
                try {
                    String dbHandle = collection.getHandle();
                    if (dbHandle == null) {
                        // we are still in workflow - no handle assigned so SKIP dso
                        sb.append("Database handle NOT found. SKIPPING...");
                        status = Curator.CURATE_SKIP;
                    }else{
                        sb.append("Database handle is: ").append(dbHandle);
                        sb.append(" Found Handle: ");
                        List<MetadataValue> values = collectionService.getMetadataByMetadataString(collection, "dc.identifier.uri");
                        collectionService.getMetadataByMetadataString(collection, "dc.identifier.uri")
                            .stream().map((mv)-> { return mv.getValue();}).forEach((val)-> {sb.append(val);});
                        
//                        collectionService.replaceMetadata(Curator.curationContext(), collection, "dc", 
//                                "identifier", "uri", "en", dbHandle,null, 0, 0);
                        collectionService.removeMetadataValues(Curator.curationContext(), collection, values);
                        collectionService.setMetadataSingleValue(Curator.curationContext(),collection, "dc", "identifier",
                                 "uri", "en", "https://repotest.ub.fau.de/handle/" + dbHandle);
                        sb.append(" Updated with Handle: ");
                        collectionService.getMetadataByMetadataString(collection, "dc.identifier.uri")
                            .stream().map((mv)-> { return mv.getValue();}).forEach((val)-> {sb.append(val);});
                        status = Curator.CURATE_SUCCESS;
                    }
                    report(sb.toString());
                    setResult(sb.toString());              
                } catch (SQLException ex) {
                    Logger.getLogger(UpdateHandleFromDB.class.getName()).log(Level.SEVERE, null, ex);
                    status = Curator.CURATE_ERROR;
                }
                break;
            case Constants.COMMUNITY:
                sb.append("is COMMUNITY. ");
                Community community = (Community) dso;
                try {
                    String dbHandle = community.getHandle();
                    if (dbHandle == null) {
                        // we are still in workflow - no handle assigned so SKIP dso
                        sb.append("Database handle NOT found. SKIPPING...");
                        status = Curator.CURATE_SKIP;
                    }else{
                        sb.append("Database handle is: ").append(dbHandle);
                        sb.append(" Found Handle: ");
                        List<MetadataValue> values = communityService.getMetadataByMetadataString(community, "dc.identifier.uri");
                        communityService.getMetadataByMetadataString(community, "dc.identifier.uri")
                            .stream().map((mv)-> { return mv.getValue();}).forEach((val)-> {sb.append(val);});
                       // communityService.replaceMetadata(Curator.curationContext(), community, "dc", 
                        //        "identifier", "uri", "en", dbHandle,null, 0, 0);
                        communityService.removeMetadataValues(Curator.curationContext(), community, values);
                        communityService.setMetadataSingleValue(Curator.curationContext(), community, "dc", "identifier",
                                 "uri", "en", "https://repotest.ub.fau.de/handle/" + dbHandle);
                        sb.append(" Updated with Handle: ");
                        communityService.getMetadataByMetadataString(community, "dc.identifier.uri")
                            .stream().map((mv)-> { return mv.getValue();}).forEach((val)-> {sb.append(val);});
                        status = Curator.CURATE_SUCCESS;
                    }
                    report(sb.toString());
                    setResult(sb.toString());              
                } catch (SQLException ex) {
                    Logger.getLogger(UpdateHandleFromDB.class.getName()).log(Level.SEVERE, null, ex);
                    status = Curator.CURATE_ERROR;
                }
                break;
            default:
                setResult("DSpace Object skipped because is not an Item, Collection or Community");
                status = Curator.CURATE_SKIP;
        }
        return status ;
    }

  
}
