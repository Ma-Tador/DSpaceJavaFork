
package org.dspace.ctask.general;

import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.time.DateUtils;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.ResourcePolicy;
import org.dspace.authorize.factory.AuthorizeServiceFactory;
import org.dspace.authorize.service.AuthorizeService;
import org.dspace.authorize.service.ResourcePolicyService;
import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.BitstreamService;
import org.dspace.content.service.BundleService;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;
import org.dspace.curate.Distributive;
import org.apache.commons.collections.CollectionUtils;
import org.dspace.eperson.Group;
import org.dspace.eperson.factory.EPersonServiceFactory;
import org.dspace.eperson.service.GroupService;

import org.dspace.content.DSpaceObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import org.dspace.curate.Suspendable;

/**
 * A curator task creating zip archives in BagIt format for items with more than
 * one ORIGINAL bitstream.
 */
//@Distributive
@Suspendable
public class ArchiveOriginalBitstreams extends AbstractCurationTask {

    private final static String ARCHIVE_BUNDLE_NAME = "ARCHIVE";
    private final static String BAGIT_ARCHIVE_NAME = "container";
    private final static String BAGIT_ARCHIVE_FILE_NAME = BAGIT_ARCHIVE_NAME + ".zip";
    private final static String BAGIT_BASE_DIR = BAGIT_ARCHIVE_NAME + "/";
    private final static String BAGIT_PAYLOAD_DIR = "data/";
    private final static String BAGIT_MANIFEST_FILE_NAME = "manifest-md5.txt";
    private final static String BAGIT_DECLARATION_FILE_NAME = "bagit.txt";
    private final static String BAGIT_DECLARATION_CONTENT = "BagIt-Version: 0.97\nTag-File-Character-Encoding: UTF-8";

    private final static List<String> PUBLICATION_TYPES = Arrays.asList("book", "conferenceobject", "doctoralthesis", "habilitation", "masterthesis",
                                                            "other", "periodicalpart", "preprint", "report", "workingpaper", "article", "bookpart",
                                                            "studythesis", "postprint", "coursematerial", "bachelorthesis");

    private BitstreamService bitstreamService;
    private BundleService bundleService;
    private ResourcePolicyService resourcePolicyService;
    private AuthorizeService authorizeService;
    private GroupService groupService;
    private Group groupAnonymous;

    @Override
    public void init(Curator curator, String taskId) throws IOException {
        super.init(curator, taskId);
        bitstreamService = ContentServiceFactory.getInstance().getBitstreamService();
        bundleService = ContentServiceFactory.getInstance().getBundleService();
        resourcePolicyService = AuthorizeServiceFactory.getInstance().getResourcePolicyService();
        authorizeService = AuthorizeServiceFactory.getInstance().getAuthorizeService();
        groupService = EPersonServiceFactory.getInstance().getGroupService();
    }

    /**
     * Performs the archive curation task on an item. <br>
     * If there are at most one bitstream and no old archive, no action is
     * performed.<br>
     * Otherwise, if there is an old archive, it is checked whether all
     * checksums match. If they do not, the old archive is removed.
     *
     * @param dso the DSpace Object
     * @return result indicating if the processing was performed successfully
     * @throws IOException
     */
    @Override
    public int perform(DSpaceObject dso) throws IOException {
        int result = Curator.CURATE_FAIL;
        StringBuilder sb = new StringBuilder();

        if (dso.getType() == Constants.ITEM) {
            Item item = (Item) dso;
            try {
                // Skip items if in submission workflow
                if (itemService.isInProgressSubmission(Curator.curationContext(), item)) {
                    System.out.println("Item " + item.getHandle() + " SKIPPED, because it is in submission workflow.");
                    setResult("Object skipped");
                    result = Curator.CURATE_SKIP;
                    System.out.println("--------------------------------------------------------------------------");
                    return result;
                }
                // Create archive if item type is publication (NOT for research data)
                String dcType = itemService.getMetadataFirstValue(item, "dc", "type", null, Item.ANY);
                List<Bitstream> originalBitstreams = getOriginalBitstreams(item);
                List<Bundle> archiveBundles = itemService.getBundles(item, ARCHIVE_BUNDLE_NAME);
                if (groupAnonymous == null) {
                    groupAnonymous = groupService.findByName(Curator.curationContext(), Group.ANONYMOUS);
                }
                //skip item if just 1 original bitstream =>  NO need to create archive_bundle
                if (originalBitstreams.size() < 2 && CollectionUtils.isEmpty(archiveBundles)) {
                    System.out.println("Item " + item.getHandle() + " SKIPPED, because has just 1 bistream. No need to create archive for 1 bistream.");
                    setResult("Item " + item.getID() + "skipped, because it has 1 bitstream ( NO need to create archive for 1 bitstream)");
                    result = Curator.CURATE_SKIP;
                    System.out.println("--------------------------------------------------------------------------");
                    return result;
                }
                //if item has NO archive_bundle, but has more than 1 bitsrtream
                if (CollectionUtils.isEmpty(archiveBundles)) {
                    System.out.println("Item " + item.getHandle() + " has NOT yet an ARCHIVE. Processing...");
                    //skip item if NOT a publication and NO existing archive_bundle 
                    if (!PUBLICATION_TYPES.contains(dcType)) {
                        System.out.println("Item " + item.getHandle() + " SKIPPED, because is not a publication. Doc type: " + dcType);
                        setResult("Item " + item.getID() + "skipped, because is NOT a publiction. Document type for this item is: " + dcType);
                        result = Curator.CURATE_SKIP;
                        System.out.println("--------------------------------------------------------------------------");
                        return result;
                    }
                    //create archive_bundle (if NO archive_bundle existing and more than 1 bitstream)
                    Bundle archiveBundle = bundleService.create(Curator.curationContext(), item, ARCHIVE_BUNDLE_NAME);
                    String createMessage = createArchiveBitstream(archiveBundle, originalBitstreams);
                    itemService.updateLastModified(Curator.curationContext(), item);
                    sb.append("The item with handle ").append(item.getHandle()).append(" has ").append(originalBitstreams.size()).append(" bitstreams. New zip archive created. ");
                    if (createMessage != null) {
                        sb.append(createMessage);
                    }
                    System.out.println("Item " + item.getHandle() + " receives a NEW archive.");
                    report(sb.toString());
                    setResult(sb.toString());
                    result = Curator.CURATE_SUCCESS;
                } else { // if item has already an archive_bundle
                    System.out.println("Item " + item.getHandle() + " has ALREADY an ARCHIVE. Checking existing archive...");
                    // check if the checksums match for archive_bundle with originalBistrams
                    Bundle archiveBundle = archiveBundles.get(0);
                    //if checksum NOT matching, create new archive if more than 1 bitstream
                    if (!archiveChecksumsMatch(originalBitstreams, archiveBundle)) {
                        Bitstream archiveBitstream = bitstreamService.getBitstreamByName(item, ARCHIVE_BUNDLE_NAME, BAGIT_ARCHIVE_FILE_NAME);
                        bundleService.removeBitstream(Curator.curationContext(), archiveBundle, archiveBitstream);
                        // Create new archive if more than 1 bitstream
                        if (originalBitstreams.size() > 1) {
                            System.out.println("Item " + item.getHandle() + " checksum error. Replacing old archive with NEW created archive...");
                            String createMessage = createArchiveBitstream(archiveBundle, originalBitstreams);
                            itemService.updateLastModified(Curator.curationContext(), item);
                            sb.append("Checksums don't match; zip archive replaced for item with handle ").append(item.getHandle());
                            if (createMessage != null) {
                                sb.append("; ").append(createMessage);
                            }
                            System.out.println("Done. Item " + item.getHandle() + " archive updated.");
                            report(sb.toString());
                            setResult(sb.toString());
                            result = Curator.CURATE_SUCCESS;
                        }
                    } else { //if checksum matches
                        System.out.println("Done. Item " + item.getHandle() + " archive updated.");
                        report("All checksums match for item with handle " + item.getHandle());
                        report("Checksum check of archive successfull.");
                        setResult("Checksum check of archive successfull.");
                        result = Curator.CURATE_SUCCESS;
                    }
                    // Check if archiveEmbargoEndDate matches the originalBistreamsMaxEmbargoEndDate
                    Date maxEmbargoEndDate = getMaxEmbargoEndDate(originalBitstreams);
                    Date archiveEmbargoEndDate = getMaxEmbargoEndDate(archiveBundle.getBitstreams());
                    //if originalBistreamEmbargoDate set but archiveEmbargoDate NOT set OR originalEmbargoDate != archiveEmbargoDate
                    if (maxEmbargoEndDate != null && (archiveEmbargoEndDate == null || !DateUtils.isSameDay(maxEmbargoEndDate, archiveEmbargoEndDate))) {
                        System.out.println("Item " + item.getHandle() + " embargoDate updated.");
                        sb.append("A bitstream's embargo end date is later than the archive's date. Changing it in the archive to date: ").append(maxEmbargoEndDate);
                        report(sb.toString());
                        setResult(sb.toString());
                        //update archiveEmbargoDate to be same as maxEmbargo of originalBitstreams
                        Bitstream archiveBitstream = bitstreamService.getBitstreamByName(item, ARCHIVE_BUNDLE_NAME, BAGIT_ARCHIVE_FILE_NAME);
                        List<ResourcePolicy> resourcePolicies = resourcePolicyService.find(Curator.curationContext(), archiveBitstream, groupAnonymous, Constants.READ);
                        for (ResourcePolicy resourcePolicy : resourcePolicies) {
                            authorizeService.createOrModifyPolicy(resourcePolicy, Curator.curationContext(), null, groupAnonymous, null, maxEmbargoEndDate, Constants.READ, null, archiveBitstream);
                        }
                        result = Curator.CURATE_SUCCESS;
                    } else { //if archiveEmbargoDate matches originalBitstreamEmabrgoDate, do nothing
                        System.out.println("Item " + item.getHandle() + " embargoDate matches for archive and bitstreams. No embargoDate to update.");
                        report("Embargo end date matches for item with handle " + item.getHandle());
                        result = Curator.CURATE_SUCCESS;
                    }
                }
                if (archiveBundles.size() > 1) {  //ERROR, should be always just 1 archive for an item
                    System.out.println("Item " + item.getHandle() + " ERROR. Item should have only 1 archive.");
                    report("There is more than one " + ARCHIVE_BUNDLE_NAME + " bundle present in item " + item.getID() + ", this should never be the case!");
                }
            } catch (AuthorizeException e) {
                System.out.println("Error creating or modifying embargo end date: " + e);
            }catch (SQLException e) {
                System.out.println("Error creating or modifying embargo end date: " + e);
            }
        }
        else {
         System.out.println("DSpaceObject " + dso.getHandle() +  "  skipped, because is not an Item.");
         setResult("Object skipped");
         result = Curator.CURATE_SKIP;
        }
        System.out.println("--------------------------------------------------------------------------");
        return result;
     }
        /**
         * Creates a bitstream with a zip archive of all original bitstreams.
         *
         * @param archiveBundle the archive bundle
         * @param originalBitstreams a list of original bitstreams.
         * @throws SQLException
         * @throws IOException
         * @throws AuthorizeException
         */
    private String createArchiveBitstream(Bundle archiveBundle, List<Bitstream> originalBitstreams)
            throws SQLException, IOException, AuthorizeException {
        String returnMessage = null;

        Context context = Curator.curationContext();
        File archiveFile = createBagitZipArchive(context, originalBitstreams);
        Bitstream archiveBitstream = bitstreamService.create( Curator.curationContext(), archiveBundle, new FileInputStream(archiveFile));
        archiveBitstream.setName(context, BAGIT_ARCHIVE_FILE_NAME);
        // Set the embargo end date for the archive to the last embargo end date of all the bitstreams.
        Date maxEmbargoDate = getMaxEmbargoEndDate(originalBitstreams);
        if (maxEmbargoDate != null) {
            returnMessage = "Setting embargo for archive to " + maxEmbargoDate;
            report(returnMessage);
            authorizeService.createOrModifyPolicy( null, context, null, groupAnonymous, null, maxEmbargoDate, Constants.READ, null, archiveBitstream);
        }
        return returnMessage;
    }

    /**
     * Gets the maximum embargo end date of all bitstreams in the list.
     *
     * @param originalBitstreams
     * @return the max embargo end date or null if no embargo set.
     * @throws SQLException
     */
    private Date getMaxEmbargoEndDate(List<Bitstream> originalBitstreams)
            throws SQLException {
        Date maxEmbargoDate = null;
        for (Bitstream bitstream : originalBitstreams) {
            List<ResourcePolicy> resourcePolicies = resourcePolicyService.find( Curator.curationContext(), bitstream, groupAnonymous, Constants.READ);
            for (ResourcePolicy resourcePolicy : resourcePolicies) {
                if (resourcePolicy.getStartDate() != null) {
                    report(" - Bitstream embargo found: " + resourcePolicy.getStartDate());
                    if (maxEmbargoDate == null || maxEmbargoDate.before(resourcePolicy.getStartDate())) {
                        maxEmbargoDate = resourcePolicy.getStartDate();
                    }
                }
            }
        }
        return maxEmbargoDate;
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

    /**
     * Checks if the checksums of the ORIGINAL bitstream are the same as those
     * for the files in the archive BagIt zip.
     *
     * @param originalBitstreams the ORIGINAL bitstreams
     * @param archiveBundle the archive bundle
     * @return true, if all ORIGINAL bitstreams are present in the archive and
     * all the checksums match.
     *
     * @throws SQLException
     * @throws IOException
     * @throws AuthorizeException
     */
    private boolean archiveChecksumsMatch(List<Bitstream> originalBitstreams, Bundle archiveBundle)
            throws SQLException, IOException, AuthorizeException {

        List<Bitstream> archiveBitstreams = archiveBundle.getBitstreams();
        // This shouldn't happen, but when it does, a new archive must be generated.
        if (CollectionUtils.isEmpty(archiveBitstreams)) {
            return false;
        }
        InputStream archiveInputStream = bitstreamService.retrieve(Curator.curationContext(), archiveBitstreams.get(0));
        ZipInputStream zipInputStream = new ZipInputStream(archiveInputStream);
        String manifestContent = getManifestContent(zipInputStream, BAGIT_BASE_DIR + BAGIT_MANIFEST_FILE_NAME);
        Map<String, String> checksumMap = getChecksumMap(manifestContent);
        if (originalBitstreams.size() != checksumMap.size()) {
            return false;
        }
        for (Bitstream bitstream : originalBitstreams) {
            if (!StringUtils.equals(checksumMap.get(BAGIT_PAYLOAD_DIR + getMd5FileName(bitstream.getName())), bitstream.getChecksum())) {
                return false;
            }
        }
        return true;
    }

    /**
     * Gets the contents of the manifest file of a BagIt zip-file.
     *
     * @param zipInputStream the input stream of the zip file
     * @param manifestFileName the name of the manifest file
     * @return a string with the manifest content
     * @throws IOException if the zip stream cannot de read
     */
    private String getManifestContent(ZipInputStream zipInputStream, String manifestFileName)
            throws IOException {
        String content = null;
        ZipEntry zipEntry;
        while ((zipEntry = zipInputStream.getNextEntry()) != null) {
            if (StringUtils.equals(manifestFileName, zipEntry.getName())) {
                content = IOUtils.toString(zipInputStream, Charset.forName("UTF-8"));
            }
        }
        return content;
    }

    /**
     * Creates a map with file names as keys and checksums as values from the
     * content of a BagIt manifest file.
     *
     * @param manifestContent the content of the manifest file as string.
     * @return a map with the result.
     */
    private Map<String, String> getChecksumMap(String manifestContent) {
        Map<String, String> checksumMap = new HashMap<>();
        if (manifestContent != null) {
            String[] rows = manifestContent.split("\\n");
            for (String row : rows) {
                String[] valueKey = row.split(" ", 2);
                if (valueKey.length == 2) {
                    checksumMap.put(valueKey[1], valueKey[0]);
                }
            }
        }
        return checksumMap;
    }

    /**
     * Creates a zip archive according to BagIt specifications.
     *
     * @param context the curator context
     * @param bitstreamList a list of bitstreams for the archive
     * @return the generated zip file
     * @throws SQLException
     * @throws IOException
     * @throws AuthorizeException
     */
    private File createBagitZipArchive(Context context, List<Bitstream> bitstreamList)
            throws SQLException, IOException, AuthorizeException {
        if (bitstreamList == null || bitstreamList.size() == 0) {
            return null;
        }
        String tempFileName = bitstreamList.get(0).getChecksum();
        File tempZipFile = File.createTempFile(tempFileName, ".zip");
        Set<String> fileNamesInZip = new HashSet();
        try {
            FileOutputStream fileOutputStream = new FileOutputStream(tempZipFile);
            ZipOutputStream zipOutputStream = new ZipOutputStream(fileOutputStream, Charset.forName("UTF-8"));
            StringBuffer checksums = new StringBuffer();
            for (Bitstream bitstream : bitstreamList) {
                String fileName = getMd5FileName(bitstream.getName());
                // You can't have several files with the same name in a zip
                if (fileNamesInZip.contains(fileName)) {
                    continue;
                } else {
                    fileNamesInZip.add(fileName);
                }
                addZipEntry(zipOutputStream, fileName, bitstreamService.retrieve(context, bitstream));
                // For the BagIt checksum file
                checksums.append(bitstream.getChecksum());
                checksums.append(" ");
                checksums.append(BAGIT_PAYLOAD_DIR + fileName);
                checksums.append("\n");
            }
            //Write manifest file to zip
            ZipEntry zipEntry = new ZipEntry(BAGIT_BASE_DIR + BAGIT_MANIFEST_FILE_NAME);
            zipOutputStream.putNextEntry(zipEntry);
            zipOutputStream.write(checksums.toString().getBytes());
            //Write begit declation file to zip
            zipEntry = new ZipEntry(BAGIT_BASE_DIR + BAGIT_DECLARATION_FILE_NAME);
            zipOutputStream.putNextEntry(zipEntry);
            zipOutputStream.write(BAGIT_DECLARATION_CONTENT.getBytes());
            zipOutputStream.close();
            fileOutputStream.close();
        } catch (IOException e) {
            System.out.println("Error creating zip archive: " + e);
            throw e;
        }
        return tempZipFile;
    }

    /**
     * Adds a zip entry to a zipOutputStream using an inputStream.
     *
     * @param zipOutputStream
     * @param fileName
     * @param inputStream
     * @throws IOException
     */
    void addZipEntry(ZipOutputStream zipOutputStream, String fileName, InputStream inputStream)
            throws IOException {
        ZipEntry zipEntry = new ZipEntry(BAGIT_BASE_DIR + BAGIT_PAYLOAD_DIR + fileName);
        zipOutputStream.putNextEntry(zipEntry);
        int length;
        byte[] buffer = new byte[2048];
        while ((length = inputStream.read(buffer, 0, buffer.length)) > 0) {
            zipOutputStream.write(buffer, 0, length);
        }
        zipOutputStream.closeEntry();
        inputStream.close();
    }

    /**
     * Creates a md5 string from the filename and appends the extension (if
     * any).
     *
     * @param fileName the name of the file
     * @return a string with the me5 filename
     */
    String getMd5FileName(String fileName) {
        String extension = FilenameUtils.getExtension(fileName);
        if (StringUtils.isNotEmpty(extension)) {
            extension = "." + extension;
        }
        return DigestUtils.md5Hex(fileName) + extension;
    }
}
