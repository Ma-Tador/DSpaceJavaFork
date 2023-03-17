/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.ctask.general;

import static org.junit.Assert.assertEquals;

import java.io.IOException;

import org.dspace.AbstractIntegrationTestWithDatabase;
import org.dspace.builder.CollectionBuilder;
import org.dspace.builder.CommunityBuilder;
import org.dspace.builder.ItemBuilder;
import org.dspace.content.Collection;
import org.dspace.content.Item;
<<<<<<< HEAD
=======
import org.dspace.core.factory.CoreServiceFactory;
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
import org.dspace.curate.Curator;
import org.dspace.identifier.VersionedHandleIdentifierProviderWithCanonicalHandles;
import org.dspace.services.ConfigurationService;
import org.dspace.services.factory.DSpaceServicesFactory;
<<<<<<< HEAD
=======
import org.junit.After;
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
import org.junit.Test;

/**
 * Rudimentary test of the curation task.
 *
 * @author mwood
 */
public class CreateMissingIdentifiersIT
        extends AbstractIntegrationTestWithDatabase {
    private static final String P_TASK_DEF
            = "plugin.named.org.dspace.curate.CurationTask";
    private static final String TASK_NAME = "test";

    @Test
    public void testPerform()
            throws IOException {
<<<<<<< HEAD
        ConfigurationService configurationService
                = DSpaceServicesFactory.getInstance().getConfigurationService();
        configurationService.setProperty(P_TASK_DEF, null);
        configurationService.addPropertyValue(P_TASK_DEF,
=======
        // Must remove any cached named plugins before creating a new one
        CoreServiceFactory.getInstance().getPluginService().clearNamedPluginClasses();
        ConfigurationService configurationService = kernelImpl.getConfigurationService();
        // Define a new task dynamically
        configurationService.setProperty(P_TASK_DEF,
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
                CreateMissingIdentifiers.class.getCanonicalName() + " = " + TASK_NAME);

        Curator curator = new Curator();
        curator.addTask(TASK_NAME);

        context.setCurrentUser(admin);
        parentCommunity = CommunityBuilder.createCommunity(context)
<<<<<<< HEAD
                .build();
        Collection collection = CollectionBuilder.createCollection(context, parentCommunity)
                .build();
        Item item = ItemBuilder.createItem(context, collection)
                .build();
=======
                                          .build();
        Collection collection = CollectionBuilder.createCollection(context, parentCommunity)
                                                 .build();
        Item item = ItemBuilder.createItem(context, collection)
                               .build();
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb

        /*
         * Curate with regular test configuration -- should succeed.
         */
        curator.curate(context, item);
        int status = curator.getStatus(TASK_NAME);
        assertEquals("Curation should succeed", Curator.CURATE_SUCCESS, status);

        /*
         * Now install an incompatible provider to make the task fail.
         */
        DSpaceServicesFactory.getInstance()
                .getServiceManager()
                .registerServiceClass(
                        VersionedHandleIdentifierProviderWithCanonicalHandles.class.getCanonicalName(),
                        VersionedHandleIdentifierProviderWithCanonicalHandles.class);

        curator.curate(context, item);
        System.out.format("With incompatible provider, result is '%s'.\n",
                curator.getResult(TASK_NAME));
        assertEquals("Curation should fail", Curator.CURATE_ERROR,
                curator.getStatus(TASK_NAME));
    }
<<<<<<< HEAD
=======

    @Override
    @After
    public void destroy() throws Exception {
        super.destroy();
        DSpaceServicesFactory.getInstance().getServiceManager().getApplicationContext().refresh();
    }
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
}
