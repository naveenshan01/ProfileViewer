# ProfileViewer
To view installed provisioning profiles in a mac. 

This is helpfull because latest Xcode remove the option provisioing file from Window>>Organizer.

To view profiles run the terminal script 'ProfileViewer' (Just drop in the terminal and press enter).


Complete source is added in to the folder 'ProfileViewer-Source' which helps to modify the output structure and more parameters.  Which also shows how to decode a provisioing file using 'CMSDecoderRef'.

Sample Output
```
1 Name : AppName_Distribution AppId : com.company.appname -Type: ad-hoc 
     UUID : 013ff38a-55f0-4514-88f1-bd12efa38d3f -Expiry: 2016-06-13 16:56:48 +0000
2 Name : AppName_Development AppId : com.company.appname -Type: debug 
     UUID : 1a5c1555-759b-4394-960d-50b627605453 -Expiry: 2016-05-17 11:40:40 +0000
```
