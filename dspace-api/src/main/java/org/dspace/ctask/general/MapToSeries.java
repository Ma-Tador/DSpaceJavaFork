
package org.dspace.ctask.general;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;


import org.dspace.app.util.DCInputsReader;
import org.dspace.app.util.DCInputsReaderException;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Collection;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.MetadataValue;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.CollectionService;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;
import org.dspace.curate.Suspendable;

/**
 * MapToSeries task checks item metadata for local.series.name. If exists, it will map the document to that collection.
 * The task succeeds if the mapping is done without problems, otherwise it fails.
 *
 * @author Stelica Valianos
 */
@Suspendable
public class MapToSeries extends AbstractCurationTask {
    // map of DCInputSets
    protected DCInputsReader reader = null;

    //required metadata to map the item to the collection given by the metadata's value
    String requiredMetadata = "local.series.mapping"; 

    protected CollectionService collectionService = ContentServiceFactory.getInstance().getCollectionService();



   @Override
    public void init(Curator curator, String taskId) throws IOException {
        super.init(curator, taskId);
        try {
            reader = new DCInputsReader();
        } catch (DCInputsReaderException dcrE) {
            throw new IOException(dcrE.getMessage(), dcrE);
        }
    }


    /**
     * Perform the curation task upon passed DSO
     *
     * @param dso the DSpace object
     * @throws IOException if IO error
     */
    @Override
    public int perform(DSpaceObject dso) throws IOException {
        int result = Curator.CURATE_FAIL;
        StringBuilder sb = new StringBuilder();
        
        if (dso.getType() == Constants.ITEM) {
            Item item = (Item) dso;
            try {
                String handle = item.getHandle();
                if (handle == null) {
                    // we are still in workflow - no handle assigned
                    handle = "in workflow";
                }
                sb.append("Item: ").append(handle);
                List<MetadataValue> vals = itemService.getMetadataByMetadataString(item, requiredMetadata);
                if (vals.size() == 1) {
                    sb.append("- Item will be mapped to given Series handle.");
                    Curator.curationContext().turnOffAuthorisationSystem();
                    Collection colToMapTo = collectionService.findByIdOrLegacyId(Curator.curationContext(), vals.get(0).getValue());
                    collectionService.addItem(Curator.curationContext(), colToMapTo, item);
                    collectionService.update(Curator.curationContext(), colToMapTo);

                    itemService.addMetadata(Curator.curationContext(), item, "local", "series", "name", "*", colToMapTo.getName());
                    itemService.update(Curator.curationContext(), item);

                    Curator.curationContext().restoreAuthSystemState();
                    report(sb.toString());
                    setResult(sb.toString());
                    result = Curator.CURATE_SUCCESS;
                }else{
                    sb.append(" - Error Metadata local.series.mapping is empty / has too many Collection's ID to map to... Values stored in local.series.mapping:  ");
                    sb.append(vals.stream().map(el -> el.getValue()).collect(Collectors.joining(", ")) );
                    report(sb.toString());
                    setResult(sb.toString());
                    result = Curator.CURATE_FAIL;                }
            } catch (SQLException ex) {
                Logger.getLogger(MapToSeries.class.getName()).log(Level.SEVERE, null, ex);
            } catch (AuthorizeException ex) {
                Logger.getLogger(MapToSeries.class.getName()).log(Level.SEVERE, null, ex);
            }
        } else {
            setResult("Object skipped");
            result = Curator.CURATE_SKIP;
        }
        return result;
    }



}
