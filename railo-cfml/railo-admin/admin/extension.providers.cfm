<!--- Action --->
<cfset stVeritfyMessages=struct()>
<cfparam name="error" default="#struct(message:"",detail:"")#">
<cfparam name="form.mainAction" default="none">
<cfset error.message="">
<cftry>

	<cfswitch expression="#form.mainAction#">

        <cfcase value="#stText.Buttons.verify#">
        	<cfset data.urls=toArrayFromForm("url")>
        	<cfset data.rows=toArrayFromForm("row")>
            <cfloop from="1" to="#arrayLen(data.urls)#" index="idx">
            	<cfif arrayIndexExists(data.rows,idx)>
                	
                        
                    <cftry>
                        <cfadmin 
                            action="verifyExtensionProvider"
                            type="#request.adminType#"
                            password="#session["password"&request.adminType]#"
                            
                            url="#trim(data.urls[idx])#">
                            <cfset stVeritfyMessages["#data.urls[idx]#"].Label = "OK">
                        <cfcatch>
                            <cfset stVeritfyMessages["#data.urls[idx]#"].Label = "Error">
                            <cfset stVeritfyMessages["#data.urls[idx]#"].message = cfcatch.message>
                            <cfset stVeritfyMessages["#data.urls[idx]#"].detail = cfcatch.detail>
                            
                        </cfcatch>
                    </cftry> 
                </cfif>
            </cfloop>
            
		</cfcase>
        <cfcase value="#stText.Buttons.save#">
        	<cfset data.urls=toArrayFromForm("url")>
        	<cfset data.rows=toArrayFromForm("row")>
            
            <cfloop from="1" to="#arrayLen(data.urls)#" index="idx">
            	<cfif arrayIndexExists(data.rows,idx)>
                	<cfadmin 
                        action="updateExtensionProvider"
                        type="#request.adminType#"
                        password="#session["password"&request.adminType]#"
                        
                        url="#trim(data.urls[idx])#">
                </cfif>
            </cfloop>
		</cfcase>
        <cfcase value="#stText.Buttons.delete#">
        	<cfset data.urls=toArrayFromForm("url")>
        	<cfset data.rows=toArrayFromForm("row")>
            
            <cfloop from="1" to="#arrayLen(data.urls)#" index="idx">
            	<cfif arrayIndexExists(data.rows,idx)>
                	<cfadmin 
                        action="removeExtensionProvider"
                        type="#request.adminType#"
                        password="#session["password"&request.adminType]#"
                        
                        url="#trim(data.urls[idx])#">
                </cfif>
            </cfloop>
		</cfcase>
        <cfcase value="#stText.Buttons.install#">
            <cfif StructKeyExists(form,"row") and StructKeyExists(data,"ids") and ArrayIndexExists(data.ids,row)>
            	<cflocation url="#request.self#?action=#url.action#&action2=install1&provider=#data.hashProviders[row]#&app=#data.ids[row]#" addtoken="no">
            </cfif>
		</cfcase>
	</cfswitch>
	<cfcatch>
		<cfset error.message=cfcatch.message>
		<cfset error.detail=cfcatch.Detail>
	</cfcatch>
</cftry>

<!--- 
Redirtect to entry --->
<cfif cgi.request_method EQ "POST" and error.message EQ "" and form.mainAction neq stText.Buttons.verify>
	<cflocation url="#request.self#?action=#url.action#" addtoken="no">
</cfif>


<!--- 
Error Output --->
<cfset printError(error)>

<cfadmin 
	action="getExtensionProviders"
	type="#request.adminType#"
	password="#session["password"&request.adminType]#"
	returnVariable="providers">

<cfset hasAccess=true>






<!--- 
list all mappings and display necessary edit fields --->
<script>
function checkTheBox(field) {
	var apendix=field.name.split('_')[1];
	var box=field.form['row_'+apendix];
	box.checked=true;
}

function selectAll(field) {
	var form=field.form;
	for(var key in form.elements){
		if((""+form.elements[key].name).indexOf("row_")==0){
			form.elements[key].checked=field.checked;
		}
	}
}
</script>
<cfoutput>


<table class="tbl" width="740">
<tr>
	<td colspan="3">#stText.ext.prov.IntroText#</td>
</tr>
<cfform action="#request.self#?action=#url.action#" method="post">
	<tr>
		<td width="30"><input type="checkbox" class="checkbox" name="rro" onclick="selectAll(this)"><cfmodule template="tp.cfm"  width="10" height="1"></td>
		<td width="640" class="tblHead" nowrap>#stText.ext.prov.url#</td>
		<td width="70" class="tblHead" nowrap>#stText.Settings.DBCheck#</td>
	</tr>
    
	<cfloop query="providers">
		<cfif true>
        <tr>
            <!--- checkbox ---->
            <td><table border="0" cellpadding="0" cellspacing="0">
            <tr>
                <td><cfif not providers.isReadOnly><input type="checkbox" class="checkbox" name="row_#providers.currentrow#" value="#providers.currentrow#"></cfif></td>
            </tr>
            </table></td>
            
            <!--- url --->
            <td height="30" class="tblContent" title="#providers.url#" nowrap>
            	<input type="hidden" name="url_#providers.currentrow#" value="#providers.url#">#providers.url#
             </td>
			<td class="tblContent" nowrap valign="middle" align="center">
				<cfif StructKeyExists(stVeritfyMessages, providers.url)>
					#stVeritfyMessages[providers.url].label#
					<cfif stVeritfyMessages[providers.url].label neq "OK">
						&nbsp;<cfmodule template="img.cfm" src="red-info.gif" 
							width="9" 
							height="9" 
							border="0" 
                            title="#stVeritfyMessages[providers.url].message##Chr(13)#"
							alt="#stVeritfyMessages[providers.url].message##Chr(13)#">
					</cfif>
				<cfelse>
					&nbsp;				
				</cfif>
			</td>
            
        </tr>
        </cfif>
    </cfloop>
    
    
    
<cfif hasAccess>
	<tr>
		<td><table border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td><input type="checkbox" class="checkbox" name="row_#providers.recordcount+1#" value="#providers.recordcount+1#"></td>
		</tr>
		</table></td>
		
		<td class="tblContent" nowrap colspan="2"><cfinput onKeyDown="checkTheBox(this)" type="text" 
			name="url_#providers.recordcount+1#" value="" required="no"  style="width:600px">
            <br /><span class="comment">&nbsp;&nbsp;#stText.ext.prov.urlDesc#</span></td>
	</tr>
</cfif>
<cfif hasAccess>
<cfmodule template="remoteclients.cfm" colspan="8" line=true>
	<tr>
		<td colspan="3">
		 <table border="0" cellpadding="0" cellspacing="0">
		 <tr>
			<td><cfmodule template="tp.cfm"  width="8" height="1"></td>		
			<td><cfmodule template="img.cfm" src="#ad#-bgcolor.gif" width="1" height="10"></td>
			<td></td>
		 </tr>
		 <tr>
			<td></td>
			<td valign="top"><cfmodule template="img.cfm" src="#ad#-bgcolor.gif" width="1" height="14"><cfmodule template="img.cfm" src="#ad#-bgcolor.gif" width="54" height="1"></td>
			<td>&nbsp;
			<input type="submit" class="submit" name="mainAction" value="#stText.Buttons.save#">
			<input type="submit" class="submit" name="mainAction" value="#stText.Buttons.verify#">
			<input type="submit" class="submit" name="mainAction" value="#stText.Buttons.Delete#">
			<input type="reset" class="reset" name="cancel" value="#stText.Buttons.Cancel#">
			</td>	
		</tr>
		 </table>
		 </td>
	</tr>
</cfif>
</cfform>
</cfoutput>
</table>