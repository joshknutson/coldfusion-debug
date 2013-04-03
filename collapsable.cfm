<cfif IsDebugMode()>
	<cfsilent>
		<cfset startTime = getTickCount()>
		<cfscript>
			formEncoding = getEncoding("FORM");
			urlEncoding = getEncoding("URL");
			setEncoding("FORM", formEncoding);
			setEncoding("URL", urlEncoding);
		</cfscript>
	<!--- Localized strings --->
		<cfset undefined = ""/>
		<!--- Use the debugging service to check options --->
		<cftry>
			<cfobject action="CREATE" type="JAVA" class="coldfusion.server.ServiceFactory" name="factory">
			<cfset cfdebugger = factory.getDebuggingService()>
			<cfcatch type="Any"></cfcatch>
		</cftry>

		<!--- Load the debugging service's event table --->
		<cfset qEvents = cfdebugger.getDebugger().getData()>

		<!--- Produce the filtered event queries --->
		<!--- EVENT: Templates --->
		<cftry>
			<cfquery dbType="query" name="cfdebug_templates" debug="false">
				SELECT template, parent, Sum(endTime - StartTime) AS et
				FROM qEvents
				WHERE type = 'Template'
				GROUP BY template, parent
				ORDER BY et DESC
			</cfquery>
			<cfscript>
				if( cfdebug_templates.recordCount eq 1 and len(trim(cfdebug_templates.et))){
					querySetCell(cfdebug_templates, "et", "0", 1);
				}
			</cfscript>
			<cfcatch type="Any">
				<cfscript>
					cfdebug_templates = queryNew('template, parent, et');
				</cfscript>
			</cfcatch>
		</cftry>

		<!--- EVENT: SQL Queries --->
		<cftry>
			<cfquery dbType="query" name="cfdebug_queries" debug="false">
				SELECT *, (endTime - startTime) AS executionTime
				FROM qEvents
				WHERE type = 'SqlQuery'
			</cfquery>
			<cfscript>
				if(cfdebug_queries.recordCount eq 1 and len(trim(cfdebug_queries.executionTime))){
					querySetCell(cfdebug_queries, "executionTime", "0", 1);
				}
			</cfscript>
			<cfcatch type="Any">
				<cfscript>
					cfdebug_queries = queryNew('ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL, et');
				</cfscript>
			</cfcatch>
		</cftry>

		<!--- EVENT: Object Queries --->
		<cftry>
			<cfquery dbType="query" name="cfdebug_cfoql" debug="false">
				SELECT *, (endTime - startTime) AS executionTime
				FROM qEvents
				WHERE type = 'ObjectQuery'
			</cfquery>
			<cfscript>
				if( cfdebug_cfoql.recordCount eq 1 and len(trim(cfdebug_cfoql.executionTime))){
					querySetCell(cfdebug_cfoql, "executionTime", "0", 1);
				}
			</cfscript>
			<cfcatch type="Any">
				<cfscript>
					cfdebug_cfoql = queryNew('ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL');
				</cfscript>
			</cfcatch>
		</cftry>

		<!--- EVENT: Stored Procedures --->
		<cftry>
			<cfquery dbType="query" name="cfdebug_storedproc" debug="false">
				SELECT *, (endTime - startTime) AS executionTime
				FROM qEvents
				WHERE type = 'StoredProcedure'
			</cfquery>
			<cfscript>
				if( cfdebug_storedproc.recordCount eq 1 and len(trim(cfdebug_storedproc.executionTime))){
					querySetCell(cfdebug_storedproc, "executionTime", "0", 1);
				}
			</cfscript>
			<cfcatch type="Any">
				<cfscript>
					cfdebug_storedproc = queryNew('ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL');
				</cfscript>
			</cfcatch>
		</cftry>

		<!--- EVENT: Trace Points --->
		<cftry>
			<cfquery dbType="query" name="cfdebug_trace" debug="false">
				SELECT *
				FROM qEvents
				WHERE type = 'Trace'
			</cfquery>
			<cfcatch type="Any">
				<cfscript>
					cfdebug_trace = queryNew('ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL');
				</cfscript>
			</cfcatch>
		</cftry>

		<!--- EVENT: CFTimer Points --->
		<cftry>
			<cfquery dbType="query" name="cfdebug_timer" debug="false">
				SELECT *
				FROM qEvents
				WHERE type = 'CFTimer'
			</cfquery>
			<cfcatch type="Any">
				<cfscript>
					cfdebug_timer = queryNew('ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL');
				</cfscript>
			</cfcatch>
		</cftry>

		<!--- EVENT: Locking Warning Points --->
		<cftry>
			<cfquery dbType="query" name="cfdebug_lock" debug="false">
				SELECT *
				FROM qEvents
				WHERE type = 'LockWarning'
			</cfquery>
			<cfcatch type="Any">
				<cfscript>
					cfdebug_lock = queryNew('ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL');
				</cfscript>
			</cfcatch>
		</cftry>

		<!--- EVENT: Exceptions --->
		<cftry>
			<cfquery dbType="query" name="cfdebug_ex" debug="false">
				SELECT *
				FROM qEvents
				WHERE type = 'Exception'
			</cfquery>
			<cfcatch type="Any">
				<cfscript>
					cfdebug_ex = queryNew('ATTRIBUTES, BODY, CACHEDQUERY, CATEGORY, DATASOURCE, ENDTIME, EXECUTIONTIME, LINE, MESSAGE, NAME, PARENT, PRIORITY, RESULT, ROWCOUNT, STACKTRACE, STARTTIME, TEMPLATE, TIMESTAMP, TYPE, URL');
				</cfscript>
			</cfcatch>
		</cftry>

		<!--- Establish Section Display Flags --->
		<cfparam name="displayDebug" default="false" type="boolean"><!--- ::	display the debug time 	:: --->
		<cfparam name="bGeneral" default="false" type="boolean">
		<cfparam name="bFoundExecution" default="false" type="boolean">
		<cfparam name="bFoundTemplates" default="false" type="boolean">
		<cfparam name="bFoundExceptions" default="false" type="boolean">
		<cfparam name="bFoundSQLQueries" default="false" type="boolean">
		<cfparam name="bFoundObjectQueries" default="false" type="boolean">
		<cfparam name="bFoundStoredProc" default="false" type="boolean">
		<cfparam name="bFoundTrace" default="false" type="boolean">
		<cfparam name="bFoundTimer" default="false" type="boolean">
		<cfparam name="bFoundLocking" default="false" type="boolean">
		<cfparam name="bFoundScopeVars" default="false" type="boolean">

		<cftry>
			<cfscript>
		        // no longer doing template query at the top since we have tree and summary mode
				bFoundTemplates = cfdebugger.check("Template");
				if( bFoundTemplates )
				{ displayDebug=true; }
				if ( isDefined("cfdebugger.settings.general") and cfdebugger.settings.general )
				{ bGeneral = true; displayDebug=true; }
				if (IsDefined("cfdebug_ex") AND cfdebug_ex.recordCount GT 0) { bFoundExceptions = true; displayDebug=true; }
				else { bFoundExceptions = false; }
				if (IsDefined("cfdebug_queries") AND cfdebug_queries.RecordCount GT 0) { bFoundSQLQueries = true; displayDebug=true; }
				else { bFoundSQLQueries = false; }
				if (IsDefined("cfdebug_cfoql") AND cfdebug_cfoql.RecordCount GT 0) { bFoundObjectQueries = true; displayDebug=true; }
				else { bFoundObjectQueries = false; }
				if (IsDefined("cfdebug_storedproc") AND cfdebug_storedproc.RecordCount GT 0) { bFoundStoredProc = true; displayDebug=true; }
				else { bFoundStoredProc = false; }
				if (IsDefined("cfdebug_trace") AND cfdebug_trace.recordCount GT 0) { bFoundTrace = true; displayDebug=true; }
				else { bFoundTrace = false; }
				if (IsDefined("cfdebug_timer") AND cfdebug_timer.recordCount GT 0) { bFoundTimer = true; displayDebug=true; }
				else { bFoundTimer = false; }
				if (IsDefined("cfdebug_lock") AND cfdebug_lock.recordCount GT 0) { bFoundLocking = true; displayDebug=true; }
				else { bFoundLocking = false; }
				if (IsDefined("cfdebugger") AND cfdebugger.check("Variables")) { bFoundScopeVars = true; displayDebug=true; }
				else { bFoundScopeVars = false; }
			</cfscript>
			<cfcatch type="Any"></cfcatch>
		</cftry>
		<cfset currentaddress = "#cgi.script_name#?#cgi.query_string#" />
		<!--- if the current address doesn't already include 'init', append it --->
		<cfif not StructKeyExists(url,"init")>
			<cfset currentaddress = currentaddress & "&init" />
		</cfif>
	</cfsilent>
<cfsetting enablecfoutputonly="no">
<style>
div#CFDdebugPanel{font-family:Arial,Helvetica,sans-serif; clear:both; font-size:11px; font-weight:normal; color:#000; background-color:#eee; text-align:left; margin-top:40px; padding:0}
.cfd-default-header{font-size:13px; font-weight:bold; color:#fff; background-color:#134A7A; padding:5px; cursor:pointer; border:1px outset #eee; margin:0;transition:background-color 250ms linear;}
.cfd-default-header:hover,.cfd-default-highlight{background-color:#B9D3FB; color:#000;cursor:pointer}
.CFDtemplate_overage{font-weight:bold; color:#C00}
.CFDdebugContent{display:none}
.CFDdebugContentView{padding:5px; display:block; margin:0;}
#CFDinfo label{font-weight:bold; float:left; width:140px; clear:left; height:20px}
#CFDinfo div{clear:right; height:20px}
.CFDrenderTime{margin-top:20px; margin-bottom:20px; font-weight:bold; font-style:italic}
.CFDdebugTables{font-size:11px; border:1px outset #93C2FF; background:#eee; width:99%;margin-bottom:0.5em;margin-top:0.1em}
.CFDdebugTables th{font-size:11px; background:#CFE9FF; font-weight:bold; padding:5px; text-align:center; color:#000}
.CFDdebugTables tr{background-color:#fff}
.CFDdebugTables tr:hover{background-color:#FEFFAF}
.CFDdebugTables td{padding:5px; font-size:11px}
.CFDdebugTables caption{font-size:12px;padding-left:10px;text-align:left;}
pre.cfdebugquery{margin:20px}
span.cfqueryparam, span.cfdebugcachedquery{color:blue}
h4.cfdebugvariable{font-size:1.1em; font-weight:bold; margin-top:10px}
h4.cfdebugqueryparam{font-weight:bold; padding-left:20px}
ul.cfdebugqueryparams{margin:0; padding:0; padding-left:35px}
ul.cfdebugqueryparams li{list-style:none; padding:2px 0}
ul.cfdebugqueryparams li span{color:blue}
.cfdebug code, .cfdebug pre, td.cfdebug, pre.cfdebugquery, #CFDscope pre{font-family:Consolas,Arial,sans-serif; line-height:1.5em}
.CFDdebugToolbar{padding:.5em; margin:0}
.CFDdebugButton{outline:0; margin:0 4px 0 0;padding:.4em 1em; text-decoration:none !important; cursor:pointer; position:relative; text-align:center; zoom:1}
.cfdTextRight{text-align:right}
.cfdTextCenter{text-align:center}
.cfdTextLeft{text-align:left}
.cfdRetKey{text-transform:lowercase;}
.cfdRetKey:after{ content: ":";}
.cfdRetVal{white-space:nowrap;width: 100%; overflow: hidden;text-overflow: ellipsis;display:inline-block;}
.CFDdebugTables tr:nth-child(even){background-color:#EFF6FF}
.CFDdebugTables tr:nth-child(even):hover{background-color:#FEFFAF}
span.CFDdebugLoader{background:url(//raw.github.com/joshknutson/coldfusion-debug/master/assets/images/loading.gif) no-repeat; padding-left:20px}
@media print {div#CFDdebugPanel{display:none;}}
</style>
<script>
function CFDtoggle(divid){if(document.getElementById(divid).className=="CFDdebugContent ui-widget-content"){document.getElementById(divid).className="CFDdebugContentView ui-widget-content";setCookie(divid,1);}else{document.getElementById(divid).className="CFDdebugContent ui-widget-content";setCookie(divid,0);}}
function setCookie(c_name,value){var expiredays=30;var exdate=new Date();exdate.setDate(exdate.getDate()+expiredays);document.cookie=c_name+"="+escape(value)+((expiredays==null)?"":";expires="+exdate.toGMTString());}
function addState(){var lis=document.getElementById("CFDdebugPanel").getElementsByTagName("H3");for(var i=0;i<lis.length;i++){lis[i].onmouseover=function(){this.className+=" cfd-default-highlight ui-state-highlight";};lis[i].onmouseout=function(){this.className=this.className.replace(new RegExp("cfd-default-highlight\\b"),"").replace(new RegExp("ui-state-highlight\\b"),"");}};}
function addLoadEvent(func){var oldonload=window.onload;if(typeof window.onload!='function'){window.onload=func;}else{window.onload=function(){if(oldonload){oldonload();}func();}}};addLoadEvent(addState);
try{if(typeof jQuery  == 'function'){jQuery('#reloadJax').delegate('click',function(event){var loadingText = '<span class="CFDdebugLoader">Loading..</span>';jQuery('#reloadJax').html(loadingText);jQuery.get("<cfoutput>#currentaddress#</cfoutput>", function(data){ jQuery('#reloadJax').text('AJAX Reinitialize');});event.preventDefault();});function addReload(){	var vhtml = '<a href="<cfoutput>#currentaddress#</cfoutput>"  class="CFDdebugButton ui-state-default ui-corner-all" title="AJAX Reinitialize" id="reloadJax">AJAX Reinitialize</a>';jQuery('#jaxReload').html(vhtml)};addLoadEvent(addReload);}}catch(err){}
</script>
<div id="CFDdebugPanel">
<cfif bGeneral>
<cfoutput>
	<cftry>
	<div class="ui-widget">
		<h3 class="cfd-default-header ui-widget-header" onclick="CFDtoggle('CFDinfo')">&gt; Debugging Information</h3>
		<div class="CFDdebugToolbar ui-widget-content">
			<a href="#currentaddress#" class="CFDdebugButton ui-state-default ui-corner-all" title="Reinitialize">Reinitialize</a>
			<span id="jaxReload">&nbsp;</span>
			<cfif bFoundSQLQueries>
				<!--- get total cfquery execution time --->
				<cfquery name="total_cfquery" dbtype="query" debug="false">
				select	sum(executiontime) as total
				from cfdebug_queries
				</cfquery>
				<cfset totalQueryTime = total_cfquery.total>
				<cfquery dbType="query" name="cfdebug_execution" debug="false">
			      	SELECT (endTime - startTime) AS executionTime
			      	FROM qEvents
			      	WHERE type = 'ExecutionTime'
			  	</cfquery>
			  	<div class="CFDdebugContentView  ui-widget-content">
	                <div><em>#totalQueryTime# ms : TOTAL QUERY TIME <cfif totalQueryTime gt 0>(#lsNumberFormat(totalQueryTime/cfdebug_execution.executiontime*100,"99.99")# % of Total)</cfif></em></div>
	           	</div>
			</cfif>
		</div>
		<div class="CFDdebugContent<cfif structkeyexists(cookie,"CFDinfo") and cookie.CFDinfo>View</cfif> ui-widget-content" id="CFDinfo">
			<label title="#server.coldfusion.productname#">#server.coldfusion.productname#</label>
			<div>#server.coldfusion.productversion#</div>
			<label title="Template"> Template </label>
			<div>#xmlFormat(CGI.Script_Name)#</div>
			<label title="Time Stamp"> Time Stamp </label>
			<div>#DateFormat(Now())# #TimeFormat(Now())#</div>
			<label title="Locale"> Locale </label>
			<div>#GetLocale()#</div>
			<label title="User Agent"> User Agent </label>
			<div>#CGI.HTTP_USER_AGENT#</div>
			<label title="Remote IP"> Remote IP </label>
			<div>#CGI.REMOTE_ADDR#</div>
			<label title="Host Name"> Host Name </label>
			<div>#CGI.REMOTE_HOST#</div>
		</div>
	</div>
	<cfcatch type="Any"></cfcatch>
	</cftry>
</cfoutput>
</cfif>

<!--- Template Stack and Executions Times --->
<cfif bFoundTemplates>
  	<!--- Total Execution Time of all top level pages --->
  	<cfquery dbType="query" name="cfdebug_execution" debug="false">
      	SELECT (endTime - startTime) AS executionTime
      	FROM qEvents
      	WHERE type = 'ExecutionTime'
  	</cfquery>
	<!--- ::
		in the case that no execution time is recorded.
		we will add a value of -1 so we know that a problem exists but the template continues to run properly.
		:: --->
	<cfif not cfdebug_execution.recordCount>
		<cfscript>
			queryAddRow(cfdebug_execution);
			querySetCell(cfdebug_execution, "executionTime", "-1");
		</cfscript>
	</cfif>

  	<cfquery dbType="query" name="cfdebug_top_level_execution_sum" debug="false">
  		SELECT sum(endTime - startTime) AS executionTime
	  	FROM qEvents
  		WHERE type = 'Template' AND parent = ''
  	</cfquery>

    <!--- File not found will not produce any records when looking for top level pages --->
    <cfif cfdebug_top_level_execution_sum.recordCount and len(trim(cfdebug_top_level_execution_sum.executionTime[1])) gt 0>
        <cfset time_other = Max(cfdebug_execution.executionTime - val(cfdebug_top_level_execution_sum.executionTime), 0)>
        <cfoutput>
			<div class="ui-widget">
       		<h3 class="cfd-default-header ui-widget-header" onclick="CFDtoggle('CFDexecution')">&gt; Execution Time</h3>
			<div class="CFDdebugContent<cfif structkeyexists(cookie,"CFDexecution") and cookie.CFDexecution>View</cfif> ui-widget-content" id="CFDexecution">
        </cfoutput>

        <cfif cfdebugger.settings.template_mode EQ "tree">
            <cfset a = arrayNew(1)>
            <cfloop query="qEvents">
               <cfscript>
                    // only want templates, IMQ of SELECT * ...where type = 'template' will result
                    // in cannot convert the value "" to a boolean for cachedquery column
                    // SELECT stacktrace will result in Query Of Queries runtime error.
                    // Failed to get meta_data for columnqEvents.stacktrace .
                    // Was told I need to define meta data for debugging event table similar to <cfldap>
                    if( qEvents.type eq "template" ) {
                        st = structNew();
                        st.StackTrace = qEvents.stackTrace;
                        st.template = qEvents.template;
                        st.startTime = qEvents.starttime;
                        st.endTime = qEvents.endtime;
                        st.parent =  qEvents.parent;
                        st.line =  qEvents.line;

                        arrayAppend(a, st);
                    }
               </cfscript>
            </cfloop>
            <cfset qTree = queryNew("template,templateId,parentId,duration,line") />
            <cfloop index="i" from="1" to="#arrayLen(a)#">
                <cfset childidList = "" />
                <cfset parentidList = "" />
                <cfloop index="x" from="#arrayLen(a[i].stacktrace.tagcontext)#" to="1" step="-1">
                    <cfscript>
                        if( a[i].stacktrace.tagcontext[x].id NEQ "CF_INDEX" ) {
                            // keep appending the line number from the template stack to form a unique id
                            childIdList = listAppend(childIdList, a[i].stacktrace.tagcontext[x].line);
                            if( x eq 1 ) {
                                //parentIdList = listAppend(parentIdList, a[i].stacktrace.tagcontext[x].template);
								raw_trace = a[i].stacktrace.tagcontext[x].raw_trace;
                                findFunctionPrefix = "$func"; // set prefix to account for length and position since CF doesn't have RegEx lookbehind assertion
                                findFunction = ReFindNoCase("(?=\" & findFunctionPrefix & ").*(?=\.runFunction\()",raw_trace,1,true);
                                if( findFunction.len[1] NEQ 0 AND findFunction.pos[1] NEQ 0 ) {
                                    // get function name from raw_trace to allow for proper application.cfc tree rendering
                                    parentfunction = Trim(Mid(raw_trace, findFunction.pos[1] + Len(findFunctionPrefix), findFunction.len[1] - Len(findFunctionPrefix)));
                                    // append the function name (pulled from raw_trace) to the cfc template for tree root comparison.
                                    parentIdList = listAppend(parentIdList, a[i].stacktrace.tagcontext[x].template & " | " & lcase(parentfunction));
                                }else {
                                	parentIdList = listAppend(parentIdList, a[i].stacktrace.tagcontext[x].template);
								}
                            } else {
                                parentIdList = listAppend(parentIdList, a[i].stacktrace.tagcontext[x].line);
                            }
                        }
                    </cfscript>
                </cfloop>

                <cfscript>
                    // template is the last part of the unique id...12,5,17,c:\wwwroot\foo.cfm
                    // if we don't remove the "CFC[" prefix, then the parentId and childId relationship
                    // will be all wrong
                    startToken = "CFC[ ";
                    endToken = " | ";
                    thisTemplate = a[i].template;
                    startTokenIndex = FindNoCase(startToken, thisTemplate, 1);
                    if( startTokenIndex NEQ 0 ) {
                        endTokenIndex = FindNoCase(endToken, thisTemplate, startTokenIndex);
                        thisTemplate = Trim(Mid(thisTemplate,Len(startToken),endTokenIndex-Len(startToken)));
                    }
                    childIdList = listAppend(childIdList, thisTemplate);

                    queryAddRow(qTree);
                    querySetCell(qTree, "template", a[i].template);
                    querySetCell(qTree, "templateId", childIdList);
                    querySetCell(qTree, "parentId", parentIdList);
                    querySetCell(qTree, "duration", a[i].endtime - a[i].starttime);
                    querySetCell(qTree, "line", a[i].line);
                </cfscript>
            </cfloop>

            <cfset stTree = structNew()>
            <cfloop query="qTree">
                <cfscript>
                // empty parent assumed to be top level with the exception of application.cfm
                if( len(trim(parentId)) eq 0 ){
                    parentId = 0;
                }
                    stTree[parentId] = structNew();
                    stTree[parentId].templateId = qTree.templateId;
                    stTree[parentId].template = qTree.template;
                    stTree[parentId].duration = qTree.duration;
                    stTree[parentId].line = qTree.line;
                    stTree[parentId].children = arrayNew(1);
                </cfscript>
            </cfloop>
            <cfloop query="qTree">
                <cfscript>
                    stTree[templateId] = structNew();
                    stTree[templateId].templateId = qTree.templateId;
                    stTree[templateId].template = qTree.template;
                    stTree[templateId].duration = qTree.duration;
                    stTree[templateId].line = qTree.line;
                    stTree[templateId].children = arrayNew(1);
                </cfscript>
            </cfloop>
            <cfloop query="qTree">
                <cfscript>
                    arrayAppend(stTree[parentId].children, stTree[templateId]);
                </cfscript>
            </cfloop>

            <cfquery dbType="query" name="topNodes" debug="false">
                SELECT parentId, templateid
                FROM qTree
                WHERE parentId = ''
            </cfquery>

            <cfoutput query="topNodes">
                #drawTree(stTree,-1,topNodes.templateid,cfdebugger.settings.template_highlight_minimum)#
            </cfoutput>
            <cfoutput><p class="template">
                (#time_other# ms) STARTUP, PARSING, COMPILING, LOADING, &amp; SHUTDOWN<br />
                (#cfdebug_execution.executionTime# ms) TOTAL EXECUTION TIME<br />
               <span class="CFDtemplate_overage">red = over #cfdebugger.settings.template_highlight_minimum# ms execution time</span>
                </p></cfoutput>
        <cfelse>
        	<cftry>
                <cfquery dbType="query" name="cfdebug_templates_summary" debug="false">
	                SELECT  template, Sum(endTime - startTime) AS totalExecutionTime, count(template) AS instances
	                FROM qEvents
	                WHERE type = 'Template'
	                group by template
	                order by totalExecutionTime DESC
                </cfquery>
                <cfoutput>
                <table class="CFDdebugTables">
					<caption class="cfdTextLeft"><span class="CFDtemplate_overage">red = over #cfdebugger.settings.template_highlight_minimum# ms average execution time</span></caption>
					<thead>
					  <tr>
						<th width="13%">Total Time</th>
						<th>Avg Time</td>
						<th>Count</th>
						<th>Template</th>
					</tr>
				</thead>
                </cfoutput>
                <cftry>
					<tbody>
                    <cfoutput query="cfdebug_templates_summary">
                       <cfsilent>
							 <cfset templateOutput = template>
	                        <cfset templateAverageTime = Round(totalExecutionTime / instances)>

	                        <cfif template EQ ExpandPath(cgi.script_name)>
	                            <cfset templateOutput = "<img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/topdoc.gif' alt='top level' border='0'> " &
	                                "<strong>" & template & "</strong>">
								 <cfif templateAverageTime GT cfdebugger.settings.template_highlight_minimum>
	                                <cfset templateOutput = "<span class='CFDtemplate_overage'>" & template & "</span>">
	                                <cfset templateAverageTime = "<span class='CFDtemplate_overage'>" & templateAverageTime & "</span>">
									<cfset totalTime = "<span class='CFDtemplate_overage'>" & totalExecutionTime & "</span>">
	                            </cfif>
	                        <cfelse>
	                            <cfif templateAverageTime GT cfdebugger.settings.template_highlight_minimum>
	                                <cfset templateOutput = "<span class='CFDtemplate_overage'>" & template & "</span>">
	                                <cfset templateAverageTime = "<span class='CFDtemplate_overage'>" & templateAverageTime & "</span>">
									<cfset totalTime = "<span class='CFDtemplate_overage'>" & totalExecutionTime & "</span>">
	                            </cfif>
	                        </cfif>
						</cfsilent>
                        <tr>
							<cfif isDefined("totalTime") and len(trim(totalTime))>
								<td class="cfdebug cfdTextRight">#totalTime# ms</td>
								<cfset totalTime = "">
							<cfelse>
    	                        <td class="cfdebug cfdTextRight">#totalExecutionTime# ms</td>
							</cfif>
                            <td class="cfdebug cfdTextRight">#templateAverageTime# ms</td>
                            <td class="cfdebug cfdTextCenter">#instances#</td>
                            <td class="cfdebug cfdTextLeft">#templateOutput#</td>
                        </tr>
                       </cfoutput>
					</tbody>
                	<cfcatch type="Any"></cfcatch>
                </cftry>
                <cfoutput>
					<tfoot>
		                <tr>
							<td class="cfdebug cfdTextRight"><em>#time_other# ms</em></td><td colspan=2>&nbsp;</td>
		                    <td class="cfdebug cfdTextLeft"><em>STARTUP, PARSING, COMPILING, LOADING, &amp; SHUTDOWN</em></td>
						</tr>
		                <tr>
							<td class="cfdebug cfdTextRight"><em>#cfdebug_execution.executionTime# ms</em></td><td colspan=2>&nbsp;</td>
		                    <td class="cfdebug cfdTextLeft"><em>TOTAL EXECUTION TIME</em></td>
						</tr>
						<!--- inspired by one of Ray Camden's Templates  --->
						<cfif bFoundSQLQueries>
							<!--- get total cfquery execution time --->
							<cfquery name="total_cfquery" dbtype="query">
							select	sum(executiontime) as total
							from cfdebug_queries
							</cfquery>
							<cfset totalQueryTime = total_cfquery.total>
	                		<tr>
								<td class="cfdebug cfdTextRight"><em>#totalQueryTime# ms</em></td><td colspan=2>&nbsp;</td>
	                    		<td class="cfdebug cfdTextLeft"><em>TOTAL QUERY TIME <cfif totalQueryTime gt 0>(#lsNumberFormat(totalQueryTime/cfdebug_execution.executiontime*100,"99.99")# % of Total)</cfif></em></td>
							</tr>
						</cfif>
					</tfoot>
            	</table>
				</div>
			</div>
				</cfoutput>
        	<cfcatch type="Any"></cfcatch>
        	</cftry>
        </cfif> <!--- template_mode = summary--->
    <cfelse>
	<div class="ui-widget">
        <h3 class="cfd-default-header ui-widget-header" onclick="CFDtoggle('CFDexecution')">&gt; Execution Time</h3>
        <div class="ui-widget-content">No top level page was found.</div>
	</div>
    </cfif> <!--- if top level templates are available --->
</cfif>

<!--- CFCS --->
<cfsilent>
	<cfquery dbType="query" name="cfcs" debug="false">
		select template, (endTime - startTime) as et, [timestamp]
		from qEvents
		where type = 'Template'
		and template like 'CFC[[ %'
		escape '['
		group by template, [timestamp], startTime, endTime
	</cfquery>
	<cfset cfcData = structNew()>
	<cfloop query="cfcs">
		<cfset tString = replaceNoCase(template, "CFC[ ", "")>
		<cfset tString = reReplace(tString, "] from .*", "")>
		<cfset theCFC = trim(listFirst(tString, "|"))>
		<cfset theMethod = trim(listLast(tString, "|"))>
		<!--- remove args --->
		<cfset theMethod = trim(reReplaceNoCase(theMethod, "\(.*?\).*", "()"))>
		<cfif not structKeyExists(cfcData, theCFC)>
			<cfset cfcData[theCFC] = structNew()>
		</cfif>
		<cfif not structKeyExists(cfcData[theCFC], theMethod)>
			<cfset cfcData[theCFC][theMethod] = structNew()>
			<cfset cfcData[theCFC][theMethod].count = 0>
			<cfset cfcData[theCFC][theMethod].total = 0>
		</cfif>
		<cfset cfcData[theCFC][theMethod].count = cfcData[theCFC][theMethod].count + 1>
		<cfset cfcData[theCFC][theMethod].total = cfcData[theCFC][theMethod].total + et>
	</cfloop>
</cfsilent>
<!--- make averages --->
<cfloop item="cfc" collection="#cfcData#">
	<cfloop item="method" collection="#cfcdata[cfc]#">
		<cfset cfcdata[cfc][method].average = cfcdata[cfc][method].total / cfcdata[cfc][method].count>
	</cfloop>
</cfloop>
<cfif cfcs.recordcount>
<cfoutput>
<div class="ui-widget">
	<h3 class="cfd-default-header ui-widget-header" onclick="CFDtoggle('CFDcfc')">&gt; CFC Data</h3>
	<div class="CFDdebugContent<cfif structkeyexists(cookie,"CFDcfc") and cookie.CFDcfc>View</cfif> ui-widget-content" id="CFDcfc">
		<table class="CFDdebugTables">
		<thead>
			<tr>
				<th>Total Time</th>
				<th>Avg Time</th>
				<th>Count</th>
				<th>CFC</th>
				<th>Method</th>
			</tr>
		</thead>
		<tbody>
		<cfloop item="cfc" collection="#cfcData#">
			<cfloop item="method" collection="#cfcdata[cfc]#">
			<tr>
				<td class="cfdTextRight">#cfcdata[cfc][method].total# ms</td>
				<td>#numberFormat(cfcdata[cfc][method].average,"00.00")# ms</td>
				<td>#cfcdata[cfc][method].count#</td>
				<td>#cfc#</td>
				<td>#method#</td>
			</tr>
			</cfloop>
		</cfloop>
		</tbody>
		</table>
	</div>
</div>
</cfoutput>
</cfif>

<!--- Exceptions --->
<cfif bFoundExceptions>
<cftry>
<cfoutput>
<div class="ui-widget">
	<h3 class="cfd-default-header ui-widget-header" onclick="CFDtoggle('CFDexceptions');">&gt; Exceptions</h3>
	<div class="CFDdebugContent<cfif structkeyexists(cookie,"CFDexceptions") and cookie.CFDexceptions>View</cfif> ui-widget-content" id="CFDexceptions">
	<cfloop query="cfdebug_ex">
	    <div class="cfdebug">#TimeFormat(cfdebug_ex.timestamp, "HH:mm:ss.SSS")# - #cfdebug_ex.name# <cfif FindNoCase("Exception", cfdebug_ex.name) EQ 0>Exception</cfif> - in #cfdebug_ex.template# : line #cfdebug_ex.line#</div>
	    <cfif IsDefined("cfdebug_ex.message") AND Len(Trim(cfdebug_ex.message)) GT 0>
	    <pre>
	    #cfdebug_ex.message#
	    </pre>
	    </cfif>
	</cfloop>
	</div>
</div>
</cfoutput>
	<cfcatch type="Any">
		<!--- Error reporting an exception event entry. --->
	</cfcatch>
</cftry>
</cfif>

<!--- SQL Queries --->
<cfoutput>
<cfif bFoundSQLQueries>
	<cftry>
	<div class="ui-widget">
		<h3 class="cfd-default-header ui-widget-header" onclick="CFDtoggle('CFDsql');">&gt; SQL Queries</h3>
		<div class="CFDdebugContent<cfif structkeyexists(cookie,"CFDsql") and cookie.CFDsql>View</cfif> ui-widget-content" id="CFDsql">
		<cfloop query="cfdebug_queries">
			<strong>#cfdebug_queries.name#</strong> (Datasource=#cfdebug_queries.datasource#, <span<cfif cfdebug_queries.executiontime gt cfdebugger.settings.template_highlight_minimum> class="CFDtemplate_overage" </cfif>>Time=#Max(cfdebug_queries.executionTime, 0)#ms</span><cfif IsDefined("cfdebug_queries.rowcount") AND IsNumeric(cfdebug_queries.rowcount)>, Records=#Max(cfdebug_queries.rowcount, 0)#<cfelseif IsDefined("cfdebug_queries.result.recordCount")>, Records=#cfdebug_queries.result.recordCount#</cfif><cfif cfdebug_queries.cachedquery>, <span class="cfdebugcachedquery">Cached Query</span></cfif>) in #cfdebug_queries.template# @ #TimeFormat(cfdebug_queries.timestamp, "HH:mm:ss.SSS")#<br />
			<cfset theBody = cfdebug_queries.body>
			<cfif arrayLen(cfdebug_queries.attributes) GT 0>
           		<cfloop from="1" to="#arrayLen(cfdebug_queries.attributes)#" index="i">
           			<cfset stThisParam = cfdebug_queries.attributes[cfdebug_queries.currentRow][i]>
           			<cfswitch expression="#stThisParam.sqlType#">
           				<cfcase value="cf_sql_datetime,cf_sql_date,cf_sql_integer" delimiters=",">
           					<cfset thisParam = stThisParam.value>
           				</cfcase>
           				<cfcase value="cf_sql_bit">
           					<cfif stThisParam.value>
           						<cfset thisParam = "'1'">
           					<cfelse>
           						<cfset thisParam = "'0'">
           					</cfif>
           				</cfcase>
           				<cfdefaultcase>
           					<cfset thisParam = "'#stThisParam.value#'">
           				</cfdefaultcase>
           			</cfswitch>
           			<cfset thisParam = '<span class="cfqueryparam">#thisParam#</span>'>
           			<cfset theBody = replace(theBody, '?', thisParam)>
				</cfloop>
			</cfif>

			<!--- remove empty lines --->
			<cfset newBody = "" />
			<cfloop list="#theBody#" index="i" delimiters="#chr(13)#">
				<cfset newLine = trim(i) />
				<cfif newLine neq "">
					<cfif newBody eq "">
						<cfset newBody = newLine />
					<cfelse>
						<cfset newBody = newBody & chr(13) & newLine />
					</cfif>
				</cfif>
			</cfloop>

			<!--- replace tabs --->
			<cfset newBody = replace(newBody,chr(9),"","all") />

			<pre class="cfdebugquery">#newBody#</pre>

			<cfif arrayLen(cfdebug_queries.attributes) GT 0>
			    <h4 class="cfdebugqueryparam">Query Parameter Value(s)</h4>
			    <ul class="cfdebugqueryparams">
			    <cfloop index="x" from="1" to="#arrayLen(cfdebug_queries.attributes)#">
	        		<cfset thisParam = #cfdebug_queries.attributes[cfdebug_queries.currentRow][x]#>
	        		<cfset class="" />
	        		<cfif x eq 1>
	        			<cfset class="first">
	        		<cfelseif x eq arrayLen(cfdebug_queries.attributes)>
	        			<cfset class="last">
	        		</cfif>
			        <li class="#class#">Parameter ###x#<cfif StructKeyExists(thisParam, "sqlType")>(#thisParam.sqlType#)</cfif> = <cfif StructKeyExists(thisParam, "value")><span>#htmleditformat(thisParam.value)#</span></cfif></li>
			    </cfloop>
			   </ul>
			    <br />
			</cfif>
		</cfloop>
		</div>
	</div>
	<cfcatch type="Any">
		<!--- Error reporting query event --->
	</cfcatch>
</cftry>
</cfif>

<!--- Stored Procs --->
<cfif bFoundStoredProc>
<cftry>
<div class="ui-widget">
<h3 class="cfd-default-header ui-widget-header" onclick="CFDtoggle('CFDprocedures')">&gt; Stored Procedures</h3>
<div class="CFDdebugContent<cfif structkeyexists(cookie,"CFDprocedures") and cookie.CFDprocedures>View</cfif> ui-widget-content" id="CFDprocedures">
<cfloop query="cfdebug_storedproc">
<!--- Output stored procedure details, remember, include result (output params) and attributes (input params) columns --->
    <fieldset>
	<legend><strong>#cfdebug_storedproc.name#</strong> (Datasource=#cfdebug_storedproc.datasource#, <span<cfif cfdebug_storedproc.executionTime gt cfdebugger.settings.template_highlight_minimum> class="CFDtemplate_overage" </cfif>>Time=#Max(cfdebug_storedproc.executionTime, 0)#ms</span>) in #cfdebug_storedproc.template# @ #TimeFormat(cfdebug_storedproc.timestamp, "HH:mm:ss.SSS")#</caption>
	</legend>
            <table class="CFDdebugTables">
			<caption>Parameters</caption>
			<thead>
	            <tr>
					<th>type</th>
					<th>CFSQLType</th>
					<th>value</th>
					<th>variable</th>
					<th>dbVarName</th>
				</tr>
			</thead>
			<tbody>
            <cfloop index="x" from=1 to="#arrayLen(cfdebug_storedproc.attributes)#">
            <cfset thisParam = #cfdebug_storedproc.attributes[cfdebug_storedproc.currentRow][x]#>
            <tr>
                <td>&nbsp;<cfif StructKeyExists(thisParam, "type")>#thisParam.type#</cfif></td>
                <td>&nbsp;<cfif StructKeyExists(thisParam, "sqlType")>#thisParam.sqlType#</cfif></td>
                <td>&nbsp;<cfif StructKeyExists(thisParam, "value")>#htmleditformat(thisParam.value)#</cfif></td>
                <td>&nbsp;<cfif StructKeyExists(thisParam, "variable")>#thisParam.variable# = #CFDebugSerializable(thisParam.variable)#</cfif></td>
                <td>&nbsp;<cfif StructKeyExists(thisParam, "dbVarName")>#thisParam.dbVarName#</cfif></td>
            </tr>
            </cfloop>
			</tbody>
            </table>

            <table class="CFDdebugTables">
            <caption>Result Sets</caption>
			<thead>
            <tr><th>name</th><th>resultset</th></tr>
			</thead>
			<tbody>
			<cfif arrayLen(cfdebug_storedproc.result)>
            <cfloop index="x" from=1 to="#arrayLen(cfdebug_storedproc.result)#">
            <cfset thisParam = #cfdebug_storedproc.result[cfdebug_storedproc.currentRow][x]#>
            <tr>
                <td>&nbsp;<cfif StructKeyExists(thisParam, "name")>#thisParam.name#</cfif></td>
                <td>&nbsp;<cfif StructKeyExists(thisParam, "resultSet")>#thisParam.resultSet#</cfif></td>
            </tr>
            </cfloop>
			<cfelse>
			<tr><td colspan="100%">No results returned</td></tr>
			</cfif>
			</tbody>
            </table>
       </fieldset>
</cfloop>
</div>
</div>
	<cfcatch type="Any">
		<!--- Error reporting stored proc event --->
	</cfcatch>
</cftry>
</cfif>

<!--- :: CFTimer :: --->
<cfif bFoundTimer>
	<div class="ui-widget">
		<h3 class="cfd-default-header ui-widget-header" onclick="CFDtoggle('CFDtimer')">&gt;CFTimer Times</h3>
		<p class="cfdebug">
		<cfloop query="cfdebug_timer">
		    <cftry>
		    	<img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/#Replace(cfdebug_timer.priority, " ", "%20")#_16x16.gif' alt="#cfdebug_timer.priority# type">
				 [#val(cfdebug_timer.endTime) - val(cfdebug_timer.startTime)#ms] <em>#cfdebug_timer.message#</em><br />
		    	<cfcatch type="Any"></cfcatch>
		    </cftry>
		</cfloop>
		</p>
	</div>
</cfif>

<!--- Tracing --->
<cfif bFoundTrace>
	<div class="ui-widget">
		<h3 class="cfd-default-header ui-widget-header" onclick="CFDtoggle('CFDpoints')">&gt;Trace Points</h3>
		<p class="cfdebug">

		<cfset firstTrace=true>
		<cfset prevDelta=0>
		<cfloop query="cfdebug_trace">
		    <cfset deltaFromRequest = Val(cfdebug_trace.endTime)>
		    <cfset deltaFromLast = Val(deltaFromRequest-prevDelta)>
		    <cftry>
		    	<img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/#Replace(cfdebug_trace.priority, " ", "%20")#_16x16.gif' alt="#cfdebug_trace.priority# type"> [#TimeFormat(cfdebug_trace.timestamp, "HH:mm:ss.lll")# #cfdebug_trace.template# @ line: #cfdebug_trace.line#] [#deltaFromRequest# ms (<cfif firstTrace>1st trace<cfelse>#deltaFromLast# ms</cfif>)] - <cfif #cfdebug_trace.category# NEQ "">[#cfdebug_trace.category#]</cfif> <cfif #cfdebug_trace.result# NEQ "">[#cfdebug_trace.result#]</cfif> <em>#cfdebug_trace.message#</em><br />
		    	<cfcatch type="Any"></cfcatch>
		    </cftry>
		    <cfset prevDelta = deltaFromRequest>
		    <cfset firstTrace=false>
		</cfloop>
		</p>
	</div>
</cfif>

<!--- SCOPE VARIABLES --->
<cfif bFoundScopeVars>
<div class="ui-widget">
<h3 class="cfd-default-header ui-widget-header" onclick="CFDtoggle('CFDscope')">&gt; Scope Variables</h3>
<div class="CFDdebugContent<cfif structkeyexists(cookie,"CFDscope") and cookie.CFDscope>View</cfif> ui-widget-content" id="CFDscope">
<cftry>
<cfif IsDefined("APPLICATION") AND IsStruct(APPLICATION) AND StructCount(APPLICATION) GT 0 AND cfdebugger.check("ApplicationVar")>
<h4 class="cfdebugvariable">Application Variables:</h4>
<pre>#sortedScope(application)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("CGI") AND IsStruct(CGI) AND StructCount(CGI) GT 0 AND cfdebugger.check("CGIVar")>
<h4 class="cfdebugvariable">CGI Variables:</h4>
<pre>#sortedScope(cgi)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("CLIENT") AND IsStruct(CLIENT) AND StructCount(CLIENT) GT 0 AND cfdebugger.check("ClientVar")>
<h4 class="cfdebugvariable">Client Variables:</h4>
<pre>#sortedScope(client)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("COOKIE") AND IsStruct(COOKIE) AND StructCount(COOKIE) GT 0 AND cfdebugger.check("CookieVar")>
<h4 class="cfdebugvariable">Cookie Variables:</h4>
<pre>#sortedScope(cookie)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("FORM") AND IsStruct(FORM) AND StructCount(FORM) GT 0 AND cfdebugger.check("FormVar")>
<h4 class="cfdebugvariable">Form Fields:</h4>
<pre>#sortedScope(form)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("REQUEST") AND IsStruct(REQUEST) AND StructCount(REQUEST) GT 0 AND cfdebugger.check("RequestVar")>
<h4 class="cfdebugvariable">Request Parameters:</h4>
<pre>#sortedScope(request)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("SERVER") AND IsStruct(SERVER) AND StructCount(SERVER) GT 0 AND cfdebugger.check("ServerVar")>
<h4 class="cfdebugvariable">Server Variables:</h4>
<pre>#sortedScope(server)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("SESSION") AND IsStruct(SESSION) AND StructCount(SESSION) GT 0 AND cfdebugger.check("SessionVar")>
<h4 class="cfdebugvariable">Session Variables:</h4>
<pre>#sortedScope(session)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>

<cftry>
<cfif IsDefined("URL") AND IsStruct(URL) AND StructCount(URL) GT 0 AND cfdebugger.check("URLVar")>
<h4 class="cfdebugvariable">URL Parameters:</h4>
<pre>#sortedScope(url)#</pre>
</cfif>
<cfcatch type="Any"></cfcatch>
</cftry>
</cfif>

<cfset duration = getTickCount() - startTime>
<cfif displayDebug>
<pre class="cfdebug CFDrenderTime"><em>Debug Rendering Time: #duration# ms</em></pre><br />
</cfif>
</cfoutput>
</div>
</div>
</div>
<cfsetting enablecfoutputonly="No">
</cfif>

<cfscript>
//UDF - Handle output of complex data types.
function CFDebugSerializable(variable){
var ret = "";
	try{
			if(IsSimpleValue(variable)){
				ret = xmlFormat(variable);
			}else{
				if (IsStruct(variable)){
					ret = ("Struct (" & StructCount(variable) & ")");
				}
				else if(IsArray(variable)){
					ret = ("Array (" & ArrayLen(variable) & ")");
				}
				else if(IsQuery(variable)){
					ret = ("Query (" & variable.RecordCount & ")");
				}else{
					ret = ("Complex type");
				}
			}
	}catch("any" ex){
        ret = "undefined";
    }
    return ret;
}
// UDF - tree writing
function drawNode(nTree, indent, id, highlightThreshold) {
    var templateOuput = "";
    if( nTree[id].duration GT highlightThreshold ) {
        templateOutput = "<span class='CFDCFDtemplate_overage'>(#nTree[id].duration#ms) " & nTree[id].template & " @ line " & #nTree[id].line# & "</span><br />";
    } else {
        templateOutput = "<span class='template'>(#nTree[id].duration#ms) " & nTree[id].template & " @ line " & #nTree[id].line# & "</span><br />";
    }
    writeOutput(repeatString("&nbsp;&nbsp;&middot;", indent + 1) & " <img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/arrow.gif' alt='arrow' border='0'><img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/endDoc.gif' alt='top level' border='0'> " & templateOutput);
    return "";
}

function drawTree(tree, indent, id, highlightThreshold) {
    var alength = 1;
    var i = 1;
    var templateOuput = "";

	if( structKeyExists(tree, id)){
	    // top level nodes (application.cfm,cgi.script_name,etc) have a -1 parent line number
	    if(tree[id].line EQ -1) {
			if( Tree[id].duration GT highlightThreshold ){
	        	writeoutput( "<img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/topdoc.gif' alt='top level' border='0'> " & "<span class='CFDCFDtemplate_overage'><strong>(#Tree[id].duration#ms) " & Tree[id].template & "</strong></span><br />" );
			}else{
				writeoutput( "<img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/topdoc.gif' alt='top level' border='0'> " & "<span class='template'><strong>(#Tree[id].duration#ms) " & Tree[id].template & "</strong></span><br />" );
			}
	    } else {
	        if( Tree[id].duration GT highlightThreshold ) {
	            templateOutput = "<span class='CFDtemplate_overage'>(#Tree[id].duration#ms) " & Tree[id].template & " @ line " & #Tree[id].line# & "</span><br />";
	        } else {
	            templateOutput = "<span class='template'>(#Tree[id].duration#ms) " & Tree[id].template & " @ line " & #Tree[id].line# & "</span><br />";
	        }
	        writeoutput( repeatString("&nbsp;&nbsp;&middot;", indent + 1) & " <img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/arrow.gif' alt='arrow' border='0'><img src='#getpageContext().getRequest().getContextPath()#/CFIDE/debug/images/parentDoc.gif' alt='top level' border='0'> " & templateOutput );
	    }

	    if( isArray( tree[id].children ) and arrayLen( tree[id].children ) ) {
	        alength = arrayLen( tree[id].children );
	        for( i = 1; i lte alength; i = i + 1 ) {
	            if( isArray(tree[id].children[i].children) and arrayLen( tree[id].children[i].children ) gt 0 ) {
	                drawTree(tree, indent + 1, tree[id].children[i].templateid, highlightThreshold);
	            } else {
	                drawNode(tree, indent + 1, tree[id].children[i].templateid, highlightThreshold);
	            }
	        }
	    } else {
	        // single template, no includes?
	        //drawNode(tree, indent + 1, tree[id].template, highlightThreshold);
	    }
	}
    return "";
}
</cfscript>

<cffunction name="sortedScope" output="false">
    <cfargument name="scope" />
    <cfset retVal='' />
    <cfset keys = structKeyArray(scope) />
    <cfset arraySort(keys,"text") />
    <cfloop index="x" from=1 to="#arrayLen(keys)#">
    	<cfset keyName = keys[x] />
    	<cfif isSimpleValue(keyName) and keyName neq "">

		<cfset retVal = retVal & '<dt class="cfdRetKey">' />
        <cfset retVal = retVal & keyName & "</dt><dd class='cfdRetVal'>" />
        	<cfset keyValue = "&nbsp;" />
           <cftry>
    		    <cfset keyValue = CFDebugSerializable(scope[keyname]) />
    		<cfcatch>
    			<cfset keyValue = "undefined" />
           	</cfcatch>
      	    </cftry>
        <cfset retVal = retVal & keyValue & "</dd>" />
    	</cfif>
    </cfloop>
	<cfset retVal = "<dl class='cfdRet'>#retVal#</dl>" />
    <cfreturn trim(retVal) />
</cffunction>