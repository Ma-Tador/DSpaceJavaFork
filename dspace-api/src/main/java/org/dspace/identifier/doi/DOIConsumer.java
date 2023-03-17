/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.identifier.doi;

<<<<<<< HEAD
import java.sql.SQLException;

=======
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
import org.apache.logging.log4j.Logger;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.factory.ContentServiceFactory;
<<<<<<< HEAD
import org.dspace.content.logic.Filter;
import org.dspace.content.logic.FilterUtils;
=======
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.event.Consumer;
import org.dspace.event.Event;
<<<<<<< HEAD
import org.dspace.identifier.DOI;
import org.dspace.identifier.DOIIdentifierProvider;
import org.dspace.identifier.IdentifierException;
import org.dspace.identifier.IdentifierNotApplicableException;
import org.dspace.identifier.factory.IdentifierServiceFactory;
import org.dspace.identifier.service.DOIService;
import org.dspace.services.ConfigurationService;
import org.dspace.services.factory.DSpaceServicesFactory;
=======
import org.dspace.identifier.DOIIdentifierProvider;
import org.dspace.identifier.IdentifierException;
import org.dspace.identifier.IdentifierNotFoundException;
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
import org.dspace.utils.DSpace;
import org.dspace.workflow.factory.WorkflowServiceFactory;

/**
 * @author Pascal-Nicolas Becker (p dot becker at tu hyphen berlin dot de)
<<<<<<< HEAD
 * @author Kim Shepherd
=======
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
 */
public class DOIConsumer implements Consumer {
    /**
     * log4j logger
     */
    private static Logger log = org.apache.logging.log4j.LogManager.getLogger(DOIConsumer.class);

<<<<<<< HEAD
    ConfigurationService configurationService;

=======
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
    @Override
    public void initialize() throws Exception {
        // nothing to do
        // we can ask spring to give as a properly setuped instance of
        // DOIIdentifierProvider. Doing so we don't have to configure it and
        // can load it in consume method as this is not very expensive.
<<<<<<< HEAD
        configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();
=======
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb

    }

    // as we use asynchronous metadata update, our updates are not very expensive.
    // so we can do everything in the consume method.
    @Override
    public void consume(Context ctx, Event event) throws Exception {
        if (event.getSubjectType() != Constants.ITEM) {
            log.warn("DOIConsumer should not have been given this kind of "
                         + "subject in an event, skipping: " + event.toString());
            return;
        }
        if (Event.MODIFY_METADATA != event.getEventType()) {
            log.warn("DOIConsumer should not have been given this kind of "
                         + "event type, skipping: " + event.toString());
            return;
        }

        DSpaceObject dso = event.getSubject(ctx);
        //FIXME
        if (!(dso instanceof Item)) {
            log.debug("DOIConsumer got an event whose subject was not an item, "
                          + "skipping: " + event.toString());
            return;
        }
        Item item = (Item) dso;
<<<<<<< HEAD
        DOIIdentifierProvider provider = new DSpace().getSingletonService(DOIIdentifierProvider.class);
        boolean inProgress = (ContentServiceFactory.getInstance().getWorkspaceItemService().findByItem(ctx, item)
                != null || WorkflowServiceFactory.getInstance().getWorkflowItemService().findByItem(ctx, item) != null);
        boolean identifiersInSubmission = configurationService.getBooleanProperty("identifiers.submission.register",
                false);
        DOIService doiService = IdentifierServiceFactory.getInstance().getDOIService();
        Filter workspaceFilter = null;
        if (identifiersInSubmission) {
            workspaceFilter = FilterUtils.getFilterFromConfiguration("identifiers.submission.filter.workspace");
        }

        if (inProgress && !identifiersInSubmission) {
            // ignore workflow and workspace items, DOI will be minted and updated when item is installed
            // UNLESS special pending filter is set
            return;
        }
        DOI doi = null;
        try {
            doi = doiService.findDOIByDSpaceObject(ctx, dso);
        } catch (SQLException ex) {
=======

        if (ContentServiceFactory.getInstance().getWorkspaceItemService().findByItem(ctx, item) != null
            || WorkflowServiceFactory.getInstance().getWorkflowItemService().findByItem(ctx, item) != null) {
            // ignore workflow and workspace items, DOI will be minted when item is installed
            return;
        }

        DOIIdentifierProvider provider = new DSpace().getSingletonService(
            DOIIdentifierProvider.class);

        String doi = null;
        try {
            doi = provider.lookup(ctx, dso);
        } catch (IdentifierNotFoundException ex) {
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
            // nothing to do here, next if clause will stop us from processing
            // items without dois.
        }
        if (doi == null) {
<<<<<<< HEAD
            // No DOI. The only time something should be minted is if we have enabled submission reg'n and
            // it passes the workspace filter. We also need to update status to PENDING straight after.
            if (inProgress) {
                provider.mint(ctx, dso, workspaceFilter);
                DOI newDoi = doiService.findDOIByDSpaceObject(ctx, dso);
                if (newDoi != null) {
                    newDoi.setStatus(DOIIdentifierProvider.PENDING);
                    doiService.update(ctx, newDoi);
                }
            } else {
                log.debug("DOIConsumer cannot handles items without DOIs, skipping: " + event.toString());
            }
        } else {
            // If in progress, we can also switch PENDING and MINTED status depending on the latest filter
            // evaluation
            if (inProgress) {
                try {
                    // Check the filter
                    provider.checkMintable(ctx, workspaceFilter, dso);
                    // If we made it here, the existing doi should be back to PENDING
                    if (DOIIdentifierProvider.MINTED.equals(doi.getStatus())) {
                        doi.setStatus(DOIIdentifierProvider.PENDING);
                    }
                } catch (IdentifierNotApplicableException e) {
                    // Set status to MINTED if configured to downgrade existing DOIs
                    if (configurationService
                            .getBooleanProperty("identifiers.submission.strip_pending_during_submission", true)) {
                        doi.setStatus(DOIIdentifierProvider.MINTED);
                    }
                }
                doiService.update(ctx, doi);
            } else {
                try {
                    provider.updateMetadata(ctx, dso, doi.getDoi());
                } catch (IllegalArgumentException ex) {
                    // should not happen, as we got the DOI from the DOIProvider
                    log.warn("DOIConsumer caught an IdentifierException.", ex);
                } catch (IdentifierException ex) {
                    log.warn("DOIConsumer cannot update metadata for Item with ID "
                            + item.getID() + " and DOI " + doi + ".", ex);
                }
            }
            ctx.commit();
=======
            log.debug("DOIConsumer cannot handles items without DOIs, skipping: "
                          + event.toString());
            return;
        }
        try {
            provider.updateMetadata(ctx, dso, doi);
        } catch (IllegalArgumentException ex) {
            // should not happen, as we got the DOI from the DOIProvider
            log.warn("DOIConsumer caught an IdentifierException.", ex);
        } catch (IdentifierException ex) {
            log.warn("DOIConsumer cannot update metadata for Item with ID "
                         + item.getID() + " and DOI " + doi + ".", ex);
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
        }
    }

    @Override
    public void end(Context ctx) throws Exception {


    }

    @Override
    public void finish(Context ctx) throws Exception {
        // nothing to do
    }

<<<<<<< HEAD
}
=======
}
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
