<#
.Synopsis
  Deletes large number of blobs in a container of Storage account, which are older than x days

.DESCRIPTION
  This Runbook deletes huge number of blobs in a container, by processing them in chunks of 10,000 blobs at a time. When the number of blobs grow beyond a couple of thousands, the usual method of deleting each blob at a time may just get suspended without completing the task. 

.PARAMETER CredentialAssetName
	The Credential asset which contains the credential for connecting to subscription

.PARAMETER Subscription
	Name of the subscription attached to the credential in CredentialAssetName

.PARAMETER container
	Container name from which the blobs are to be deleted

.PARAMETER AzStorageName
	The Storage Name to which the container belong to
	
.PARAMETER retentionDays
	Retention days. Blobs older than these many days will be deleted. To delete all, use 0
	
.NOTES
   AUTHOR: Anurag Singh, MSFT
   LASTEDIT: March 30, 2016
#>

function delete-blobs
{   
    param (
        [Parameter(Mandatory=$true)] 
        [String]  $CredentialAssetName,
        
        [Parameter(Mandatory=$true)]
        [String] $Subscription,

        [Parameter(Mandatory=$true)] 
        [String] $container,
		
		[Parameter(Mandatory=$true)] 
        [String] $AzStorageName,
		
		[Parameter(Mandatory=$true)] 
        [Int] $retentionDays
    )

$Cred = Get-AutomationPSCredential -Name $CredentialAssetName
$Account = Add-AzureAccount -Credential $Cred

if(!$Account) 
{
    write-output "Connection to Azure Subscription using the Credential asset failed..."
	Break;
}

set-AzureSubscription -SubscriptionName $Subscription

$AzStorageKey = (Get-AzureStorageKey -StorageAccountName $AzStorageName).Primary
$context = New-AzureStorageContext -StorageAccountName $AzStorageName -StorageAccountKey $AzStorageKey


$blobsremoved = 0
$MaxReturn = 10000
$Total = 0
$Token = $Null
$TotalDel = 0
$dateLimit = (get-date).AddDays(-$retentionDays) 

try
{
	do
	{
		Write-Output "Retrieving blobs"
		$blobs = Get-AzureStorageBlob -Container $container -context $context -MaxCount $MaxReturn  -ContinuationToken $Token 
		$blobstodelete =  $blobs | where LastModified -LE $dateLimit
		$Total += $Blobs.Count
		Write-Output "$Total  total Retrieved blobs"
 
		$Token = $Blobs[$blobs.Count -1].ContinuationToken;

		if($Blobs.Length -le 0) 
		{ 
			break;
		}

		if($blobstodelete.Length -le 0) 
		{ 
			continue;
		}

		$TotalDel += $blobstodelete.Count

		$blobstodelete  | Remove-AzureStorageBlob -Force 

		Write-Output "$TotalDel  blobs deleted"
	}
	While ($Token -ne $Null)
}

catch 
{
	write-output $_
}

}