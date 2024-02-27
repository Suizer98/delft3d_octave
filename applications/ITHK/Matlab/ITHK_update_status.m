function ITHK_update_status(status)

global S

root.status=status;
xml_write(S.statusFilename,root);
mput(S.h,S.statusFilename);
delete(S.statusFilename);
