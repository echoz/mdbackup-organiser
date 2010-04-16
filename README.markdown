mdbackup-organiser
==================

All iPhone/iPod touch backups are store in directories in ~/Library/Application Support/MobileSync/Backups.
They are stored in directories that have the GUID of the device suffixed by the timestamp of the back up.

Within these directories they consist of .mdinfo, .mddata as well as 3 plists that provide metadata information about the backup.

What mbbackup-organiser does is that you specify an iTunes backup directory and it will organise the files based upon the Manifest.plist into the source directory.

A general layout after running the tool against say ~/Library/Application Support/MobileSync/Backup/<device UUID> will give

	Applications
	. com.lexcycle.stanza
	.. 32904980902904380204320.mdinfo
	.. 32904980902904380204320.mddata
	.. etc.
	Files
	. HomeDomain
	. MediaDomain
	. KeychainDomain
	. Library

PLIST
-----
- Info.plist
Contains information about the backup and other generic information about the device associated with the back up.

- Status.plist
Status on the backup. If it were successful or not.

- Manifest.plist
Metadata file that contains a base64 encoded plist with the actual manifest data. The binary plist is used to identify the various .mddata and .mdinfo files.



.MDDATA/.MDINFO
---------------
These files come in a pair. 

MDINFO files are binary plists that contain metadata and also the actual mdinfo base64 encoded. They provide information about the .mddata about the domain it is in as well as its path and other related information.

There are 5 known domains, AppDomain, MediaDomain, HomeDomain, LibraryDomain, KeychainDomain. These correspond to actual locations as well as type of files on the iPhone.

MDDATA files are just basically any kind of file that has been renamed with a SHA1 hash of its file/path and suffixed with .mddata. They can be images, sqlite databases, epubs, etc.



SELECTIVELY RESTORE APPLICATIONS
--------------------------------
In no way is this an official method to do this so proceed at your own risk.

1. Remove all backups that iTunes currently has in iTunes preferences.
2. After a fresh restore of the iPhone OS on any iPhone OS device. Do a backup of the device by Ctrl + Clicking on the device in iTunes and choose backup.
3. Disconnect the device.
4. Navigate to the mobilesync/backups directory and copy all related .mdinfo and .mddata of Applications you want to restore into the directory replacing any of it were existing.
5. Do the same for the other Domains. Ensure that all .mddata and .mdinfo are not in a directory except the current directory it is in.
6. Copy Info.plist, Status.plist, and Manifest.plist into the backup directory as well.
7. Connect your device, ensure it doesn't sync automatically.
8. Ctrl + Click on the device in iTunes and select restore. There should only be one option.
9. Make tea/coffee and wait it out.