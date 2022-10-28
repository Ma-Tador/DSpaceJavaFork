

package org.dspace.ctask.general;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.ResourcePolicy;
import org.dspace.authorize.factory.AuthorizeServiceFactory;
import org.dspace.authorize.service.ResourcePolicyService;
import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;
import org.dspace.curate.Distributive;
import org.dspace.eperson.Group;
import org.dspace.eperson.factory.EPersonServiceFactory;
import org.dspace.eperson.service.GroupService;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.dspace.curate.Suspendable;

/**
 * A curator task setting the access level for OpenAire.
 */
//@Distributive
@Suspendable
public class DnbAccessRights extends AbstractCurationTask {

    private final static String FREE = "free";
    private final static String DOMAIN = "domain";
    private final static String EMBARGOED = "embargoed";
    private final static String UNKNOWN = "unknown";

    private final static List<String> PUBLICATION_SUBTYPES = Arrays.asList("article", "bookpart", "periodicalpart");

    private final static List<String> PUBLICATION_TYPES = Arrays.asList("book", "conferenceobject", "doctoralthesis", "habilitation", "masterthesis", "other",
                                                "preprint", "report", "workingpaper", "postprint", "coursematerial", "journalissue", "studythesis");

    //private AuthorizeService authorizeService;
    private ItemService itemService;

    private final ResourcePolicyService resourcePolicyService = AuthorizeServiceFactory.getInstance().getResourcePolicyService();

    private final GroupService groupService = EPersonServiceFactory.getInstance().getGroupService();

    @Override
    public void init(Curator curator, String taskId) throws IOException {
        super.init(curator, taskId);
        //authorizeService = AuthorizeServiceFactory.getInstance().getAuthorizeService();
        itemService = ContentServiceFactory.getInstance().getItemService();
    }

    /**
     * Performs the curation task on an item. <br>
     * Sets the access rights field ro 'free', 'domain', 'embargoed' or
     * 'unknown' Only operates on items where the field is empty or set with one
     * of the above values! If the field is set with another value (as
     * 'blocked'), it is left as was. Otherwise the following logic is used: If
     * an item is in embargo, the field is set to 'embargoed'. If the item is
     * not in embargo and the field is empty or set to 'embargoed', a logic is
     * used to calculate, if it shall be set to 'free' or 'domain'.
     *
     * @param dso the DSpaceObject
     * @return result of the process
     * @throws IOException
     */
    @Override
    public int perform(DSpaceObject dso) throws IOException {
        int result = Curator.CURATE_FAIL;

        if (dso.getType() == Constants.ITEM) {
            Item item = (Item) dso;
            try {
                String accessRights = itemService.getMetadataFirstValue(item, "local", "sendToDnb", "", Item.ANY);
                report("Item " + item.getHandle() + " has access rights " + accessRights);
                //if no accessRights for item, set accessRights
                if (accessRights == null) {
                    System.out.println("Item "+ item.getHandle() + ", has no local.sendToDnb set. Setting access rights..."); 
                    if (isInEmbargo(Curator.curationContext(), item)) {
                        System.out.println("Item "+ item.getHandle() + ", local.sendToDnb set to Embargoed.");
                        setAccessRights(item, EMBARGOED);
                    } else {
                        System.out.println("Item "+ item.getHandle() + ", has no local.sendToDnb set. Setting local.sendToDnb= Free/Domain/Unknown");
                        setAccessRights(item, calculateAccessRights(item));
                    }
                } else if ((FREE.equals(accessRights) || DOMAIN.equals(accessRights) || UNKNOWN.equals(accessRights)) && isInEmbargo(Curator.curationContext(), item)) {
                    //if item had some other accessRights, but in embargo, update to Embargoed
                    System.out.println("Item was in embrago, but set in local.sendToDnb= Free, Domain or Unknown. Updating local.sendToDnb= embargoed.");
                    setAccessRights(item, EMBARGOED); 
                } else if (EMBARGOED.equals(accessRights) && !isInEmbargo(Curator.curationContext(), item)) {
                    //if item was in embrago, but now not, update accessRights to Free/Unknown/Domain
                    System.out.println("Item's local.sendToDnb= Embargoed, but is no longer embargoed. Update local.sendToDnb= unknown/Free/Domain.");
                    setAccessRights(item, calculateAccessRights(item));
                }
                System.out.println("Done. Item "+ item.getHandle() + ", has local.sendToDnb updated.");
                result = Curator.CURATE_SUCCESS;
            } catch (SQLException e) {
                System.out.println("Couldn't update item with handle " + item.getHandle() + ": " + e);
            } catch (AuthorizeException e) {
                System.out.println("Couldn't update item with handle " + item.getHandle() + ": " + e);
            }
        }else{
            System.out.println("DSpace object " + dso.getHandle() + ", is SKIPPED, because is not an Item.");
            setResult("Object skipped");
            result = Curator.CURATE_SKIP; 
        }
        System.out.println("------------------------------------------------------------------------");
        return result;
   }
        /**
         * Calculates the access rights for the item.
         *
         * CAREFUL! This logic is NOT exhaustive! This method should ONLY be
         * called when tub.accessrights.dnb is empty or embargoed. There has to
         * remain a possibility to manually set this value to free or domain.
         *
         * The following logic tries to estimate the rights as good as we can.
         * If an item is under creative commons the decision is easy. We try to
         * estimate the status of all other documents following their document
         * type. This was specified by TU Universitätsverlag and OA-Team. See
         * DEPONCE-30.
         *
         * @param item
         * @return either "free", "domain" or "unknown"
         */
    private String calculateAccessRights(Item item) {
        //modified steli
        String dcRightsUri = itemService.getMetadataFirstValue(item, "dc", "rights", "uri", Item.ANY);
        //modified steli
        String dcPublisherName = itemService.getMetadataFirstValue(item, "dc", "publisher", null, Item.ANY);

        String dcType = itemService.getMetadataFirstValue(item, "dc", "type", null, Item.ANY);

        if (StringUtils.contains(dcRightsUri, "creativecommons.org") || StringUtils.contains(dcPublisherName, "Friedrich-Alexander-Universit") || PUBLICATION_TYPES.contains(dcType)) {
            return FREE;
        }
//FAU has no documents with DOMAIN access rights. @Steli
//        if (PUBLICATION_SUBTYPES.contains(dcType) && !StringUtils.contains(dcRightsUri, "creativecommons.org")) {
//            return DOMAIN;
//       }
        return UNKNOWN;
    }

    /**
     * Sets the access rights field of the given item to the given value.
     *
     * @param item
     * @param value
     * @throws SQLException
     * @throws AuthorizeException
     */
    private void setAccessRights(Item item, String value) throws SQLException, AuthorizeException {
        itemService.setMetadataSingleValue(Curator.curationContext(), item, "local", "sendToDnb", null, Item.ANY, value);
        itemService.update(Curator.curationContext(), item);
        String message = "DNB Access rights for item with handle " + item.getHandle() + " changed to " + value;
        report(message);
        setResult(message);
    }

    /**
     * Checks if the item of any ORIGINAL bitstream in the item is embargoed,
     * i.e. if user Anonymous is not allowed to read it.
     *
     * @param context
     * @param item
     * @return true, if there is an embargo, otherwise false.
     * @throws SQLException
     */
    private boolean isInEmbargo(Context context, Item item) throws SQLException {
        if (dspaceObjectInEmbargo(context, item)) {
            return true;
        }
        for (Bitstream bitstream : getOriginalBitstreams(item)) {
            if (dspaceObjectInEmbargo(context, bitstream)) {
                return true;
            }
        }
        return false;
    }



    private boolean dspaceObjectInEmbargo(Context context, DSpaceObject dSpaceObject) throws SQLException {
        List<ResourcePolicy> policies = resourcePolicyService.find( context, dSpaceObject, groupService.findByName(context, Group.ANONYMOUS), Constants.READ);
        // There should be only one policy for this group, action and bitstream.
        // If there is a start date, this is the read start date a.k.a. the embargo end date
        for (ResourcePolicy policy : policies) {
            if (!resourcePolicyService.isDateValid(policy)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Retrieves all ORIGINAL bitstream objects in an item.
     *
     * @param item the item object
     * @return a list with the bitstreams-
     */
    private List<Bitstream> getOriginalBitstreams(Item item) {
        List<Bitstream> bitstreams = new ArrayList<>();
        for (Bundle bundle : item.getBundles()) {
            if ("ORIGINAL".equals(bundle.getName())) {
                bitstreams.addAll(bundle.getBitstreams());
            }
        }
        return bitstreams;
    }

}
