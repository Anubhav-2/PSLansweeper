Select Top 1000000 tblAssets.AssetID As [Asset ID],
 tblAssets.AssetName,
 tblAssets.Lastseen,
 tblAssets.Lasttried
 From tblAssets
 Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
 Inner Join tblAssetGroupLink On tblAssets.AssetID = tblAssetGroupLink.AssetID
 Inner Join tblAssetGroups On tblAssetGroups.AssetGroupID = tblAssetGroupLink.AssetGroupID
 Where tblAssetCustom.State = 1 And tblAssetGroups.AssetGroup Like 'IT Managed Redhat'
