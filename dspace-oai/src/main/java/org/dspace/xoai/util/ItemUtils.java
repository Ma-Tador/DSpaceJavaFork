<<<<<<< HEAD
=======
/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
package org.dspace.xoai.util;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.List;

import com.lyncode.xoai.dataprovider.xml.xoai.Element;
import com.lyncode.xoai.dataprovider.xml.xoai.Metadata;
import com.lyncode.xoai.util.Base64Utils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.dspace.app.util.factory.UtilServiceFactory;
import org.dspace.app.util.service.MetadataExposureService;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;
import org.dspace.content.Item;
import org.dspace.content.MetadataField;
import org.dspace.content.MetadataValue;
import org.dspace.content.authority.Choices;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.BitstreamService;
import org.dspace.content.service.ItemService;
import org.dspace.content.service.RelationshipService;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.Utils;
import org.dspace.services.ConfigurationService;
import org.dspace.services.factory.DSpaceServicesFactory;
import org.dspace.xoai.data.DSpaceItem;
<<<<<<< HEAD
import org.dspace.authorize.ResourcePolicy;
import org.dspace.authorize.factory.AuthorizeServiceFactory;
import org.dspace.authorize.service.ResourcePolicyService;
import org.dspace.embargo.factory.EmbargoServiceFactory;
import org.dspace.embargo.service.EmbargoService;
import org.dspace.eperson.Group;
import org.dspace.eperson.factory.EPersonServiceFactory;
import org.dspace.eperson.service.GroupService;
import java.util.Date;
import org.dspace.content.DCDate;
//import org.dspace.core.ConfigurationManager;  //obsolete import

=======
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb

/**
 * @author Lyncode Development Team (dspace at lyncode dot com)
 */
@SuppressWarnings("deprecation")
public class ItemUtils {
    private static final Logger log = LogManager.getLogger(ItemUtils.class);

<<<<<<< HEAD
    private static final MetadataExposureService metadataExposureService = UtilServiceFactory.getInstance().getMetadataExposureService();

    private static final ItemService itemService = ContentServiceFactory.getInstance().getItemService();

    private static final RelationshipService relationshipService = ContentServiceFactory.getInstance().getRelationshipService();

    private static final BitstreamService bitstreamService = ContentServiceFactory.getInstance().getBitstreamService();

    private static final ConfigurationService configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();

    //added for embargo openAccess  Steli
    private static final ResourcePolicyService resourcePolicyService = AuthorizeServiceFactory.getInstance().getResourcePolicyService();

    private static final GroupService groupService = EPersonServiceFactory.getInstance().getGroupService();

    private static final EmbargoService embargoService = EmbargoServiceFactory.getInstance().getEmbargoService();



=======
    private static final MetadataExposureService metadataExposureService
            = UtilServiceFactory.getInstance().getMetadataExposureService();

    private static final ItemService itemService
            = ContentServiceFactory.getInstance().getItemService();

    private static final RelationshipService relationshipService
            = ContentServiceFactory.getInstance().getRelationshipService();

    private static final BitstreamService bitstreamService
            = ContentServiceFactory.getInstance().getBitstreamService();

    private static final ConfigurationService configurationService
            = DSpaceServicesFactory.getInstance().getConfigurationService();
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
    /**
     * Default constructor
     */
    private ItemUtils() {
    }

    public static Element getElement(List<Element> list, String name) {
        for (Element e : list) {
            if (name.equals(e.getName())) {
                return e;
            }
        }
<<<<<<< HEAD
=======

>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
        return null;
    }

    public static Element create(String name) {
        Element e = new Element();
        e.setName(name);
        return e;
    }

    public static Element.Field createValue(String name, String value) {
        Element.Field e = new Element.Field();
        e.setValue(value);
        e.setName(name);
        return e;
    }

<<<<<<< HEAD


=======
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
    private static Element createBundlesElement(Context context, Item item) throws SQLException {
        Element bundles = create("bundles");

        List<Bundle> bs;

        bs = item.getBundles();
        for (Bundle b : bs) {
            Element bundle = create("bundle");
            bundles.getElement().add(bundle);
            bundle.getField().add(createValue("name", b.getName()));

            Element bitstreams = create("bitstreams");
            bundle.getElement().add(bitstreams);
            List<Bitstream> bits = b.getBitstreams();
            for (Bitstream bit : bits) {
                Element bitstream = create("bitstream");
                bitstreams.getElement().add(bitstream);
                String url = "";
                String bsName = bit.getName();
                String sid = String.valueOf(bit.getSequenceID());
<<<<<<< HEAD
                //String baseUrl = configurationService.getProperty("oai.bitstream.baseUrl");
                //System.out.println(baseUrl);
=======
                String baseUrl = configurationService.getProperty("oai.bitstream.baseUrl");
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
                String handle = null;
                // get handle of parent Item of this bitstream, if there
                // is one:
                List<Bundle> bn = bit.getBundles();
                if (!bn.isEmpty()) {
                    List<Item> bi = bn.get(0).getItems();
                    if (!bi.isEmpty()) {
                        handle = bi.get(0).getHandle();
                    }
                }
<<<<<<< HEAD
                //url = baseUrl + "/bitstreams/" + bit.getID().toString() + "/download";
		url = "https://repotest.ub.fau.de/bitstreams/" + bit.getID().toString() + "/download";
=======
                url = baseUrl + "/bitstreams/" + bit.getID().toString() + "/download";
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb

                String cks = bit.getChecksum();
                String cka = bit.getChecksumAlgorithm();
                String oname = bit.getSource();
                String name = bit.getName();
                String description = bit.getDescription();

                if (name != null) {
                    bitstream.getField().add(createValue("name", name));
                }
                if (oname != null) {
                    bitstream.getField().add(createValue("originalName", name));
                }
                if (description != null) {
                    bitstream.getField().add(createValue("description", description));
                }
                bitstream.getField().add(createValue("format", bit.getFormat(context).getMIMEType()));
                bitstream.getField().add(createValue("size", "" + bit.getSizeBytes()));
                bitstream.getField().add(createValue("url", url));
                bitstream.getField().add(createValue("checksum", cks));
                bitstream.getField().add(createValue("checksumAlgorithm", cka));
                bitstream.getField().add(createValue("sid", bit.getSequenceID() + ""));
            }
        }

        return bundles;
    }

<<<<<<< HEAD



=======
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
    private static Element createLicenseElement(Context context, Item item)
            throws SQLException, AuthorizeException, IOException {
        Element license = create("license");
        List<Bundle> licBundles;
        licBundles = itemService.getBundles(item, Constants.LICENSE_BUNDLE_NAME);
        if (!licBundles.isEmpty()) {
            Bundle licBundle = licBundles.get(0);
            List<Bitstream> licBits = licBundle.getBitstreams();
            if (!licBits.isEmpty()) {
                Bitstream licBit = licBits.get(0);
                InputStream in;

                in = bitstreamService.retrieve(context, licBit);
                ByteArrayOutputStream out = new ByteArrayOutputStream();
                Utils.bufferedCopy(in, out);
                license.getField().add(createValue("bin", Base64Utils.encode(out.toString())));
<<<<<<< HEAD
=======

>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
            }
        }
        return license;
    }

<<<<<<< HEAD



=======
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
    /**
     * This method will add all sub-elements to a top element, like: dc, or dcterms, ...     *
     * @param schema         Element argument passed by reference that will be changed
     * @param val            Metadatavalue that will be processed
     * @throws SQLException
     */
    private static void fillSchemaElement(Element schema, MetadataValue val) throws SQLException {
        MetadataField field = val.getMetadataField();
        Element valueElem = schema;

        // Has element.. with XOAI one could have only schema and value
        if (field.getElement() != null && !field.getElement().equals("")) {
            Element element = getElement(schema.getElement(), field.getElement());
            if (element == null) {
                element = create(field.getElement());
                schema.getElement().add(element);
            }
            valueElem = element;

            // Qualified element?
            if (field.getQualifier() != null && !field.getQualifier().equals("")) {
                Element qualifier = getElement(element.getElement(), field.getQualifier());
                if (qualifier == null) {
                    qualifier = create(field.getQualifier());
                    element.getElement().add(qualifier);
                }
                valueElem = qualifier;
            }
        }

        // Language?
        if (val.getLanguage() != null && !val.getLanguage().equals("")) {
            Element language = getElement(valueElem.getElement(), val.getLanguage());
            if (language == null) {
                language = create(val.getLanguage());
                valueElem.getElement().add(language);
            }
            valueElem = language;
        } else {
            Element language = getElement(valueElem.getElement(), "none");
            if (language == null) {
                language = create("none");
                valueElem.getElement().add(language);
            }
            valueElem = language;
        }

        valueElem.getField().add(createValue("value", val.getValue()));
        if (val.getAuthority() != null) {
            valueElem.getField().add(createValue("authority", val.getAuthority()));
            if (val.getConfidence() != Choices.CF_NOVALUE) {
                valueElem.getField().add(createValue("confidence", val.getConfidence() + ""));
            }
        }
    }

<<<<<<< HEAD




=======
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
    /**
     * Utility method to retrieve a structured XML in XOAI format
     * @param context
     * @param item
     * @return Structured XML Metadata in XOAI format
     */
    public static Metadata retrieveMetadata(Context context, Item item) {
<<<<<<< HEAD
        // read all metadata into Metadata Object
        Metadata metadata = new Metadata();
        Date bitstreamMinEmbargoDate = null;
        Date bitstreamMaxEmbargoDate = null;
        List<MetadataValue> vals = itemService.getMetadata(item, Item.ANY, Item.ANY, Item.ANY, Item.ANY);
        
        for(MetadataValue val : vals) {
            MetadataField field = val.getMetadataField();
            try {
                // Don't expose fields that are hidden by configuration
                if (metadataExposureService.isHidden(context, field.getMetadataSchema().getName(), field.getElement(),field.getQualifier())) {
                    continue;
                }
                //get metadata schema ex.dcterms
=======
        Metadata metadata;

        // read all metadata into Metadata Object
        metadata = new Metadata();

        List<MetadataValue> vals = itemService.getMetadata(item, Item.ANY, Item.ANY, Item.ANY, Item.ANY);
        for (MetadataValue val : vals) {
            MetadataField field = val.getMetadataField();
            try {
                // Don't expose fields that are hidden by configuration
                if (metadataExposureService.isHidden(context, field.getMetadataSchema().getName(), field.getElement(),
                        field.getQualifier())) {
                    continue;
                }

>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
                Element schema = getElement(metadata.getElement(), field.getMetadataSchema().getName());
                if (schema == null) {
                    schema = create(field.getMetadataSchema().getName());
                    metadata.getElement().add(schema);
                }
<<<<<<< HEAD
=======

>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
                fillSchemaElement(schema, val);
            } catch (SQLException se) {
                throw new RuntimeException(se);
            }
        }
<<<<<<< HEAD
        // Done! Metadata has been read!
        // Now adding bitstream info
        try {
            //ORG Element bundles = createBundlesElement(context, item);
	    //ORG metadata.getElement().add(bundles);
            	//added steli as in P.Becker config for OAI-PMH embargo
		Element bundles = create("bundles");
		metadata.getElement().add(bundles);
		List<Bundle> bs = item.getBundles();		
		Group groupAnonymous = groupService.findByName(context, Group.ANONYMOUS);

		for (Bundle b : bs){
                  Element bundle = create("bundle");
                  bundles.getElement().add(bundle);
                  bundle.getField().add(createValue("name", b.getName()));
		  Element bitstreams = create("bitstreams");
                  bundle.getElement().add(bitstreams);
                  List<Bitstream> bits = b.getBitstreams();
                  for (Bitstream bit : bits){
		    Element bitstream = create("bitstream");
                    bitstreams.getElement().add(bitstream);
                    String url = "";
                    String bsName = bit.getName();
                    String sid = String.valueOf(bit.getSequenceID());
                    //String baseUrl = configurationService.getProperty("oai","bitstream.baseUrl");
                    String handle = null;
		    // get handle of parent Item of this bitstream, if there is one
		    List<Bundle> bn = bit.getBundles();
                    if (!bn.isEmpty()){
                        List<Item> bi = bn.get(0).getItems();
                        if (!bi.isEmpty()){
                            handle = bi.get(0).getHandle();
                        }
                    }
		    //url = baseUrl + "/bitstreams/" + bit.getID().toString() + "/download";  //org
		    url = "https://repotest.ub.fau.de/bitstreams/" + bit.getID().toString() + "/download";
		    
		    // Find Embargo end date of the bitstream (if there is one)
		    Date embargoEndDate = null;
		    //ORG, cant find function signature, maybe obsolete -> List<ResourcePolicy> policies = resourcePolicyService.find( context, bit, groupAnonymous, Constants.READ, -1);
                    List<ResourcePolicy> policies = resourcePolicyService.find( context, bit, groupAnonymous, Constants.READ);
		    // There should be at most one policy for this group, action and bitstream. If startDate exists, it means embargo date is startDate
		    for (ResourcePolicy policy : policies){
                        if (policy.getStartDate() != null){
                            embargoEndDate = policy.getStartDate();
                            break;
                        }
                    } 
		    String cks = bit.getChecksum();
                    String cka = bit.getChecksumAlgorithm();
                    String oname = bit.getSource();
                    String name = bit.getName();
                    String description = bit.getDescription();
		    
		    if (name != null){ bitstream.getField().add( createValue("name", name)); }
		    if (oname != null){ bitstream.getField().add( createValue("originalName", name)); }
		    if (description != null){ bitstream.getField().add( createValue("description", description));  }
		    
		    bitstream.getField().add( createValue("format", bit.getFormat(context).getMIMEType()));
		    bitstream.getField().add( createValue("size", "" + bit.getSizeBytes()));
                    bitstream.getField().add( createValue("url", url));
                    bitstream.getField().add( createValue("checksum", cks));
                    bitstream.getField().add( createValue("checksumAlgorithm", cka));
                    bitstream.getField().add( createValue("sid", bit.getSequenceID() + ""));
		    if (embargoEndDate != null){
                        bitstream.getField().add( createValue("embargoEndDate", embargoEndDate.toString()));
                        if (bitstreamMinEmbargoDate == null || embargoEndDate.before(bitstreamMinEmbargoDate)){
                            bitstreamMinEmbargoDate = embargoEndDate;
                        }
                        if (bitstreamMaxEmbargoDate == null || embargoEndDate.after(bitstreamMaxEmbargoDate)){
                            bitstreamMaxEmbargoDate = embargoEndDate; 
                        }
                    }
		}//end for bitstreams
	    }//end for bundles
        } 
	catch (SQLException e) {
            log.warn(e.getMessage(), e);
        }
        // add Other info and embargo
        Element other = create("others");
        other.getField().add(createValue("handle", item.getHandle()));
        other.getField().add(createValue("identifier", DSpaceItem.buildIdentifier(item.getHandle())));
        other.getField().add(createValue("lastModifyDate", item.getLastModified().toString()));
	//added steli for embargo for OpenAire and DNB OAI-PMH, see P/Becker github -->
	if (bitstreamMaxEmbargoDate != null){
            other.getField().add( createValue("bitstreamMaxEmbargoEnd", bitstreamMaxEmbargoDate.toString()));
        }
        if (bitstreamMinEmbargoDate != null){
            other.getField().add( createValue("bitstreamMinEmbargoEnd", bitstreamMinEmbargoDate.toString()));
        }
        try {
            DCDate itemEmbargo = null;
            if ((itemEmbargo = embargoService.getEmbargoTermsAsDate(context, item)) != null) {
                other.getField().add(  createValue("itemEmbargoEnd", itemEmbargo.toString()));
            }
        }
        catch (SQLException | AuthorizeException e){
            log.warn("Unable to get item embargo: " + e, e);
        }
	metadata.getElement().add(other);
=======

        // Done! Metadata has been read!
        // Now adding bitstream info
        try {
            Element bundles = createBundlesElement(context, item);
            metadata.getElement().add(bundles);
        } catch (SQLException e) {
            log.warn(e.getMessage(), e);
        }

        // Other info
        Element other = create("others");

        other.getField().add(createValue("handle", item.getHandle()));
        other.getField().add(createValue("identifier", DSpaceItem.buildIdentifier(item.getHandle())));
        other.getField().add(createValue("lastModifyDate", item.getLastModified().toString()));
        metadata.getElement().add(other);
>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb

        // Repository Info
        Element repository = create("repository");
        repository.getField().add(createValue("url", configurationService.getProperty("dspace.ui.url")));
        repository.getField().add(createValue("name", configurationService.getProperty("dspace.name")));
        repository.getField().add(createValue("mail", configurationService.getProperty("mail.admin")));
        metadata.getElement().add(repository);

        // Licensing info
        try {
            Element license = createLicenseElement(context, item);
            metadata.getElement().add(license);
        } catch (AuthorizeException | IOException | SQLException e) {
            log.warn(e.getMessage(), e);
        }
<<<<<<< HEAD
=======

>>>>>>> ec0853ddad290f20cf4b7d647891df2011f1eafb
        return metadata;
    }
}
