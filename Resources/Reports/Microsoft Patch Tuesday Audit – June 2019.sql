﻿Select Distinct Top 1000000
    Coalesce(tsysOS.Image,
tsysAssetTypes.AssetTypeIcon10) As icon,
    tblAssets.AssetID,
    tblAssets.AssetName,
    tblAssets.Domain,
    tblState.Statename As State,
    Case tblAssets.AssetID
When SubQuery1.AssetID Then 'Up to date'
Else 'Out of date'
End As [Patch status],
    Case
When tblComputersystem.Domainrole > 1 Then 'Server'
Else 'Workstation'
End As [Workstation/Server],
    tblAssets.Username,
    tblAssets.Userdomain,
    tblAssets.IPAddress,
    tsysIPLocations.IPLocation,
    tblAssetCustom.Manufacturer,
    tblAssetCustom.Model,
    tsysOS.OSname As OS,
    tblAssets.SP,
    Case
When tsysOS.OScode Like '10.0.10240%' Then '1507'
When tsysOS.OScode Like '10.0.10586%' Then '1511'
When tsysOS.OScode Like '10.0.14393%' Then '1607'
When tsysOS.OScode Like '10.0.15063%' Then '1703'
When tsysOS.OScode Like '10.0.16299%' Then '1709'
When tsysOS.OScode Like '10.0.17134%' Then '1803'
When tsysOS.OScode Like '10.0.17763%' Then '1809'
When tsysOS.OScode Like '10.0.18362%' Then '1903'
End As Version,
    tblAssets.Lastseen,
    tblAssets.Lasttried,
    Case
When tblErrors.ErrorText Is Not Null Or
        tblErrors.ErrorText != '' Then
'Scanning Error: ' + tsysasseterrortypes.ErrorMsg
Else ''
End As ScanningErrors,
    Case
When tblAssets.AssetID = SubQuery1.AssetID Then ''
Else Case
When tsysOS.OSname = 'Win 2008' Then 'KB4503273 or KB4503287'
When tsysOS.OSname = 'Win 7' Or tsysOS.OSname = 'Win 7 RC' Or
        tsysOS.OSname = 'Win 2008 R2' Then 'KB4503292 or KB4503269'
When tsysOS.OSname = 'Win 2012' Or
        tsysOS.OSname = 'Win 8' Then 'KB4503285 or KB4503263'
When tsysOS.OSname = 'Win 8.1' Or
        tsysOS.OSname = 'Win 2012 R2' Then 'KB4503276 or KB4503290'
When tsysOS.OScode Like '10.0.10240' Then 'KB4503291'
When tsysOS.OScode Like '10.0.10586' Then 'KB4093109'
When tsysOS.OScode Like '10.0.14393' Or
        tsysOS.OSname = 'Win 2016' Then 'KB4503267'
When tsysOS.OScode Like '10.0.15063' Then 'KB4503279'
When tsysOS.OScode Like '10.0.16299' Then 'KB4503284'
When tsysOS.OScode Like '10.0.17134' Then 'KB4503286'
When tsysOS.OScode Like '10.0.17763' Or
        tsysOS.OSname = 'Win 2019' Then 'KB4503327'
When tsysOS.OScode Like '10.0.18362' Then 'KB4503293'
End
End As [Install one of these updates],
    Convert(nvarchar,DateDiff(day, QuickFixLastScanned.QuickFixLastScanned,
GetDate())) + ' days ago' As WindowsUpdateInfoLastScanned,
    Case
When Convert(nvarchar,DateDiff(day, QuickFixLastScanned.QuickFixLastScanned,
GetDate())) > 3 Then
'Windows update information may not be up to date. We recommend rescanning this machine.'
Else ''
End As Comment,
    Case tblAssets.AssetID
When SubQuery1.AssetID Then '#d4f4be'
Else '#ffadad'
End As backgroundcolor
From tblAssets
    Inner Join tblAssetCustom On tblAssets.AssetID = tblAssetCustom.AssetID
    Left Join tsysOS On tsysOS.OScode = tblAssets.OScode
    Left Join (Select Top 1000000
        tblQuickFixEngineering.AssetID
    From tblQuickFixEngineering
        Inner Join tblQuickFixEngineeringUni On tblQuickFixEngineeringUni.QFEID
= tblQuickFixEngineering.QFEID
    Where tblQuickFixEngineeringUni.HotFixID In ('KB4503273','KB4503287','KB4503292','KB4503269','KB4503285',
'KB4503263','KB4503276','KB4503290','KB4503291','KB4093109','KB4503267','KB4503279','KB4503284','KB4503286',
'KB4503327','KB4503293')) As
SubQuery1 On tblAssets.AssetID = SubQuery1.AssetID
    Inner Join tsysAssetTypes On tsysAssetTypes.AssetType = tblAssets.Assettype
    Inner Join tblOperatingsystem On tblOperatingsystem.AssetID =
tblAssets.AssetID
    Left Join tsysIPLocations On tblAssets.IPNumeric >= tsysIPLocations.StartIP
        And tblAssets.IPNumeric <= tsysIPLocations.EndIP
    Inner Join tblState On tblState.State = tblAssetCustom.State
    Left Join (Select Distinct Top 1000000
        tblAssets.AssetID As ID,
        TsysLastscan.Lasttime As QuickFixLastScanned
    From TsysWaittime
        Inner Join TsysLastscan On TsysWaittime.CFGCode = TsysLastscan.CFGcode
        Inner Join tblAssets On tblAssets.AssetID = TsysLastscan.AssetID
    Where TsysWaittime.CFGname = 'QUICKFIX') As QuickFixLastScanned On
tblAssets.AssetID = QuickFixLastScanned.ID
    Left Join (Select Distinct Top 1000000
        tblAssets.AssetID As ID,
        Max(tblErrors.Teller) As ErrorID
    From tblErrors
        Inner Join tblAssets On tblAssets.AssetID = tblErrors.AssetID
    Group By tblAssets.AssetID) As ScanningError On tblAssets.AssetID =
ScanningError.ID
    Left Join tblErrors On ScanningError.ErrorID = tblErrors.Teller
    Left Join tsysasseterrortypes On tsysasseterrortypes.Errortype =
tblErrors.ErrorType
    Inner Join tblComputersystem On tblAssets.AssetID = tblComputersystem.AssetID
Where tblAssets.AssetID Not In (Select Top 1000000
        tblAssets.AssetID
    From tblAssets Inner Join tsysOS On tsysOS.OScode = tblAssets.OScode
    Where tsysOS.OSname Like 'Win 7%' And tblAssets.SP = 0) And
    tsysOS.OSname != 'Win 2000 S' And tsysOS.OSname Not Like '%XP%' And
    tsysOS.OSname Not Like '%2003%' And tsysAssetTypes.AssetTypename Like
'Windows%' And tblAssetCustom.State = 1
Order By tblAssets.Domain,
tblAssets.AssetName