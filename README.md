# delete-blobs
Delete large number of blobs in chunks of 10000 in Azure Automation

This PowerShell script, designed to run in Azure Automatiom, deletes huge number of blobs in a container, by processing them in chunks of 10,000 blobs at a time. When the  number of blobs grows beyond a couple of thousands, the usual method of deleting each blob at a time may just get suspended without completing the task.

This could be used to to delete all blobs (when parameter retentionDays is supplied as 0), or certain blobs which has not been modified for the last rententionDays number of days.


## Note: 
The script was written long back and has not been maintained/tested for a while. 
It was erlier available here: https://gallery.technet.microsoft.com/Delete-large-number-of-97e04976

Since Technet Gallery is retiring, I wanted to keep a backup here - in case we might need it later ;-)